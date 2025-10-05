/// Validadores de formularios siguiendo convenciones del Design System
///
/// HU-001: Validación de email para registro
/// HU-002: Validación de campos requeridos para login
class Validators {
  /// Valida formato de email
  ///
  /// Retorna `null` si es válido, mensaje de error si no lo es.
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email es requerido';
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Formato de email inválido';
    }

    return null;
  }

  /// Valida que un campo no esté vacío
  ///
  /// Retorna un validator function que puede usarse en TextFormField.
  ///
  /// Ejemplo:
  /// ```dart
  /// CorporateFormField(
  ///   validator: Validators.required('Contraseña es requerida'),
  /// )
  /// ```
  static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return message;
      }
      return null;
    };
  }

  /// Valida longitud mínima de un campo
  ///
  /// Retorna un validator function que valida que el campo tenga al menos
  /// [minLength] caracteres.
  static String? Function(String?) minLength(int minLength, String message) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return message;
      }
      if (value.length < minLength) {
        return message;
      }
      return null;
    };
  }

  /// Valida longitud máxima de un campo
  static String? Function(String?) maxLength(int maxLength, String message) {
    return (String? value) {
      if (value != null && value.length > maxLength) {
        return message;
      }
      return null;
    };
  }
}
