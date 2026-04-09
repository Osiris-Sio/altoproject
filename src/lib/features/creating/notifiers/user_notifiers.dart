import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altoproject/core/config/app_config.dart';
import 'package:altoproject/core/providers/app_providers.dart';
import 'package:altoproject/services/crypto_service.dart';
import '../models/user.dart';

class UserNotifiers extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('user_firstName') ?? '';
    final lastName = prefs.getString('user_lastName') ?? '';
    return User(firstName: firstName, lastName: lastName);
  }

  /// Sauvegarde le nom + génère la paire de clés RSA du profil.
  Future<void> setNames(String firstName, String lastName) async {
    state = const AsyncLoading();

    try {
      // 1. Sauvegarder le nom dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_firstName', firstName);
      await prefs.setString('user_lastName', lastName);

      // 2. Générer la paire de clés RSA dans un isolate (non bloquant pour l'UI)
      final keyPair = await compute(
        _generateRsaKeyPair,
        AppConfig.rsaKeyBitLength,
      );

      // 3. Stocker les clés dans flutter_secure_storage
      final keyStorage = ref.read(keyStorageProvider);
      await keyStorage.saveProfileKeyPair(
        publicKeyPem: keyPair.publicKeyPem,
        privateKeyPem: keyPair.privateKeyPem,
      );

      state = AsyncData(User(firstName: firstName, lastName: lastName));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Met à jour uniquement le nom/prénom (sans régénérer les clés RSA).
  Future<void> updateNames(String firstName, String lastName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_firstName', firstName);
    await prefs.setString('user_lastName', lastName);
    state = AsyncData(User(firstName: firstName, lastName: lastName));
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AsyncData(User(firstName: '', lastName: ''));
  }
}

/// Fonction top-level pour compute() — génère une paire de clés RSA dans un isolate.
({String publicKeyPem, String privateKeyPem}) _generateRsaKeyPair(
    int bitLength) {
  return CryptoService().generateRsaKeyPair(bitLength: bitLength);
}
