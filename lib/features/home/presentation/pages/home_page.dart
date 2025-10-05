import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Página principal tras login exitoso (HU-002)
///
/// Características:
/// - AppBar: Título + botón logout
/// - Saludo personalizado (CA-003): Muestra nombreCompleto del usuario
/// - Info del usuario: Email, rol, estado
/// - Logout: IconButton que dispara LogoutRequested event
/// - Placeholder: Mensaje para futuras features
///
/// Ruta: /home (protegida con AuthGuard)
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Venta de Medias'),
        actions: [
          // Botón de Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Redirigir a login tras logout
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícono de bienvenida
                        Icon(
                          Icons.check_circle_outline,
                          size: 100,
                          color: Theme.of(context).colorScheme.primary,
                        ),

                        const SizedBox(height: 24),

                        // Saludo personalizado (CA-003)
                        Text(
                          '¡Bienvenido!',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),

                        const SizedBox(height: 8),

                        // Nombre del usuario
                        Text(
                          state.user.nombreCompleto,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Info adicional en Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _InfoRow(
                                  label: 'Email:',
                                  value: state.user.email,
                                ),
                                const SizedBox(height: 12),
                                _InfoRow(
                                  label: 'Rol:',
                                  value: state.user.rol?.value ?? 'Sin asignar',
                                ),
                                const SizedBox(height: 12),
                                _InfoRow(
                                  label: 'Estado:',
                                  value: state.user.estado.value,
                                ),
                                const SizedBox(height: 12),
                                _InfoRow(
                                  label: 'Email verificado:',
                                  value: state.user.emailVerificado ? 'Sí' : 'No',
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Placeholder para futuras funcionalidades
                        Text(
                          'Funcionalidades próximamente...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Fallback si no autenticado
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

/// Widget auxiliar para mostrar info del usuario
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
