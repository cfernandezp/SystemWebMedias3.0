# Schema BD - E001-HU-003: Logout Seguro

**HU**: E001-HU-003 - Logout Seguro
**Responsable**: @supabase-expert
**Fecha de diseño**: 2025-10-06

---

## 📊 TABLAS NUEVAS

### 1. token_blacklist (Tokens Invalidados)

Almacena tokens JWT que han sido invalidados por logout.

```sql
CREATE TABLE token_blacklist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token TEXT NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blacklisted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    reason TEXT CHECK (reason IN ('manual_logout', 'inactivity', 'token_expired'))
);

-- Índices para performance
CREATE INDEX idx_token_blacklist_token ON token_blacklist(token);
CREATE INDEX idx_token_blacklist_expires_at ON token_blacklist(expires_at);
CREATE INDEX idx_token_blacklist_user_id ON token_blacklist(user_id);

-- Comentarios
COMMENT ON TABLE token_blacklist IS 'HU-003: Tokens JWT invalidados por logout - RN-003-LOGOUT.3';
COMMENT ON COLUMN token_blacklist.token IS 'Token JWT invalidado (hash)';
COMMENT ON COLUMN token_blacklist.reason IS 'Motivo de invalidación: manual_logout, inactivity, token_expired';
COMMENT ON COLUMN token_blacklist.expires_at IS 'Fecha de expiración original del token';
```

**Reglas de negocio**:
- **RN-003-LOGOUT.3**: Token invalidado NO puede usarse para futuras peticiones
- **RN-003-LOGOUT.7**: Tokens de "Recordarme" también se invalidan en logout manual
- Cleanup automático de tokens expirados cada 24 horas

---

### 2. audit_logs (Auditoría de Seguridad)

Registra todos los eventos de seguridad del sistema.

```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL CHECK (event_type IN ('login', 'logout', 'password_change', 'password_reset', 'email_change')),
    event_subtype TEXT,  -- 'manual', 'inactivity', 'token_expired', 'remember_me', etc.
    ip_address INET,
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para consultas
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_event_type ON audit_logs(event_type);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);

-- Comentarios
COMMENT ON TABLE audit_logs IS 'HU-003: Auditoría de eventos de seguridad - RN-003-LOGOUT.9';
COMMENT ON COLUMN audit_logs.event_type IS 'Tipo de evento: login, logout, password_change, etc.';
COMMENT ON COLUMN audit_logs.event_subtype IS 'Subtipo del evento (ej: manual, inactivity, token_expired)';
COMMENT ON COLUMN audit_logs.metadata IS 'Información adicional del evento (session_duration, etc.)';
```

**Reglas de negocio**:
- **RN-003-LOGOUT.9**: Registro de todos los eventos de logout (manual/automático)
- Información sensible NO se almacena en logs
- Logs consultables para auditorías de seguridad

---

## 🔄 MODIFICACIONES A TABLAS EXISTENTES

### users (Tracking de Actividad)

```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Índice para consultas de inactividad
CREATE INDEX idx_users_last_activity_at ON users(last_activity_at);

-- Comentario
COMMENT ON COLUMN users.last_activity_at IS 'HU-003: Última actividad del usuario para detección de inactividad - RN-003-LOGOUT.5';
```

**Reglas de negocio**:
- **RN-003-LOGOUT.5**: Si `last_activity_at` > 2 horas → logout automático
- Se actualiza en cada request autenticado
- Warning de inactividad 5 minutos antes (115 minutos)

---

## 🔍 QUERIES IMPORTANTES

### Verificar si Token está en Blacklist

```sql
SELECT EXISTS (
    SELECT 1
    FROM token_blacklist
    WHERE token = $1
      AND expires_at > NOW()
) AS is_blacklisted;
```

### Detectar Usuarios Inactivos

