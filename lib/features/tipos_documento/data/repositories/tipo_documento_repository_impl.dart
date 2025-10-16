import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/tipos_documento/data/datasources/tipo_documento_remote_datasource.dart';
import 'package:system_web_medias/features/tipos_documento/domain/entities/tipo_documento_entity.dart';
import 'package:system_web_medias/features/tipos_documento/domain/repositories/tipo_documento_repository.dart';

class TipoDocumentoRepositoryImpl implements TipoDocumentoRepository {
  final TipoDocumentoRemoteDataSource remoteDataSource;

  TipoDocumentoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TipoDocumentoEntity>>> listarTiposDocumento({
    required bool incluirInactivos,
  }) async {
    try {
      final result = await remoteDataSource.listarTiposDocumento(
        incluirInactivos: incluirInactivos,
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, TipoDocumentoEntity>> crearTipoDocumento({
    required String codigo,
    required String nombre,
    required String formato,
    required int longitudMinima,
    required int longitudMaxima,
  }) async {
    try {
      final result = await remoteDataSource.crearTipoDocumento(
        codigo: codigo,
        nombre: nombre,
        formato: formato,
        longitudMinima: longitudMinima,
        longitudMaxima: longitudMaxima,
      );
      return Right(result);
    } on DuplicateCodigoException catch (e) {
      return Left(DuplicateCodigoFailure(e.message));
    } on DuplicateNombreException catch (e) {
      return Left(DuplicateNombreFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on InvalidLengthException catch (e) {
      return Left(InvalidLengthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, TipoDocumentoEntity>> actualizarTipoDocumento({
    required String id,
    required String codigo,
    required String nombre,
    required String formato,
    required int longitudMinima,
    required int longitudMaxima,
    required bool activo,
  }) async {
    try {
      final result = await remoteDataSource.actualizarTipoDocumento(
        id: id,
        codigo: codigo,
        nombre: nombre,
        formato: formato,
        longitudMinima: longitudMinima,
        longitudMaxima: longitudMaxima,
        activo: activo,
      );
      return Right(result);
    } on TipoDocumentoNotFoundException catch (e) {
      return Left(TipoDocumentoNotFoundFailure(e.message));
    } on DuplicateCodigoException catch (e) {
      return Left(DuplicateCodigoFailure(e.message));
    } on DuplicateNombreException catch (e) {
      return Left(DuplicateNombreFailure(e.message));
    } on InvalidLengthException catch (e) {
      return Left(InvalidLengthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> eliminarTipoDocumento({
    required String id,
  }) async {
    try {
      await remoteDataSource.eliminarTipoDocumento(id: id);
      return const Right(null);
    } on TipoDocumentoNotFoundException catch (e) {
      return Left(TipoDocumentoNotFoundFailure(e.message));
    } on TipoEnUsoException catch (e) {
      return Left(TipoEnUsoFailure(e.message, personasCount: e.personasCount));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validarFormatoDocumento({
    required String tipoDocumentoId,
    required String numeroDocumento,
  }) async {
    try {
      final result = await remoteDataSource.validarFormatoDocumento(
        tipoDocumentoId: tipoDocumentoId,
        numeroDocumento: numeroDocumento,
      );
      return Right(result);
    } on TipoDocumentoNotFoundException catch (e) {
      return Left(TipoDocumentoNotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on InvalidLengthException catch (e) {
      return Left(InvalidLengthFailure(e.message));
    } on InvalidFormatException catch (e) {
      return Left(InvalidFormatFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }
}
