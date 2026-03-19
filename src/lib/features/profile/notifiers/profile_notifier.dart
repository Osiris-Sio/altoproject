import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/pairing_relation.dart';

class ProfileNotifier extends ChangeNotifier {
  PairingRelation? _currentPairing;
  PairingRelation? get currentPairing => _currentPairing;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _countdownTimer;
  Timer? _pollingTimer;

  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (_currentPairing == null) return 0.0;
    return _currentPairing!.progressPercentage;
  }

  bool get hasExpired => _remainingSeconds <= 0;

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  /// Initialise un nouveau pairing
  Future<void> initiatePairing() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Utiliser une clé publique fictive pour les tests
      const publicKey = 'TEST_PUBLIC_KEY_FOR_QR_CODE_DEMO';

      // Générer un relationCode unique
      final relationCode = const Uuid().v4().substring(0, 8).toUpperCase();

      // Créer la relation localement
      _currentPairing = PairingRelation.create(
        relationCode: relationCode,
        userPublicKey: publicKey,
      );

      // TODO: Décommenter quand l'API est prête
      // Initialiser via l'API
      // _currentPairing = await PairingApiService.initPairing(
      //   relationCode: relationCode,
      //   userPublicKey: publicKey,
      // );

      // Démarrer les timers
      _startCountdown();
      _startPolling();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'initialisation: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Démarre le compte à rebours
  void _startCountdown() {
    _stopTimers();

    if (_currentPairing == null) return;

    _remainingSeconds = _currentPairing!.timeRemaining.inSeconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _handleTimeout();
      }
    });
  }

  /// Démarre le polling du statut
  void _startPolling() {
    _pollingTimer?.cancel();

    // Vérifier le statut toutes les 3 secondes
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkPairingStatus();
    });
  }

  /// Vérifie le statut du pairing via l'API
  Future<void> _checkPairingStatus() async {
    if (_currentPairing == null) return;

    try {
      // TODO: Décommenter quand l'API est prête
      // final statusResponse = await PairingApiService.getStatus(
      //   _currentPairing!.relationCode,
      // );

      // Simulation pour le développement
      // Décommenter et adapter avec la vraie réponse API
      /*
      if (statusResponse.status == PairingStatus.matched) {
        _currentPairing = _currentPairing!.copyWith(
          status: PairingStatus.matched,
          partnerPublicKey: statusResponse.partnerPublicKey,
          partnerRelationCode: statusResponse.partnerRelationCode,
        );

        _stopTimers();
        notifyListeners();

        // Appeler le callback de succès si nécessaire
        _onPairingMatched();
      }
      */
    } catch (e) {
      // Log l'erreur mais ne pas arrêter le polling
      debugPrint('Erreur lors du polling: $e');
    }
  }

  /// Gère l'expiration du timeout
  void _handleTimeout() {
    _stopTimers();

    if (_currentPairing != null) {
      _currentPairing = _currentPairing!.copyWith(
        status: PairingStatus.expired,
      );
    }

    _errorMessage = 'Le délai de pairing a expiré';
    notifyListeners();
  }


  /// Réinitialise le pairing
  Future<void> resetPairing() async {
    _stopTimers();
    _currentPairing = null;
    _errorMessage = null;
    notifyListeners();

    await initiatePairing();
  }

  /// Arrête tous les timers
  void _stopTimers() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Annule le pairing en cours
  void cancelPairing() {
    _stopTimers();
    _currentPairing = null;
    _remainingSeconds = 0;
    _errorMessage = null;
    notifyListeners();
  }
}

