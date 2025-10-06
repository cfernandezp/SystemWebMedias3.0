# Models Auth Module

Archivo consolidado de modelos Dart para el módulo de Autenticación.

---

## HU-001: Registro de Alta al Sistema Web {#hu-001}

### Model: User
```dart
class User extends Equatable {
  final String id;
  final String email;
  final String nombreCompleto;      // ← nombre_completo
  final String rol;
  final String estado;
  final bool emailVerificado;        // ← email_verificado
  final DateTime createdAt;          // ← created_at
  final DateTime? updatedAt;         // ← updated_at
}
```

### Model: RegisterRequestModel
```dart
class RegisterRequestModel extends Equatable {
  final String email;
  final String password;
  final String nombreCompleto;
  final String rol;
}
```

### Model: AuthResponseModel
```dart
class AuthResponseModel extends Equatable {
  final String userId;
  final String email;
  final String message;
}
```

**Status**: ✅ Implementado
**Location**: `lib/features/auth/data/models/`

---

## HU-002: Login por Roles con Aprobación {#hu-002}

### Model: LoginRequestModel
```dart
class LoginRequestModel extends Equatable {
  final String email;
  final String password;
  final bool rememberMe;
}
```

### Model: LoginResponseModel
```dart
class LoginResponseModel extends Equatable {
  final String userId;
  final String email;
  final String nombreCompleto;
  final String rol;
  final String sessionToken;
  final String message;
}
```

**Status**: ✅ Implementado

---

## HU-003: Logout Seguro {#hu-003}

### Model: LogoutRequestModel
```dart
class LogoutRequestModel extends Equatable {
  final String userId;
  final String token;
  final String logoutType;      // 'manual', 'inactivity', 'token_expired'
  final String? ipAddress;
}
```

### Model: LogoutResponseModel
```dart
class LogoutResponseModel extends Equatable {
  final String message;
}
```

### Model: InactivityStatusModel
```dart
class InactivityStatusModel extends Equatable {
  final bool isInactive;           // ← is_inactive
  final int minutesInactive;       // ← minutes_inactive
  final int warningThreshold;      // ← warning_threshold
}
```

### Model: AuditLogModel
```dart
class AuditLogModel extends Equatable {
  final String id;
  final String? userId;            // ← user_id
  final String eventType;          // ← event_type
  final String? eventSubtype;      // ← event_subtype
  final String? ipAddress;         // ← ip_address
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;        // ← created_at
}
```

**Status**: ✅ Implementado

---

## HU-004: Recuperar Contraseña {#hu-004}

### Model: PasswordResetRequestModel
```dart
/// Modelo para solicitud de recuperación de contraseña
///
/// Mapping BD ↔ Dart:
/// - `p_email` → `email`
/// - `p_ip_address` → `ipAddress` (opcional)
class PasswordResetRequestModel extends Equatable {
  final String email;
  final String? ipAddress;

  const PasswordResetRequestModel({
    required this.email,
    this.ipAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'p_email': email,
      if (ipAddress != null) 'p_ip_address': ipAddress,
    };
  }

  @override
  List<Object?> get props => [email, ipAddress];
}
```

**Location**: `lib/features/auth/data/models/password_reset_request_model.dart`

---

## Código Final Implementado - HU-004

### PasswordResetRequestModel (Implementado)
```dart
import 'package:equatable/equatable.dart';

/// HU-004: Model para solicitud de recuperación de contraseña
class PasswordResetRequestModel extends Equatable {
  final String email;

  const PasswordResetRequestModel({
    required this.email,
  });

  /// Convertir a JSON para enviar al backend (snake_case)
  Map<String, dynamic> toJson() => {
        'p_email': email,
      };

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'PasswordResetRequestModel(email: $email)';
}
```

**Diferencias vs Diseño**:
- ❌ `ipAddress` opcional eliminado (no requerido por backend en versión actual)
- ✅ `toString()` agregado para debugging
- ✅ Sintaxis simplificada en `toJson()`

---

