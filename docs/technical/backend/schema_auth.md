# Schema Auth Module

Archivo consolidado de esquemas de base de datos para el módulo de Autenticación.

---

## HU-001: Registro de Alta al Sistema Web {#hu-001}

### Diseño (referencia):
- Tabla: `users`
  - `id` UUID PK
  - `email` TEXT UNIQUE
  - `password_hash` TEXT
  - `nombre_completo` TEXT
  - `rol` user_role (ENUM)
  - `estado` user_estado (ENUM: REGISTRADO, APROBADO, RECHAZADO)
  - `email_verificado` BOOLEAN
  - `created_at`, `updated_at` TIMESTAMP
- Tabla: `email_confirmations`
  - `id` UUID PK
  - `user_id` UUID FK
  - `token` TEXT UNIQUE
  - `expires_at` TIMESTAMP
  - `confirmed_at` TIMESTAMP
- Función: `register_user(p_email, p_password, p_nombre_completo, p_rol)`
- Función: `confirm_email(p_token)`

**Status**: ✅ Implementado
**Migration**: `20251004145739_hu001_users_registration.sql`

---

## HU-002: Login por Roles con Aprobación {#hu-002}

### Diseño (referencia):
- Función: `login_user(p_email, p_password, p_remember_me)`
  - Valida email verificado
  - Valida estado APROBADO
  - Retorna user + session_token

**Status**: ✅ Implementado
**Migration**: Incluida en HU-001

---

## HU-003: Logout Seguro {#hu-003}

### Diseño (referencia):
- Tabla: `token_blacklist`
  - `id` UUID PK
  - `token` TEXT UNIQUE
  - `user_id` UUID FK
  - `blacklisted_at` TIMESTAMP
  - `expires_at` TIMESTAMP
  - `reason` TEXT
- Tabla: `audit_logs`
  - `id` UUID PK
  - `user_id` UUID FK
  - `event_type` TEXT
  - `event_subtype` TEXT
  - `ip_address` INET
  - `metadata` JSONB
  - `created_at` TIMESTAMP
- Función: `logout_user(p_user_id, p_token, p_logout_type, p_ip_address)`
- Función: `check_inactivity(p_user_id)`

**Status**: ✅ Implementado
**Migration**: `20251006192540_hu003_logout_seguro.sql`

---

## HU-004: Recuperar Contraseña {#hu-004}

### Diseño:

#### Tabla: password_recovery
```sql
CREATE TABLE password_recovery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_password_recovery_token ON password_recovery(token);
CREATE INDEX idx_password_recovery_email ON password_recovery(email);
CREATE INDEX idx_password_recovery_expires_at ON password_recovery(expires_at);
```

#### Función: request_password_reset
```
Params:
  - p_email TEXT
  - p_ip_address INET

Logic:
  1. Validar email existe y está confirmado
  2. Verificar rate limiting (3 solicitudes/15 min)
  3. Generar token seguro (32 bytes, URL-safe)
  4. Guardar en password_recovery con expires_at = NOW() + 24 hours
  5. Retornar mensaje genérico (privacidad)

Response:
  {
    "success": true,
    "data": {
      "message": "Si el email existe, se enviará un enlace de recuperación",
      "email_sent": true
    }
  }
```

#### Función: validate_reset_token
```
Params:
  - p_token TEXT

Logic:
  1. Buscar token en password_recovery
  2. Verificar no expirado (expires_at > NOW())
  3. Verificar no usado (used_at IS NULL)
  4. Retornar estado

Response:
  {
    "success": true,
    "data": {
      "is_valid": true/false,
      "message": "Token válido/expirado/usado/inválido",
      "expires_at": "timestamp",
      "user_id": "uuid"
    }
  }
```

#### Función: reset_password
```
Params:
  - p_token TEXT
  - p_new_password TEXT
  - p_ip_address INET

Logic:
  1. Validar token (via validate_reset_token)
  2. Validar nueva contraseña (min 8 chars)
  3. Hash password (bcrypt o similar)
  4. Actualizar auth.users.encrypted_password
  5. Marcar token como usado (used_at = NOW())
  6. Invalidar sesiones activas (eliminar refresh_tokens)
  7. Registrar en audit_logs
  8. Retornar success

Response:
  {
    "success": true,
    "data": {
      "message": "Contraseña actualizada exitosamente",
      "user_id": "uuid"
    }
  }
```

#### Función: cleanup_expired_recovery_tokens
```
Logic:
  - DELETE FROM password_recovery WHERE expires_at < NOW()
  - Retornar conteo de tokens eliminados

Execution: Automático (pg_cron o manual)
```

**Status**: ✅ Implementado
**Migration**: `20251006214500_hu004_password_recovery.sql`

**Security Specs**:
- Token: 32 bytes random, URL-safe encoding
- Expiración: 24 horas desde creación
- Rate limiting: 3 solicitudes/15 minutos por email
- Uso único: `used_at` marcado al cambiar password
- Privacidad: No revelar si email existe en sistema

