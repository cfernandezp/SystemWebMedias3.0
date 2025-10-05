# Backend HU-001: Registro de Alta al Sistema

**Estado**: ✅ Implementado
**Fecha**: 2025-10-04
**Implementado por**: @supabase-expert

---

## Estructura de Archivos

```
supabase/
├── migrations/
│   └── 20251004145739_hu001_users_registration.sql
├── functions/
│   ├── auth/
│   │   ├── register/index.ts
│   │   ├── confirm-email/index.ts
│   │   └── resend-confirmation/index.ts
│   ├── shared/
│   │   ├── types.ts
│   │   ├── utils.ts
│   │   └── validators.ts
│   └── deno.json
├── policies/
└── seed/
```

---

## Paso 1: Configurar Variables de Entorno

Crear archivo `.env` en la raíz del proyecto Supabase:

```bash
# Supabase Configuration
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=tu_anon_key_aqui

# Frontend URL
FRONTEND_URL=http://localhost:3000

# Email Service (Resend API)
RESEND_API_KEY=re_tu_api_key_aqui
```

**Obtener claves**:
- `SUPABASE_ANON_KEY`: Ejecutar `supabase status` después de iniciar el proyecto
- `RESEND_API_KEY`: Crear cuenta gratuita en https://resend.com (100 emails/día gratis)

---

## Paso 2: Aplicar Migration

```bash
# Iniciar Supabase local
supabase start

# Aplicar migration
supabase db reset

# O aplicar solo esta migration
supabase migration up
```

**Verificar que se creó correctamente**:

```sql
-- Conectar a la BD local
psql postgresql://postgres:postgres@localhost:54322/postgres

-- Verificar tablas
\dt

-- Verificar ENUMs
\dT

-- Verificar estructura de users
\d users

-- Verificar RLS policies
\d+ users
```

Deberías ver:
- Tabla `users` con 11 campos
- Tabla `confirmation_resend_attempts`
- ENUMs `user_role` y `user_estado`
- 5 policies RLS activas

---

## Paso 3: Deployar Edge Functions

```bash
# Deploy todas las funciones de auth
supabase functions deploy auth/register
supabase functions deploy auth/confirm-email
supabase functions deploy auth/resend-confirmation

# O deployar todas a la vez
supabase functions deploy
```

**Configurar secrets (variables de entorno para functions)**:

```bash
# Para desarrollo local (archivo .env.local en supabase/functions/)
echo "RESEND_API_KEY=re_xxx" > supabase/functions/.env.local
echo "FRONTEND_URL=http://localhost:3000" >> supabase/functions/.env.local

# Para producción (Supabase Cloud)
supabase secrets set RESEND_API_KEY=re_xxx
supabase secrets set FRONTEND_URL=https://tuapp.com
```

---

## Paso 4: Probar Endpoints

### 4.1 Probar Registro (POST /auth/register)

```bash
curl -X POST http://localhost:54321/functions/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "confirm_password": "password123",
    "nombre_completo": "Usuario de Prueba"
  }'
```

**Response esperada (201)**:
```json
{
  "id": "uuid-generado",
  "email": "test@example.com",
  "nombre_completo": "Usuario de Prueba",
  "estado": "REGISTRADO",
  "email_verificado": false,
  "created_at": "2025-10-04T...",
  "message": "Registro exitoso. Revisa tu email para confirmar tu cuenta"
}
```

### 4.2 Probar Email Duplicado (409)

```bash
# Ejecutar el mismo curl anterior otra vez
# Response esperada:
{
  "error": "DUPLICATE_EMAIL",
  "message": "Este email ya está registrado"
}
```

### 4.3 Probar Validaciones (400)

```bash
# Contraseña corta
curl -X POST http://localhost:54321/functions/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test2@example.com",
    "password": "123",
    "confirm_password": "123",
    "nombre_completo": "Usuario 2"
  }'

# Response esperada:
{
  "error": "VALIDATION_ERROR",
  "message": "Contraseña debe tener al menos 8 caracteres",
  "field": "password"
}
```

### 4.4 Probar Confirmación de Email

```bash
# 1. Extraer el token del email recibido (o de la BD)
psql postgresql://postgres:postgres@localhost:54322/postgres
SELECT token_confirmacion FROM users WHERE email = 'test@example.com';

# 2. Confirmar email
curl -X GET "http://localhost:54321/functions/v1/auth/confirm-email?token=TOKEN_AQUI"

# Response esperada (200):
{
  "message": "Email confirmado exitosamente",
  "email_verificado": true,
  "estado": "REGISTRADO",
  "next_step": "Tu cuenta está esperando aprobación del administrador..."
}
```

