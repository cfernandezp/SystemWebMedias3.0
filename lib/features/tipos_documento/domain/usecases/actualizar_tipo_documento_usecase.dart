import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/tipos_documento/domain/entities/tipo_documento_entity.dart';
import 'package:system_web_medias/features/tipos_documento/domain/repositories/tipo_documento_repository.dart';

class ActualizarTipoDocumentoParams {
  final String id;
  final String codigo;
  final String nombre;
  final String formato;
  final int longitudMinima;
  final int longitudMaxima;
  final bool activo;

  ActualizarTipoDocumentoParams({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.formato,
    required this.longitudMinima,
    required this.longitudMaxima,
    required this.activo,
  });
}

class ActualizarTipoDocumentoUseCase {
  final TipoDocumentoRepository repository;

  ActualizarTipoDocumentoUseCase({required this.repository});

  Future<Either<Failure, TipoDocumentoEntity>> call(
    ActualizarTipoDocumentoParams params,
  ) async {
    if (params.id.isEmpty || params.codigo.isEmpty || params.nombre.isEmpty) {
      return const Left(ValidationFailure('ID, código y nombre son obligatorios'));
    }

    if (params.longitudMinima <= 0) {
      return const Left(ValidationFailure('Longitud mínima debe ser mayor a 0'));
    }

    if (params.longitudMaxima < params.longitudMinima) {
      return const Left(ValidationFailure('Longitud máxima debe ser mayor o igual a mínima'));
    }

    return await repository.actualizarTipoDocumento(
      id: params.id,
      codigo: params.codigo,
      nombre: params.nombre,
      formato: params.formato,
      longitudMinima: params.longitudMinima,
      longitudMaxima: params.longitudMaxima,
      activo: params.activo,
    );
  }
}
