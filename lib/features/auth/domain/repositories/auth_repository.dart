import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/data/models/auth_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/email_confirmation_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/inactivity_status_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/logout_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/logout_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/password_reset_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/register_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/token_blacklist_check_model.dart';
import 'package:system_web_medias/features/auth/data/models/validate_reset_token_model.dart';
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

  /// HU-003: Logout Seguro methods
  /// Logout con invalidación de token
  Future<Either<Failure, LogoutResponseModel>> logoutSecure(
    LogoutRequestModel request,
  );

  /// Verificar si token está en blacklist
  Future<Either<Failure, TokenBlacklistCheckModel>> checkTokenBlacklist(
    String token,
  );

  /// Verificar estado de inactividad del usuario
  Future<Either<Failure, InactivityStatusModel>> checkInactivity(
    String userId,
  );

  /// Actualizar última actividad del usuario
  Future<Either<Failure, void>> updateUserActivity(String userId);

  /// HU-004: Password Recovery methods
  /// Solicitar recuperación de contraseña
  Future<Either<Failure, PasswordResetResponseModel>> requestPasswordReset(
    String email,
  );

  /// Cambiar contraseña con token de recuperación
  Future<Either<Failure, void>> resetPassword(
    String token,
    String newPassword,
  );

  /// Validar token de recuperación
  Future<Either<Failure, ValidateResetTokenModel>> validateResetToken(
    String token,
  );
}
