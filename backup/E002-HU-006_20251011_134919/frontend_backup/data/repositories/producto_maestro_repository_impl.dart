import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/data/datasources/producto_maestro_remote_datasource.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_filter_model.dart';
import 'package:system_web_medias/features/productos_maestros/domain/repositories/producto_maestro_repository.dart';

class ProductoMaestroRepositoryImpl implements ProductoMaestroRepository {
  final ProductoMaestroRemoteDatasource remoteDatasource;

  ProductoMaestroRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, ProductoMaestroModel>> crearProductoMaestro({
    required String marcaId,
    required String materialId,
    required String tipoId,
    required String sistemaTallaId,
    String? descripcion,
  }) async {
    try {
      final result = await remoteDatasource.crearProductoMaestro(
        marcaId: marcaId,
        materialId: materialId,
        tipoId: tipoId,
        sistemaTallaId: sistemaTallaId,
        descripcion: descripcion,
      );
      return Right(result);
    } on DuplicateCombinationException catch (e) {
      return Left(DuplicateCombinationFailure(e.message));
    } on DuplicateCombinationInactiveException catch (e) {
      return Left(
          DuplicateCombinationInactiveFailure(e.message, productoId: e.productoId));
    } on InactiveCatalogException catch (e) {
      return Left(InactiveCatalogFailure(e.message));
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
  Future<Either<Failure, List<ProductoMaestroModel>>>
      listarProductosMaestros({
    ProductoMaestroFilterModel? filtros,
  }) async {
    try {
      final result =
          await remoteDatasource.listarProductosMaestros(filtros: filtros);
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
  Future<Either<Failure, ProductoMaestroModel>> editarProductoMaestro({
    required String productoId,
    String? marcaId,
    String? materialId,
    String? tipoId,
    String? sistemaTallaId,
    String? descripcion,
  }) async {
    try {
      final result = await remoteDatasource.editarProductoMaestro(
        productoId: productoId,
        marcaId: marcaId,
        materialId: materialId,
        tipoId: tipoId,
        sistemaTallaId: sistemaTallaId,
        descripcion: descripcion,
      );
      return Right(result);
    } on HasDerivedArticlesException catch (e) {
      return Left(HasDerivedArticlesFailure(e.message, totalArticles: e.totalArticles));
    } on ProductoMaestroNotFoundException catch (e) {
      return Left(ProductoMaestroNotFoundFailure(e.message));
    } on InactiveCatalogException catch (e) {
      return Left(InactiveCatalogFailure(e.message));
    } on DuplicateCombinationException catch (e) {
      return Left(DuplicateCombinationFailure(e.message));
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
  Future<Either<Failure, void>> eliminarProductoMaestro(
      String productoId) async {
    try {
      await remoteDatasource.eliminarProductoMaestro(productoId);
      return const Right(null);
    } on HasDerivedArticlesException catch (e) {
      return Left(HasDerivedArticlesFailure(e.message, totalArticles: e.totalArticles));
    } on ProductoMaestroNotFoundException catch (e) {
      return Left(ProductoMaestroNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> desactivarProductoMaestro({
    required String productoId,
    required bool desactivarArticulos,
  }) async {
    try {
      final affectedArticles = await remoteDatasource.desactivarProductoMaestro(
        productoId: productoId,
        desactivarArticulos: desactivarArticulos,
      );
      return Right(affectedArticles);
    } on ProductoMaestroNotFoundException catch (e) {
      return Left(ProductoMaestroNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductoMaestroModel>> reactivarProductoMaestro(
      String productoId) async {
    try {
      final result =
          await remoteDatasource.reactivarProductoMaestro(productoId);
      return Right(result);
    } on InactiveCatalogException catch (e) {
      return Left(InactiveCatalogFailure(e.message));
    } on ProductoMaestroNotFoundException catch (e) {
      return Left(ProductoMaestroNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> validarCombinacionComercial({
    required String tipoId,
    required String sistemaTallaId,
  }) async {
    try {
      final warnings = await remoteDatasource.validarCombinacionComercial(
        tipoId: tipoId,
        sistemaTallaId: sistemaTallaId,
      );
      return Right(warnings);
    } on TipoNotFoundException catch (e) {
      return Left(TipoNotFoundFailure(e.message));
    } on SistemaNotFoundException catch (e) {
      return Left(SistemaNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
