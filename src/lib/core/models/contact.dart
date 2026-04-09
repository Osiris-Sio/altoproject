/// Modèle unifié représentant un contact Alto.
///
/// Contient toutes les informations nécessaires pour :
/// - afficher le contact dans la liste (name)
/// - chiffrer/déchiffrer les messages (publicKey — clé publique du contact)
/// - interagir avec l'API en réception (relationCode — code du contact)
/// - interagir avec l'API en émission (myRelationCode — notre propre code pour cette relation)
class Contact {
  final String id;
  final String name;

  /// Code de relation du CONTACT (partenaire). Utilisé pour :
  /// - GET /element?relationCode=... (récupérer ses messages)
  final String relationCode;

  /// Notre propre code de relation. Utilisé pour :
  /// - POST /element avec relationCode=myRelationCode (envoyer un message)
  /// - Retrouver notre clé privée RSA dans KeyStorage
  final String myRelationCode;

  /// Clé publique du CONTACT — permet de vérifier ses messages (déchiffrement).
  final String publicKey;
  final DateTime createdAt;

  const Contact({
    required this.id,
    required this.name,
    required this.relationCode,
    required this.myRelationCode,
    required this.publicKey,
    required this.createdAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      relationCode: json['relationCode'] as String,
      // Rétro-compatibilité : si absent, utilise relationCode comme fallback
      myRelationCode:
          (json['myRelationCode'] as String?) ?? json['relationCode'] as String,
      publicKey: json['publicKey'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationCode': relationCode,
      'myRelationCode': myRelationCode,
      'publicKey': publicKey,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Contact copyWith({
    String? id,
    String? name,
    String? relationCode,
    String? myRelationCode,
    String? publicKey,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      relationCode: relationCode ?? this.relationCode,
      myRelationCode: myRelationCode ?? this.myRelationCode,
      publicKey: publicKey ?? this.publicKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Contact(id: $id, name: $name, relationCode: $relationCode)';
}

