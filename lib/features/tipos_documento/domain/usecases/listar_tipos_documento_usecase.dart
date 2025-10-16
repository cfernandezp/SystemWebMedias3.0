import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/tipos_documento/domain/entities/tipo_documento_entity.dart';
import 'package:system_web_medias/features/tipos_documento/domain/repositories/tipo_documento_repository.dart';

class ListarTiposDocumentoUseCase {
  final TipoDocumentoRepository repository;

  ListarTiposDocumentoUseCase({required this.repository});

  Future<Either<Failure, List<TipoDocumentoEntity>>> call({
    bool incluirInactivos = false,
  }) async {
    return await repository.listarTiposDocumento(
      incluirInactivos: incluirInactivos,
    );
  }
}