### Model: PasswordResetResponseModel
```dart
/// Modelo para respuesta de solicitud de recuperación
///
/// Mapping BD ↔ Dart:
/// - `message` → `message`
/// - `email_sent` → `emailSent`
class PasswordResetResponseModel extends Equatable {
  final String message;
  final bool emailSent;

  const PasswordResetResponseModel({
    required this.message,
    required this.emailSent,
  });

  factory PasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponseModel(
      message: json['message'] as String,
      emailSent: json['email_sent'] as bool? ?? false,
    );
  }

  @override
  List<Object> get props => [message, emailSent];
}
```

**Location**: `lib/features/auth/data/models/password_reset_response_model.dart`

---

### PasswordResetResponseModel (Implementado)
```dart
import 'package:equatable/equatable.dart';

/// HU-004: Model para respuesta de solicitud de recuperación
class PasswordResetResponseModel extends Equatable {
  final String message;
  final bool emailSent;
  final String? token;
  final DateTime? expiresAt;

  const PasswordResetResponseModel({
    required this.message,
    required this.emailSent,
    this.token,
    this.expiresAt,
  });

  /// Crear desde JSON del backend (snake_case → camelCase)
  factory PasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponseModel(
      message: json['message'] as String,
      emailSent: json['email_sent'] as bool,
      token: json['token'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [message, emailSent, token, expiresAt];

  @override
  String toString() =>
      'PasswordResetResponseModel(message: $message, emailSent: $emailSent, token: $token, expiresAt: $expiresAt)';
}
```

**Diferencias vs Diseño**:
- ✅ `token` opcional agregado (para debug/testing)
- ✅ `expiresAt` opcional agregado (para debug/testing)
- ✅ `toString()` agregado para debugging
- ✅ Mapeo `expires_at` → `expiresAt` con parsing de DateTime

---

### Model: ValidateResetTokenModel
```dart
/// Modelo para validación de token de recuperación
///
/// Mapping BD ↔ Dart:
/// - `is_valid` → `valid`
/// - `message` → `message`
/// - `expires_at` → `expiresAt`
/// - `user_id` → `userId`
class ValidateResetTokenModel extends Equatable {
  final bool valid;
  final String message;
  final DateTime? expiresAt;
  final String? userId;

  const ValidateResetTokenModel({
    required this.valid,
    required this.message,
    this.expiresAt,
    this.userId,
  });

  factory ValidateResetTokenModel.fromJson(Map<String, dynamic> json) {
    return ValidateResetTokenModel(
      valid: json['is_valid'] as bool,  // ⚠️ Backend usa 'is_valid'
      message: json['message'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      userId: json['user_id'] as String?,
    );
  }

  @override
  List<Object?> get props => [valid, message, expiresAt, userId];
}
```

**Location**: `lib/features/auth/data/models/validate_reset_token_model.dart`

**NOTA IMPORTANTE**: Backend retorna `is_valid`, no `valid`. El mapping está corregido en línea 18.

---

### ValidateResetTokenModel (Implementado)
```dart
import 'package:equatable/equatable.dart';

/// HU-004: Model para respuesta de validación de token de recuperación
class ValidateResetTokenModel extends Equatable {
  final bool valid;
  final String? userId;
  final DateTime? expiresAt;

  const ValidateResetTokenModel({
    required this.valid,
    this.userId,
    this.expiresAt,
  });

  /// Crear desde JSON del backend (snake_case → camelCase)
  factory ValidateResetTokenModel.fromJson(Map<String, dynamic> json) {
    return ValidateResetTokenModel(
      valid: json['is_valid'] as bool, // Backend retorna 'is_valid'
      userId: json['user_id'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [valid, userId, expiresAt];

  @override
  String toString() =>
      'ValidateResetTokenModel(valid: $valid, userId: $userId, expiresAt: $expiresAt)';
}
```

**Diferencias vs Diseño**:
- ❌ `message` eliminado (no es necesario en response exitoso, mensaje viene en error)
- ✅ Mapeo correcto `is_valid` → `valid` confirmado
- ✅ `toString()` agregado para debugging
- ✅ Estructura simplificada (solo campos necesarios)

---

### Model: ResetPasswordModel
```dart
/// Modelo para cambio de contraseña con token
///
/// Mapping BD ↔ Dart:
/// - `p_token` → `token`
/// - `p_new_password` → `newPassword`
/// - `p_ip_address` → `ipAddress` (opcional)
class ResetPasswordModel extends Equatable {
  final String token;
  final String newPassword;
  final String? ipAddress;

  const ResetPasswordModel({
    required this.token,
    required this.newPassword,
    this.ipAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'p_token': token,
      'p_new_password': newPassword,
      if (ipAddress != null) 'p_ip_address': ipAddress,
    };
  }

  @override
  List<Object?> get props => [token, newPassword, ipAddress];
}
```

