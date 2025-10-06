import 'package:equatable/equatable.dart';

/// HU-004: Model para respuesta de solicitud de recuperación
class PasswordResetResponseModel extends Equatable {
  final String message;
  final bool emailSent;
  final String? token;
  final DateTime? expiresAt;

  const PasswordResetResponseModel({
    required this.message,
    required this.emailSent,
    this.token,
    this.expiresAt,
  });

  /// Crear desde JSON del backend (snake_case → camelCase)
  factory PasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponseModel(
      message: json['message'] as String,
      emailSent: json['email_sent'] as bool,
      token: json['token'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [message, emailSent, token, expiresAt];

  @override
  String toString() =>
      'PasswordResetResponseModel(message: $message, emailSent: $emailSent, token: $token, expiresAt: $expiresAt)';
}
