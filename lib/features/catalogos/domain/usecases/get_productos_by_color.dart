import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/colores_repository.dart';

class GetProductosByColor {
  final ColoresRepository repository;

  GetProductosByColor(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({
    required String colorNombre,
    required bool exacto,
  }) async {
    return await repository.getProductosByColor(
      colorNombre: colorNombre,
      exacto: exacto,
    );
  }
}
