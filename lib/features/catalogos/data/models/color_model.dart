import 'package:equatable/equatable.dart';

class ColorModel extends Equatable {
  final String id;
  final String nombre;
  final List<String> codigosHex;
  final String tipoColor;
  final bool activo;
  final int productosCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ColorModel({
    required this.id,
    required this.nombre,
    required this.codigosHex,
    required this.tipoColor,
    required this.activo,
    required this.productosCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) {
    return ColorModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      codigosHex: (json['codigos_hex'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      tipoColor: json['tipo_color'] as String,
      activo: json['activo'] as bool,
      productosCount: json['productos_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigos_hex': codigosHex,
      'tipo_color': tipoColor,
      'activo': activo,
      'productos_count': productosCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ColorModel copyWith({
    String? id,
    String? nombre,
    List<String>? codigosHex,
    String? tipoColor,
    bool? activo,
    int? productosCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ColorModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigosHex: codigosHex ?? this.codigosHex,
      tipoColor: tipoColor ?? this.tipoColor,
      activo: activo ?? this.activo,
      productosCount: productosCount ?? this.productosCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get codigoHexPrimario => codigosHex.isNotEmpty ? codigosHex.first : '#000000';

  bool get esCompuesto => tipoColor == 'compuesto';

  @override
  List<Object?> get props => [
        id,
        nombre,
        codigosHex,
        tipoColor,
        activo,
        productosCount,
        createdAt,
        updatedAt,
      ];
}
