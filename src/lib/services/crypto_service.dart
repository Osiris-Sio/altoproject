import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'package:basic_utils/basic_utils.dart';

/// Service de cryptographie RSA — source unique de vérité.
///
/// Utilisé pour :
/// - générer des paires de clés RSA (pairing)
/// - chiffrer les messages sortants (avec la clé publique du contact)
/// - déchiffrer les messages entrants (avec sa propre clé privée)
class CryptoService {
  // ── Génération de clés ───────────────────────────────────────────────────

  /// Génère une paire de clés RSA 2048 bits (synchrone).
  /// Retourne `(publicKeyPem, privateKeyPem)` au format PEM.
  ({String publicKeyPem, String privateKeyPem}) generateRsaKeyPair({
    int bitLength = 2048,
  }) {
    final generator = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
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

  // ── Chiffrement / Déchiffrement ──────────────────────────────────────────

  /// Chiffre [plaintext] avec la clé publique PEM du destinataire.
  /// Retourne le texte chiffré encodé en Base64.
  String encryptWithPublicKey({
    required String recipientPublicKeyPem,
    required String plaintext,
  }) {
    final publicKey = CryptoUtils.rsaPublicKeyFromPem(recipientPublicKeyPem);
    final engine = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final ciphertextBytes =
        engine.process(Uint8List.fromList(utf8.encode(plaintext)));
    return base64Encode(ciphertextBytes);
  }

  /// Déchiffre [ciphertextB64] (Base64) avec sa propre clé privée PEM.
  /// Retourne le texte en clair.
  String decryptWithPrivateKey({
    required String myPrivateKeyPem,
    required String ciphertextB64,
  }) {
    final privateKey = CryptoUtils.rsaPrivateKeyFromPem(myPrivateKeyPem);
    final engine = OAEPEncoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final clearBytes = engine.process(base64Decode(ciphertextB64));
    return utf8.decode(clearBytes);
  }

  // ── Helpers PEM ──────────────────────────────────────────────────────────

  RSAPublicKey publicKeyFromPem(String pem) =>
      CryptoUtils.rsaPublicKeyFromPem(pem);

  RSAPrivateKey privateKeyFromPem(String pem) =>
      CryptoUtils.rsaPrivateKeyFromPem(pem);

  String publicKeyToPem(RSAPublicKey publicKey) =>
      CryptoUtils.encodeRSAPublicKeyToPem(publicKey);

  String privateKeyToPem(RSAPrivateKey privateKey) =>
      CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);

  // ── Interne ──────────────────────────────────────────────────────────────

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
}

