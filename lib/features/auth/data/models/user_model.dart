import 'package:system_web_medias/features/auth/domain/entities/user.dart';

/// Model que extiende Entity y agrega serialización JSON
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.nombreCompleto,
    super.rol,
    required super.estado,
    required super.emailVerificado,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Mapping desde JSON (Backend snake_case → Dart camelCase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      rol: UserRole.fromString(json['rol'] as String?),
      estado: json['estado'] != null
          ? UserEstado.fromString(json['estado'] as String)
          : UserEstado.registrado, // Default si no viene del backend
      emailVerificado: json['email_verificado'] as bool,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(), // Default si no viene del backend
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(), // Default si no viene del backend
    );
  }

  /// Mapping a JSON (Dart camelCase → Backend snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre_completo': nombreCompleto,
      'rol': rol?.value,
      'estado': estado.value,
      'email_verificado': emailVerificado,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// CopyWith para inmutabilidad
  UserModel copyWith({
    String? id,
    String? email,
    String? nombreCompleto,
    UserRole? rol,
    UserEstado? estado,
    bool? emailVerificado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
      emailVerificado: emailVerificado ?? this.emailVerificado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
