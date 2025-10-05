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
