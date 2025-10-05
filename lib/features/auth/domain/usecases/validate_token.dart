import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/data/models/validate_token_response_model.dart';
import 'package:system_web_medias/features/auth/domain/repositories/auth_repository.dart';

/// Use Case para validar token de sesión
///
/// Implementa HU-002 (Login al Sistema)
/// Verifica que el token sea válido y no haya expirado
class ValidateToken {
  final AuthRepository repository;

  ValidateToken(this.repository);

  Future<Either<Failure, ValidateTokenResponseModel>> call(String token) async {
    return await repository.validateToken(token);
  }
}
