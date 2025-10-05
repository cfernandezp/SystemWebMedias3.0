# Models Dart - HU-002: Login al Sistema

**HU relacionada**: E001-HU-002
**Estado**: 🔵 En Desarrollo

**DISEÑADO POR**: @web-architect-expert (2025-10-05)
**IMPLEMENTADO POR**: @flutter-expert (PENDIENTE)

---

## Modelo 1: LoginRequestModel

### Propósito:
Representa la solicitud de login con credenciales del usuario.

### Diseño Propuesto:

```dart
// lib/features/auth/data/models/login_request_model.dart

class LoginRequestModel {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequestModel({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'p_email': email,
      'p_password': password,
      'p_remember_me': rememberMe,
    };
  }
}
```

### Campos:

| Campo Dart | Tipo | Obligatorio | Mapea a BD | Descripción |
|------------|------|-------------|------------|-------------|
| `email` | String | ✅ | `p_email` | Email del usuario |
| `password` | String | ✅ | `p_password` | Contraseña en texto plano |
| `rememberMe` | bool | ❌ (default: false) | `p_remember_me` | Checkbox "Recordarme" |

---

## Modelo 2: LoginResponseModel

### Propósito:
Representa la respuesta exitosa del login con token y datos del usuario.

### Diseño Propuesto:

```dart
// lib/features/auth/data/models/login_response_model.dart

import 'package:equatable/equatable.dart';
import 'user_model.dart';

class LoginResponseModel extends Equatable {
  final String token;
  final UserModel user;
  final String message;

  const LoginResponseModel({
    required this.token,
    required this.user,
    required this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'message': message,
    };
  }

  @override
  List<Object?> get props => [token, user, message];
}
```

### Campos:

| Campo Dart | Tipo | Descripción |
|------------|------|-------------|
| `token` | String | JWT token (base64) para autenticación |
| `user` | UserModel | Datos del usuario autenticado |
| `message` | String | Mensaje de bienvenida (ej: "Bienvenido Juan Pérez") |

### JSON Response Esperado:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-here",
    "email": "user@example.com",
    "nombre_completo": "Juan Pérez",
    "rol": "VENDEDOR",
    "estado": "APROBADO"
  },
  "message": "Bienvenido Juan Pérez"
}
```

---

## Modelo 3: ValidateTokenResponseModel

### Propósito:
Representa la respuesta de validación de token.

### Diseño Propuesto:

```dart
// lib/features/auth/data/models/validate_token_response_model.dart

import 'package:equatable/equatable.dart';
import 'user_model.dart';

class ValidateTokenResponseModel extends Equatable {
  final UserModel user;

  const ValidateTokenResponseModel({
    required this.user,
  });

  factory ValidateTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return ValidateTokenResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
    };
  }

  @override
  List<Object?> get props => [user];
}
```

---

## Actualización: UserModel (de HU-001)

### Campos existentes en HU-001:

```dart
class UserModel extends Equatable {
  final String id;
  final String email;
  final String nombreCompleto;
  final String? rol;              // ← Usado en HU-002 para autorización
  final String estado;             // ← Usado en HU-002 para validación
  final bool emailVerificado;      // ← Usado en HU-002 para login
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ... resto del código
}
```

**✅ NO requiere cambios**: Todos los campos necesarios ya existen en HU-001.

---

## Entidad de Dominio: User (Sin cambios)

### Ubicación:
`lib/features/auth/domain/entities/user.dart`

**✅ NO requiere cambios**: La entidad User de HU-001 ya tiene todos los campos necesarios.

---

## Modelo 4: AuthStateModel (Nuevo)

### Propósito:
Representa el estado de autenticación persistido localmente.

### Diseño Propuesto:

```dart
// lib/features/auth/data/models/auth_state_model.dart

import 'package:equatable/equatable.dart';
import 'user_model.dart';

class AuthStateModel extends Equatable {
  final String token;
  final UserModel user;
  final DateTime tokenExpiration;

  const AuthStateModel({
    required this.token,
    required this.user,
    required this.tokenExpiration,
  });

  factory AuthStateModel.fromJson(Map<String, dynamic> json) {
    return AuthStateModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      tokenExpiration: DateTime.parse(json['token_expiration'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'token_expiration': tokenExpiration.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(tokenExpiration);

  @override
  List<Object?> get props => [token, user, tokenExpiration];
}
```

### Campos:

| Campo Dart | Tipo | Descripción |
|------------|------|-------------|
| `token` | String | JWT token guardado en SecureStorage |
| `user` | UserModel | Datos del usuario autenticado |
| `tokenExpiration` | DateTime | Fecha de expiración del token |

### Uso:
Se guarda en **Flutter SecureStorage** para implementar sesiones persistentes (CA-009).

---

## Resumen de Mapping BD ↔ Dart

### Login Request (Dart → PostgreSQL):

| Dart | PostgreSQL Function Param |
|------|---------------------------|
| `email` | `p_email` |
| `password` | `p_password` |
| `rememberMe` | `p_remember_me` |

### Login Response (PostgreSQL → Dart):

| PostgreSQL JSON | Dart Field |
|-----------------|------------|
| `token` | `token` |
| `user.id` | `user.id` |
| `user.email` | `user.email` |
| `user.nombre_completo` | `user.nombreCompleto` |
| `user.rol` | `user.rol` |
| `user.estado` | `user.estado` |
| `message` | `message` |

---

## Archivos a Crear:

```
lib/features/auth/data/models/
├── login_request_model.dart          ← NUEVO (HU-002)
├── login_response_model.dart         ← NUEVO (HU-002)
├── validate_token_response_model.dart ← NUEVO (HU-002)
├── auth_state_model.dart             ← NUEVO (HU-002)
├── user_model.dart                   ← YA EXISTE (HU-001)
├── register_request_model.dart       ← YA EXISTE (HU-001)
└── auth_response_model.dart          ← YA EXISTE (HU-001)
```

---

## Implementación Final:

✅ **COMPLETADO** - Implementado por @flutter-expert (2025-10-05)

### Checklist de Validación:

- [x] `LoginRequestModel` con mapping a `p_*` params
- [x] `LoginResponseModel.fromJson()` con parsing correcto
- [x] `ValidateTokenResponseModel.fromJson()` con parsing correcto
- [x] `AuthStateModel` con getter `isExpired`
- [x] Todos los modelos con `Equatable` para comparaciones
- [x] Tests unitarios con coverage 100% (13/13 tests pasando)

### Tests Ejecutados:

```bash
flutter test test/features/auth/data/models/
# 13 tests pasando:
# - LoginRequestModel: 3 tests
# - LoginResponseModel: 4 tests
# - AuthStateModel: 6 tests
```

---

## Cambios vs Diseño Inicial:

✅ **SIN CAMBIOS** - La implementación sigue exactamente el diseño propuesto.

### Archivos Creados:

```
lib/features/auth/data/models/
├── login_request_model.dart          ✅ Implementado
├── login_response_model.dart         ✅ Implementado
├── validate_token_response_model.dart ✅ Implementado
└── auth_state_model.dart             ✅ Implementado

test/features/auth/data/models/
├── login_request_model_test.dart     ✅ 3 tests pasando
├── login_response_model_test.dart    ✅ 4 tests pasando
└── auth_state_model_test.dart        ✅ 6 tests pasando
```

### Dependencias Agregadas:

- `flutter_secure_storage: ^9.0.0` (para persistencia de sesión)
