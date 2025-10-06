import 'package:equatable/equatable.dart';

/// Modelo para verificar si un token está en blacklist.
///
/// Implementa HU-003 (Logout Seguro).
///
/// Mapping BD ↔ Dart:
/// - `is_blacklisted` → `isBlacklisted`
/// - `reason` → `reason`
/// - `message` → `message`
class TokenBlacklistCheckModel extends Equatable {
  final bool isBlacklisted;
  final String? reason;
  final String message;

  const TokenBlacklistCheckModel({
    required this.isBlacklisted,
    this.reason,
    required this.message,
  });

  /// Crea una instancia desde JSON de Supabase.
  ///
  /// Mapea snake_case a camelCase según convenciones.
  factory TokenBlacklistCheckModel.fromJson(Map<String, dynamic> json) {
    return TokenBlacklistCheckModel(
      isBlacklisted: json['is_blacklisted'] as bool,
      reason: json['reason'] as String?,
      message: json['message'] as String,
    );
  }

  @override
  List<Object?> get props => [isBlacklisted, reason, message];
}
