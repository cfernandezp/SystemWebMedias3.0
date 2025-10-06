import 'package:equatable/equatable.dart';

/// Modelo para logs de auditoría de seguridad.
///
/// Implementa HU-003 (Logout Seguro).
///
/// Mapping BD ↔ Dart:
/// - `id` → `id`
/// - `event_type` → `eventType`
/// - `event_subtype` → `eventSubtype`
/// - `ip_address` → `ipAddress`
/// - `user_agent` → `userAgent`
/// - `metadata` → `metadata`
/// - `created_at` → `createdAt`
class AuditLogModel extends Equatable {
  final String id;
  final String eventType;
  final String? eventSubtype;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const AuditLogModel({
    required this.id,
    required this.eventType,
    this.eventSubtype,
    this.ipAddress,
    this.userAgent,
    this.metadata,
    required this.createdAt,
  });

  /// Crea una instancia desde JSON de Supabase.
  ///
  /// Mapea snake_case a camelCase según convenciones.
  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String,
      eventType: json['event_type'] as String,
      eventSubtype: json['event_subtype'] as String?,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        eventType,
        eventSubtype,
        ipAddress,
        userAgent,
        metadata,
        createdAt,
      ];
}
