import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/features/user/data/models/user_profile_model.dart';

/// Abstract contract para data source remoto de perfil de usuario
abstract class UserProfileRemoteDataSource {
  /// Obtener perfil de usuario para header
  Future<UserProfileModel> getUserProfile(String userId);
}

/// Implementation que consume funciones PostgreSQL vía Supabase RPC
class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  const UserProfileRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      // Llamar función PostgreSQL: get_user_profile(p_user_id)
      final response = await supabaseClient.rpc(
        'get_user_profile',
        params: {'p_user_id': userId},
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
        final errorMessage = error?['message'] as String? ?? 'Error al obtener perfil';
        final errorCode = error?['code'] as String? ?? 'unknown';

        switch (errorCode) {
          case 'user_not_found':
            throw NotFoundException(errorMessage);
          default:
            throw ServerException(errorMessage, 500);
        }
      }

      // Extraer data y mapear a modelo
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw ServerException('Campo data vacío en respuesta', 500);
      }

      return UserProfileModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerException('Error de base de datos: ${e.message}', e.code != null ? int.tryParse(e.code!) : 500);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Error inesperado: ${e.toString()}', 500);
    }
  }
}
