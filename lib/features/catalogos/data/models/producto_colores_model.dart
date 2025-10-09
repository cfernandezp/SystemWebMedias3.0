import 'package:equatable/equatable.dart';

class ProductoColoresModel extends Equatable {
  final String productoId;
  final List<String> colores;
  final int cantidadColores;
  final String tipoColor;
  final String? descripcionVisual;

  const ProductoColoresModel({
    required this.productoId,
    required this.colores,
    required this.cantidadColores,
    required this.tipoColor,
    this.descripcionVisual,
  });

  factory ProductoColoresModel.fromJson(Map<String, dynamic> json) {
    final coloresArray = json['colores'] as List<dynamic>;

    return ProductoColoresModel(
      productoId: json['producto_id'] as String,
      colores: coloresArray.map((e) => e.toString()).toList(),
      cantidadColores: json['cantidad_colores'] as int,
      tipoColor: json['tipo_color'] as String,
      descripcionVisual: json['descripcion_visual'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'colores': colores,
      'cantidad_colores': cantidadColores,
      'tipo_color': tipoColor,
      'descripcion_visual': descripcionVisual,
    };
  }

  String clasificarTipoColor() {
    switch (cantidadColores) {
      case 1:
        return 'Unicolor';
      case 2:
        return 'Bicolor';
      case 3:
        return 'Tricolor';
      default:
        return 'Multicolor';
    }
  }

  ProductoColoresModel copyWith({
    String? productoId,
    List<String>? colores,
    int? cantidadColores,
    String? tipoColor,
    String? descripcionVisual,
  }) {
    return ProductoColoresModel(
      productoId: productoId ?? this.productoId,
      colores: colores ?? this.colores,
      cantidadColores: cantidadColores ?? this.cantidadColores,
      tipoColor: tipoColor ?? this.tipoColor,
      descripcionVisual: descripcionVisual ?? this.descripcionVisual,
    );
  }

  @override
  List<Object?> get props => [
        productoId,
        colores,
        cantidadColores,
        tipoColor,
        descripcionVisual,
      ];
}
