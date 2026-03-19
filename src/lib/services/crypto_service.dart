import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'package:basic_utils/basic_utils.dart';

class CryptoService {
  /// Génère un SecureRandom pour la génération de clés
  static SecureRandom _getSecureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(256));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  /// Génère une paire de clés RSA 2048 bits
  /// Retourne les clés au format PEM standard
  static Future<({String publicKeyPem, String privateKeyPem})> generateRSAKeyPair({
    int bitLength = 2048,
  }) async {
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
          _getSecureRandom(),
        ),
      );

    final pair = keyGen.generateKeyPair();
    final publicKey = pair.publicKey as RSAPublicKey;
    final privateKey = pair.privateKey as RSAPrivateKey;

    return (
      publicKeyPem: CryptoUtils.encodeRSAPublicKeyToPem(publicKey),
      privateKeyPem: CryptoUtils.encodeRSAPrivateKeyToPem(privateKey),
    );
  }

  /// Chiffre un message avec une clé publique RSA (format PEM)
  /// Retourne le résultat en Base64
  static String encryptWithPublicKey({
    required String recipientPublicKeyPem,
    required String plaintext,
  }) {
    final RSAPublicKey publicKey = CryptoUtils.rsaPublicKeyFromPem(recipientPublicKeyPem);

    final engine = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final ciphertextBytes = engine.process(Uint8List.fromList(utf8.encode(plaintext)));
    return base64Encode(ciphertextBytes);
  }

  /// Déchiffre un message avec une clé privée RSA (format PEM)
  /// Le message chiffré doit être en Base64
  static String decryptWithPrivateKey({
    required String myPrivateKeyPem,
    required String ciphertextB64,
  }) {
    final RSAPrivateKey privateKey = CryptoUtils.rsaPrivateKeyFromPem(myPrivateKeyPem);

    final engine = OAEPEncoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final clearBytes = engine.process(base64Decode(ciphertextB64));
    return utf8.decode(clearBytes);
  }

  /// Convertit une clé publique PEM en RSAPublicKey
  static RSAPublicKey publicKeyFromPem(String pem) {
    return CryptoUtils.rsaPublicKeyFromPem(pem);
  }

  /// Convertit une clé privée PEM en RSAPrivateKey
  static RSAPrivateKey privateKeyFromPem(String pem) {
    return CryptoUtils.rsaPrivateKeyFromPem(pem);
  }

  /// Convertit une clé publique RSA en format PEM
  static String publicKeyToPem(RSAPublicKey publicKey) {
    return CryptoUtils.encodeRSAPublicKeyToPem(publicKey);
  }

  /// Convertit une clé privée RSA en format PEM
  static String privateKeyToPem(RSAPrivateKey privateKey) {
    return CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);
  }
}

