import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/core/injection/injection_container.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/register_form.dart';
import 'package:system_web_medias/shared/design_system/molecules/auth_header.dart';

/// Página principal de registro
///
/// Características:
/// - Responsive: Desktop (≥1200px) split-screen, Mobile (<768px) full-width
/// - Incluye BlocProvider para AuthBloc
/// - Background: #F9FAFB (backgroundLight)
class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB), // backgroundLight
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Desktop layout (≥1200px)
            if (constraints.maxWidth >= 1200) {
              return _buildDesktopLayout();
            }
            // Mobile/Tablet layout (<1200px)
            return _buildMobileLayout();
          },
        ),
      ),
    );
  }

  /// Layout para desktop (≥1200px)
  /// Split-screen 50/50: Branding + Formulario
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Lado izquierdo: Branding
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4ECDC4), // primaryTurquoise
                  const Color(0xFF26A69A), // primaryDark
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo grande
                    const Icon(
                      Icons.store_outlined,
                      size: 120,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sistema de Gestión de Medias',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gestiona tu inventario, ventas y reportes en un solo lugar',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Lado derecho: Formulario
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    AuthHeader(
                      title: 'Bienvenido',
                      subtitle: 'Crea tu cuenta para comenzar',
                      showLogo: false,
                    ),
                    SizedBox(height: 32),
                    RegisterForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Layout para mobile/tablet (<1200px)
  /// Full-width con scroll
  Widget _buildMobileLayout() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                SizedBox(height: 24),
                AuthHeader(
                  title: 'Bienvenido',
                  subtitle: 'Crea tu cuenta para comenzar',
                ),
                SizedBox(height: 32),
                RegisterForm(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
