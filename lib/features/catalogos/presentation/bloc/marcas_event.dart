import 'package:equatable/equatable.dart';

/// Eventos del Bloc de Marcas
abstract class MarcasEvent extends Equatable {
  const MarcasEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Cargar todas las marcas
class LoadMarcas extends MarcasEvent {
  const LoadMarcas();
}

/// Evento: Crear nueva marca
class CreateMarca extends MarcasEvent {
  final String nombre;
  final String codigo;
  final bool activo;

  const CreateMarca({
    required this.nombre,
    required this.codigo,
    this.activo = true,
  });

  @override
  List<Object?> get props => [nombre, codigo, activo];
}

/// Evento: Actualizar marca existente
class UpdateMarca extends MarcasEvent {
  final String id;
  final String nombre;
  final bool activo;

  const UpdateMarca({
    required this.id,
    required this.nombre,
    required this.activo,
  });

  @override
  List<Object?> get props => [id, nombre, activo];
}

/// Evento: Activar/desactivar marca
class ToggleMarca extends MarcasEvent {
  final String id;

  const ToggleMarca(this.id);

  @override
  List<Object?> get props => [id];
}

/// Evento: Buscar marcas por nombre o código
class SearchMarcas extends MarcasEvent {
  final String query;

  const SearchMarcas(this.query);

  @override
  List<Object?> get props => [query];
}
