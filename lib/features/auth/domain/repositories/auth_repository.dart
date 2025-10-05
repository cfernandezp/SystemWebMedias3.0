import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/data/models/auth_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/email_confirmation_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/register_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/validate_token_response_model.dart';

/// Abstract repository - Domain layer NO debe depender de Data layer
abstract class AuthRepository {
  /// Registrar nuevo usuario
  Future<Either<Failure, AuthResponseModel>> register(
    RegisterRequestModel request,
  );

  /// Confirmar email con token
  Future<Either<Failure, EmailConfirmationResponseModel>> confirmEmail(
    String token,
  );

  /// Reenviar email de confirmación
  Future<Either<Failure, void>> resendConfirmation(String email);

  /// HU-002: Login methods
  Future<Either<Failure, LoginResponseModel>> login(LoginRequestModel request);
  Future<Either<Failure, ValidateTokenResponseModel>> validateToken(String token);
  Future<Either<Failure, void>> logout();
}
