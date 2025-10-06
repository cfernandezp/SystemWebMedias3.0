import 'package:system_web_medias/features/dashboard/domain/entities/top_producto.dart';

class TopProductoModel extends TopProducto {
  const TopProductoModel({
    required super.productoId,
    required super.nombre,
    required super.cantidadVendida,
  });

  factory TopProductoModel.fromJson(Map<String, dynamic> json) {
    return TopProductoModel(
      productoId: json['producto_id'] as String,
      nombre: json['nombre'] as String,
      cantidadVendida: json['cantidad_vendida'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'nombre': nombre,
      'cantidad_vendida': cantidadVendida,
    };
  }
}
