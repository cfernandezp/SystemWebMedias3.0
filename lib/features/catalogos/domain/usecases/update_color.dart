import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/colores_repository.dart';

class UpdateColor {
  final ColoresRepository repository;

  UpdateColor(this.repository);

  Future<Either<Failure, ColorModel>> call({
    required String id,
    required String nombre,
    required String codigoHex,
  }) async {
    return await repository.updateColor(
      id: id,
      nombre: nombre,
      codigoHex: codigoHex,
    );
  }
}
