import 'package:flutter/material.dart';

/// Modal de confirmación para cerrar sesión
///
/// Especificaciones:
/// - Border radius: 12px
/// - Botón cancelar: TextButton gris
/// - Botón confirmar: ElevatedButton rojo (#F44336)
/// - Ícono: Icons.logout rojo
///
/// Características:
/// - Diseño consistente con Design System
/// - Theme-aware
/// - Accesible con navegación por teclado
class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutConfirmationDialog({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Icon(
            Icons.logout,
            color: theme.colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text('Cerrar sesión'),
        ],
      ),
      content: Text(
        '¿Estás seguro que deseas cerrar sesión?',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
