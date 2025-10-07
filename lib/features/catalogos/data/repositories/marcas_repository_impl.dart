import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/catalogos/data/datasources/marcas_remote_datasource.dart';
import 'package:system_web_medias/features/catalogos/data/models/marca_model.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/marcas_repository.dart';

/// Implementación del Repository de Marcas
class MarcasRepositoryImpl implements MarcasRepository {
  final MarcasRemoteDataSource remoteDataSource;

  MarcasRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<MarcaModel>>> getMarcas() async {
    try {
      final marcas = await remoteDataSource.getMarcas();
      return Right(marcas);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MarcaModel>> createMarca({
    required String nombre,
    required String codigo,
    required bool activo,
  }) async {
    try {
      final marca = await remoteDataSource.createMarca(
        nombre: nombre,
        codigo: codigo,
        activo: activo,
      );
      return Right(marca);
    } on DuplicateCodigoException catch (e) {
      return Left(DuplicateCodigoFailure(e.message));
    } on DuplicateNombreException catch (e) {
      return Left(DuplicateNombreFailure(e.message));
    } on InvalidCodigoException catch (e) {
      return Left(InvalidCodigoFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MarcaModel>> updateMarca({
    required String id,
    required String nombre,
    required bool activo,
  }) async {
    try {
      final marca = await remoteDataSource.updateMarca(
        id: id,
        nombre: nombre,
        activo: activo,
      );
      return Right(marca);
    } on MarcaNotFoundException catch (e) {
      return Left(MarcaNotFoundFailure(e.message));
    } on DuplicateNombreException catch (e) {
      return Left(DuplicateNombreFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MarcaModel>> toggleMarca(String id) async {
    try {
      final marca = await remoteDataSource.toggleMarca(id);
      return Right(marca);
    } on MarcaNotFoundException catch (e) {
      return Left(MarcaNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
