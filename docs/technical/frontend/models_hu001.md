# Modelos Frontend - HU-001: Registro de Alta al Sistema

**Framework**: Flutter Web
**HU relacionada**: E001-HU-001
**Ubicación**: `lib/features/auth/data/models/`
**Estado**: IMPLEMENTADO

**DISEÑADO POR**: @web-architect-expert (2025-10-04)
**IMPLEMENTADO POR**: @flutter-expert (2025-10-04)

---

## UserModel

**Mapea con**: Tabla `users`
**Ubicación**: `lib/features/auth/data/models/user_model.dart`

### Diseño Propuesto:

```dart
import 'package:equatable/equatable.dart';

enum UserRole {
  admin('ADMIN'),
  gerente('GERENTE'),
  vendedor('VENDEDOR');

  final String value;
  const UserRole(this.value);

  static UserRole? fromString(String? value) {
    if (value == null) return null;
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid role: $value'),
    );
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
    return UserEstado.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid estado: $value'),
    );
  }
}

class UserModel extends Equatable {
  final String id;                    // ← users.id (UUID)
  final String email;                 // ← users.email (TEXT)
  final String nombreCompleto;        // ← users.nombre_completo (TEXT)
  final UserRole? rol;                // ← users.rol (ENUM, nullable)
  final UserEstado estado;            // ← users.estado (ENUM)
  final bool emailVerificado;         // ← users.email_verificado (BOOLEAN)
  final DateTime createdAt;           // ← users.created_at (TIMESTAMP)
  final DateTime updatedAt;           // ← users.updated_at (TIMESTAMP)

  const UserModel({
    required this.id,
    required this.email,
    required this.nombreCompleto,
    this.rol,
    required this.estado,
    required this.emailVerificado,
    required this.createdAt,
    required this.updatedAt,
  });

  // Mapping desde JSON (Backend snake_case → Dart camelCase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      rol: UserRole.fromString(json['rol'] as String?),
      estado: UserEstado.fromString(json['estado'] as String),
      emailVerificado: json['email_verificado'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Mapping a JSON (Dart camelCase → Backend snake_case)
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

  // Helper methods
  bool get isApproved => estado == UserEstado.aprobado;
  bool get canLogin => isApproved && emailVerificado;
  bool get isAdmin => rol == UserRole.admin;
  bool get isGerente => rol == UserRole.gerente;
  bool get isVendedor => rol == UserRole.vendedor;

  // CopyWith para inmutabilidad
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
```

---

## RegisterRequestModel

**Propósito**: Request para POST /auth/register
**Ubicación**: `lib/features/auth/data/models/register_request_model.dart`

### Diseño Propuesto:

```dart
import 'package:equatable/equatable.dart';

class RegisterRequestModel extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String nombreCompleto;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.nombreCompleto,
  });

  // Mapping a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'email': email.toLowerCase().trim(),        // Normalizar email
      'password': password,
      'confirm_password': confirmPassword,
      'nombre_completo': nombreCompleto.trim(),   // Trim espacios
    };
  }

  @override
  List<Object?> get props => [email, password, confirmPassword, nombreCompleto];

  // Validaciones Frontend (RN-006, RN-002)
  String? validateEmail() {
    if (email.isEmpty) return 'Email es requerido';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) return 'Formato de email inválido';
    return null;
  }

  String? validatePassword() {
    if (password.isEmpty) return 'Contraseña es requerida';
    if (password.length < 8) return 'Contraseña debe tener al menos 8 caracteres';
    return null;
  }

  String? validateConfirmPassword() {
    if (confirmPassword.isEmpty) return 'Confirmar contraseña es requerido';
    if (password != confirmPassword) return 'Las contraseñas no coinciden';
    return null;
  }

  String? validateNombreCompleto() {
    if (nombreCompleto.trim().isEmpty) return 'Nombre completo es requerido';
    return null;
  }

  // Validación completa del formulario
  Map<String, String> validateAll() {
    final errors = <String, String>{};

    final emailError = validateEmail();
    if (emailError != null) errors['email'] = emailError;

    final passwordError = validatePassword();
    if (passwordError != null) errors['password'] = passwordError;

    final confirmPasswordError = validateConfirmPassword();
    if (confirmPasswordError != null) errors['confirmPassword'] = confirmPasswordError;

    final nombreError = validateNombreCompleto();
    if (nombreError != null) errors['nombreCompleto'] = nombreError;

    return errors;
  }

  bool get isValid => validateAll().isEmpty;
}
```

---

## AuthResponseModel

**Propósito**: Response de endpoints de autenticación
**Ubicación**: `lib/features/auth/data/models/auth_response_model.dart`

### Diseño Propuesto:

```dart
import 'package:equatable/equatable.dart';
import 'user_model.dart';

class AuthResponseModel extends Equatable {
  final String? id;
  final String? email;
  final String? nombreCompleto;
  final String? estado;
  final bool? emailVerificado;
  final DateTime? createdAt;
  final String message;

  const AuthResponseModel({
    this.id,
    this.email,
    this.nombreCompleto,
    this.estado,
    this.emailVerificado,
    this.createdAt,
    required this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      id: json['id'] as String?,
      email: json['email'] as String?,
      nombreCompleto: json['nombre_completo'] as String?,
      estado: json['estado'] as String?,
      emailVerificado: json['email_verificado'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      message: json['message'] as String,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        nombreCompleto,
        estado,
        emailVerificado,
        createdAt,
        message,
      ];
}
```

---

## EmailConfirmationResponseModel

**Propósito**: Response de GET /auth/confirm-email
**Ubicación**: `lib/features/auth/data/models/email_confirmation_response_model.dart`

