import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../contact/view/contact_page.dart';
import '../../settings/view/settings_page.dart';
import '../../add/view/scan_pairing_screen.dart';
import '../../profile/view/profile_screen.dart';
import '../../profile/notifiers/profile_notifier.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  static const _titles = ['Alto Messages', 'Alto Messages - Paramètres'];

  // ── Bouton central "+" ───────────────────────────────────────────────────

  void _onAddPressed() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poignée
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6D5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.qr_code_scanner,
                      color: Color(0xFF6B4FA0)),
                ),
                title: const Text('Scanner un QR Code',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ScanPairingScreen()),
                  );
                },
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6D5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.qr_code, color: Color(0xFF6B4FA0)),
                ),
                title: const Text('Partager mon QR Code',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => ProfileNotifier(),
                        child: const ProfileScreen(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: _currentIndex == 0
            ? [IconButton(icon: const Icon(Icons.search), onPressed: () {})]
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ContactPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        currentIndex: _currentIndex,
        onMessagesTab: () => setState(() => _currentIndex = 0),
        onSettingsTab: () => setState(() => _currentIndex = 1),
        onAddPressed: _onAddPressed,
      ),
    );
  }
}

// ── Bottom bar custom ────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onMessagesTab;
  final VoidCallback onSettingsTab;
  final VoidCallback onAddPressed;

  const _BottomBar({
    required this.currentIndex,
    required this.onMessagesTab,
    required this.onSettingsTab,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.chat_bubble_outline,
                label: 'Messages',
                selected: currentIndex == 0,
                onTap: onMessagesTab,
              ),
              _AddButton(onPressed: onAddPressed),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Paramètres',
                selected: currentIndex == 1,
                onTap: onSettingsTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? const Color(0xFF6B4FA0) : Colors.grey.shade500;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFF6B4FA0),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x446B4FA0),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

