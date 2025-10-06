import 'package:system_web_medias/features/auth/domain/entities/user.dart';
import 'dashboard_metrics.dart';

/// Métricas consolidadas para rol ADMIN
/// Implementa RN-001
class AdminMetrics extends DashboardMetrics {
  final double ventasTotalesGlobal;     // ← ventas_totales_global
  final int clientesActivosGlobal;      // ← clientes_activos_global
  final int ordenesPendientesGlobal;    // ← ordenes_pendientes_global
  final int tiendasActivas;             // ← tiendas_activas
  final int productosStockCritico;      // ← productos_stock_critico

  const AdminMetrics({
    required this.ventasTotalesGlobal,
    required this.clientesActivosGlobal,
    required this.ordenesPendientesGlobal,
    required this.tiendasActivas,
    required this.productosStockCritico,
  }) : super(rol: UserRole.admin);

  @override
  List<Object?> get props => [
        rol,
        ventasTotalesGlobal,
        clientesActivosGlobal,
        ordenesPendientesGlobal,
        tiendasActivas,
        productosStockCritico,
      ];
}
