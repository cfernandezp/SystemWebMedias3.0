import 'package:equatable/equatable.dart';

/// Entity pura de perfil de usuario con lógica de negocio
/// NO contiene lógica de serialización (eso es responsabilidad del Model)
class UserProfile extends Equatable {
  final String id;
  final String nombreCompleto;
  final String email;
  final String rol;
  final String? avatarUrl;
  final bool sidebarCollapsed;

  const UserProfile({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.rol,
    this.avatarUrl,
    required this.sidebarCollapsed,
  });

  /// Lógica de negocio: Obtener iniciales del nombre
  String get initials {
    final parts = nombreCompleto.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '??';
  }

  /// Lógica de negocio: Obtener badge de rol con estilo legible
  String get roleBadge {
    switch (rol.toUpperCase()) {
      case 'ADMIN':
        return 'Administrador';
      case 'GERENTE':
        return 'Gerente';
      case 'VENDEDOR':
        return 'Vendedor';
      default:
        return rol;
    }
  }

  /// Lógica de negocio: Verificar si tiene avatar configurado
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  @override
  List<Object?> get props => [id, nombreCompleto, email, rol, avatarUrl, sidebarCollapsed];
}
