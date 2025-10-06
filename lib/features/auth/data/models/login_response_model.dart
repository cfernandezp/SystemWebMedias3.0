import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/auth/data/models/user_model.dart';

/// Modelo de respuesta exitosa del login
///
/// Implementa HU-002 (Login al Sistema)
/// Contiene token JWT (opcional), datos del usuario y mensaje de bienvenida
///
/// Mapping PostgreSQL → Dart:
/// - `data.token` → `token` (opcional - el backend actual no lo envía)
/// - `data.user` → `user` (UserModel)
/// - `data.message` → `message`
class LoginResponseModel extends Equatable {
  final String? token;
  final UserModel user;
  final String message;

  const LoginResponseModel({
    this.token,
    required this.user,
    required this.message,
  });

  /// Parse desde JSON de respuesta PostgreSQL
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String,
    );
  }

  /// Convierte a JSON para persistencia
  Map<String, dynamic> toJson() {
    return {
      if (token != null) 'token': token,
      'user': user.toJson(),
      'message': message,
    };
  }

  @override
  List<Object?> get props => [token, user, message];
}
