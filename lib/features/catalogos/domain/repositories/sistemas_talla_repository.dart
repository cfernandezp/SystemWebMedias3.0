import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/sistema_talla_model.dart';
import '../../data/models/valor_talla_model.dart';
import '../../data/models/create_sistema_talla_request.dart';
import '../../data/models/update_sistema_talla_request.dart';

/// Repository abstracto para gestión de sistemas de tallas.
///
/// Implementa patrón Either<Failure, Success> según Clean Architecture.
/// Cumple E002-HU-004 (Gestionar Sistemas de Tallas).
abstract class SistemasTallaRepository {
  /// Obtiene lista de sistemas con filtros
  /// Returns: Either<Failure, List<SistemaTallaModel>>
  Future<Either<Failure, List<SistemaTallaModel>>> getSistemasTalla({
    String? search,
    String? tipoFilter,
    bool? activoFilter,
  });

  /// Crea nuevo sistema de tallas
  /// Returns: Either<Failure, SistemaTallaModel>
  Future<Either<Failure, SistemaTallaModel>> createSistemaTalla(
    CreateSistemaTallaRequest request,
  );

  /// Actualiza sistema existente
  /// Returns: Either<Failure, SistemaTallaModel>
  Future<Either<Failure, SistemaTallaModel>> updateSistemaTalla(
    UpdateSistemaTallaRequest request,
  );

  /// Obtiene sistema con sus valores
  /// Returns: Either<Failure, Map<String, dynamic>> con 'sistema' y 'valores'
  Future<Either<Failure, Map<String, dynamic>>> getSistemaTallaValores(String sistemaId);

  /// Agrega valor a sistema
  /// Returns: Either<Failure, ValorTallaModel>
  Future<Either<Failure, ValorTallaModel>> addValorTalla(
    String sistemaId,
    String valor,
    int? orden,
  );

  /// Actualiza valor existente
  /// Returns: Either<Failure, ValorTallaModel>
  Future<Either<Failure, ValorTallaModel>> updateValorTalla(
    String valorId,
    String valor,
    int? orden,
  );

  /// Elimina (soft delete) valor
  /// Returns: Either<Failure, void>
  Future<Either<Failure, void>> deleteValorTalla(String valorId, bool force);

  /// Activa/desactiva sistema (toggle)
  /// Returns: Either<Failure, SistemaTallaModel>
  Future<Either<Failure, SistemaTallaModel>> toggleSistemaTallaActivo(String id);
}
