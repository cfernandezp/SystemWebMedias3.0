import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/tipos_documento/domain/entities/tipo_documento_entity.dart';

abstract class TipoDocumentoRepository {
  Future<Either<Failure, List<TipoDocumentoEntity>>> listarTiposDocumento({
    required bool incluirInactivos,
  });

  Future<Either<Failure, TipoDocumentoEntity>> crearTipoDocumento({
    required String codigo,
    required String nombre,
    required String formato,
    required int longitudMinima,
    required int longitudMaxima,
  });

  Future<Either<Failure, TipoDocumentoEntity>> actualizarTipoDocumento({
    required String id,
    required String codigo,
    required String nombre,
    required String formato,
    required int longitudMinima,
    required int longitudMaxima,
    required bool activo,
  });

  Future<Either<Failure, void>> eliminarTipoDocumento({
    required String id,
  });

  Future<Either<Failure, bool>> validarFormatoDocumento({
    required String tipoDocumentoId,
    required String numeroDocumento,
  });
}
