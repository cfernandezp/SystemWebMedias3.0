import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:system_web_medias/features/auth/data/models/inactivity_status_model.dart';
import 'package:system_web_medias/features/auth/data/models/logout_request_model.dart';
import 'package:system_web_medias/features/auth/data/models/logout_response_model.dart';
import 'package:system_web_medias/features/auth/data/models/token_blacklist_check_model.dart';
import 'package:system_web_medias/features/auth/data/repositories/auth_repository_impl.dart';

// Mock de AuthRemoteDataSource
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
  });

  // Register fallback values para mocktail
  setUpAll(() {
    registerFallbackValue(LogoutRequestModel(
      token: 'test-token',
      userId: 'test-user-id',
    ));
  });

  group('HU-003: logoutSecure', () {
    final logoutRequest = LogoutRequestModel(
      token: 'test-jwt-token',
      userId: 'user-123',
      logoutType: 'manual',
    );

    final logoutResponse = LogoutResponseModel(
      message: 'Sesión cerrada exitosamente',
      logoutType: 'manual',
      blacklistedAt: DateTime.parse('2025-10-06T10:30:00Z'),
    );

    test('should return LogoutResponseModel when logout is successful', () async {
      // Arrange
      when(() => mockDataSource.logout(any()))
          .thenAnswer((_) async => logoutResponse);

      // Act
      final result = await repository.logoutSecure(logoutRequest);

      // Assert
      expect(result, Right(logoutResponse));
      verify(() => mockDataSource.logout(logoutRequest)).called(1);
    });

    test('should return TokenBlacklistedFailure when TokenBlacklistedException is thrown', () async {
      // Arrange
      when(() => mockDataSource.logout(any()))
          .thenThrow(TokenBlacklistedException('Token ya invalidado', 401));

      // Act
      final result = await repository.logoutSecure(logoutRequest);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<TokenBlacklistedFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return AlreadyLoggedOutFailure when AlreadyLoggedOutException is thrown', () async {
      // Arrange
      when(() => mockDataSource.logout(any()))
          .thenThrow(AlreadyLoggedOutException('Ya has cerrado sesión', 400));

      // Act
      final result = await repository.logoutSecure(logoutRequest);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<AlreadyLoggedOutFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when ValidationException is thrown', () async {
      // Arrange
      when(() => mockDataSource.logout(any()))
          .thenThrow(ValidationException('Token es requerido', 400));

      // Act
      final result = await repository.logoutSecure(logoutRequest);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ConnectionFailure when NetworkException is thrown', () async {
      // Arrange
      when(() => mockDataSource.logout(any()))
          .thenThrow(NetworkException('Error de conexión'));

      // Act
      final result = await repository.logoutSecure(logoutRequest);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ConnectionFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      // Arrange
      when(() => mockDataSource.logout(any()))
          .thenThrow(ServerException('Error del servidor', 500));

      // Act
      final result = await repository.logoutSecure(logoutRequest);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('HU-003: checkTokenBlacklist', () {
    const token = 'test-jwt-token';

    final blacklistCheck = TokenBlacklistCheckModel(
      isBlacklisted: true,
      reason: 'manual_logout',
      message: 'Token inválido',
    );

    test('should return TokenBlacklistCheckModel when check is successful', () async {
      // Arrange
      when(() => mockDataSource.checkTokenBlacklist(token))
          .thenAnswer((_) async => blacklistCheck);

      // Act
      final result = await repository.checkTokenBlacklist(token);

      // Assert
      expect(result, Right(blacklistCheck));
      verify(() => mockDataSource.checkTokenBlacklist(token)).called(1);
    });

    test('should return ValidationFailure when ValidationException is thrown', () async {
      // Arrange
      when(() => mockDataSource.checkTokenBlacklist(token))
          .thenThrow(ValidationException('Token es requerido', 400));

      // Act
      final result = await repository.checkTokenBlacklist(token);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ConnectionFailure when NetworkException is thrown', () async {
      // Arrange
      when(() => mockDataSource.checkTokenBlacklist(token))
          .thenThrow(NetworkException('Error de conexión'));

      // Act
      final result = await repository.checkTokenBlacklist(token);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ConnectionFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('HU-003: checkInactivity', () {
    const userId = 'user-123';

    final inactivityStatus = InactivityStatusModel(
      isInactive: false,
      lastActivityAt: DateTime.parse('2025-10-06T10:10:00Z'),
      inactiveMinutes: 115,
      minutesUntilLogout: 5,
      shouldWarn: true,
      message: 'Tu sesión expirará en 5 minutos',
    );

    test('should return InactivityStatusModel when check is successful', () async {
      // Arrange
      when(() => mockDataSource.checkInactivity(userId))
          .thenAnswer((_) async => inactivityStatus);

      // Act
      final result = await repository.checkInactivity(userId);

      // Assert
      expect(result, Right(inactivityStatus));
      verify(() => mockDataSource.checkInactivity(userId)).called(1);
    });

    test('should return UserNotFoundFailure when UserNotFoundException is thrown', () async {
      // Arrange
      when(() => mockDataSource.checkInactivity(userId))
          .thenThrow(UserNotFoundException('Usuario no encontrado', 404));

      // Act
      final result = await repository.checkInactivity(userId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UserNotFoundFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when ValidationException is thrown', () async {
      // Arrange
      when(() => mockDataSource.checkInactivity(userId))
          .thenThrow(ValidationException('User ID es requerido', 400));

      // Act
      final result = await repository.checkInactivity(userId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('HU-003: updateUserActivity', () {
    const userId = 'user-123';

    test('should return Right(null) when update is successful', () async {
      // Arrange
      when(() => mockDataSource.updateUserActivity(userId))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.updateUserActivity(userId);

      // Assert
      expect(result, const Right(null));
      verify(() => mockDataSource.updateUserActivity(userId)).called(1);
    });

    test('should return UserNotFoundFailure when UserNotFoundException is thrown', () async {
      // Arrange
      when(() => mockDataSource.updateUserActivity(userId))
          .thenThrow(UserNotFoundException('Usuario no encontrado', 404));

      // Act
      final result = await repository.updateUserActivity(userId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<UserNotFoundFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure when ValidationException is thrown', () async {
      // Arrange
      when(() => mockDataSource.updateUserActivity(userId))
          .thenThrow(ValidationException('User ID es requerido', 400));

      // Act
      final result = await repository.updateUserActivity(userId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ConnectionFailure when NetworkException is thrown', () async {
      // Arrange
      when(() => mockDataSource.updateUserActivity(userId))
          .thenThrow(NetworkException('Error de conexión'));

      // Act
      final result = await repository.updateUserActivity(userId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ConnectionFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      // Arrange
      when(() => mockDataSource.updateUserActivity(userId))
          .thenThrow(ServerException('Error del servidor', 500));

      // Act
      final result = await repository.updateUserActivity(userId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
