import 'package:equatable/equatable.dart';

class EstadisticasColoresModel extends Equatable {
  final int totalProductos;
  final int productosUnicolor;
  final int productosMulticolor;
  final double porcentajeUnicolor;
  final double porcentajeMulticolor;
  final List<ProductoPorColorModel> productosPorColor;
  final List<CombinacionColoresModel> topCombinaciones;
  final List<ProductoPorColorModel> coloresMenosUsados;

  const EstadisticasColoresModel({
    required this.totalProductos,
    required this.productosUnicolor,
    required this.productosMulticolor,
    required this.porcentajeUnicolor,
    required this.porcentajeMulticolor,
    required this.productosPorColor,
    required this.topCombinaciones,
    required this.coloresMenosUsados,
  });

  factory EstadisticasColoresModel.fromJson(Map<String, dynamic> json) {
    return EstadisticasColoresModel(
      totalProductos: json['total_productos'] as int,
      productosUnicolor: json['productos_unicolor'] as int,
      productosMulticolor: json['productos_multicolor'] as int,
      porcentajeUnicolor: (json['porcentaje_unicolor'] as num).toDouble(),
      porcentajeMulticolor: (json['porcentaje_multicolor'] as num).toDouble(),
      productosPorColor: (json['productos_por_color'] as List)
          .map((e) => ProductoPorColorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      topCombinaciones: (json['top_combinaciones'] as List)
          .map((e) => CombinacionColoresModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      coloresMenosUsados: (json['colores_menos_usados'] as List)
          .map((e) => ProductoPorColorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        totalProductos,
        productosUnicolor,
        productosMulticolor,
        porcentajeUnicolor,
        porcentajeMulticolor,
        productosPorColor,
        topCombinaciones,
        coloresMenosUsados,
      ];
}

class ProductoPorColorModel extends Equatable {
  final String color;
  final String codigoHex;
  final int cantidadProductos;

  const ProductoPorColorModel({
    required this.color,
    required this.codigoHex,
    required this.cantidadProductos,
  });

  factory ProductoPorColorModel.fromJson(Map<String, dynamic> json) {
    return ProductoPorColorModel(
      color: json['color'] as String,
      codigoHex: json['codigo_hex'] as String,
      cantidadProductos: json['cantidad_productos'] as int,
    );
  }

  @override
  List<Object?> get props => [color, codigoHex, cantidadProductos];
}

class CombinacionColoresModel extends Equatable {
  final List<String> colores;
  final String tipoColor;
  final int cantidadProductos;

  const CombinacionColoresModel({
    required this.colores,
    required this.tipoColor,
    required this.cantidadProductos,
  });

  factory CombinacionColoresModel.fromJson(Map<String, dynamic> json) {
    final coloresArray = json['colores'] as List<dynamic>;

    return CombinacionColoresModel(
      colores: coloresArray.map((e) => e.toString()).toList(),
      tipoColor: json['tipo_color'] as String,
      cantidadProductos: json['cantidad_productos'] as int,
    );
  }

  @override
  List<Object?> get props => [colores, tipoColor, cantidadProductos];
}
