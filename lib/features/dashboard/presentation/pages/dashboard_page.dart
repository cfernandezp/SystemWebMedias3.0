import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_event.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';
import 'package:system_web_medias/shared/design_system/organisms/authenticated_header.dart';

/// Página principal del Dashboard
/// Muestra resumen de métricas y accesos rápidos
///
/// Características:
/// - Grid responsivo de cards
/// - Gráficos de resumen (ventas, productos, clientes)
/// - Accesos rápidos a funciones principales
/// - Theme-aware
/// - AuthenticatedHeader con datos de usuario
class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Solo renderizar si está autenticado
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authState.user;

        return Scaffold(
          appBar: AuthenticatedHeader(
            userName: user.nombreCompleto,
            userRole: _formatRole(user.rol?.value ?? 'USUARIO'),
            avatarUrl: null,
            title: null,
            onLogoutConfirmed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Resumen general del sistema',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Grid de métricas
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1200
                          ? 4
                          : constraints.maxWidth > 768
                              ? 2
                              : 1;

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        childAspectRatio: 2.5,
                        children: const [
                          _MetricCard(
                            title: 'Ventas del día',
                            value: '\$0.00',
                            icon: Icons.point_of_sale,
                            color: Color(0xFF4ECDC4),
                          ),
                          _MetricCard(
                            title: 'Productos',
                            value: '0',
                            icon: Icons.inventory_2,
                            color: Color(0xFF26A69A),
                          ),
                          _MetricCard(
                            title: 'Clientes',
                            value: '0',
                            icon: Icons.people,
                            color: Color(0xFF66BB6A),
                          ),
                          _MetricCard(
                            title: 'Stock bajo',
                            value: '0',
                            icon: Icons.warning,
                            color: Color(0xFFFFA726),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Accesos rápidos
                  const Text(
                    'Accesos rápidos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1200
                          ? 3
                          : constraints.maxWidth > 768
                              ? 2
                              : 1;

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 3,
                        children: [
                          _QuickAccessCard(
                            title: 'Nueva venta',
                            description: 'Registrar una venta en el punto de venta',
                            icon: Icons.add_shopping_cart,
                            onTap: () {
                              // TODO: Navegar a /pos
                            },
                          ),
                          _QuickAccessCard(
                            title: 'Agregar producto',
                            description: 'Añadir un nuevo producto al catálogo',
                            icon: Icons.add_box,
                            onTap: () {
                              // TODO: Navegar a /products/new
                            },
                          ),
                          _QuickAccessCard(
                            title: 'Ver reportes',
                            description: 'Consultar reportes de ventas e inventario',
                            icon: Icons.bar_chart,
                            onTap: () {
                              // TODO: Navegar a /reportes
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Helper para formatear rol en español
  String _formatRole(String role) {
    switch (role) {
      case 'ADMIN':
        return 'Administrador';
      case 'GERENTE':
        return 'Gerente';
      case 'VENDEDOR':
        return 'Vendedor';
      default:
        return role;
    }
  }
}

/// Card de métrica con ícono y valor
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Color.fromARGB(
                (0.1 * 255).round(),
                (color.a * color.r * 255.0).round() & 0xFF,
                (color.a * color.g * 255.0).round() & 0xFF,
                (color.a * color.b * 255.0).round() & 0xFF,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de acceso rápido con acción
class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}
