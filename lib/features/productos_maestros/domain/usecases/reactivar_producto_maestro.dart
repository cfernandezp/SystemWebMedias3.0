import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/domain/repositories/producto_maestro_repository.dart';

class ReactivarProductoMaestro {
  final ProductoMaestroRepository repository;

  ReactivarProductoMaestro(this.repository);

  Future<Either<Failure, void>> call({required String productoId}) {
    return repository.reactivarProductoMaestro(productoId: productoId);
  }
}
