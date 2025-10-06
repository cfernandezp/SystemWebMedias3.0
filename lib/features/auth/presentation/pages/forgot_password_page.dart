import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/design_system/atoms/corporate_button.dart';
import '../../../../shared/design_system/atoms/corporate_form_field.dart';
import '../../../../core/utils/validators.dart';

/// Página de recuperación de contraseña (HU-004)
///
/// Funcionalidad:
/// - Formulario para solicitar enlace de recuperación
/// - Validación de email formato
/// - Manejo de estados: loading, success, error
/// - Navegación: volver al login
/// - Privacidad: no revelar si email existe
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            PasswordResetRequested(
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetRequestSuccess) {
            // Mostrar mensaje de éxito
            setState(() => _emailSent = true);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is PasswordResetRequestFailure) {
            // Mostrar error (rate limit, etc.)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PasswordResetRequestInProgress;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _emailSent
                        ? _buildSuccessView(context)
                        : _buildFormView(context, isLoading),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Vista del formulario
  Widget _buildFormView(BuildContext context, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono de cabecera
          Icon(
            Icons.lock_reset,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 24),

          // Título
          const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Descripción
          const Text(
            'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Campo Email
          CorporateFormField(
            controller: _emailController,
            label: 'Email',
            hintText: 'tu@email.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            enabled: !isLoading,
            validator: Validators.email,
          ),

          const SizedBox(height: 24),

          // Botón enviar
          CorporateButton(
            text: 'Enviar enlace de recuperación',
            onPressed: isLoading ? null : _handleSubmit,
            isLoading: isLoading,
          ),

          const SizedBox(height: 16),

          // Link volver al login
          TextButton(
            onPressed: isLoading ? null : () => context.go('/login'),
            child: const Text(
              'Volver al login',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vista de confirmación después de enviar
  Widget _buildSuccessView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono de éxito
        Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),

        const SizedBox(height: 24),

        // Título
        const Text(
          'Revisa tu correo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // Mensaje
        const Text(
          'Si el email existe en nuestro sistema, te enviamos un enlace de recuperación.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        const Text(
          'El enlace expirará en 24 horas.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Botón volver al login
        CorporateButton(
          text: 'Volver al login',
          onPressed: () => context.go('/login'),
          variant: ButtonVariant.secondary,
        ),

        const SizedBox(height: 16),

        // Link para reenviar
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: const Text(
            '¿No recibiste el correo? Reenviar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
