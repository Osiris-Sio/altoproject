import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:altoproject/core/config/app_colors.dart';
import 'package:altoproject/core/providers/update_provider.dart';
import 'package:altoproject/services/update_service.dart';

/// États du téléchargement in-app.
enum _DownloadState { idle, downloading, error }

/// Bannière de mise à jour affichée en haut de l'écran principal.
class UpdateBanner extends ConsumerStatefulWidget {
  const UpdateBanner({super.key});

  @override
  ConsumerState<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends ConsumerState<UpdateBanner> {
  bool _dismissed = false;
  _DownloadState _downloadState = _DownloadState.idle;
  double _progress = 0.0;
  String? _errorMessage;

  // ── Téléchargement + installation directe ──────────────────────────────

  Future<void> _downloadAndInstall(UpdateInfo info) async {
    final apkUrl = info.apkDownloadUrl;
    if (apkUrl == null) {
      // Pas d'APK joint → ouvrir la page releases dans le navigateur
      _openReleasePage(info);
      return;
    }

    setState(() {
      _downloadState = _DownloadState.downloading;
      _progress = 0.0;
      _errorMessage = null;
    });

    try {
      await ref.read(updateServiceProvider).downloadAndInstall(
            apkUrl,
            onProgress: (p) {
              if (mounted) setState(() => _progress = p);
            },
          );
      // L'installeur Android prend la main → pas besoin de changer l'état
      if (mounted) setState(() => _downloadState = _DownloadState.idle);
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadState = _DownloadState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _openReleasePage(UpdateInfo info) async {
    final uri = Uri.parse(info.releasesPageUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showChangelog(BuildContext context, UpdateInfo info) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nouveautés v${info.latestVersion}'),
        content: SingleChildScrollView(
          child: Text(
            info.changelog.isNotEmpty
                ? info.changelog
                : 'Aucune note de version disponible.',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _downloadAndInstall(info);
            },
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text(
              Platform.isAndroid && info.apkDownloadUrl != null
                  ? 'Installer'
                  : 'Télécharger',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final updateAsync = ref.watch(updateInfoProvider);

    return updateAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (info) {
        if (info == null) return const SizedBox.shrink();
        return _buildBanner(context, info);
      },
    );
  }

  Widget _buildBanner(BuildContext context, UpdateInfo info) {
    return Material(
      elevation: 2,
      color: _downloadState == _DownloadState.error
          ? Colors.red.shade700
          : AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Icône / spinner
                  _buildLeadingIcon(),
                  const SizedBox(width: 12),

                  // Texte
                  Expanded(child: _buildText(info)),

                  // Actions
                  if (_downloadState == _DownloadState.idle) ...[
                    _ActionButton(
                      label: 'Voir',
                      onPressed: () => _showChangelog(context, info),
                    ),
                    const SizedBox(width: 4),
                    _ActionButton(
                      label: Platform.isAndroid && info.apkDownloadUrl != null
                          ? 'Installer'
                          : 'Obtenir',
                      onPressed: () => _downloadAndInstall(info),
                    ),
                    const SizedBox(width: 4),
                    _CloseButton(onPressed: () => setState(() => _dismissed = true)),
                  ],

                  if (_downloadState == _DownloadState.error) ...[
                    _ActionButton(
                      label: 'Réessayer',
                      onPressed: () => _downloadAndInstall(info),
                    ),
                    const SizedBox(width: 4),
                    _CloseButton(onPressed: () => setState(() => _dismissed = true)),
                  ],
                ],
              ),
            ),

            // Barre de progression (visible pendant le téléchargement)
            if (_downloadState == _DownloadState.downloading)
              LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 3,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    if (_downloadState == _DownloadState.downloading) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: _progress > 0 ? _progress : null,
              strokeWidth: 2.5,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
            ),
            Text(
              _progress > 0 ? '${(_progress * 100).round()}%' : '',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _downloadState == _DownloadState.error
            ? Icons.error_outline
            : Icons.system_update_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildText(UpdateInfo info) {
    if (_downloadState == _DownloadState.downloading) {
      final pct = (_progress * 100).round();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Téléchargement en cours…',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
          Text(
            '$pct %',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
          ),
        ],
      );
    }
    if (_downloadState == _DownloadState.error) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Erreur de téléchargement',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
          Text(
            _errorMessage ?? 'Une erreur est survenue.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75), fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Mise à jour disponible — v${info.latestVersion}',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
        Text(
          'Vous utilisez v${info.currentVersion}',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
        ),
      ],
    );
  }
}

// ── Widgets internes ───────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _ActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.close, color: Colors.white, size: 18),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      tooltip: 'Ignorer',
    );
  }
}
