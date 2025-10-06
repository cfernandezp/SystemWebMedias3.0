import 'package:system_web_medias/features/user/domain/entities/user_profile.dart';

/// Model que extiende Entity y agrega serialización JSON
/// Mapea la respuesta de get_user_profile() desde PostgreSQL
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.nombreCompleto,
    required super.email,
    required super.rol,
    super.avatarUrl,
    required super.sidebarCollapsed,
  });

  /// Factory: Desde JSON del backend
  /// Mapping snake_case → camelCase
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      nombreCompleto: json['nombre_completo'] as String, // snake_case → camelCase
      email: json['email'] as String,
      rol: json['rol'] as String,
      avatarUrl: json['avatar_url'] as String?, // snake_case → camelCase
      sidebarCollapsed: json['sidebar_collapsed'] as bool, // snake_case → camelCase
    );
  }

  /// Convertir a JSON
  /// Mapping camelCase → snake_case
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_completo': nombreCompleto, // camelCase → snake_case
      'email': email,
      'rol': rol,
      'avatar_url': avatarUrl, // camelCase → snake_case
      'sidebar_collapsed': sidebarCollapsed, // camelCase → snake_case
    };
  }

  /// CopyWith para actualizar sidebar_collapsed
  UserProfileModel copyWith({
    String? id,
    String? nombreCompleto,
    String? email,
    String? rol,
    String? avatarUrl,
    bool? sidebarCollapsed,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
    );
  }
}