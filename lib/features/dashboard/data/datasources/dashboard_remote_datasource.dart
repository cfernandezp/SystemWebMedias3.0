import 'package:system_web_medias/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/sales_chart_data.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/top_producto.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/top_vendedor.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/transaccion_reciente.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/producto_stock_bajo.dart';

/// Interface para datasource remoto de dashboard
abstract class DashboardRemoteDataSource {
  /// Obtiene métricas del dashboard según rol del usuario
  Future<DashboardMetrics> getMetrics(String userId);

  /// Obtiene datos históricos de ventas por mes
  Future<List<SalesChartData>> getSalesChart(String userId, {int months = 6});

  /// Obtiene top N productos más vendidos
  Future<List<TopProducto>> getTopProductos(String userId, {int limit = 5});

  /// Obtiene top N vendedores (solo GERENTE y ADMIN)
  Future<List<TopVendedor>> getTopVendedores(String userId, {int limit = 5});

  /// Obtiene últimas N transacciones
  Future<List<TransaccionReciente>> getTransaccionesRecientes(String userId,
      {int limit = 5});

  /// Obtiene productos con stock bajo o crítico
  Future<List<ProductoStockBajo>> getProductosStockBajo(String userId);

  /// Refresca métricas del dashboard
  Future<void> refreshMetrics();
}
