import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/tipos_repository.dart';
import '../datasources/tipos_remote_datasource.dart';
import '../models/tipo_model.dart';

/// Implementación de TiposRepository.
///
/// Maneja patrón Either<Failure, Success>.
/// Mapea excepciones a Failures según 00-CONVENTIONS.md.
class TiposRepositoryImpl implements TiposRepository {
  final TiposRemoteDataSource remoteDataSource;

  TiposRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<TipoModel>>> getTipos({
    String? search,
    bool? activoFilter,
  }) async {
    try {
      final result = await remoteDataSource.getTipos(
        search: search,
        activoFilter: activoFilter,
      );
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
  Future<Either<Failure, TipoModel>> createTipo({
    required String nombre,
    String? descripcion,
    required String codigo,
    String? imagenUrl,
  }) async {
    try {
      final result = await remoteDataSource.createTipo(
        nombre: nombre,
        descripcion: descripcion,
        codigo: codigo,
        imagenUrl: imagenUrl,
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
  Future<Either<Failure, TipoModel>> updateTipo({
    required String id,
    required String nombre,
    String? descripcion,
    String? imagenUrl,
    required bool activo,
  }) async {
    try {
      final result = await remoteDataSource.updateTipo(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        imagenUrl: imagenUrl,
        activo: activo,
      );
      return Right(result);
    } on TipoNotFoundException catch (e) {
      return Left(TipoNotFoundFailure(e.message));
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
  Future<Either<Failure, TipoModel>> toggleTipoActivo(String id) async {
    try {
      final result = await remoteDataSource.toggleTipoActivo(id);
      return Right(result);
    } on TipoNotFoundException catch (e) {
      return Left(TipoNotFoundFailure(e.message));
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
  Future<Either<Failure, TipoModel>> getTipoDetail(String id) async {
    try {
      final result = await remoteDataSource.getTipoDetail(id);
      return Right(result);
    } on TipoNotFoundException catch (e) {
      return Left(TipoNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TipoModel>>> getTiposActivos() async {
    try {
      final result = await remoteDataSource.getTiposActivos();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }
}
