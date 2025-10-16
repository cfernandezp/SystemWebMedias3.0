import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/tipos_documento/domain/repositories/tipo_documento_repository.dart';

class ValidarFormatoDocumentoParams {
  final String tipoDocumentoId;
  final String numeroDocumento;

  ValidarFormatoDocumentoParams({
    required this.tipoDocumentoId,
    required this.numeroDocumento,
  });
}

class ValidarFormatoDocumentoUseCase {
  final TipoDocumentoRepository repository;

  ValidarFormatoDocumentoUseCase({required this.repository});

  Future<Either<Failure, bool>> call(
    ValidarFormatoDocumentoParams params,
  ) async {
    if (params.tipoDocumentoId.isEmpty || params.numeroDocumento.isEmpty) {
      return const Left(ValidationFailure('Tipo de documento y número son obligatorios'));
    }

    return await repository.validarFormatoDocumento(
      tipoDocumentoId: params.tipoDocumentoId,
      numeroDocumento: params.numeroDocumento,
    );
  }
}
