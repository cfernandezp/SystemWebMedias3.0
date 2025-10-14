import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/articulos/data/models/articulo_model.dart';
import 'package:system_web_medias/features/articulos/domain/repositories/articulos_repository.dart';

class EditarArticuloUseCase {
  final ArticulosRepository repository;

  EditarArticuloUseCase({required this.repository});

  Future<Either<Failure, ArticuloModel>> call({
    required String articuloId,
    double? precio,
    bool? activo,
  }) async {
    return await repository.editarArticulo(
      articuloId: articuloId,
      precio: precio,
      activo: activo,
    );
  }
}