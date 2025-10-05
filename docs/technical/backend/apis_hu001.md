# APIs Backend - HU-001: Registro de Alta al Sistema

**Base URL Local**: `http://localhost:54321/functions/v1`
**HU relacionada**: E001-HU-001
**Estado**: ✅ Implementado

**DISEÑADO POR**: @web-architect-expert (2025-10-04)
**IMPLEMENTADO POR**: @supabase-expert (2025-10-04)

---

## POST /auth/register

**Implementa**: RN-001, RN-002, RN-003, RN-006
**Edge Function**: `supabase/functions/auth/register/index.ts`
**Estado**: ✅ Implementado
**Endpoint**: `POST http://localhost:54321/functions/v1/auth/register`

### Request:

```json
{
  "email": "usuario@example.com",
  "password": "contraseña123",
  "confirm_password": "contraseña123",
  "nombre_completo": "Juan Pérez"
}
```

### Validaciones Backend:

- **RN-006**: Email obligatorio con formato válido (regex: `^[^\s@]+@[^\s@]+\.[^\s@]+$`)
- **RN-006**: Contraseña obligatoria
- **RN-002**: Contraseña mínimo 8 caracteres
- **RN-002**: confirm_password debe coincidir exactamente con password
- **RN-006**: nombre_completo obligatorio (trim espacios)
- **RN-001**: Verificar email no duplicado (case-insensitive)
- **RN-002**: Hashear contraseña con bcrypt/argon2 (nunca almacenar plain text)
- **RN-003**: Generar token_confirmacion único (UUID v4)
- **RN-003**: Establecer token_expiracion a NOW() + 24 horas
- **RN-004**: Estado inicial: REGISTRADO
- **Enviar email** de confirmación con enlace seguro

### Response 201 (Created):

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

### Response 400 (Bad Request):

```json
{
  "error": "VALIDATION_ERROR",
  "message": "Email es requerido",
  "field": "email"
}
```

Otros mensajes posibles:
- "Formato de email inválido"
- "Contraseña es requerida"
- "Contraseña debe tener al menos 8 caracteres"
- "Las contraseñas no coinciden"
- "Nombre completo es requerido"

### Response 409 (Conflict):

```json
{
  "error": "DUPLICATE_EMAIL",
  "message": "Este email ya está registrado"
}
```

### Lógica Implementada:

✅ **Archivo**: `C:\SystemWebMedias3.0\supabase\functions\auth\register\index.ts`

**Flujo implementado**:
1. ✅ CORS handling (OPTIONS request)
2. ✅ Validación de request body usando `validateRegisterRequest()`
   - Email obligatorio, formato válido, normalización a lowercase
   - Password >= 8 caracteres
   - confirm_password coincide con password
   - nombre_completo obligatorio y trimmed
3. ✅ Verificación de email duplicado (case-insensitive usando `.ilike()`)
4. ✅ Hash de contraseña con bcrypt (usando deno.land/x/bcrypt)
5. ✅ Generación de token_confirmacion (crypto.randomUUID())
6. ✅ Cálculo de token_expiracion (NOW() + 24h)
7. ✅ Inserción en BD con estado REGISTRADO
8. ✅ Envío de email con template HTML corporativo turquesa
9. ✅ Response 201 con datos del usuario (sin password_hash ni tokens)

**Manejo de errores**:
- 400: ValidationError (campos inválidos)
- 409: DUPLICATE_EMAIL (email ya registrado)
- 500: INTERNAL_ERROR (errores inesperados)

**Nota**: Email se envía usando Resend API (requiere env var `RESEND_API_KEY`)

---

## GET /auth/confirm-email?token={token}

**Implementa**: RN-003
**Edge Function**: `supabase/functions/auth/confirm-email/index.ts`
**Estado**: ✅ Implementado
**Endpoint**: `GET http://localhost:54321/functions/v1/auth/confirm-email?token={token}`

### Query Parameters:

- `token` (required): Token de confirmación recibido por email

### Validaciones Backend:

- **RN-003**: Verificar que token existe en BD
- **RN-003**: Verificar que token no ha expirado (token_expiracion > NOW())
- **RN-003**: Verificar que email_verificado === false (no reutilizar token)
- Actualizar email_verificado a true
- Limpiar token_confirmacion y token_expiracion (seguridad)

