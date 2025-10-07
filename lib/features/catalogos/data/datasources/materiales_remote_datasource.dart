import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/material_model.dart';

/// DataSource remoto para gestión de materiales.
///
/// Implementa llamadas RPC a Supabase según E002-HU-002_IMPLEMENTATION.md (Backend).
/// Maneja errores con hints del backend según 00-CONVENTIONS.md sección 3.2.
abstract class MaterialesRemoteDataSource {
  /// Llama RPC: listar_materiales()
  /// Returns: List<MaterialModel>
  Future<List<MaterialModel>> listarMateriales();

  /// Llama RPC: crear_material(p_nombre, p_descripcion, p_codigo)
  /// Returns: MaterialModel creado
  /// Throws: DuplicateCodeException, DuplicateNameException, ValidationException, UnauthorizedException
  /// Nota: User ID se obtiene automáticamente del token JWT via auth.uid()
  Future<MaterialModel> crearMaterial({
    required String nombre,
    String? descripcion,
    required String codigo,
  });

  /// Llama RPC: actualizar_material(p_id, p_nombre, p_descripcion, p_activo)
  /// Returns: MaterialModel actualizado
  /// Throws: MaterialNotFoundException, DuplicateNameException, ValidationException, UnauthorizedException
  /// Nota: User ID se obtiene automáticamente del token JWT via auth.uid()
  Future<MaterialModel> actualizarMaterial({
    required String id,
    required String nombre,
    String? descripcion,
    required bool activo,
  });

  /// Llama RPC: toggle_material_activo(p_id)
  /// Returns: MaterialModel con estado cambiado
  /// Throws: MaterialNotFoundException, UnauthorizedException
  /// Nota: User ID se obtiene automáticamente del token JWT via auth.uid()
  Future<MaterialModel> toggleMaterialActivo({
    required String id,
  });

  /// Llama RPC: buscar_materiales(p_query)
  /// Returns: List<MaterialModel> con resultados de búsqueda
  Future<List<MaterialModel>> buscarMateriales(String query);

  /// Llama RPC: obtener_detalle_material(p_id)
  /// Returns: Map con detalle completo + estadísticas
  /// Throws: MaterialNotFoundException
  Future<Map<String, dynamic>> obtenerDetalleMaterial(String id);
}

class MaterialesRemoteDataSourceImpl implements MaterialesRemoteDataSource {
  final SupabaseClient supabase;

  MaterialesRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<MaterialModel>> listarMateriales() async {
    try {
      final response = await supabase.rpc('listar_materiales');

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;
        return data.map((json) => MaterialModel.fromJson(json as Map<String, dynamic>)).toList();
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
  Future<MaterialModel> crearMaterial({
    required String nombre,
    String? descripcion,
    required String codigo,
  }) async {
    try {
      final response = await supabase.rpc('crear_material', params: {
        'p_nombre': nombre,
        'p_descripcion': descripcion,
        'p_codigo': codigo,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return MaterialModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        // Mapear hints a excepciones específicas según IMPLEMENTATION.md Backend
        if (hint == 'duplicate_code') {
          throw DuplicateCodeException(message, 409);
        } else if (hint == 'duplicate_name') {
          throw DuplicateNameException(message, 409);
        } else if (hint == 'unauthorized') {
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
  Future<MaterialModel> actualizarMaterial({
    required String id,
    required String nombre,
    String? descripcion,
    required bool activo,
  }) async {
    try {
      final response = await supabase.rpc('actualizar_material', params: {
        'p_id': id,
        'p_nombre': nombre,
        'p_descripcion': descripcion,
        'p_activo': activo,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return MaterialModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'material_not_found') {
          throw MaterialNotFoundException(message, 404);
        } else if (hint == 'duplicate_name') {
          throw DuplicateNameException(message, 409);
        } else if (hint == 'unauthorized') {
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
  Future<MaterialModel> toggleMaterialActivo({
    required String id,
  }) async {
    try {
      final response = await supabase.rpc('toggle_material_activo', params: {
        'p_id': id,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return MaterialModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'material_not_found') {
          throw MaterialNotFoundException(message, 404);
        } else if (hint == 'unauthorized') {
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
  Future<List<MaterialModel>> buscarMateriales(String query) async {
    try {
      final response = await supabase.rpc('buscar_materiales', params: {
        'p_query': query,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;
        return data.map((json) => MaterialModel.fromJson(json as Map<String, dynamic>)).toList();
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
  Future<Map<String, dynamic>> obtenerDetalleMaterial(String id) async {
    try {
      final response = await supabase.rpc('obtener_detalle_material', params: {
        'p_id': id,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return result['data'] as Map<String, dynamic>;
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'material_not_found') {
          throw MaterialNotFoundException(message, 404);
        }

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }
}
