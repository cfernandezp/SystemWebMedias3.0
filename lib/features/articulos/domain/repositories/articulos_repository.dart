import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/articulos/data/models/articulo_model.dart';
import 'package:system_web_medias/features/articulos/data/models/filtros_articulos_model.dart';

abstract class ArticulosRepository {
  Future<Either<Failure, Map<String, dynamic>>> generarSku({
    required String productoMaestroId,
    required List<String> coloresIds,
  });

  Future<Either<Failure, Map<String, dynamic>>> validarSkuUnico({
    required String sku,
    String? articuloId,
  });

  Future<Either<Failure, ArticuloModel>> crearArticulo({
    required String productoMaestroId,
    required List<String> coloresIds,
    required double precio,
  });

  Future<Either<Failure, List<ArticuloModel>>> listarArticulos({
    FiltrosArticulosModel? filtros,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, ArticuloModel>> obtenerArticulo({
    required String articuloId,
  });

  Future<Either<Failure, ArticuloModel>> editarArticulo({
    required String articuloId,
    double? precio,
    bool? activo,
  });

  Future<Either<Failure, void>> eliminarArticulo({
    required String articuloId,
  });

  Future<Either<Failure, Map<String, dynamic>>> desactivarArticulo({
    required String articuloId,
  });
}