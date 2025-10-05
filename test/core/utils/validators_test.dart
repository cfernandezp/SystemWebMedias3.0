import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('should return null for valid email', () {
        expect(Validators.email('test@example.com'), null);
        expect(Validators.email('user.name@domain.co.uk'), null);
        expect(Validators.email('user+tag@example.com'), null);
      });

      test('should return error message for empty email', () {
        expect(Validators.email(''), 'Email es requerido');
        expect(Validators.email(null), 'Email es requerido');
      });

      test('should return error message for invalid email format', () {
        expect(Validators.email('invalid'), 'Formato de email inválido');
        expect(Validators.email('invalid@'), 'Formato de email inválido');
        expect(Validators.email('@example.com'), 'Formato de email inválido');
        expect(Validators.email('user@'), 'Formato de email inválido');
        expect(Validators.email('user@domain'), 'Formato de email inválido');
      });
    });

    group('required', () {
      test('should return null for non-empty value', () {
        final validator = Validators.required('Campo requerido');
        expect(validator('some value'), null);
        expect(validator('a'), null);
      });

      test('should return custom error message for empty value', () {
        final validator = Validators.required('Contraseña es requerida');
        expect(validator(''), 'Contraseña es requerida');
        expect(validator(null), 'Contraseña es requerida');
      });

      test('should work with different error messages', () {
        final validatorPassword = Validators.required('Contraseña es requerida');
        final validatorName = Validators.required('Nombre es requerido');

        expect(validatorPassword(''), 'Contraseña es requerida');
        expect(validatorName(''), 'Nombre es requerido');
      });
    });

    group('minLength', () {
      test('should return null when value meets minimum length', () {
        final validator = Validators.minLength(8, 'Mínimo 8 caracteres');
        expect(validator('12345678'), null);
        expect(validator('123456789'), null);
      });

      test('should return error when value is too short', () {
        final validator = Validators.minLength(8, 'Mínimo 8 caracteres');
        expect(validator('1234567'), 'Mínimo 8 caracteres');
        expect(validator(''), 'Mínimo 8 caracteres');
      });

      test('should return error when value is null', () {
        final validator = Validators.minLength(8, 'Mínimo 8 caracteres');
        expect(validator(null), 'Mínimo 8 caracteres');
      });
    });

    group('maxLength', () {
      test('should return null when value is within max length', () {
        final validator = Validators.maxLength(100, 'Máximo 100 caracteres');
        expect(validator('a' * 100), null);
        expect(validator('a' * 50), null);
        expect(validator(null), null);
      });

      test('should return error when value exceeds max length', () {
        final validator = Validators.maxLength(100, 'Máximo 100 caracteres');
        expect(validator('a' * 101), 'Máximo 100 caracteres');
      });
    });
  });
}
