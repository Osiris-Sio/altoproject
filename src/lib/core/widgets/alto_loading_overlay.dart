import 'package:flutter/material.dart';
import 'package:altoproject/core/config/app_colors.dart';

/// Overlay de chargement semi-transparent avec carte centrale.
///
/// À utiliser dans un Stack au-dessus du contenu principal :
/// ```dart
/// if (isLoading)
///   const AltoLoadingOverlay(message: 'Génération des clés…'),
/// ```
class AltoLoadingOverlay extends StatelessWidget {
  final String? message;

  const AltoLoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