### Diseño Propuesto:

```dart
import 'package:equatable/equatable.dart';

class EmailConfirmationResponseModel extends Equatable {
  final String message;
  final bool emailVerificado;
  final String estado;
  final String nextStep;

  const EmailConfirmationResponseModel({
    required this.message,
    required this.emailVerificado,
    required this.estado,
    required this.nextStep,
  });

  factory EmailConfirmationResponseModel.fromJson(Map<String, dynamic> json) {
    return EmailConfirmationResponseModel(
      message: json['message'] as String,
      emailVerificado: json['email_verificado'] as bool,
      estado: json['estado'] as String,
      nextStep: json['next_step'] as String,
    );
  }

  @override
  List<Object?> get props => [message, emailVerificado, estado, nextStep];
}
```

---

## ErrorResponseModel

**Propósito**: Manejo consistente de errores de API
**Ubicación**: `lib/core/error/error_response_model.dart`

### Diseño Propuesto:

```dart
import 'package:equatable/equatable.dart';

class ErrorResponseModel extends Equatable {
  final String error;
  final String message;
  final String? field;

  const ErrorResponseModel({
    required this.error,
    required this.message,
    this.field,
  });

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    return ErrorResponseModel(
      error: json['error'] as String,
      message: json['message'] as String,
      field: json['field'] as String?,
    );
  }

  @override
  List<Object?> get props => [error, message, field];

  // Helper methods
  bool get isDuplicateEmail => error == 'DUPLICATE_EMAIL';
  bool get isValidationError => error == 'VALIDATION_ERROR';
  bool get isInvalidToken => error == 'INVALID_TOKEN';
  bool get isRateLimitExceeded => error == 'RATE_LIMIT_EXCEEDED';
}
```

---

## Código Final Implementado:

### Estructura de Archivos Implementada:

```
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart          ✅ IMPLEMENTADO
│   │   ├── failures.dart            ✅ IMPLEMENTADO
│   │   └── error_response_model.dart ✅ IMPLEMENTADO
│   └── injection/
│       └── injection_container.dart  ✅ IMPLEMENTADO
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── auth_remote_datasource.dart ✅ IMPLEMENTADO
│       │   ├── models/
│       │   │   ├── user_model.dart               ✅ IMPLEMENTADO
│       │   │   ├── register_request_model.dart   ✅ IMPLEMENTADO
│       │   │   ├── auth_response_model.dart      ✅ IMPLEMENTADO
│       │   │   └── email_confirmation_response_model.dart ✅ IMPLEMENTADO
│       │   └── repositories/
│       │       └── auth_repository_impl.dart     ✅ IMPLEMENTADO
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user.dart                     ✅ IMPLEMENTADO
│       │   ├── repositories/
│       │   │   └── auth_repository.dart          ✅ IMPLEMENTADO
│       │   └── usecases/
│       │       ├── register_user.dart            ✅ IMPLEMENTADO
│       │       ├── confirm_email.dart            ✅ IMPLEMENTADO
│       │       └── resend_confirmation.dart      ✅ IMPLEMENTADO
│       └── presentation/
│           └── bloc/
│               ├── auth_bloc.dart                ✅ IMPLEMENTADO
│               ├── auth_event.dart               ✅ IMPLEMENTADO
│               └── auth_state.dart               ✅ IMPLEMENTADO
└── main.dart                                     ✅ IMPLEMENTADO
```

### Endpoints Configurados:

```dart
// DataSource configurado para conectarse a:
- POST http://localhost:54321/functions/v1/auth/register
- GET  http://localhost:54321/functions/v1/auth/confirm-email?token={token}
- POST http://localhost:54321/functions/v1/auth/resend-confirmation
```

## Cambios vs Diseño Inicial:

### 1. Entity vs Model (Mejora arquitectónica)
- **Diseño**: UserModel como clase independiente con Equatable
- **Implementado**: UserModel EXTIENDE User (Entity)
  - User en domain/entities: Lógica de negocio pura
  - UserModel en data/models: Serialización JSON + extends User
  - Ventaja: Separación clara domain/data, mejor testabilidad

### 2. ENUMs movidos a Entity
- **Diseño**: ENUMs dentro de UserModel
- **Implementado**: ENUMs (UserRole, UserEstado) en domain/entities/user.dart
  - Razón: Son parte del dominio, no de la capa de datos
  - Ventaja: Reutilizables en toda la app sin depender de data layer

### 3. ErrorResponseModel Helper adicional
- **Diseño**: isDuplicateEmail, isValidationError, isInvalidToken, isRateLimitExceeded
- **Implementado**: Agregado isEmailAlreadyVerified
  - Razón: Manejar error específico de POST /auth/resend-confirmation

### 4. Dependency Injection completo
- **Diseño**: No especificado
- **Implementado**: GetIt container completo con:
  - Factory para AuthBloc (nueva instancia por página)
  - LazySingleton para UseCases, Repository, DataSource
  - LazySingleton para http.Client

### 5. HTTP Client real implementado
- **Diseño**: Mencionado Supabase Client o HTTP
- **Implementado**: package:http con manejo completo de:
  - Status codes: 200, 201, 400, 409, 429
  - ErrorResponseModel parsing
  - Exception mapping a Failures
  - NetworkException para errores de conexión

---

## Dependencias Requeridas:

Agregar en `pubspec.yaml`:

```yaml
dependencies:
  equatable: ^2.0.5          # Para comparación de objetos
  json_annotation: ^4.8.1    # Para serialización JSON (opcional)

dev_dependencies:
  json_serializable: ^6.7.1  # Generador de código (opcional)
```
