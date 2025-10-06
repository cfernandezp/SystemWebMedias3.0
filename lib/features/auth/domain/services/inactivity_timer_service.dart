import 'dart:async';

/// Servicio para detectar inactividad del usuario.
///
/// Implementa HU-003 (Logout Seguro - RN-003-LOGOUT-006).
///
/// - Timeout de inactividad: 120 minutos (2 horas)
/// - Warning previo: 115 minutos (5 minutos antes del logout)
///
/// El timer se resetea cada vez que el usuario interactúa con la aplicación.
class InactivityTimerService {
  Timer? _inactivityTimer;
  Timer? _warningTimer;

  static const int _timeoutMinutes = 120; // 2 horas
  static const int _warningMinutes = 115; // Warning 5 min antes

  final void Function() onInactive;
  final void Function(int minutesRemaining) onWarning;

  InactivityTimerService({
    required this.onInactive,
    required this.onWarning,
  });

  /// Inicia el timer de inactividad.
  void startTimer() {
    resetTimer();
  }

  /// Resetea el timer de inactividad.
  ///
  /// Debe llamarse en cada interacción del usuario
  /// (click, scroll, input, etc.).
  void resetTimer() {
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();

    // Timer para warning (115 minutos)
    _warningTimer = Timer(
      const Duration(minutes: _warningMinutes),
      () => onWarning(5), // 5 minutos restantes
    );

    // Timer para logout automático (120 minutos)
    _inactivityTimer = Timer(
      const Duration(minutes: _timeoutMinutes),
      onInactive,
    );
  }

  /// Detiene el timer de inactividad.
  void stopTimer() {
    _inactivityTimer?.cancel();
    _warningTimer?.cancel();
  }

  /// Libera recursos del servicio.
  void dispose() {
    stopTimer();
  }
}
