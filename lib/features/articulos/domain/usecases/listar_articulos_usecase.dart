import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/articulos/data/models/articulo_model.dart';
import 'package:system_web_medias/features/articulos/data/models/filtros_articulos_model.dart';
import 'package:system_web_medias/features/articulos/domain/repositories/articulos_repository.dart';

class ListarArticulosUseCase {
  final ArticulosRepository repository;

  ListarArticulosUseCase({required this.repository});

  Future<Either<Failure, List<ArticuloModel>>> call({
    FiltrosArticulosModel? filtros,
    int? limit,
    int? offset,
  }) async {
    return await repository.listarArticulos(
      filtros: filtros,
      limit: limit,
      offset: offset,
    );
  }
}