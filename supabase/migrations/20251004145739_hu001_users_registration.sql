-- Migration: HU-001 - Registro de Alta al Sistema
-- Fecha: 2025-10-04
-- Razón: Crear infraestructura completa para registro y autenticación de usuarios
-- Impacto: Crea tabla users, ENUMs, índices, triggers y RLS policies

BEGIN;

-- ============================================
-- PASO 1: Crear ENUMs
-- ============================================

-- ENUM para roles de usuario (RN-007)
CREATE TYPE user_role AS ENUM ('ADMIN', 'GERENTE', 'VENDEDOR');

-- ENUM para estados de usuario (RN-004, RN-005)
CREATE TYPE user_estado AS ENUM ('REGISTRADO', 'APROBADO', 'RECHAZADO', 'SUSPENDIDO');

-- ============================================
-- PASO 2: Crear tabla users
-- ============================================

CREATE TABLE users (
    -- Identificador único
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Credenciales (RN-001, RN-002, RN-006)
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    nombre_completo TEXT NOT NULL,

    -- Permisos y estado (RN-004, RN-005, RN-007)
    rol user_role,  -- Nullable, asignado al aprobar
    estado user_estado NOT NULL DEFAULT 'REGISTRADO',

    -- Verificación de email (RN-003)
    email_verificado BOOLEAN NOT NULL DEFAULT false,
    token_confirmacion TEXT,
    token_expiracion TIMESTAMP WITH TIME ZONE,

    -- Auditoría
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- PASO 3: Crear índices para performance
-- ============================================

-- Índice case-insensitive para búsquedas de email (RN-001)
CREATE INDEX idx_users_email ON users(LOWER(email));

-- Constraint de unicidad case-insensitive (RN-001)
CREATE UNIQUE INDEX idx_users_email_unique ON users(LOWER(email));

-- Índice para filtrar por estado (usado en administración)
CREATE INDEX idx_users_estado ON users(estado);

-- Índice para búsqueda rápida de tokens (RN-003)
CREATE INDEX idx_users_token_confirmacion ON users(token_confirmacion)
    WHERE token_confirmacion IS NOT NULL;

-- ============================================
-- PASO 4: Function y Trigger para updated_at
-- ============================================

-- Function para auto-actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que ejecuta la función antes de cada UPDATE
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- PASO 5: Habilitar Row Level Security (RLS)
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PASO 6: Crear RLS Policies
-- ============================================

-- Policy 1: ADMIN puede ver todos los usuarios
CREATE POLICY "admin_view_all_users"
    ON users
    FOR SELECT
    USING (
        auth.jwt() ->> 'rol' = 'ADMIN'
    );

-- Policy 2: Usuarios pueden ver su propio perfil
CREATE POLICY "users_view_own_profile"
    ON users
    FOR SELECT
    USING (
        auth.uid() = id
    );

-- Policy 3: Solo ADMIN puede actualizar usuarios (estado, rol)
CREATE POLICY "admin_update_users"
    ON users
    FOR UPDATE
    USING (
        auth.jwt() ->> 'rol' = 'ADMIN'
    );

-- Policy 4: Permitir INSERT para registro público (sin autenticación)
-- Esto es necesario para el endpoint de registro
CREATE POLICY "public_insert_users"
    ON users
    FOR INSERT
    WITH CHECK (true);

-- Policy 5: Usuarios pueden actualizar su propio perfil (nombre, email)
CREATE POLICY "users_update_own_profile"
    ON users
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (
        -- No pueden cambiar rol ni estado
        auth.uid() = id AND
        rol = (SELECT rol FROM users WHERE id = auth.uid()) AND
        estado = (SELECT estado FROM users WHERE id = auth.uid())
    );

-- ============================================
-- PASO 7: Tabla auxiliar para control de reenvíos (RN-003)
-- ============================================

-- Tabla para rastrear intentos de reenvío de confirmación (límite 3/hora)
CREATE TABLE confirmation_resend_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address TEXT
);

-- Índice para búsquedas rápidas por usuario y fecha
CREATE INDEX idx_resend_attempts_user_time
    ON confirmation_resend_attempts(user_id, attempted_at DESC);

-- ============================================
-- PASO 8: Comentarios para documentación
-- ============================================

COMMENT ON TABLE users IS 'HU-001: Usuarios del sistema con autenticación y roles';
COMMENT ON COLUMN users.email IS 'Email único (case-insensitive) - RN-001';
COMMENT ON COLUMN users.password_hash IS 'Hash bcrypt de la contraseña - RN-002';
COMMENT ON COLUMN users.nombre_completo IS 'Nombre completo del usuario - RN-006';
COMMENT ON COLUMN users.rol IS 'Rol asignado al aprobar (nullable) - RN-007';
COMMENT ON COLUMN users.estado IS 'Estado del usuario: REGISTRADO, APROBADO, RECHAZADO, SUSPENDIDO - RN-004';
COMMENT ON COLUMN users.email_verificado IS 'Indica si el email fue confirmado - RN-003';
COMMENT ON COLUMN users.token_confirmacion IS 'Token UUID para confirmar email (24h validez) - RN-003';
COMMENT ON COLUMN users.token_expiracion IS 'Fecha de expiración del token - RN-003';

COMMENT ON TABLE confirmation_resend_attempts IS 'Control de intentos de reenvío de confirmación (límite 3/hora) - RN-003';

COMMIT;
