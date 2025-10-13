import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/domain/repositories/producto_maestro_repository.dart';

class DesactivarProductoMaestro {
  final ProductoMaestroRepository repository;

  DesactivarProductoMaestro(this.repository);

  Future<Either<Failure, int>> call({
    required String productoId,
    required bool desactivarArticulos,
  }) async {
    return await repository.desactivarProductoMaestro(
      productoId: productoId,
      desactivarArticulos: desactivarArticulos,
    );
  }
}
