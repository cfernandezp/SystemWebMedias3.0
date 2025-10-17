import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';
import 'package:system_web_medias/features/personas/domain/repositories/persona_repository.dart';

class BuscarPersonaPorDocumento {
  final PersonaRepository repository;

  BuscarPersonaPorDocumento(this.repository);

  Future<Either<Failure, Persona>> call(BuscarPersonaPorDocumentoParams params) async {
    return await repository.buscarPersonaPorDocumento(
      tipoDocumentoId: params.tipoDocumentoId,
      numeroDocumento: params.numeroDocumento,
    );
  }
}

class BuscarPersonaPorDocumentoParams extends Equatable {
  final String tipoDocumentoId;
  final String numeroDocumento;

  const BuscarPersonaPorDocumentoParams({
    required this.tipoDocumentoId,
    required this.numeroDocumento,
  });

  @override
  List<Object?> get props => [tipoDocumentoId, numeroDocumento];
}
