import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/user/domain/entities/user_profile.dart';

/// Contract abstracto del repository de perfil de usuario
/// Define las operaciones disponibles sin especificar implementación
abstract class UserProfileRepository {
  /// Obtener perfil de usuario para header
  /// Returns: Either<Failure, UserProfile>
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
}
