import 'package:equatable/equatable.dart';

/// HU-006: Modelo de filtros para listado de productos maestros
///
/// Implementa CA-010 (Búsqueda y Filtrado)
/// Permite filtrar por marca, material, tipo, sistema_talla, estado y texto libre
class ProductoMaestroFilterModel extends Equatable {
  final String? marcaId;
  final String? materialId;
  final String? tipoId;
  final String? sistemaTallaId;
  final bool? activo;
  final String? searchText;

  const ProductoMaestroFilterModel({
    this.marcaId,
    this.materialId,
    this.tipoId,
    this.sistemaTallaId,
    this.activo,
    this.searchText,
  });

  Map<String, dynamic> toJson() {
    final params = <String, dynamic>{};

    if (marcaId != null) params['p_marca_id'] = marcaId;
    if (materialId != null) params['p_material_id'] = materialId;
    if (tipoId != null) params['p_tipo_id'] = tipoId;
    if (sistemaTallaId != null) params['p_sistema_talla_id'] = sistemaTallaId;
    if (activo != null) params['p_activo'] = activo;
    if (searchText != null && searchText!.isNotEmpty) {
      params['p_search_text'] = searchText;
    }

    return params;
  }

  ProductoMaestroFilterModel copyWith({
    String? marcaId,
    String? materialId,
    String? tipoId,
    String? sistemaTallaId,
    bool? activo,
    String? searchText,
  }) {
    return ProductoMaestroFilterModel(
      marcaId: marcaId ?? this.marcaId,
      materialId: materialId ?? this.materialId,
      tipoId: tipoId ?? this.tipoId,
      sistemaTallaId: sistemaTallaId ?? this.sistemaTallaId,
      activo: activo ?? this.activo,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props =>
      [marcaId, materialId, tipoId, sistemaTallaId, activo, searchText];
}
