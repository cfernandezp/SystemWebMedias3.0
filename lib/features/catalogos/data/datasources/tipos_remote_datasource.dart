import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/tipo_model.dart';

/// DataSource remoto para gestión de tipos.
///
/// Implementa llamadas RPC a Supabase según E002-HU-003_IMPLEMENTATION.md (Backend).
/// Maneja errores con hints del backend según 00-CONVENTIONS.md sección 3.2.
abstract class TiposRemoteDataSource {
  /// Llama RPC: get_tipos(p_search, p_activo_filter)
  /// Returns: List<TipoModel>
  Future<List<TipoModel>> getTipos({String? search, bool? activoFilter});

  /// Llama RPC: create_tipo(p_nombre, p_descripcion, p_codigo, p_imagen_url)
  /// Returns: TipoModel creado
  /// Throws: DuplicateCodeException, DuplicateNameException, ValidationException, UnauthorizedException
  /// Nota: User ID se obtiene automáticamente del token JWT via auth.uid()
  Future<TipoModel> createTipo({
    required String nombre,
    String? descripcion,
    required String codigo,
    String? imagenUrl,
  });

  /// Llama RPC: update_tipo(p_id, p_nombre, p_descripcion, p_imagen_url, p_activo)
  /// Returns: TipoModel actualizado
  /// Throws: TipoNotFoundException, DuplicateNameException, ValidationException, UnauthorizedException
  /// Nota: User ID se obtiene automáticamente del token JWT via auth.uid()
  Future<TipoModel> updateTipo({
    required String id,
    required String nombre,
    String? descripcion,
    String? imagenUrl,
    required bool activo,
  });

  /// Llama RPC: toggle_tipo_activo(p_id)
  /// Returns: TipoModel con estado cambiado + productos_count
  /// Throws: TipoNotFoundException, UnauthorizedException
  /// Nota: User ID se obtiene automáticamente del token JWT via auth.uid()
  Future<TipoModel> toggleTipoActivo(String id);

  /// Llama RPC: get_tipo_detalle(p_id)
  /// Returns: TipoModel con estadísticas completas
  /// Throws: TipoNotFoundException
  Future<TipoModel> getTipoDetail(String id);

  /// Llama RPC: get_tipos_activos()
  /// Returns: List<TipoModel> solo activos
  Future<List<TipoModel>> getTiposActivos();
}

class TiposRemoteDataSourceImpl implements TiposRemoteDataSource {
  final SupabaseClient supabase;

  TiposRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<TipoModel>> getTipos({String? search, bool? activoFilter}) async {
    try {
      final response = await supabase.rpc('get_tipos', params: {
        'p_search': search,
        'p_activo_filter': activoFilter,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;
        return data.map((json) => TipoModel.fromJson(json as Map<String, dynamic>)).toList();
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
  Future<TipoModel> createTipo({
    required String nombre,
    String? descripcion,
    required String codigo,
    String? imagenUrl,
  }) async {
    try {
      final response = await supabase.rpc('create_tipo', params: {
        'p_nombre': nombre,
        'p_descripcion': descripcion,
        'p_codigo': codigo,
        'p_imagen_url': imagenUrl,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return TipoModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        // Mapear hints a excepciones específicas según IMPLEMENTATION.md Backend
        if (hint == 'duplicate_codigo') {
          throw DuplicateCodeException(message, 409);
        } else if (hint == 'duplicate_nombre') {
          throw DuplicateNameException(message, 409);
        } else if (hint == 'unauthorized' || hint == 'not_authenticated') {
          throw UnauthorizedException(message, 401);
        } else if (hint?.contains('invalid') == true || hint?.contains('missing') == true) {
          throw ValidationException(message, 400);
        }

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<TipoModel> updateTipo({
    required String id,
    required String nombre,
    String? descripcion,
    String? imagenUrl,
    required bool activo,
  }) async {
    try {
      final response = await supabase.rpc('update_tipo', params: {
        'p_id': id,
        'p_nombre': nombre,
        'p_descripcion': descripcion,
        'p_imagen_url': imagenUrl,
        'p_activo': activo,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return TipoModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'tipo_not_found') {
          throw TipoNotFoundException(message, 404);
        } else if (hint == 'duplicate_nombre') {
          throw DuplicateNameException(message, 409);
        } else if (hint == 'unauthorized' || hint == 'not_authenticated') {
          throw UnauthorizedException(message, 401);
        } else if (hint?.contains('invalid') == true || hint?.contains('missing') == true) {
          throw ValidationException(message, 400);
        }

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<TipoModel> toggleTipoActivo(String id) async {
    try {
      final response = await supabase.rpc('toggle_tipo_activo', params: {
        'p_id': id,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return TipoModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'tipo_not_found') {
          throw TipoNotFoundException(message, 404);
        } else if (hint == 'unauthorized' || hint == 'not_authenticated') {
          throw UnauthorizedException(message, 401);
        }

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<TipoModel> getTipoDetail(String id) async {
    try {
      final response = await supabase.rpc('get_tipo_detalle', params: {
        'p_id': id,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return TipoModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'tipo_not_found') {
          throw TipoNotFoundException(message, 404);
        }

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<List<TipoModel>> getTiposActivos() async {
    try {
      final response = await supabase.rpc('get_tipos_activos');

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;
        return data.map((json) => TipoModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw ServerException(error['message'] as String, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }
}
