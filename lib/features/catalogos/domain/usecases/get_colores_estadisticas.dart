import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/catalogos/data/models/estadisticas_colores_model.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/colores_repository.dart';

class GetColoresEstadisticas {
  final ColoresRepository repository;

  GetColoresEstadisticas(this.repository);

  Future<Either<Failure, EstadisticasColoresModel>> call() async {
    return await repository.getEstadisticas();
  }
}
