import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/auth/data/models/audit_log_model.dart';

void main() {
  group('AuditLogModel', () {
    test('should parse from JSON with all fields', () {
      // Arrange
      final json = {
        'id': 'log-uuid-1',
        'event_type': 'logout',
        'event_subtype': 'manual',
        'ip_address': '192.168.1.1',
        'user_agent': 'Mozilla/5.0...',
        'metadata': {
          'session_duration': 2700,
          'logout_type': 'manual',
        },
        'created_at': '2025-10-06T10:30:00Z',
      };

      // Act
      final model = AuditLogModel.fromJson(json);

      // Assert
      expect(model.id, 'log-uuid-1');
      expect(model.eventType, 'logout');
      expect(model.eventSubtype, 'manual');
      expect(model.ipAddress, '192.168.1.1');
      expect(model.userAgent, 'Mozilla/5.0...');
      expect(model.metadata, {
        'session_duration': 2700,
        'logout_type': 'manual',
      });
      expect(model.createdAt, DateTime.parse('2025-10-06T10:30:00Z'));
    });

    test('should parse from JSON with minimal fields', () {
      // Arrange
      final json = {
        'id': 'log-uuid-2',
        'event_type': 'login',
        'event_subtype': null,
        'ip_address': null,
        'user_agent': null,
        'metadata': null,
        'created_at': '2025-10-06T11:00:00Z',
      };

      // Act
      final model = AuditLogModel.fromJson(json);

      // Assert
      expect(model.id, 'log-uuid-2');
      expect(model.eventType, 'login');
      expect(model.eventSubtype, null);
      expect(model.ipAddress, null);
      expect(model.userAgent, null);
      expect(model.metadata, null);
      expect(model.createdAt, DateTime.parse('2025-10-06T11:00:00Z'));
    });

    test('should parse different event types correctly', () {
      // Test logout event
      final json1 = {
        'id': 'log-1',
        'event_type': 'logout',
        'event_subtype': 'inactivity',
        'ip_address': '192.168.1.1',
        'user_agent': 'Mozilla/5.0',
        'metadata': {'reason': 'timeout'},
        'created_at': '2025-10-06T10:00:00Z',
      };
      final model1 = AuditLogModel.fromJson(json1);
      expect(model1.eventType, 'logout');
      expect(model1.eventSubtype, 'inactivity');

      // Test login event
      final json2 = {
        'id': 'log-2',
        'event_type': 'login',
        'event_subtype': 'success',
        'ip_address': '192.168.1.2',
        'user_agent': 'Chrome',
        'metadata': null,
        'created_at': '2025-10-06T11:00:00Z',
      };
      final model2 = AuditLogModel.fromJson(json2);
      expect(model2.eventType, 'login');
      expect(model2.eventSubtype, 'success');
    });

    test('should support equality comparison', () {
      // Arrange
      final model1 = AuditLogModel(
        id: 'log-1',
        eventType: 'logout',
        eventSubtype: 'manual',
        ipAddress: '192.168.1.1',
        userAgent: 'Mozilla/5.0',
        metadata: {'key': 'value'},
        createdAt: DateTime.parse('2025-10-06T10:00:00Z'),
      );
      final model2 = AuditLogModel(
        id: 'log-1',
        eventType: 'logout',
        eventSubtype: 'manual',
        ipAddress: '192.168.1.1',
        userAgent: 'Mozilla/5.0',
        metadata: {'key': 'value'},
        createdAt: DateTime.parse('2025-10-06T10:00:00Z'),
      );
      final model3 = AuditLogModel(
        id: 'log-2',
        eventType: 'login',
        createdAt: DateTime.parse('2025-10-06T11:00:00Z'),
      );

      // Assert
      expect(model1, equals(model2));
      expect(model1, isNot(equals(model3)));
    });
  });
}
