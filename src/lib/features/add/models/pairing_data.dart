/// Modèle représentant les données extraites d'un QR code
class PairingData {
  final String relationCode;
  final String publicKey;

  PairingData({
    required this.relationCode,
    required this.publicKey,
  });

  factory PairingData.fromJson(Map<String, dynamic> json) {
    return PairingData(
      relationCode: json['relationCode'] as String,
      publicKey: json['publicKey'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relationCode': relationCode,
      'publicKey': publicKey,
    };
  }
}

/// État du pairing
enum PairingStatus {
  waiting,
  completed,
  finalized,
  error,
  timeout, // polling expiré après 2 min
}

/// Modèle représentant l'état du pairing
class PairingState {
  final PairingStatus status;
  final PairingData? partnerData;
  final String? errorMessage;

  PairingState({
    required this.status,
    this.partnerData,
    this.errorMessage,
  });

  factory PairingState.initial() {
    return PairingState(status: PairingStatus.waiting);
  }

  factory PairingState.timeout() {
    return PairingState(
      status: PairingStatus.timeout,
      errorMessage: 'Le délai de 2 minutes a expiré. Veuillez régénérer le code.',
    );
  }

  factory PairingState.error(String message) {
    return PairingState(
      status: PairingStatus.error,
      errorMessage: message,
    );
  }

  PairingState copyWith({
    PairingStatus? status,
    PairingData? partnerData,
    String? errorMessage,
  }) {
    return PairingState(
      status: status ?? this.status,
      partnerData: partnerData ?? this.partnerData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

