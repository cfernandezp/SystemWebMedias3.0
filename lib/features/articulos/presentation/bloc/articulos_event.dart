import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/articulos/data/models/filtros_articulos_model.dart';

abstract class ArticulosEvent extends Equatable {
  const ArticulosEvent();

  @override
  List<Object?> get props => [];
}

class GenerarSkuEvent extends ArticulosEvent {
  final String productoMaestroId;
  final List<String> coloresIds;

  const GenerarSkuEvent({
    required this.productoMaestroId,
    required this.coloresIds,
  });

  @override
  List<Object?> get props => [productoMaestroId, coloresIds];
}

class CrearArticuloEvent extends ArticulosEvent {
  final String productoMaestroId;
  final List<String> coloresIds;
  final double precio;

  const CrearArticuloEvent({
    required this.productoMaestroId,
    required this.coloresIds,
    required this.precio,
  });

  @override
  List<Object?> get props => [productoMaestroId, coloresIds, precio];
}

class ListarArticulosEvent extends ArticulosEvent {
  final FiltrosArticulosModel? filtros;
  final int? limit;
  final int? offset;

  const ListarArticulosEvent({
    this.filtros,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [filtros, limit, offset];
}

class ObtenerArticuloEvent extends ArticulosEvent {
  final String articuloId;

  const ObtenerArticuloEvent({required this.articuloId});

  @override
  List<Object?> get props => [articuloId];
}

class EditarArticuloEvent extends ArticulosEvent {
  final String articuloId;
  final double? precio;
  final bool? activo;

  const EditarArticuloEvent({
    required this.articuloId,
    this.precio,
    this.activo,
  });

  @override
  List<Object?> get props => [articuloId, precio, activo];
}

class EliminarArticuloEvent extends ArticulosEvent {
  final String articuloId;

  const EliminarArticuloEvent({required this.articuloId});

  @override
  List<Object?> get props => [articuloId];
}

class DesactivarArticuloEvent extends ArticulosEvent {
  final String articuloId;

  const DesactivarArticuloEvent({required this.articuloId});

  @override
  List<Object?> get props => [articuloId];
}