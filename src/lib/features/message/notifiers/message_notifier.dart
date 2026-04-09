import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:altoproject/core/models/contact.dart';
import 'package:altoproject/services/crypto_service.dart';
import 'package:altoproject/services/element_api_service.dart';
import 'package:altoproject/services/key_storage.dart';
import 'package:altoproject/services/message_storage_service.dart';
import '../models/message.dart';

/// Limite max de caractères pour RSA-2048 OAEP (≈ 214 bytes UTF-8).
const int kMaxMessageLength = 190;

class MessageNotifier extends StateNotifier<MessageState> {
  final ElementApiService _elementApi;
  final KeyStorage _keyStorage;
  final MessageStorageService _storage;
  final Contact _contact;

  Timer? _refreshTimer;
  static const _autoRefreshInterval = Duration(seconds: 5);

  MessageNotifier({
    required ElementApiService elementApi,
    required KeyStorage keyStorage,
    required MessageStorageService storage,
    required Contact contact,
  })  : _elementApi = elementApi,
        _keyStorage = keyStorage,
        _storage = storage,
        _contact = contact,
        super(MessageState.initial()) {
    _loadAndRefresh();
  }

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Charge l'historique local puis lance le polling réseau.
  Future<void> _loadAndRefresh() async {
    await _loadLocalMessages();
    receiveMessages();
    _startAutoRefresh();
  }

  /// Charge les messages persistés localement.
  Future<void> _loadLocalMessages() async {
    try {
      final stored = await _storage.getMessages(_contact.id);
      if (stored.isEmpty) return;
      final messages = stored
          .map((s) => Message(
                id: s.id,
                type: s.type,
                content: s.content,
                isMine: s.isMine,
                timestamp: s.timestamp,
              ))
          .toList();
      state = state.copyWith(messages: messages);
    } catch (_) {
      // Erreur de lecture silencieuse — on continue sans historique
    }
  }

  // ── Auto-refresh ──────────────────────────────────────────────────────────

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer =
        Timer.periodic(_autoRefreshInterval, (_) => receiveMessages());
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // ── Envoi générique ───────────────────────────────────────────────────────

  /// Chiffre [content] avec la clé publique du contact et le dépose
  /// sur le serveur avec le [type] spécifié (MESSAGE, COLOR, ICON, URL).
  Future<void> sendTypedMessage(String type, String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    if (type == 'MESSAGE' && trimmed.length > kMaxMessageLength) {
      state = state.copyWith(
        error: 'Message trop long (max $kMaxMessageLength caractères).',
      );
      return;
    }

    if (_contact.publicKey.isEmpty) {
      state = state.copyWith(
        error: 'Clé publique du contact introuvable. Re-faites le pairing.',
      );
      return;
    }

    state = state.copyWith(isSending: true, clearError: true);

    try {
      final encrypted = await compute(
        _encryptIsolate,
        (publicKeyPem: _contact.publicKey, plaintext: trimmed),
      );

      await _elementApi.postElement(
        relationCode: _contact.myRelationCode,
        key: type,
        value: encrypted,
      );

      final msg = Message(
        id: const Uuid().v4(),
        type: type,
        content: trimmed,
        isMine: true,
        timestamp: DateTime.now(),
      );

      await _storage.addMessage(
        _contact.id,
        StoredMessage(
          id: msg.id,
          type: msg.type,
          content: msg.content,
          isMine: true,
          timestamp: msg.timestamp,
        ),
      );

      state = state.copyWith(
        messages: [...state.messages, msg],
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: _friendlyError('Erreur d\'envoi', e),
      );
    }
  }

  /// Alias pour la compatibilité — envoie un message texte.
  Future<void> sendMessage(String text) => sendTypedMessage('MESSAGE', text);

  // ── Réception ─────────────────────────────────────────────────────────────

  /// Récupère le prochain message depuis la boîte du contact.
  ///
  /// Schéma : `GET /element?relationCode=contact.relationCode`
  /// → Déchiffrement avec notre clé privée (stockée sous myRelationCode).
  Future<void> receiveMessages() async {
    if (state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true);

    try {
      final element = await _elementApi.getElement(_contact.relationCode);

      if (element == null) {
        state = state.copyWith(isRefreshing: false);
        return;
      }

      // Récupération de notre clé privée
      final privateKey =
          await _keyStorage.readPrivateKeyPem(_contact.myRelationCode);

      if (privateKey == null || privateKey.isEmpty) {
        state = state.copyWith(
          isRefreshing: false,
          error: 'Clé privée introuvable pour ce contact. Re-faites le pairing.',
        );
        return;
      }

      // Déchiffrement RSA-OAEP dans un isolate (non bloquant)
      final decrypted = await compute(
        _decryptIsolate,
        (privateKeyPem: privateKey, ciphertextB64: element.value),
      );

      final msg = Message(
        id: const Uuid().v4(),
        type: element.key,
        content: decrypted,
        isMine: false,
        timestamp: DateTime.now(),
      );

      // Persistance locale
      await _storage.addMessage(
        _contact.id,
        StoredMessage(
          id: msg.id,
          type: msg.type,
          content: msg.content,
          isMine: false,
          timestamp: msg.timestamp,
        ),
      );

      state = state.copyWith(
        messages: [...state.messages, msg],
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: _friendlyError('Erreur de réception', e),
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void clearError() => state = state.copyWith(clearError: true);

  String _friendlyError(String prefix, Object e) {
    final msg = e.toString();
    if (msg.contains('too large') || msg.contains('input too large')) {
      return 'Contenu trop long pour RSA-2048 (max ~$kMaxMessageLength car.).';
    }
    if (msg.contains('SocketException') || msg.contains('ClientException')) {
      return 'Erreur réseau. Vérifiez votre connexion.';
    }
    return '$prefix : $msg';
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// ── Fonctions top-level pour compute() ───────────────────────────────────────

String _encryptIsolate(({String publicKeyPem, String plaintext}) params) {
  return CryptoService().encryptWithPublicKey(
    recipientPublicKeyPem: params.publicKeyPem,
    plaintext: params.plaintext,
  );
}

String _decryptIsolate(({String privateKeyPem, String ciphertextB64}) params) {
  return CryptoService().decryptWithPrivateKey(
    myPrivateKeyPem: params.privateKeyPem,
    ciphertextB64: params.ciphertextB64,
  );
}
