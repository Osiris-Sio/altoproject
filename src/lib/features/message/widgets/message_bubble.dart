import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';

/// Bulle de message — s'aligne à droite (moi) ou à gauche (contact).
/// Rendu adapté par contenu : texte, URL cliquable, emoji en grand.
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  // ── Détection automatique du contenu ─────────────────────────────────────

  /// Vrai si [s] ressemble à une URL (commence par http/https, sans espace).
  static bool _isUrl(String s) {
    final t = s.trim();
    return !t.contains(' ') &&
        (t.startsWith('http://') || t.startsWith('https://')) &&
        t.length > 7;
  }

  /// Vrai si [s] est uniquement composé d'emoji (pas de lettres/chiffres/espaces).
  static bool _isEmojiOnly(String s) {
    final t = s.trim();
    if (t.isEmpty || t.contains(' ') || t.runes.length > 8) return false;
    return !RegExp(r'[a-zA-Z0-9!@#$%^&*()\-+=\[\]{}|;:,<>./?\\`~_]')
        .hasMatch(t);
  }

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMine ? 60 : 12,
          right: isMine ? 12 : 60,
        ),
        padding: _paddingForContent(),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFF6B4FA0) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContent(context),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isMine
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _paddingForContent() {
    // Emoji seul → padding généreux
    if (message.type == 'ICON' ||
        (message.type == 'MESSAGE' && _isEmojiOnly(message.content))) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
    return const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
  }

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      // ── Texte (avec auto-détection URL / emoji) ───────────────────────────
      case 'MESSAGE':
        if (_isUrl(message.content)) {
          return _buildUrlWidget(context, message.content);
        }
        if (_isEmojiOnly(message.content)) {
          return Text(
            message.content,
            style: const TextStyle(fontSize: 48),
          );
        }
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: message.isMine ? Colors.white : Colors.black87,
          ),
        );

      // ── Emoji (rétrocompatibilité) ────────────────────────────────────────
      case 'ICON':
        return Text(
          message.content,
          style: const TextStyle(fontSize: 48),
        );

      // ── URL (rétrocompatibilité) ──────────────────────────────────────────
      case 'URL':
        return _buildUrlWidget(context, message.content);

      // ── Fallback (anciens types COLOR, etc.) ─────────────────────────────
      default:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: message.isMine ? Colors.white : Colors.black87,
          ),
        );
    }
  }

  /// Rendu d'un lien cliquable.
  Widget _buildUrlWidget(BuildContext context, String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: url));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lien copié'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.open_in_new,
            size: 16,
            color: message.isMine
                ? Colors.lightBlueAccent
                : Colors.blue.shade600,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              url,
              style: TextStyle(
                fontSize: 14,
                color: message.isMine
                    ? Colors.lightBlueAccent
                    : Colors.blue.shade700,
                decoration: TextDecoration.underline,
                decorationColor: message.isMine
                    ? Colors.lightBlueAccent
                    : Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

