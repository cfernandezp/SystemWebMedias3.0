/// Modelo de solicitud de login
///
/// Implementa HU-002 (Login al Sistema)
/// Mapea credenciales de usuario a parámetros de función PostgreSQL
///
/// Mapping Dart → PostgreSQL:
/// - `email` → `p_email`
/// - `password` → `p_password`
/// - `rememberMe` → `p_remember_me`
class LoginRequestModel {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequestModel({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  /// Convierte a JSON para RPC call a `login_user()`
  Map<String, dynamic> toJson() {
    return {
      'p_email': email,
      'p_password': password,
      'p_remember_me': rememberMe,
    };
  }
}
