import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:altoproject/core/config/app_config.dart';
import '../models/pairing_data.dart';
import '../services/crypto_service.dart';
import '../services/database_service.dart';
import '../services/key_storage.dart';
import '../services/pairing_api_service.dart';
import '../notifiers/add_user_notifier.dart';

/// Provider pour le service d'API de pairing
final pairingApiServiceProvider = Provider<PairingApiService>((ref) {
  return PairingApiService(baseUrl: AppConfig.pairingApiBaseUrl);
});

/// Provider pour le service de cryptographie
final cryptoServiceProvider = Provider<CryptoService>((ref) {
  return CryptoService();
});

/// Provider pour le stockage sécurisé
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider pour le stockage des clés
final keyStorageProvider = Provider<KeyStorage>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return KeyStorage(storage);
});

/// Provider pour le service de base de données
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Provider pour le notifier d'ajout d'utilisateur
final addUserNotifierProvider = StateNotifierProvider<AddUserNotifier, PairingState>((ref) {
  final apiService = ref.watch(pairingApiServiceProvider);
  final cryptoService = ref.watch(cryptoServiceProvider);
  final keyStorage = ref.watch(keyStorageProvider);
  final databaseService = ref.watch(databaseServiceProvider);

  return AddUserNotifier(
    apiService: apiService,
    cryptoService: cryptoService,
    keyStorage: keyStorage,
    databaseService: databaseService,
  );
});


