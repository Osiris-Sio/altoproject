import 'package:flutter/material.dart';

/// Écran Paramètres — stub (sera complété à l'Étape 8)
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 64, color: Color(0xFFD4C5E8)),
          SizedBox(height: 16),
          Text(
            'Paramètres',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'À venir — Étape 8',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

