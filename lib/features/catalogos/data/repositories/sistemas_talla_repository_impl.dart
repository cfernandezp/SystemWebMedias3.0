import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/sistemas_talla_repository.dart';
import '../datasources/sistemas_talla_remote_datasource.dart';
import '../models/sistema_talla_model.dart';
import '../models/valor_talla_model.dart';
import '../models/create_sistema_talla_request.dart';
import '../models/update_sistema_talla_request.dart';

/// Implementación del repository de sistemas de tallas.
///
/// Implementa patrón Either<Failure, Success> según Clean Architecture.
/// Mapea excepciones a failures según 00-CONVENTIONS.md.
class SistemasTallaRepositoryImpl implements SistemasTallaRepository {
  final SistemasTallaRemoteDataSource remoteDataSource;

  SistemasTallaRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SistemaTallaModel>>> getSistemasTalla({
    String? search,
    String? tipoFilter,
    bool? activoFilter,
  }) async {
    try {
      final result = await remoteDataSource.getSistemasTalla(
        search: search,
        tipoFilter: tipoFilter,
        activoFilter: activoFilter,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, SistemaTallaModel>> createSistemaTalla(
    CreateSistemaTallaRequest request,
  ) async {
    try {
      final result = await remoteDataSource.createSistemaTalla(request);
      return Right(result);
    } on DuplicateNameException catch (e) {
      return Left(DuplicateNameFailure(e.message));
    } on DuplicateValueException catch (e) {
      return Left(DuplicateValueFailure(e.message));
    } on OverlappingRangesException catch (e) {
      return Left(OverlappingRangesFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, SistemaTallaModel>> updateSistemaTalla(
    UpdateSistemaTallaRequest request,
  ) async {
    try {
      final result = await remoteDataSource.updateSistemaTalla(request);
      return Right(result);
    } on SistemaNotFoundException catch (e) {
      return Left(SistemaNotFoundFailure(e.message));
    } on DuplicateNameException catch (e) {
      return Left(DuplicateNameFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSistemaTallaValores(
    String sistemaId,
  ) async {
    try {
      final result = await remoteDataSource.getSistemaTallaValores(sistemaId);
      return Right(result);
    } on SistemaNotFoundException catch (e) {
      return Left(SistemaNotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ValorTallaModel>> addValorTalla(
    String sistemaId,
    String valor,
    int? orden,
  ) async {
    try {
      final result = await remoteDataSource.addValorTalla(sistemaId, valor, orden);
      return Right(result);
    } on SistemaNotFoundException catch (e) {
      return Left(SistemaNotFoundFailure(e.message));
    } on DuplicateValueException catch (e) {
      return Left(DuplicateValueFailure(e.message));
    } on OverlappingRangesException catch (e) {
      return Left(OverlappingRangesFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ValorTallaModel>> updateValorTalla(
    String valorId,
    String valor,
    int? orden,
  ) async {
    try {
      final result = await remoteDataSource.updateValorTalla(valorId, valor, orden);
      return Right(result);
    } on ValorNotFoundException catch (e) {
      return Left(ValorNotFoundFailure(e.message));
    } on DuplicateValueException catch (e) {
      return Left(DuplicateValueFailure(e.message));
    } on OverlappingRangesException catch (e) {
      return Left(OverlappingRangesFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteValorTalla(String valorId, bool force) async {
    try {
      await remoteDataSource.deleteValorTalla(valorId, force);
      return const Right(null);
    } on ValorNotFoundException catch (e) {
      return Left(ValorNotFoundFailure(e.message));
    } on LastValueException catch (e) {
      return Left(LastValueFailure(e.message));
    } on ValorUsedByProductsException catch (e) {
      return Left(ValorUsedByProductsFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, SistemaTallaModel>> toggleSistemaTallaActivo(String id) async {
    try {
      final result = await remoteDataSource.toggleSistemaTallaActivo(id);
      return Right(result);
    } on SistemaNotFoundException catch (e) {
      return Left(SistemaNotFoundFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }
}
