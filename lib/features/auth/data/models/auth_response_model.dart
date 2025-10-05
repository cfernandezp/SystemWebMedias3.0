import 'package:equatable/equatable.dart';

class AuthResponseModel extends Equatable {
  final String? id;
  final String? email;
  final String? nombreCompleto;
  final String? estado;
  final bool? emailVerificado;
  final DateTime? createdAt;
  final String message;

  const AuthResponseModel({
    this.id,
    this.email,
    this.nombreCompleto,
    this.estado,
    this.emailVerificado,
    this.createdAt,
    required this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      id: json['id'] as String?,
      email: json['email'] as String?,
      nombreCompleto: json['nombre_completo'] as String?,
      estado: json['estado'] as String?,
      emailVerificado: json['email_verificado'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      message: json['message'] as String,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        nombreCompleto,
        estado,
        emailVerificado,
        createdAt,
        message,
      ];
}
