import 'package:system_web_medias/features/dashboard/domain/entities/producto_stock_bajo.dart';

class ProductoStockBajoModel extends ProductoStockBajo {
  const ProductoStockBajoModel({
    required super.productoId,
    required super.nombre,
    required super.stockActual,
    required super.stockMaximo,
    required super.porcentajeStock,
    required super.nivelAlerta,
  });

  factory ProductoStockBajoModel.fromJson(Map<String, dynamic> json) {
    return ProductoStockBajoModel(
      productoId: json['producto_id'] as String,
      nombre: json['nombre'] as String,
      stockActual: json['stock_actual'] as int,
      stockMaximo: json['stock_maximo'] as int,
      porcentajeStock: json['porcentaje_stock'] as int,
      nivelAlerta: _parseNivelAlerta(json['nivel_alerta'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'nombre': nombre,
      'stock_actual': stockActual,
      'stock_maximo': stockMaximo,
      'porcentaje_stock': porcentajeStock,
      'nivel_alerta': _nivelAlertaToString(nivelAlerta),
    };
  }

  static NivelAlerta _parseNivelAlerta(String value) {
    switch (value.toUpperCase()) {
      case 'CRITICO':
        return NivelAlerta.critico;
      case 'BAJO':
        return NivelAlerta.bajo;
      default:
        throw ArgumentError('Nivel de alerta no válido: $value');
    }
  }

  static String _nivelAlertaToString(NivelAlerta nivel) {
    switch (nivel) {
      case NivelAlerta.critico:
        return 'CRITICO';
      case NivelAlerta.bajo:
        return 'BAJO';
    }
  }
}
