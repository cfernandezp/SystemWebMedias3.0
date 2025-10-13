import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_filter_model.dart';
import 'package:system_web_medias/features/productos_maestros/domain/repositories/producto_maestro_repository.dart';

class ListarProductosMaestros {
  final ProductoMaestroRepository repository;

  ListarProductosMaestros(this.repository);

  Future<Either<Failure, List<ProductoMaestroModel>>> call({
    ProductoMaestroFilterModel? filtros,
  }) async {
    return await repository.listarProductosMaestros(filtros: filtros);
  }
}
