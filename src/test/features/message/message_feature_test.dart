import 'package:flutter_test/flutter_test.dart';
import 'package:altoproject/features/message/models/message.dart';
import 'package:altoproject/services/message_storage_service.dart';
import 'package:altoproject/services/crypto_service.dart';

void main() {
  // ── Message Model ──────────────────────────────────────────────────────────
  group('Message Model', () {
    test('Message crée correctement avec tous les champs', () {
      final now = DateTime.now();
      final msg = Message(
        id: 'test-id',
        type: 'MESSAGE',
        content: 'Hello!',
        isMine: true,
        timestamp: now,
      );

      expect(msg.id, 'test-id');
      expect(msg.type, 'MESSAGE');
      expect(msg.content, 'Hello!');
      expect(msg.isMine, true);
      expect(msg.timestamp, now);
    });
  });

  // ── MessageState ───────────────────────────────────────────────────────────
  group('MessageState', () {
    test('initial() crée un état vide', () {
      final state = MessageState.initial();
      expect(state.messages, isEmpty);
      expect(state.isSending, false);
      expect(state.isRefreshing, false);
      expect(state.error, isNull);
      expect(state.messageSent, false);
    });

    test('copyWith() met à jour les champs correctement', () {
      final state = MessageState.initial();
      final updated = state.copyWith(isSending: true, messageSent: true);

      expect(updated.isSending, true);
      expect(updated.messageSent, true);
      expect(updated.messages, isEmpty); // non modifié
    });

    test('copyWith(clearError: true) efface l\'erreur', () {
      final state = MessageState.initial().copyWith(error: 'Une erreur');
      expect(state.error, 'Une erreur');

      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });

    test('copyWith(clearMessageSent: true) remet messageSent à false', () {
      final state = MessageState.initial().copyWith(messageSent: true);
      expect(state.messageSent, true);

      final cleared = state.copyWith(clearMessageSent: true);
      expect(cleared.messageSent, false);
    });

    test('addMessage via copyWith préserve les messages existants', () {
      final msg1 = Message(
        id: '1',
        type: 'MESSAGE',
        content: 'Premier',
        isMine: true,
        timestamp: DateTime.now(),
      );
      final msg2 = Message(
        id: '2',
        type: 'MESSAGE',
        content: 'Deuxième',
        isMine: false,
        timestamp: DateTime.now(),
      );

      var state = MessageState.initial().copyWith(messages: [msg1]);
      state = state.copyWith(messages: [...state.messages, msg2]);

      expect(state.messages.length, 2);
      expect(state.messages[0].content, 'Premier');
      expect(state.messages[1].content, 'Deuxième');
    });
  });

  // ── StoredMessage ──────────────────────────────────────────────────────────
  group('StoredMessage serialization', () {
    test('toJson/fromJson round-trip fonctionne', () {
      final original = StoredMessage(
        id: 'abc-123',
        type: 'MESSAGE',
        content: 'Test message',
        isMine: true,
        timestamp: DateTime.parse('2026-04-08T12:00:00Z'),
      );

      final json = original.toJson();
      final restored = StoredMessage.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.content, original.content);
      expect(restored.isMine, original.isMine);
      expect(restored.timestamp.toIso8601String(),
          original.timestamp.toIso8601String());
    });

    test('isMine false est sérialisé correctement', () {
      final msg = StoredMessage(
        id: 'xyz',
        type: 'MESSAGE',
        content: 'Reçu',
        isMine: false,
        timestamp: DateTime.now(),
      );
      final json = msg.toJson();
      expect(json['isMine'], false);
      final restored = StoredMessage.fromJson(json);
      expect(restored.isMine, false);
    });
  });

  // ── CryptoService chiffrement/déchiffrement ────────────────────────────────
  group('CryptoService encrypt/decrypt round-trip', () {
    final crypto = CryptoService();

    test('chiffrement avec clé publique et déchiffrement avec clé privée', () {
      // Générer une paire de clés RSA 1024 bits (plus rapide pour les tests)
      final keyPair = crypto.generateRsaKeyPair(bitLength: 1024);

      const plaintext = 'Bonjour Alto!';

      final encrypted = crypto.encryptWithPublicKey(
        recipientPublicKeyPem: keyPair.publicKeyPem,
        plaintext: plaintext,
      );

      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(contains(plaintext))); // bien chiffré

      final decrypted = crypto.decryptWithPrivateKey(
        myPrivateKeyPem: keyPair.privateKeyPem,
        ciphertextB64: encrypted,
      );

      expect(decrypted, plaintext);
    });

    test('deux chiffrements du même texte donnent des résultats différents (OAEP)', () {
      final keyPair = crypto.generateRsaKeyPair(bitLength: 1024);
      const plaintext = 'Test';

      final enc1 = crypto.encryptWithPublicKey(
        recipientPublicKeyPem: keyPair.publicKeyPem,
        plaintext: plaintext,
      );
      final enc2 = crypto.encryptWithPublicKey(
        recipientPublicKeyPem: keyPair.publicKeyPem,
        plaintext: plaintext,
      );

      // OAEP utilise un padding aléatoire → toujours différent
      expect(enc1, isNot(equals(enc2)));
    });

    test('déchiffrement avec mauvaise clé privée lance une erreur', () {
      final keyPair1 = crypto.generateRsaKeyPair(bitLength: 1024);
      final keyPair2 = crypto.generateRsaKeyPair(bitLength: 1024);

      final encrypted = crypto.encryptWithPublicKey(
        recipientPublicKeyPem: keyPair1.publicKeyPem,
        plaintext: 'Secret',
      );

      // Déchiffrer avec la mauvaise clé doit échouer (ArgumentError ou Exception)
      expect(
        () => crypto.decryptWithPrivateKey(
          myPrivateKeyPem: keyPair2.privateKeyPem,
          ciphertextB64: encrypted,
        ),
        throwsA(anything),
      );
    });
  });
}


