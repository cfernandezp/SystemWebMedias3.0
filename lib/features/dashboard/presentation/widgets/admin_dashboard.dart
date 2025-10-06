import 'package:flutter/material.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/metrics_grid.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/sales_line_chart.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/top_productos_list.dart';

/// AdminDashboard (Organism)
///
/// Dashboard completo para rol ADMIN.
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Cumple CA-003: Dashboard para Admin
///
/// Estructura:
/// - Fila 1: Cards de métricas globales (6 métricas en grid 3x2)
/// - Fila 2: Gráfico de ventas consolidadas
/// - Fila 3: Top productos a nivel global
/// - Fila 4: Acciones rápidas (grid de botones)
class AdminDashboard extends StatelessWidget {
  final AdminMetrics metrics;
  final bool isLoading;

  const AdminDashboard({
    Key? key,
    required this.metrics,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fila 1: Métricas globales
          MetricsGrid(
            metricas: _buildMetricsCards(context),
            isLoading: isLoading,
          ),
          const SizedBox(height: 16),

          // Fila 2: Gráfico de ventas consolidadas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SalesLineChart(
              datos: metrics.ventasPorMes,
              titulo: 'Ventas Globales por Mes',
            ),
          ),
          const SizedBox(height: 16),

          // Fila 3: Top productos global
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TopProductosList(
              productos: metrics.topProductos,
              titulo: 'Productos Más Vendidos (Global)',
            ),
          ),
          const SizedBox(height: 16),

          // Fila 4: Acciones rápidas
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildAccionesRapidas(context),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<MetricCardData> _buildMetricsCards(BuildContext context) {
    return [
      MetricCardData(
        icon: Icons.bar_chart,
        titulo: 'Ventas Totales Global',
        valor: '\$${_formatMonto(metrics.ventasTotales)}',
        subtitulo: 'todas las tiendas',
        tendenciaPorcentaje: metrics.tendenciaVentas,
        onTap: () {
          Navigator.pushNamed(context, '/reportes/ventas-global');
        },
      ),
      MetricCardData(
        icon: Icons.groups,
        titulo: 'Clientes Activos',
        valor: metrics.clientesActivos.toString(),
        subtitulo: 'mes actual',
        tendenciaPorcentaje: metrics.tendenciaClientes,
        onTap: () {
          Navigator.pushNamed(context, '/clientes');
        },
      ),
      MetricCardData(
        icon: Icons.list_alt,
        titulo: 'Órdenes Pendientes',
        valor: metrics.ordenesPendientes.toString(),
        subtitulo: 'todas las tiendas',
        onTap: () {
          Navigator.pushNamed(
            context,
            '/ordenes',
            arguments: {'estado': 'pendiente'},
          );
        },
      ),
      MetricCardData(
        icon: Icons.store,
        titulo: 'Tiendas Activas',
        valor: metrics.tiendasActivas.toString(),
        subtitulo: 'operando',
        onTap: () {
          Navigator.pushNamed(context, '/tiendas');
        },
      ),
      MetricCardData(
        icon: Icons.warning_amber,
        titulo: 'Stock Crítico',
        valor: metrics.productosStockCritico.toString(),
        subtitulo: 'productos',
        iconColor: metrics.productosStockCritico > 0
            ? const Color(0xFFF44336) // Error
            : const Color(0xFF4CAF50), // Success
        onTap: () {
          Navigator.pushNamed(
            context,
            '/inventario',
            arguments: {'filtro': 'stock_critico'},
          );
        },
      ),
      MetricCardData(
        icon: Icons.person_outline,
        titulo: 'Usuarios Activos',
        valor: metrics.usuariosActivos.toString(),
        subtitulo: 'vendedores y gerentes',
        onTap: () {
          Navigator.pushNamed(context, '/usuarios');
        },
      ),
    ];
  }

  Widget _buildAccionesRapidas(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Rápidas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1200 ? 4 : 2;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2,
                children: [
                  _buildAccionButton(
                    context,
                    icon: Icons.point_of_sale,
                    label: 'Nueva Venta',
                    onTap: () => Navigator.pushNamed(context, '/ventas/nueva'),
                  ),
                  _buildAccionButton(
                    context,
                    icon: Icons.inventory,
                    label: 'Productos',
                    onTap: () => Navigator.pushNamed(context, '/productos'),
                  ),
                  _buildAccionButton(
                    context,
                    icon: Icons.warehouse,
                    label: 'Inventario',
                    onTap: () => Navigator.pushNamed(context, '/inventario'),
                  ),
                  _buildAccionButton(
                    context,
                    icon: Icons.assessment,
                    label: 'Reportes',
                    onTap: () => Navigator.pushNamed(context, '/reportes'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMonto(double monto) {
    if (monto >= 1000000) {
      return '${(monto / 1000000).toStringAsFixed(1)}M';
    } else if (monto >= 1000) {
      return '${(monto / 1000).toStringAsFixed(0)}K';
    } else {
      return monto.toStringAsFixed(0);
    }
  }
}

/// AdminMetrics
///
/// Modelo de datos para métricas del admin
class AdminMetrics {
  final double ventasTotales;
  final double tendenciaVentas;
  final int clientesActivos;
  final double tendenciaClientes;
  final int ordenesPendientes;
  final int tiendasActivas;
  final int productosStockCritico;
  final int usuariosActivos;
  final List<SalesChartData> ventasPorMes;
  final List<TopProducto> topProductos;

  const AdminMetrics({
    required this.ventasTotales,
    required this.tendenciaVentas,
    required this.clientesActivos,
    required this.tendenciaClientes,
    required this.ordenesPendientes,
    required this.tiendasActivas,
    required this.productosStockCritico,
    required this.usuariosActivos,
    required this.ventasPorMes,
    required this.topProductos,
  });

  factory AdminMetrics.empty() {
    return const AdminMetrics(
      ventasTotales: 0,
      tendenciaVentas: 0,
      clientesActivos: 0,
      tendenciaClientes: 0,
      ordenesPendientes: 0,
      tiendasActivas: 0,
      productosStockCritico: 0,
      usuariosActivos: 0,
      ventasPorMes: [],
      topProductos: [],
    );
  }
}
