import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/auth/data/models/user_model.dart';

/// Modelo de estado de autenticación persistido localmente
///
/// Implementa HU-002 (Login al Sistema)
/// Se guarda en Flutter SecureStorage para sesiones persistentes (CA-009)
///
/// Mapping Dart ↔ SecureStorage:
/// - `token` → `token`
/// - `user` → `user` (objeto serializado)
/// - `tokenExpiration` → `token_expiration` (ISO 8601)
class AuthStateModel extends Equatable {
  final String token;
  final UserModel user;
  final DateTime tokenExpiration;

  const AuthStateModel({
    required this.token,
    required this.user,
    required this.tokenExpiration,
  });

  /// Parse desde JSON de SecureStorage
  factory AuthStateModel.fromJson(Map<String, dynamic> json) {
    return AuthStateModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tokenExpiration: DateTime.parse(json['token_expiration'] as String),
    );
  }

  /// Convierte a JSON para guardar en SecureStorage
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'token_expiration': tokenExpiration.toIso8601String(),
    };
  }

  /// Verifica si el token ha expirado
  bool get isExpired => DateTime.now().isAfter(tokenExpiration);

  @override
  List<Object?> get props => [token, user, tokenExpiration];
}