**Location**: `lib/features/auth/data/models/reset_password_model.dart`

---

### ResetPasswordModel (Implementado)
```dart
import 'package:equatable/equatable.dart';

/// HU-004: Model para cambiar contraseña con token
class ResetPasswordModel extends Equatable {
  final String token;
  final String newPassword;

  const ResetPasswordModel({
    required this.token,
    required this.newPassword,
  });

  /// Convertir a JSON para enviar al backend (snake_case)
  Map<String, dynamic> toJson() => {
        'p_token': token,
        'p_new_password': newPassword,
      };

  @override
  List<Object> get props => [token, newPassword];

  @override
  String toString() =>
      'ResetPasswordModel(token: ${token.substring(0, 10)}..., newPassword: ****)';
}
```

**Diferencias vs Diseño**:
- ❌ `ipAddress` opcional eliminado (no requerido por backend en versión actual)
- ✅ `toString()` agregado con seguridad (oculta password, trunca token)
- ✅ Sintaxis simplificada en `toJson()`

---

## Convenciones de Mapping

| Backend (PostgreSQL) | Frontend (Dart) | Tipo |
|----------------------|-----------------|------|
| `p_email` | `email` | String |
| `p_token` | `token` | String |
| `p_new_password` | `newPassword` | String |
| `p_ip_address` | `ipAddress` | String? |
| `message` | `message` | String |
| `email_sent` | `emailSent` | bool |
| `is_valid` | `valid` | bool |
| `expires_at` | `expiresAt` | DateTime? |
| `user_id` | `userId` | String? |

**Regla de Oro**:
- Backend: `snake_case` (PostgreSQL)
- Frontend: `camelCase` (Dart)
- Mapping EXPLÍCITO en `fromJson()` y `toJson()`

---

## Resumen de Verificación HU-004

**Fecha verificación**: 2025-10-06
**Verificado por**: @flutter-expert

### Mapeos snake_case ↔ camelCase: ✅ CORRECTO
- `is_valid` → `valid` (ValidateResetTokenModel) ✅
- `email_sent` → `emailSent` (PasswordResetResponseModel) ✅
- `expires_at` → `expiresAt` (ambos modelos) ✅
- `user_id` → `userId` (ValidateResetTokenModel) ✅
- `p_email` → `email` (PasswordResetRequestModel) ✅
- `p_token` → `token` (ResetPasswordModel) ✅
- `p_new_password` → `newPassword` (ResetPasswordModel) ✅

### Nombres RPC en DataSource: ✅ CORRECTO
- `request_password_reset` (línea 428) ✅
- `validate_reset_token` (línea 470) ✅
- `reset_password` (línea 516) ✅

### Convenciones Dart: ✅ CUMPLE
- Archivos en `snake_case` ✅
- Clases en `PascalCase` ✅
- Variables en `camelCase` ✅
- Models extienden `Equatable` ✅
- Métodos `fromJson()` y `toJson()` implementados ✅

### Compilación: ✅ SIN ERRORES CRÍTICOS
- `flutter analyze`: 14 warnings (deprecated, unused vars) - No críticos
- 0 errores de compilación
- Warnings en otros módulos (dashboard, tests) - NO relacionados con HU-004

### Diferencias vs Diseño Original:
1. **PasswordResetRequestModel**: `ipAddress` eliminado (no requerido)
2. **PasswordResetResponseModel**: `token` y `expiresAt` agregados (debug)
3. **ValidateResetTokenModel**: `message` eliminado (solo en errors)
4. **ResetPasswordModel**: `ipAddress` eliminado (no requerido)
5. **Todos los modelos**: `toString()` agregado para debugging

**Justificación**: Todas las diferencias son mejoras de implementación que no afectan la funcionalidad core ni rompen el contrato con el backend.

---

**Status**: ✅ Frontend HU-004 verificado y documentado
**Última actualización**: 2025-10-06
**Mantenido por**: @web-architect-expert
