import 'package:equatable/equatable.dart';

/// HU-004: Model para solicitud de recuperación de contraseña
class PasswordResetRequestModel extends Equatable {
  final String email;

  const PasswordResetRequestModel({
    required this.email,
  });

  /// Convertir a JSON para enviar al backend (snake_case)
  Map<String, dynamic> toJson() => {
        'p_email': email,
      };

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'PasswordResetRequestModel(email: $email)';
}
