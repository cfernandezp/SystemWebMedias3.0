import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/auth/data/models/logout_request_model.dart';

void main() {
  group('LogoutRequestModel', () {
    test('should create instance with required fields', () {
      // Arrange & Act
      final model = LogoutRequestModel(
        token: 'test-token',
        userId: 'user-123',
      );

      // Assert
      expect(model.token, 'test-token');
      expect(model.userId, 'user-123');
      expect(model.logoutType, 'manual');
      expect(model.ipAddress, null);
      expect(model.userAgent, null);
      expect(model.sessionDuration, null);
    });

    test('should create instance with all fields', () {
      // Arrange & Act
      final model = LogoutRequestModel(
        token: 'test-token',
        userId: 'user-123',
        logoutType: 'inactivity',
        ipAddress: '192.168.1.1',
        userAgent: 'Mozilla/5.0',
        sessionDuration: Duration(minutes: 45),
      );

      // Assert
      expect(model.token, 'test-token');
      expect(model.userId, 'user-123');
      expect(model.logoutType, 'inactivity');
      expect(model.ipAddress, '192.168.1.1');
      expect(model.userAgent, 'Mozilla/5.0');
      expect(model.sessionDuration, Duration(minutes: 45));
    });

    test('should convert to JSON with correct mapping (snake_case)', () {
      // Arrange
      final model = LogoutRequestModel(
        token: 'test-token',
        userId: 'user-123',
        logoutType: 'manual',
        ipAddress: '192.168.1.1',
        userAgent: 'Mozilla/5.0',
        sessionDuration: Duration(minutes: 30),
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['p_token'], 'test-token');
      expect(json['p_user_id'], 'user-123');
      expect(json['p_logout_type'], 'manual');
      expect(json['p_ip_address'], '192.168.1.1');
      expect(json['p_user_agent'], 'Mozilla/5.0');
      expect(json['p_session_duration'], 1800); // 30 minutes in seconds
    });

    test('should convert duration to seconds correctly', () {
      // Arrange
      final model = LogoutRequestModel(
        token: 'test-token',
        userId: 'user-123',
        sessionDuration: Duration(hours: 2, minutes: 15),
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['p_session_duration'], 8100); // 2h 15m = 8100 seconds
    });

    test('should support equality comparison', () {
      // Arrange
      final model1 = LogoutRequestModel(
        token: 'test-token',
        userId: 'user-123',
      );
      final model2 = LogoutRequestModel(
        token: 'test-token',
        userId: 'user-123',
      );
      final model3 = LogoutRequestModel(
        token: 'different-token',
        userId: 'user-123',
      );

      // Assert
      expect(model1, equals(model2));
      expect(model1, isNot(equals(model3)));
    });
  });
}
