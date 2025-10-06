import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/auth/data/models/login_response_model.dart';

void main() {
  group('LoginResponseModel', () {
    final validJson = {
      'token': 'test_token_abc123',
      'user': {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'email': 'test@example.com',
        'nombre_completo': 'Test User',
        'rol': 'VENDEDOR',
        'estado': 'APROBADO',
        'email_verificado': true,
        'created_at': '2025-10-05T12:00:00Z',
        'updated_at': '2025-10-05T12:00:00Z',
      },
      'message': 'Bienvenido Test User',
    };

    test('fromJson should parse correctly', () {
      // Act
      final model = LoginResponseModel.fromJson(validJson);

      // Assert
      expect(model.token, 'test_token_abc123');
      expect(model.user.email, 'test@example.com');
      expect(model.user.nombreCompleto, 'Test User');
      expect(model.message, 'Bienvenido Test User');
    });

    test('toJson should serialize correctly', () {
      // Arrange
      final model = LoginResponseModel.fromJson(validJson);

      // Act
      final json = model.toJson();

      // Assert
      expect(json['token'], 'test_token_abc123');
      expect(json['user']['email'], 'test@example.com');
      expect(json['message'], 'Bienvenido Test User');
    });

    test('should support Equatable equality', () {
      // Arrange
      final model1 = LoginResponseModel.fromJson(validJson);
      final model2 = LoginResponseModel.fromJson(validJson);

      // Assert
      expect(model1, equals(model2));
    });

    test('should detect inequality when token differs', () {
      // Arrange
      final model1 = LoginResponseModel.fromJson(validJson);
      final model2 = LoginResponseModel.fromJson({
        ...validJson,
        'token': 'different_token',
      });

      // Assert
      expect(model1, isNot(equals(model2)));
    });

    test('fromJson should handle missing token (backend actual)', () {
      // Arrange - Este es el formato real que el backend está enviando
      final jsonWithoutToken = {
        'user': {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'email': 'admin@admin.com',
          'nombre_completo': 'Admin User',
          'email_verificado': true,
        },
        'message': 'Bienvenido Admin User',
      };

      // Act
      final model = LoginResponseModel.fromJson(jsonWithoutToken);

      // Assert
      expect(model.token, isNull);
      expect(model.user.email, 'admin@admin.com');
      expect(model.user.nombreCompleto, 'Admin User');
      expect(model.message, 'Bienvenido Admin User');
    });

    test('toJson should omit token when null', () {
      // Arrange
      final jsonWithoutToken = {
        'user': {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'email': 'admin@admin.com',
          'nombre_completo': 'Admin User',
          'email_verificado': true,
        },
        'message': 'Bienvenido Admin User',
      };
      final model = LoginResponseModel.fromJson(jsonWithoutToken);

      // Act
      final json = model.toJson();

      // Assert
      expect(json.containsKey('token'), isFalse);
      expect(json['user']['email'], 'admin@admin.com');
      expect(json['message'], 'Bienvenido Admin User');
    });
  });
}
