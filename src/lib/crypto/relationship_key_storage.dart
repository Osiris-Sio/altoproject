import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service de stockage des clés par relationId
/// Conforme au guide GUIDE_KEYS.md
class RelationshipKeyStorage {
  final FlutterSecureStorage _storage;

  RelationshipKeyStorage(this._storage);

  /// Clé pour la clé publique d'une relation
  String _pubKey(String relationId) => 'rel:$relationId:pubPem';

  /// Clé pour la clé privée d'une relation
  String _privKey(String relationId) => 'rel:$relationId:privPem';

  /// Sauvegarde une paire de clés pour une relation donnée
  Future<void> saveKeyPair(
    String relationId, {
    required String publicKeyPem,
    required String privateKeyPem,
  }) async {
    await _storage.write(key: _pubKey(relationId), value: publicKeyPem);
    await _storage.write(key: _privKey(relationId), value: privateKeyPem);
  }

  /// Récupère la clé publique d'une relation
  Future<String?> readPublicKeyPem(String relationId) =>
      _storage.read(key: _pubKey(relationId));

  /// Récupère la clé privée d'une relation
  Future<String?> readPrivateKeyPem(String relationId) =>
      _storage.read(key: _privKey(relationId));

  /// Supprime les clés d'une relation
  Future<void> deleteKeyPair(String relationId) async {
    await _storage.delete(key: _pubKey(relationId));
    await _storage.delete(key: _privKey(relationId));
  }

  /// Vérifie si une relation a des clés stockées
  Future<bool> hasKeyPair(String relationId) async {
    final publicKey = await readPublicKeyPem(relationId);
    final privateKey = await readPrivateKeyPem(relationId);
    return publicKey != null && privateKey != null;
  }
}

