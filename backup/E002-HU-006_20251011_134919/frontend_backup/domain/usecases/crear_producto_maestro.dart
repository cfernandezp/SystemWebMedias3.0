import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';
import 'package:system_web_medias/features/productos_maestros/domain/repositories/producto_maestro_repository.dart';

class CrearProductoMaestro {
  final ProductoMaestroRepository repository;

  CrearProductoMaestro(this.repository);

  Future<Either<Failure, ProductoMaestroModel>> call({
    required String marcaId,
    required String materialId,
    required String tipoId,
    required String sistemaTallaId,
    String? descripcion,
  }) async {
    return await repository.crearProductoMaestro(
      marcaId: marcaId,
      materialId: materialId,
      tipoId: tipoId,
      sistemaTallaId: sistemaTallaId,
      descripcion: descripcion,
    );
  }
}
