import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/auth/data/models/register_request_model.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_event.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_button.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_form_field.dart';

/// Formulario de registro que integra con AuthBloc
///
/// Características:
/// - Validación en tiempo real
/// - Integración con BlocConsumer
/// - Estados: loading, success, error
/// - SnackBars para feedback
class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreCompletoController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreCompletoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistered) {
          // Mostrar SnackBar success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Registro exitoso. Revisa tu email para confirmar tu cuenta'),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF4CAF50), // success color
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Navegar a página de espera de confirmación
          Navigator.pushNamed(
            context,
            '/email-confirmation-waiting',
            arguments: state.response.email,
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
              backgroundColor: const Color(0xFFF44336), // error color
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              const Text(
                'Crear cuenta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26A69A), // primaryDark
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completa los datos para registrarte',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280), // textSecondary
                ),
              ),
              const SizedBox(height: 24),

              // Campo Email
              CorporateFormField(
                controller: _emailController,
                label: 'Email',
                hintText: 'ejemplo@correo.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                enabled: !isLoading,
                validator: (value) {
                  final request = _buildRequest();
                  return request.validateEmail();
                },
              ),
              const SizedBox(height: 16),

              // Campo Nombre Completo
              CorporateFormField(
                controller: _nombreCompletoController,
                label: 'Nombre Completo',
                hintText: 'Juan Pérez',
                prefixIcon: Icons.person_outlined,
                enabled: !isLoading,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  final request = _buildRequest();
                  return request.validateNombreCompleto();
                },
              ),
              const SizedBox(height: 16),

              // Campo Contraseña
              CorporateFormField(
                controller: _passwordController,
                label: 'Contraseña',
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                enabled: !isLoading,
                validator: (value) {
                  final request = _buildRequest();
                  return request.validatePassword();
                },
              ),
              const SizedBox(height: 16),

              // Campo Confirmar Contraseña
              CorporateFormField(
                controller: _confirmPasswordController,
                label: 'Confirmar Contraseña',
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                enabled: !isLoading,
                validator: (value) {
                  final request = _buildRequest();
                  return request.validateConfirmPassword();
                },
              ),
              const SizedBox(height: 24),

              // Botón Registrarse
              CorporateButton(
                text: 'Registrarse',
                onPressed: isLoading ? null : _handleRegister,
                isLoading: isLoading,
              ),
              const SizedBox(height: 16),

              // Enlace a Login
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(
                      color: Color(0xFF4ECDC4), // primaryTurquoise
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  RegisterRequestModel _buildRequest() {
    return RegisterRequestModel(
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      nombreCompleto: _nombreCompletoController.text,
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final request = _buildRequest();

      // Dispatch evento al Bloc
      context.read<AuthBloc>().add(RegisterRequested(request: request));
    }
  }
}
