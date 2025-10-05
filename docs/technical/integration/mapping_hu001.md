# Mapping Backend ↔ Frontend - HU-001: Registro de Alta al Sistema

**Propósito**: Garantizar consistencia entre snake_case (BD) y camelCase (Dart)
**HU relacionada**: E001-HU-001
**Última actualización**: 2025-10-04 por @web-architect-expert

---

## Tabla: users ↔ UserModel

**Backend**: `users` (snake_case)
**Frontend**: `UserModel` (camelCase)

| Backend (snake_case) | SQL Type | Frontend (camelCase) | Dart Type | RN Relacionada | Notas |
|---------------------|----------|---------------------|-----------|----------------|-------|
| `id` | UUID | `id` | String | - | Primary Key, gen_random_uuid() |
| `email` | TEXT | `email` | String | RN-001, RN-006 | UNIQUE, LOWER(email) en índice |
| `password_hash` | TEXT | - | - | RN-002 | NO exponer en frontend (seguridad) |
| `nombre_completo` | TEXT | `nombreCompleto` | String | RN-006 | NOT NULL, trim() en validación |
| `rol` | ENUM | `rol` | UserRole? | RN-007 | Nullable, valores: ADMIN, GERENTE, VENDEDOR |
| `estado` | ENUM | `estado` | UserEstado | RN-004, RN-005 | NOT NULL, valores: REGISTRADO, APROBADO, RECHAZADO, SUSPENDIDO |
| `email_verificado` | BOOLEAN | `emailVerificado` | bool | RN-003 | DEFAULT false |
| `token_confirmacion` | TEXT | - | - | RN-003 | NO exponer en frontend (seguridad) |
| `token_expiracion` | TIMESTAMP | - | - | RN-003 | NO exponer en frontend (seguridad) |
| `created_at` | TIMESTAMP | `createdAt` | DateTime | - | DEFAULT NOW() |
| `updated_at` | TIMESTAMP | `updatedAt` | DateTime | - | AUTO UPDATE via trigger |

### Ejemplo de Transformación:

**Backend Response (snake_case):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "usuario@example.com",
  "nombre_completo": "Juan Pérez",
  "rol": "VENDEDOR",
  "estado": "REGISTRADO",
  "email_verificado": false,
  "created_at": "2025-10-04T10:30:00Z",
  "updated_at": "2025-10-04T10:30:00Z"
}
```

**Frontend Model (camelCase):**
```dart
UserModel(
  id: "550e8400-e29b-41d4-a716-446655440000",
  email: "usuario@example.com",
  nombreCompleto: "Juan Pérez",
  rol: UserRole.vendedor,
  estado: UserEstado.registrado,
  emailVerificado: false,
  createdAt: DateTime(2025, 10, 4, 10, 30),
  updatedAt: DateTime(2025, 10, 4, 10, 30),
)
```

### Mapping en fromJson:

```dart
factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,                            // ← id
  email: json['email'] as String,                      // ← email
  nombreCompleto: json['nombre_completo'] as String,   // ← nombre_completo
  rol: UserRole.fromString(json['rol'] as String?),    // ← rol (nullable)
  estado: UserEstado.fromString(json['estado'] as String), // ← estado
  emailVerificado: json['email_verificado'] as bool,   // ← email_verificado
  createdAt: DateTime.parse(json['created_at'] as String), // ← created_at
  updatedAt: DateTime.parse(json['updated_at'] as String), // ← updated_at
);
```

### Mapping en toJson:

```dart
Map<String, dynamic> toJson() => {
  'id': id,                               // → id
  'email': email,                         // → email
  'nombre_completo': nombreCompleto,      // → nombre_completo
  'rol': rol?.value,                      // → rol (puede ser null)
  'estado': estado.value,                 // → estado
  'email_verificado': emailVerificado,    // → email_verificado
  'created_at': createdAt.toIso8601String(), // → created_at
  'updated_at': updatedAt.toIso8601String(), // → updated_at
};
```

---

## Request: POST /auth/register ↔ RegisterRequestModel

**Backend Request (snake_case):**
```json
{
  "email": "usuario@example.com",
  "password": "contraseña123",
  "confirm_password": "contraseña123",
  "nombre_completo": "Juan Pérez"
}
```

**Frontend Model (camelCase):**
```dart
RegisterRequestModel(
  email: "usuario@example.com",
  password: "contraseña123",
  confirmPassword: "contraseña123",
  nombreCompleto: "Juan Pérez",
)
```

### Mapping en toJson:

```dart
Map<String, dynamic> toJson() => {
  'email': email.toLowerCase().trim(),        // → email (normalizado)
  'password': password,                       // → password
  'confirm_password': confirmPassword,        // → confirm_password
  'nombre_completo': nombreCompleto.trim(),   // → nombre_completo (trim)
};
```

---

## Response: POST /auth/register ↔ AuthResponseModel

**Backend Response (snake_case):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "usuario@example.com",
  "nombre_completo": "Juan Pérez",
  "estado": "REGISTRADO",
  "email_verificado": false,
  "created_at": "2025-10-04T10:30:00Z",
  "message": "Registro exitoso. Revisa tu email para confirmar tu cuenta"
}
```

