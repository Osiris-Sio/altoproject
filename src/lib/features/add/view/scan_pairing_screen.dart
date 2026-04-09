import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:altoproject/features/add/providers/add_providers.dart';
import 'package:altoproject/features/add/view/add_confirm_screen.dart';

/// Écran de scan du QR code
class ScanPairingScreen extends ConsumerStatefulWidget {
  const ScanPairingScreen({super.key});

  @override
  ConsumerState<ScanPairingScreen> createState() => _ScanPairingScreenState();
}

class _ScanPairingScreenState extends ConsumerState<ScanPairingScreen> {
  MobileScannerController? cameraController;
  bool _isProcessing = false;
  bool _cameraPermissionDenied = false;

  // Champ de saisie manuelle pour le fallback web
  final TextEditingController _manualCodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      setState(() {
        cameraController = MobileScannerController();
      });
    } else {
      setState(() => _cameraPermissionDenied = true);
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    _manualCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _processCode(String code) async {
    if (_isProcessing || code.trim().isEmpty) return;
    setState(() => _isProcessing = true);

    try {
      await ref
          .read(addUserNotifierProvider.notifier)
          .handleScannedQrCode(code.trim());

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AddConfirmScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du scan: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  void _handleBarcode(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null) return;
    _processCode(code);
  }

  @override
  Widget build(BuildContext context) {
    // ── Fallback Web / Safari : saisie manuelle du code ──────────────────
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: const Color(0xFFE6D5F5),
        appBar: AppBar(
          title: const Text('Entrer le code de pairing'),
          backgroundColor: const Color(0xFFE6D5F5),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code, size: 80, color: Color(0xFF6B4FA0)),
                const SizedBox(height: 24),
                const Text(
                  'La caméra n\'est pas disponible sur le web.\nSaisissez le code de pairing manuellement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _manualCodeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Code de pairing',
                    hintText: 'Ex: abc-123-...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon:
                        const Icon(Icons.key, color: Color(0xFF6B4FA0)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => _processCode(_manualCodeCtrl.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4FA0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Confirmer',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Écran caméra (Android / iOS) ─────────────────────────────────────
    if (_cameraPermissionDenied) {
      return Scaffold(
        backgroundColor: const Color(0xFFEDE6F5),
        appBar: AppBar(
          title: const Text('Scanner le QR code'),
          backgroundColor: const Color(0xFFEDE6F5),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.no_photography_outlined,
                    size: 72, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Permission caméra refusée',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D1B4E)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Autorisez l\'accès à la caméra dans les paramètres de l\'application.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: openAppSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Ouvrir les paramètres'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4FA0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!kIsWeb && cameraController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scanner le QR code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _handleBarcode,
          ),
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Placez le QR code dans le cadre',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: const Color(0xFF6B4FA0),
        child: const Icon(Icons.close, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// Overlay graphique avec un cadre de scan au centre
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(
            RRect.fromRectAndRadius(scanArea, const Radius.circular(20)))
        ..fillType = PathFillType.evenOdd,
      paint,
    );

    final cornerPaint = Paint()
      ..color = const Color(0xFF6B4FA0)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const d = 30.0;
    // Coin supérieur gauche
    canvas.drawLine(Offset(scanArea.left, scanArea.top),
        Offset(scanArea.left + d, scanArea.top), cornerPaint);
    canvas.drawLine(Offset(scanArea.left, scanArea.top),
        Offset(scanArea.left, scanArea.top + d), cornerPaint);
    // Coin supérieur droit
    canvas.drawLine(Offset(scanArea.right, scanArea.top),
        Offset(scanArea.right - d, scanArea.top), cornerPaint);
    canvas.drawLine(Offset(scanArea.right, scanArea.top),
        Offset(scanArea.right, scanArea.top + d), cornerPaint);
    // Coin inférieur gauche
    canvas.drawLine(Offset(scanArea.left, scanArea.bottom),
        Offset(scanArea.left + d, scanArea.bottom), cornerPaint);
    canvas.drawLine(Offset(scanArea.left, scanArea.bottom),
        Offset(scanArea.left, scanArea.bottom - d), cornerPaint);
    // Coin inférieur droit
    canvas.drawLine(Offset(scanArea.right, scanArea.bottom),
        Offset(scanArea.right - d, scanArea.bottom), cornerPaint);
    canvas.drawLine(Offset(scanArea.right, scanArea.bottom),
        Offset(scanArea.right, scanArea.bottom - d), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

