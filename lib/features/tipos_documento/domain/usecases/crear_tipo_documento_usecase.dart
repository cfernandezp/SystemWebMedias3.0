import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/tipos_documento/domain/entities/tipo_documento_entity.dart';
import 'package:system_web_medias/features/tipos_documento/domain/repositories/tipo_documento_repository.dart';

class CrearTipoDocumentoParams {
  final String codigo;
  final String nombre;
  final String formato;
  final int longitudMinima;
  final int longitudMaxima;

  CrearTipoDocumentoParams({
    required this.codigo,
    required this.nombre,
    required this.formato,
    required this.longitudMinima,
    required this.longitudMaxima,
  });
}

class CrearTipoDocumentoUseCase {
  final TipoDocumentoRepository repository;

  CrearTipoDocumentoUseCase({required this.repository});

  Future<Either<Failure, TipoDocumentoEntity>> call(
    CrearTipoDocumentoParams params,
  ) async {
    if (params.codigo.isEmpty || params.nombre.isEmpty) {
      return const Left(ValidationFailure('Código y nombre son obligatorios'));
    }

    if (params.longitudMinima <= 0) {
      return const Left(ValidationFailure('Longitud mínima debe ser mayor a 0'));
    }

    if (params.longitudMaxima < params.longitudMinima) {
      return const Left(ValidationFailure('Longitud máxima debe ser mayor o igual a mínima'));
    }

    return await repository.crearTipoDocumento(
      codigo: params.codigo,
      nombre: params.nombre,
      formato: params.formato,
      longitudMinima: params.longitudMinima,
      longitudMaxima: params.longitudMaxima,
    );
  }
}
