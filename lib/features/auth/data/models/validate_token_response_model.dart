import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/auth/data/models/user_model.dart';

/// Modelo de respuesta de validación de token
///
/// Implementa HU-002 (Login al Sistema)
/// Retorna datos actualizados del usuario si el token es válido
///
/// Mapping PostgreSQL → Dart:
/// - `data.user` → `user` (UserModel)
class ValidateTokenResponseModel extends Equatable {
  final UserModel user;

  const ValidateTokenResponseModel({
    required this.user,
  });

  /// Parse desde JSON de respuesta PostgreSQL
  factory ValidateTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return ValidateTokenResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Convierte a JSON para persistencia
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
    };
  }

  @override
  List<Object?> get props => [user];
}
