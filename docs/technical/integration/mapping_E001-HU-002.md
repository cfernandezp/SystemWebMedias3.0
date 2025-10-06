# Mapping BD ↔ Dart - HU-002: Login al Sistema

**HU relacionada**: E001-HU-002
**Estado**: 🔵 En Desarrollo

**DISEÑADO POR**: @web-architect-expert (2025-10-05)

---

## 🔄 LOGIN REQUEST

### Dart → PostgreSQL Function

**Modelo Dart**: `LoginRequestModel`

```dart
{
  "email": "user@example.com",
  "password": "Password123!",
  "rememberMe": true
}
```

**Llamada RPC**:

```dart
await supabase.rpc('login_user', params: {
  'p_email': 'user@example.com',
  'p_password': 'Password123!',
  'p_remember_me': true,
});
```

**Mapping**:

| Dart Field | PostgreSQL Param | Tipo |
|------------|------------------|------|
| `email` | `p_email` | TEXT |
| `password` | `p_password` | TEXT |
| `rememberMe` | `p_remember_me` | BOOLEAN |

---

## 🔄 LOGIN RESPONSE (Exitoso)

### PostgreSQL → Dart

**PostgreSQL JSON Response**:

```json
{
  "success": true,
  "data": {
    "token": "ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "nombre_completo": "Juan Pérez",
      "rol": "VENDEDOR",
      "estado": "APROBADO"
    },
    "message": "Bienvenido Juan Pérez"
  }
}
```

**Modelo Dart**: `LoginResponseModel`

```dart
LoginResponseModel(
  token: "ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5...",
  user: UserModel(
    id: "550e8400-e29b-41d4-a716-446655440000",
    email: "user@example.com",
    nombreCompleto: "Juan Pérez",
    rol: "VENDEDOR",
    estado: "APROBADO",
    emailVerificado: true,
    createdAt: DateTime(...),
    updatedAt: DateTime(...),
  ),
  message: "Bienvenido Juan Pérez",
)
```

**Mapping**:

| PostgreSQL JSON Path | Dart Field | Tipo | Transformación |
|----------------------|------------|------|----------------|
| `data.token` | `token` | String | Directo |
| `data.user.id` | `user.id` | String | Directo (UUID as String) |
| `data.user.email` | `user.email` | String | Directo |
| `data.user.nombre_completo` | `user.nombreCompleto` | String | snake_case → camelCase |
| `data.user.rol` | `user.rol` | String? | Directo (nullable) |
| `data.user.estado` | `user.estado` | String | Directo (ENUM as String) |
| `data.message` | `message` | String | Directo |

---

## 🔄 LOGIN RESPONSE (Error - Credenciales Incorrectas)

### PostgreSQL → Dart

**PostgreSQL JSON Response**:

```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Email o contraseña incorrectos",
    "hint": "invalid_credentials"
  }
}
```

**Excepción Dart**: `UnauthorizedException`

```dart
throw UnauthorizedException(
  "Email o contraseña incorrectos",
  401,
);
```

**Mapping de Hints a Excepciones**:

| PostgreSQL Hint | Dart Exception | HTTP Status Code |
|-----------------|----------------|------------------|
| `invalid_credentials` | `UnauthorizedException` | 401 |
| `email_not_verified` | `EmailNotVerifiedException` | 403 |
| `user_not_approved` | `UserNotApprovedException` | 403 |
| `missing_email` | `ValidationException` | 400 |
| `invalid_email` | `ValidationException` | 400 |
| `missing_password` | `ValidationException` | 400 |

---

## 🔄 VALIDATE TOKEN REQUEST

### Dart → PostgreSQL Function

**Llamada RPC**:

```dart
await supabase.rpc('validate_token', params: {
  'p_token': 'ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5...',
});
```

**Mapping**:

| Dart Variable | PostgreSQL Param | Tipo |
|---------------|------------------|------|
| `token` | `p_token` | TEXT |

---

## 🔄 VALIDATE TOKEN RESPONSE (Exitoso)

### PostgreSQL → Dart

