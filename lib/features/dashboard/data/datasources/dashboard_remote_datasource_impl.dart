import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:system_web_medias/features/dashboard/data/models/vendedor_metrics_model.dart';
import 'package:system_web_medias/features/dashboard/data/models/gerente_metrics_model.dart';
import 'package:system_web_medias/features/dashboard/data/models/admin_metrics_model.dart';
import 'package:system_web_medias/features/dashboard/data/models/sales_chart_data_model.dart';
import 'package:system_web_medias/features/dashboard/data/models/top_producto_model.dart';
import 'package:system_web_medias/features/dashboard/data/models/top_vendedor_model.dart';
import 'package:system_web_medias/features/dashboard/data/models/transaccion_reciente_model.dart';
import 'package:system_web_medias/features/dashboard/data/models/producto_stock_bajo_model.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/sales_chart_data.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/top_producto.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/top_vendedor.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/transaccion_reciente.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/producto_stock_bajo.dart';

/// Implementación del datasource remoto de dashboard usando Supabase
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final SupabaseClient supabase;

  DashboardRemoteDataSourceImpl({required this.supabase});

  @override
  Future<DashboardMetrics> getMetrics(String userId) async {
    try {
      final response = await supabase.rpc('get_dashboard_metrics', params: {
        'p_user_id': userId,
      });

      // Validar response no nulo
      if (response == null) {
        throw ServerException('Response vacío', 500);
      }

      final result = response as Map<String, dynamic>;

      // Validar que 'success' exista
      if (!result.containsKey('success')) {
        throw ServerException('Formato de respuesta inválido', 500);
      }

      // Success
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final rol = data['rol'] as String;

        // Polimorfismo según rol
        switch (rol) {
          case 'VENDEDOR':
            return VendedorMetricsModel.fromJson(data);
          case 'GERENTE':
            return GerenteMetricsModel.fromJson(data);
          case 'ADMIN':
            return AdminMetricsModel.fromJson(data);
          default:
            throw ServerException('Rol no reconocido: $rol', 500);
        }
      }

      // Error
      final error = result['error'] as Map<String, dynamic>;
      throw _mapError(error);
    } on PostgrestException catch (e) {
      throw NetworkException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error inesperado: $e');
    }
  }

  @override
  Future<List<SalesChartData>> getSalesChart(String userId,
      {int months = 6}) async {
    try {
      final response = await supabase.rpc('get_sales_chart_data', params: {
        'p_user_id': userId,
        'p_months': months,
      });

      if (response == null) {
        throw ServerException('Response vacío', 500);
      }

      final result = response as Map<String, dynamic>;

      if (!result.containsKey('success')) {
        throw ServerException('Formato de respuesta inválido', 500);
      }

      if (result['success'] == true) {
        final data = result['data'] as List;
        return data
            .map((item) => SalesChartDataModel.fromJson(item))
            .toList();
      }

      final error = result['error'] as Map<String, dynamic>;
      throw _mapError(error);
    } on PostgrestException catch (e) {
      throw NetworkException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error inesperado: $e');
    }
  }

  @override
  Future<List<TopProducto>> getTopProductos(String userId,
      {int limit = 5}) async {
    try {
      final response = await supabase.rpc('get_top_productos', params: {
        'p_user_id': userId,
        'p_limit': limit,
      });

      if (response == null) {
        throw ServerException('Response vacío', 500);
      }

      final result = response as Map<String, dynamic>;

      if (!result.containsKey('success')) {
        throw ServerException('Formato de respuesta inválido', 500);
      }

      if (result['success'] == true) {
        final data = result['data'] as List;
        return data.map((item) => TopProductoModel.fromJson(item)).toList();
      }

      final error = result['error'] as Map<String, dynamic>;
      throw _mapError(error);
    } on PostgrestException catch (e) {
      throw NetworkException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error inesperado: $e');
    }
  }

  @override
  Future<List<TopVendedor>> getTopVendedores(String userId,
      {int limit = 5}) async {
    try {
      final response = await supabase.rpc('get_top_vendedores', params: {
        'p_user_id': userId,
        'p_limit': limit,
      });

      if (response == null) {
        throw ServerException('Response vacío', 500);
      }

      final result = response as Map<String, dynamic>;

      if (!result.containsKey('success')) {
        throw ServerException('Formato de respuesta inválido', 500);
      }

      if (result['success'] == true) {
        final data = result['data'] as List;
        return data.map((item) => TopVendedorModel.fromJson(item)).toList();
      }

      final error = result['error'] as Map<String, dynamic>;
      throw _mapError(error);
    } on PostgrestException catch (e) {
      throw NetworkException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error inesperado: $e');
    }
  }

  @override
  Future<List<TransaccionReciente>> getTransaccionesRecientes(String userId,
      {int limit = 5}) async {
    try {
      final response =
          await supabase.rpc('get_transacciones_recientes', params: {
        'p_user_id': userId,
        'p_limit': limit,
      });

      if (response == null) {
        throw ServerException('Response vacío', 500);
      }

      final result = response as Map<String, dynamic>;

      if (!result.containsKey('success')) {
        throw ServerException('Formato de respuesta inválido', 500);
      }

      if (result['success'] == true) {
        final data = result['data'] as List;
        return data
            .map((item) => TransaccionRecienteModel.fromJson(item))
            .toList();
      }

      final error = result['error'] as Map<String, dynamic>;
      throw _mapError(error);
    } on PostgrestException catch (e) {
      throw NetworkException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error inesperado: $e');
    }
  }

  @override
  Future<List<ProductoStockBajo>> getProductosStockBajo(String userId) async {
    try {
      final response = await supabase.rpc('get_productos_stock_bajo', params: {
        'p_user_id': userId,
      });

      if (response == null) {
        throw ServerException('Response vacío', 500);
      }

      final result = response as Map<String, dynamic>;

      if (!result.containsKey('success')) {
        throw ServerException('Formato de respuesta inválido', 500);
      }

      if (result['success'] == true) {
        final data = result['data'] as List;
        return data
            .map((item) => ProductoStockBajoModel.fromJson(item))
            .toList();
      }

      final error = result['error'] as Map<String, dynamic>;
      throw _mapError(error);
    } on PostgrestException catch (e) {
      throw NetworkException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error inesperado: $e');
    }
  }

  @override
  Future<void> refreshMetrics() async {
    try {
      await supabase.rpc('refresh_dashboard_metrics');
    } on PostgrestException catch (e) {
      throw NetworkException('Error al refrescar métricas: ${e.message}');
    } catch (e) {
      throw NetworkException('Error inesperado: $e');
    }
  }

  /// Mapea error de PostgreSQL a excepción Dart
  AppException _mapError(Map<String, dynamic> error) {
    final hint = error['hint'] as String?;
    final message = error['message'] as String;

    switch (hint) {
      case 'user_not_authorized':
        return UnauthorizedException(message, 403);

      case 'user_not_found':
        return NotFoundException(message, 404);

      case 'no_tienda_assigned':
      case 'invalid_role':
      case 'missing_param':
      case 'invalid_param':
        return ValidationException(message, 400);

      case 'forbidden':
        return ForbiddenException(message, 403);

      default:
        return ServerException(message, 500);
    }
  }
}