**Frontend Model (camelCase):**
```dart
AuthResponseModel(
  id: "550e8400-e29b-41d4-a716-446655440000",
  email: "usuario@example.com",
  nombreCompleto: "Juan Pérez",
  estado: "REGISTRADO",
  emailVerificado: false,
  createdAt: DateTime(2025, 10, 4, 10, 30),
  message: "Registro exitoso. Revisa tu email para confirmar tu cuenta",
)
```

### Mapping en fromJson:

```dart
factory AuthResponseModel.fromJson(Map<String, dynamic> json) => AuthResponseModel(
  id: json['id'] as String?,
  email: json['email'] as String?,
  nombreCompleto: json['nombre_completo'] as String?,     // ← nombre_completo
  estado: json['estado'] as String?,
  emailVerificado: json['email_verificado'] as bool?,    // ← email_verificado
  createdAt: json['created_at'] != null
      ? DateTime.parse(json['created_at'] as String)
      : null,
  message: json['message'] as String,
);
```

---

## Response: GET /auth/confirm-email ↔ EmailConfirmationResponseModel

**Backend Response (snake_case):**
```json
{
  "message": "Email confirmado exitosamente",
  "email_verificado": true,
  "estado": "REGISTRADO",
  "next_step": "Tu cuenta está esperando aprobación del administrador"
}
```

**Frontend Model (camelCase):**
```dart
EmailConfirmationResponseModel(
  message: "Email confirmado exitosamente",
  emailVerificado: true,
  estado: "REGISTRADO",
  nextStep: "Tu cuenta está esperando aprobación del administrador",
)
```

### Mapping en fromJson:

```dart
factory EmailConfirmationResponseModel.fromJson(Map<String, dynamic> json) {
  return EmailConfirmationResponseModel(
    message: json['message'] as String,
    emailVerificado: json['email_verificado'] as bool,    // ← email_verificado
    estado: json['estado'] as String,
    nextStep: json['next_step'] as String,                 // ← next_step
  );
}
```

---

## Error Response ↔ ErrorResponseModel

**Backend Error Response (snake_case):**
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Email es requerido",
  "field": "email"
}
```

**Frontend Model (camelCase):**
```dart
ErrorResponseModel(
  error: "VALIDATION_ERROR",
  message: "Email es requerido",
  field: "email",
)
```

### Mapping en fromJson:

```dart
factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
  return ErrorResponseModel(
    error: json['error'] as String,
    message: json['message'] as String,
    field: json['field'] as String?,
  );
}
```

---

## ENUMS Mapping

### UserRole (Dart) ↔ user_role (PostgreSQL)

| Backend (ENUM) | Frontend (Dart Enum) |
|----------------|---------------------|
| `'ADMIN'` | `UserRole.admin` |
| `'GERENTE'` | `UserRole.gerente` |
| `'VENDEDOR'` | `UserRole.vendedor` |
| `NULL` | `null` |

```dart
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
```

### UserEstado (Dart) ↔ user_estado (PostgreSQL)

| Backend (ENUM) | Frontend (Dart Enum) |
|----------------|---------------------|
| `'REGISTRADO'` | `UserEstado.registrado` |
| `'APROBADO'` | `UserEstado.aprobado` |
| `'RECHAZADO'` | `UserEstado.rechazado` |
| `'SUSPENDIDO'` | `UserEstado.suspendido` |

```dart
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
```

---

## Campos de Seguridad (NO Expuestos en Frontend)

Estos campos NUNCA deben enviarse al frontend:

| Campo Backend | Motivo |
|---------------|--------|
| `password_hash` | Seguridad: hash de contraseña |
| `token_confirmacion` | Seguridad: token sensible |
| `token_expiracion` | Seguridad: info del token |

**IMPORTANTE**: Los endpoints backend DEBEN excluir estos campos en los SELECT queries.

```sql
-- ✅ CORRECTO
SELECT id, email, nombre_completo, rol, estado, email_verificado, created_at, updated_at
FROM users WHERE id = $1;

-- ❌ INCORRECTO
SELECT * FROM users WHERE id = $1;  -- Expone password_hash y tokens
```

---

## Normalización de Datos

### Email
- **Backend**: Almacenar lowercase, índice LOWER(email)
- **Frontend**: Normalizar a lowercase en toJson()

```dart
// Frontend
'email': email.toLowerCase().trim()
```

```sql
-- Backend
CREATE UNIQUE INDEX idx_users_email_unique ON users(LOWER(email));
```

### Nombre Completo
- **Backend**: Almacenar como viene (respeta mayúsculas)
- **Frontend**: Trim espacios antes de enviar

```dart
// Frontend
'nombre_completo': nombreCompleto.trim()
```

---

## Validación de Consistencia

### Checklist para @supabase-expert y @flutter-expert:

- [ ] Todos los campos snake_case en BD mapean a camelCase en Dart
- [ ] ENUMs usan valores idénticos en ambos lados
- [ ] Campos sensibles NO se exponen en responses
- [ ] Email normalizado a lowercase en ambos lados
- [ ] Timestamps se convierten correctamente (ISO 8601)
- [ ] Campos nullable se manejan correctamente (tipo? en Dart)
- [ ] Validaciones frontend coinciden con validaciones backend

---

## Actualización por Agentes

- **@supabase-expert**: Verifica nombres de campos BD (snake_case) al implementar
- **@flutter-expert**: Verifica nombres de propiedades Dart (camelCase) al implementar
- **@web-architect-expert**: Mantiene tabla actualizada y resuelve discrepancias

**Cualquier cambio en BD o modelos DEBE actualizarse aquí primero.**
