import 'package:system_web_medias/features/dashboard/domain/entities/admin_metrics.dart';

class AdminMetricsModel extends AdminMetrics {
  const AdminMetricsModel({
    required super.ventasTotalesGlobal,
    required super.clientesActivosGlobal,
    required super.ordenesPendientesGlobal,
    required super.tiendasActivas,
    required super.productosStockCritico,
  });

  factory AdminMetricsModel.fromJson(Map<String, dynamic> json) {
    return AdminMetricsModel(
      ventasTotalesGlobal: (json['ventas_totales_global'] as num).toDouble(),
      clientesActivosGlobal: json['clientes_activos_global'] as int,
      ordenesPendientesGlobal: json['ordenes_pendientes_global'] as int,
      tiendasActivas: json['tiendas_activas'] as int,
      productosStockCritico: json['productos_stock_critico'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ventas_totales_global': ventasTotalesGlobal,
      'clientes_activos_global': clientesActivosGlobal,
      'ordenes_pendientes_global': ordenesPendientesGlobal,
      'tiendas_activas': tiendasActivas,
      'productos_stock_critico': productosStockCritico,
    };
  }
}
