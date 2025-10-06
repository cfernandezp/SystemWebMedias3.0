import 'package:equatable/equatable.dart';

/// Modelo de respuesta de logout.
///
/// Implementa HU-003 (Logout Seguro).
///
/// Mapping BD ↔ Dart:
/// - `message` → `message`
/// - `logout_type` → `logoutType`
/// - `blacklisted_at` → `blacklistedAt`
class LogoutResponseModel extends Equatable {
  final String message;
  final String logoutType;
  final DateTime blacklistedAt;

  const LogoutResponseModel({
    required this.message,
    required this.logoutType,
    required this.blacklistedAt,
  });

  /// Crea una instancia desde JSON de Supabase.
  ///
  /// Mapea snake_case a camelCase según convenciones.
  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) {
    return LogoutResponseModel(
      message: json['message'] as String,
      logoutType: json['logout_type'] as String,
      blacklistedAt: DateTime.parse(json['blacklisted_at'] as String),
    );
  }

  @override
  List<Object> get props => [message, logoutType, blacklistedAt];
}
