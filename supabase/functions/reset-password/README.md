# Edge Function: reset-password

## Propósito

Cambiar la contraseña de un usuario usando un token de recuperación mediante Supabase Admin API.

## Razón de Existencia

Esta función reemplaza la función SQL `reset_password()` que presentaba un error crítico:

```
ERROR: operator does not exist: character varying = uuid
HINT: auth.users.encrypted_password no puede ser actualizado directamente con crypt()
```

Supabase Auth requiere el uso de Admin API para actualizar contraseñas de forma segura.

## Endpoint

```
POST /functions/v1/reset-password
```

## Request Body

```json
{
  "token": "AbCdEfGh1234567890...",
  "newPassword": "NewPassword123!",
  "ipAddress": "127.0.0.1"
}
```

### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| token | string | Sí | Token de recuperación (32 bytes URL-safe) |
| newPassword | string | Sí | Nueva contraseña (mínimo 8 caracteres) |
| ipAddress | string | No | IP del cliente (para auditoría) |

## Response

### Success (200)

```json
{
  "success": true,
  "data": {
    "message": "Contraseña actualizada exitosamente. Por seguridad, todas las sesiones activas han sido cerradas."
  }
}
```

### Error (400/500)

```json
{
  "success": false,
  "error": {
    "message": "La contraseña debe tener al menos 8 caracteres",
    "hint": "weak_password"
  }
}
```

## Error Codes

| Hint | Status | Descripción |
|------|--------|-------------|
| missing_params | 400 | Token o password faltantes |
| weak_password | 400 | Password < 8 caracteres |
| invalid_token | 400 | Token no existe en BD |
| expired_token | 400 | Token expirado (>24h) |
| used_token | 400 | Token ya fue utilizado |
| validation_error | 500 | Error validando token |
| update_failed | 500 | Error actualizando password |
| internal_error | 500 | Error inesperado |

## Flujo de Ejecución

1. **Validación de entrada**
   - Verifica token y password no vacíos
   - Valida password >= 8 caracteres

2. **Validación de token**
   - Llama a `validate_reset_token()` RPC
   - Verifica token no expirado ni usado

3. **Actualización de password**
   - Usa `supabaseAdmin.auth.admin.updateUserById()`
   - Hashing automático por Supabase Auth

4. **Marcar token como usado**
   - Actualiza `password_recovery.used_at`

5. **Cerrar sesiones activas**
   - Usa `supabaseAdmin.auth.admin.signOut(userId)`

6. **Auditoría**
   - Registra en `audit_log` (event_type: 'password_reset')

## Variables de Entorno Requeridas

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## Testing Local

### 1. Iniciar función localmente

```bash
npx supabase functions serve reset-password --no-verify-jwt
```

### 2. Generar token de prueba

```sql
SELECT request_password_reset('test@example.com', '127.0.0.1'::INET);
```

### 3. Obtener token

```sql
SELECT token FROM password_recovery
WHERE email = 'test@example.com'
ORDER BY created_at DESC
LIMIT 1;
```

### 4. Probar función

```bash
curl -X POST "http://127.0.0.1:54321/functions/v1/reset-password" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "TOKEN_AQUI",
    "newPassword": "NewPassword123!",
    "ipAddress": "127.0.0.1"
  }'
```

### 5. Verificar resultado

```sql
-- Token marcado como usado
SELECT used_at FROM password_recovery
WHERE email = 'test@example.com'
ORDER BY created_at DESC LIMIT 1;

-- Registro en auditoría
SELECT * FROM audit_log
WHERE event_type = 'password_reset'
ORDER BY created_at DESC LIMIT 1;
```

## Deployment

### Producción

```bash
npx supabase functions deploy reset-password
```

### Verificar logs

```bash
npx supabase functions logs reset-password
```

## Integración con Flutter

```dart
final response = await supabase.functions.invoke(
  'reset-password',
  body: {
    'token': token,
    'newPassword': newPassword,
    'ipAddress': ipAddress,
  },
);

if (response.status == 200) {
  final data = response.data as Map<String, dynamic>;
  if (data['success'] == true) {
    // Password actualizado exitosamente
    // Redirigir a login
  }
} else {
  final error = response.data as Map<String, dynamic>;
  final hint = error['error']['hint'];
  // Manejar error según hint
}
```

## Seguridad

- ✅ Validación de entrada robusta
- ✅ Rate limiting manejado por `validate_reset_token()`
- ✅ Tokens únicos y URL-safe
- ✅ Expiración automática (24h)
- ✅ Hashing automático por Supabase Auth
- ✅ Invalidación de sesiones activas
- ✅ Auditoría completa
- ✅ CORS configurado
- ✅ Sin exposición de datos sensibles

## Ventajas vs Función SQL

1. **Compatibilidad**: Usa Admin API, no acceso directo a `auth.users`
2. **Hashing**: Gestionado automáticamente por Supabase
3. **Logs**: Centralizados en Supabase Dashboard
4. **Flexibilidad**: Fácil de extender (ej: envío de emails)
5. **Mantenibilidad**: TypeScript con tipos fuertes

## Archivos Relacionados

- Migration: `supabase/migrations/20251006214500_hu004_password_recovery.sql`
- DataSource: `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Docs: `docs/technical/backend/apis_E001-HU-004.md`
- Tests: `supabase/test_reset_password_edge_function.sql`

## Autor

**Agente**: @supabase-expert
**Fecha**: 2025-10-06
**HU**: E001-HU-004 - Recuperar Contraseña
