import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altoproject/core/providers/app_providers.dart';
import 'package:altoproject/core/providers/theme_provider.dart';
import 'package:altoproject/features/creating/models/user.dart';
import 'package:altoproject/features/creating/providers/user_provider.dart';
import 'package:altoproject/features/creating/view/user_page.dart';

/// Écran Paramètres — Étape 8
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _clearingCache = false;

  // ── Profil ────────────────────────────────────────────────────────────────

  void _editProfile(User user) {
    final firstCtrl = TextEditingController(text: user.firstName);
    final lastCtrl = TextEditingController(text: user.lastName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Prénom',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Nom',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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
            onPressed: () async {
              final first = firstCtrl.text.trim();
              final last = lastCtrl.text.trim();
              if (first.isEmpty || last.isEmpty) return;
              await ref.read(userProvider.notifier).updateNames(first, last);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  // ── Cache ─────────────────────────────────────────────────────────────────

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le cache'),
        content: const Text(
          'Tous vos messages stockés localement seront effacés.\n\n'
          'Les messages sur le serveur restent accessibles via le bouton Rafraîchir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _clearingCache = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith('alto_messages_'))
          .toList();
      for (final k in keys) {
        await prefs.remove(k);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cache effacé (${keys.length} conversation(s))'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _clearingCache = false);
    }
  }

  // ── Compte ────────────────────────────────────────────────────────────────

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
          'Cette action est irréversible.\n\n'
          'Votre profil, vos contacts, vos clés de chiffrement '
          'et tous vos messages locaux seront définitivement supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // 1. Effacer les clés RSA (secure storage)
    await ref.read(secureStorageProvider).deleteAll();
    // 2. Effacer tout SharedPreferences (profil, contacts, messages)
    await ref.read(userProvider.notifier).reset();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const UserPage()),
        (route) => false,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final themeMode = ref.watch(themeModeProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── En-tête profil ────────────────────────────────────────────────
          userAsync.when(
            data: (user) => _buildHeader(user),
            loading: () => _buildHeader(null),
            error: (_, __) => _buildHeader(null),
          ),

          // ── Sections ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Mon profil ─────────────────────────────────────────────
                _sectionTitle('Mon profil'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: userAsync.when(
                    data: (user) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: const _SettingIcon(
                          icon: Icons.person_outline,
                          color: Color(0xFF6B4FA0)),
                      title: const Text('Modifier le profil'),
                      subtitle: Text('${user.firstName} ${user.lastName}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _editProfile(user),
                    ),
                    loading: () => const ListTile(
                      leading: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      title: Text('Chargement…'),
                    ),
                    error: (_, __) => const ListTile(
                      title: Text('Erreur de chargement'),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Apparence ──────────────────────────────────────────────
                _sectionTitle('Apparence'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const _SettingIcon(
                              icon: Icons.palette_outlined,
                              color: Color(0xFF6B4FA0)),
                          const SizedBox(width: 12),
                          const Text('Thème de l\'application',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                        ]),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ThemeChip(
                              label: 'Système',
                              icon: Icons.brightness_auto_rounded,
                              selected: themeMode == ThemeMode.system,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setMode(ThemeMode.system),
                            ),
                            _ThemeChip(
                              label: 'Clair',
                              icon: Icons.light_mode_rounded,
                              selected: themeMode == ThemeMode.light,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setMode(ThemeMode.light),
                            ),
                            _ThemeChip(
                              label: 'Sombre',
                              icon: Icons.dark_mode_rounded,
                              selected: themeMode == ThemeMode.dark,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setMode(ThemeMode.dark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Données ────────────────────────────────────────────────
                _sectionTitle('Données'),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: _clearingCache
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF6B4FA0),
                                    ),
                                  ),
                                ),
                              )
                            : const _SettingIcon(
                                icon: Icons.delete_sweep_outlined,
                                color: Colors.orange),
                        title: const Text('Supprimer le cache'),
                        subtitle: const Text(
                            'Efface les messages stockés localement'),
                        onTap: _clearingCache ? null : _clearCache,
                      ),
                      const Divider(height: 1, indent: 68),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: const _SettingIcon(
                            icon: Icons.delete_forever_outlined,
                            color: Colors.red),
                        title: const Text('Supprimer mon compte',
                            style: TextStyle(color: Colors.red)),
                        subtitle: const Text('Action irréversible'),
                        onTap: _deleteAccount,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Center(
                  child: Text(
                    'Alto v1.0.0 — RSA-2048 end-to-end encryption',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets internes ──────────────────────────────────────────────────────

  Widget _buildHeader(User? user) {
    final name = user != null ? '${user.firstName} ${user.lastName}' : '…';
    final initials = user != null && user.firstName.isNotEmpty
        ? (user.firstName[0] +
                (user.lastName.isNotEmpty ? user.lastName[0] : ''))
            .toUpperCase()
        : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B4FA0), Color(0xFF4A3070)],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 12, color: Color(0xFFD4C5E8)),
              SizedBox(width: 4),
              Text(
                'Chiffrement de bout en bout',
                style: TextStyle(fontSize: 12, color: Color(0xFFD4C5E8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B4FA0),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Widgets réutilisables ─────────────────────────────────────────────────────

class _SettingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SettingIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF6B4FA0)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? Colors.white : const Color(0xFF6B4FA0),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF6B4FA0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
