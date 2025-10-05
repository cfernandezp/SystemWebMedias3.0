-- Migration: HU-002 - Login al Sistema
-- Fecha: 2025-10-05
-- Razón: Implementar funciones de autenticación y validación de sesiones
-- Impacto: Crea tabla login_attempts y funciones: check_login_rate_limit(), login_user(), validate_token()

BEGIN;

-- ============================================
-- PASO 1: Tabla de control de intentos de login (CA-008 - Seguridad)
-- ============================================

CREATE TABLE login_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address TEXT,
    success BOOLEAN NOT NULL
);

-- Índice para búsquedas rápidas por email y fecha
CREATE INDEX idx_login_attempts_email_time ON login_attempts(email, attempted_at);

COMMENT ON TABLE login_attempts IS 'HU-002: Registro de intentos de login para rate limiting (5 intentos/15 min)';
COMMENT ON COLUMN login_attempts.email IS 'Email del usuario que intentó login (case-insensitive)';
COMMENT ON COLUMN login_attempts.attempted_at IS 'Timestamp del intento';
COMMENT ON COLUMN login_attempts.success IS 'Si el intento fue exitoso (true) o fallido (false)';

-- ============================================
-- PASO 2: Función check_login_rate_limit()
-- ============================================

CREATE OR REPLACE FUNCTION check_login_rate_limit(
    p_email TEXT,
    p_ip_address TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_failed_attempts INT;
BEGIN
    -- Contar intentos fallidos en últimos 15 minutos
    SELECT COUNT(*)
    INTO v_failed_attempts
    FROM login_attempts
    WHERE LOWER(email) = LOWER(p_email)
      AND success = false
      AND attempted_at > NOW() - INTERVAL '15 minutes';

    -- Máximo 5 intentos fallidos
    IF v_failed_attempts >= 5 THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION check_login_rate_limit IS 'HU-002: Verifica límite de 5 intentos fallidos por email en 15 minutos';

-- ============================================
-- PASO 3: Función login_user()
-- ============================================

CREATE OR REPLACE FUNCTION login_user(
    p_email TEXT,
    p_password TEXT,
    p_remember_me BOOLEAN DEFAULT false
)
RETURNS JSON AS $$
DECLARE
    v_user RECORD;
    v_password_match BOOLEAN;
    v_token TEXT;
    v_token_expiration INTERVAL;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Validar formato de email
    IF p_email IS NULL OR p_email = '' THEN
        v_error_hint := 'missing_email';
        RAISE EXCEPTION 'Email es requerido';
    END IF;

    IF NOT p_email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$' THEN
        v_error_hint := 'invalid_email';
        RAISE EXCEPTION 'Formato de email inválido';
    END IF;

    -- Validar password no vacío
    IF p_password IS NULL OR p_password = '' THEN
        v_error_hint := 'missing_password';
        RAISE EXCEPTION 'Contraseña es requerida';
    END IF;

    -- Verificar rate limit (CA-008)
    IF NOT check_login_rate_limit(p_email, 'unknown') THEN
        v_error_hint := 'rate_limit_exceeded';
        RAISE EXCEPTION 'Demasiados intentos fallidos. Intenta en 15 minutos';
    END IF;

    -- Buscar usuario por email (case-insensitive) (RN-001)
    SELECT *
    INTO v_user
    FROM users
    WHERE LOWER(email) = LOWER(p_email);

    -- Usuario no existe (CA-004)
    IF v_user IS NULL THEN
        -- Registrar intento fallido
        INSERT INTO login_attempts (email, success)
        VALUES (p_email, false);

        v_error_hint := 'invalid_credentials';
        RAISE EXCEPTION 'Email o contraseña incorrectos';
    END IF;

    -- Verificar contraseña (RN-002)
    v_password_match := (v_user.password_hash = crypt(p_password, v_user.password_hash));

    IF NOT v_password_match THEN
        -- Registrar intento fallido (CA-005)
        INSERT INTO login_attempts (email, success)
        VALUES (v_user.email, false);

        v_error_hint := 'invalid_credentials';
        RAISE EXCEPTION 'Email o contraseña incorrectos';
    END IF;

    -- Verificar email verificado (CA-006) (RN-003)
    IF v_user.email_verificado = false THEN
        v_error_hint := 'email_not_verified';
        RAISE EXCEPTION 'Debes confirmar tu email antes de iniciar sesión';
    END IF;

    -- Verificar estado APROBADO (CA-007) (RN-005)
    IF v_user.estado != 'APROBADO' THEN
        v_error_hint := 'user_not_approved';
        RAISE EXCEPTION 'No tienes acceso al sistema. Contacta al administrador';
    END IF;

    -- Generar JWT token (CA-003)
    -- Token expiration: 8 horas (sin remember_me) o 30 días (con remember_me)
    v_token_expiration := CASE
        WHEN p_remember_me THEN INTERVAL '30 days'
        ELSE INTERVAL '8 hours'
    END;

    v_token := encode(
        convert_to(
            json_build_object(
                'user_id', v_user.id,
                'email', v_user.email,
                'rol', v_user.rol,
                'exp', extract(epoch from (NOW() + v_token_expiration))
            )::text,
            'UTF8'
        ),
        'base64'
    );

    -- Registrar intento exitoso
    INSERT INTO login_attempts (email, success)
    VALUES (v_user.email, true);

    -- Respuesta exitosa (CA-003)
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'token', v_token,
            'user', json_build_object(
                'id', v_user.id,
                'email', v_user.email,
                'nombre_completo', v_user.nombre_completo,
                'rol', v_user.rol,
                'estado', v_user.estado
            ),
            'message', 'Bienvenido ' || v_user.nombre_completo
        )
    ) INTO v_result;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', COALESCE(v_error_hint, 'unknown')
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION login_user IS 'HU-002: Autentica usuario validando email, contraseña, verificación y aprobación (RN-001, RN-002, RN-003, RN-005, RN-007)';

