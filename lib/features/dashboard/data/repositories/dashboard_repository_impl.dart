import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/sales_chart_data.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/top_producto.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/top_vendedor.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/transaccion_reciente.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/producto_stock_bajo.dart';
import 'package:system_web_medias/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Implementación del repository de dashboard
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, DashboardMetrics>> getMetrics(String userId) async {
    try {
      final metrics = await remoteDataSource.getMetrics(userId);
      return Right(metrics);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SalesChartData>>> getSalesChart(
    String userId, {
    int months = 6,
  }) async {
    try {
      final chartData =
          await remoteDataSource.getSalesChart(userId, months: months);
      return Right(chartData);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
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
  Future<Either<Failure, List<TopProducto>>> getTopProductos(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final productos =
          await remoteDataSource.getTopProductos(userId, limit: limit);
      return Right(productos);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
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
  Future<Either<Failure, List<TopVendedor>>> getTopVendedores(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final vendedores =
          await remoteDataSource.getTopVendedores(userId, limit: limit);
      return Right(vendedores);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
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
  Future<Either<Failure, List<TransaccionReciente>>> getTransaccionesRecientes(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final transacciones = await remoteDataSource.getTransaccionesRecientes(
          userId,
          limit: limit);
      return Right(transacciones);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
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
  Future<Either<Failure, List<ProductoStockBajo>>> getProductosStockBajo(
    String userId,
  ) async {
    try {
      final productos = await remoteDataSource.getProductosStockBajo(userId);
      return Right(productos);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
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
  Future<Either<Failure, void>> refreshMetrics() async {
    try {
      await remoteDataSource.refreshMetrics();
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }
}
