import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/auth/data/models/login_request_model.dart';

void main() {
  group('LoginRequestModel', () {
    test('toJson should map fields correctly to PostgreSQL params', () {
      // Arrange
      const model = LoginRequestModel(
        email: 'test@example.com',
        password: 'Password123!',
        rememberMe: true,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json, {
        'p_email': 'test@example.com',
        'p_password': 'Password123!',
        'p_remember_me': true,
      });
    });

    test('toJson should use default rememberMe false when not provided', () {
      // Arrange
      const model = LoginRequestModel(
        email: 'test@example.com',
        password: 'Password123!',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['p_remember_me'], false);
    });

    test('toJson should handle rememberMe false explicitly', () {
      // Arrange
      const model = LoginRequestModel(
        email: 'test@example.com',
        password: 'Password123!',
        rememberMe: false,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['p_remember_me'], false);
    });
  });
}
