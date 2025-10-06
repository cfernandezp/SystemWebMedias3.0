import 'package:system_web_medias/features/auth/domain/entities/user.dart';
import 'dashboard_metrics.dart';

/// Métricas específicas para rol GERENTE
/// Implementa RN-001, RN-007 (meta mensual)
class GerenteMetrics extends DashboardMetrics {
  final String tiendaId;             // ← tienda_id
  final double ventasTotales;        // ← ventas_totales
  final int clientesActivos;         // ← clientes_activos
  final int ordenesPendientes;       // ← ordenes_pendientes
  final int productosStockBajo;      // ← productos_stock_bajo
  final double metaMensual;          // ← meta_mensual
  final double ventasMesActual;      // ← ventas_mes_actual

  const GerenteMetrics({
    required this.tiendaId,
    required this.ventasTotales,
    required this.clientesActivos,
    required this.ordenesPendientes,
    required this.productosStockBajo,
    required this.metaMensual,
    required this.ventasMesActual,
  }) : super(rol: UserRole.gerente);

  /// Calcula progreso de meta mensual (0-100+)
  /// Implementa RN-007
  double get progresoMeta {
    if (metaMensual == 0) return 0;
    return (ventasMesActual / metaMensual) * 100;
  }

  /// Indica color del indicador de meta
  /// RN-007: < 50% y día > 20 = rojo, >= 50% < 100% = amarillo, >= 100% = verde
  MetaIndicator get metaIndicator {
    final progreso = progresoMeta;
    final diaDelMes = DateTime.now().day;

    if (progreso >= 100) return MetaIndicator.verde;
    if (progreso >= 50) return MetaIndicator.amarillo;
    if (progreso < 50 && diaDelMes > 20) return MetaIndicator.rojo;
    return MetaIndicator.amarillo;
  }

  @override
  List<Object?> get props => [
        rol,
        tiendaId,
        ventasTotales,
        clientesActivos,
        ordenesPendientes,
        productosStockBajo,
        metaMensual,
        ventasMesActual,
      ];
}

enum MetaIndicator { verde, amarillo, rojo }
