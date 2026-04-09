import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altoproject/services/update_service.dart';

/// Provider du service de mise à jour.
final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

/// Provider asynchrone qui vérifie les mises à jour au démarrage.
/// Retourne null si aucune mise à jour ou en cas d'erreur réseau.
final updateInfoProvider = FutureProvider<UpdateInfo?>((ref) async {
  final service = ref.read(updateServiceProvider);
  final info = await service.checkForUpdate();
  // Ne retourner que si une mise à jour est réellement disponible
  if (info == null || !info.hasUpdate) return null;
  return info;
});

