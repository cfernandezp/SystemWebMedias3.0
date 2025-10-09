import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/colores_repository.dart';

class GetColoresList {
  final ColoresRepository repository;

  GetColoresList(this.repository);

  Future<Either<Failure, List<ColorModel>>> call() async {
    return await repository.getColores();
  }
}
