import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/tipo_model.dart';

/// Repository abstracto para gestión de tipos.
///
/// Implementa patrón Either<Failure, Success> según Clean Architecture.
/// Ver E002-HU-003_IMPLEMENTATION.md (Frontend).
abstract class TiposRepository {
  /// Obtener lista de tipos con filtros opcionales
  ///
  /// Parámetros:
  /// - [search]: Búsqueda multicriterio (nombre, descripción, código)
  /// - [activoFilter]: Filtrar por estado (true=activos, false=inactivos, null=todos)
  Future<Either<Failure, List<TipoModel>>> getTipos({
    String? search,
    bool? activoFilter,
  });

  /// Crear nuevo tipo
  ///
  /// Validaciones backend:
  /// - RN-003-001: Código único 3 letras mayúsculas
  /// - RN-003-002: Nombre único max 50 caracteres
  /// - RN-003-003: Descripción opcional max 200 caracteres
  /// - RN-003-011: Solo ADMIN puede crear
  Future<Either<Failure, TipoModel>> createTipo({
    required String nombre,
    String? descripcion,
    required String codigo,
    String? imagenUrl,
  });

  /// Actualizar tipo existente
  ///
  /// Validaciones backend:
  /// - RN-003-004: Código NO se puede modificar (inmutable)
  /// - RN-003-002: Nombre único (excepto sí mismo)
  /// - RN-003-011: Solo ADMIN puede actualizar
  Future<Either<Failure, TipoModel>> updateTipo({
    required String id,
    required String nombre,
    String? descripcion,
    String? imagenUrl,
    required bool activo,
  });

  /// Activar/Desactivar tipo (toggle)
  ///
  /// Implementa:
  /// - RN-003-005: Soft delete (no elimina físicamente)
  /// - RN-003-007: Retorna contador de productos asociados
  /// - RN-003-011: Solo ADMIN puede gestionar
  Future<Either<Failure, TipoModel>> toggleTipoActivo(String id);

  /// Obtener detalle de tipo con estadísticas
  ///
  /// Retorna:
  /// - Información completa del tipo
  /// - productos_count: Cantidad de productos asociados
  /// - productos_list: Lista de productos (primeros 10)
  Future<Either<Failure, TipoModel>> getTipoDetail(String id);

  /// Obtener solo tipos activos para formularios de productos
  ///
  /// Implementa RN-003-006: Solo tipos activos disponibles para nuevos productos
  Future<Either<Failure, List<TipoModel>>> getTiposActivos();
}
