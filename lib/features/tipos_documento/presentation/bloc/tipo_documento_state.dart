import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/tipos_documento/domain/entities/tipo_documento_entity.dart';

abstract class TipoDocumentoState extends Equatable {
  const TipoDocumentoState();

  @override
  List<Object?> get props => [];
}

class TipoDocumentoInitial extends TipoDocumentoState {}

class TipoDocumentoLoading extends TipoDocumentoState {}

class TipoDocumentoListLoaded extends TipoDocumentoState {
  final List<TipoDocumentoEntity> tipos;

  const TipoDocumentoListLoaded({required this.tipos});

  @override
  List<Object?> get props => [tipos];
}

class TipoDocumentoOperationSuccess extends TipoDocumentoState {
  final String message;
  final TipoDocumentoEntity? tipo;

  const TipoDocumentoOperationSuccess({
    required this.message,
    this.tipo,
  });

  @override
  List<Object?> get props => [message, tipo];
}

class TipoDocumentoValidationResult extends TipoDocumentoState {
  final bool esValido;
  final String message;

  const TipoDocumentoValidationResult({
    required this.esValido,
    required this.message,
  });

  @override
  List<Object?> get props => [esValido, message];
}

class TipoDocumentoError extends TipoDocumentoState {
  final String message;

  const TipoDocumentoError({required this.message});

  @override
  List<Object?> get props => [message];
}