### Response 200 (Success):

```json
{
  "message": "Email confirmado exitosamente",
  "email_verificado": true,
  "estado": "REGISTRADO",
  "next_step": "Tu cuenta está esperando aprobación del administrador"
}
```

### Response 400 (Bad Request):

```json
{
  "error": "INVALID_TOKEN",
  "message": "Enlace de confirmación inválido o expirado"
}
```

### Lógica Implementada:

✅ **Archivo**: `C:\SystemWebMedias3.0\supabase\functions\auth\confirm-email\index.ts`

**Flujo implementado**:
1. ✅ CORS handling (OPTIONS request)
2. ✅ Extracción y validación de token desde query params
   - Validación de formato UUID v4
3. ✅ Búsqueda de usuario por token_confirmacion
4. ✅ Verificación de que email no esté ya verificado
5. ✅ Verificación de que token no haya expirado (comparación de fechas)
6. ✅ UPDATE: email_verificado = true, token_confirmacion = NULL, token_expiracion = NULL
7. ✅ Response 200 con mensaje de éxito y next_step

**Manejo de errores**:
- 400: INVALID_TOKEN (token no existe, expirado o ya usado)
- 400: EMAIL_ALREADY_VERIFIED (email ya confirmado)
- 500: INTERNAL_ERROR (errores inesperados)

---

## POST /auth/resend-confirmation

**Implementa**: RN-003 (límite 3 reenvíos por hora)
**Edge Function**: `supabase/functions/auth/resend-confirmation/index.ts`
**Estado**: ✅ Implementado
**Endpoint**: `POST http://localhost:54321/functions/v1/auth/resend-confirmation`

### Request:

```json
{
  "email": "usuario@example.com"
}
```

### Validaciones Backend:

- **RN-003**: Verificar que usuario existe
- **RN-003**: Verificar que email_verificado === false (no reenviar si ya confirmó)
- **RN-003**: Verificar límite de 3 reenvíos por hora (anti-spam)
  - Opción 1: Tabla `confirmation_attempts` con timestamp
  - Opción 2: Contador en tabla users con reset cada hora
- Generar nuevo token_confirmacion
- Actualizar token_expiracion a NOW() + 24h
- Enviar nuevo email

### Response 200 (Success):

```json
{
  "message": "Email de confirmación reenviado",
  "token_expiracion": "2025-10-05T10:30:00Z"
}
```

### Response 400 (Bad Request):

```json
{
  "error": "EMAIL_ALREADY_VERIFIED",
  "message": "Este email ya fue confirmado"
}
```

### Response 429 (Too Many Requests):

```json
{
  "error": "RATE_LIMIT_EXCEEDED",
  "message": "Máximo 3 reenvíos por hora. Intenta más tarde",
  "retry_after": "2025-10-04T11:30:00Z"
}
```

### Lógica Implementada:

✅ **Archivo**: `C:\SystemWebMedias3.0\supabase\functions\auth\resend-confirmation\index.ts`

**Flujo implementado**:
1. ✅ CORS handling (OPTIONS request)
2. ✅ Validación de request body (email requerido y formato válido)
3. ✅ Normalización de email a lowercase
4. ✅ Búsqueda de usuario por email (case-insensitive usando `.ilike()`)
5. ✅ Verificación de que email NO esté ya verificado
6. ✅ Verificación de límite de reenvíos (RN-003):
   - Consulta a tabla `confirmation_resend_attempts`
   - Cuenta intentos en última hora (usando `gte('attempted_at', oneHourAgo)`)
   - Si >= 3 intentos → Error 429 con retry_after
7. ✅ Generación de nuevo token_confirmacion (crypto.randomUUID())
8. ✅ UPDATE de token_confirmacion y token_expiracion (NOW() + 24h)
9. ✅ Registro de intento en `confirmation_resend_attempts` (incluye IP)
10. ✅ Envío de nuevo email con template HTML
11. ✅ Response 200 con mensaje de éxito

**Manejo de errores**:
- 404: USER_NOT_FOUND (email no existe)
- 400: EMAIL_ALREADY_VERIFIED (email ya confirmado)
- 429: RATE_LIMIT_EXCEEDED (más de 3 intentos en última hora)
- 500: INTERNAL_ERROR (errores inesperados)

