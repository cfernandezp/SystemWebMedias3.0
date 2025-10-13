import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_filter_model.dart';

abstract class ProductoMaestroRepository {
  Future<Either<Failure, ProductoMaestroModel>> crearProductoMaestro({
    required String marcaId,
    required String materialId,
    required String tipoId,
    required String sistemaTallaId,
    String? descripcion,
  });

  Future<Either<Failure, List<ProductoMaestroModel>>> listarProductosMaestros({
    ProductoMaestroFilterModel? filtros,
  });

  Future<Either<Failure, ProductoMaestroModel>> editarProductoMaestro({
    required String productoId,
    String? marcaId,
    String? materialId,
    String? tipoId,
    String? sistemaTallaId,
    String? descripcion,
  });

  Future<Either<Failure, void>> eliminarProductoMaestro(String productoId);

  Future<Either<Failure, int>> desactivarProductoMaestro({
    required String productoId,
    required bool desactivarArticulos,
  });

  Future<Either<Failure, ProductoMaestroModel>> reactivarProductoMaestro(
      String productoId);

  Future<Either<Failure, List<String>>> validarCombinacionComercial({
    required String tipoId,
    required String sistemaTallaId,
  });
}
