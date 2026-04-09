import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/core/config/app_colors.dart';
import 'package:altoproject/core/models/contact.dart';
import '../providers/message_providers.dart';
import '../widgets/message_bubble.dart';

// ── Emojis disponibles dans le picker ────────────────────────────────────────

const _kEmojis = [
  '😀', '😂', '😍', '🥺', '😎', '🤩', '😴', '🤔', '😅', '🙏',
  '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '💕', '💯',
  '✨', '🔥', '💧', '🎉', '🎊', '🌟', '💪', '👍', '👎', '🤝',
  '🌸', '🌈', '🦋', '🐶', '🐱', '🌺', '🍕', '🎵', '🚀', '⚡',
];

// ── Écran de conversation ─────────────────────────────────────────────────────

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

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get _canSend {
    final l = _textCtrl.text.trim().length;
    return l > 0 && l <= kMaxMessageLength;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _send() async {
    if (!_canSend) return;
    FocusScope.of(context).unfocus();
    final content = _textCtrl.text.trim();
    _textCtrl.clear();
    setState(() {});
    await ref
        .read(messageNotifierProvider(widget.contact).notifier)
        .sendMessage(content);
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

  /// Insère [emoji] à la position du curseur dans le champ texte.
  void _insertEmoji(String emoji) {
    final text = _textCtrl.text;
    final sel = _textCtrl.selection;
    final start = sel.start.clamp(0, text.length);
    final end = sel.end.clamp(0, text.length);
    final newText = text.replaceRange(start, end, emoji);
    _textCtrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
    setState(() {});
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Choisir un emoji',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface(ctx),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: _kEmojis.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _insertEmoji(_kEmojis[i]);
                },
                child: Center(
                  child: Text(_kEmojis[i], style: const TextStyle(fontSize: 24)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageNotifierProvider(widget.contact));

    ref.listen(messageNotifierProvider(widget.contact), (prev, next) {
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
      // Erreurs uniquement — plus de notification "message envoyé"
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
      backgroundColor: AppColors.adaptiveSurface(context),
      appBar: _buildAppBar(state),
      body: Column(
        children: [
          const _EncryptionBanner(),
          Expanded(child: _buildMessageList(state)),
          _buildInputBar(state),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(MessageState state) {
    return AppBar(
      backgroundColor: AppColors.appBarBg(context),
      elevation: 0.5,
      leading: const BackButton(color: AppColors.primary),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.adaptiveSurface(context),
            child: Text(
              widget.contact.name.isNotEmpty
                  ? widget.contact.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.primary,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface(context),
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
                    color: AppColors.primary,
                  ),
                )
              : const Icon(Icons.refresh, color: AppColors.primary),
          onPressed: state.isRefreshing ? null : _refresh,
          tooltip: 'Vérifier les nouveaux messages',
        ),
      ],
    );
  }

  // ── Liste ─────────────────────────────────────────────────────────────────

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
    return Container(
      color: AppColors.appBarBg(context),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Bouton emoji — insère dans le champ texte
            _EmojiButton(onPressed: _showEmojiPicker),
            const SizedBox(width: 8),
            // Champ principal (texte, emoji, URL…)
            Expanded(
              child: _MessageTextField(
                controller: _textCtrl,
                onChanged: () => setState(() {}),
                onSubmitted: _send,
              ),
            ),
            const SizedBox(width: 8),
            _SendButton(
              enabled: !state.isSending && _canSend,
              isSending: state.isSending,
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bouton emoji ──────────────────────────────────────────────────────────────

class _EmojiButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _EmojiButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.inputBg(context),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.emoji_emotions_outlined,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ── Champ texte MESSAGE ───────────────────────────────────────────────────────

class _MessageTextField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _MessageTextField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = kMaxMessageLength - controller.text.length;
    final isOverLimit = remaining < 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4, right: 4),
            child: Text(
              '$remaining car.',
              style: TextStyle(
                fontSize: 10,
                color: isOverLimit
                    ? Colors.red
                    : (remaining < 30 ? Colors.orange : Colors.grey),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBg(context),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Message, lien, emoji…',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => onSubmitted(),
          ),
        ),
      ],
    );
  }
}

// ── Widgets partagés ──────────────────────────────────────────────────────────

class _EncryptionBanner extends StatelessWidget {
  const _EncryptionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: AppColors.accentBg(context),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 12, color: AppColors.primary),
          SizedBox(width: 6),
          Text(
            'Chiffrement de bout en bout (RSA-2048)',
            style: TextStyle(fontSize: 11, color: AppColors.primary),
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
          Text(
            'Aucun message pour l\'instant',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface(context),
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
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
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
          color: enabled ? AppColors.primary : AppColors.sendDisabled,
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
