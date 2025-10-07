import 'package:equatable/equatable.dart';
import '../../data/models/tipo_model.dart';

/// Estados del Bloc de Tipos
abstract class TiposState extends Equatable {
  const TiposState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TiposInitial extends TiposState {
  const TiposInitial();
}

/// Estado de carga
class TiposLoading extends TiposState {
  const TiposLoading();
}

/// Lista de tipos cargada exitosamente (CA-001, CA-011)
class TiposLoaded extends TiposState {
  final List<TipoModel> tipos;
  final String? searchQuery;

  const TiposLoaded({
    required this.tipos,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [tipos, searchQuery];
}

/// Detalle de tipo cargado (CA-012)
class TipoDetailLoaded extends TiposState {
  final Map<String, dynamic> detail;

  const TipoDetailLoaded({required this.detail});

  @override
  List<Object?> get props => [detail];
}

/// Operación exitosa (crear, actualizar, toggle)
class TipoOperationSuccess extends TiposState {
  final String message;

  const TipoOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error en operación
class TiposError extends TiposState {
  final String message;

  const TiposError({required this.message});

  @override
  List<Object?> get props => [message];
}
