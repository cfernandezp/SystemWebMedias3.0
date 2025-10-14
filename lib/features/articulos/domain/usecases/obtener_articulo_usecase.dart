import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/articulos/data/models/articulo_model.dart';
import 'package:system_web_medias/features/articulos/domain/repositories/articulos_repository.dart';

class ObtenerArticuloUseCase {
  final ArticulosRepository repository;

  ObtenerArticuloUseCase({required this.repository});

  Future<Either<Failure, ArticuloModel>> call({
    required String articuloId,
  }) async {
    return await repository.obtenerArticulo(articuloId: articuloId);
  }
}