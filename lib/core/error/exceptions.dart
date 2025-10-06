/// Base class para todas las exceptions
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException([super.message = 'Error del servidor', super.statusCode]);
}

class ValidationException extends AppException {
  ValidationException([super.message = 'Error de validación', super.statusCode = 400]);
}

class DuplicateEmailException extends AppException {
  DuplicateEmailException([super.message = 'Email duplicado', super.statusCode = 409]);
}

class InvalidTokenException extends AppException {
  InvalidTokenException([super.message = 'Token inválido', super.statusCode = 400]);
}

class RateLimitException extends AppException {
  RateLimitException([super.message = 'Límite excedido', super.statusCode = 429]);
}

class EmailAlreadyVerifiedException extends AppException {
  EmailAlreadyVerifiedException([super.message = 'Email ya verificado', super.statusCode = 400]);
}

class NetworkException extends AppException {
  NetworkException([super.message = 'Sin conexión a internet']);
}

/// HU-002: Login exceptions
class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'No autorizado', super.statusCode = 401]);
}

class EmailNotVerifiedException extends AppException {
  EmailNotVerifiedException([super.message = 'Email no verificado', super.statusCode = 403]);
}

class UserNotApprovedException extends AppException {
  UserNotApprovedException([super.message = 'Usuario no aprobado', super.statusCode = 403]);
}

/// E003-HU-001: Dashboard exceptions
class NotFoundException extends AppException {
  NotFoundException([super.message = 'Recurso no encontrado', super.statusCode = 404]);
}

class ForbiddenException extends AppException {
  ForbiddenException([super.message = 'Operación no permitida', super.statusCode = 403]);
}

/// E001-HU-003: Logout Seguro exceptions
class TokenBlacklistedException extends AppException {
  TokenBlacklistedException([super.message = 'Token ya invalidado', super.statusCode = 401]);
}

class AlreadyLoggedOutException extends AppException {
  AlreadyLoggedOutException([super.message = 'Ya has cerrado sesión', super.statusCode = 400]);
}

class UserNotFoundException extends AppException {
  UserNotFoundException([super.message = 'Usuario no encontrado', super.statusCode = 404]);
}

/// E001-HU-004: Password Recovery exceptions
class ExpiredTokenException extends AppException {
  ExpiredTokenException([super.message = 'Enlace de recuperación expirado', super.statusCode = 400]);
}

class UsedTokenException extends AppException {
  UsedTokenException([super.message = 'Enlace ya utilizado', super.statusCode = 400]);
}

class WeakPasswordException extends AppException {
  WeakPasswordException([super.message = 'Contraseña muy débil', super.statusCode = 400]);
}
