import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/domain/repositories/producto_maestro_repository.dart';

class ValidarCombinacionComercial {
  final ProductoMaestroRepository repository;

  ValidarCombinacionComercial(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String tipoId,
    required String sistemaTallaId,
  }) {
    return repository.validarCombinacionComercial(
      tipoId: tipoId,
      sistemaTallaId: sistemaTallaId,
    );
  }
}
