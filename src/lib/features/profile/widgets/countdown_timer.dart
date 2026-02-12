import 'package:flutter/material.dart';

/// Widget de compte à rebours
class CountdownTimer extends StatelessWidget {
  final int remainingSeconds;
  final bool isExpired;
  final VoidCallback? onExpired;

  const CountdownTimer({
    super.key,
    required this.remainingSeconds,
    this.isExpired = false,
    this.onExpired,
  });

  String get _formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _color {
    if (isExpired) return Colors.red;
    if (remainingSeconds <= 30) return Colors.orange;
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? Colors.red.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.timer_off : Icons.access_time,
            color: _color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isExpired ? 'Expiré' : _formattedTime,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de barre de progression
class CircularCountdownTimer extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final Widget child;

  const CircularCountdownTimer({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.child,
  });

  double get _progress {
    if (totalSeconds == 0) return 0.0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }

  Color get _color {
    if (remainingSeconds <= 30) return Colors.red;
    if (remainingSeconds <= 60) return Colors.orange;
    return Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: CircularProgressIndicator(
            value: _progress,
            strokeWidth: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
        child,
      ],
    );
  }
}

