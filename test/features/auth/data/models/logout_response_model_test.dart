import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/auth/data/models/logout_response_model.dart';

void main() {
  group('LogoutResponseModel', () {
    test('should parse from JSON correctly with snake_case mapping', () {
      // Arrange
      final json = {
        'message': 'Sesión cerrada exitosamente',
        'logout_type': 'manual',
        'blacklisted_at': '2025-10-06T10:30:00Z',
      };

      // Act
      final model = LogoutResponseModel.fromJson(json);

      // Assert
      expect(model.message, 'Sesión cerrada exitosamente');
      expect(model.logoutType, 'manual');
      expect(model.blacklistedAt, DateTime.parse('2025-10-06T10:30:00Z'));
    });

    test('should parse inactivity logout correctly', () {
      // Arrange
      final json = {
        'message': 'Sesión cerrada por inactividad',
        'logout_type': 'inactivity',
        'blacklisted_at': '2025-10-06T12:00:00Z',
      };

      // Act
      final model = LogoutResponseModel.fromJson(json);

      // Assert
      expect(model.message, 'Sesión cerrada por inactividad');
      expect(model.logoutType, 'inactivity');
    });

    test('should parse token_expired logout correctly', () {
      // Arrange
      final json = {
        'message': 'Token expirado',
        'logout_type': 'token_expired',
        'blacklisted_at': '2025-10-06T14:00:00Z',
      };

      // Act
      final model = LogoutResponseModel.fromJson(json);

      // Assert
      expect(model.logoutType, 'token_expired');
    });

    test('should support equality comparison', () {
      // Arrange
      final model1 = LogoutResponseModel(
        message: 'Sesión cerrada',
        logoutType: 'manual',
        blacklistedAt: DateTime.parse('2025-10-06T10:30:00Z'),
      );
      final model2 = LogoutResponseModel(
        message: 'Sesión cerrada',
        logoutType: 'manual',
        blacklistedAt: DateTime.parse('2025-10-06T10:30:00Z'),
      );
      final model3 = LogoutResponseModel(
        message: 'Diferente',
        logoutType: 'manual',
        blacklistedAt: DateTime.parse('2025-10-06T10:30:00Z'),
      );

      // Assert
      expect(model1, equals(model2));
      expect(model1, isNot(equals(model3)));
    });
  });
}
