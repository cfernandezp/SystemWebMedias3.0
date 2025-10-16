import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/features/tipos_documento/data/models/tipo_documento_model.dart';

abstract class TipoDocumentoRemoteDataSource {
  Future<List<TipoDocumentoModel>> listarTiposDocumento({
    required bool incluirInactivos,
  });

  Future<TipoDocumentoModel> crearTipoDocumento({
    required String codigo,
    required String nombre,
    required String formato,
    required int longitudMinima,
    required int longitudMaxima,
  });

  Future<TipoDocumentoModel> actualizarTipoDocumento({
    required String id,
    required String codigo,
    required String nombre,
    required String formato,
    required int longitudMinima,
    required int longitudMaxima,
    required bool activo,
  });

  Future<void> eliminarTipoDocumento({
    required String id,
  });

  Future<bool> validarFormatoDocumento({
    required String tipoDocumentoId,
    required String numeroDocumento,
  });
}

class TipoDocumentoRemoteDataSourceImpl implements TipoDocumentoRemoteDataSource {
  final SupabaseClient supabase;

  TipoDocumentoRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<TipoDocumentoModel>> listarTiposDocumento({
    required bool incluirInactivos,
  }) async {
    try {
      final response = await supabase.rpc(
        'listar_tipos_documento',
        params: {'p_incluir_inactivos': incluirInactivos},
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;
        return data
            .map((json) => TipoDocumentoModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw ServerException(error['message'] as String? ?? 'Error al listar tipos de documento', 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión al listar tipos de documento: $e');
    }
  }

  @override
  Future<TipoDocumentoModel> crearTipoDocumento({
    required String codigo,
    required String nombre,
    required String formato,
    required int longitudMinima,
    required int longitudMaxima,
  }) async {
    try {
      final response = await supabase.rpc(
        'crear_tipo_documento',
        params: {
          'p_codigo': codigo,
          'p_nombre': nombre,
          'p_formato': formato,
          'p_longitud_minima': longitudMinima,
          'p_longitud_maxima': longitudMaxima,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return TipoDocumentoModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'missing_param') {
          throw ValidationException('Todos los campos son obligatorios', 400);
        } else if (hint == 'duplicate_codigo') {
          throw DuplicateCodigoException('Este código ya existe, ingresa otro', 409);
        } else if (hint == 'duplicate_nombre') {
          throw DuplicateNombreException('Ya existe un tipo de documento con este nombre', 409);
        } else if (hint == 'invalid_length') {
          throw InvalidLengthException('Longitud inválida', 400);
        }

        throw ServerException(error['message'] as String? ?? 'Error al crear tipo de documento', 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión al crear tipo de documento: $e');
    }
  }

  @override
  Future<TipoDocumentoModel> actualizarTipoDocumento({
    required String id,
    required String codigo,
    required String nombre,
    required String formato,
    required int longitudMinima,
    required int longitudMaxima,
    required bool activo,
  }) async {
    try {
      final response = await supabase.rpc(
        'actualizar_tipo_documento',
        params: {
          'p_id': id,
          'p_codigo': codigo,
          'p_nombre': nombre,
          'p_formato': formato,
          'p_longitud_minima': longitudMinima,
          'p_longitud_maxima': longitudMaxima,
          'p_activo': activo,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return TipoDocumentoModel.fromJson(result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'tipo_not_found') {
          throw TipoDocumentoNotFoundException('Tipo de documento no encontrado', 404);
        } else if (hint == 'duplicate_codigo') {
          throw DuplicateCodigoException('Este código ya existe, ingresa otro', 409);
        } else if (hint == 'duplicate_nombre') {
          throw DuplicateNombreException('Ya existe un tipo de documento con este nombre', 409);
        } else if (hint == 'invalid_length') {
          throw InvalidLengthException('Longitud inválida', 400);
        }

        throw ServerException(error['message'] as String? ?? 'Error al actualizar tipo de documento', 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión al actualizar tipo de documento: $e');
    }
  }

  @override
  Future<void> eliminarTipoDocumento({
    required String id,
  }) async {
    try {
      final response = await supabase.rpc(
        'eliminar_tipo_documento',
        params: {'p_id': id},
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return;
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'tipo_not_found') {
          throw TipoDocumentoNotFoundException('Tipo de documento no encontrado', 404);
        } else if (hint == 'tipo_en_uso') {
          final message = error['message'] as String? ?? 'Tipo de documento en uso';
          throw TipoEnUsoException(message, 400);
        }

        throw ServerException(error['message'] as String? ?? 'Error al eliminar tipo de documento', 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión al eliminar tipo de documento: $e');
    }
  }

  @override
  Future<bool> validarFormatoDocumento({
    required String tipoDocumentoId,
    required String numeroDocumento,
  }) async {
    try {
      final response = await supabase.rpc(
        'validar_formato_documento',
        params: {
          'p_tipo_documento_id': tipoDocumentoId,
          'p_numero_documento': numeroDocumento,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        return data['valido'] as bool? ?? false;
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'missing_param') {
          throw ValidationException('Tipo de documento y número son obligatorios', 400);
        } else if (hint == 'tipo_not_found') {
          throw TipoDocumentoNotFoundException('Tipo de documento no encontrado', 404);
        } else if (hint == 'invalid_length') {
          throw InvalidLengthException('Longitud de documento inválida', 400);
        } else if (hint == 'invalid_format') {
          throw InvalidFormatException('Formato de documento inválido', 400);
        }

        throw ServerException(error['message'] as String? ?? 'Error al validar formato', 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión al validar formato: $e');
    }
  }
}
