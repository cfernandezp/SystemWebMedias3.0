import 'package:flutter/material.dart';
import 'dart:async';

/// Modal de advertencia antes de logout automático por inactividad
///
/// Especificaciones:
/// - Ícono: Icons.timer_outlined en warning color
/// - Countdown timer de minutos restantes
/// - LinearProgressIndicator visual
/// - Botones: "Cerrar Sesión" y "Extender Sesión"
/// - No dismissible (barrierDismissible: false)
///
/// Características:
/// - Theme-aware
/// - Timer automático que cuenta hacia atrás
/// - Se cierra automáticamente cuando llega a 0
/// - Cleanup de timer en dispose
class InactivityWarningDialog extends StatefulWidget {
  final int minutesRemaining;
  final VoidCallback onExtendSession;
  final VoidCallback onLogout;

  const InactivityWarningDialog({
    Key? key,
    required this.minutesRemaining,
    required this.onExtendSession,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<InactivityWarningDialog> createState() =>
      _InactivityWarningDialogState();

  /// Método estático para mostrar el dialog
  static Future<void> show({
    required BuildContext context,
    required int minutesRemaining,
    required VoidCallback onExtendSession,
    required VoidCallback onLogout,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InactivityWarningDialog(
        minutesRemaining: minutesRemaining,
        onExtendSession: onExtendSession,
        onLogout: onLogout,
      ),
    );
  }
}

class _InactivityWarningDialogState extends State<InactivityWarningDialog> {
  late int _remainingMinutes;
  late Timer _countdownTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _remainingMinutes = widget.minutesRemaining;

    // Countdown timer que se ejecuta cada minuto
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingMinutes--;
      });

      if (_remainingMinutes <= 0) {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
          widget.onLogout();
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Usamos warning si está disponible, sino naranja por defecto
    final warningColor = const Color(0xFFFF9800);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      icon: Icon(
        Icons.timer_outlined,
        size: 48,
        color: warningColor,
      ),
      title: const Text('Sesión por Expirar'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tu sesión expirará en $_remainingMinutes minuto${_remainingMinutes != 1 ? 's' : ''} por inactividad.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _remainingMinutes / widget.minutesRemaining,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: warningColor,
          ),
          const SizedBox(height: 8),
          Text(
            '¿Deseas extender tu sesión?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _countdownTimer.cancel();
            Navigator.of(context).pop();
            widget.onLogout();
          },
          child: const Text('Cerrar Sesión'),
        ),
        FilledButton(
          onPressed: () {
            _countdownTimer.cancel();
            Navigator.of(context).pop();
            widget.onExtendSession();
          },
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
          ),
          child: const Text('Extender Sesión'),
        ),
      ],
    );
  }
}