**Implementación de rate limiting**:
- Usa tabla `confirmation_resend_attempts` (creada en migration)
- Almacena: user_id, attempted_at, ip_address
- Calcula intentos en ventana deslizante de 1 hora

---

## Configuración de Email

### Template de Confirmación:

✅ **Implementado**: Template HTML corporativo con tema turquesa en `shared/utils.ts`

**Características del template**:
- Diseño responsivo (max-width: 600px)
- Colores corporativos: Turquesa #4ECDC4 y #26A69A
- Header con gradiente turquesa
- Botón CTA con gradiente y shadow
- Secciones de advertencia (expira 24h, seguridad)
- Footer con información de aprobación pendiente
- Marca: "Importadora Hiltex"

**Variables dinámicas**:
- `{nombreCompleto}`: Nombre del usuario
- `{confirmLink}`: URL completa con token (formato: `{FRONTEND_URL}/confirm-email?token={token}`)

**Ver código completo**: `C:\SystemWebMedias3.0\supabase\functions\shared\utils.ts` función `getConfirmationEmailTemplate()`

### Configuración de Email Service:

✅ **Implementado**: Integración con Resend API para envío de emails

**Configuración requerida**:
```bash
# Variables de entorno (.env)
RESEND_API_KEY=re_xxxxxxxxxxxxx
FRONTEND_URL=http://localhost:3000
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Detalles de implementación**:
- Servicio: Resend API (https://resend.com)
- From: `Importadora Hiltex <noreply@hiltex.com>`
- Subject: "Confirma tu email - Importadora Hiltex"
- Content-Type: text/html
- Implementado en: `shared/utils.ts` y usado por register/resend-confirmation

**Alternativas para producción**:
- Configurar SMTP propio en Supabase
- Usar SendGrid, AWS SES, o Mailgun
- El código está preparado para cambiar fácilmente el proveedor

---

## Resumen de Implementación

### Archivos creados:

**Migrations**:
- ✅ `supabase/migrations/20251004145739_hu001_users_registration.sql`

**Edge Functions**:
- ✅ `supabase/functions/auth/register/index.ts`
- ✅ `supabase/functions/auth/confirm-email/index.ts`
- ✅ `supabase/functions/auth/resend-confirmation/index.ts`

**Shared Utilities**:
- ✅ `supabase/functions/shared/types.ts` - Tipos TypeScript
- ✅ `supabase/functions/shared/utils.ts` - Utilidades (CORS, email, hash, etc)
- ✅ `supabase/functions/shared/validators.ts` - Validaciones de request

**Configuración**:
- ✅ `supabase/functions/deno.json` - Configuración Deno

### Endpoints disponibles:

1. `POST http://localhost:54321/functions/v1/auth/register`
2. `GET http://localhost:54321/functions/v1/auth/confirm-email?token={token}`
3. `POST http://localhost:54321/functions/v1/auth/resend-confirmation`

### Reglas de Negocio implementadas:

- ✅ **RN-001**: Email único case-insensitive (índice único + validación)
- ✅ **RN-002**: Password hasheado con bcrypt, mínimo 8 caracteres, confirmación
- ✅ **RN-003**: Token confirmación 24h validez, límite 3 reenvíos/hora
- ✅ **RN-004**: Estados controlados por ENUM user_estado
- ✅ **RN-005**: Estados validados en RLS policies
- ✅ **RN-006**: Campos obligatorios con validaciones de formato
- ✅ **RN-007**: Rol nullable, asignado al aprobar

### Cambios vs Diseño Inicial:

1. **Email service**: Implementado con Resend API en lugar de SMTP directo de Supabase
   - Más simple para desarrollo
   - Fácil de cambiar a SMTP en producción

2. **Tabla auxiliar**: Agregada `confirmation_resend_attempts` para rate limiting
   - Implementa límite de 3 reenvíos/hora de forma robusta
   - Almacena IP para auditoría

3. **RLS Policies**: Agregadas 2 policies adicionales
   - `public_insert_users`: Permite registro sin autenticación
   - `users_update_own_profile`: Usuarios pueden actualizar su perfil

4. **Template email**: Template HTML mejorado con diseño corporativo
   - Gradientes turquesa
   - Secciones de advertencia
   - Responsive design
   - Marca "Importadora Hiltex"

Todos los cambios mejoran la implementación sin afectar la especificación original.
