import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/data/datasources/producto_maestro_remote_datasource.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_filter_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_completo_request_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_completo_response_model.dart';
import 'package:system_web_medias/features/productos_maestros/domain/repositories/producto_maestro_repository.dart';

class ProductoMaestroRepositoryImpl implements ProductoMaestroRepository {
  final ProductoMaestroRemoteDataSource remoteDataSource;

  ProductoMaestroRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> validarCombinacionComercial({
    required String tipoId,
    required String sistemaTallaId,
  }) async {
    try {
      final result = await remoteDataSource.validarCombinacionComercial(
        tipoId: tipoId,
        sistemaTallaId: sistemaTallaId,
      );
      return Right(result);
    } on TipoNotFoundException catch (e) {
      return Left(TipoNotFoundFailure(e.message));
    } on SistemaNotFoundException catch (e) {
      return Left(SistemaNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProductoMaestroModel>> crearProductoMaestro({
    required String marcaId,
    required String materialId,
    required String tipoId,
    required String sistemaTallaId,
    String? descripcion,
  }) async {
    try {
      final result = await remoteDataSource.crearProductoMaestro(
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
      return Left(DuplicateCombinationInactiveFailure(
        e.message,
        productoId: e.productoId,
      ));
    } on InactiveCatalogException catch (e) {
      return Left(InactiveCatalogFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ProductoMaestroModel>>> listarProductosMaestros({
    ProductoMaestroFilterModel? filtros,
  }) async {
    try {
      final result = await remoteDataSource.listarProductosMaestros(
        filtros: filtros,
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProductoMaestroModel>> editarProductoMaestro({
    required String productoId,
    String? descripcion,
  }) async {
    try {
      final result = await remoteDataSource.editarProductoMaestro(
        productoId: productoId,
        descripcion: descripcion,
      );
      return Right(result);
    } on HasDerivedArticlesException catch (e) {
      return Left(HasDerivedArticlesFailure(
        e.message,
        totalArticles: e.totalArticles,
      ));
    } on ProductoMaestroNotFoundException catch (e) {
      return Left(ProductoMaestroNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> eliminarProductoMaestro({
    required String productoId,
  }) async {
    try {
      await remoteDataSource.eliminarProductoMaestro(productoId: productoId);
      return const Right(null);
    } on HasDerivedArticlesException catch (e) {
      return Left(HasDerivedArticlesFailure(
        e.message,
        totalArticles: e.totalArticles,
      ));
    } on ProductoMaestroNotFoundException catch (e) {
      return Left(ProductoMaestroNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> desactivarProductoMaestro({
    required String productoId,
    required bool desactivarArticulos,
  }) async {
    try {
      final result = await remoteDataSource.desactivarProductoMaestro(
        productoId: productoId,
        desactivarArticulos: desactivarArticulos,
      );
      return Right(result);
    } on ProductoMaestroNotFoundException catch (e) {
      return Left(ProductoMaestroNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> reactivarProductoMaestro({
    required String productoId,
  }) async {
    try {
      await remoteDataSource.reactivarProductoMaestro(productoId: productoId);
      return const Right(null);
    } on InactiveCatalogException catch (e) {
      return Left(InactiveCatalogFailure(e.message));
    } on ProductoMaestroNotFoundException catch (e) {
      return Left(ProductoMaestroNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProductoCompletoResponseModel>> crearProductoCompleto(
    ProductoCompletoRequestModel request,
  ) async {
    try {
      final response = await remoteDataSource.crearProductoCompleto(request);
      return Right(response);
    } on DuplicateCombinationException catch (e) {
      return Left(DuplicateCombinationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on InactiveCatalogException catch (e) {
      return Left(InactiveCatalogFailure(e.message));
    } on ColorInactiveException catch (e) {
      return Left(ValidationFailure(e.message));
    } on DuplicateSkuException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