```sql
SELECT id, email, last_activity_at,
       NOW() - last_activity_at AS inactive_duration
FROM users
WHERE last_activity_at < NOW() - INTERVAL '2 hours'
  AND id IN (
      -- Solo usuarios con sesión activa
      SELECT DISTINCT user_id FROM sessions WHERE expires_at > NOW()
  );
```

### Limpiar Tokens Expirados de Blacklist

```sql
DELETE FROM token_blacklist
WHERE expires_at < NOW();
```

### Consultar Historial de Logouts de un Usuario

```sql
SELECT
    event_subtype,
    ip_address,
    metadata->>'session_duration' AS session_duration,
    created_at
FROM audit_logs
WHERE user_id = $1
  AND event_type = 'logout'
ORDER BY created_at DESC
LIMIT 20;
```

---

## 📝 MIGRATION FILE

**Nombre**: `20251006_hu003_logout_seguro.sql`

```sql
-- Migration: HU-003 Logout Seguro
-- Fecha: 2025-10-06
-- Responsable: @supabase-expert

BEGIN;

-- 1. Tabla token_blacklist
CREATE TABLE IF NOT EXISTS token_blacklist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token TEXT NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blacklisted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    reason TEXT CHECK (reason IN ('manual_logout', 'inactivity', 'token_expired'))
);

CREATE INDEX idx_token_blacklist_token ON token_blacklist(token);
CREATE INDEX idx_token_blacklist_expires_at ON token_blacklist(expires_at);
CREATE INDEX idx_token_blacklist_user_id ON token_blacklist(user_id);

COMMENT ON TABLE token_blacklist IS 'HU-003: Tokens JWT invalidados por logout - RN-003-LOGOUT.3';

-- 2. Tabla audit_logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL CHECK (event_type IN ('login', 'logout', 'password_change', 'password_reset', 'email_change')),
    event_subtype TEXT,
    ip_address INET,
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_event_type ON audit_logs(event_type);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);

COMMENT ON TABLE audit_logs IS 'HU-003: Auditoría de eventos de seguridad - RN-003-LOGOUT.9';

-- 3. Modificar tabla users
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

CREATE INDEX idx_users_last_activity_at ON users(last_activity_at);

COMMENT ON COLUMN users.last_activity_at IS 'HU-003: Última actividad del usuario para detección de inactividad - RN-003-LOGOUT.5';

COMMIT;
```

---

## ✅ VALIDACIONES

Después de aplicar migration, verificar:

```sql
-- Verificar tablas creadas
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('token_blacklist', 'audit_logs');

-- Verificar columna en users
SELECT column_name FROM information_schema.columns
WHERE table_name = 'users'
  AND column_name = 'last_activity_at';

-- Verificar índices
SELECT indexname FROM pg_indexes
WHERE tablename IN ('token_blacklist', 'audit_logs', 'users')
ORDER BY tablename, indexname;
```

---

## 📊 DIAGRAMA ER (Relaciones)

```
users (1) ----< (N) token_blacklist
  |
  |
  v
(0..N) audit_logs
```

**Relaciones**:
- `token_blacklist.user_id` → `users.id` (CASCADE on DELETE)
- `audit_logs.user_id` → `users.id` (SET NULL on DELETE)

---

## 🔐 SECURITY CONSIDERATIONS

1. **Token Storage**: Almacenar hash del token, NO el token completo
2. **Audit Logs**: NO incluir datos sensibles (passwords, tokens) en metadata
3. **Cleanup Job**: Ejecutar cleanup de blacklist diariamente (cron job)
4. **RLS Policies**: Aplicar Row Level Security en audit_logs (solo admins)

---

## 📝 NOTAS DE IMPLEMENTACIÓN

- Verificar que tabla `users` existe antes de agregar columna
- Usar `IF NOT EXISTS` para idempotencia
- Índices críticos para performance: `token`, `expires_at`, `user_id`
- Considerar particionamiento de `audit_logs` si crece mucho (futuro)

---

**Estado**: ⏳ Pendiente de implementación
**Próximo paso**: Implementar funciones en `apis_E001-HU-003.md`
