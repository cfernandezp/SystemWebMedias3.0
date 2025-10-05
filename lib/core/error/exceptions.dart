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
