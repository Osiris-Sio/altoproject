import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/core/providers/app_providers.dart';
import '../models/pairing_data.dart';
import '../notifiers/add_user_notifier.dart';

// Re-export des providers partagés pour rétro-compatibilité
export 'package:altoproject/core/providers/app_providers.dart'
    show
        secureStorageProvider,
        cryptoServiceProvider,
        keyStorageProvider,
        databaseServiceProvider,
        pairingApiServiceProvider;

/// Provider pour le notifier d'ajout d'utilisateur
final addUserNotifierProvider =
    StateNotifierProvider<AddUserNotifier, PairingState>((ref) {
  return AddUserNotifier(
    apiService: ref.watch(pairingApiServiceProvider),
    cryptoService: ref.watch(cryptoServiceProvider),
    keyStorage: ref.watch(keyStorageProvider),
    databaseService: ref.watch(databaseServiceProvider),
  );
});
