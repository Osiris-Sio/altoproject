/// Modèle représentant une relation de pairing en cours
class PairingRelation {
  final String relationCode;
  final String userPublicKey;
  final DateTime createdAt;
  final DateTime expiresAt;
  final PairingStatus status;
  final String? partnerPublicKey;
  final String? partnerRelationCode;

  PairingRelation({
    required this.relationCode,
    required this.userPublicKey,
    required this.createdAt,
    required this.expiresAt,
    this.status = PairingStatus.pending,
    this.partnerPublicKey,
    this.partnerRelationCode,
  });

  /// Durée de validité par défaut : 2 minutes
  static const Duration defaultTTL = Duration(minutes: 2);

  /// Crée une nouvelle relation de pairing
  factory PairingRelation.create({
    required String relationCode,
    required String userPublicKey,
  }) {
    final now = DateTime.now();
    return PairingRelation(
      relationCode: relationCode,
      userPublicKey: userPublicKey,
      createdAt: now,
      expiresAt: now.add(defaultTTL),
      status: PairingStatus.pending,
    );
  }

  /// Crée une relation depuis JSON (API response)
  factory PairingRelation.fromJson(Map<String, dynamic> json) {
    return PairingRelation(
      relationCode: json['relationCode'] as String,
      userPublicKey: json['userPublicKey'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: PairingStatus.fromString(json['status'] as String? ?? 'pending'),
      partnerPublicKey: json['partnerPublicKey'] as String?,
      partnerRelationCode: json['partnerRelationCode'] as String?,
    );
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() => {
        'relationCode': relationCode,
        'userPublicKey': userPublicKey,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'status': status.name,
        if (partnerPublicKey != null) 'partnerPublicKey': partnerPublicKey,
        if (partnerRelationCode != null)
          'partnerRelationCode': partnerRelationCode,
      };

  /// Vérifie si le pairing a expiré
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Calcule le temps restant avant expiration
  Duration get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Calcule le pourcentage de temps écoulé (pour UI)
  double get progressPercentage {
    final total = expiresAt.difference(createdAt).inSeconds;
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Crée une copie avec modifications
  PairingRelation copyWith({
    String? relationCode,
    String? userPublicKey,
    DateTime? createdAt,
    DateTime? expiresAt,
    PairingStatus? status,
    String? partnerPublicKey,
    String? partnerRelationCode,
  }) {
    return PairingRelation(
      relationCode: relationCode ?? this.relationCode,
      userPublicKey: userPublicKey ?? this.userPublicKey,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      partnerPublicKey: partnerPublicKey ?? this.partnerPublicKey,
      partnerRelationCode: partnerRelationCode ?? this.partnerRelationCode,
    );
  }
}

/// Statuts possibles d'une relation de pairing
enum PairingStatus {
  pending,    // En attente du scan par le partenaire
  matched,    // Partenaire a scanné, en attente de finalisation
  completed,  // Pairing finalisé avec succès
  expired,    // Délai dépassé
  failed;     // Échec du pairing

  static PairingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PairingStatus.pending;
      case 'matched':
        return PairingStatus.matched;
      case 'completed':
        return PairingStatus.completed;
      case 'expired':
        return PairingStatus.expired;
      case 'failed':
        return PairingStatus.failed;
      default:
        return PairingStatus.pending;
    }
  }
}

