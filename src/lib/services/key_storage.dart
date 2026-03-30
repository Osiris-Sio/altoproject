import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage sécurisé des paires de clés RSA, indexées par relationCode.
///
/// Clés stockées :
///   rel:{relationId}:pubPem  → clé publique PEM
///   rel:{relationId}:privPem → clé privée PEM
class KeyStorage {
  final FlutterSecureStorage _storage;

  const KeyStorage(this._storage);

  String _pub(String id) => 'rel:$id:pubPem';
  String _priv(String id) => 'rel:$id:privPem';

  Future<void> saveKeyPair(
    String relationId, {
    required String publicKeyPem,
    required String privateKeyPem,
  }) async {
    await _storage.write(key: _pub(relationId), value: publicKeyPem);
    await _storage.write(key: _priv(relationId), value: privateKeyPem);
  }

  Future<String?> readPublicKeyPem(String relationId) =>
      _storage.read(key: _pub(relationId));

  Future<String?> readPrivateKeyPem(String relationId) =>
      _storage.read(key: _priv(relationId));

  Future<void> deleteKeyPair(String relationId) async {
    await _storage.delete(key: _pub(relationId));
    await _storage.delete(key: _priv(relationId));
  }
}

