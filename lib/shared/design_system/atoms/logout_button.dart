import 'package:flutter/material.dart';

/// Botón de logout con icono
///
/// Especificaciones:
/// - Color: Error del tema (rojo)
/// - Icono: Icons.logout
/// - Texto: "Cerrar Sesión"
/// - Estado loading con CircularProgressIndicator
///
/// Características:
/// - Theme-aware (usa colorScheme.error)
/// - Estado loading integrado
/// - Padding consistente con Design System
class LogoutButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const LogoutButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout, size: 20),
      label: const Text('Cerrar Sesión'),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.hovered)) {
            return theme.colorScheme.error.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.pressed)) {
            return theme.colorScheme.error.withValues(alpha: 0.2);
          }
          return null;
        }),
      ),
    );
  }
}
