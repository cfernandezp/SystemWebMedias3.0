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

/// E002-HU-001: Gestionar Catálogo de Marcas exceptions
class DuplicateCodigoException extends AppException {
  DuplicateCodigoException([super.message = 'Este código ya existe, ingresa otro', super.statusCode = 409]);
}

class DuplicateNombreException extends AppException {
  DuplicateNombreException([super.message = 'Ya existe una marca con este nombre', super.statusCode = 409]);
}

class InvalidCodigoException extends AppException {
  InvalidCodigoException([super.message = 'Código inválido', super.statusCode = 400]);
}

class MarcaNotFoundException extends AppException {
  MarcaNotFoundException([super.message = 'La marca no existe', super.statusCode = 404]);
}

/// E002-HU-002: Gestionar Catálogo de Materiales exceptions
class DuplicateCodeException extends AppException {
  DuplicateCodeException([super.message = 'Este código ya existe, ingresa otro', super.statusCode = 409]);
}

class DuplicateNameException extends AppException {
  DuplicateNameException([super.message = 'Ya existe un material con este nombre', super.statusCode = 409]);
}

class MaterialNotFoundException extends AppException {
  MaterialNotFoundException([super.message = 'El material no existe', super.statusCode = 404]);
}

/// E002-HU-003: Gestionar Catálogo de Tipos exceptions
class TipoNotFoundException extends AppException {
  TipoNotFoundException([super.message = 'El tipo no existe', super.statusCode = 404]);
}

/// E002-HU-004: Gestionar Sistemas de Tallas exceptions
class DuplicateValueException extends AppException {
  DuplicateValueException([super.message = 'Este valor ya existe en el sistema', super.statusCode = 409]);
}

class OverlappingRangesException extends AppException {
  OverlappingRangesException([super.message = 'Los rangos no pueden superponerse', super.statusCode = 400]);
}

class LastValueException extends AppException {
  LastValueException([super.message = 'No se puede eliminar el último valor del sistema', super.statusCode = 400]);
}

class ValorUsedByProductsException extends AppException {
  ValorUsedByProductsException([super.message = 'Este valor está siendo usado por productos', super.statusCode = 400]);
}

class SistemaNotFoundException extends AppException {
  SistemaNotFoundException([super.message = 'El sistema de tallas no existe', super.statusCode = 404]);
}

class ValorNotFoundException extends AppException {
  ValorNotFoundException([super.message = 'El valor de talla no existe', super.statusCode = 404]);
}

/// E002-HU-005: Gestionar Catálogo de Colores exceptions
class InvalidHexFormatException extends AppException {
  InvalidHexFormatException([super.message = 'Formato hexadecimal inválido', super.statusCode = 400]);
}

class ColorNotFoundException extends AppException {
  ColorNotFoundException([super.message = 'El color no existe', super.statusCode = 404]);
}

class ColorInUseException extends AppException {
  ColorInUseException([super.message = 'Color en uso, solo se puede desactivar', super.statusCode = 400]);
}

/// E002-HU-006: Crear Producto Maestro exceptions
class DuplicateCombinationException extends AppException {
  DuplicateCombinationException([super.message = 'Ya existe un producto con esta combinación', super.statusCode = 409]);
}

class DuplicateCombinationInactiveException extends AppException {
  final String? productoId;

  DuplicateCombinationInactiveException(
    String message,
    int statusCode, {
    this.productoId,
  }) : super(message, statusCode);
}

class InactiveCatalogException extends AppException {
  InactiveCatalogException([super.message = 'Uno o más catálogos están inactivos', super.statusCode = 400]);
}

class HasDerivedArticlesException extends AppException {
  final int? totalArticles;

  HasDerivedArticlesException(
    String message,
    int statusCode, {
    this.totalArticles,
  }) : super(message, statusCode);
}

class ProductoMaestroNotFoundException extends AppException {
  ProductoMaestroNotFoundException([super.message = 'Producto maestro no encontrado', super.statusCode = 404]);
}

/// E002-HU-007: Especializar Artículos con Colores exceptions
class DuplicateSkuException extends AppException {
  DuplicateSkuException([super.message = 'Este SKU ya existe para otro artículo', super.statusCode = 409]);
}

class InvalidColorCountException extends AppException {
  InvalidColorCountException([super.message = 'Cantidad de colores inválida', super.statusCode = 400]);
}

class ColorInactiveException extends AppException {
  ColorInactiveException([super.message = 'Uno o más colores están inactivos', super.statusCode = 400]);
}

class InvalidPriceException extends AppException {
  InvalidPriceException([super.message = 'El precio debe ser mayor a 0', super.statusCode = 400]);
}

class ArticuloNotFoundException extends AppException {
  ArticuloNotFoundException([super.message = 'Artículo no encontrado', super.statusCode = 404]);
}

class ArticuloHasStockException extends AppException {
  ArticuloHasStockException([super.message = 'No se puede eliminar. El artículo tiene stock en tiendas', super.statusCode = 400]);
}

