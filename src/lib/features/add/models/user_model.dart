class UserModel {
  final String firstName;
  final String uuid;
  final String publicKey;

  UserModel({
    required this.firstName,
    required this.uuid,
    required this.publicKey,
  });

  /// Crée un UserModel à partir d'un Map JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['firstName'] as String,
      uuid: json['uuid'] as String,
      publicKey: json['publicKey'] as String,
    );
  }

  /// Convertit le UserModel en Map JSON
  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'uuid': uuid,
    'publicKey': publicKey,
  };

  /// Crée une copie avec des modifications
  UserModel copyWith({
    String? firstName,
    String? uuid,
    String? publicKey,
  }) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      uuid: uuid ?? this.uuid,
      publicKey: publicKey ?? this.publicKey,
    );
  }
}