**PostgreSQL JSON Response**:

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "nombre_completo": "Juan Pérez",
      "rol": "VENDEDOR",
      "estado": "APROBADO"
    }
  }
}
```

**Modelo Dart**: `ValidateTokenResponseModel`

```dart
ValidateTokenResponseModel(
  user: UserModel(
    id: "550e8400-e29b-41d4-a716-446655440000",
    email: "user@example.com",
    nombreCompleto: "Juan Pérez",
    rol: "VENDEDOR",
    estado: "APROBADO",
    emailVerificado: true,
    createdAt: DateTime(...),
    updatedAt: DateTime(...),
  ),
)
```

**Mapping**: Igual que `LoginResponseModel.user`

---

## 🔄 VALIDATE TOKEN RESPONSE (Error - Token Expirado)

### PostgreSQL → Dart

**PostgreSQL JSON Response**:

```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Tu sesión ha expirado. Inicia sesión nuevamente",
    "hint": "expired_token"
  }
}
```

**Excepción Dart**: `UnauthorizedException`

```dart
throw UnauthorizedException(
  "Tu sesión ha expirado. Inicia sesión nuevamente",
  401,
);
```

**Mapping de Hints**:

| PostgreSQL Hint | Dart Exception | HTTP Status Code |
|-----------------|----------------|------------------|
| `expired_token` | `UnauthorizedException` | 401 |
| `invalid_token` | `ValidationException` | 400 |
| `missing_token` | `ValidationException` | 400 |
| `user_not_found` | `NotFoundException` | 404 |
| `user_not_approved` | `UserNotApprovedException` | 403 |

---

## 🔄 PERSISTENCIA LOCAL (SecureStorage)

### AuthStateModel → SecureStorage

**Modelo Dart**:

```dart
AuthStateModel(
  token: "ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5...",
  user: UserModel(...),
  tokenExpiration: DateTime(2025, 11, 05),  // 30 días después si rememberMe
)
```

**JSON guardado en SecureStorage**:

```json
{
  "token": "ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "nombre_completo": "Juan Pérez",
    "rol": "VENDEDOR",
    "estado": "APROBADO",
    "email_verificado": true,
    "created_at": "2025-10-04T12:00:00Z",
    "updated_at": "2025-10-04T12:00:00Z"
  },
  "token_expiration": "2025-11-05T12:00:00Z"
}
```

**Clave en SecureStorage**: `auth_state`

**Mapping**:

| Dart Field | SecureStorage JSON Key | Tipo |
|------------|------------------------|------|
| `token` | `token` | String |
| `user` | `user` | Object (UserModel serializado) |
| `tokenExpiration` | `token_expiration` | String (ISO 8601) |

---

## 🔄 JWT TOKEN STRUCTURE

### PostgreSQL → Token Content

**Token decodificado** (base64):

```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "rol": "VENDEDOR",
  "exp": 1730851200
}
```

**Mapping**:

| JWT Field | Descripción | Tipo |
|-----------|-------------|------|
| `user_id` | UUID del usuario | String (UUID) |
| `email` | Email del usuario | String |
| `rol` | Rol del usuario | String (ENUM) |
| `exp` | Fecha de expiración (epoch timestamp) | Number |

**Cálculo de `exp`**:
- Sin `rememberMe`: `NOW() + 8 hours` → `exp = extract(epoch from NOW() + '8 hours'::interval)`
- Con `rememberMe`: `NOW() + 30 days` → `exp = extract(epoch from NOW() + '30 days'::interval)`

---

## 📋 RESUMEN DE CONVERSIONES

### Naming Conventions:

| Contexto | Convención | Ejemplo |
|----------|-----------|---------|
| PostgreSQL columns | `snake_case` | `nombre_completo`, `email_verificado` |
| PostgreSQL params | `p_snake_case` | `p_email`, `p_remember_me` |
| Dart fields | `camelCase` | `nombreCompleto`, `emailVerificado` |
| Dart classes | `PascalCase` | `LoginResponseModel`, `UserModel` |
| JSON keys (PostgreSQL) | `snake_case` | `nombre_completo`, `created_at` |
| JSON keys (Dart) | Mixto (según origen) | `nombre_completo` → `nombreCompleto` |

### Tipos de Datos:

| PostgreSQL | Dart | Notas |
|------------|------|-------|
| `TEXT` | `String` | Directo |
| `BOOLEAN` | `bool` | Directo |
| `UUID` | `String` | Convertir a String en Dart |
| `TIMESTAMP WITH TIME ZONE` | `DateTime` | Parse con `DateTime.parse()` |
| `JSON` | `Map<String, dynamic>` | Parse con `jsonDecode()` |
| `user_role` (ENUM) | `String?` | Nullable, convertir a String |
| `user_estado` (ENUM) | `String` | Non-nullable, convertir a String |

---

## 🔍 VALIDACIÓN DE MAPPING

### Checklist:

- [x] **Request params**: Prefijo `p_` en PostgreSQL
- [x] **Response fields**: snake_case en PostgreSQL, camelCase en Dart
- [x] **Error hints**: Consistencia entre BD y excepciones Dart
- [x] **Nullability**: `rol` es nullable, `estado` es non-nullable
- [x] **Timestamps**: Conversión con `DateTime.parse()` y `toIso8601String()`
- [x] **UUIDs**: Convertir a String en Dart
- [x] **ENUMs**: Tratar como String en Dart

---

**Última actualización**: 2025-10-05
**Mantenido por**: @web-architect-expert
