-- ============================================
-- Migration: 00000000000002_auth_tables.sql
-- Descripción: Tablas de autenticación, auditoría y seguridad
-- Fecha: 2025-10-07 (Consolidado)
-- Contexto: Usa auth.users de Supabase Auth como tabla principal
-- ============================================

BEGIN;

-- ============================================
-- PASO 1: Tabla auxiliar login_attempts
-- ============================================
-- HU-002: Control de rate limiting en login (5 intentos/15 min)

CREATE TABLE login_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address TEXT,
    success BOOLEAN NOT NULL
);

CREATE INDEX idx_login_attempts_email_time ON login_attempts(email, attempted_at);

COMMENT ON TABLE login_attempts IS 'HU-002: Registro de intentos de login para rate limiting (5 intentos/15 min)';
COMMENT ON COLUMN login_attempts.email IS 'Email del usuario que intentó login (case-insensitive)';
COMMENT ON COLUMN login_attempts.success IS 'Si el intento fue exitoso (true) o fallido (false)';

-- ============================================
-- PASO 2: Tabla token_blacklist
-- ============================================
-- HU-003: Tokens JWT invalidados por logout seguro

CREATE TABLE token_blacklist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token TEXT NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    blacklisted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    reason TEXT CHECK (reason IN ('manual_logout', 'inactivity', 'token_expired'))
);

CREATE INDEX idx_token_blacklist_token ON token_blacklist(token);
CREATE INDEX idx_token_blacklist_expires_at ON token_blacklist(expires_at);
CREATE INDEX idx_token_blacklist_user_id ON token_blacklist(user_id);

COMMENT ON TABLE token_blacklist IS 'HU-003: Tokens JWT invalidados por logout - RN-003-LOGOUT.3';
COMMENT ON COLUMN token_blacklist.reason IS 'Motivo: manual_logout, inactivity, token_expired';

-- ============================================
-- PASO 3: Tabla audit_logs
-- ============================================
-- HU-003: Auditoría de eventos de seguridad

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL CHECK (event_type IN (
        'login', 'logout', 'password_change', 'password_reset', 'email_change',
        'material_management', 'marca_management',
        'tipo_created', 'tipo_updated', 'tipo_activated', 'tipo_deactivated',
        'sistema_talla_created', 'sistema_talla_updated', 'sistema_talla_activated', 'sistema_talla_deactivated',
        'valor_talla_added', 'valor_talla_updated', 'valor_talla_deleted',
        'color_created', 'color_updated', 'color_deactivated', 'color_deleted'
    )),
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
COMMENT ON COLUMN audit_logs.metadata IS 'Información adicional del evento (session_duration, etc.)';

-- ============================================
-- PASO 4: Tabla user_sessions
-- ============================================
-- HU-003: Tracking de actividad para detección de inactividad

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_sessions_last_activity_at ON user_sessions(last_activity_at);
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);

COMMENT ON TABLE user_sessions IS 'HU-003: Tracking de actividad del usuario - RN-003-LOGOUT.5';

-- ============================================
-- PASO 5: Tabla password_recovery
-- ============================================
-- HU-004: Tokens de recuperación de contraseña

CREATE TABLE password_recovery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    token TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_password_recovery_token ON password_recovery(token);
CREATE INDEX idx_password_recovery_user_id ON password_recovery(user_id);
CREATE INDEX idx_password_recovery_email ON password_recovery(email);
CREATE INDEX idx_password_recovery_expires_at ON password_recovery(expires_at);

COMMENT ON TABLE password_recovery IS 'HU-004: Tokens de recuperación de contraseña - RN-004-PASSWORD';
COMMENT ON COLUMN password_recovery.token IS 'Token seguro URL-safe de 32 bytes';
COMMENT ON COLUMN password_recovery.expires_at IS 'Expiración: 24 horas desde creación';

-- ============================================
-- PASO 6: Habilitar RLS en tablas de auth
-- ============================================

ALTER TABLE login_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE token_blacklist ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE password_recovery ENABLE ROW LEVEL SECURITY;

-- Policies básicas (solo ADMIN puede ver todo)
CREATE POLICY admin_view_all_audit ON audit_logs
    FOR SELECT
    USING ((SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'ADMIN');

CREATE POLICY users_view_own_audit ON audit_logs
    FOR SELECT
    USING (user_id = auth.uid());

COMMIT;

-- ============================================
-- RESUMEN
-- ============================================
-- Tablas creadas:
--   - login_attempts (rate limiting)
--   - token_blacklist (logout seguro)
--   - audit_logs (auditoría de seguridad)
--   - user_sessions (tracking actividad)
--   - password_recovery (recuperación contraseña)
-- ============================================