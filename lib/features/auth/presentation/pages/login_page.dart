import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import '../../../../shared/design_system/molecules/auth_header.dart';

/// Página principal de autenticación con formulario de login (HU-002)
///
/// Características:
/// - Responsive: Max width 440px en desktop, full width en mobile
/// - Scrollable: SingleChildScrollView para teclados móviles
/// - Centered: Center + MainAxisAlignment.center
/// - Theme-aware: Usa Theme.of(context)
///
/// Ruta: /login
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header con logo y título
                  const AuthHeader(
                    title: 'Iniciar Sesión',
                    subtitle: 'Ingresa a tu cuenta',
                  ),

                  const SizedBox(height: 32),

                  // Formulario de login
                  const LoginForm(),

                  const SizedBox(height: 24),

                  // Enlace a registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Regístrate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
