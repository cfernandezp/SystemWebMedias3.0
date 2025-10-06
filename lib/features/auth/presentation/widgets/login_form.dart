import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'remember_me_checkbox.dart';
import '../../../../shared/design_system/atoms/corporate_button.dart';
import '../../../../shared/design_system/atoms/corporate_form_field.dart';
import '../../../../core/utils/validators.dart';

/// Formulario de login con validaciones, estados y manejo de errores (HU-002)
///
/// Características:
/// - Validaciones frontend (CA-002): Email formato, campos requeridos
/// - Estados: Loading, Success, Error con BlocConsumer
/// - Navegación (CA-003): Redirect a /home on success
/// - Mensajes de error (CA-004, CA-005, CA-006, CA-007): SnackBar con texto específico
/// - Reenviar confirmación (CA-006): Action en SnackBar si hint == 'email_not_verified'
/// - Remember Me (CA-008): Checkbox que envía parámetro al backend
class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              rememberMe: _rememberMe,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Redirección a /dashboard (CA-003) - GoRouter lo maneja automáticamente
          context.go('/dashboard');

          // Mostrar SnackBar de bienvenida
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Bienvenido'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthError) {
          // Mostrar error (CA-004, CA-005, CA-006, CA-007)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              action: state.errorHint == 'email_not_verified'
                  ? SnackBarAction(
                      label: 'Reenviar',
                      textColor: Colors.white,
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              ResendConfirmationRequested(
                                email: _emailController.text.trim(),
                              ),
                            );
                      },
                    )
                  : null,
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
              // Campo Email (CA-001, CA-002)
              CorporateFormField(
                controller: _emailController,
                label: 'Email',
                hintText: 'tu@email.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                enabled: !isLoading,
                validator: Validators.email,
              ),

              const SizedBox(height: 16),

              // Campo Contraseña (CA-001, CA-002)
              CorporateFormField(
                controller: _passwordController,
                label: 'Contraseña',
                hintText: '••••••••',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                enabled: !isLoading,
                validator: Validators.required('Contraseña es requerida'),
              ),

              const SizedBox(height: 8),

              // Link "¿Olvidaste tu contraseña?" (HU-004)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.go('/forgot-password');
                        },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),

              const SizedBox(height: 8),

              // Checkbox "Recordarme" (CA-001, CA-008)
              RememberMeCheckbox(
                value: _rememberMe,
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
              ),

              const SizedBox(height: 24),

              // Botón "Iniciar Sesión" (CA-001)
              CorporateButton(
                text: 'Iniciar Sesión',
                onPressed: isLoading ? null : _handleSubmit,
                isLoading: isLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}
