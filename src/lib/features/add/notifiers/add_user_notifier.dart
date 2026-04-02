import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:altoproject/core/models/contact.dart';
import '../models/pairing_data.dart';
import 'package:altoproject/services/crypto_service.dart';
import 'package:altoproject/services/database_service.dart';
import 'package:altoproject/services/key_storage.dart';
import 'package:altoproject/services/pairing_api_service.dart';

/// Notifier pour gérer l'ajout d'un utilisateur
class AddUserNotifier extends StateNotifier<PairingState> {
  final PairingApiService _apiService;
  final CryptoService _cryptoService;
  final KeyStorage _keyStorage;
  final DatabaseService _databaseService;

  Timer? _pollingTimer;
  String? _myRelationCode;
  String? _myPublicKey;
  String? _myPrivateKey;

  /// Nombre max de cycles de polling (2 s × 60 = 2 min)
  static const _maxPollingCycles = 60;

  AddUserNotifier({
    required PairingApiService apiService,
    required CryptoService cryptoService,
    required KeyStorage keyStorage,
    required DatabaseService databaseService,
  })  : _apiService = apiService,
        _cryptoService = cryptoService,
        _keyStorage = keyStorage,
        _databaseService = databaseService,
        super(PairingState.initial());

  /// Génère les clés et le QR code (Mode: Je montre mon QR code)
  Future<String> generateQrCode() async {
    try {
      // Génération de la paire de clés RSA
      final keyPair = _cryptoService.generateRsaKeyPair();
      _myPublicKey = keyPair.publicKeyPem;
      _myPrivateKey = keyPair.privateKeyPem;

      // Génération d'un relationCode unique
      _myRelationCode = const Uuid().v4();

      // Initialisation du pairing sur le serveur
      await _apiService.initPairing(
        relationCode: _myRelationCode!,
        publicKey: _myPublicKey!,
      );

      // Démarrage du polling pour détecter le match
      _startPolling(_myRelationCode!);

      // Retourne le relationCode à encoder dans le QR code
      return _myRelationCode!;
    } catch (e) {
      state = PairingState.error('Erreur lors de la génération du QR code: $e');
      rethrow;
    }
  }

  /// Traite le QR code scanné (Mode: Je scanne le QR code de l'autre)
  Future<void> handleScannedQrCode(String scannedRelationCode) async {
    try {
      // Génération de ma paire de clés
      final keyPair = _cryptoService.generateRsaKeyPair();
      _myPublicKey = keyPair.publicKeyPem;
      _myPrivateKey = keyPair.privateKeyPem;

      // Génération de mon relationCode
      _myRelationCode = const Uuid().v4();

      // Match avec le serveur
      final partnerResult = await _apiService.matchPairing(
        relationCodeA: scannedRelationCode,
        relationCodeB: _myRelationCode!,
        publicKeyB: _myPublicKey!,
      );
      // Convertir PairingPartnerData → PairingData (même structure)
      final partnerData = PairingData(
        relationCode: partnerResult.relationCode,
        publicKey: partnerResult.publicKey,
      );

      // Sauvegarde temporaire des données du partenaire
      state = state.copyWith(
        status: PairingStatus.completed,
        partnerData: partnerData,
      );

      // Sauvegarde de mes clés
      await _keyStorage.saveKeyPair(
        _myRelationCode!,
        publicKeyPem: _myPublicKey!,
        privateKeyPem: _myPrivateKey!,
      );

      // Démarrage du polling pour détecter la finalisation
      _startPollingForFinalization(scannedRelationCode);
    } catch (e) {
      state = PairingState.error('Erreur lors du scan: $e');
      rethrow;
    }
  }

  /// Démarre le polling pour détecter le match (côté initiateur)
  void _startPolling(String relationCode) {
    _pollingTimer?.cancel();
    int cycles = 0;

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      cycles++;
      if (cycles >= _maxPollingCycles) {
        timer.cancel();
        state = PairingState.timeout();
        return;
      }
      try {
        final status = await _apiService.getPairingStatus(relationCode);
        if (status == 'completed') {
          timer.cancel();
          await _finalizeAsInitiator(relationCode);
        }
      } catch (e) {
        // Ignore les erreurs de polling temporaires
      }
    });
  }

  /// Finalise le pairing côté initiateur (Alice)
  Future<void> _finalizeAsInitiator(String myRelationCode) async {
    try {
      // Récupération des infos du partenaire
      final partnerResult = await _apiService.finalizePairing(myRelationCode);
      final partnerData = PairingData(
        relationCode: partnerResult.relationCode,
        publicKey: partnerResult.publicKey,
      );

      // Sauvegarde de mes clés
      await _keyStorage.saveKeyPair(
        myRelationCode,
        publicKeyPem: _myPublicKey!,
        privateKeyPem: _myPrivateKey!,
      );

      // Mise à jour de l'état
      state = state.copyWith(
        status: PairingStatus.completed,
        partnerData: partnerData,
      );
    } catch (e) {
      state = PairingState.error('Erreur lors de la finalisation: $e');
      rethrow;
    }
  }

  /// Démarre le polling pour détecter la finalisation (côté scanner)
  void _startPollingForFinalization(String partnerRelationCode) {
    _pollingTimer?.cancel();
    int cycles = 0;

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      cycles++;
      if (cycles >= _maxPollingCycles) {
        timer.cancel();
        state = PairingState.timeout();
        return;
      }
      try {
        final status = await _apiService.getPairingStatus(partnerRelationCode);
        if (status == 'finalized') {
          timer.cancel();
          state = state.copyWith(status: PairingStatus.finalized);
        }
      } catch (e) {
        // Ignore les erreurs de polling temporaires
      }
    });
  }

  /// Confirme et sauvegarde le contact
  Future<void> confirmAndSaveContact(String contactName) async {
    try {
      if (state.partnerData == null) {
        throw Exception('Aucune donnée de partenaire disponible');
      }

      final contact = Contact(
        id: const Uuid().v4(),
        name: contactName,
        relationCode: state.partnerData!.relationCode,
        publicKey: state.partnerData!.publicKey,
        createdAt: DateTime.now(),
      );

      // Sauvegarde dans la base de données
      await _databaseService.insertContact(contact);

      // Réinitialisation de l'état
      state = PairingState.initial();
      _myRelationCode = null;
      _myPublicKey = null;
      _myPrivateKey = null;
    } catch (e) {
      state = PairingState.error('Erreur lors de la sauvegarde du contact: $e');
      rethrow;
    }
  }

  /// Annule le pairing en cours
  void cancel() {
    _pollingTimer?.cancel();
    state = PairingState.initial();
    _myRelationCode = null;
    _myPublicKey = null;
    _myPrivateKey = null;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

