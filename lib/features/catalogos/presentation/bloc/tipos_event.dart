import 'package:equatable/equatable.dart';

/// Eventos del Bloc de Tipos
abstract class TiposEvent extends Equatable {
  const TiposEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar lista de tipos (CA-001)
class LoadTiposEvent extends TiposEvent {
  const LoadTiposEvent();
}

/// Buscar tipos por query (CA-011)
class SearchTiposEvent extends TiposEvent {
  final String query;

  const SearchTiposEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Crear nuevo tipo (CA-002, CA-003, CA-004)
class CreateTipoEvent extends TiposEvent {
  final String nombre;
  final String? descripcion;
  final String codigo;
  final String? imagenUrl;

  const CreateTipoEvent({
    required this.nombre,
    this.descripcion,
    required this.codigo,
    this.imagenUrl,
  });

  @override
  List<Object?> get props => [nombre, descripcion, codigo, imagenUrl];
}

/// Actualizar tipo existente (CA-005, CA-006, CA-007)
class UpdateTipoEvent extends TiposEvent {
  final String id;
  final String nombre;
  final String? descripcion;
  final bool activo;

  const UpdateTipoEvent({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, descripcion, activo];
}

/// Activar/desactivar tipo (CA-008, CA-009, CA-010)
class ToggleTipoActivoEvent extends TiposEvent {
  final String id;

  const ToggleTipoActivoEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Cargar detalle de tipo (CA-012)
class LoadTipoDetailEvent extends TiposEvent {
  final String id;

  const LoadTipoDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}
