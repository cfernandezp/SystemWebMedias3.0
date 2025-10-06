import 'package:flutter/material.dart';
import 'package:system_web_medias/shared/design_system/atoms/meta_progress_bar.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/metrics_grid.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/sales_line_chart.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/top_vendedores_list.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/transacciones_recientes_list.dart';

/// GerenteDashboard (Organism)
///
/// Dashboard completo para rol GERENTE.
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Cumple CA-002: Dashboard para Gerente
///
/// Estructura:
/// - Fila 1: Cards de métricas (ventas totales, clientes, stock, órdenes)
/// - Fila 2: Meta mensual con barra de progreso
/// - Fila 3: Gráfico de ventas + Top vendedores (responsive)
/// - Fila 4: Transacciones recientes
class GerenteDashboard extends StatelessWidget {
  final GerenteMetrics metrics;
  final bool isLoading;

  const GerenteDashboard({
    Key? key,
    required this.metrics,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fila 1: Métricas principales
          MetricsGrid(
            metricas: _buildMetricsCards(context),
            isLoading: isLoading,
          ),
          const SizedBox(height: 16),

          // Fila 2: Meta mensual
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MetaProgressBar.fromVentas(
                metaMensual: metrics.metaMensual,
                ventasActuales: metrics.ventasMesActual,
              ),
            ),
          const SizedBox(height: 16),

          // Fila 3: Gráfico + Top Vendedores
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SalesLineChart(
                      datos: metrics.ventasPorMes,
                      titulo: 'Ventas de la Tienda',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TopVendedoresList(
                      vendedores: metrics.topVendedores,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SalesLineChart(
                datos: metrics.ventasPorMes,
                titulo: 'Ventas de la Tienda',
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TopVendedoresList(
                vendedores: metrics.topVendedores,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Fila 4: Transacciones recientes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TransaccionesRecientesList(
              transacciones: metrics.transaccionesRecientes,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<MetricCardData> _buildMetricsCards(BuildContext context) {
    return [
      MetricCardData(
        icon: Icons.trending_up,
        titulo: 'Ventas Totales',
        valor: '\$${metrics.ventasMesActual.toStringAsFixed(0)}',
        subtitulo: 'mes actual',
        tendenciaPorcentaje: metrics.tendenciaVentas,
        onTap: () {
          Navigator.pushNamed(context, '/ventas');
        },
      ),
      MetricCardData(
        icon: Icons.people,
        titulo: 'Clientes Activos',
        valor: metrics.clientesActivos.toString(),
        subtitulo: 'este mes',
        tendenciaPorcentaje: metrics.tendenciaClientes,
        onTap: () {
          Navigator.pushNamed(
            context,
            '/clientes',
            arguments: {'estado': 'activo'},
          );
        },
      ),
      MetricCardData(
        icon: Icons.inventory,
        titulo: 'Productos en Stock',
        valor: metrics.productosStock.toString(),
        subtitulo: '${metrics.productosStockBajo} en stock bajo',
        iconColor: metrics.productosStockBajo > 0
            ? const Color(0xFFFF9800) // Warning
            : null,
        onTap: () {
          Navigator.pushNamed(
            context,
            '/inventario',
            arguments: {'filtro': 'todos'},
          );
        },
      ),
      MetricCardData(
        icon: Icons.assignment,
        titulo: 'Órdenes Pendientes',
        valor: metrics.ordenesPendientes.toString(),
        subtitulo: 'de la tienda',
        onTap: () {
          Navigator.pushNamed(
            context,
            '/ordenes',
            arguments: {'estado': 'pendiente'},
          );
        },
      ),
    ];
  }
}

/// GerenteMetrics
///
/// Modelo de datos para métricas del gerente
class GerenteMetrics {
  final double ventasMesActual;
  final double tendenciaVentas;
  final int clientesActivos;
  final double tendenciaClientes;
  final int productosStock;
  final int productosStockBajo;
  final int ordenesPendientes;
  final double metaMensual;
  final List<SalesChartData> ventasPorMes;
  final List<TopVendedor> topVendedores;
  final List<TransaccionReciente> transaccionesRecientes;

  const GerenteMetrics({
    required this.ventasMesActual,
    required this.tendenciaVentas,
    required this.clientesActivos,
    required this.tendenciaClientes,
    required this.productosStock,
    required this.productosStockBajo,
    required this.ordenesPendientes,
    required this.metaMensual,
    required this.ventasPorMes,
    required this.topVendedores,
    required this.transaccionesRecientes,
  });

  factory GerenteMetrics.empty() {
    return const GerenteMetrics(
      ventasMesActual: 0,
      tendenciaVentas: 0,
      clientesActivos: 0,
      tendenciaClientes: 0,
      productosStock: 0,
      productosStockBajo: 0,
      ordenesPendientes: 0,
      metaMensual: 50000,
      ventasPorMes: [],
      topVendedores: [],
      transaccionesRecientes: [],
    );
  }
}
