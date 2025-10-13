import 'package:equatable/equatable.dart';

/// HU-006: Modelo de Producto Maestro
///
/// Implementa E002-HU-006 (Crear Producto Maestro)
/// Cumple RN-037: Unicidad de combinación (marca+material+tipo+sistema_talla)
/// Cumple RN-039: Descripción opcional max 200 caracteres
///
/// Mapping BD ↔ Dart (snake_case ↔ camelCase):
/// - `id` ↔ `id`
/// - `marca_id` ↔ `marcaId`
/// - `material_id` ↔ `materialId`
/// - `tipo_id` ↔ `tipoId`
/// - `sistema_talla_id` ↔ `sistemaTallaId`
/// - `descripcion` ↔ `descripcion`
/// - `activo` ↔ `activo`
/// - `created_at` ↔ `createdAt`
/// - `updated_at` ↔ `updatedAt`
/// - `nombre_completo` ↔ `nombreCompleto`
/// - `marca_nombre` ↔ `marcaNombre`
/// - `material_nombre` ↔ `materialNombre`
/// - `tipo_nombre` ↔ `tipoNombre`
/// - `sistema_talla_nombre` ↔ `sistemaTallaNombre`
/// - `articulos_activos` ↔ `articulosActivos`
/// - `articulos_totales` ↔ `articulosTotales`
/// - `tiene_catalogos_inactivos` ↔ `tieneCatalogosInactivos`
class ProductoMaestroModel extends Equatable {
  final String id;
  final String marcaId;
  final String materialId;
  final String tipoId;
  final String sistemaTallaId;
  final String? descripcion;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? nombreCompleto;
  final String? marcaNombre;
  final String? materialNombre;
  final String? tipoNombre;
  final String? sistemaTallaNombre;
  final int? articulosActivos;
  final int? articulosTotales;
  final bool? tieneCatalogosInactivos;
  final List<String>? warnings;

  const ProductoMaestroModel({
    required this.id,
    required this.marcaId,
    required this.materialId,
    required this.tipoId,
    required this.sistemaTallaId,
    this.descripcion,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.nombreCompleto,
    this.marcaNombre,
    this.materialNombre,
    this.tipoNombre,
    this.sistemaTallaNombre,
    this.articulosActivos,
    this.articulosTotales,
    this.tieneCatalogosInactivos,
    this.warnings,
  });

  factory ProductoMaestroModel.fromJson(Map<String, dynamic> json) {
    return ProductoMaestroModel(
      id: json['id'] as String,
      marcaId: json['marca_id'] as String,
      materialId: json['material_id'] as String,
      tipoId: json['tipo_id'] as String,
      sistemaTallaId: json['sistema_talla_id'] as String,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      nombreCompleto: json['nombre_completo'] as String?,
      marcaNombre: json['marca_nombre'] as String?,
      materialNombre: json['material_nombre'] as String?,
      tipoNombre: json['tipo_nombre'] as String?,
      sistemaTallaNombre: json['sistema_talla_nombre'] as String?,
      articulosActivos: json['articulos_activos'] as int?,
      articulosTotales: json['articulos_totales'] as int?,
      tieneCatalogosInactivos: json['tiene_catalogos_inactivos'] as bool?,
      warnings: json['warnings'] != null
          ? List<String>.from(json['warnings'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca_id': marcaId,
      'material_id': materialId,
      'tipo_id': tipoId,
      'sistema_talla_id': sistemaTallaId,
      'descripcion': descripcion,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre_completo': nombreCompleto,
      'marca_nombre': marcaNombre,
      'material_nombre': materialNombre,
      'tipo_nombre': tipoNombre,
      'sistema_talla_nombre': sistemaTallaNombre,
      'articulos_activos': articulosActivos,
      'articulos_totales': articulosTotales,
      'tiene_catalogos_inactivos': tieneCatalogosInactivos,
      'warnings': warnings,
    };
  }

  ProductoMaestroModel copyWith({
    String? id,
    String? marcaId,
    String? materialId,
    String? tipoId,
    String? sistemaTallaId,
    String? descripcion,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombreCompleto,
    String? marcaNombre,
    String? materialNombre,
    String? tipoNombre,
    String? sistemaTallaNombre,
    int? articulosActivos,
    int? articulosTotales,
    bool? tieneCatalogosInactivos,
    List<String>? warnings,
  }) {
    return ProductoMaestroModel(
      id: id ?? this.id,
      marcaId: marcaId ?? this.marcaId,
      materialId: materialId ?? this.materialId,
      tipoId: tipoId ?? this.tipoId,
      sistemaTallaId: sistemaTallaId ?? this.sistemaTallaId,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      marcaNombre: marcaNombre ?? this.marcaNombre,
      materialNombre: materialNombre ?? this.materialNombre,
      tipoNombre: tipoNombre ?? this.tipoNombre,
      sistemaTallaNombre: sistemaTallaNombre ?? this.sistemaTallaNombre,
      articulosActivos: articulosActivos ?? this.articulosActivos,
      articulosTotales: articulosTotales ?? this.articulosTotales,
      tieneCatalogosInactivos:
          tieneCatalogosInactivos ?? this.tieneCatalogosInactivos,
      warnings: warnings ?? this.warnings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        marcaId,
        materialId,
        tipoId,
        sistemaTallaId,
        descripcion,
        activo,
        createdAt,
        updatedAt,
        nombreCompleto,
        marcaNombre,
        materialNombre,
        tipoNombre,
        sistemaTallaNombre,
        articulosActivos,
        articulosTotales,
        tieneCatalogosInactivos,
        warnings,
      ];
}
