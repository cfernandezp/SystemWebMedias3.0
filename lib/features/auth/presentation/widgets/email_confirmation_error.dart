import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_event.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_button.dart';

/// Página de error en confirmación de email
///
/// Muestra:
/// - Icono error (rojo)
/// - Mensaje de enlace inválido o expirado
/// - Botón para reenviar email (si hay email disponible)
/// - Link para volver a registrarse
class EmailConfirmationError extends StatelessWidget {
  final String? email;

  const EmailConfirmationError({
    Key? key,
    this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthConfirmationResent) {
          // Mostrar SnackBar success y navegar a página de espera
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Email de confirmación reenviado'),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Navegar a página de espera
          Navigator.pushReplacementNamed(
            context,
            '/auth/email-confirmation-waiting',
            arguments: email,
          );
        } else if (state is AuthError) {
          // Mostrar SnackBar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(state.message),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFF44336),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono error
                const Icon(
                  Icons.error_outline,
                  size: 120,
                  color: Color(0xFFF44336), // error color
                ),
                const SizedBox(height: 32),

                // Título
                const Text(
                  'Enlace inválido',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF26A69A), // primaryDark
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Mensaje
                const Text(
                  'El enlace de confirmación es inválido o ha expirado',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Botón reenviar (si tenemos email)
                if (email != null) ...[
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return CorporateButton(
                        text: 'Reenviar email de confirmación',
                        onPressed: isLoading ? null : () => _handleResend(context),
                        isLoading: isLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Enlace a registro
                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/auth/register',
                    (route) => false,
                  ),
                  child: const Text(
                    'Volver a registrarse',
                    style: TextStyle(
                      color: Color(0xFF4ECDC4), // primaryTurquoise
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleResend(BuildContext context) {
    if (email != null) {
      context.read<AuthBloc>().add(ResendConfirmationRequested(email: email!));
    }
  }
}
