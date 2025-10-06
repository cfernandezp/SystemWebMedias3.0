# Estrategia Dual-Track de Migraciones

**Propósito**: Mantener migraciones incrementales para desarrollo Y consolidadas para producción simultáneamente.

**Fecha**: 2025-10-05
**Responsable**: @supabase-expert

---

## 🎯 CONCEPTO: Dual-Track Migrations

### Filosofía:
Mantener **2 versiones** de las migraciones en paralelo:

1. **Track Incremental** (`/migrations/`) - Para desarrollo
2. **Track Consolidado** (`/migrations-consolidated/`) - Para producción

---

## 📁 ESTRUCTURA DE CARPETAS

```
supabase/
├── migrations/                          ← DESARROLLO (incremental)
│   ├── 20251004145739_hu001_users_registration.sql
│   ├── 20251004170000_hu001_database_functions.sql
│   ├── 20251004180000_fix_database_functions.sql
│   ├── 20251005040208_hu002_login_functions.sql
│   ├── 20251005042727_fix_hu002_use_supabase_auth.sql
│   └── ... (múltiples archivos - historial completo)
│
└── migrations-consolidated/             ← PRODUCCIÓN (limpio)
    ├── E001_authentication_system.sql   ← Consolidado de HU-001 a HU-004
    ├── E002_product_management.sql      ← Consolidado de HU-005 a HU-008
    └── README.md                        ← Índice de consolidados
```

---

## 🔄 FLUJO DE TRABAJO

### Para @supabase-expert

Cada vez que implementas una HU, haces **2 pasos**:

#### PASO 1: Crear migración incremental (como siempre)

```bash
# Crear migración para desarrollo
supabase migration new hu003_logout_functions

# Escribir SQL en:
supabase/migrations/20251006120000_hu003_logout_functions.sql
```

#### PASO 2: Actualizar migración consolidada

```bash
# Editar archivo consolidado de la épica
vim supabase/migrations-consolidated/E001_authentication_system.sql
```

**Agregar tu cambio al final del archivo consolidado:**

```sql
-- ============================================
-- HU-003: Logout Seguro
-- Fecha: 2025-10-06
-- Implementado por: @supabase-expert
-- ============================================

CREATE OR REPLACE FUNCTION logout_user(
    p_token TEXT
)
RETURNS JSON AS $$
BEGIN
    -- Lógica de logout
    ...
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION logout_user IS 'HU-003: Invalida token de sesión';
```

---

## 📝 TEMPLATE: Archivo Consolidado

### Estructura de `E001_authentication_system.sql`

```sql
-- ============================================
-- ÉPICA: E001 - Sistema de Autenticación y Autorización
-- ============================================
-- Descripción: Infraestructura completa para registro, login, logout y password reset
-- HUs incluidas: HU-001, HU-002, HU-003, HU-004
-- Última actualización: 2025-10-06
-- Responsable: @supabase-expert
--
-- NOTAS:
-- - Este archivo es la versión CONSOLIDADA para producción
-- - Migraciones incrementales en: supabase/migrations/202510*.sql
-- - Ver historial completo en Git
-- ============================================

BEGIN;

-- ============================================
-- PASO 1: ENUMs y Tipos Base
-- ============================================
-- Implementado en: HU-001
-- Fecha: 2025-10-04

CREATE TYPE user_role AS ENUM ('ADMIN', 'GERENTE', 'VENDEDOR');
CREATE TYPE user_estado AS ENUM ('REGISTRADO', 'APROBADO', 'RECHAZADO', 'SUSPENDIDO');

COMMENT ON TYPE user_role IS 'HU-001: Roles de usuario en el sistema';
COMMENT ON TYPE user_estado IS 'HU-001: Estados del ciclo de vida del usuario';


-- ============================================
-- PASO 2: Tablas Principales
-- ============================================
-- Implementado en: HU-001
-- Última modificación: HU-002 (agregó login_attempts)

-- Tabla users (HU-001)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    nombre_completo TEXT NOT NULL,
    rol user_role,
    estado user_estado NOT NULL DEFAULT 'REGISTRADO',
    email_verificado BOOLEAN NOT NULL DEFAULT false,
    token_confirmacion TEXT,
    token_expiracion TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla login_attempts (HU-002)
CREATE TABLE login_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address TEXT,
    success BOOLEAN NOT NULL
);


-- ============================================
-- PASO 3: Índices
-- ============================================

-- HU-001: Índices para users
CREATE INDEX idx_users_email ON users(LOWER(email));
CREATE INDEX idx_users_estado ON users(estado);
CREATE INDEX idx_users_token_confirmacion ON users(token_confirmacion);

-- HU-002: Índices para login_attempts
CREATE INDEX idx_login_attempts_email_time ON login_attempts(email, attempted_at);


-- ============================================
-- PASO 4: Funciones de Negocio
-- ============================================

-- ============================================
-- HU-001: Registro de Usuarios
-- Fecha: 2025-10-04
-- ============================================

CREATE OR REPLACE FUNCTION register_user(
    p_email TEXT,
    p_password TEXT,
    p_nombre_completo TEXT
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_token TEXT;
BEGIN
    -- Lógica de registro...
    -- (código completo aquí)
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION register_user IS 'HU-001: Registra nuevo usuario con validaciones';


-- ============================================
-- HU-002: Login de Usuarios
-- Fecha: 2025-10-05
-- ============================================

CREATE OR REPLACE FUNCTION check_login_rate_limit(
    p_email TEXT,
    p_ip_address TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Lógica de rate limiting...
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION login_user(
    p_email TEXT,
    p_password TEXT,
    p_remember_me BOOLEAN DEFAULT false
)
RETURNS JSON AS $$
BEGIN
    -- Lógica de login...
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION login_user IS 'HU-002: Autentica usuario y genera token JWT';


-- ============================================
-- HU-003: Logout Seguro
-- Fecha: 2025-10-06
-- ============================================

CREATE OR REPLACE FUNCTION logout_user(
    p_token TEXT
)
RETURNS JSON AS $$
BEGIN
    -- Lógica de logout...
    -- (PENDIENTE - agregar cuando implementes HU-003)
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION logout_user IS 'HU-003: Invalida token de sesión';


-- ============================================
-- HU-004: Recuperar Contraseña
-- Fecha: PENDIENTE
-- ============================================

-- (Agregar cuando implementes HU-004)


-- ============================================
-- PASO 5: Triggers
-- ============================================

-- HU-001: Auto-update de updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


-- ============================================
-- PASO 6: RLS Policies (si aplica)
-- ============================================

-- (Agregar si decides usar RLS)


-- ============================================
-- PASO 7: Datos Semilla (opcional)
-- ============================================

-- Usuario admin de prueba (SOLO desarrollo)
-- INSERT INTO users (email, password_hash, nombre_completo, rol, estado, email_verificado)
-- VALUES ('admin@test.com', crypt('Admin123!', gen_salt('bf')), 'Admin Test', 'ADMIN', 'APROBADO', true);


COMMIT;

-- ============================================
-- FIN DE MIGRACIÓN CONSOLIDADA
-- ============================================
-- Total HUs: 4 (HU-001, HU-002, HU-003, HU-004)
-- Total funciones: 4 (register, login, logout, reset_password)
-- Total tablas: 2 (users, login_attempts)
-- ============================================
```

