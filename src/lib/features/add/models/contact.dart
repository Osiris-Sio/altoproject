/// Modèle représentant un contact dans Alto
class Contact {
  final String id;
  final String name;
  final String relationCode;
  final String publicKey;
  final DateTime createdAt;

  Contact({
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

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as String,
      name: map['name'] as String,
      relationCode: map['relationCode'] as String,
      publicKey: map['publicKey'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relationCode': relationCode,
      'publicKey': publicKey,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

