import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:system_web_medias/features/auth/data/models/auth_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/email_confirmation_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/inactivity_status_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/logout_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/logout_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/password_reset_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/password_reset_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/register_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/reset_password_model.dart';
import 'package:system_web_medias/features/auth/data/models/token_blacklist_check_model.dart';
import 'package:system_web_medias/features/auth/data/models/validate_reset_token_model.dart';
import 'package:system_web_medias/features/auth/data/models/validate_token_response_model.dart';
import 'package:system_web_medias/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, AuthResponseModel>> register(
    RegisterRequestModel request,
  ) async {
    try {
      final result = await remoteDataSource.register(request);
      return Right(result);
    } on DuplicateEmailException catch (e) {
      return Left(DuplicateEmailFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, EmailConfirmationResponseModel>> confirmEmail(
    String token,
  ) async {
    try {
      final result = await remoteDataSource.confirmEmail(token);
      return Right(result);
    } on InvalidTokenException catch (e) {
      return Left(InvalidTokenFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resendConfirmation(String email) async {
    try {
      await remoteDataSource.resendConfirmation(email);
      return const Right(null);
    } on EmailAlreadyVerifiedException catch (e) {
      return Left(EmailAlreadyVerifiedFailure(e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  /// HU-002: Login con credenciales
  @override
  Future<Either<Failure, LoginResponseModel>> login(
    LoginRequestModel request,
  ) async {
    try {
      final result = await remoteDataSource.login(request);
      return Right(result);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on EmailNotVerifiedException catch (e) {
      return Left(EmailNotVerifiedFailure(e.message));
    } on UserNotApprovedException catch (e) {
      return Left(UserNotApprovedFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  /// HU-002: Validar token de sesión
  @override
  Future<Either<Failure, ValidateTokenResponseModel>> validateToken(
    String token,
  ) async {
    try {
      final result = await remoteDataSource.validateToken(token);
      return Right(result);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on UserNotApprovedException catch (e) {
      return Left(UserNotApprovedFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  /// HU-002: Logout (solo limpia estado local)
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // El logout solo limpia el estado local (SecureStorage)
      // La lógica de limpieza se maneja en el Bloc
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  /// HU-003: Logout seguro con invalidación de token
  @override
  Future<Either<Failure, LogoutResponseModel>> logoutSecure(
    LogoutRequestModel request,
  ) async {
    try {
      final result = await remoteDataSource.logout(request);
      return Right(result);
    } on TokenBlacklistedException catch (e) {
      return Left(TokenBlacklistedFailure(e.message));
    } on AlreadyLoggedOutException catch (e) {
      return Left(AlreadyLoggedOutFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  /// HU-003: Verificar si token está en blacklist
  @override
  Future<Either<Failure, TokenBlacklistCheckModel>> checkTokenBlacklist(
    String token,
  ) async {
    try {
      final result = await remoteDataSource.checkTokenBlacklist(token);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  /// HU-003: Verificar estado de inactividad del usuario
  @override
  Future<Either<Failure, InactivityStatusModel>> checkInactivity(
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.checkInactivity(userId);
      return Right(result);
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  /// HU-003: Actualizar última actividad del usuario
  @override
  Future<Either<Failure, void>> updateUserActivity(String userId) async {
    try {
      await remoteDataSource.updateUserActivity(userId);
      return const Right(null);
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  /// HU-004: Solicitar recuperación de contraseña
  @override
  Future<Either<Failure, PasswordResetResponseModel>> requestPasswordReset(
    String email,
  ) async {
    try {
      final request = PasswordResetRequestModel(email: email);
      final result = await remoteDataSource.requestPasswordReset(request);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  /// HU-004: Cambiar contraseña con token
  @override
  Future<Either<Failure, void>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final request = ResetPasswordModel(
        token: token,
        newPassword: newPassword,
      );
      await remoteDataSource.resetPassword(request);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on WeakPasswordException catch (e) {
      return Left(WeakPasswordFailure(e.message));
    } on InvalidTokenException catch (e) {
      return Left(InvalidTokenFailure(e.message));
    } on ExpiredTokenException catch (e) {
      return Left(ExpiredTokenFailure(e.message));
    } on UsedTokenException catch (e) {
      return Left(UsedTokenFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  /// HU-004: Validar token de recuperación
  @override
  Future<Either<Failure, ValidateResetTokenModel>> validateResetToken(
    String token,
  ) async {
    try {
      final result = await remoteDataSource.validateResetToken(token);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on InvalidTokenException catch (e) {
      return Left(InvalidTokenFailure(e.message));
    } on ExpiredTokenException catch (e) {
      return Left(ExpiredTokenFailure(e.message));
    } on UsedTokenException catch (e) {
      return Left(UsedTokenFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }
}
