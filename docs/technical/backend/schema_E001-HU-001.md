# Schema BD - HU-001: Registro de Alta al Sistema

**HU relacionada**: E001-HU-001
**Reglas de negocio**: RN-001, RN-002, RN-003, RN-004, RN-005, RN-006, RN-007
**Migración**: `supabase/migrations/YYYYMMDDHHMMSS_create_users_table.sql`
**Estado**: ✅ Implementado

**DISEÑADO POR**: @web-architect-expert (2025-10-04)
**IMPLEMENTADO POR**: @supabase-expert (2025-10-04)

---

## Tabla: users

### Diseño Propuesto:

```sql
-- Crear ENUM para roles
CREATE TYPE user_role AS ENUM ('ADMIN', 'GERENTE', 'VENDEDOR');

-- Crear ENUM para estados
CREATE TYPE user_estado AS ENUM ('REGISTRADO', 'APROBADO', 'RECHAZADO', 'SUSPENDIDO');

-- Tabla principal de usuarios
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
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

-- Índices para optimización
CREATE INDEX idx_users_email ON users(LOWER(email));
CREATE INDEX idx_users_estado ON users(estado);
CREATE INDEX idx_users_token_confirmacion ON users(token_confirmacion) WHERE token_confirmacion IS NOT NULL;

-- Constraint: email case-insensitive (RN-001)
CREATE UNIQUE INDEX idx_users_email_unique ON users(LOWER(email));

-- Function para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS Policies (Row Level Security)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Solo ADMIN puede ver todos los usuarios
CREATE POLICY "ADMIN can view all users"
    ON users FOR SELECT
    USING (
        auth.jwt() ->> 'rol' = 'ADMIN'
    );

-- Policy: Usuarios pueden ver su propio perfil
CREATE POLICY "Users can view own profile"
    ON users FOR SELECT
    USING (auth.uid() = id);

-- Policy: Solo ADMIN puede actualizar estados y roles
CREATE POLICY "ADMIN can update user status and roles"
    ON users FOR UPDATE
    USING (
        auth.jwt() ->> 'rol' = 'ADMIN'
    );
```

### Campos:

| Campo | Tipo | Descripción | Mapea a Dart | RN Relacionada |
|-------|------|-------------|--------------|----------------|
| `id` | UUID | Primary Key, generado automáticamente | `id` | - |
| `email` | TEXT | Email único (case-insensitive) | `email` | RN-001, RN-006 |
| `password_hash` | TEXT | Contraseña hasheada (bcrypt/argon2) | - | RN-002 |
| `nombre_completo` | TEXT | Nombre completo del usuario | `nombreCompleto` | RN-006 |
| `rol` | ENUM | Rol del usuario (ADMIN, GERENTE, VENDEDOR), nullable | `rol` | RN-007 |
| `estado` | ENUM | Estado actual del usuario | `estado` | RN-004, RN-005 |
| `email_verificado` | BOOLEAN | Si el email fue confirmado | `emailVerificado` | RN-003 |
| `token_confirmacion` | TEXT | Token para confirmar email (24h validez) | - | RN-003 |
| `token_expiracion` | TIMESTAMP | Fecha de expiración del token | - | RN-003 |
| `created_at` | TIMESTAMP | Fecha de creación del registro | `createdAt` | - |
| `updated_at` | TIMESTAMP | Fecha de última actualización | `updatedAt` | - |

### Validaciones Implementadas:

- **RN-001**: Email único con índice case-insensitive
- **RN-002**: password_hash solo almacena versión cifrada
- **RN-003**: token_confirmacion con token_expiracion (24h)
- **RN-004**: Estados controlados por ENUM user_estado
- **RN-005**: Estados validados en RLS policies
- **RN-006**: Campos NOT NULL para datos obligatorios
- **RN-007**: Rol nullable por defecto, asignado al aprobar

### SQL Final Implementado:

✅ **Migration aplicada**: `supabase/migrations/20251004145739_hu001_users_registration.sql`

La implementación incluye:
- ✅ ENUMs `user_role` y `user_estado`
- ✅ Tabla `users` con 11 campos
- ✅ 3 índices optimizados (email, estado, token)
- ✅ Índice único case-insensitive para email (RN-001)
- ✅ Function `update_updated_at_column()` y trigger
- ✅ RLS habilitado con 5 policies
- ✅ Tabla auxiliar `confirmation_resend_attempts` para control de límite 3 reenvíos/hora (RN-003)

**Archivo de migration**: Ver código completo en `C:\SystemWebMedias3.0\supabase\migrations\20251004145739_hu001_users_registration.sql`

### Cambios vs Diseño Inicial:

1. **Agregado**: Tabla `confirmation_resend_attempts` para implementar límite de 3 reenvíos/hora (RN-003)
   - Contiene: user_id, attempted_at, ip_address
   - Permite rastrear intentos y aplicar rate limiting

2. **Agregado**: Policy adicional `public_insert_users` para permitir registro sin autenticación

3. **Agregado**: Policy `users_update_own_profile` para que usuarios puedan actualizar su perfil (sin cambiar rol/estado)

4. **Agregado**: Comentarios SQL (COMMENT ON TABLE/COLUMN) para documentación inline

Todos los cambios mejoran la implementación sin afectar la funcionalidad especificada.
