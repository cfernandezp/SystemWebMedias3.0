import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/colores_repository.dart';

class DeleteColor {
  final ColoresRepository repository;

  DeleteColor(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String id) async {
    return await repository.deleteColor(id);
  }
}
