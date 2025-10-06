import 'package:equatable/equatable.dart';

/// Base class para todos los failures
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Errores de servidor (500, 502, etc)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Errores de conexión (no internet)
class ConnectionFailure extends Failure {
  const ConnectionFailure([super.message = 'Sin conexión a internet']);
}

/// Errores de validación (400)
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Error de validación']);
}

/// Email duplicado (409)
class DuplicateEmailFailure extends Failure {
  const DuplicateEmailFailure([super.message = 'Este email ya está registrado']);
}

/// Token inválido o expirado (400)
class InvalidTokenFailure extends Failure {
  const InvalidTokenFailure([super.message = 'Enlace inválido o expirado']);
}

/// Límite de intentos excedido (429)
class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message = 'Demasiados intentos. Intenta más tarde']);
}

/// Email ya verificado
class EmailAlreadyVerifiedFailure extends Failure {
  const EmailAlreadyVerifiedFailure([super.message = 'Este email ya fue confirmado']);
}

/// Error genérico
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Error inesperado']);
}

/// HU-002: Login failures
/// No autorizado (401)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'No autorizado']);
}

/// Email no verificado (403)
class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure([super.message = 'Debes verificar tu email primero']);
}

/// Usuario no aprobado (403)
class UserNotApprovedFailure extends Failure {
  const UserNotApprovedFailure([super.message = 'Tu cuenta no ha sido aprobada']);
}

/// E003-HU-001: Dashboard failures
/// Recurso no encontrado (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}

/// Operación no permitida (403)
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'No tienes permisos para esta operación']);
}

/// E001-HU-003: Logout Seguro failures
/// Token ya invalidado (401)
class TokenBlacklistedFailure extends Failure {
  const TokenBlacklistedFailure([super.message = 'Token ya invalidado. Inicia sesión nuevamente']);
}

/// Ya cerró sesión (400)
class AlreadyLoggedOutFailure extends Failure {
  const AlreadyLoggedOutFailure([super.message = 'Ya has cerrado sesión']);
}

/// Usuario no encontrado (404)
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([super.message = 'Usuario no encontrado']);
}

/// E001-HU-004: Password Recovery failures
/// Token expirado (400)
class ExpiredTokenFailure extends Failure {
  const ExpiredTokenFailure([super.message = 'Enlace de recuperación expirado. Solicita uno nuevo']);
}

/// Token ya usado (400)
class UsedTokenFailure extends Failure {
  const UsedTokenFailure([super.message = 'Enlace ya utilizado. Solicita uno nuevo']);
}

/// Contraseña débil (400)
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([super.message = 'La contraseña debe tener al menos 8 caracteres']);
}
