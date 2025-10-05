import 'package:flutter/material.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_button.dart';

/// Página de confirmación exitosa de email
///
/// Muestra:
/// - Icono success (check verde)
/// - Mensaje de éxito
/// - Información sobre aprobación del administrador
/// - Botón para ir al inicio
class EmailConfirmationSuccess extends StatelessWidget {
  const EmailConfirmationSuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono success
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Color(0xFF4CAF50), // success color
                ),
              ),
              const SizedBox(height: 32),

              // Título
              const Text(
                'Email confirmado',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26A69A), // primaryDark
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Mensaje principal
              const Text(
                'Tu cuenta está esperando aprobación del administrador',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Mensaje secundario
              const Text(
                'Recibirás un email cuando tu cuenta sea aprobada.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280), // textSecondary
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Botón ir al login
              CorporateButton(
                text: 'Ir al inicio',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/auth/login',
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
