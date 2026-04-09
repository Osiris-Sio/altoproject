import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/core/models/contact.dart';
import '../providers/message_providers.dart';
import '../widgets/message_bubble.dart';

/// Écran de conversation avec un contact.
///
/// - Affiche les messages en bulles (droite = moi, gauche = contact)
/// - Chiffre avec la clé publique du contact à l'envoi (RSA-OAEP)
/// - Déchiffre avec notre clé privée à la réception
/// - Auto-refresh toutes les 5 s + bouton manuel
class MessagePage extends ConsumerStatefulWidget {
  final Contact contact;

  const MessagePage({super.key, required this.contact});

  @override
  ConsumerState<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    FocusScope.of(context).unfocus();

    await ref
        .read(messageNotifierProvider(widget.contact).notifier)
        .sendMessage(text);

    _scrollToBottom();
  }

  Future<void> _refresh() async {
    await ref
        .read(messageNotifierProvider(widget.contact).notifier)
        .receiveMessages();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageNotifierProvider(widget.contact));

    // Scroll automatique quand un nouveau message arrive
    ref.listen(messageNotifierProvider(widget.contact), (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
      // Feedback succès envoi
      if (next.messageSent && !(prev?.messageSent ?? false)) {
        ref
            .read(messageNotifierProvider(widget.contact).notifier)
            .clearMessageSent();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Message envoyé ✓'),
              ],
            ),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      // Afficher les erreurs en SnackBar
      if (next.error != null && next.error != prev?.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.error!),
                backgroundColor: Colors.red.shade700,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () => ref
                      .read(messageNotifierProvider(widget.contact).notifier)
                      .clearError(),
                ),
              ),
            );
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4EFF9),
      appBar: _buildAppBar(state),
      body: Column(
        children: [
          _EncryptionBanner(),
          Expanded(child: _buildMessageList(state)),
          _buildInputBar(state),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(MessageState state) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: const BackButton(color: Color(0xFF6B4FA0)),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE6D5F5),
            child: Text(
              widget.contact.name.isNotEmpty
                  ? widget.contact.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Color(0xFF6B4FA0),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D1B4E),
                  ),
                ),
                if (state.isRefreshing)
                  const Text(
                    'Vérification…',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: state.isRefreshing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF6B4FA0),
                  ),
                )
              : const Icon(Icons.refresh, color: Color(0xFF6B4FA0)),
          onPressed: state.isRefreshing ? null : _refresh,
          tooltip: 'Vérifier les nouveaux messages',
        ),
      ],
    );
  }

  // ── Liste de messages ─────────────────────────────────────────────────────

  Widget _buildMessageList(MessageState state) {
    if (state.messages.isEmpty && !state.isRefreshing) {
      return _EmptyConversation(onRefresh: _refresh);
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: state.messages.length,
      itemBuilder: (_, i) => MessageBubble(message: state.messages[i]),
    );
  }

  // ── Barre de saisie ───────────────────────────────────────────────────────

  Widget _buildInputBar(MessageState state) {
    final remaining = kMaxMessageLength - _textCtrl.text.length;
    final isOverLimit = remaining < 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_textCtrl.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 4),
                child: Text(
                  '$remaining car. restants',
                  style: TextStyle(
                    fontSize: 11,
                    color: isOverLimit
                        ? Colors.red
                        : (remaining < 30 ? Colors.orange : Colors.grey),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EBF8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textCtrl,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Message…',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SendButton(
                  enabled: !state.isSending &&
                      _textCtrl.text.trim().isNotEmpty &&
                      !isOverLimit,
                  isSending: state.isSending,
                  onPressed: _send,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliaires ───────────────────────────────────────────────────────

class _EncryptionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFFEDE3F8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 12, color: Color(0xFF6B4FA0)),
          SizedBox(width: 6),
          Text(
            'Chiffrement de bout en bout (RSA-2048)',
            style: TextStyle(fontSize: 11, color: Color(0xFF6B4FA0)),
          ),
        ],
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyConversation({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Aucun message pour l\'instant',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D1B4E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Envoyez le premier message\nou vérifiez les nouveaux.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Vérifier les messages'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B4FA0),
              side: const BorderSide(color: Color(0xFF6B4FA0)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final bool isSending;
  final VoidCallback onPressed;

  const _SendButton({
    required this.enabled,
    required this.isSending,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF6B4FA0)
              : const Color(0xFFCCBCE8),
          shape: BoxShape.circle,
        ),
        child: isSending
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}
