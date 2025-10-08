import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/materiales_repository.dart';
import '../datasources/materiales_remote_datasource.dart';
import '../models/material_model.dart';

/// Implementación de MaterialesRepository.
///
/// Maneja patrón Either<Failure, Success>.
/// Mapea excepciones a Failures según 00-CONVENTIONS.md.
class MaterialesRepositoryImpl implements MaterialesRepository {
  final MaterialesRemoteDataSource remoteDataSource;

  MaterialesRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<MaterialModel>>> getMateriales() async {
    try {
      final result = await remoteDataSource.listarMateriales();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, MaterialModel>> createMaterial({
    required String nombre,
    String? descripcion,
    required String codigo,
  }) async {
    try {
      final result = await remoteDataSource.crearMaterial(
        nombre: nombre,
        descripcion: descripcion,
        codigo: codigo,
      );
      return Right(result);
    } on DuplicateCodeException catch (e) {
      return Left(DuplicateCodeFailure(e.message));
    } on DuplicateNameException catch (e) {
      return Left(DuplicateNameFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, MaterialModel>> updateMaterial({
    required String id,
    required String nombre,
    String? descripcion,
    required bool activo,
  }) async {
    try {
      final result = await remoteDataSource.actualizarMaterial(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        activo: activo,
      );
      return Right(result);
    } on MaterialNotFoundException catch (e) {
      return Left(MaterialNotFoundFailure(e.message));
    } on DuplicateNameException catch (e) {
      return Left(DuplicateNameFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, MaterialModel>> toggleMaterialActivo(String id) async {
    try {
      final result = await remoteDataSource.toggleMaterialActivo(
        id: id,
      );
      return Right(result);
    } on MaterialNotFoundException catch (e) {
      return Left(MaterialNotFoundFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MaterialModel>>> searchMateriales(String query) async {
    try {
      final result = await remoteDataSource.buscarMateriales(query);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMaterialDetail(String id) async {
    try {
      final result = await remoteDataSource.obtenerDetalleMaterial(id);
      return Right(result);
    } on MaterialNotFoundException catch (e) {
      return Left(MaterialNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }
}
