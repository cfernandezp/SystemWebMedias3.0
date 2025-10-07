import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/material_model.dart';

/// Repository abstracto para gestión de materiales.
///
/// Implementa patrón Either<Failure, Success> según Clean Architecture.
/// Ver E002-HU-002_IMPLEMENTATION.md (Frontend).
abstract class MaterialesRepository {
  /// Obtener lista de materiales
  Future<Either<Failure, List<MaterialModel>>> getMateriales();

  /// Crear nuevo material
  Future<Either<Failure, MaterialModel>> createMaterial({
    required String nombre,
    String? descripcion,
    required String codigo,
  });

  /// Actualizar material existente
  Future<Either<Failure, MaterialModel>> updateMaterial({
    required String id,
    required String nombre,
    String? descripcion,
    required bool activo,
  });

  /// Activar/Desactivar material (toggle)
  Future<Either<Failure, MaterialModel>> toggleMaterialActivo(String id);

  /// Buscar materiales por query
  Future<Either<Failure, List<MaterialModel>>> searchMateriales(String query);

  /// Obtener detalle de material con estadísticas
  Future<Either<Failure, Map<String, dynamic>>> getMaterialDetail(String id);
}
