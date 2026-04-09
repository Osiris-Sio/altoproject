import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistance locale des messages (par contact ID).
///
/// Stocke les messages dans SharedPreferences sous la clé
/// `alto_messages_{contactId}` pour qu'ils survivent aux
/// navigations et redémarrages de l'app.
///
/// Structure JSON stockée :
/// ```json
/// [
///   { "id": "...", "type": "MESSAGE", "content": "...",
///     "isMine": true, "timestamp": "2026-04-08T..." }
/// ]
/// ```
class MessageStorageService {
  static const _prefix = 'alto_messages_';

  // ── Lecture ──────────────────────────────────────────────────────────────

  /// Retourne tous les messages enregistrés pour le contact [contactId].
  Future<List<StoredMessage>> getMessages(String contactId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$contactId');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => StoredMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Écriture ─────────────────────────────────────────────────────────────

  /// Ajoute un message à l'historique du contact [contactId].
  Future<void> addMessage(String contactId, StoredMessage message) async {
    final messages = await getMessages(contactId);
    messages.add(message);
    await _save(contactId, messages);
  }

  /// Supprime tout l'historique pour un contact (ex: suppression de compte).
  Future<void> clearMessages(String contactId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$contactId');
  }

  // ── Interne ───────────────────────────────────────────────────────────────

  Future<void> _save(String contactId, List<StoredMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix$contactId',
      jsonEncode(messages.map((m) => m.toJson()).toList()),
    );
  }
}

// ── DTO ───────────────────────────────────────────────────────────────────────

/// Version sérialisable d'un Message pour SharedPreferences.
class StoredMessage {
  final String id;
  final String type;
  final String content;
  final bool isMine;
  final DateTime timestamp;

  const StoredMessage({
    required this.id,
    required this.type,
    required this.content,
    required this.isMine,
    required this.timestamp,
  });

  factory StoredMessage.fromJson(Map<String, dynamic> json) {
    return StoredMessage(
      id: json['id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      isMine: json['isMine'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'content': content,
        'isMine': isMine,
        'timestamp': timestamp.toIso8601String(),
      };
}

