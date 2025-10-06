import 'package:equatable/equatable.dart';

/// HU-004: Model para respuesta de validación de token de recuperación
class ValidateResetTokenModel extends Equatable {
  final bool valid;
  final String? userId;
  final DateTime? expiresAt;

  const ValidateResetTokenModel({
    required this.valid,
    this.userId,
    this.expiresAt,
  });

  /// Crear desde JSON del backend (snake_case → camelCase)
  factory ValidateResetTokenModel.fromJson(Map<String, dynamic> json) {
    return ValidateResetTokenModel(
      valid: json['is_valid'] as bool, // Backend retorna 'is_valid'
      userId: json['user_id'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [valid, userId, expiresAt];

  @override
  String toString() =>
      'ValidateResetTokenModel(valid: $valid, userId: $userId, expiresAt: $expiresAt)';
}
