import 'package:flutter_test/flutter_test.dart';
import 'package:altoproject/features/add/models/contact.dart';
import 'package:altoproject/features/add/models/pairing_data.dart';
import 'package:altoproject/services/crypto_service.dart';

void main() {
  group('Contact Model Tests', () {
    test('Contact toJson and fromJson should work correctly', () {
      final contact = Contact(
        id: 'test-id',
        name: 'Test User',
        relationCode: 'test-relation-code',
        publicKey: 'test-public-key',
        createdAt: DateTime.parse('2026-03-05T10:00:00Z'),
      );

      final json = contact.toJson();
      final contactFromJson = Contact.fromJson(json);

      expect(contactFromJson.id, contact.id);
      expect(contactFromJson.name, contact.name);
      expect(contactFromJson.relationCode, contact.relationCode);
      expect(contactFromJson.publicKey, contact.publicKey);
      expect(contactFromJson.createdAt, contact.createdAt);
    });

    test('Contact toJson and fromJson (via toMap alias) should work correctly', () {
      final contact = Contact(
        id: 'test-id',
        name: 'Test User',
        relationCode: 'test-relation-code',
        publicKey: 'test-public-key',
        createdAt: DateTime.parse('2026-03-05T10:00:00Z'),
      );

      final map = contact.toJson();
      final contactFromMap = Contact.fromJson(map);

      expect(contactFromMap.id, contact.id);
      expect(contactFromMap.name, contact.name);
      expect(contactFromMap.relationCode, contact.relationCode);
      expect(contactFromMap.publicKey, contact.publicKey);
      expect(contactFromMap.createdAt, contact.createdAt);
    });
  });

  group('PairingData Model Tests', () {
    test('PairingData toJson and fromJson should work correctly', () {
      final pairingData = PairingData(
        relationCode: 'test-relation-code',
        publicKey: 'test-public-key',
      );

      final json = pairingData.toJson();
      final pairingDataFromJson = PairingData.fromJson(json);

      expect(pairingDataFromJson.relationCode, pairingData.relationCode);
      expect(pairingDataFromJson.publicKey, pairingData.publicKey);
    });
  });

  group('PairingState Tests', () {
    test('PairingState initial should have waiting status', () {
      final state = PairingState.initial();

      expect(state.status, PairingStatus.waiting);
      expect(state.partnerData, isNull);
      expect(state.errorMessage, isNull);
    });

    test('PairingState error should have error status and message', () {
      final state = PairingState.error('Test error');

      expect(state.status, PairingStatus.error);
      expect(state.errorMessage, 'Test error');
      expect(state.partnerData, isNull);
    });

    test('PairingState copyWith should work correctly', () {
      final state = PairingState.initial();
      final pairingData = PairingData(
        relationCode: 'test-code',
        publicKey: 'test-key',
      );

      final newState = state.copyWith(
        status: PairingStatus.completed,
        partnerData: pairingData,
      );

      expect(newState.status, PairingStatus.completed);
      expect(newState.partnerData, pairingData);
      expect(newState.errorMessage, isNull);
    });
  });

  group('CryptoService Tests', () {
    test('generateRsaKeyPair should generate valid key pair', () {
      final cryptoService = CryptoService();
      final keyPair = cryptoService.generateRsaKeyPair();

      expect(keyPair.publicKeyPem, isNotEmpty);
      expect(keyPair.privateKeyPem, isNotEmpty);
      expect(keyPair.publicKeyPem, contains('BEGIN RSA PUBLIC KEY'));
      expect(keyPair.publicKeyPem, contains('END RSA PUBLIC KEY'));
      expect(keyPair.privateKeyPem, contains('BEGIN RSA PRIVATE KEY'));
      expect(keyPair.privateKeyPem, contains('END RSA PRIVATE KEY'));
    });

    test('generateRsaKeyPair should generate different keys each time', () {
      final cryptoService = CryptoService();
      final keyPair1 = cryptoService.generateRsaKeyPair();
      final keyPair2 = cryptoService.generateRsaKeyPair();

      expect(keyPair1.publicKeyPem, isNot(equals(keyPair2.publicKeyPem)));
      expect(keyPair1.privateKeyPem, isNot(equals(keyPair2.privateKeyPem)));
    });

    test('generateRsaKeyPair with custom bit length should work', () {
      final cryptoService = CryptoService();
      final keyPair = cryptoService.generateRsaKeyPair(bitLength: 1024);

      expect(keyPair.publicKeyPem, isNotEmpty);
      expect(keyPair.privateKeyPem, isNotEmpty);
    });
  });
}

