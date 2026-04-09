import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';

/// Bulle de message — s'aligne à droite (moi) ou à gauche (contact).
/// Rendu adapté par type : MESSAGE, COLOR, ICON, URL.
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

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
        padding: _paddingForType(),
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

  EdgeInsets _paddingForType() {
    if (message.type == 'ICON') {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
    if (message.type == 'COLOR') {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    }
    return const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
  }

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      // ── Texte ────────────────────────────────────────────────────────────
      case 'MESSAGE':
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: message.isMine ? Colors.white : Colors.black87,
          ),
        );

      // ── Couleur ──────────────────────────────────────────────────────────
      case 'COLOR':
        final hex = message.content.startsWith('#')
            ? message.content
            : '#${message.content}';
        Color? color;
        try {
          color = Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
        } catch (_) {}

        return GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: hex));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$hex copié'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (color != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hex.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: message.isMine ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Appuyer pour copier',
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isMine
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      // ── Emoji ────────────────────────────────────────────────────────────
      case 'ICON':
        return Text(
          message.content,
          style: const TextStyle(fontSize: 48),
        );

      // ── URL ──────────────────────────────────────────────────────────────
      case 'URL':
        final url = message.content;
        return GestureDetector(
          onTap: () async {
            final uri = Uri.tryParse(url);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
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

