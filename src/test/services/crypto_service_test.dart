import 'package:flutter_test/flutter_test.dart';
import 'package:altoproject/services/crypto_service.dart';

void main() {
  // Instance partagée pour tous les tests
  final crypto = CryptoService();

  group('CryptoService - Conformité GUIDE_KEYS.md', () {
    test('Génération de paire de clés RSA-2048 en format PEM', () {
      final keyPair = crypto.generateRsaKeyPair();

      expect(keyPair.publicKeyPem, contains('-----BEGIN PUBLIC KEY-----'));
      expect(keyPair.publicKeyPem, contains('-----END PUBLIC KEY-----'));
      expect(keyPair.privateKeyPem, anyOf(
        contains('-----BEGIN PRIVATE KEY-----'),
        contains('-----BEGIN RSA PRIVATE KEY-----'),
      ));
      expect(keyPair.privateKeyPem, anyOf(
        contains('-----END PRIVATE KEY-----'),
        contains('-----END RSA PRIVATE KEY-----'),
      ));
      expect(keyPair.publicKeyPem.length, greaterThan(100));
      expect(keyPair.privateKeyPem.length, greaterThan(100));
    });

    test('Chiffrement et déchiffrement d\'un message court', () {
      final bobKeys = crypto.generateRsaKeyPair();
      const originalMessage = 'Hello Bob! This is a secret message.';

      final encrypted = crypto.encryptWithPublicKey(
        recipientPublicKeyPem: bobKeys.publicKeyPem,
        plaintext: originalMessage,
      );
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(originalMessage)));

      final decrypted = crypto.decryptWithPrivateKey(
        myPrivateKeyPem: bobKeys.privateKeyPem,
        ciphertextB64: encrypted,
      );
      expect(decrypted, equals(originalMessage));
    });

    test('Chiffrement bidirectionnel (Alice ↔ Bob)', () {
      final aliceKeys = crypto.generateRsaKeyPair();
      final bobKeys = crypto.generateRsaKeyPair();

      // Alice → Bob
      const aliceMessage = 'Salut Bob!';
      final encryptedForBob = crypto.encryptWithPublicKey(
        recipientPublicKeyPem: bobKeys.publicKeyPem,
        plaintext: aliceMessage,
      );
      expect(crypto.decryptWithPrivateKey(
        myPrivateKeyPem: bobKeys.privateKeyPem,
        ciphertextB64: encryptedForBob,
      ), equals(aliceMessage));

      // Bob → Alice
      const bobMessage = 'Salut Alice!';
      final encryptedForAlice = crypto.encryptWithPublicKey(
        recipientPublicKeyPem: aliceKeys.publicKeyPem,
        plaintext: bobMessage,
      );
      expect(crypto.decryptWithPrivateKey(
        myPrivateKeyPem: aliceKeys.privateKeyPem,
        ciphertextB64: encryptedForAlice,
      ), equals(bobMessage));
    });

    test('Conversion PEM ↔ RSAPublicKey', () {
      final keyPair = crypto.generateRsaKeyPair();
      final publicKey = crypto.publicKeyFromPem(keyPair.publicKeyPem);
      final pemAgain = crypto.publicKeyToPem(publicKey);

      expect(pemAgain, contains('-----BEGIN PUBLIC KEY-----'));
      expect(pemAgain, contains('-----END PUBLIC KEY-----'));
    });

    test('Ne peut pas déchiffrer avec la mauvaise clé privée', () {
      final aliceKeys = crypto.generateRsaKeyPair();
      final eveKeys = crypto.generateRsaKeyPair();

      const message = 'Secret message';
      final encrypted = crypto.encryptWithPublicKey(
        recipientPublicKeyPem: aliceKeys.publicKeyPem,
        plaintext: message,
      );

      expect(
        () => crypto.decryptWithPrivateKey(
          myPrivateKeyPem: eveKeys.privateKeyPem,
          ciphertextB64: encrypted,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Chiffrement de JSON (petit payload)', () {
      final keys = crypto.generateRsaKeyPair();
      const jsonPayload = '{"userId":"123","code":"ABC-XYZ"}';

      final encrypted = crypto.encryptWithPublicKey(
        recipientPublicKeyPem: keys.publicKeyPem,
        plaintext: jsonPayload,
      );
      final decrypted = crypto.decryptWithPrivateKey(
        myPrivateKeyPem: keys.privateKeyPem,
        ciphertextB64: encrypted,
      );
      expect(decrypted, equals(jsonPayload));
    });
  });
}
