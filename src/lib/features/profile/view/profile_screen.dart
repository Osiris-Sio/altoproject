import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/profile_notifier.dart';
import '../widgets/qr_code_display.dart';
import '../../../services/secure_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Utilisateur';

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Initialiser le pairing automatiquement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileNotifier>().initiatePairing();
    });
  }

  Future<void> _loadUserData() async {
    final firstName = await SecureStorageService.getFirstName();
    if (firstName != null && mounted) {
      setState(() {
        _userName = firstName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userName),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProfileNotifier>(
        builder: (context, notifier, _) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // QR Code ou état
                  if (notifier.isLoading)
                    const CircularProgressIndicator()
                  else if (notifier.hasExpired || notifier.currentPairing == null)
                    Column(
                      children: [
                        const Icon(Icons.qr_code, size: 100, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Code expiré', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => notifier.resetPairing(),
                          child: const Text('Générer nouveau code'),
                        ),
                      ],
                    )
                  else
                    QRCodeDisplay(
                      relationCode: notifier.currentPairing!.relationCode,
                      publicKey: notifier.currentPairing!.userPublicKey,
                      size: 200,
                    ),

                  const SizedBox(height: 24),

                  // Timer
                  if (!notifier.isLoading && notifier.currentPairing != null && !notifier.hasExpired)
                    Text(
                      notifier.formattedTime,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Message d'erreur
                  if (notifier.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        notifier.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Bouton retour
                  TextButton.icon(
                    onPressed: () {
                      notifier.cancelPairing();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

