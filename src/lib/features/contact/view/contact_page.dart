import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/contact_tile.dart';
import '../providers/contact_provider.dart';
import '../../add/view/scan_pairing_screen.dart';
import '../../profile/view/profile_screen.dart';
import '../../profile/notifiers/profile_notifier.dart';

/// Corps de l'onglet "Messages" — intégré dans MainScaffold via IndexedStack.
/// Pas de Scaffold propre : c'est MainScaffold qui fournit l'AppBar et la bottom bar.
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final contactList = ContactProvider().contacts;

    if (contactList.isEmpty) {
      return _EmptyContactsView();
    }

    return ListView.separated(
      itemCount: contactList.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) => ContactTile(contact: contactList[index]),
    );
  }
}

// ── État vide ────────────────────────────────────────────────────────────────

class _EmptyContactsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: Center(
            child: Text(
              'Vous n\'avez pas de contacts\nUtilisez le bouton "+" pour commencer',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.6),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
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
                icon: Icons.share_outlined,
                label: 'Partager mon QR Code',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => ProfileNotifier(),
                      child: const ProfileScreen(),
                    ),
                  ),
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
          foregroundColor: const Color(0xFF6B4FA0),
          side: const BorderSide(color: Color(0xFFD4C5E8), width: 1.5),
          backgroundColor: const Color(0xFFEDE3F8),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
