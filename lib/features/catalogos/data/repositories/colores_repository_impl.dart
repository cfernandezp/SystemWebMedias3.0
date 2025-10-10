import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/catalogos/data/datasources/colores_remote_datasource.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';
import 'package:system_web_medias/features/catalogos/data/models/estadisticas_colores_model.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/colores_repository.dart';

class ColoresRepositoryImpl implements ColoresRepository {
  final ColoresRemoteDataSource remoteDataSource;

  ColoresRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ColorModel>>> getColores() async {
    try {
      final colores = await remoteDataSource.listarColores();
      return Right(colores);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ColorModel>> createColor({
    required String nombre,
    required List<String> codigosHex,
  }) async {
    try {
      final color = await remoteDataSource.crearColor(
        nombre: nombre,
        codigosHex: codigosHex,
      );
      return Right(color);
    } on DuplicateNombreException catch (e) {
      return Left(DuplicateNombreFailure(e.message));
    } on InvalidHexFormatException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ColorModel>> updateColor({
    required String id,
    required String nombre,
    required List<String> codigosHex,
  }) async {
    try {
      final color = await remoteDataSource.editarColor(
        id: id,
        nombre: nombre,
        codigosHex: codigosHex,
      );
      return Right(color);
    } on ColorNotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on DuplicateNombreException catch (e) {
      return Left(DuplicateNombreFailure(e.message));
    } on InvalidHexFormatException catch (e) {
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
  Future<Either<Failure, Map<String, dynamic>>> deleteColor(String id) async {
    try {
      final result = await remoteDataSource.eliminarColor(id);
      return Right(result);
    } on ColorNotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ColorInUseException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getProductosByColor({
    required String colorNombre,
    required bool exacto,
  }) async {
    try {
      final productos = await remoteDataSource.obtenerProductosPorColor(
        colorNombre: colorNombre,
        exacto: exacto,
      );
      return Right(productos);
    } on ColorNotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> filterProductosByCombinacion({
    required List<String> colores,
  }) async {
    try {
      final productos = await remoteDataSource.filtrarProductosPorCombinacion(
        colores: colores,
      );
      return Right(productos);
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
  Future<Either<Failure, EstadisticasColoresModel>> getEstadisticas() async {
    try {
      final estadisticas = await remoteDataSource.obtenerEstadisticas();
      return Right(estadisticas);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
