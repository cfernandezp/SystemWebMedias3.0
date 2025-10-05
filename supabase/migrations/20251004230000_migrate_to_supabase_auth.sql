-- Migration: Migrar de tabla users custom a auth.users de Supabase
-- Fecha: 2025-10-04
-- Razón: Usar Supabase Auth nativo para que emails y tokens funcionen automáticamente con Inbucket

BEGIN;

-- ============================================
-- PASO 1: Eliminar todo lo relacionado con tabla users custom
-- ============================================

-- Eliminar triggers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS trigger_update_users_updated_at ON users;

-- Eliminar funciones de registro custom
DROP FUNCTION IF EXISTS register_user(TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS confirm_email(TEXT);
DROP FUNCTION IF EXISTS resend_confirmation(TEXT, TEXT);
DROP FUNCTION IF EXISTS send_confirmation_email(TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS generate_confirmation_token();
DROP FUNCTION IF EXISTS hash_password(TEXT);

-- Eliminar tabla de intentos de reenvío
DROP TABLE IF EXISTS confirmation_resend_attempts CASCADE;

-- Eliminar tabla users custom
DROP TABLE IF EXISTS users CASCADE;

-- Eliminar tipo ENUM estado_usuario
DROP TYPE IF EXISTS estado_usuario CASCADE;

-- ============================================
-- PASO 2: Configurar Supabase Auth para usar metadata
-- ============================================

-- Nota: Supabase Auth ya tiene la tabla auth.users
-- Vamos a usar raw_user_meta_data para guardar nombre_completo

-- Función helper para obtener nombre completo desde metadata
CREATE OR REPLACE FUNCTION get_user_nombre_completo()
RETURNS TEXT AS $$
BEGIN
    RETURN COALESCE(
        auth.jwt() ->> 'user_metadata' ->> 'nombre_completo',
        auth.jwt() ->> 'email'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 3: Vista para compatibilidad (opcional)
-- ============================================

-- Vista que simula la antigua tabla users para facilitar migración
CREATE OR REPLACE VIEW vista_users AS
SELECT
    id,
    email,
    raw_user_meta_data->>'nombre_completo' as nombre_completo,
    email_confirmed_at IS NOT NULL as email_verificado,
    CASE
        WHEN email_confirmed_at IS NOT NULL THEN 'ACTIVO'
        ELSE 'REGISTRADO'
    END as estado,
    created_at,
    updated_at
FROM auth.users;

-- ============================================
-- COMENTARIOS
-- ============================================

COMMENT ON FUNCTION get_user_nombre_completo IS 'HU-001: Obtiene nombre completo del usuario desde JWT metadata';
COMMENT ON VIEW vista_users IS 'HU-001: Vista de compatibilidad que simula tabla users antigua usando auth.users';

COMMIT;
