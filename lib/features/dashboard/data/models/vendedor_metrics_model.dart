import 'package:system_web_medias/features/dashboard/domain/entities/vendedor_metrics.dart';

/// Model que extiende Entity y agrega serialización JSON
class VendedorMetricsModel extends VendedorMetrics {
  const VendedorMetricsModel({
    required super.ventasHoy,
    required super.comisionesMes,
    required super.ordenesPendientes,
    required super.productosStockBajo,
  });

  /// Mapping desde JSON (Backend snake_case → Dart camelCase)
  factory VendedorMetricsModel.fromJson(Map<String, dynamic> json) {
    return VendedorMetricsModel(
      ventasHoy: (json['ventas_hoy'] as num).toDouble(),
      comisionesMes: (json['comisiones_mes'] as num).toDouble(),
      ordenesPendientes: json['ordenes_pendientes'] as int,
      productosStockBajo: json['productos_stock_bajo'] as int,
    );
  }

  /// Mapping a JSON (Dart camelCase → Backend snake_case)
  Map<String, dynamic> toJson() {
    return {
      'ventas_hoy': ventasHoy,
      'comisiones_mes': comisionesMes,
      'ordenes_pendientes': ordenesPendientes,
      'productos_stock_bajo': productosStockBajo,
    };
  }
}
