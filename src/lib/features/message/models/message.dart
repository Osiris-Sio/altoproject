/// Représente un message échangé dans une conversation Alto.
///
/// Les messages sont stockés en mémoire pendant la session
/// (détruits côté serveur après lecture — usage unique).
class Message {
  final String id;

  /// Type d'information : "MESSAGE", "COLOR", "ICON", "URL" (pour step 7)
  final String type;

  /// Contenu **déchiffré** (texte lisible)
  final String content;

  /// `true` = envoyé par moi, `false` = reçu du contact
  final bool isMine;

  final DateTime timestamp;

  const Message({
    required this.id,
    required this.type,
    required this.content,
    required this.isMine,
    required this.timestamp,
  });
}

// ── État de la page de conversation ──────────────────────────────────────────

class MessageState {
  final List<Message> messages;
  final bool isSending;
  final bool isRefreshing;
  final String? error;

  /// `true` juste après l'envoi réussi — utilisé pour le feedback visuel.
  final bool messageSent;

  const MessageState({
    required this.messages,
    this.isSending = false,
    this.isRefreshing = false,
    this.error,
    this.messageSent = false,
  });

  factory MessageState.initial() {
    return const MessageState(messages: []);
  }

  MessageState copyWith({
    List<Message>? messages,
    bool? isSending,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    bool? messageSent,
    bool clearMessageSent = false,
  }) {
    return MessageState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      messageSent: clearMessageSent ? false : (messageSent ?? this.messageSent),
    );
  }
}

