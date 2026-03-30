import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/models/contact.dart';

/// Service d'API pairing — source unique de vérité.
///
/// Implémente les 4 appels du guide GUIDE_PAIRING.md :
///   POST   /pairing            → init (Alice)
///   PUT    /pairing            → match (Bob)
///   GET    /pairing/{code}/status → polling
///   DELETE /pairing            → finalisation (Alice)
class PairingApiService {
  final String baseUrl;

  PairingApiService({required this.baseUrl});

  // ── Init (Alice affiche son QR) ──────────────────────────────────────────

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
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'initPairing échoué (${response.statusCode}): ${response.body}');
    }
  }

  // ── Match (Bob scanne le QR d'Alice) ────────────────────────────────────

  /// Retourne les données d'Alice : `{ relationCode, publicKey }`.
  Future<PairingPartnerData> matchPairing({
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
      throw Exception(
          'matchPairing échoué (${response.statusCode}): ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PairingPartnerData(
      relationCode: data['relationCodeA'] as String,
      publicKey: data['publicKeyA'] as String,
    );
  }

  // ── Polling ──────────────────────────────────────────────────────────────

  /// Retourne `"waiting"`, `"completed"` ou `"finalized"`.
  Future<String> getPairingStatus(String relationCode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pairing/$relationCode/status'),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'getPairingStatus échoué (${response.statusCode}): ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['status'] as String;
  }

  // ── Finalisation (Alice récupère les infos de Bob) ────────────────────────

  /// Retourne les données de Bob : `{ relationCode, publicKey }`.
  Future<PairingPartnerData> finalizePairing(String relationCodeA) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/pairing?relationCodeA=$relationCodeA'),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'finalizePairing échoué (${response.statusCode}): ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PairingPartnerData(
      relationCode: data['relationCodeB'] as String,
      publicKey: data['publicKeyB'] as String,
    );
  }
}

// ── DTO ──────────────────────────────────────────────────────────────────────

/// Données du partenaire reçues après match ou finalisation.
class PairingPartnerData {
  final String relationCode;
  final String publicKey;

  const PairingPartnerData({
    required this.relationCode,
    required this.publicKey,
  });

  /// Convertit en [Contact] complet (le nom est saisi par l'utilisateur).
  Contact toContact({required String id, required String name}) {
    return Contact(
      id: id,
      name: name,
      relationCode: relationCode,
      publicKey: publicKey,
      createdAt: DateTime.now(),
    );
  }
}
