import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'dart:convert';

class CryptoService {
  /// Génère une paire de clés RSA 2048 bits
  static Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> generateRSAKeyPair() async {
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
          _getSecureRandom(),
        ),
      );

    final pair = keyGen.generateKeyPair();
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey as RSAPublicKey,
      pair.privateKey as RSAPrivateKey,
    );
  }

  /// Génère un nombre aléatoire sécurisé pour la génération de clés
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

  /// Convertit une clé publique RSA en format PEM (base64)
  static String publicKeyToPem(RSAPublicKey publicKey) {
    final modulus = publicKey.modulus!;
    final exponent = publicKey.exponent!;

    // Encodage simple en base64 du modulus et exponent
    final Map<String, String> keyData = {
      'modulus': modulus.toString(),
      'exponent': exponent.toString(),
    };

    final jsonString = json.encode(keyData);
    return base64.encode(utf8.encode(jsonString));
  }

  /// Convertit une clé privée RSA en format PEM (base64)
  static String privateKeyToPem(RSAPrivateKey privateKey) {
    final Map<String, String> keyData = {
      'modulus': privateKey.modulus!.toString(),
      'privateExponent': privateKey.privateExponent!.toString(),
      'p': privateKey.p!.toString(),
      'q': privateKey.q!.toString(),
    };

    final jsonString = json.encode(keyData);
    return base64.encode(utf8.encode(jsonString));
  }

  /// Convertit une clé publique PEM en RSAPublicKey
  static RSAPublicKey publicKeyFromPem(String pem) {
    final jsonString = utf8.decode(base64.decode(pem));
    final Map<String, dynamic> keyData = json.decode(jsonString);

    return RSAPublicKey(
      BigInt.parse(keyData['modulus']),
      BigInt.parse(keyData['exponent']),
    );
  }

  /// Convertit une clé privée PEM en RSAPrivateKey
  static RSAPrivateKey privateKeyFromPem(String pem) {
    final jsonString = utf8.decode(base64.decode(pem));
    final Map<String, dynamic> keyData = json.decode(jsonString);

    return RSAPrivateKey(
      BigInt.parse(keyData['modulus']),
      BigInt.parse(keyData['privateExponent']),
      BigInt.parse(keyData['p']),
      BigInt.parse(keyData['q']),
    );
  }

  /// Chiffre un message avec une clé publique RSA
  static String encrypt(String plainText, RSAPublicKey publicKey) {
    final cipher = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final plainBytes = Uint8List.fromList(utf8.encode(plainText));
    final encryptedBytes = cipher.process(plainBytes);

    return base64.encode(encryptedBytes);
  }

  /// Déchiffre un message avec une clé privée RSA
  static String decrypt(String cipherText, RSAPrivateKey privateKey) {
    final cipher = OAEPEncoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final cipherBytes = base64.decode(cipherText);
    final decryptedBytes = cipher.process(Uint8List.fromList(cipherBytes));

    return utf8.decode(decryptedBytes);
  }
}

