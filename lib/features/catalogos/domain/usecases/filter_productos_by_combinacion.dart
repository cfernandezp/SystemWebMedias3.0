import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/colores_repository.dart';

class FilterProductosByCombinacion {
  final ColoresRepository repository;

  FilterProductosByCombinacion(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({
    required List<String> colores,
  }) async {
    return await repository.filterProductosByCombinacion(
      colores: colores,
    );
  }
}
