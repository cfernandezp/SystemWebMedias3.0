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

/// E002-HU-001: Gestionar Catálogo de Marcas failures
/// Código duplicado (409)
class DuplicateCodigoFailure extends Failure {
  const DuplicateCodigoFailure([super.message = 'Este código ya existe, ingresa otro']);
}

/// Nombre duplicado (409)
class DuplicateNombreFailure extends Failure {
  const DuplicateNombreFailure([super.message = 'Ya existe una marca con este nombre']);
}

/// Código inválido (400)
class InvalidCodigoFailure extends Failure {
  const InvalidCodigoFailure([super.message = 'Código solo puede contener letras mayúsculas']);
}

/// Marca no encontrada (404)
class MarcaNotFoundFailure extends Failure {
  const MarcaNotFoundFailure([super.message = 'La marca no existe']);
}

/// E002-HU-002: Gestionar Catálogo de Materiales failures
/// Código duplicado (409)
class DuplicateCodeFailure extends Failure {
  const DuplicateCodeFailure([super.message = 'Este código ya existe, ingresa otro']);
}

/// Nombre duplicado (409)
class DuplicateNameFailure extends Failure {
  const DuplicateNameFailure([super.message = 'Ya existe un material con este nombre']);
}

/// Material no encontrado (404)
class MaterialNotFoundFailure extends Failure {
  const MaterialNotFoundFailure([super.message = 'El material no existe']);
}

/// Tipo no encontrado (404)
class TipoNotFoundFailure extends Failure {
  const TipoNotFoundFailure([super.message = 'El tipo no existe']);
}

/// E002-HU-004: Gestionar Sistemas de Tallas failures
/// Valor duplicado (409)
class DuplicateValueFailure extends Failure {
  const DuplicateValueFailure([super.message = 'Este valor ya existe en el sistema']);
}

/// Rangos superpuestos (400)
class OverlappingRangesFailure extends Failure {
  const OverlappingRangesFailure([super.message = 'Los rangos no pueden superponerse']);
}

/// Último valor (400)
class LastValueFailure extends Failure {
  const LastValueFailure([super.message = 'No se puede eliminar el último valor del sistema']);
}

/// Valor usado por productos (400)
class ValorUsedByProductsFailure extends Failure {
  const ValorUsedByProductsFailure([super.message = 'Este valor está siendo usado por productos']);
}

/// Sistema no encontrado (404)
class SistemaNotFoundFailure extends Failure {
  const SistemaNotFoundFailure([super.message = 'El sistema de tallas no existe']);
}

/// Valor no encontrado (404)
class ValorNotFoundFailure extends Failure {
  const ValorNotFoundFailure([super.message = 'El valor de talla no existe']);
}

/// E002-HU-006: Crear Producto Maestro failures
/// Combinación duplicada (409)
class DuplicateCombinationFailure extends Failure {
  const DuplicateCombinationFailure([super.message = 'Ya existe un producto con esta combinación']);
}

/// Combinación duplicada inactiva (409)
class DuplicateCombinationInactiveFailure extends Failure {
  final String? productoId;

  const DuplicateCombinationInactiveFailure(
    String message, {
    this.productoId,
  }) : super(message);

  @override
  List<Object> get props => productoId != null ? [message, productoId!] : [message];
}

/// Catálogo inactivo (400)
class InactiveCatalogFailure extends Failure {
  const InactiveCatalogFailure([super.message = 'Uno o más catálogos están inactivos']);
}

/// Tiene artículos derivados (400)
class HasDerivedArticlesFailure extends Failure {
  final int? totalArticles;

  const HasDerivedArticlesFailure(
    String message, {
    this.totalArticles,
  }) : super(message);

  @override
  List<Object> get props => totalArticles != null ? [message, totalArticles!] : [message];
}

/// Producto maestro no encontrado (404)
class ProductoMaestroNotFoundFailure extends Failure {
  const ProductoMaestroNotFoundFailure([super.message = 'Producto maestro no encontrado']);
}

/// E004-HU-001: Catálogo de Tipos de Documento failures
/// Tipo de documento no encontrado (404)
class TipoDocumentoNotFoundFailure extends Failure {
  const TipoDocumentoNotFoundFailure([super.message = 'Tipo de documento no encontrado']);
}

/// Tipo en uso (400)
class TipoEnUsoFailure extends Failure {
  final int? personasCount;

  const TipoEnUsoFailure(
    String message, {
    this.personasCount,
  }) : super(message);

  @override
  List<Object> get props => personasCount != null ? [message, personasCount!] : [message];
}

/// Formato inválido (400)
class InvalidFormatFailure extends Failure {
  const InvalidFormatFailure([super.message = 'Formato de documento inválido']);
}

/// Longitud inválida (400)
class InvalidLengthFailure extends Failure {
  const InvalidLengthFailure([super.message = 'Longitud de documento inválida']);
}

/// E004-HU-002: Gestión de Personas failures
/// Documento duplicado (409)
class DuplicatePersonaFailure extends Failure {
  const DuplicatePersonaFailure([super.message = 'Ya existe una persona con este documento']);
}

/// Formato de documento inválido (400)
class InvalidDocumentFormatFailure extends Failure {
  const InvalidDocumentFormatFailure([super.message = 'Formato de documento inválido']);
}

/// Documento inválido para tipo persona (400)
class InvalidDocumentForPersonTypeFailure extends Failure {
  const InvalidDocumentForPersonTypeFailure([super.message = 'Tipo de documento no válido para este tipo de persona']);
}

/// Falta nombre (400)
class MissingNombreFailure extends Failure {
  const MissingNombreFailure([super.message = 'El nombre completo es obligatorio para persona natural']);
}

/// Falta razón social (400)
class MissingRazonSocialFailure extends Failure {
  const MissingRazonSocialFailure([super.message = 'La razón social es obligatoria para persona jurídica']);
}

/// Email inválido (400)
class InvalidEmailFailure extends Failure {
  const InvalidEmailFailure([super.message = 'Formato de email inválido']);
}

/// Teléfono inválido (400)
class InvalidPhoneFailure extends Failure {
  const InvalidPhoneFailure([super.message = 'El celular debe tener 9 dígitos']);
}

/// Persona no encontrada (404)
class PersonaNotFoundFailure extends Failure {
  const PersonaNotFoundFailure([super.message = 'Persona no encontrada']);
}

/// Tiene transacciones (403)
class HasTransactionsFailure extends Failure {
  const HasTransactionsFailure([super.message = 'Esta persona tiene transacciones registradas. Solo puede desactivarse']);
}

/// Ya está activa (400)
class AlreadyActiveFailure extends Failure {
  const AlreadyActiveFailure([super.message = 'La persona ya está activa']);
}

