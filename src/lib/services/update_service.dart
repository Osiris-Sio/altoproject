import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:altoproject/core/config/app_config.dart';

/// Exception levée quand la permission d'installation est refusée.
/// Utilisée par UpdateBanner pour afficher un bouton "Autoriser".
class InstallPermissionDeniedException implements Exception {
  final String message;
  const InstallPermissionDeniedException(this.message);

  @override
  String toString() => message;
}

/// Résultat de la vérification de mise à jour.
class UpdateInfo {
  /// Version actuelle de l'application installée (ex: "1.0.0").
  final String currentVersion;

  /// Dernière version disponible sur GitHub (ex: "1.2.0").
  final String latestVersion;

  /// Notes de version (body de la release GitHub).
  final String changelog;

  /// URL directe vers le fichier APK à télécharger (null si introuvable).
  final String? apkDownloadUrl;

  /// URL de la page GitHub Releases.
  final String releasesPageUrl;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.changelog,
    this.apkDownloadUrl,
    required this.releasesPageUrl,
  });

  /// Vrai si une mise à jour est disponible (latest > current).
  bool get hasUpdate => _compareVersions(latestVersion, currentVersion) > 0;

  /// Compare deux versions sémantiques (ex: "1.2.0" vs "1.0.0").
  /// Retourne positif si [a] > [b], négatif si [a] < [b], 0 si égaux.
  static int _compareVersions(String a, String b) {
    final partsA = _parseParts(a);
    final partsB = _parseParts(b);
    for (var i = 0; i < 3; i++) {
      final diff = partsA[i] - partsB[i];
      if (diff != 0) return diff;
    }
    return 0;
  }

  static List<int> _parseParts(String version) {
    // Supprime le préfixe "v" éventuel (ex: "v1.2.0" → "1.2.0")
    final clean = version.replaceFirst(RegExp(r'^v'), '');
    final parts = clean.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts;
  }
}

/// Service de vérification de mise à jour via l'API GitHub Releases.
class UpdateService {
  final http.Client _client;

  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  /// Vérifie si une mise à jour est disponible.
  /// Retourne null en cas d'erreur réseau (silencieux).
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // ex: "1.0.0"

      final response = await _client
          .get(
            Uri.parse(AppConfig.githubLatestReleaseUrl),
            headers: {
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final latestVersion = (data['tag_name'] as String? ?? '').replaceFirst(RegExp(r'^v'), '');
      final changelog = data['body'] as String? ?? '';

      // Chercher un APK dans les assets de la release
      String? apkUrl;
      final assets = data['assets'] as List<dynamic>? ?? [];
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String?;
          break;
        }
      }

      return UpdateInfo(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        changelog: changelog,
        apkDownloadUrl: apkUrl,
        releasesPageUrl: AppConfig.githubReleasesPageUrl,
      );
    } catch (_) {
      // Silencieux : pas de réseau ou repo privé → pas de bannière
      return null;
    }
  }

  /// Télécharge l'APK depuis [apkUrl] et lance l'installation système.
  ///
  /// [onProgress] reçoit une valeur entre 0.0 et 1.0 pendant le téléchargement.
  /// Lève une [Exception] en cas d'erreur.
  Future<void> downloadAndInstall(
    String apkUrl, {
    void Function(double progress)? onProgress,
  }) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
          'Installation directe uniquement disponible sur Android.');
    }

    // Dossier cache de l'application (pas besoin de permission WRITE_STORAGE)
    final cacheDir = await getTemporaryDirectory();
    final apkFile = File('${cacheDir.path}/alto_update.apk');

    // Supprimer un éventuel APK résiduel
    if (await apkFile.exists()) await apkFile.delete();

    // Téléchargement en streaming pour suivre la progression
    final request = http.Request('GET', Uri.parse(apkUrl));
    final streamedResponse = await _client
        .send(request)
        .timeout(const Duration(minutes: 10));

    if (streamedResponse.statusCode != 200) {
      throw Exception(
          'Téléchargement échoué (HTTP ${streamedResponse.statusCode})');
    }

    final totalBytes = streamedResponse.contentLength ?? 0;
    var receivedBytes = 0;
    final sink = apkFile.openWrite();

    await for (final chunk in streamedResponse.stream) {
      sink.add(chunk);
      receivedBytes += chunk.length;
      if (totalBytes > 0) {
        onProgress?.call(receivedBytes / totalBytes);
      }
    }
    await sink.close();
    onProgress?.call(1.0);

    // ── Vérification permission installation (Android 8+) ─────────────────
    if (Platform.isAndroid) {
      var status = await Permission.requestInstallPackages.status;
      if (!status.isGranted) {
        // Ouvre automatiquement Paramètres → Apps → Alto → Installer apps inconnues
        status = await Permission.requestInstallPackages.request();
        if (!status.isGranted) {
          throw const InstallPermissionDeniedException(
            'Permission "Installer des applications inconnues" refusée.\n'
            'Activez-la dans Paramètres → Apps → Alto.',
          );
        }
      }
    }

    // Déclencher l'installeur système Android
    final result = await OpenFile.open(apkFile.path);
    debugPrint('[UpdateService] OpenFile: ${result.type} — ${result.message}');

    if (result.type != ResultType.done) {
      throw Exception(
          'L\'installeur n\'a pas pu démarrer : ${result.message}');
    }
  }
}

