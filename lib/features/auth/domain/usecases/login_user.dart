import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/data/models/login_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_response_model.dart';
import 'package:system_web_medias/features/auth/domain/repositories/auth_repository.dart';

/// Use Case para login de usuario
///
/// Implementa HU-002 (Login al Sistema)
/// Valida credenciales y retorna token + datos de usuario
class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, LoginResponseModel>> call(
    LoginRequestModel request,
  ) async {
    return await repository.login(request);
  }
}
