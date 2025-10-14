import 'package:equatable/equatable.dart';

/// Modelo de Producto Maestro
///
/// Implementa E002-HU-006: Crear Producto Maestro
///
/// Mapping BD ↔ Dart:
/// - `marca_id` → `marcaId`
/// - `material_id` → `materialId`
/// - `tipo_id` → `tipoId`
/// - `sistema_talla_id` → `sistemaTallaId`
/// - `marca_nombre` → `marcaNombre`
/// - `marca_codigo` → `marcaCodigo`
/// - `material_nombre` → `materialNombre`
/// - `material_codigo` → `materialCodigo`
/// - `tipo_nombre` → `tipoNombre`
/// - `tipo_codigo` → `tipoCodigo`
/// - `sistema_talla_nombre` → `sistemaTallaNombre`
/// - `sistema_talla_tipo` → `sistemaTallaTipo`
/// - `nombre_completo` → `nombreCompleto`
/// - `articulos_activos` → `articulosActivos`
/// - `articulos_totales` → `articulosTotales`
/// - `tiene_catalogos_inactivos` → `tieneCatalogosInactivos`
/// - `created_at` → `createdAt`
/// - `updated_at` → `updatedAt`
class ProductoMaestroModel extends Equatable {
  final String id;
  final String marcaId;
  final String marcaNombre;
  final String marcaCodigo;
  final String materialId;
  final String materialNombre;
  final String materialCodigo;
  final String tipoId;
  final String tipoNombre;
  final String tipoCodigo;
  final String sistemaTallaId;
  final String sistemaTallaNombre;
  final String sistemaTallaTipo;
  final String? descripcion;
  final bool activo;
  final int articulosActivos;
  final int articulosTotales;
  final bool tieneCatalogosInactivos;
  final String nombreCompleto;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductoMaestroModel({
    required this.id,
    required this.marcaId,
    required this.marcaNombre,
    required this.marcaCodigo,
    required this.materialId,
    required this.materialNombre,
    required this.materialCodigo,
    required this.tipoId,
    required this.tipoNombre,
    required this.tipoCodigo,
    required this.sistemaTallaId,
    required this.sistemaTallaNombre,
    required this.sistemaTallaTipo,
    this.descripcion,
    required this.activo,
    required this.articulosActivos,
    required this.articulosTotales,
    required this.tieneCatalogosInactivos,
    required this.nombreCompleto,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductoMaestroModel.fromJson(Map<String, dynamic> json) {
    final marca = json['marca'] as Map<String, dynamic>?;
    final material = json['material'] as Map<String, dynamic>?;
    final tipo = json['tipo'] as Map<String, dynamic>?;
    final sistemaTalla = json['sistema_talla'] as Map<String, dynamic>?;

    return ProductoMaestroModel(
      id: json['id'] as String? ?? '',
      marcaId: marca?['id'] as String? ?? json['marca_id'] as String? ?? '',
      marcaNombre: marca?['nombre'] as String? ?? json['marca_nombre'] as String? ?? '',
      marcaCodigo: marca?['codigo'] as String? ?? json['marca_codigo'] as String? ?? '',
      materialId: material?['id'] as String? ?? json['material_id'] as String? ?? '',
      materialNombre: material?['nombre'] as String? ?? json['material_nombre'] as String? ?? '',
      materialCodigo: material?['codigo'] as String? ?? json['material_codigo'] as String? ?? '',
      tipoId: tipo?['id'] as String? ?? json['tipo_id'] as String? ?? '',
      tipoNombre: tipo?['nombre'] as String? ?? json['tipo_nombre'] as String? ?? '',
      tipoCodigo: tipo?['codigo'] as String? ?? json['tipo_codigo'] as String? ?? '',
      sistemaTallaId: sistemaTalla?['id'] as String? ?? json['sistema_talla_id'] as String? ?? '',
      sistemaTallaNombre: sistemaTalla?['nombre'] as String? ?? json['sistema_talla_nombre'] as String? ?? '',
      sistemaTallaTipo: sistemaTalla?['tipo_sistema'] as String? ?? json['sistema_talla_tipo'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
      articulosActivos: json['articulos_activos'] as int? ?? 0,
      articulosTotales: json['articulos_totales'] as int? ?? 0,
      tieneCatalogosInactivos: json['tiene_catalogos_inactivos'] as bool? ?? false,
      nombreCompleto: json['nombre_completo'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca_id': marcaId,
      'marca_nombre': marcaNombre,
      'marca_codigo': marcaCodigo,
      'material_id': materialId,
      'material_nombre': materialNombre,
      'material_codigo': materialCodigo,
      'tipo_id': tipoId,
      'tipo_nombre': tipoNombre,
      'tipo_codigo': tipoCodigo,
      'sistema_talla_id': sistemaTallaId,
      'sistema_talla_nombre': sistemaTallaNombre,
      'sistema_talla_tipo': sistemaTallaTipo,
      'descripcion': descripcion,
      'activo': activo,
      'articulos_activos': articulosActivos,
      'articulos_totales': articulosTotales,
      'tiene_catalogos_inactivos': tieneCatalogosInactivos,
      'nombre_completo': nombreCompleto,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProductoMaestroModel copyWith({
    String? id,
    String? marcaId,
    String? marcaNombre,
    String? marcaCodigo,
    String? materialId,
    String? materialNombre,
    String? materialCodigo,
    String? tipoId,
    String? tipoNombre,
    String? tipoCodigo,
    String? sistemaTallaId,
    String? sistemaTallaNombre,
    String? sistemaTallaTipo,
    String? descripcion,
    bool? activo,
    int? articulosActivos,
    int? articulosTotales,
    bool? tieneCatalogosInactivos,
    String? nombreCompleto,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductoMaestroModel(
      id: id ?? this.id,
      marcaId: marcaId ?? this.marcaId,
      marcaNombre: marcaNombre ?? this.marcaNombre,
      marcaCodigo: marcaCodigo ?? this.marcaCodigo,
      materialId: materialId ?? this.materialId,
      materialNombre: materialNombre ?? this.materialNombre,
      materialCodigo: materialCodigo ?? this.materialCodigo,
      tipoId: tipoId ?? this.tipoId,
      tipoNombre: tipoNombre ?? this.tipoNombre,
      tipoCodigo: tipoCodigo ?? this.tipoCodigo,
      sistemaTallaId: sistemaTallaId ?? this.sistemaTallaId,
      sistemaTallaNombre: sistemaTallaNombre ?? this.sistemaTallaNombre,
      sistemaTallaTipo: sistemaTallaTipo ?? this.sistemaTallaTipo,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      articulosActivos: articulosActivos ?? this.articulosActivos,
      articulosTotales: articulosTotales ?? this.articulosTotales,
      tieneCatalogosInactivos: tieneCatalogosInactivos ?? this.tieneCatalogosInactivos,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        marcaId,
        marcaNombre,
        marcaCodigo,
        materialId,
        materialNombre,
        materialCodigo,
        tipoId,
        tipoNombre,
        tipoCodigo,
        sistemaTallaId,
        sistemaTallaNombre,
        sistemaTallaTipo,
        descripcion,
        activo,
        articulosActivos,
        articulosTotales,
        tieneCatalogosInactivos,
        nombreCompleto,
        createdAt,
        updatedAt,
      ];
}
