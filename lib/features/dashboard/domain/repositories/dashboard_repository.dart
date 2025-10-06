import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/sales_chart_data.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/top_producto.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/top_vendedor.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/transaccion_reciente.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/producto_stock_bajo.dart';

/// Repository interface para dashboard
/// Define contrato que debe cumplir la implementación
abstract class DashboardRepository {
  /// Obtiene métricas del dashboard según rol del usuario
  Future<Either<Failure, DashboardMetrics>> getMetrics(String userId);

  /// Obtiene datos históricos de ventas por mes
  Future<Either<Failure, List<SalesChartData>>> getSalesChart(
    String userId, {
    int months = 6,
  });

  /// Obtiene top N productos más vendidos
  Future<Either<Failure, List<TopProducto>>> getTopProductos(
    String userId, {
    int limit = 5,
  });

  /// Obtiene top N vendedores (solo GERENTE y ADMIN)
  Future<Either<Failure, List<TopVendedor>>> getTopVendedores(
    String userId, {
    int limit = 5,
  });

  /// Obtiene últimas N transacciones
  Future<Either<Failure, List<TransaccionReciente>>> getTransaccionesRecientes(
    String userId, {
    int limit = 5,
  });

  /// Obtiene productos con stock bajo o crítico
  Future<Either<Failure, List<ProductoStockBajo>>> getProductosStockBajo(
    String userId,
  );

  /// Refresca métricas del dashboard
  Future<Either<Failure, void>> refreshMetrics();
}
