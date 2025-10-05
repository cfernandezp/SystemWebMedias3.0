import 'package:equatable/equatable.dart';

enum UserRole {
  admin('ADMIN'),
  gerente('GERENTE'),
  vendedor('VENDEDOR');

  final String value;
  const UserRole(this.value);

  static UserRole? fromString(String? value) {
    if (value == null) return null;
    try {
      return UserRole.values.firstWhere(
        (e) => e.value == value,
      );
    } catch (e) {
      throw ArgumentError('Invalid role: $value');
    }
  }
}

enum UserEstado {
  registrado('REGISTRADO'),
  aprobado('APROBADO'),
  rechazado('RECHAZADO'),
  suspendido('SUSPENDIDO');

  final String value;
  const UserEstado(this.value);

  static UserEstado fromString(String value) {
    try {
      return UserEstado.values.firstWhere(
        (e) => e.value == value,
      );
    } catch (e) {
      throw ArgumentError('Invalid estado: $value');
    }
  }
}

/// Entity pura con lógica de negocio
class User extends Equatable {
  final String id;
  final String email;
  final String nombreCompleto;
  final UserRole? rol;
  final UserEstado estado;
  final bool emailVerificado;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.nombreCompleto,
    this.rol,
    required this.estado,
    required this.emailVerificado,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        nombreCompleto,
        rol,
        estado,
        emailVerificado,
        createdAt,
        updatedAt,
      ];

  // Lógica de negocio pura
  bool get isApproved => estado == UserEstado.aprobado;
  bool get canLogin => isApproved && emailVerificado;
  bool get isAdmin => rol == UserRole.admin;
  bool get isGerente => rol == UserRole.gerente;
  bool get isVendedor => rol == UserRole.vendedor;
}
