import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:altoproject/core/config/app_config.dart';
import 'package:altoproject/services/crypto_service.dart';
import 'package:altoproject/services/database_service.dart';
import 'package:altoproject/services/element_api_service.dart';
import 'package:altoproject/services/key_storage.dart';
import 'package:altoproject/services/message_storage_service.dart';
import 'package:altoproject/services/pairing_api_service.dart';

/// Stockage sécurisé Flutter (singleton)
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Service de cryptographie RSA
final cryptoServiceProvider = Provider<CryptoService>((ref) {
  return CryptoService();
});

/// Stockage des clés RSA (indexé par relationId ou "profile")
final keyStorageProvider = Provider<KeyStorage>((ref) {
  return KeyStorage(ref.watch(secureStorageProvider));
});

/// Service de base de données (contacts)
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Service d'API pairing
final pairingApiServiceProvider = Provider<PairingApiService>((ref) {
  return PairingApiService(baseUrl: AppConfig.pairingApiBaseUrl);
});

/// Service d'API échange d'éléments chiffrés
final elementApiServiceProvider = Provider<ElementApiService>((ref) {
  return const ElementApiService(baseUrl: AppConfig.pairingApiBaseUrl);
});

/// Service de persistance locale des messages
final messageStorageServiceProvider = Provider<MessageStorageService>((ref) {
  return MessageStorageService();
});

