import 'package:equatable/equatable.dart';
import '../../../data/models/create_sistema_talla_request.dart';
import '../../../data/models/update_sistema_talla_request.dart';

/// Eventos del Bloc de Sistemas de Tallas
///
/// Implementa E002-HU-004 (Gestionar Sistemas de Tallas).
abstract class SistemasTallaEvent extends Equatable {
  const SistemasTallaEvent();

  @override
  List<Object?> get props => [];
}

class LoadSistemasTallaEvent extends SistemasTallaEvent {
  final String? search;
  final String? tipoFilter;
  final bool? activoFilter;

  const LoadSistemasTallaEvent({
    this.search,
    this.tipoFilter,
    this.activoFilter,
  });

  @override
  List<Object?> get props => [search, tipoFilter, activoFilter];
}

class CreateSistemaTallaEvent extends SistemasTallaEvent {
  final CreateSistemaTallaRequest request;

  const CreateSistemaTallaEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateSistemaTallaEvent extends SistemasTallaEvent {
  final UpdateSistemaTallaRequest request;

  const UpdateSistemaTallaEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class LoadSistemaTallaValoresEvent extends SistemasTallaEvent {
  final String sistemaId;

  const LoadSistemaTallaValoresEvent(this.sistemaId);

  @override
  List<Object?> get props => [sistemaId];
}

class AddValorTallaEvent extends SistemasTallaEvent {
  final String sistemaId;
  final String valor;
  final int? orden;

  const AddValorTallaEvent({
    required this.sistemaId,
    required this.valor,
    this.orden,
  });

  @override
  List<Object?> get props => [sistemaId, valor, orden];
}

class UpdateValorTallaEvent extends SistemasTallaEvent {
  final String valorId;
  final String valor;
  final int? orden;

  const UpdateValorTallaEvent({
    required this.valorId,
    required this.valor,
    this.orden,
  });

  @override
  List<Object?> get props => [valorId, valor, orden];
}

class DeleteValorTallaEvent extends SistemasTallaEvent {
  final String valorId;
  final bool force;

  const DeleteValorTallaEvent({
    required this.valorId,
    this.force = false,
  });

  @override
  List<Object?> get props => [valorId, force];
}

class ToggleSistemaTallaActivoEvent extends SistemasTallaEvent {
  final String id;

  const ToggleSistemaTallaActivoEvent(this.id);

  @override
  List<Object?> get props => [id];
}
