import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:altoproject/features/add/providers/add_providers.dart';
import 'package:altoproject/features/add/models/pairing_data.dart';
import 'package:altoproject/features/add/view/add_confirm_screen.dart';

/// Écran pour afficher le QR code à scanner
class ShowQrScreen extends ConsumerStatefulWidget {
  const ShowQrScreen({super.key});

  @override
  ConsumerState<ShowQrScreen> createState() => _ShowQrScreenState();
}

class _ShowQrScreenState extends ConsumerState<ShowQrScreen> {
  String? _qrData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateQrCode();
  }

  Future<void> _generateQrCode() async {
    try {
      final qrCode = await ref.read(addUserNotifierProvider.notifier).generateQrCode();
      setState(() {
        _qrData = qrCode;
        _isLoading = false;
      });

      // Écouter les changements d'état pour détecter le match
      ref.listen(addUserNotifierProvider, (previous, next) {
        if (next.status == PairingStatus.completed && mounted) {
          // Le match a été détecté, naviguer vers l'écran de confirmation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AddConfirmScreen(),
            ),
          );
        } else if (next.status == PairingStatus.error && mounted) {
          setState(() {
            _error = next.errorMessage;
          });
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Annuler le pairing si on quitte l'écran
    ref.read(addUserNotifierProvider.notifier).cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D5F5),
      appBar: AppBar(
        title: const Text('Mon QR Code'),
        backgroundColor: const Color(0xFFE6D5F5),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator(
                color: Color(0xFF6B4FA0),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Erreur: $_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        _generateQrCode();
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
            else if (_qrData != null)
              Column(
                children: [
                  const Text(
                    'Faites scanner ce QR code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: QrImageView(
                      data: _qrData!,
                      version: QrVersions.auto,
                      size: 250.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Indicateur d'attente
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF6B4FA0),
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          'En attente du scan...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B4FA0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: const Color(0xFF6B4FA0),
        child: const Icon(Icons.close, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}


