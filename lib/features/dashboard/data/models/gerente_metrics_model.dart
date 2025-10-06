import 'package:system_web_medias/features/dashboard/domain/entities/gerente_metrics.dart';

class GerenteMetricsModel extends GerenteMetrics {
  const GerenteMetricsModel({
    required super.tiendaId,
    required super.ventasTotales,
    required super.clientesActivos,
    required super.ordenesPendientes,
    required super.productosStockBajo,
    required super.metaMensual,
    required super.ventasMesActual,
  });

  factory GerenteMetricsModel.fromJson(Map<String, dynamic> json) {
    return GerenteMetricsModel(
      tiendaId: json['tienda_id'] as String,
      ventasTotales: (json['ventas_totales'] as num).toDouble(),
      clientesActivos: json['clientes_activos'] as int,
      ordenesPendientes: json['ordenes_pendientes'] as int,
      productosStockBajo: json['productos_stock_bajo'] as int,
      metaMensual: (json['meta_mensual'] as num).toDouble(),
      ventasMesActual: (json['ventas_mes_actual'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tienda_id': tiendaId,
      'ventas_totales': ventasTotales,
      'clientes_activos': clientesActivos,
      'ordenes_pendientes': ordenesPendientes,
      'productos_stock_bajo': productosStockBajo,
      'meta_mensual': metaMensual,
      'ventas_mes_actual': ventasMesActual,
    };
  }
}
