import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/articulos/data/models/articulo_model.dart';
import 'package:system_web_medias/features/articulos/domain/repositories/articulos_repository.dart';

class CrearArticuloUseCase {
  final ArticulosRepository repository;

  CrearArticuloUseCase({required this.repository});

  Future<Either<Failure, ArticuloModel>> call({
    required String productoMaestroId,
    required List<String> coloresIds,
    required double precio,
  }) async {
    return await repository.crearArticulo(
      productoMaestroId: productoMaestroId,
      coloresIds: coloresIds,
      precio: precio,
    );
  }
}