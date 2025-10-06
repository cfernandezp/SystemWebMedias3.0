import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/features/menu/data/models/menu_response_model.dart';

/// Abstract contract para data source remoto de menú
abstract class MenuRemoteDataSource {
  /// Obtener opciones de menú según rol del usuario
  Future<MenuResponseModel> getMenuOptions(String userId);

  /// Actualizar preferencia de sidebar (expandido/colapsado)
  Future<void> updateSidebarPreference(String userId, bool collapsed);
}

/// Implementation que consume funciones PostgreSQL vía Supabase RPC
class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final SupabaseClient supabaseClient;

  const MenuRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<MenuResponseModel> getMenuOptions(String userId) async {
    try {
      // Llamar función PostgreSQL: get_menu_options(p_user_id)
      final response = await supabaseClient.rpc(
        'get_menu_options',
        params: {'p_user_id': userId},
      );

      // Validar respuesta
      if (response == null) {
        throw ServerException('Respuesta vacía del servidor', 500);
      }

      // Verificar estructura de respuesta
      if (response is! Map<String, dynamic>) {
        throw ServerException('Formato de respuesta inválido', 500);
      }

      // Verificar campo 'success'
      final success = response['success'] as bool?;
      if (success != true) {
        final error = response['error'] as Map<String, dynamic>?;
        final errorMessage = error?['message'] as String? ?? 'Error desconocido';
        final errorCode = error?['code'] as String? ?? 'unknown';

        // Mapear errores según hint
        switch (errorCode) {
          case 'user_not_authorized':
            throw ForbiddenException(errorMessage);
          case 'user_not_found':
            throw NotFoundException(errorMessage);
          case 'invalid_role':
            throw ValidationException(errorMessage);
          case 'menu_empty':
            throw NotFoundException('No hay menús disponibles para tu rol');
          default:
            throw ServerException(errorMessage, 500);
        }
      }

      // Extraer data y mapear a modelo
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw ServerException('Campo data vacío en respuesta', 500);
      }

      return MenuResponseModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException('Error de base de datos: ${e.message}', e.code != null ? int.tryParse(e.code!) : 500);
    } on AppException {
      rethrow; // Re-lanzar excepciones personalizadas
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}', 500);
    }
  }

  @override
  Future<void> updateSidebarPreference(String userId, bool collapsed) async {
    try {
      // Llamar función PostgreSQL: update_sidebar_preference(p_user_id, p_collapsed)
      final response = await supabaseClient.rpc(
        'update_sidebar_preference',
        params: {
          'p_user_id': userId,
          'p_collapsed': collapsed,
        },
      );

      // Validar respuesta
      if (response == null) {
        throw ServerException('Respuesta vacía del servidor', 500);
      }

      if (response is! Map<String, dynamic>) {
        throw ServerException('Formato de respuesta inválido', 500);
      }

      // Verificar campo 'success'
      final success = response['success'] as bool?;
      if (success != true) {
        final error = response['error'] as Map<String, dynamic>?;
        final errorMessage = error?['message'] as String? ?? 'Error al actualizar preferencia';
        final errorCode = error?['code'] as String? ?? 'unknown';

        switch (errorCode) {
          case 'user_not_found':
            throw NotFoundException(errorMessage);
          default:
            throw ServerException(errorMessage, 500);
        }
      }

      // Operación exitosa, no hay return
    } on PostgrestException catch (e) {
      throw ServerException('Error de base de datos: ${e.message}', e.code != null ? int.tryParse(e.code!) : 500);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}', 500);
    }
  }
}
