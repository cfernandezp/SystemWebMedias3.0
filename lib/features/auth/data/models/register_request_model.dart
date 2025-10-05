import 'package:equatable/equatable.dart';

class RegisterRequestModel extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String nombreCompleto;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.nombreCompleto,
  });

  /// Mapping a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'email': email.toLowerCase().trim(), // Normalizar email
      'password': password,
      'confirm_password': confirmPassword, // snake_case para backend
      'nombre_completo': nombreCompleto.trim(), // Trim espacios
    };
  }

  @override
  List<Object?> get props => [email, password, confirmPassword, nombreCompleto];

  /// Validaciones Frontend (RN-006, RN-002)
  String? validateEmail() {
    if (email.isEmpty) return 'Email es requerido';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) return 'Formato de email inválido';
    return null;
  }

  String? validatePassword() {
    if (password.isEmpty) return 'Contraseña es requerida';
    if (password.length < 8) return 'Contraseña debe tener al menos 8 caracteres';
    return null;
  }

  String? validateConfirmPassword() {
    if (confirmPassword.isEmpty) return 'Confirmar contraseña es requerido';
    if (password != confirmPassword) return 'Las contraseñas no coinciden';
    return null;
  }

  String? validateNombreCompleto() {
    if (nombreCompleto.trim().isEmpty) return 'Nombre completo es requerido';
    return null;
  }

  /// Validación completa del formulario
  Map<String, String> validateAll() {
    final errors = <String, String>{};

    final emailError = validateEmail();
    if (emailError != null) errors['email'] = emailError;

    final passwordError = validatePassword();
    if (passwordError != null) errors['password'] = passwordError;

    final confirmPasswordError = validateConfirmPassword();
    if (confirmPasswordError != null) errors['confirmPassword'] = confirmPasswordError;

    final nombreError = validateNombreCompleto();
    if (nombreError != null) errors['nombreCompleto'] = nombreError;

    return errors;
  }

  bool get isValid => validateAll().isEmpty;
}
