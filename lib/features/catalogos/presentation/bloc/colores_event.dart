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
  final String codigoHex;

  const CreateColorEvent({
    required this.nombre,
    required this.codigoHex,
  });

  @override
  List<Object?> get props => [nombre, codigoHex];
}

class UpdateColorEvent extends ColoresEvent {
  final String id;
  final String nombre;
  final String codigoHex;

  const UpdateColorEvent({
    required this.id,
    required this.nombre,
    required this.codigoHex,
  });

  @override
  List<Object?> get props => [id, nombre, codigoHex];
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