**Error Hints**:
- `rate_limit_exceeded`: Límite de solicitudes alcanzado
- `token_expired`: Token válido pero expirado
- `token_invalid`: Token no existe
- `token_used`: Token ya fue utilizado
- `password_weak`: Password no cumple política de seguridad

---

### Código Final Implementado

**Status**: ⚠️ IMPLEMENTADO CON ERROR CRÍTICO
**Fecha**: 2025-10-06
**Implementado por**: @supabase-expert
**Verificado por**: @supabase-expert

#### Cambios vs Diseño Inicial:

1. ✅ **Tabla password_recovery**: Implementada exactamente como diseño
   - Foreign key: `auth.users(id)` en vez de `users(id)` (uso de Supabase Auth nativo)
   - Índice adicional: `idx_password_recovery_user_id` para optimización

2. ✅ **request_password_reset()**: Funcional
   - Validación email: ✅ OK
   - Rate limiting: ✅ OK (3 solicitudes/15 min)
   - Generación token: ✅ OK (32 bytes URL-safe)
   - Privacidad: ✅ OK (mensaje genérico)
   - Respuesta incluye token en `data.token` (para testing/dev)

3. ✅ **validate_reset_token()**: Funcional
   - Validaciones: ✅ OK (token inválido, expirado, usado)
   - Response field: `is_valid` en vez de `valid` (documentado en mapping)

4. ❌ **reset_password()**: ERROR CRÍTICO
   - **PROBLEMA**: Línea 280-283 usa `crypt()` de pgcrypto para hashear password
   - **ERROR**: Supabase Auth NO acepta actualización directa de `encrypted_password`
   - **SÍNTOMA**: `operator does not exist: character varying = uuid`
   - **CAUSA**: Intentar hashear con `crypt()` incompatible con sistema de Supabase Auth

   **Código actual (INCORRECTO)**:
   ```sql
   UPDATE auth.users
   SET encrypted_password = crypt(p_new_password, gen_salt('bf')),
       updated_at = NOW()
   WHERE id = v_recovery.user_id;
   ```

   **SOLUCIÓN REQUERIDA**:
   - Opción 1: Usar Supabase Admin API (`auth.admin.updateUserById()`) desde Edge Function
   - Opción 2: Usar función de Supabase Auth `auth.update_user_password()`
   - Opción 3: Crear Edge Function que llame a Supabase Auth API

   **RECOMENDACIÓN**: Implementar Edge Function que use Admin API de Supabase:
   ```typescript
   const { data, error } = await supabaseAdmin.auth.admin.updateUserById(
     userId,
     { password: newPassword }
   )
   ```

5. ✅ **cleanup_expired_recovery_tokens()**: Funcional
   - Eliminación automática: ✅ OK
   - Retorna conteo: ✅ OK

#### Migration aplicada:
- `supabase/migrations/20251006214500_hu004_password_recovery.sql`

#### Pruebas realizadas:

**TEST 1: request_password_reset**
```
Input: admin@test.com
Output: ✅ Token generado correctamente
{
  "success": true,
  "data": {
    "message": "Si el email existe, se enviara un enlace de recuperacion",
    "email_sent": true,
    "token": "wPMnbq3_4U8gn2E8QuQVCJJKgLAeudhI-WsxXY-AAQo",
    "expires_at": "2025-10-07T22:03:45.551714+00:00"
  }
}
```

**TEST 2: validate_reset_token**
```
Input: wPMnbq3_4U8gn2E8QuQVCJJKgLAeudhI-WsxXY-AAQo
Output: ✅ Token validado correctamente
{
  "success": true,
  "data": {
    "is_valid": true,
    "user_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
    "email": "admin@test.com",
    "expires_at": "2025-10-07T22:03:45.551714+00:00"
  }
}
```

**TEST 3: reset_password**
```
Input: token + "NewPassword123!"
Output: ❌ ERROR
{
  "success": false,
  "error": {
    "code": "42883",
    "message": "operator does not exist: character varying = uuid",
    "hint": "unknown"
  }
}
```

#### Estado funciones RPC:

| Función                          | Estado      | Observaciones                          |
|----------------------------------|-------------|----------------------------------------|
| `request_password_reset()`       | ✅ OK       | Funcional - Genera tokens correctos    |
| `validate_reset_token()`         | ✅ OK       | Funcional - Validación correcta        |
| `reset_password()`               | ❌ ERROR    | Requiere refactorización urgente       |
| `cleanup_expired_recovery_tokens()` | ✅ OK    | Funcional - Limpieza OK                |

#### ACCIÓN REQUERIDA:

**PRIORIDAD: ALTA**
**Bloqueante**: SÍ - HU-004 NO funcional hasta fix

**Próximos pasos**:
1. Crear Edge Function `reset-password` que use Supabase Admin API
2. Actualizar función `reset_password()` para llamar a Edge Function
3. O alternativamente: Migrar toda lógica a Edge Function TypeScript
4. Re-ejecutar tests de integración
5. Actualizar documentación con solución final

---

**Última actualización**: 2025-10-06
**Mantenido por**: @web-architect-expert
