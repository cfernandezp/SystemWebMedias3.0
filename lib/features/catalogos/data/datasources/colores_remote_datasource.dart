import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';
import 'package:system_web_medias/features/catalogos/data/models/estadisticas_colores_model.dart';

abstract class ColoresRemoteDataSource {
  Future<List<ColorModel>> listarColores();

  Future<ColorModel> crearColor({
    required String nombre,
    required List<String> codigosHex,
  });

  Future<ColorModel> editarColor({
    required String id,
    required String nombre,
    required List<String> codigosHex,
  });

  Future<Map<String, dynamic>> eliminarColor(String id);

  Future<List<Map<String, dynamic>>> obtenerProductosPorColor({
    required String colorNombre,
    required bool exacto,
  });

  Future<List<Map<String, dynamic>>> filtrarProductosPorCombinacion({
    required List<String> colores,
  });

  Future<EstadisticasColoresModel> obtenerEstadisticas();
}

class ColoresRemoteDataSourceImpl implements ColoresRemoteDataSource {
  final SupabaseClient supabase;

  ColoresRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<ColorModel>> listarColores() async {
    try {
      final response = await supabase.rpc('listar_colores');
      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;

        return data
            .map((json) => ColorModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final message = error['message'] as String;

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ColorModel> crearColor({
    required String nombre,
    required List<String> codigosHex,
  }) async {
    try {
      final response = await supabase.rpc('crear_color', params: {
        'p_nombre': nombre,
        'p_codigos_hex': codigosHex,
      });
      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return ColorModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'duplicate_name') {
          throw DuplicateNombreException(message);
        } else if (hint == 'invalid_hex_format') {
          throw InvalidHexFormatException(message);
        } else if (hint == 'invalid_name_length') {
          throw ValidationException(message, 400);
        } else if (hint == 'invalid_name_chars') {
          throw ValidationException(message, 400);
        } else if (hint == 'invalid_color_count') {
          throw ValidationException(message, 400);
        } else if (hint == 'unauthorized') {
          throw UnauthorizedException(message);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ColorModel> editarColor({
    required String id,
    required String nombre,
    required List<String> codigosHex,
  }) async {
    try {
      final response = await supabase.rpc('editar_color', params: {
        'p_id': id,
        'p_nombre': nombre,
        'p_codigos_hex': codigosHex,
      });
      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return ColorModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'color_not_found') {
          throw ColorNotFoundException(message);
        } else if (hint == 'duplicate_name') {
          throw DuplicateNombreException(message);
        } else if (hint == 'invalid_hex_format') {
          throw InvalidHexFormatException(message);
        } else if (hint == 'invalid_color_count') {
          throw ValidationException(message, 400);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> eliminarColor(String id) async {
    try {
      final response = await supabase.rpc('eliminar_color', params: {
        'p_id': id,
      });
      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final deleted = data['deleted'] as bool;
        final deactivated = data['deactivated'] as bool;

        return {
          'deleted': deleted,
          'deactivated': deactivated,
          'productos_count': data['productos_count'] as int,
        };
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'color_not_found') {
          throw ColorNotFoundException(message);
        } else if (hint == 'has_products_use_deactivate') {
          throw ColorInUseException(message);
        } else if (hint == 'unauthorized') {
          throw UnauthorizedException(message);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> obtenerProductosPorColor({
    required String colorNombre,
    required bool exacto,
  }) async {
    try {
      final response = await supabase.rpc('obtener_productos_por_color', params: {
        'p_color_nombre': colorNombre,
        'p_exacto': exacto,
      });
      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;

        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'color_not_found') {
          throw ColorNotFoundException(message);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> filtrarProductosPorCombinacion({
    required List<String> colores,
  }) async {
    try {
      final response = await supabase.rpc('filtrar_productos_por_combinacion', params: {
        'p_colores': colores,
      });
      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;

        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'missing_param') {
          throw ValidationException(message, 400);
        }
        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<EstadisticasColoresModel> obtenerEstadisticas() async {
    try {
      final response = await supabase.rpc('estadisticas_colores');
      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return EstadisticasColoresModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final message = error['message'] as String;

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }
}
