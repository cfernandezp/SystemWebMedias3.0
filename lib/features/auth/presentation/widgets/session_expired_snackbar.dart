import 'package:flutter/material.dart';

/// Snackbar para mostrar mensajes de sesión cerrada
///
/// Especificaciones:
/// - Íconos específicos según tipo de logout:
///   - manual: Icons.check_circle (turquesa)
///   - inactivity: Icons.timer_off (naranja warning)
///   - token_expired: Icons.lock_clock (rojo error)
/// - Floating behavior
/// - Duración: 4 segundos
/// - Acción "Entendido" para tipos no manuales
///
/// Características:
/// - Theme-aware
/// - Colores según tipo de logout
/// - Texto en blanco para contraste
class SessionExpiredSnackbar {
  /// Muestra un snackbar con mensaje de sesión cerrada
  ///
  /// [message] Texto a mostrar
  /// [logoutType] Tipo de logout: 'manual', 'inactivity', 'token_expired'
  static void show({
    required BuildContext context,
    required String message,
    String logoutType = 'manual',
  }) {
    final theme = Theme.of(context);

    IconData icon;
    Color backgroundColor;

    switch (logoutType) {
      case 'inactivity':
        icon = Icons.timer_off;
        backgroundColor = const Color(0xFFFF9800); // warning
        break;
      case 'token_expired':
        icon = Icons.lock_clock;
        backgroundColor = theme.colorScheme.error;
        break;
      case 'multi_tab':
        icon = Icons.tab;
        backgroundColor = theme.colorScheme.error;
        break;
      default: // 'manual'
        icon = Icons.check_circle;
        backgroundColor = theme.colorScheme.primary;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
        action: logoutType != 'manual'
            ? SnackBarAction(
                label: 'Entendido',
                textColor: Colors.white,
                onPressed: () {},
              )
            : null,
      ),
    );
  }
}
