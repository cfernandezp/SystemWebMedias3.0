import 'package:equatable/equatable.dart';

class FiltrosArticulosModel extends Equatable {
  final String? productoMaestroId;
  final String? marcaId;
  final String? tipoId;
  final String? materialId;
  final bool? activo;
  final String? searchText;

  const FiltrosArticulosModel({
    this.productoMaestroId,
    this.marcaId,
    this.tipoId,
    this.materialId,
    this.activo,
    this.searchText,
  });

  Map<String, dynamic> toParams() {
    return {
      'p_producto_maestro_id': productoMaestroId,
      'p_marca_id': marcaId,
      'p_tipo_id': tipoId,
      'p_material_id': materialId,
      'p_activo': activo,
      'p_search': searchText,
    };
  }

  FiltrosArticulosModel copyWith({
    String? productoMaestroId,
    String? marcaId,
    String? tipoId,
    String? materialId,
    bool? activo,
    String? searchText,
  }) {
    return FiltrosArticulosModel(
      productoMaestroId: productoMaestroId ?? this.productoMaestroId,
      marcaId: marcaId ?? this.marcaId,
      tipoId: tipoId ?? this.tipoId,
      materialId: materialId ?? this.materialId,
      activo: activo ?? this.activo,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props =>
      [productoMaestroId, marcaId, tipoId, materialId, activo, searchText];
}