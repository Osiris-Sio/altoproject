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

/// Limite maximale de caractères pour RSA-2048 OAEP (≈ 214 bytes UTF-8).
/// On limite volontairement à 190 pour conserver de la marge.
const int kMaxMessageLength = 190;

/// Notifier gérant la conversation avec un contact donné.
///
/// - Envoi    : chiffre avec la clé publique du contact → POST /element
/// - Réception: GET /element → déchiffre avec notre clé privée
/// - Auto-refresh toutes les 5 s
/// - Persistance locale via [MessageStorageService]
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

  // ── Envoi ─────────────────────────────────────────────────────────────────

  /// Chiffre [text] avec la clé publique du contact et le dépose sur le serveur.
  ///
  /// Schéma : `POST /element { relationCode: myRelationCode, key, value: base64 }`
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (trimmed.length > kMaxMessageLength) {
      state = state.copyWith(
        error:
            'Message trop long (max $kMaxMessageLength caractères pour RSA-2048).',
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
      // Chiffrement RSA-OAEP avec la clé publique du contact
      final encrypted = await compute(
        _encryptIsolate,
        (publicKeyPem: _contact.publicKey, plaintext: trimmed),
      );

      // Dépôt dans notre boîte (identifiée par myRelationCode)
      await _elementApi.postElement(
        relationCode: _contact.myRelationCode,
        key: 'MESSAGE',
        value: encrypted,
      );

      final msg = Message(
        id: const Uuid().v4(),
        type: 'MESSAGE',
        content: trimmed,
        isMine: true,
        timestamp: DateTime.now(),
      );

      // Persistance locale immédiate
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
        messageSent: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: _friendlyError('Erreur d\'envoi', e),
      );
    }
  }

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
  void clearMessageSent() => state = state.copyWith(clearMessageSent: true);

  String _friendlyError(String prefix, Object e) {
    final msg = e.toString();
    if (msg.contains('too large') || msg.contains('input too large')) {
      return 'Message trop long pour RSA-2048 (max ~$kMaxMessageLength car.).';
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
