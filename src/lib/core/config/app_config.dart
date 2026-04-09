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

  // ── Mises à jour (Option A — GitHub Releases) ─────────────────────────────
  /// Organisation ou utilisateur GitHub propriétaire du dépôt.
  static const String githubOwner = 'Osiris-Sio';

  /// Nom du dépôt GitHub.
  static const String githubRepo = 'altoproject';

  /// URL de l'API GitHub Releases (latest).
  static String get githubLatestReleaseUrl =>
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  /// URL de la page des releases (pour le lien "Télécharger").
  static String get githubReleasesPageUrl =>
      'https://github.com/$githubOwner/$githubRepo/releases/latest';
}
