import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/colores_repository.dart';

class CreateColor {
  final ColoresRepository repository;

  CreateColor(this.repository);

  Future<Either<Failure, ColorModel>> call({
    required String nombre,
    required String codigoHex,
  }) async {
    return await repository.createColor(
      nombre: nombre,
      codigoHex: codigoHex,
    );
  }
}
