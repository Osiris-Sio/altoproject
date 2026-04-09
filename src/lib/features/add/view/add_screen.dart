import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/core/config/app_colors.dart';
import 'package:altoproject/features/add/view/scan_pairing_screen.dart';
import 'package:altoproject/features/add/view/show_qr_screen.dart';

/// Écran principal pour ajouter un contact (accessible depuis la navigation).
class AddScreen extends ConsumerWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.pairingBg(context),
      appBar: AppBar(
        title: const Text('Ajouter un contact'),
        backgroundColor: AppColors.pairingBg(context),
        elevation: 0,
        foregroundColor: AppColors.onSurface(context),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.cardBg(context),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group_add_outlined,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Connectez-vous avec quelqu\'un',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Scannez le QR code d\'un contact\nou partagez le vôtre.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScanPairingScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scanner un QR code',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.muted,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShowQrScreen()),
                  ),
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Montrer mon QR code',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.muted,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
