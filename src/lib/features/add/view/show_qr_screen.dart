import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:altoproject/features/add/providers/add_providers.dart';
import 'package:altoproject/features/add/models/pairing_data.dart';
import 'package:altoproject/features/add/view/add_confirm_screen.dart';

/// Écran affichant le QR code de pairing (rôle Alice)
class ShowQrScreen extends ConsumerStatefulWidget {
  const ShowQrScreen({super.key});

  @override
  ConsumerState<ShowQrScreen> createState() => _ShowQrScreenState();
}

class _ShowQrScreenState extends ConsumerState<ShowQrScreen> {
  String? _qrData;
  bool _isLoading = true;
  String? _error;

  // ── Timer countdown 2 minutes ─────────────────────────────────────────────
  static const _totalSeconds = 120; // AppConfig.pairingTimeout
  int _remainingSeconds = _totalSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startQrGeneration();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    ref.read(addUserNotifierProvider.notifier).cancel();
    super.dispose();
  }

  // ── Génération du QR code et lancement du timer ───────────────────────────

  Future<void> _startQrGeneration() async {
    _countdownTimer?.cancel();
    setState(() {
      _isLoading = true;
      _error = null;
      _qrData = null;
      _remainingSeconds = _totalSeconds;
    });

    try {
      final qrCode =
          await ref.read(addUserNotifierProvider.notifier).generateQrCode();
      if (!mounted) return;
      setState(() {
        _qrData = qrCode;
        _isLoading = false;
      });
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          // Le notifier a déjà mis timeout via son propre polling timeout
          // On force juste l'affichage expiré
        }
      });
    });
  }

  bool get _isExpired => _remainingSeconds <= 0;

  String get _formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_isExpired) return Colors.red;
    if (_remainingSeconds <= 30) return Colors.orange;
    return const Color(0xFF6B4FA0);
  }

  double get _timerProgress =>
      (_totalSeconds - _remainingSeconds) / _totalSeconds;

  // ── Navigation après succès ───────────────────────────────────────────────

  void _goToConfirm() {
    _countdownTimer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AddConfirmScreen()),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Écouter les changements d'état du pairing
    ref.listen(addUserNotifierProvider, (_, next) {
      if (!mounted) return;
      if (next.status == PairingStatus.completed) {
        _goToConfirm();
      } else if (next.status == PairingStatus.timeout) {
        _countdownTimer?.cancel();
        setState(() => _remainingSeconds = 0);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFEDE6F5),
      appBar: AppBar(
        title: const Text('Mon QR Code'),
        backgroundColor: const Color(0xFFEDE6F5),
        elevation: 0,
        foregroundColor: const Color(0xFF2D1B4E),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildBody(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _countdownTimer?.cancel();
          ref.read(addUserNotifierProvider.notifier).cancel();
          Navigator.pop(context);
        },
        backgroundColor: const Color(0xFF6B4FA0),
        child: const Icon(Icons.close, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    // ── Chargement ──────────────────────────────────────────────────────────
    if (_isLoading) {
      return const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF6B4FA0)),
          SizedBox(height: 20),
          Text(
            'Initialisation du pairing…',
            style: TextStyle(fontSize: 16, color: Color(0xFF6B4FA0)),
          ),
        ],
      );
    }

    // ── Erreur ──────────────────────────────────────────────────────────────
    if (_error != null) {
      return Column(
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erreur : $_error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 15),
          ),
          const SizedBox(height: 24),
          _RegenerateButton(onPressed: () {
            ref.read(addUserNotifierProvider.notifier).cancel();
            _startQrGeneration();
          }),
        ],
      );
    }

    // ── QR Code expiré ──────────────────────────────────────────────────────
    if (_isExpired) {
      return Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_off, size: 60, color: Colors.red),
          ),
          const SizedBox(height: 20),
          const Text(
            'Code expiré',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D1B4E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Le QR code n\'est plus valide.\nGénérez-en un nouveau.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 28),
          _RegenerateButton(onPressed: () {
            ref.read(addUserNotifierProvider.notifier).cancel();
            _startQrGeneration();
          }),
        ],
      );
    }

    // ── QR Code actif ───────────────────────────────────────────────────────
    return Column(
      children: [
        const Text(
          'Faites scanner ce QR code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D1B4E),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Valable 2 minutes',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 28),

        // QR code entouré du timer circulaire
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 290,
              height: 290,
              child: CircularProgressIndicator(
                value: _timerProgress,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: QrImageView(
                data: _qrData!,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Affichage du code en texte
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD4C5E8)),
          ),
          child: Text(
            _qrData!.length > 16
                ? '${_qrData!.substring(0, 8)}…${_qrData!.substring(_qrData!.length - 4)}'
                : _qrData!,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Color(0xFF6B4FA0),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Countdown textuel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _remainingSeconds <= 30
                ? Colors.orange.shade50
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _remainingSeconds <= 30
                  ? Colors.orange.shade200
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                color: _timerColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Expire dans $_formattedTime',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _timerColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Indicateur de polling
        const _WaitingIndicator(),

        const SizedBox(height: 80), // espace pour le FAB
      ],
    );
  }
}

// ── Widgets auxiliaires ────────────────────────────────────────────────────

class _RegenerateButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RegenerateButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh),
      label: const Text('Générer un nouveau code'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B4FA0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}

class _WaitingIndicator extends StatelessWidget {
  const _WaitingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: const Color(0xFF6B4FA0).withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'En attente du scan…',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B4FA0),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

