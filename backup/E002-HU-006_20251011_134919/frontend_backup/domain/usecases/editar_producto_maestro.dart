import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';
import 'package:system_web_medias/features/productos_maestros/domain/repositories/producto_maestro_repository.dart';

class EditarProductoMaestro {
  final ProductoMaestroRepository repository;

  EditarProductoMaestro(this.repository);

  Future<Either<Failure, ProductoMaestroModel>> call({
    required String productoId,
    String? marcaId,
    String? materialId,
    String? tipoId,
    String? sistemaTallaId,
    String? descripcion,
  }) async {
    return await repository.editarProductoMaestro(
      productoId: productoId,
      marcaId: marcaId,
      materialId: materialId,
      tipoId: tipoId,
      sistemaTallaId: sistemaTallaId,
      descripcion: descripcion,
    );
  }
}
