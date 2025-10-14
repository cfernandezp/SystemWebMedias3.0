import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';

class ArticuloModel extends Equatable {
  final String id;
  final String productoMaestroId;
  final String sku;
  final String tipoColoracion;
  final List<String> coloresIds;
  final double precio;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductoMaestroModel? productoMaestro;
  final List<ColorModel>? colores;

  const ArticuloModel({
    required this.id,
    required this.productoMaestroId,
    required this.sku,
    required this.tipoColoracion,
    required this.coloresIds,
    required this.precio,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.productoMaestro,
    this.colores,
  });

  factory ArticuloModel.fromJson(Map<String, dynamic> json) {
    return ArticuloModel(
      id: json['id'] as String? ?? '',
      productoMaestroId: json['producto_maestro_id'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      tipoColoracion: json['tipo_coloracion'] as String? ?? 'unicolor',
      coloresIds: (json['colores_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      precio: ((json['precio'] as num?) ?? 0).toDouble(),
      activo: json['activo'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      productoMaestro: json['producto_maestro'] != null
          ? ProductoMaestroModel.fromJson(
              json['producto_maestro'] as Map<String, dynamic>)
          : null,
      colores: json['colores'] != null
          ? (json['colores'] as List<dynamic>)
              .map((e) => ColorModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_maestro_id': productoMaestroId,
      'sku': sku,
      'tipo_coloracion': tipoColoracion,
      'colores_ids': coloresIds,
      'precio': precio,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (productoMaestro != null)
        'producto_maestro': productoMaestro!.toJson(),
      if (colores != null)
        'colores': colores!.map((e) => e.toJson()).toList(),
    };
  }

  ArticuloModel copyWith({
    String? id,
    String? productoMaestroId,
    String? sku,
    String? tipoColoracion,
    List<String>? coloresIds,
    double? precio,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductoMaestroModel? productoMaestro,
    List<ColorModel>? colores,
  }) {
    return ArticuloModel(
      id: id ?? this.id,
      productoMaestroId: productoMaestroId ?? this.productoMaestroId,
      sku: sku ?? this.sku,
      tipoColoracion: tipoColoracion ?? this.tipoColoracion,
      coloresIds: coloresIds ?? this.coloresIds,
      precio: precio ?? this.precio,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productoMaestro: productoMaestro ?? this.productoMaestro,
      colores: colores ?? this.colores,
    );
  }

  bool get esUnicolor => tipoColoracion == 'unicolor';
  bool get esBicolor => tipoColoracion == 'bicolor';
  bool get esTricolor => tipoColoracion == 'tricolor';

  String get nombreCompleto {
    if (productoMaestro != null && colores != null) {
      final coloresStr = colores!.map((c) => c.nombre).join('-');
      return '${productoMaestro!.nombreCompleto} - $coloresStr';
    }
    return sku;
  }

  @override
  List<Object?> get props => [
        id,
        productoMaestroId,
        sku,
        tipoColoracion,
        coloresIds,
        precio,
        activo,
        createdAt,
        updatedAt,
        productoMaestro,
        colores,
      ];
}