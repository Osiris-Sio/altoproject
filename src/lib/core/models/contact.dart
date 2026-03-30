/// Modèle unifié représentant un contact Alto.
///
/// Contient toutes les informations nécessaires pour :
/// - afficher le contact dans la liste (name)
/// - chiffrer/déchiffrer les messages (publicKey)
/// - interagir avec l'API (relationCode)
class Contact {
  final String id;
  final String name;
  final String relationCode;
  final String publicKey;
  final DateTime createdAt;

  const Contact({
    required this.id,
    required this.name,
    required this.relationCode,
    required this.publicKey,
    required this.createdAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      relationCode: json['relationCode'] as String,
      publicKey: json['publicKey'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relationCode': relationCode,
      'publicKey': publicKey,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Contact copyWith({
    String? id,
    String? name,
    String? relationCode,
    String? publicKey,
    DateTime? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      relationCode: relationCode ?? this.relationCode,
      publicKey: publicKey ?? this.publicKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Contact(id: $id, name: $name, relationCode: $relationCode)';
}

