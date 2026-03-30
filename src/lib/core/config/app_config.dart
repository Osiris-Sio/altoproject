/// Configuration centralisée de l'application Alto.
/// C'est ici l'unique endroit où modifier l'URL du backend.
class AppConfig {
  // ── Backend ──────────────────────────────────────────────────────────────
  static const String pairingApiBaseUrl = 'https://alto.samyn.ovh';

  // ── Polling ───────────────────────────────────────────────────────────────
  static const Duration pollingInterval = Duration(seconds: 2);

  // ── Cryptographie ─────────────────────────────────────────────────────────
  static const int rsaKeyBitLength = 2048;

  // ── Pairing ───────────────────────────────────────────────────────────────
  /// Durée de validité d'un pairing avant expiration côté client.
  static const Duration pairingTimeout = Duration(minutes: 2);
}
