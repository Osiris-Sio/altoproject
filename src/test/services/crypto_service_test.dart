import 'package:flutter_test/flutter_test.dart';
import 'package:altoproject/services/crypto_service.dart';

void main() {
  group('CryptoService - Conformité GUIDE_KEYS.md', () {
    test('Génération de paire de clés RSA-2048 en format PEM', () async {
      // Générer la paire
      final keyPair = await CryptoService.generateRSAKeyPair();

      // Vérifier que les clés sont au format PEM (PKCS#8)
      // basic_utils utilise PKCS#8 pour les deux clés
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

      // Vérifier que les clés ne sont pas vides
      expect(keyPair.publicKeyPem.length, greaterThan(100));
      expect(keyPair.privateKeyPem.length, greaterThan(100));
    });

    test('Chiffrement et déchiffrement d\'un message court', () async {
      // Générer deux paires de clés (Alice et Bob)
      final aliceKeys = await CryptoService.generateRSAKeyPair();
      final bobKeys = await CryptoService.generateRSAKeyPair();

      // Alice envoie un message à Bob
      const originalMessage = 'Hello Bob! This is a secret message.';

      // Alice chiffre avec la clé publique de Bob
      final encrypted = CryptoService.encryptWithPublicKey(
        recipientPublicKeyPem: bobKeys.publicKeyPem,
        plaintext: originalMessage,
      );

      // Vérifier que le message est chiffré (en Base64)
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(originalMessage)));

      // Bob déchiffre avec sa clé privée
      final decrypted = CryptoService.decryptWithPrivateKey(
        myPrivateKeyPem: bobKeys.privateKeyPem,
        ciphertextB64: encrypted,
      );

      // Vérifier que le message déchiffré est identique
      expect(decrypted, equals(originalMessage));
    });

    test('Chiffrement bidirectionnel (Alice ↔ Bob)', () async {
      // Générer les clés
      final aliceKeys = await CryptoService.generateRSAKeyPair();
      final bobKeys = await CryptoService.generateRSAKeyPair();

      // Alice → Bob
      const aliceMessage = 'Salut Bob!';
      final encryptedForBob = CryptoService.encryptWithPublicKey(
        recipientPublicKeyPem: bobKeys.publicKeyPem,
        plaintext: aliceMessage,
      );
      final decryptedByBob = CryptoService.decryptWithPrivateKey(
        myPrivateKeyPem: bobKeys.privateKeyPem,
        ciphertextB64: encryptedForBob,
      );
      expect(decryptedByBob, equals(aliceMessage));

      // Bob → Alice
      const bobMessage = 'Salut Alice!';
      final encryptedForAlice = CryptoService.encryptWithPublicKey(
        recipientPublicKeyPem: aliceKeys.publicKeyPem,
        plaintext: bobMessage,
      );
      final decryptedByAlice = CryptoService.decryptWithPrivateKey(
        myPrivateKeyPem: aliceKeys.privateKeyPem,
        ciphertextB64: encryptedForAlice,
      );
      expect(decryptedByAlice, equals(bobMessage));
    });

    test('Conversion PEM ↔ RSAPublicKey', () async {
      // Générer une paire
      final keyPair = await CryptoService.generateRSAKeyPair();

      // Convertir PEM → RSAPublicKey → PEM
      final publicKey = CryptoService.publicKeyFromPem(keyPair.publicKeyPem);
      final pemAgain = CryptoService.publicKeyToPem(publicKey);

      // Vérifier que le format est préservé (PKCS#8)
      expect(pemAgain, contains('-----BEGIN PUBLIC KEY-----'));
      expect(pemAgain, contains('-----END PUBLIC KEY-----'));
    });

    test('Ne peut pas déchiffrer avec la mauvaise clé privée', () async {
      // Générer deux paires différentes
      final aliceKeys = await CryptoService.generateRSAKeyPair();
      final eveKeys = await CryptoService.generateRSAKeyPair();

      // Alice chiffre un message pour elle-même
      const message = 'Secret message';
      final encrypted = CryptoService.encryptWithPublicKey(
        recipientPublicKeyPem: aliceKeys.publicKeyPem,
        plaintext: message,
      );

      // Eve essaie de déchiffrer avec SA clé privée (devrait échouer avec ArgumentError)
      expect(
        () => CryptoService.decryptWithPrivateKey(
          myPrivateKeyPem: eveKeys.privateKeyPem,
          ciphertextB64: encrypted,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Chiffrement de JSON (petit payload)', () async {
      // Générer les clés
      final keys = await CryptoService.generateRSAKeyPair();

      // Chiffrer un JSON
      const jsonPayload = '{"userId":"123","code":"ABC-XYZ"}';
      final encrypted = CryptoService.encryptWithPublicKey(
        recipientPublicKeyPem: keys.publicKeyPem,
        plaintext: jsonPayload,
      );

      // Déchiffrer
      final decrypted = CryptoService.decryptWithPrivateKey(
        myPrivateKeyPem: keys.privateKeyPem,
        ciphertextB64: encrypted,
      );

      expect(decrypted, equals(jsonPayload));
    });
  });
}





