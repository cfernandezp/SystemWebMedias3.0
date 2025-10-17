import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/features/personas/data/models/persona_model.dart';

abstract class PersonaRemoteDataSource {
  Future<PersonaModel> buscarPersonaPorDocumento({
    required String tipoDocumentoId,
    required String numeroDocumento,
  });

  Future<PersonaModel> crearPersona({
    required String tipoDocumentoId,
    required String numeroDocumento,
    required String tipoPersona,
    String? nombreCompleto,
    String? razonSocial,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
  });

  Future<Map<String, dynamic>> listarPersonas({
    String? tipoDocumentoId,
    String? tipoPersona,
    bool? activo,
    String? busqueda,
    int limit = 50,
    int offset = 0,
  });

  Future<PersonaModel> obtenerPersona(String personaId);

  Future<PersonaModel> editarPersona({
    required String personaId,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
  });

  Future<PersonaModel> desactivarPersona({
    required String personaId,
    bool desactivarRoles = false,
  });

  Future<Map<String, dynamic>> eliminarPersona(String personaId);

  Future<PersonaModel> reactivarPersona({
    required String personaId,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
  });
}

class PersonaRemoteDataSourceImpl implements PersonaRemoteDataSource {
  final SupabaseClient supabase;

  PersonaRemoteDataSourceImpl({required this.supabase});

  @override
  Future<PersonaModel> buscarPersonaPorDocumento({
    required String tipoDocumentoId,
    required String numeroDocumento,
  }) async {
    try {
      final response = await supabase.rpc(
        'buscar_persona_por_documento',
        params: {
          'p_tipo_documento_id': tipoDocumentoId,
          'p_numero_documento': numeroDocumento,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return PersonaModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'not_found') {
          throw PersonaNotFoundException(error['message'], 404);
        } else if (hint == 'missing_param') {
          throw ValidationException(error['message'], 400);
        }
        throw ServerException(error['message'], 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<PersonaModel> crearPersona({
    required String tipoDocumentoId,
    required String numeroDocumento,
    required String tipoPersona,
    String? nombreCompleto,
    String? razonSocial,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
  }) async {
    try {
      final response = await supabase.rpc(
        'crear_persona',
        params: {
          'p_tipo_documento_id': tipoDocumentoId,
          'p_numero_documento': numeroDocumento,
          'p_tipo_persona': tipoPersona,
          'p_nombre_completo': nombreCompleto,
          'p_razon_social': razonSocial,
          'p_email': email,
          'p_celular': celular,
          'p_telefono': telefono,
          'p_direccion': direccion,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return PersonaModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'duplicate_document') {
          throw DuplicatePersonaException(error['message'], 409);
        } else if (hint == 'invalid_document_format') {
          throw InvalidDocumentFormatException(error['message'], 400);
        } else if (hint == 'invalid_document_for_person_type') {
          throw InvalidDocumentForPersonTypeException(error['message'], 400);
        } else if (hint == 'missing_nombre') {
          throw MissingNombreException(error['message'], 400);
        } else if (hint == 'missing_razon_social') {
          throw MissingRazonSocialException(error['message'], 400);
        } else if (hint == 'invalid_email') {
          throw InvalidEmailException(error['message'], 400);
        } else if (hint == 'invalid_phone') {
          throw InvalidPhoneException(error['message'], 400);
        }
        throw ServerException(error['message'], 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> listarPersonas({
    String? tipoDocumentoId,
    String? tipoPersona,
    bool? activo,
    String? busqueda,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await supabase.rpc(
        'listar_personas',
        params: {
          'p_tipo_documento_id': tipoDocumentoId,
          'p_tipo_persona': tipoPersona,
          'p_activo': activo,
          'p_busqueda': busqueda,
          'p_limit': limit,
          'p_offset': offset,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>)
            .map((item) => PersonaModel.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'items': items,
          'total': data['total'] as int,
          'limit': data['limit'] as int,
          'offset': data['offset'] as int,
          'hasMore': data['has_more'] as bool,
        };
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw ServerException(error['message'], 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<PersonaModel> obtenerPersona(String personaId) async {
    try {
      final response = await supabase.rpc(
        'obtener_persona',
        params: {
          'p_persona_id': personaId,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return PersonaModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'not_found') {
          throw PersonaNotFoundException(error['message'], 404);
        }
        throw ServerException(error['message'], 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<PersonaModel> editarPersona({
    required String personaId,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
  }) async {
    try {
      final response = await supabase.rpc(
        'editar_persona',
        params: {
          'p_persona_id': personaId,
          'p_email': email,
          'p_celular': celular,
          'p_telefono': telefono,
          'p_direccion': direccion,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return PersonaModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'not_found') {
          throw PersonaNotFoundException(error['message'], 404);
        } else if (hint == 'invalid_email') {
          throw InvalidEmailException(error['message'], 400);
        } else if (hint == 'invalid_phone') {
          throw InvalidPhoneException(error['message'], 400);
        }
        throw ServerException(error['message'], 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<PersonaModel> desactivarPersona({
    required String personaId,
    bool desactivarRoles = false,
  }) async {
    try {
      final response = await supabase.rpc(
        'desactivar_persona',
        params: {
          'p_persona_id': personaId,
          'p_desactivar_roles': desactivarRoles,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return PersonaModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'not_found') {
          throw PersonaNotFoundException(error['message'], 404);
        }
        throw ServerException(error['message'], 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> eliminarPersona(String personaId) async {
    try {
      final response = await supabase.rpc(
        'eliminar_persona',
        params: {
          'p_persona_id': personaId,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return {
          'success': true,
          'message': result['data']['message'] ?? 'Persona eliminada correctamente',
        };
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'not_found') {
          throw PersonaNotFoundException(error['message'], 404);
        } else if (hint == 'has_transactions') {
          throw HasTransactionsException(error['message'], 403);
        }
        throw ServerException(error['message'], 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<PersonaModel> reactivarPersona({
    required String personaId,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
  }) async {
    try {
      final response = await supabase.rpc(
        'reactivar_persona',
        params: {
          'p_persona_id': personaId,
          'p_email': email,
          'p_celular': celular,
          'p_telefono': telefono,
          'p_direccion': direccion,
        },
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return PersonaModel.fromJson(result['data']);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'not_found') {
          throw PersonaNotFoundException(error['message'], 404);
        } else if (hint == 'already_active') {
          throw AlreadyActiveException(error['message'], 400);
        }
        throw ServerException(error['message'], 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }
}
