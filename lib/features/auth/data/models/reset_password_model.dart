import 'package:equatable/equatable.dart';

/// HU-004: Model para cambiar contraseña con token
class ResetPasswordModel extends Equatable {
  final String token;
  final String newPassword;

  const ResetPasswordModel({
    required this.token,
    required this.newPassword,
  });

  /// Convertir a JSON para enviar al backend (snake_case)
  Map<String, dynamic> toJson() => {
        'p_token': token,
        'p_new_password': newPassword,
      };

  @override
  List<Object> get props => [token, newPassword];

  @override
  String toString() =>
      'ResetPasswordModel(token: ${token.substring(0, 10)}..., newPassword: ****)';
}
