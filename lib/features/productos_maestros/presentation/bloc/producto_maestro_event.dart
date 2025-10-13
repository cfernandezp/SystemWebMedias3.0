import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_filter_model.dart';

abstract class ProductoMaestroEvent extends Equatable {
  const ProductoMaestroEvent();

  @override
  List<Object?> get props => [];
}

class ValidarCombinacionEvent extends ProductoMaestroEvent {
  final String tipoId;
  final String sistemaTallaId;

  const ValidarCombinacionEvent({
    required this.tipoId,
    required this.sistemaTallaId,
  });

  @override
  List<Object?> get props => [tipoId, sistemaTallaId];
}

class CrearProductoMaestroEvent extends ProductoMaestroEvent {
  final String marcaId;
  final String materialId;
  final String tipoId;
  final String sistemaTallaId;
  final String? descripcion;

  const CrearProductoMaestroEvent({
    required this.marcaId,
    required this.materialId,
    required this.tipoId,
    required this.sistemaTallaId,
    this.descripcion,
  });

  @override
  List<Object?> get props => [marcaId, materialId, tipoId, sistemaTallaId, descripcion];
}

class ListarProductosMaestrosEvent extends ProductoMaestroEvent {
  final ProductoMaestroFilterModel? filtros;

  const ListarProductosMaestrosEvent({this.filtros});

  @override
  List<Object?> get props => [filtros];
}

class EditarProductoMaestroEvent extends ProductoMaestroEvent {
  final String productoId;
  final String? descripcion;

  const EditarProductoMaestroEvent({
    required this.productoId,
    this.descripcion,
  });

  @override
  List<Object?> get props => [productoId, descripcion];
}

class EliminarProductoMaestroEvent extends ProductoMaestroEvent {
  final String productoId;

  const EliminarProductoMaestroEvent({required this.productoId});

  @override
  List<Object?> get props => [productoId];
}

class DesactivarProductoMaestroEvent extends ProductoMaestroEvent {
  final String productoId;
  final bool desactivarArticulos;

  const DesactivarProductoMaestroEvent({
    required this.productoId,
    required this.desactivarArticulos,
  });

  @override
  List<Object?> get props => [productoId, desactivarArticulos];
}

class ReactivarProductoMaestroEvent extends ProductoMaestroEvent {
  final String productoId;

  const ReactivarProductoMaestroEvent({required this.productoId});

  @override
  List<Object?> get props => [productoId];
}
