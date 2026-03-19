import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Clés de stockage
  static const String _keyPrivateKey = 'private_key';
  static const String _keyPublicKey = 'public_key';
  static const String _keyUuid = 'user_uuid';
  static const String _keyFirstName = 'user_first_name';

  /// Sauvegarde la clé privée de manière sécurisée
  static Future<void> savePrivateKey(String privateKey) async {
    await _storage.write(key: _keyPrivateKey, value: privateKey);
  }

  /// Récupère la clé privée
  static Future<String?> getPrivateKey() async {
    return await _storage.read(key: _keyPrivateKey);
  }

  /// Sauvegarde la clé publique
  static Future<void> savePublicKey(String publicKey) async {
    await _storage.write(key: _keyPublicKey, value: publicKey);
  }

  /// Récupère la clé publique
  static Future<String?> getPublicKey() async {
    return await _storage.read(key: _keyPublicKey);
  }

  /// Sauvegarde l'UUID de l'utilisateur
  static Future<void> saveUserUuid(String uuid) async {
    await _storage.write(key: _keyUuid, value: uuid);
  }

  /// Récupère l'UUID de l'utilisateur
  static Future<String?> getUserUuid() async {
    return await _storage.read(key: _keyUuid);
  }

  /// Sauvegarde le prénom de l'utilisateur
  static Future<void> saveFirstName(String firstName) async {
    await _storage.write(key: _keyFirstName, value: firstName);
  }

  /// Récupère le prénom de l'utilisateur
  static Future<String?> getFirstName() async {
    return await _storage.read(key: _keyFirstName);
  }

  /// Vérifie si un utilisateur existe déjà
  static Future<bool> hasUser() async {
    final uuid = await getUserUuid();
    return uuid != null && uuid.isNotEmpty;
  }

  /// Supprime toutes les données utilisateur
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Supprime uniquement la clé privée
  static Future<void> deletePrivateKey() async {
    await _storage.delete(key: _keyPrivateKey);
  }
}

