# Schema Backend - HU-004: Recuperar Contraseña

**Epic**: E001 - Autenticación
**Historia**: HU-004 - Recuperar Contraseña
**Agente**: @supabase-expert
**Fecha**: 2025-10-06
**Estado**: ✅ Implementado

---

## Tabla: password_recovery

### Estructura

```sql
CREATE TABLE IF NOT EXISTS password_recovery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    token TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Índices

```sql
CREATE INDEX idx_password_recovery_token ON password_recovery(token);
CREATE INDEX idx_password_recovery_user_id ON password_recovery(user_id);
CREATE INDEX idx_password_recovery_email ON password_recovery(email);
CREATE INDEX idx_password_recovery_expires_at ON password_recovery(expires_at);
```

### Comentarios

```sql
COMMENT ON TABLE password_recovery IS 'HU-004: Tokens de recuperacion de contrasena - RN-004-PASSWORD';
COMMENT ON COLUMN password_recovery.token IS 'Token seguro URL-safe de 32 bytes';
COMMENT ON COLUMN password_recovery.expires_at IS 'Expiracion: 24 horas desde creacion';
COMMENT ON COLUMN password_recovery.used_at IS 'Marca de tiempo cuando token fue usado - NULL si no usado';
COMMENT ON COLUMN password_recovery.ip_address IS 'IP desde donde se solicito la recuperacion';
```

### Columnas

| Columna | Tipo | Constraints | Descripción |
|---------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() | Identificador único del token |
| user_id | UUID | NOT NULL, FK → auth.users(id) ON DELETE CASCADE | Usuario que solicita recuperación |
| email | TEXT | NOT NULL | Email del usuario (para auditoría) |
| token | TEXT | NOT NULL, UNIQUE | Token seguro URL-safe de 32 bytes |
| expires_at | TIMESTAMP WITH TIME ZONE | NOT NULL | Fecha de expiración (24 horas) |
| used_at | TIMESTAMP WITH TIME ZONE | NULL | Marca de uso del token |
| ip_address | INET | NULL | IP de origen de la solicitud |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Fecha de creación |

### Reglas de Negocio

- **RN-004.1**: Token debe ser único y URL-safe (32 bytes)
- **RN-004.2**: Expiración automática a las 24 horas
- **RN-004.3**: Token de uso único (used_at se marca al usar)
- **RN-004.4**: Rate limiting: máximo 3 solicitudes en 15 minutos por usuario
- **RN-004.5**: Tokens anteriores del usuario se invalidan al generar uno nuevo
- **RN-004.6**: Cascada: Si se elimina usuario, se eliminan sus tokens

### Relaciones

```
password_recovery.user_id → auth.users.id (ON DELETE CASCADE)
```

---

## Migration Aplicada

**Archivo**: `supabase/migrations/20251006214500_hu004_password_recovery.sql`
**Estado**: ✅ Aplicado exitosamente
**Fecha**: 2025-10-06 21:45:00

---

## Verificación

### Verificar tabla existe
```sql
SELECT table_name FROM information_schema.tables
WHERE table_name = 'password_recovery';
```

### Verificar estructura
```sql
\d+ password_recovery
```

### Verificar índices
```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'password_recovery';
```

---

## Notas Técnicas

### Migración de reset_password() a Edge Function

**Fecha**: 2025-10-06
**Razón**: Error crítico en función SQL `reset_password()`

```
ERROR: operator does not exist: character varying = uuid
HINT: auth.users.encrypted_password no puede ser actualizado con crypt()
```

**Solución**:
- Función SQL mantenida solo como referencia/fallback
- Implementación migrada a Edge Function `/functions/reset-password`
- Uso de Supabase Admin API (`admin.updateUserById()`) para actualizar passwords
- Hashing automático gestionado por Supabase Auth

**Archivos Afectados**:
- `supabase/functions/reset-password/index.ts` (NUEVO)
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` (MODIFICADO)
- Ver: `apis_E001-HU-004.md` sección "Edge Functions"

---

## Próximos Pasos

- ✅ Tabla creada
- ✅ Índices aplicados
- ✅ Funciones RPC implementadas
- ✅ Edge Function reset-password implementada
- ✅ Frontend Flutter actualizado a Edge Function
- ⏳ UI Components por implementar
- ⏳ Testing end-to-end

---

**Implementado por**: @supabase-expert
**Fecha**: 2025-10-06
**Última actualización**: 2025-10-06 (Migración a Edge Function)
