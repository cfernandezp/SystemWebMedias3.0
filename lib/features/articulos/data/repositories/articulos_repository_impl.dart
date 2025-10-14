import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/articulos/data/datasources/articulos_remote_datasource.dart';
import 'package:system_web_medias/features/articulos/data/models/articulo_model.dart';
import 'package:system_web_medias/features/articulos/data/models/filtros_articulos_model.dart';
import 'package:system_web_medias/features/articulos/domain/repositories/articulos_repository.dart';

class ArticulosRepositoryImpl implements ArticulosRepository {
  final ArticulosRemoteDataSource remoteDataSource;

  ArticulosRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> generarSku({
    required String productoMaestroId,
    required List<String> coloresIds,
  }) async {
    try {
      final result = await remoteDataSource.generarSku(
        productoMaestroId: productoMaestroId,
        coloresIds: coloresIds,
      );
      return Right(result);
    } on ProductoMaestroNotFoundException catch (e) {
      return Left(ProductoMaestroNotFoundFailure(e.message));
    } on ColorNotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
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
  Future<Either<Failure, Map<String, dynamic>>> validarSkuUnico({
    required String sku,
    String? articuloId,
  }) async {
    try {
      final result = await remoteDataSource.validarSkuUnico(
        sku: sku,
        articuloId: articuloId,
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ArticuloModel>> crearArticulo({
    required String productoMaestroId,
    required List<String> coloresIds,
    required double precio,
  }) async {
    try {
      final result = await remoteDataSource.crearArticulo(
        productoMaestroId: productoMaestroId,
        coloresIds: coloresIds,
        precio: precio,
      );
      return Right(result);
    } on InvalidColorCountException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ProductoMaestroNotFoundException catch (e) {
      return Left(ProductoMaestroNotFoundFailure(e.message));
    } on InactiveCatalogException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ColorInactiveException catch (e) {
      return Left(ValidationFailure(e.message));
    } on InvalidPriceException catch (e) {
      return Left(ValidationFailure(e.message));
    } on DuplicateSkuException catch (e) {
      return Left(ValidationFailure(e.message));
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
  Future<Either<Failure, List<ArticuloModel>>> listarArticulos({
    FiltrosArticulosModel? filtros,
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await remoteDataSource.listarArticulos(
        filtros: filtros,
        limit: limit,
        offset: offset,
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ArticuloModel>> obtenerArticulo({
    required String articuloId,
  }) async {
    try {
      final result = await remoteDataSource.obtenerArticulo(
        articuloId: articuloId,
      );
      return Right(result);
    } on ArticuloNotFoundException catch (e) {
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
  Future<Either<Failure, ArticuloModel>> editarArticulo({
    required String articuloId,
    double? precio,
    bool? activo,
  }) async {
    try {
      final result = await remoteDataSource.editarArticulo(
        articuloId: articuloId,
        precio: precio,
        activo: activo,
      );
      return Right(result);
    } on ArticuloNotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on InvalidPriceException catch (e) {
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
  Future<Either<Failure, void>> eliminarArticulo({
    required String articuloId,
  }) async {
    try {
      await remoteDataSource.eliminarArticulo(articuloId: articuloId);
      return const Right(null);
    } on ArticuloNotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ArticuloHasStockException catch (e) {
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
  Future<Either<Failure, Map<String, dynamic>>> desactivarArticulo({
    required String articuloId,
  }) async {
    try {
      final result = await remoteDataSource.desactivarArticulo(
        articuloId: articuloId,
      );
      return Right(result);
    } on ArticuloNotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}