import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/core/models/contact.dart';
import '../notifiers/message_notifier.dart';
import '../providers/message_providers.dart';
import '../widgets/message_bubble.dart';

// ── Types de messages disponibles ────────────────────────────────────────────

enum _MsgType {
  message(label: 'Texte', iconData: Icons.chat_bubble_outline, key: 'MESSAGE'),
  color(label: 'Couleur', iconData: Icons.palette_outlined, key: 'COLOR'),
  icon(label: 'Icône', iconData: Icons.emoji_emotions_outlined, key: 'ICON'),
  url(label: 'Lien', iconData: Icons.link, key: 'URL');

  const _MsgType({required this.label, required this.iconData, required this.key});
  final String label;
  final IconData iconData;
  final String key;
}

// ── Emojis proposés dans le picker ───────────────────────────────────────────

const _kEmojis = [
  '😀','😂','😍','🥺','😎','🤩','😴','🤔','😅','🙏',
  '❤️','🧡','💛','💚','💙','💜','🖤','🤍','💕','💯',
  '✨','🔥','💧','🎉','🎊','🌟','💪','👍','👎','🤝',
  '🌸','🌈','🦋','🐶','🐱','🌺','🍕','🎵','🚀','⚡',
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
  final TextEditingController _urlCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  _MsgType _selectedType = _MsgType.message;
  Color _selectedColor = const Color(0xFF6B4FA0);
  String? _selectedEmoji;

  @override
  void dispose() {
    _textCtrl.dispose();
    _urlCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _colorToHex(Color c) =>
      '#${c.red.toRadixString(16).padLeft(2, '0')}'
      '${c.green.toRadixString(16).padLeft(2, '0')}'
      '${c.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

  bool get _canSend {
    switch (_selectedType) {
      case _MsgType.message:
        final l = _textCtrl.text.trim().length;
        return l > 0 && l <= kMaxMessageLength;
      case _MsgType.color:
        return true;
      case _MsgType.icon:
        return _selectedEmoji != null;
      case _MsgType.url:
        return _urlCtrl.text.trim().isNotEmpty;
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _send() async {
    if (!_canSend) return;
    FocusScope.of(context).unfocus();

    String content;
    switch (_selectedType) {
      case _MsgType.message:
        content = _textCtrl.text.trim();
        _textCtrl.clear();
        break;
      case _MsgType.color:
        content = _colorToHex(_selectedColor);
        break;
      case _MsgType.icon:
        content = _selectedEmoji!;
        break;
      case _MsgType.url:
        content = _urlCtrl.text.trim();
        if (!content.startsWith('http://') && !content.startsWith('https://')) {
          content = 'https://$content';
        }
        _urlCtrl.clear();
        break;
    }

    await ref
        .read(messageNotifierProvider(widget.contact).notifier)
        .sendTypedMessage(_selectedType.key, content);
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

  void _pickColor() {
    Color temp = _selectedColor;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choisir une couleur'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (c) => temp = c,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4FA0),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() => _selectedColor = temp);
              Navigator.pop(ctx);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _pickEmoji() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisir un emoji',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D1B4E),
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
                  setState(() => _selectedEmoji = _kEmojis[i]);
                  Navigator.pop(ctx);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedEmoji == _kEmojis[i]
                        ? const Color(0xFFE6D5F5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(_kEmojis[i], style: const TextStyle(fontSize: 24)),
                  ),
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
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypeSelector(
              selected: _selectedType,
              onChanged: (t) => setState(() {
                _selectedType = t;
                if (t != _MsgType.icon) _selectedEmoji = null;
              }),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _buildTypeInput()),
                const SizedBox(width: 8),
                _SendButton(
                  enabled: !state.isSending && _canSend,
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

  Widget _buildTypeInput() {
    switch (_selectedType) {
      case _MsgType.message:
        return _MessageTextField(
          controller: _textCtrl,
          onChanged: () => setState(() {}),
          onSubmitted: _send,
        );

      case _MsgType.color:
        return GestureDetector(
          onTap: _pickColor,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBF8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _colorToHex(_selectedColor),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Color(0xFF2D1B4E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF6B4FA0)),
              ],
            ),
          ),
        );

      case _MsgType.icon:
        return GestureDetector(
          onTap: _pickEmoji,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBF8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                if (_selectedEmoji != null)
                  Text(_selectedEmoji!, style: const TextStyle(fontSize: 26))
                else
                  const Icon(Icons.emoji_emotions_outlined,
                      color: Colors.grey, size: 24),
                const SizedBox(width: 10),
                Text(
                  _selectedEmoji != null
                      ? 'Emoji sélectionné'
                      : 'Appuyer pour choisir un emoji',
                  style: TextStyle(
                    color: _selectedEmoji != null
                        ? const Color(0xFF2D1B4E)
                        : Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF6B4FA0)),
              ],
            ),
          ),
        );

      case _MsgType.url:
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBF8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: _urlCtrl,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.send,
            decoration: const InputDecoration(
              hintText: 'https://...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon:
                  Icon(Icons.link, color: Color(0xFF6B4FA0), size: 20),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _send(),
          ),
        );
    }
  }
}

// ── Sélecteur de type ─────────────────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final _MsgType selected;
  final ValueChanged<_MsgType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _MsgType.values.map((type) {
        final isSelected = type == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6B4FA0)
                    : const Color(0xFFF0EBF8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(type.iconData,
                      size: 16,
                      color: isSelected ? Colors.white : const Color(0xFF6B4FA0)),
                  const SizedBox(height: 2),
                  Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF6B4FA0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
            color: const Color(0xFFF0EBF8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Message…',
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
          color: enabled ? const Color(0xFF6B4FA0) : const Color(0xFFCCBCE8),
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
