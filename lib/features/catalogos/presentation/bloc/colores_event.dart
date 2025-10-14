import 'package:equatable/equatable.dart';

abstract class ColoresEvent extends Equatable {
  const ColoresEvent();

  @override
  List<Object?> get props => [];
}

class LoadColores extends ColoresEvent {
  const LoadColores();
}

class CreateColorEvent extends ColoresEvent {
  final String nombre;
  final List<String> codigosHex;

  const CreateColorEvent({
    required this.nombre,
    required this.codigosHex,
  });

  @override
  List<Object?> get props => [nombre, codigosHex];
}

class UpdateColorEvent extends ColoresEvent {
  final String id;
  final String nombre;
  final List<String> codigosHex;

  const UpdateColorEvent({
    required this.id,
    required this.nombre,
    required this.codigosHex,
  });

  @override
  List<Object?> get props => [id, nombre, codigosHex];
}

class DeleteColorEvent extends ColoresEvent {
  final String id;

  const DeleteColorEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchColores extends ColoresEvent {
  final String query;

  const SearchColores(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadEstadisticas extends ColoresEvent {
  const LoadEstadisticas();
}

class LoadProductosByColor extends ColoresEvent {
  final String colorNombre;
  final bool exacto;

  const LoadProductosByColor({
    required this.colorNombre,
    required this.exacto,
  });

  @override
  List<Object?> get props => [colorNombre, exacto];
}

class FilterProductosByCombinacionEvent extends ColoresEvent {
  final List<String> colores;

  const FilterProductosByCombinacionEvent({
    required this.colores,
  });

  @override
  List<Object?> get props => [colores];
}

class FilterByTipoColorEvent extends ColoresEvent {
  final String? tipoColorFilter;

  const FilterByTipoColorEvent(this.tipoColorFilter);

  @override
  List<Object?> get props => [tipoColorFilter];
}
