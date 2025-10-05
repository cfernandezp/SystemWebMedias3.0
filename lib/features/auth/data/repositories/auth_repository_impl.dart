import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:system_web_medias/features/auth/data/models/auth_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/email_confirmation_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/login_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/register_request_model.dart';
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
}
