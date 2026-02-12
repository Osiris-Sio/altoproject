import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../../../services/crypto_service.dart';
import '../../../services/secure_storage_service.dart';

class AddUserNotifier extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Crée un nouvel utilisateur avec génération de clés RSA
  Future<bool> createUser(String firstName) async {
    if (firstName.trim().isEmpty) {
      _errorMessage = "Le prénom ne peut pas être vide";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Générer UUID unique
      final uuid = const Uuid().v4();

      // 2. Générer les clés RSA 2048 bits
      final keyPair = await CryptoService.generateRSAKeyPair();
      final publicKeyPem = CryptoService.publicKeyToPem(keyPair.publicKey);
      final privateKeyPem = CryptoService.privateKeyToPem(keyPair.privateKey);

      // 3. Créer le modèle utilisateur
      _currentUser = UserModel(
        firstName: firstName.trim(),
        uuid: uuid,
        publicKey: publicKeyPem,
      );

      // 4. Sauvegarder les données de manière sécurisée
      await SecureStorageService.savePrivateKey(privateKeyPem);
      await SecureStorageService.savePublicKey(publicKeyPem);
      await SecureStorageService.saveUserUuid(uuid);
      await SecureStorageService.saveFirstName(firstName.trim());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Erreur lors de la création du compte: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Charge l'utilisateur existant depuis le stockage sécurisé
  Future<void> loadExistingUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasUser = await SecureStorageService.hasUser();
      if (!hasUser) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final firstName = await SecureStorageService.getFirstName();
      final uuid = await SecureStorageService.getUserUuid();
      final publicKey = await SecureStorageService.getPublicKey();

      if (firstName != null && uuid != null && publicKey != null) {
        _currentUser = UserModel(
          firstName: firstName,
          uuid: uuid,
          publicKey: publicKey,
        );
      }
    } catch (e) {
      _errorMessage = "Erreur lors du chargement: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialise les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Supprime l'utilisateur actuel
  Future<void> deleteUser() async {
    await SecureStorageService.clearAll();
    _currentUser = null;
    notifyListeners();
  }
}

