import 'package:flutter/material.dart';

/// Palette de couleurs centralisée d'Alto.
/// Toute couleur codée en dur doit référencer cette classe.
abstract final class AppColors {
  // ── Couleurs principales ────────────────────────────────────────────────
  /// Violet principal Alto — boutons, avatars, icônes actives.
  static const Color primary = Color(0xFF6B4FA0);

  /// Violet foncé — utilisé en fin de dégradé.
  static const Color primaryDark = Color(0xFF4A3070);

  /// Violet très foncé — texte, fond mode sombre.
  static const Color dark = Color(0xFF2D1B4E);

  // ── Surfaces et fonds ──────────────────────────────────────────────────
  /// Fond lilac léger — avatars, chips sélectionnés, bulles reçues.
  static const Color surface = Color(0xFFE6D5F5);

  /// Fond lilac moyen — AppBar des écrans de pairing.
  static const Color backgroundMedium = Color(0xFFEDE6F5);

  /// Fond écran messagerie.
  static const Color scaffoldBackground = Color(0xFFF4EFF9);

  /// Fond champ de saisie.
  static const Color inputBackground = Color(0xFFF0EBF8);

  /// Fond badge chiffrement / boutons secondaires discrets.
  static const Color surfaceAccent = Color(0xFFEDE3F8);

  // ── États désactivés ───────────────────────────────────────────────────
  /// Violet atténué — bordures secondaires, icônes désactivées.
  static const Color muted = Color(0xFFD4C5E8);

  /// Bouton principal désactivé.
  static const Color disabled = Color(0xFFAA90CC);

  /// Bouton d'envoi désactivé.
  static const Color sendDisabled = Color(0xFFCCBCE8);

  // ── Couleurs adaptatives (requièrent un BuildContext) ────────────────────
  // Ces méthodes renvoient la couleur correcte selon le thème actif.

  /// Fond de carte / conteneur blanc.
  /// Clair : blanc. Sombre : [ColorScheme.surfaceContainerHigh].
  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surfaceContainerHigh
          : Colors.white;

  /// Fond lilac adaptatif (avatars, chips, icônes de liste).
  /// Clair : [surface] lilas. Sombre : [ColorScheme.surfaceContainerHighest].
  static Color adaptiveSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : surface;

  /// Fond des écrans de pairing (scaffold + AppBar).
  /// Clair : [backgroundMedium]. Sombre : [ColorScheme.surfaceContainerLow].
  static Color pairingBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surfaceContainerLow
          : backgroundMedium;

  /// Fond des champs de saisie.
  /// Clair : [inputBackground]. Sombre : [ColorScheme.surfaceContainerHighest].
  static Color inputBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : inputBackground;

  /// Couleur de texte principal adaptative (remplace [dark] en mode sombre).
  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  /// Fond de bannière chiffrement / badges discrets.
  /// Clair : [surfaceAccent]. Sombre : [ColorScheme.surfaceContainerLow].
  static Color accentBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surfaceContainerLow
          : surfaceAccent;

  /// Fond AppBar.
  /// Clair : blanc. Sombre : [ColorScheme.surface].
  static Color appBarBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface
          : Colors.white;
}
