import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/profile/models/pairing_relation.dart';

/// Service de gestion des appels API de pairing
class PairingApiService {
  static const String baseUrl = 'https://alto.samyn.ovh';

  /// Initialise un nouveau pairing
  /// POST /pairing
  static Future<PairingRelation> initPairing({
    required String relationCode,
    required String userPublicKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pairing'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'relationCode': relationCode,
          'userPublicKey': userPublicKey,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return PairingRelation.fromJson(data);
      } else {
        throw PairingApiException(
          'Erreur lors de l\'initialisation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw PairingApiException('Erreur réseau: ${e.toString()}');
    }
  }

  /// Récupère le statut d'un pairing
  /// GET /pairing/{relationCode}/status
  static Future<PairingStatusResponse> getStatus(String relationCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pairing/$relationCode/status'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return PairingStatusResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        throw PairingApiException('Pairing non trouvé');
      } else {
        throw PairingApiException(
          'Erreur lors de la récupération du statut: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is PairingApiException) rethrow;
      throw PairingApiException('Erreur réseau: ${e.toString()}');
    }
  }

  /// Match deux utilisateurs
  /// PUT /pairing
  static Future<void> matchPairing({
    required String relationCodeA,
    required String relationCodeB,
    required String publicKeyB,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pairing'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'relationCodeA': relationCodeA,
          'relationCodeB': relationCodeB,
          'publicKeyB': publicKeyB,
        }),
      );

      if (response.statusCode != 200) {
        throw PairingApiException(
          'Erreur lors du match: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is PairingApiException) rethrow;
      throw PairingApiException('Erreur réseau: ${e.toString()}');
    }
  }

  /// Finalise un pairing
  /// POST /pairing/finalize
  static Future<void> finalizePairing({
    required String relationCode,
    required String partnerPublicKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pairing/finalize'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'relationCode': relationCode,
          'partnerPublicKey': partnerPublicKey,
        }),
      );

      if (response.statusCode != 200) {
        throw PairingApiException(
          'Erreur lors de la finalisation: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is PairingApiException) rethrow;
      throw PairingApiException('Erreur réseau: ${e.toString()}');
    }
  }
}

/// Réponse de l'API pour le statut
class PairingStatusResponse {
  final PairingStatus status;
  final String? partnerPublicKey;
  final String? partnerRelationCode;
  final DateTime? matchedAt;

  PairingStatusResponse({
    required this.status,
    this.partnerPublicKey,
    this.partnerRelationCode,
    this.matchedAt,
  });

  factory PairingStatusResponse.fromJson(Map<String, dynamic> json) {
    return PairingStatusResponse(
      status: PairingStatus.fromString(json['status'] as String),
      partnerPublicKey: json['partnerPublicKey'] as String?,
      partnerRelationCode: json['partnerRelationCode'] as String?,
      matchedAt: json['matchedAt'] != null
          ? DateTime.parse(json['matchedAt'] as String)
          : null,
    );
  }
}

/// Exception personnalisée pour les erreurs API
class PairingApiException implements Exception {
  final String message;

  PairingApiException(this.message);

  @override
  String toString() => message;
}

