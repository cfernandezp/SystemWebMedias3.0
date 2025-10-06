import 'package:system_web_medias/features/dashboard/domain/entities/top_vendedor.dart';

class TopVendedorModel extends TopVendedor {
  const TopVendedorModel({
    required super.vendedorId,
    required super.nombreCompleto,
    required super.ventasTotales,
    required super.numTransacciones,
  });

  factory TopVendedorModel.fromJson(Map<String, dynamic> json) {
    return TopVendedorModel(
      vendedorId: json['vendedor_id'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      ventasTotales: (json['ventas_totales'] as num).toDouble(),
      numTransacciones: json['num_transacciones'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendedor_id': vendedorId,
      'nombre_completo': nombreCompleto,
      'ventas_totales': ventasTotales,
      'num_transacciones': numTransacciones,
    };
  }
}
