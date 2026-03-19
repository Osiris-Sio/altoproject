/// Configuration de l'application Alto
class AppConfig {
  // URL du backend de pairing
  // IMPORTANT : Modifiez cette URL selon votre environnement
  static const String pairingApiBaseUrl = 'http://localhost:8080';

  // Pour tester sur un appareil physique avec un émulateur :
  // Android : utilisez l'IP de votre machine (ex: 'http://192.168.1.100:8080')
  // iOS : utilisez l'IP de votre machine (ex: 'http://192.168.1.100:8080')

  // Pour deux émulateurs Android :
  // static const String pairingApiBaseUrl = 'http://10.0.2.2:8080';

  // Paramètres de polling
  static const Duration pollingInterval = Duration(seconds: 2);

  // Paramètres de cryptographie
  static const int rsaKeyBitLength = 2048;

  // Timeout du pairing (côté client)
  static const Duration pairingTimeout = Duration(minutes: 2);

  // Configuration de la base de données
  static const String databaseName = 'alto.db';
  static const int databaseVersion = 1;
}

