import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/core/config/app_colors.dart';
import 'package:altoproject/core/widgets/alto_error_display.dart';
import '../widgets/contact_tile.dart';
import '../providers/contacts_provider.dart';
import '../../add/view/scan_pairing_screen.dart';
import '../../add/view/show_qr_screen.dart';

/// Corps de l'onglet "Messages" — intégré dans MainScaffold via IndexedStack.
class ContactPage extends ConsumerWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);

    return contactsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => AltoErrorDisplay(
        message: 'Impossible de charger les contacts.\n${e.toString()}',
        onRetry: () => ref.invalidate(contactsProvider),
      ),
      data: (contacts) {
        if (contacts.isEmpty) {
          return _EmptyContactsView();
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(contactsProvider.notifier).refresh(),
          child: ListView.separated(
            itemCount: contacts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => ContactTile(contact: contacts[i]),
          ),
        );
      },
    );
  }
}

// ── État vide ────────────────────────────────────────────────────────────────

class _EmptyContactsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline,
                    size: 72, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Aucun contact pour l\'instant',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Utilisez le bouton "+" pour ajouter\nvotre premier contact.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 24),
          child: Column(
            children: [
              _ShortcutButton(
                icon: Icons.qr_code_scanner_outlined,
                label: 'Scanner un QR Code',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ScanPairingScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _ShortcutButton(
                icon: Icons.qr_code_outlined,
                label: 'Partager mon QR Code',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShowQrScreen()),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.muted, width: 1.5),
          backgroundColor: AppColors.surfaceAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
