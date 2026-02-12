import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

/// Widget affichant un QR Code de pairing (version minimaliste)
class QRCodeDisplay extends StatelessWidget {
  final String relationCode;
  final String publicKey;
  final double size;

  const QRCodeDisplay({
    super.key,
    required this.relationCode,
    required this.publicKey,
    this.size = 200,
  });

  /// Génère les données JSON pour le QR Code
  String get _qrData {
    final data = {
      'relationCode': relationCode,
      'publicKey': publicKey,
      'type': 'alto_pairing',
      'version': '1.0',
    };
    return json.encode(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Code simple
        QrImageView(
          data: _qrData,
          version: QrVersions.auto,
          size: size,
          backgroundColor: Colors.white,
          errorCorrectionLevel: QrErrorCorrectLevel.H,
        ),
        const SizedBox(height: 8),

        // Code affiché
        Text(
          relationCode,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
