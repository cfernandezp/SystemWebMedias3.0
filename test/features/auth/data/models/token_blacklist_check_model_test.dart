import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/auth/data/models/token_blacklist_check_model.dart';

void main() {
  group('TokenBlacklistCheckModel', () {
    test('should parse from JSON when token is blacklisted', () {
      // Arrange
      final json = {
        'is_blacklisted': true,
        'reason': 'manual_logout',
        'message': 'Token inválido. Debes iniciar sesión nuevamente',
      };

      // Act
      final model = TokenBlacklistCheckModel.fromJson(json);

      // Assert
      expect(model.isBlacklisted, true);
      expect(model.reason, 'manual_logout');
      expect(model.message, 'Token inválido. Debes iniciar sesión nuevamente');
    });

    test('should parse from JSON when token is NOT blacklisted', () {
      // Arrange
      final json = {
        'is_blacklisted': false,
        'reason': null,
        'message': 'Token válido',
      };

      // Act
      final model = TokenBlacklistCheckModel.fromJson(json);

      // Assert
      expect(model.isBlacklisted, false);
      expect(model.reason, null);
      expect(model.message, 'Token válido');
    });

    test('should parse different blacklist reasons correctly', () {
      // Test inactivity reason
      final json1 = {
        'is_blacklisted': true,
        'reason': 'inactivity',
        'message': 'Sesión cerrada por inactividad',
      };
      final model1 = TokenBlacklistCheckModel.fromJson(json1);
      expect(model1.reason, 'inactivity');

      // Test token_expired reason
      final json2 = {
        'is_blacklisted': true,
        'reason': 'token_expired',
        'message': 'Token expirado',
      };
      final model2 = TokenBlacklistCheckModel.fromJson(json2);
      expect(model2.reason, 'token_expired');
    });

    test('should support equality comparison', () {
      // Arrange
      final model1 = TokenBlacklistCheckModel(
        isBlacklisted: true,
        reason: 'manual_logout',
        message: 'Token inválido',
      );
      final model2 = TokenBlacklistCheckModel(
        isBlacklisted: true,
        reason: 'manual_logout',
        message: 'Token inválido',
      );
      final model3 = TokenBlacklistCheckModel(
        isBlacklisted: false,
        message: 'Token válido',
      );

      // Assert
      expect(model1, equals(model2));
      expect(model1, isNot(equals(model3)));
    });
  });
}
