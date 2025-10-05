-- Migration: HU-002 FIX - Adaptar funciones de login para usar Supabase Auth
-- Fecha: 2025-10-05
-- Razón: Las funciones login_user() y validate_token() referencian tabla users que fue migrada a auth.users
-- Impacto: Reescribe funciones para usar auth.users y Supabase Auth nativo

BEGIN;

-- ============================================
-- PASO 1: Eliminar funciones rotas
-- ============================================

DROP FUNCTION IF EXISTS login_user(TEXT, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS validate_token(TEXT);

-- ============================================
-- PASO 2: Función login_user() adaptada para auth.users
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
    v_nombre_completo TEXT;
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

    -- Buscar usuario por email en auth.users (case-insensitive) (RN-001)
    SELECT *
    INTO v_user
    FROM auth.users
    WHERE LOWER(email) = LOWER(p_email);

    -- Usuario no existe (CA-004)
    IF v_user IS NULL THEN
        -- Registrar intento fallido
        INSERT INTO login_attempts (email, success)
        VALUES (p_email, false);

        v_error_hint := 'invalid_credentials';
        RAISE EXCEPTION 'Email o contraseña incorrectos';
    END IF;

    -- Verificar contraseña con Supabase Auth (RN-002)
    -- Supabase Auth almacena el hash en encrypted_password
    v_password_match := (v_user.encrypted_password = crypt(p_password, v_user.encrypted_password));

    IF NOT v_password_match THEN
        -- Registrar intento fallido (CA-005)
        INSERT INTO login_attempts (email, success)
        VALUES (v_user.email, false);

        v_error_hint := 'invalid_credentials';
        RAISE EXCEPTION 'Email o contraseña incorrectos';
    END IF;

    -- Verificar email verificado (CA-006) (RN-003)
    -- En Supabase Auth, email_confirmed_at NULL = no verificado
    IF v_user.email_confirmed_at IS NULL THEN
        v_error_hint := 'email_not_verified';
        RAISE EXCEPTION 'Debes confirmar tu email antes de iniciar sesión';
    END IF;

    -- Extraer nombre completo de metadata
    v_nombre_completo := COALESCE(
        v_user.raw_user_meta_data->>'nombre_completo',
        v_user.email
    );

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
                'nombre_completo', v_nombre_completo,
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
                'nombre_completo', v_nombre_completo,
                'email_verificado', v_user.email_confirmed_at IS NOT NULL
            ),
            'message', 'Bienvenido ' || v_nombre_completo
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

COMMENT ON FUNCTION login_user IS 'HU-002: Autentica usuario usando auth.users, validando email y contraseña (RN-001, RN-002, RN-003)';

-- ============================================
-- PASO 3: Función validate_token() adaptada
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
    v_nombre_completo TEXT;
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

    -- Buscar usuario en auth.users
    SELECT *
    INTO v_user
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user IS NULL THEN
        v_error_hint := 'user_not_found';
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    -- Extraer nombre completo de metadata
    v_nombre_completo := COALESCE(
        v_user.raw_user_meta_data->>'nombre_completo',
        v_user.email
    );

    -- Respuesta exitosa
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'user', json_build_object(
                'id', v_user.id,
                'email', v_user.email,
                'nombre_completo', v_nombre_completo,
                'email_verificado', v_user.email_confirmed_at IS NOT NULL
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

COMMENT ON FUNCTION validate_token IS 'HU-002: Valida JWT token usando auth.users (CA-010)';

COMMIT;
