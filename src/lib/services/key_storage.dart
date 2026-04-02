import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage sécurisé des paires de clés RSA.
///
/// - Clés de profil (identité de l'utilisateur) :
///     profile:pubPem  → clé publique
///     profile:privPem → clé privée
///
/// - Clés par relation :
///     rel:{relationId}:pubPem  → clé publique
///     rel:{relationId}:privPem → clé privée
class KeyStorage {
  final FlutterSecureStorage _storage;

  const KeyStorage(this._storage);

  // ── Clés de profil (identité globale) ────────────────────────────────────

  static const _profilePub = 'profile:pubPem';
  static const _profilePriv = 'profile:privPem';

  Future<void> saveProfileKeyPair({
    required String publicKeyPem,
    required String privateKeyPem,
  }) async {
    await _storage.write(key: _profilePub, value: publicKeyPem);
    await _storage.write(key: _profilePriv, value: privateKeyPem);
  }

  Future<String?> readProfilePublicKey() => _storage.read(key: _profilePub);

  Future<String?> readProfilePrivateKey() => _storage.read(key: _profilePriv);

  Future<bool> hasProfileKeyPair() async {
    final pub = await readProfilePublicKey();
    return pub != null && pub.isNotEmpty;
  }

  // ── Clés par relation ─────────────────────────────────────────────────────

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
