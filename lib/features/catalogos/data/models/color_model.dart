import 'package:equatable/equatable.dart';

class ColorModel extends Equatable {
  final String id;
  final String nombre;
  final String codigoHex;
  final bool activo;
  final int productosCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ColorModel({
    required this.id,
    required this.nombre,
    required this.codigoHex,
    required this.activo,
    required this.productosCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) {
    return ColorModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      codigoHex: json['codigo_hex'] as String,
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
      'codigo_hex': codigoHex,
      'activo': activo,
      'productos_count': productosCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ColorModel copyWith({
    String? id,
    String? nombre,
    String? codigoHex,
    bool? activo,
    int? productosCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ColorModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigoHex: codigoHex ?? this.codigoHex,
      activo: activo ?? this.activo,
      productosCount: productosCount ?? this.productosCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        codigoHex,
        activo,
        productosCount,
        createdAt,
        updatedAt,
      ];
}
