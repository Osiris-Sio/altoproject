import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pairing_data.dart';

/// Service d'API pour le pairing
class PairingApiService {
  final String baseUrl;

  PairingApiService({required this.baseUrl});

  /// Initialise un pairing (Étape 1 : Alice affiche le QR code)
  ///
  /// POST /pairing
  /// Body: { "relationCode": "...", "userPublicKey": "..." }
  Future<void> initPairing({
    required String relationCode,
    required String publicKey,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pairing'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'relationCode': relationCode,
        'userPublicKey': publicKey,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de l\'initialisation du pairing: ${response.body}');
    }
  }

  /// Match le pairing (Étape 2 : Bob scanne le QR code)
  ///
  /// PUT /pairing
  /// Body: { "relationCodeA": "...", "relationCodeB": "...", "publicKeyB": "..." }
  /// Returns: { "relationCodeA": "...", "publicKeyA": "..." }
  Future<PairingData> matchPairing({
    required String relationCodeA,
    required String relationCodeB,
    required String publicKeyB,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pairing'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'relationCodeA': relationCodeA,
        'relationCodeB': relationCodeB,
        'publicKeyB': publicKeyB,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec du match du pairing: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return PairingData(
      relationCode: data['relationCodeA'] as String,
      publicKey: data['publicKeyA'] as String,
    );
  }

  /// Récupère le statut du pairing (Polling)
  ///
  /// GET /pairing/{relationCode}/status
  /// Returns: { "status": "waiting" | "completed" | "finalized" }
  Future<String> getPairingStatus(String relationCode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pairing/$relationCode/status'),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la récupération du statut: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['status'] as String;
  }

  /// Finalise le pairing (Étape 3 : Alice récupère les infos de Bob)
  ///
  /// DELETE /pairing?relationCodeA={relationCodeA}
  /// Returns: { "relationCodeB": "...", "publicKeyB": "..." }
  Future<PairingData> finalizePairing(String relationCodeA) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/pairing?relationCodeA=$relationCodeA'),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la finalisation du pairing: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return PairingData(
      relationCode: data['relationCodeB'] as String,
      publicKey: data['publicKeyB'] as String,
    );
  }
}

