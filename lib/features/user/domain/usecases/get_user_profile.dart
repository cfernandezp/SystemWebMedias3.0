import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/user/domain/entities/user_profile.dart';
import 'package:system_web_medias/features/user/domain/repositories/user_profile_repository.dart';

/// Use Case: Obtener perfil de usuario para header
/// Sigue el patrón de Clean Architecture con params
class GetUserProfile {
  final UserProfileRepository repository;

  const GetUserProfile(this.repository);

  /// Ejecutar use case
  Future<Either<Failure, UserProfile>> call(GetUserProfileParams params) async {
    return await repository.getUserProfile(params.userId);
  }
}

/// Params del use case
class GetUserProfileParams extends Equatable {
  final String userId;

  const GetUserProfileParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
