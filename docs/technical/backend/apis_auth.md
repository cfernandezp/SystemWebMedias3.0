# APIs Auth Module

Archivo consolidado de APIs/RPC para el módulo de Autenticación.

---

## HU-001: Registro de Alta al Sistema Web {#hu-001}

### RPC: register_user
```
Endpoint: supabase.rpc('register_user')
Params: {
  p_email: string,
  p_password: string,
  p_nombre_completo: string,
  p_rol: 'GERENTE' | 'VENDEDOR'
}
Response: {
  success: boolean,
  data?: { user_id, email, message },
  error?: { code, message, hint }
}
```

### RPC: confirm_email
```
Endpoint: supabase.rpc('confirm_email')
Params: { p_token: string }
Response: {
  success: boolean,
  data?: { message, user_id },
  error?: { code, message, hint }
}
```

**Status**: ✅ Implementado

---

## HU-002: Login por Roles con Aprobación {#hu-002}

### RPC: login_user
```
Endpoint: supabase.rpc('login_user')
Params: {
  p_email: string,
  p_password: string,
  p_remember_me: boolean
}
Response: {
  success: boolean,
  data?: {
    user_id: string,
    email: string,
    nombre_completo: string,
    rol: string,
    session_token: string,
    message: string
  },
  error?: { code, message, hint }
}
```

**Status**: ✅ Implementado

---

## HU-003: Logout Seguro {#hu-003}

### RPC: logout_user
```
Endpoint: supabase.rpc('logout_user')
Params: {
  p_user_id: string,
  p_token: string,
  p_logout_type: 'manual' | 'inactivity' | 'token_expired',
  p_ip_address: string
}
Response: {
  success: boolean,
  data?: { message },
  error?: { code, message, hint }
}
```

### RPC: check_inactivity
```
Endpoint: supabase.rpc('check_inactivity')
Params: { p_user_id: string }
Response: {
  success: boolean,
  data?: {
    is_inactive: boolean,
    minutes_inactive: number,
    warning_threshold: number
  },
  error?: { code, message, hint }
}
```

**Status**: ✅ Implementado

---

## HU-004: Recuperar Contraseña {#hu-004}

### RPC: request_password_reset
```
Endpoint: supabase.rpc('request_password_reset')
Method: POST

Params: {
  p_email: string,
  p_ip_address?: string (opcional, para auditoría)
}

Response Success:
{
  "success": true,
  "data": {
    "message": "Si el email existe, se enviará un enlace de recuperación",
    "email_sent": true
  }
}

Response Error (Rate Limit):
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Límite de solicitudes alcanzado. Intenta nuevamente en 15 minutos",
    "hint": "rate_limit_exceeded"
  }
}
```

**Business Rules**:
- Rate limiting: Máximo 3 solicitudes por email cada 15 minutos
- Privacidad: Siempre retorna mensaje genérico (no revela si email existe)
- Solo usuarios con `email_verificado = true` pueden recibir token
- Token válido por 24 horas

---

### RPC: validate_reset_token
```
Endpoint: supabase.rpc('validate_reset_token')
Method: POST

Params: {
  p_token: string
}

Response Success (Token válido):
{
  "success": true,
  "data": {
    "is_valid": true,
    "message": "Token válido",
    "expires_at": "2025-10-07T10:30:00Z",
    "user_id": "uuid-here"
  }
}

Response Success (Token expirado):
{
  "success": true,
  "data": {
    "is_valid": false,
    "message": "El enlace de recuperación ha expirado",
    "expires_at": "2025-10-06T10:30:00Z"
  }
}

Response Success (Token usado):
{
  "success": true,
  "data": {
    "is_valid": false,
    "message": "Este enlace de recuperación ya fue utilizado"
  }
}

Response Success (Token inválido):
{
  "success": true,
  "data": {
    "is_valid": false,
    "message": "Enlace de recuperación inválido"
  }
}
```

**Validaciones**:
- Token existe en tabla `password_recovery`
- `expires_at > NOW()`
- `used_at IS NULL`

---

### RPC: reset_password
```
Endpoint: supabase.rpc('reset_password')
Method: POST
Status: ✅ CORREGIDO (2025-10-06) - Issue #1 fixed

NOTA: Se recomienda usar SOLO la función RPC reset_password() directamente.
La Edge Function /reset-password tiene problemas con updateUserById() y quedará deprecated.

Params: {
  p_token: string,
  p_new_password: string,
  p_ip_address?: string (opcional, para auditoría)
}

Response Success:
{
  "success": true,
  "data": {
    "message": "Contraseña actualizada exitosamente",
    "user_id": "uuid-here"
  }
}

Response Error (Token inválido):
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Enlace de recuperación inválido o expirado",
    "hint": "token_invalid"
  }
}

Response Error (Password débil):
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "La contraseña debe tener al menos 8 caracteres",
    "hint": "password_weak"
  }
}
```

**Side Effects**:
1. Actualiza `users.password_hash` (bcrypt)
2. Marca `password_recovery.used_at = NOW()`
3. Elimina refresh tokens activos del usuario (logout forzado)
4. Inserta registro en `audit_logs` (event_type: 'password_reset')

**Validaciones**:
- Token válido (via `validate_reset_token`)
- Nueva contraseña: min 8 caracteres
- Token no usado previamente

---

### RPC: cleanup_expired_recovery_tokens
```
Endpoint: supabase.rpc('cleanup_expired_recovery_tokens')
Method: POST

Params: {} (sin parámetros)

Response:
{
  "success": true,
  "data": {
    "deleted_count": 15,
    "message": "15 tokens expirados eliminados"
  }
}
```

**Usage**: Llamar periódicamente (ej: cron job diario) para limpiar tokens expirados

---

**Status**: ✅ Implementado (Backend completo)
**Pendiente**: Integración de email sending (requiere servicio externo)

**Última actualización**: 2025-10-06
**Mantenido por**: @web-architect-expert
