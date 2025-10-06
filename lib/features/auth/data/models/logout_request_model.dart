import 'package:equatable/equatable.dart';

/// Modelo de solicitud de logout.
///
/// Implementa HU-003 (Logout Seguro).
///
/// Mapping BD ↔ Dart:
/// - `p_token` → `token`
/// - `p_user_id` → `userId`
/// - `p_logout_type` → `logoutType`
/// - `p_ip_address` → `ipAddress`
/// - `p_user_agent` → `userAgent`
/// - `p_session_duration` → `sessionDuration`
class LogoutRequestModel extends Equatable {
  final String token;
  final String userId;
  final String logoutType; // 'manual', 'inactivity', 'token_expired'
  final String? ipAddress;
  final String? userAgent;
  final Duration? sessionDuration;

  const LogoutRequestModel({
    required this.token,
    required this.userId,
    this.logoutType = 'manual',
    this.ipAddress,
    this.userAgent,
    this.sessionDuration,
  });

  /// Convierte el modelo a JSON para enviar a Supabase.
  ///
  /// Mapea camelCase a snake_case según convenciones.
  Map<String, dynamic> toJson() {
    return {
      'p_token': token,
      'p_user_id': userId,
      'p_logout_type': logoutType,
      'p_ip_address': ipAddress,
      'p_user_agent': userAgent,
      'p_session_duration': sessionDuration?.inSeconds,
    };
  }

  @override
  List<Object?> get props => [
        token,
        userId,
        logoutType,
        ipAddress,
        userAgent,
        sessionDuration,
      ];
}