---

## 📋 CHECKLIST para @supabase-expert

Cada vez que crees/modifiques una migración:

### ✅ Migración Incremental (obligatorio)
- [ ] Crear archivo en `/migrations/` con timestamp
- [ ] Incluir comentarios con CA/RN
- [ ] Probar localmente
- [ ] Aplicar con `supabase db reset`

### ✅ Migración Consolidada (obligatorio)
- [ ] Editar archivo épica correspondiente en `/migrations-consolidated/`
- [ ] Agregar sección con número de HU y fecha
- [ ] Copiar función/tabla/índice completo (no solo cambios)
- [ ] Actualizar comentario de "Última actualización"
- [ ] Actualizar contador de HUs/funciones al final

### ✅ Documentación (obligatorio)
- [ ] Actualizar `migrations-consolidated/README.md`
- [ ] Agregar entrada en CHANGELOG (si aplica)

---

## 🎯 VENTAJAS de Dual-Track

### ✅ Para Desarrollo:
- Historial granular completo (`/migrations/`)
- Debugging fácil (cada cambio es rastreable)
- Rollback incremental posible
- Flujo ágil sin interrupciones

### ✅ Para Producción:
- Archivo limpio y consolidado (`/migrations-consolidated/`)
- Fácil de revisar (1 archivo por épica)
- Reducción drástica de archivos (20 → 1)
- Deploy simple y rápido

### ✅ Para el Equipo:
- No requiere squash manual
- El agente mantiene ambas versiones sincronizadas
- Decisión clara: desarrollo usa `/migrations/`, producción usa `/migrations-consolidated/`

---

## 🚀 IMPLEMENTACIÓN

### Paso 1: Crear estructura inicial

```bash
# Crear carpeta consolidados
mkdir -p supabase/migrations-consolidated

# Crear archivo para E001
touch supabase/migrations-consolidated/E001_authentication_system.sql

# Crear README
touch supabase/migrations-consolidated/README.md
```

### Paso 2: Configurar Supabase para usar consolidados en producción

En `supabase/config.toml`:

```toml
[db.migrations]
enabled = true
# DESARROLLO: usa /migrations
# PRODUCCIÓN: cambiar a /migrations-consolidated cuando deploys
schema_paths = []
```

### Paso 3: Primera consolidación (para E001 actual)

```bash
# 1. Exportar schema actual
supabase db dump -f supabase/migrations-consolidated/E001_authentication_system.sql

# 2. Limpiar archivo (remover schemas sistema)
vim supabase/migrations-consolidated/E001_authentication_system.sql

# 3. Agregar comentarios de documentación (usar template arriba)
```

---

## ⚠️ REGLAS IMPORTANTES

### ❌ NO hacer:
- Modificar manualmente `/migrations/` consolidados (son history)
- Usar `/migrations-consolidated/` en desarrollo local
- Deployar `/migrations/` a producción

### ✅ SÍ hacer:
- Mantener ambas carpetas sincronizadas
- Usar `/migrations/` para `supabase db reset` local
- Usar `/migrations-consolidated/` para deploys a staging/prod
- Documentar cada cambio en consolidado

---

## 🔄 FLUJO DE DEPLOY

### Desarrollo Local:
```bash
# Usa migraciones incrementales
supabase db reset  # Lee de /migrations/
```

### Staging/Producción:
```bash
# Usa migraciones consolidadas
supabase db push --db-url $STAGING_URL \
  --migrations-path supabase/migrations-consolidated/
```

---

## 📊 COMPARACIÓN con Estrategias Anteriores

| Aspecto | Incremental Solo | Squash Manual | Dual-Track ✅ |
|---------|------------------|---------------|---------------|
| Desarrollo rápido | ✅ | ❌ | ✅ |
| Historia limpia producción | ❌ | ✅ | ✅ |
| Debugging fácil | ✅ | ❌ | ✅ |
| Requiere intervención manual | ❌ | ✅ | ❌ |
| Escalable a 100+ HUs | ❌ | ⚠️ | ✅ |
| Mantenido por agente | ✅ | ❌ | ✅ |

---

**Última actualización**: 2025-10-05
**Responsable de mantenimiento**: @supabase-expert