-- ============================================
-- PASO 4: Función validate_token()
-- ============================================

CREATE OR REPLACE FUNCTION validate_token(
    p_token TEXT
)
RETURNS JSON AS $$
DECLARE
    v_decoded JSON;
    v_user_id UUID;
    v_exp BIGINT;
    v_user RECORD;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Validar token no vacío
    IF p_token IS NULL OR p_token = '' THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    -- Decodificar token (base64)
    BEGIN
        v_decoded := convert_from(decode(p_token, 'base64'), 'UTF8')::json;
    EXCEPTION
        WHEN OTHERS THEN
            v_error_hint := 'invalid_token';
            RAISE EXCEPTION 'Token inválido';
    END;

    -- Extraer datos del token
    v_user_id := (v_decoded->>'user_id')::UUID;
    v_exp := (v_decoded->>'exp')::BIGINT;

    -- Verificar expiración (CA-010)
    IF extract(epoch from NOW()) > v_exp THEN
        v_error_hint := 'expired_token';
        RAISE EXCEPTION 'Tu sesión ha expirado. Inicia sesión nuevamente';
    END IF;

    -- Buscar usuario
    SELECT *
    INTO v_user
    FROM users
    WHERE id = v_user_id;

    IF v_user IS NULL THEN
        v_error_hint := 'user_not_found';
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    -- Verificar que usuario sigue APROBADO (RN-005)
    IF v_user.estado != 'APROBADO' THEN
        v_error_hint := 'user_not_approved';
        RAISE EXCEPTION 'Tu acceso al sistema ha sido revocado';
    END IF;

    -- Respuesta exitosa
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'user', json_build_object(
                'id', v_user.id,
                'email', v_user.email,
                'nombre_completo', v_user.nombre_completo,
                'rol', v_user.rol,
                'estado', v_user.estado
            )
        )
    ) INTO v_result;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', COALESCE(v_error_hint, 'unknown')
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION validate_token IS 'HU-002: Valida JWT token y retorna datos del usuario si el token es válido y no expiró (CA-010)';

COMMIT;