### 4.5 Probar Reenvío de Confirmación

```bash
curl -X POST http://localhost:54321/functions/v1/auth/resend-confirmation \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com"
  }'

# Response esperada (200):
{
  "message": "Email de confirmación reenviado exitosamente",
  "token_expiracion": "2025-10-05T..."
}
```

### 4.6 Probar Límite de Reenvíos (429)

```bash
# Ejecutar el curl anterior 4 veces seguidas
# En el 4to intento:
{
  "error": "RATE_LIMIT_EXCEEDED",
  "message": "Máximo 3 reenvíos por hora. Intenta más tarde",
  "retry_after": "2025-10-04T16:00:00Z"
}
```

---

## Paso 5: Verificar Base de Datos

```sql
-- Ver usuarios creados
SELECT id, email, nombre_completo, estado, email_verificado, created_at
FROM users;

-- Ver intentos de reenvío
SELECT * FROM confirmation_resend_attempts;

-- Verificar que tokens se limpian después de confirmar
SELECT email, token_confirmacion, token_expiracion
FROM users
WHERE email_verificado = true;
-- Deberían ser NULL
```

---

## Paso 6: Probar RLS Policies

```sql
-- Simular usuario autenticado (usando auth.uid())
-- Esto se probará mejor cuando se implemente login (HU-002)

-- Por ahora, verificar que las policies están activas
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename = 'users';

-- Deberías ver 5 policies
```

---

## Checklist de Validación

### Base de Datos
- [ ] Migration aplicada sin errores
- [ ] Tabla `users` existe con 11 campos
- [ ] Tabla `confirmation_resend_attempts` existe
- [ ] ENUMs `user_role` y `user_estado` existen
- [ ] Índices creados (email, estado, token)
- [ ] Trigger `update_users_updated_at` funciona
- [ ] RLS habilitado y 5 policies activas

### Edge Functions
- [ ] POST /auth/register responde 201 con datos correctos
- [ ] POST /auth/register valida email duplicado (409)
- [ ] POST /auth/register valida contraseña corta (400)
- [ ] POST /auth/register valida contraseñas no coinciden (400)
- [ ] GET /auth/confirm-email confirma email correctamente
- [ ] GET /auth/confirm-email rechaza token inválido (400)
- [ ] GET /auth/confirm-email rechaza token expirado (400)
- [ ] POST /auth/resend-confirmation funciona
- [ ] POST /auth/resend-confirmation aplica límite 3/hora (429)

### Email
- [ ] Email de confirmación se envía
- [ ] Email usa template corporativo turquesa
- [ ] Enlace en email funciona
- [ ] Email tiene información correcta (nombre, enlace)

### Reglas de Negocio
- [ ] RN-001: Email único case-insensitive
- [ ] RN-002: Password hasheado, >= 8 caracteres, confirmación
- [ ] RN-003: Token 24h, límite 3 reenvíos/hora
- [ ] RN-004: Estados ENUM funcionan
- [ ] RN-005: Estados validados en RLS
- [ ] RN-006: Campos obligatorios validados
- [ ] RN-007: Rol nullable, no asignado al registrar

---

## Troubleshooting

### Error: "Email no se envía"

**Causa**: `RESEND_API_KEY` no configurado

**Solución**:
```bash
# Crear cuenta en resend.com
# Obtener API key
# Configurar en .env.local
echo "RESEND_API_KEY=re_tu_key" > supabase/functions/.env.local

# Re-deployar función
supabase functions deploy auth/register
```

### Error: "Duplicate key violation"

**Causa**: Email ya existe en BD

**Solución**:
```sql
-- Limpiar usuarios de prueba
DELETE FROM users WHERE email LIKE '%@example.com';
```

### Error: "Token expirado"

**Causa**: Token tiene más de 24h

**Solución**:
```bash
# Reenviar confirmación
curl -X POST http://localhost:54321/functions/v1/auth/resend-confirmation \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'
```

### Error: "bcrypt import failed"

**Causa**: Deno no puede descargar dependencias

**Solución**:
```bash
# Limpiar cache de Deno
deno cache --reload supabase/functions/shared/utils.ts
```

---

## Siguientes Pasos

1. **@flutter-expert**: Implementar modelos y repositorio que consuman estos endpoints
2. **@ux-ui-expert**: Implementar pantallas de registro y confirmación de email
3. **@supabase-expert**: Implementar HU-002 (Login) que use la tabla `users` creada
4. **QA**: Probar flujo completo de registro desde frontend

---

## Contacto

**Dudas técnicas**: Revisar documentación en `docs/technical/backend/`
**Bugs**: Reportar en canal de desarrollo
**Cambios en diseño**: Consultar con @web-architect-expert
