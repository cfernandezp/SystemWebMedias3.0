import 'package:equatable/equatable.dart';

class ProductoCompletoRequestModel extends Equatable {
  final ProductoMaestroData productoMaestro;
  final List<ArticuloData> articulos;

  const ProductoCompletoRequestModel({
    required this.productoMaestro,
    required this.articulos,
  });

  Map<String, dynamic> toJson() {
    return {
      'p_producto_maestro': productoMaestro.toJson(),
      'p_articulos': articulos.map((a) => a.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [productoMaestro, articulos];
}

class ProductoMaestroData extends Equatable {
  final String marcaId;
  final String materialId;
  final String tipoId;
  final String valorTallaId;
  final String? descripcion;

  const ProductoMaestroData({
    required this.marcaId,
    required this.materialId,
    required this.tipoId,
    required this.valorTallaId,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      'marca_id': marcaId,
      'material_id': materialId,
      'tipo_id': tipoId,
      'valor_talla_id': valorTallaId,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }

  @override
  List<Object?> get props => [marcaId, materialId, tipoId, valorTallaId, descripcion];
}

class ArticuloData extends Equatable {
  final List<String> coloresIds;
  final double precio;

  const ArticuloData({
    required this.coloresIds,
    required this.precio,
  });

  Map<String, dynamic> toJson() {
    return {
      'colores_ids': coloresIds,
      'precio': precio,
    };
  }

  @override
  List<Object?> get props => [coloresIds, precio];
}
