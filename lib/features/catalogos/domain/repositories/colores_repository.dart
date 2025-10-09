import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';
import 'package:system_web_medias/features/catalogos/data/models/estadisticas_colores_model.dart';

abstract class ColoresRepository {
  Future<Either<Failure, List<ColorModel>>> getColores();

  Future<Either<Failure, ColorModel>> createColor({
    required String nombre,
    required String codigoHex,
  });

  Future<Either<Failure, ColorModel>> updateColor({
    required String id,
    required String nombre,
    required String codigoHex,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteColor(String id);

  Future<Either<Failure, List<Map<String, dynamic>>>> getProductosByColor({
    required String colorNombre,
    required bool exacto,
  });

  Future<Either<Failure, EstadisticasColoresModel>> getEstadisticas();
}
