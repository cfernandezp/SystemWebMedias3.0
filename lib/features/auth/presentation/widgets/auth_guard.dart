import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

/// Wrapper para páginas protegidas que requieren autenticación (HU-002, CA-010)
///
/// Características:
/// - Redirige a /login si AuthUnauthenticated
/// - Muestra CircularProgressIndicator si AuthLoading
/// - Renderiza child si AuthAuthenticated
/// - Muestra mensaje de sesión expirada si aplica
///
/// Uso:
/// ```dart
/// '/home': (context) => const AuthGuard(child: HomePage()),
/// '/products': (context) => const AuthGuard(child: ProductsPage()),
/// ```
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthUnauthenticated) {
          // Redirigir a login (CA-010)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');

            // Mostrar mensaje de sesión expirada si aplica
            if (state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return child;
        }

        // Fallback: estado inicial - mostrar loading
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
