import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/password_strength_indicator.dart';
import '../../../../shared/design_system/atoms/corporate_button.dart';
import '../../../../shared/design_system/atoms/corporate_form_field.dart';

/// Página para restablecer contraseña con token (HU-004)
///
/// Funcionalidad:
/// - Validación de token al cargar
/// - Formulario nueva contraseña con confirmación
/// - Indicador de fortaleza en tiempo real
/// - Validaciones: longitud, formato, coincidencia
/// - Manejo de errores: token inválido/expirado/usado
class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _tokenValidated = false;

  @override
  void initState() {
    super.initState();
    // Validar token al cargar la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(
            ValidateResetTokenRequested(token: widget.token),
          );
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            ResetPasswordRequested(
              token: widget.token,
              newPassword: _passwordController.text,
            ),
          );
    }
  }

  /// Validador de contraseña según especificaciones HU-004
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña es requerida';
    }

    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }

    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasNumber = value.contains(RegExp(r'[0-9]'));

    if (!hasUppercase || !hasLowercase || !hasNumber) {
      return 'Debe contener mayúscula, minúscula y número';
    }

    return null;
  }

  /// Validador de confirmación de contraseña
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Debes confirmar la contraseña';
    }

    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Restablecer Contraseña'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ResetTokenValid) {
            // Token válido, mostrar formulario
            setState(() => _tokenValidated = true);
          } else if (state is ResetTokenInvalid) {
            // Token inválido, mostrar error y redirigir
            _showTokenErrorDialog(context, state.message, state.hint ?? 'unknown');
          } else if (state is ResetPasswordSuccess) {
            // Password cambiado exitosamente
            _showSuccessDialog(context);
          } else if (state is AuthError) {
            // Mostrar error
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
          // Estados de carga
          if (state is ResetTokenValidationInProgress) {
            return _buildLoadingView('Validando enlace...');
          }

          if (state is ResetPasswordInProgress) {
            return _buildLoadingView('Cambiando contraseña...');
          }

          // Si token no validado aún, mostrar loading
          if (!_tokenValidated) {
            return _buildLoadingView('Validando enlace...');
          }

          // Mostrar formulario
          return _buildFormView(context);
        },
      ),
    );
  }

  /// Vista de carga
  Widget _buildLoadingView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  /// Vista del formulario
  Widget _buildFormView(BuildContext context) {
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono de cabecera
                    Icon(
                      Icons.lock_open,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(height: 24),

                    // Título
                    const Text(
                      'Crea tu nueva contraseña',
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
                      'Tu nueva contraseña debe ser diferente a las anteriores.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Campo Nueva Contraseña
                    CorporateFormField(
                      controller: _passwordController,
                      label: 'Nueva Contraseña',
                      hintText: '••••••••',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      validator: _validatePassword,
                      onChanged: (_) => setState(() {}), // Para actualizar indicador
                    ),

                    const SizedBox(height: 16),

                    // Indicador de fortaleza
                    PasswordStrengthIndicator(
                      password: _passwordController.text,
                    ),

                    const SizedBox(height: 24),

                    // Campo Confirmar Contraseña
                    CorporateFormField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar Contraseña',
                      hintText: '••••••••',
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      validator: _validateConfirmPassword,
                    ),

                    const SizedBox(height: 32),

                    // Botón cambiar contraseña
                    CorporateButton(
                      text: 'Cambiar contraseña',
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Mostrar dialog de error de token
  void _showTokenErrorDialog(BuildContext context, String message, String hint) {
    final IconData icon;
    final String title;

    switch (hint) {
      case 'expired_token':
        icon = Icons.schedule;
        title = 'Enlace Expirado';
        break;
      case 'used_token':
        icon = Icons.check_circle_outline;
        title = 'Enlace Ya Utilizado';
        break;
      case 'invalid_token':
      default:
        icon = Icons.error_outline;
        title = 'Enlace Inválido';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(icon, size: 48, color: Theme.of(context).colorScheme.error),
        title: Text(title),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Cerrar dialog
              context.go('/login'); // Redirigir a login
            },
            child: const Text('Ir al Login'),
          ),
          CorporateButton(
            text: 'Solicitar Nuevo Enlace',
            onPressed: () {
              context.pop(); // Cerrar dialog
              context.go('/forgot-password'); // Ir a recuperar contraseña
            },
          ),
        ],
      ),
    );
  }

  /// Mostrar dialog de éxito
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('¡Contraseña Cambiada!'),
        content: const Text(
          'Tu contraseña ha sido cambiada exitosamente. Ahora puedes iniciar sesión con tu nueva contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          CorporateButton(
            text: 'Ir al Login',
            onPressed: () {
              context.pop(); // Cerrar dialog
              context.go('/login'); // Redirigir a login
            },
          ),
        ],
      ),
    );
  }
}
