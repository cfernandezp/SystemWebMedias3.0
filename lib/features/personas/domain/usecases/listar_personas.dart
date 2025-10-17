import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/personas/domain/repositories/persona_repository.dart';

class ListarPersonas {
  final PersonaRepository repository;

  ListarPersonas(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(ListarPersonasParams params) async {
    return await repository.listarPersonas(
      tipoDocumentoId: params.tipoDocumentoId,
      tipoPersona: params.tipoPersona,
      activo: params.activo,
      busqueda: params.busqueda,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class ListarPersonasParams extends Equatable {
  final String? tipoDocumentoId;
  final String? tipoPersona;
  final bool? activo;
  final String? busqueda;
  final int limit;
  final int offset;

  const ListarPersonasParams({
    this.tipoDocumentoId,
    this.tipoPersona,
    this.activo,
    this.busqueda,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [
        tipoDocumentoId,
        tipoPersona,
        activo,
        busqueda,
        limit,
        offset,
      ];
}
