import 'package:equatable/equatable.dart';

/// Eventos para MaterialesBloc
///
/// Implementa E002-HU-002 (Gestionar Catálogo de Materiales)
abstract class MaterialesEvent extends Equatable {
  const MaterialesEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar lista de materiales
class LoadMaterialesEvent extends MaterialesEvent {
  const LoadMaterialesEvent();
}

/// Buscar materiales por query
class SearchMaterialesEvent extends MaterialesEvent {
  final String query;

  const SearchMaterialesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Crear nuevo material
class CreateMaterialEvent extends MaterialesEvent {
  final String nombre;
  final String? descripcion;
  final String codigo;

  const CreateMaterialEvent({
    required this.nombre,
    this.descripcion,
    required this.codigo,
  });

  @override
  List<Object?> get props => [nombre, descripcion, codigo];
}

/// Actualizar material existente
class UpdateMaterialEvent extends MaterialesEvent {
  final String id;
  final String nombre;
  final String? descripcion;
  final bool activo;

  const UpdateMaterialEvent({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, descripcion, activo];
}

/// Activar/Desactivar material (toggle)
class ToggleMaterialActivoEvent extends MaterialesEvent {
  final String id;

  const ToggleMaterialActivoEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Cargar detalle de material
class LoadMaterialDetailEvent extends MaterialesEvent {
  final String id;

  const LoadMaterialDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}
