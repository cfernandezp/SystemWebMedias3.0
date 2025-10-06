import 'package:equatable/equatable.dart';

/// Modelo para estado de inactividad del usuario.
///
/// Implementa HU-003 (Logout Seguro).
///
/// Mapping BD ↔ Dart:
/// - `is_inactive` → `isInactive`
/// - `last_activity_at` → `lastActivityAt`
/// - `inactive_minutes` → `inactiveMinutes`
/// - `minutes_until_logout` → `minutesUntilLogout`
/// - `should_warn` → `shouldWarn`
/// - `message` → `message`
class InactivityStatusModel extends Equatable {
  final bool isInactive;
  final DateTime lastActivityAt;
  final int inactiveMinutes;
  final int minutesUntilLogout;
  final bool shouldWarn;
  final String message;

  const InactivityStatusModel({
    required this.isInactive,
    required this.lastActivityAt,
    required this.inactiveMinutes,
    required this.minutesUntilLogout,
    required this.shouldWarn,
    required this.message,
  });

  /// Crea una instancia desde JSON de Supabase.
  ///
  /// Mapea snake_case a camelCase según convenciones.
  factory InactivityStatusModel.fromJson(Map<String, dynamic> json) {
    return InactivityStatusModel(
      isInactive: json['is_inactive'] as bool,
      lastActivityAt: DateTime.parse(json['last_activity_at'] as String),
      inactiveMinutes: (json['inactive_minutes'] as num).toInt(),
      minutesUntilLogout: (json['minutes_until_logout'] as num).toInt(),
      shouldWarn: json['should_warn'] as bool,
      message: json['message'] as String,
    );
  }

  @override
  List<Object> get props => [
        isInactive,
        lastActivityAt,
        inactiveMinutes,
        minutesUntilLogout,
        shouldWarn,
        message,
      ];
}
