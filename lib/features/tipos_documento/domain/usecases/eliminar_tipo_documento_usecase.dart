import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/tipos_documento/domain/repositories/tipo_documento_repository.dart';

class EliminarTipoDocumentoUseCase {
  final TipoDocumentoRepository repository;

  EliminarTipoDocumentoUseCase({required this.repository});

  Future<Either<Failure, void>> call(String id) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure('ID es obligatorio'));
    }

    return await repository.eliminarTipoDocumento(id: id);
  }
}
