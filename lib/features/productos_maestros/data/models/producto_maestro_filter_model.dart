import 'package:equatable/equatable.dart';

/// Modelo de filtros para búsqueda de productos maestros (CA-010)
///
/// Implementa E002-HU-006: Filtrado multi-criterio
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

  bool get hasActiveFilters =>
      marcaId != null ||
      materialId != null ||
      tipoId != null ||
      sistemaTallaId != null ||
      activo != null ||
      (searchText != null && searchText!.isNotEmpty);

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

  ProductoMaestroFilterModel clearFilter() {
    return const ProductoMaestroFilterModel();
  }

  @override
  List<Object?> get props => [
        marcaId,
        materialId,
        tipoId,
        sistemaTallaId,
        activo,
        searchText,
      ];
}
