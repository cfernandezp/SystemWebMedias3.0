import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/auth/data/models/inactivity_status_model.dart';

void main() {
  group('InactivityStatusModel', () {
    test('should parse from JSON when user is inactive', () {
      // Arrange
      final json = {
        'is_inactive': true,
        'last_activity_at': '2025-10-06T08:00:00Z',
        'inactive_minutes': 125,
        'minutes_until_logout': 0,
        'should_warn': false,
        'message': 'Usuario inactivo. Sesión debe cerrarse',
      };

      // Act
      final model = InactivityStatusModel.fromJson(json);

      // Assert
      expect(model.isInactive, true);
      expect(model.lastActivityAt, DateTime.parse('2025-10-06T08:00:00Z'));
      expect(model.inactiveMinutes, 125);
      expect(model.minutesUntilLogout, 0);
      expect(model.shouldWarn, false);
      expect(model.message, 'Usuario inactivo. Sesión debe cerrarse');
    });

    test('should parse from JSON when warning should be shown', () {
      // Arrange
      final json = {
        'is_inactive': false,
        'last_activity_at': '2025-10-06T10:10:00Z',
        'inactive_minutes': 115,
        'minutes_until_logout': 5,
        'should_warn': true,
        'message': 'Tu sesión expirará en 5 minutos',
      };

      // Act
      final model = InactivityStatusModel.fromJson(json);

      // Assert
      expect(model.isInactive, false);
      expect(model.inactiveMinutes, 115);
      expect(model.minutesUntilLogout, 5);
      expect(model.shouldWarn, true);
      expect(model.message, 'Tu sesión expirará en 5 minutos');
    });

    test('should parse from JSON when user is active', () {
      // Arrange
      final json = {
        'is_inactive': false,
        'last_activity_at': '2025-10-06T10:30:00Z',
        'inactive_minutes': 30,
        'minutes_until_logout': 90,
        'should_warn': false,
        'message': 'Usuario activo',
      };

      // Act
      final model = InactivityStatusModel.fromJson(json);

      // Assert
      expect(model.isInactive, false);
      expect(model.inactiveMinutes, 30);
      expect(model.minutesUntilLogout, 90);
      expect(model.shouldWarn, false);
    });

    test('should support equality comparison', () {
      // Arrange
      final model1 = InactivityStatusModel(
        isInactive: true,
        lastActivityAt: DateTime.parse('2025-10-06T08:00:00Z'),
        inactiveMinutes: 125,
        minutesUntilLogout: 0,
        shouldWarn: false,
        message: 'Usuario inactivo',
      );
      final model2 = InactivityStatusModel(
        isInactive: true,
        lastActivityAt: DateTime.parse('2025-10-06T08:00:00Z'),
        inactiveMinutes: 125,
        minutesUntilLogout: 0,
        shouldWarn: false,
        message: 'Usuario inactivo',
      );
      final model3 = InactivityStatusModel(
        isInactive: false,
        lastActivityAt: DateTime.parse('2025-10-06T10:00:00Z'),
        inactiveMinutes: 30,
        minutesUntilLogout: 90,
        shouldWarn: false,
        message: 'Usuario activo',
      );

      // Assert
      expect(model1, equals(model2));
      expect(model1, isNot(equals(model3)));
    });
  });
}
