import 'package:equatable/equatable.dart';
import '../../../data/models/sistema_talla_model.dart';
import '../../../data/models/valor_talla_model.dart';

/// Estados del Bloc de Sistemas de Tallas
///
/// Implementa E002-HU-004 (Gestionar Sistemas de Tallas).
abstract class SistemasTallaState extends Equatable {
  const SistemasTallaState();

  @override
  List<Object?> get props => [];
}

class SistemasTallaInitial extends SistemasTallaState {}

class SistemasTallaLoading extends SistemasTallaState {}

class SistemasTallaLoaded extends SistemasTallaState {
  final List<SistemaTallaModel> sistemas;

  const SistemasTallaLoaded(this.sistemas);

  @override
  List<Object?> get props => [sistemas];
}

class SistemaTallaCreated extends SistemasTallaState {
  final SistemaTallaModel sistema;

  const SistemaTallaCreated(this.sistema);

  @override
  List<Object?> get props => [sistema];
}

class SistemaTallaUpdated extends SistemasTallaState {
  final SistemaTallaModel sistema;

  const SistemaTallaUpdated(this.sistema);

  @override
  List<Object?> get props => [sistema];
}

class SistemaTallaValoresLoaded extends SistemasTallaState {
  final SistemaTallaModel sistema;
  final List<ValorTallaModel> valores;

  const SistemaTallaValoresLoaded(this.sistema, this.valores);

  @override
  List<Object?> get props => [sistema, valores];
}

class ValorTallaAdded extends SistemasTallaState {
  final ValorTallaModel valor;

  const ValorTallaAdded(this.valor);

  @override
  List<Object?> get props => [valor];
}

class ValorTallaUpdated extends SistemasTallaState {
  final ValorTallaModel valor;

  const ValorTallaUpdated(this.valor);

  @override
  List<Object?> get props => [valor];
}

class ValorTallaDeleted extends SistemasTallaState {}

class SistemaTallaToggled extends SistemasTallaState {
  final SistemaTallaModel sistema;

  const SistemaTallaToggled(this.sistema);

  @override
  List<Object?> get props => [sistema];
}

class SistemasTallaError extends SistemasTallaState {
  final String message;

  const SistemasTallaError(this.message);

  @override
  List<Object?> get props => [message];
}
