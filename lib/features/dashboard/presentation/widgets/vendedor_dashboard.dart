import 'package:flutter/material.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/metrics_grid.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/sales_line_chart.dart';
import 'package:system_web_medias/features/dashboard/presentation/widgets/top_productos_list.dart';

/// VendedorDashboard (Organism)
///
/// Dashboard completo para rol VENDEDOR.
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Cumple CA-001: Dashboard para Vendedor
///
/// Estructura:
/// - Fila 1: Cards de métricas (ventas, comisiones, stock, órdenes)
/// - Fila 2: Gráfico de ventas mensuales
/// - Fila 3: Top productos más vendidos
///
/// Layout responsive:
/// - Desktop: Grid 2x2
/// - Mobile: Columna única
class VendedorDashboard extends StatelessWidget {
  final VendedorMetrics metrics;
  final bool isLoading;

  const VendedorDashboard({
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
          // Fila 1: Métricas principales
          MetricsGrid(
            metricas: _buildMetricsCards(context),
            isLoading: isLoading,
          ),
          const SizedBox(height: 16),

          // Fila 2: Gráfico de ventas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SalesLineChart(
              datos: metrics.ventasPorMes,
              titulo: 'Mis Ventas por Mes',
            ),
          ),
          const SizedBox(height: 16),

          // Fila 3: Top productos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TopProductosList(
              productos: metrics.topProductos,
              titulo: 'Productos Más Vendidos',
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
        icon: Icons.attach_money,
        titulo: 'Ventas de Hoy',
        valor: '\$${metrics.ventasHoy.toStringAsFixed(0)}',
        subtitulo: 'vs ayer',
        tendenciaPorcentaje: metrics.tendenciaVentasHoy,
        onTap: () {
          Navigator.pushNamed(
            context,
            '/ventas',
            arguments: {'fecha': DateTime.now()},
          );
        },
      ),
      MetricCardData(
        icon: Icons.account_balance_wallet,
        titulo: 'Mis Comisiones',
        valor: '\$${metrics.comisionesMes.toStringAsFixed(0)}',
        subtitulo: 'mes actual',
        tendenciaPorcentaje: metrics.tendenciaComisiones,
      ),
      MetricCardData(
        icon: Icons.inventory_2,
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
            arguments: {'filtro': 'stock_bajo'},
          );
        },
      ),
      MetricCardData(
        icon: Icons.pending_actions,
        titulo: 'Órdenes Pendientes',
        valor: metrics.ordenesPendientes.toString(),
        subtitulo: 'requieren atención',
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

/// VendedorMetrics
///
/// Modelo de datos para métricas del vendedor
class VendedorMetrics {
  final double ventasHoy;
  final double tendenciaVentasHoy;
  final double comisionesMes;
  final double tendenciaComisiones;
  final int productosStock;
  final int productosStockBajo;
  final int ordenesPendientes;
  final List<SalesChartData> ventasPorMes;
  final List<TopProducto> topProductos;

  const VendedorMetrics({
    required this.ventasHoy,
    required this.tendenciaVentasHoy,
    required this.comisionesMes,
    required this.tendenciaComisiones,
    required this.productosStock,
    required this.productosStockBajo,
    required this.ordenesPendientes,
    required this.ventasPorMes,
    required this.topProductos,
  });

  // Factory constructor para datos vacíos (loading/error)
  factory VendedorMetrics.empty() {
    return const VendedorMetrics(
      ventasHoy: 0,
      tendenciaVentasHoy: 0,
      comisionesMes: 0,
      tendenciaComisiones: 0,
      productosStock: 0,
      productosStockBajo: 0,
      ordenesPendientes: 0,
      ventasPorMes: [],
      topProductos: [],
    );
  }
}
