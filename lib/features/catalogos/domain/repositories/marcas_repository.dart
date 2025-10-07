import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/catalogos/data/models/marca_model.dart';

/// Abstract Repository para operaciones de marcas
abstract class MarcasRepository {
  /// HU-001: Obtener todas las marcas
  Future<Either<Failure, List<MarcaModel>>> getMarcas();

  /// HU-001: Crear nueva marca
  Future<Either<Failure, MarcaModel>> createMarca({
    required String nombre,
    required String codigo,
    required bool activo,
  });

  /// HU-001: Actualizar marca existente
  Future<Either<Failure, MarcaModel>> updateMarca({
    required String id,
    required String nombre,
    required bool activo,
  });

  /// HU-001: Activar/desactivar marca
  Future<Either<Failure, MarcaModel>> toggleMarca(String id);
}
