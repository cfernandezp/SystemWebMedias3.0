import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/sistema_talla_model.dart';
import '../models/valor_talla_model.dart';
import '../models/create_sistema_talla_request.dart';
import '../models/update_sistema_talla_request.dart';

/// DataSource remoto para gestión de sistemas de tallas.
///
/// Implementa llamadas RPC a Supabase según E002-HU-004_IMPLEMENTATION.md (Backend).
/// Maneja errores con hints del backend según 00-CONVENTIONS.md sección 3.2.
abstract class SistemasTallaRemoteDataSource {
  /// Llama RPC: get_sistemas_talla(p_search, p_tipo_filter, p_activo_filter)
  /// Returns: List<SistemaTallaModel>
  Future<List<SistemaTallaModel>> getSistemasTalla({
    String? search,
    String? tipoFilter,
    bool? activoFilter,
  });

  /// Llama RPC: create_sistema_talla(p_nombre, p_tipo_sistema, p_descripcion, p_valores, p_activo)
  /// Returns: SistemaTallaModel creado
  /// Throws: DuplicateNameException, ValidationException, DuplicateValueException,
  ///         OverlappingRangesException, UnauthorizedException
  Future<SistemaTallaModel> createSistemaTalla(CreateSistemaTallaRequest request);

  /// Llama RPC: update_sistema_talla(p_id, p_nombre, p_descripcion, p_activo)
  /// Returns: SistemaTallaModel actualizado
  /// Throws: SistemaNotFoundException, DuplicateNameException, ValidationException, UnauthorizedException
  Future<SistemaTallaModel> updateSistemaTalla(UpdateSistemaTallaRequest request);

  /// Llama RPC: get_sistema_talla_valores(p_sistema_id)
  /// Returns: Map con 'sistema' y 'valores'
  /// Throws: SistemaNotFoundException
  Future<Map<String, dynamic>> getSistemaTallaValores(String sistemaId);

  /// Llama RPC: add_valor_talla(p_sistema_id, p_valor, p_orden)
  /// Returns: ValorTallaModel creado
  /// Throws: SistemaNotFoundException, DuplicateValueException, OverlappingRangesException,
  ///         ValidationException, UnauthorizedException
  Future<ValorTallaModel> addValorTalla(String sistemaId, String valor, int? orden);

  /// Llama RPC: update_valor_talla(p_valor_id, p_valor, p_orden)
  /// Returns: ValorTallaModel actualizado
  /// Throws: ValorNotFoundException, DuplicateValueException, OverlappingRangesException,
  ///         ValidationException, UnauthorizedException
  Future<ValorTallaModel> updateValorTalla(String valorId, String valor, int? orden);

  /// Llama RPC: delete_valor_talla(p_valor_id, p_force)
  /// Returns: void
  /// Throws: ValorNotFoundException, LastValueException, ValorUsedByProductsException, UnauthorizedException
  Future<void> deleteValorTalla(String valorId, bool force);

  /// Llama RPC: toggle_sistema_talla_activo(p_id)
  /// Returns: SistemaTallaModel con estado cambiado
  /// Throws: SistemaNotFoundException, UnauthorizedException
  Future<SistemaTallaModel> toggleSistemaTallaActivo(String id);
}

class SistemasTallaRemoteDataSourceImpl implements SistemasTallaRemoteDataSource {
  final SupabaseClient supabase;

  SistemasTallaRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<SistemaTallaModel>> getSistemasTalla({
    String? search,
    String? tipoFilter,
    bool? activoFilter,
  }) async {
    try {
      final response = await supabase.rpc('get_sistemas_talla', params: {
        'p_search': search,
        'p_tipo_filter': tipoFilter,
        'p_activo_filter': activoFilter,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;
        return data
            .map((json) => SistemaTallaModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw ServerException(error['message'] as String, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<SistemaTallaModel> createSistemaTalla(CreateSistemaTallaRequest request) async {
    try {
      final response = await supabase.rpc('create_sistema_talla', params: {
        'p_nombre': request.nombre,
        'p_tipo_sistema': request.tipoSistema,
        'p_descripcion': request.descripcion,
        'p_valores': request.valores,
        'p_activo': request.activo,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return SistemaTallaModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw _mapException(error);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<SistemaTallaModel> updateSistemaTalla(UpdateSistemaTallaRequest request) async {
    try {
      final response = await supabase.rpc('update_sistema_talla', params: {
        'p_id': request.id,
        'p_nombre': request.nombre,
        'p_descripcion': request.descripcion,
        'p_activo': request.activo,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return SistemaTallaModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw _mapException(error);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getSistemaTallaValores(String sistemaId) async {
    try {
      final response = await supabase.rpc('get_sistema_talla_valores', params: {
        'p_sistema_id': sistemaId,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        return {
          'sistema': SistemaTallaModel.fromJson(data['sistema'] as Map<String, dynamic>),
          'valores': (data['valores'] as List<dynamic>)
              .map((json) => ValorTallaModel.fromJson(json as Map<String, dynamic>))
              .toList(),
        };
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw _mapException(error);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ValorTallaModel> addValorTalla(String sistemaId, String valor, int? orden) async {
    try {
      final response = await supabase.rpc('add_valor_talla', params: {
        'p_sistema_id': sistemaId,
        'p_valor': valor,
        'p_orden': orden,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return ValorTallaModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw _mapException(error);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ValorTallaModel> updateValorTalla(String valorId, String valor, int? orden) async {
    try {
      final response = await supabase.rpc('update_valor_talla', params: {
        'p_valor_id': valorId,
        'p_valor': valor,
        'p_orden': orden,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return ValorTallaModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw _mapException(error);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<void> deleteValorTalla(String valorId, bool force) async {
    try {
      final response = await supabase.rpc('delete_valor_talla', params: {
        'p_valor_id': valorId,
        'p_force': force,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return;
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw _mapException(error);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<SistemaTallaModel> toggleSistemaTallaActivo(String id) async {
    try {
      final response = await supabase.rpc('toggle_sistema_talla_activo', params: {
        'p_id': id,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return SistemaTallaModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw _mapException(error);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  /// Mapea hints del backend a excepciones específicas
  Exception _mapException(Map<String, dynamic> error) {
    final hint = error['hint'] as String?;
    final message = error['message'] as String;

    switch (hint) {
      case 'missing_nombre':
      case 'missing_tipo_sistema':
      case 'missing_valores':
      case 'invalid_range_format':
      case 'invalid_range_order':
        return ValidationException(message, 400);

      case 'duplicate_nombre':
        return DuplicateNameException(message, 409);

      case 'duplicate_valor':
        return DuplicateValueException(message, 409);

      case 'overlapping_ranges':
        return OverlappingRangesException(message, 400);

      case 'unauthorized':
      case 'not_authenticated':
        return UnauthorizedException(message, 401);

      case 'last_value_cannot_delete':
        return LastValueException(message, 400);

      case 'valor_used_by_products':
        return ValorUsedByProductsException(message, 400);

      case 'sistema_not_found':
        return SistemaNotFoundException(message, 404);

      case 'valor_not_found':
        return ValorNotFoundException(message, 404);

      default:
        return ServerException(message, 500);
    }
  }
}
