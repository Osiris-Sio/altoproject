import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service de stockage sécurisé des clés
class KeyStorage {
  final FlutterSecureStorage _storage;

  KeyStorage(this._storage);

  /// Clés pour le stockage
  String _publicKey(String relationId) => 'rel:$relationId:pubPem';
  String _privateKey(String relationId) => 'rel:$relationId:privPem';

  /// Sauvegarde une paire de clés pour une relation
  Future<void> saveKeyPair(
    String relationId, {
    required String publicKeyPem,
    required String privateKeyPem,
  }) async {
    await _storage.write(key: _publicKey(relationId), value: publicKeyPem);
    await _storage.write(key: _privateKey(relationId), value: privateKeyPem);
  }

  /// Récupère la clé publique d'une relation
  Future<String?> readPublicKeyPem(String relationId) =>
      _storage.read(key: _publicKey(relationId));

  /// Récupère la clé privée d'une relation
  Future<String?> readPrivateKeyPem(String relationId) =>
      _storage.read(key: _privateKey(relationId));

  /// Supprime les clés d'une relation
  Future<void> deleteKeyPair(String relationId) async {
    await _storage.delete(key: _publicKey(relationId));
    await _storage.delete(key: _privateKey(relationId));
  }
}

