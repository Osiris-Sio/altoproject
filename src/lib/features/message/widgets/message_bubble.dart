import 'package:flutter/material.dart';
import '../models/message.dart';

/// Bulle de message — s'aligne à droite (moi) ou à gauche (contact).
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: message.isMine ? 60 : 12,
          right: message.isMine ? 12 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMine
              ? const Color(0xFF6B4FA0)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMine ? 16 : 4),
            bottomRight: Radius.circular(message.isMine ? 4 : 16),
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
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContent(),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: message.isMine
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (message.type) {
      case 'MESSAGE':
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: message.isMine ? Colors.white : Colors.black87,
          ),
        );

      case 'COLOR':
        // Prépare pour l'étape 7
        final colorHex = message.content.startsWith('#')
            ? message.content
            : '#${message.content}';
        Color? color;
        try {
          color = Color(
              int.parse(colorHex.replaceFirst('#', '0xFF')));
        } catch (_) {}
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white30),
                ),
              ),
            const SizedBox(width: 8),
            Text(
              colorHex,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                color: message.isMine ? Colors.white : Colors.black87,
              ),
            ),
          ],
        );

      case 'ICON':
        // Prépare pour l'étape 7
        return Text(message.content, style: const TextStyle(fontSize: 32));

      case 'URL':
        // Prépare pour l'étape 7
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            color: message.isMine
                ? Colors.lightBlueAccent
                : Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
        );

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

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

