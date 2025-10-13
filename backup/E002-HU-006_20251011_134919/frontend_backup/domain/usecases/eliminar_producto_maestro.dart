import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/domain/repositories/producto_maestro_repository.dart';

class EliminarProductoMaestro {
  final ProductoMaestroRepository repository;

  EliminarProductoMaestro(this.repository);

  Future<Either<Failure, void>> call(String productoId) async {
    return await repository.eliminarProductoMaestro(productoId);
  }
}
