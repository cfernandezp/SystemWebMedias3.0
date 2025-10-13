import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_filter_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';

abstract class ProductoMaestroRepository {
  Future<Either<Failure, Map<String, dynamic>>> validarCombinacionComercial({
    required String tipoId,
    required String sistemaTallaId,
  });

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
    String? descripcion,
  });

  Future<Either<Failure, void>> eliminarProductoMaestro({
    required String productoId,
  });

  Future<Either<Failure, Map<String, dynamic>>> desactivarProductoMaestro({
    required String productoId,
    required bool desactivarArticulos,
  });

  Future<Either<Failure, void>> reactivarProductoMaestro({
    required String productoId,
  });
}
