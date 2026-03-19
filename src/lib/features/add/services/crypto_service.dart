import 'dart:math';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';

/// Service de gestion des clés cryptographiques
class CryptoService {
  /// Génère un générateur de nombres aléatoires sécurisé
  FortunaRandom _secureRandom() {
    final random = FortunaRandom();
    final seed = Uint8List(32);
    final r = Random.secure();
    for (var i = 0; i < seed.length; i++) {
      seed[i] = r.nextInt(256);
    }
    random.seed(KeyParameter(seed));
    return random;
  }

  /// Génère une paire de clés RSA (publique/privée)
  ///
  /// Retourne un record contenant:
  /// - publicKeyPem: la clé publique au format PEM
  /// - privateKeyPem: la clé privée au format PEM
  ({String publicKeyPem, String privateKeyPem}) generateRsaKeyPair({
    int bitLength = 2048,
  }) {
    final generator = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(
            BigInt.parse('65537'),
            bitLength,
            64,
          ),
          _secureRandom(),
        ),
      );

    final pair = generator.generateKeyPair();
    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    return (
      publicKeyPem: CryptoUtils.encodeRSAPublicKeyToPem(publicKey),
      privateKeyPem: CryptoUtils.encodeRSAPrivateKeyToPem(privateKey),
    );
  }
}



