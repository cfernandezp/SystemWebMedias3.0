import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/articulos/domain/repositories/articulos_repository.dart';

class EliminarArticuloUseCase {
  final ArticulosRepository repository;

  EliminarArticuloUseCase({required this.repository});

  Future<Either<Failure, void>> call({
    required String articuloId,
  }) async {
    return await repository.eliminarArticulo(articuloId: articuloId);
  }
}