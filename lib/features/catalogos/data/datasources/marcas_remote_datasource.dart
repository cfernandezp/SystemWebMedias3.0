import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/features/catalogos/data/models/marca_model.dart';

/// Abstract DataSource para operaciones de marcas
abstract class MarcasRemoteDataSource {
  /// HU-001: Obtener todas las marcas
  Future<List<MarcaModel>> getMarcas();

  /// HU-001: Crear nueva marca
  Future<MarcaModel> createMarca({
    required String nombre,
    required String codigo,
    required bool activo,
  });

  /// HU-001: Actualizar marca existente
  Future<MarcaModel> updateMarca({
    required String id,
    required String nombre,
    required bool activo,
  });

  /// HU-001: Activar/desactivar marca
  Future<MarcaModel> toggleMarca(String id);
}

/// Implementación usando Supabase RPC Functions
class MarcasRemoteDataSourceImpl implements MarcasRemoteDataSource {
  final SupabaseClient supabase;

  MarcasRemoteDataSourceImpl({
    required this.supabase,
  });

  @override
  Future<List<MarcaModel>> getMarcas() async {
    try {
      print('🔵 Llamando a get_marcas()');

      final response = await supabase.rpc('get_marcas');
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de get_marcas');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;
        print('✅ Marcas obtenidas: ${data.length}');

        return data
            .map((json) => MarcaModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final message = error['message'] as String;

        print('❌ Error en get_marcas - Message: $message');
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en getMarcas: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<MarcaModel> createMarca({
    required String nombre,
    required String codigo,
    required bool activo,
  }) async {
    try {
      print('🔵 Llamando a create_marca con nombre: $nombre, codigo: $codigo');

      final response = await supabase.rpc('create_marca', params: {
        'p_nombre': nombre,
        'p_codigo': codigo,
        'p_activo': activo,
      });
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de create_marca');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        print('✅ Marca creada exitosamente');
        return MarcaModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        print('❌ Error en create_marca - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas
        if (hint == 'duplicate_codigo') {
          throw DuplicateCodigoException(message);
        } else if (hint == 'duplicate_nombre') {
          throw DuplicateNombreException(message);
        } else if (hint == 'invalid_codigo_length' || hint == 'invalid_codigo_format') {
          throw InvalidCodigoException(message);
        } else if (hint == 'missing_nombre' || hint == 'missing_codigo') {
          throw ValidationException(message, 400);
        } else if (hint == 'invalid_nombre_length') {
          throw ValidationException(message, 400);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en createMarca: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<MarcaModel> updateMarca({
    required String id,
    required String nombre,
    required bool activo,
  }) async {
    try {
      print('🔵 Llamando a update_marca con id: $id, nombre: $nombre');

      final response = await supabase.rpc('update_marca', params: {
        'p_id': id,
        'p_nombre': nombre,
        'p_activo': activo,
      });
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de update_marca');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        print('✅ Marca actualizada exitosamente');
        return MarcaModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        print('❌ Error en update_marca - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas
        if (hint == 'marca_not_found') {
          throw MarcaNotFoundException(message);
        } else if (hint == 'duplicate_nombre') {
          throw DuplicateNombreException(message);
        } else if (hint == 'missing_nombre') {
          throw ValidationException(message, 400);
        } else if (hint == 'invalid_nombre_length') {
          throw ValidationException(message, 400);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en updateMarca: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<MarcaModel> toggleMarca(String id) async {
    try {
      print('🔵 Llamando a toggle_marca con id: $id');

      final response = await supabase.rpc('toggle_marca', params: {
        'p_id': id,
      });
      final result = response as Map<String, dynamic>;

      print('🔵 Respuesta recibida de toggle_marca');
      print('🔵 Success: ${result['success']}');

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final activo = data['activo'] as bool;
        print('✅ Marca ${activo ? 'reactivada' : 'desactivada'} exitosamente');

        return MarcaModel.fromJson(data);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        print('❌ Error en toggle_marca - Hint: $hint, Message: $message');

        // Mapear hints a excepciones específicas
        if (hint == 'marca_not_found') {
          throw MarcaNotFoundException(message);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      print('❌ Exception en toggleMarca: $e');
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }
}
