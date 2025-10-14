import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/articulos/domain/repositories/articulos_repository.dart';

class GenerarSkuUseCase {
  final ArticulosRepository repository;

  GenerarSkuUseCase({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String productoMaestroId,
    required List<String> coloresIds,
  }) async {
    return await repository.generarSku(
      productoMaestroId: productoMaestroId,
      coloresIds: coloresIds,
    );
  }
}