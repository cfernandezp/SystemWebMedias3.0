import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_event.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_button.dart';

/// Página de espera de confirmación de email
///
/// Muestra:
/// - Icono decorativo (email)
/// - Mensaje con email resaltado
/// - Botón para reenviar email
/// - Link para volver al inicio
class EmailConfirmationWaiting extends StatelessWidget {
  final String email;

  const EmailConfirmationWaiting({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthConfirmationResent) {
          // Mostrar SnackBar success
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
                // Icono decorativo
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 120,
                  color: Color(0xFF4ECDC4), // primaryTurquoise
                ),
                const SizedBox(height: 32),

                // Título
                const Text(
                  'Confirma tu email',
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
                  'Te enviamos un email a:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF26A69A), // primaryDark
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Por favor revisa tu bandeja de entrada y haz clic en el enlace de confirmación.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280), // textSecondary
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Botón reenviar
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return CorporateButton(
                      text: 'Reenviar email',
                      variant: ButtonVariant.secondary,
                      onPressed: isLoading ? null : () => _handleResend(context),
                      isLoading: isLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Enlace a login
                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  ),
                  child: const Text(
                    'Volver al inicio',
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
    context.read<AuthBloc>().add(ResendConfirmationRequested(email: email));
  }
}
