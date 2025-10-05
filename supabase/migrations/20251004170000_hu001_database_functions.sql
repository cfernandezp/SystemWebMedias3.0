-- Migration: HU-001 - Database Functions para Auth
-- Fecha: 2025-10-04
-- Razón: Migrar Edge Functions a PostgreSQL RPC Functions
-- Ventajas: Mejor performance, no requiere Deno runtime, integración nativa con Supabase

BEGIN;

-- ============================================
-- PASO 1: Extensiones necesarias
-- ============================================

-- Habilitar pgcrypto para bcrypt y gen_random_uuid
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================
-- PASO 2: Helper Functions
-- ============================================

-- Función para hashear contraseñas con bcrypt (RN-002)
CREATE OR REPLACE FUNCTION hash_password(password TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN crypt(password, gen_salt('bf', 10));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar contraseñas
CREATE OR REPLACE FUNCTION verify_password(password TEXT, password_hash TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN password_hash = crypt(password, password_hash);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para generar token de confirmación (RN-003)
CREATE OR REPLACE FUNCTION generate_confirmation_token()
RETURNS TEXT AS $$
BEGIN
    RETURN encode(gen_random_bytes(32), 'hex');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PASO 3: Function - register_user()
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
    v_token_expiration TIMESTAMP WITH TIME ZONE;
    v_result JSON;
BEGIN
    -- PASO 1: Validar que el email no exista (RN-001)
    IF EXISTS (SELECT 1 FROM users WHERE LOWER(email) = LOWER(p_email)) THEN
        RAISE EXCEPTION 'DUPLICATE_EMAIL: Este email ya está registrado'
            USING HINT = 'duplicate_email';
    END IF;

    -- PASO 2: Validar formato de email
    IF p_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'VALIDATION_ERROR: Formato de email inválido'
            USING HINT = 'invalid_email';
    END IF;

    -- PASO 3: Validar contraseña (mínimo 8 caracteres - RN-006)
    IF LENGTH(p_password) < 8 THEN
        RAISE EXCEPTION 'VALIDATION_ERROR: La contraseña debe tener al menos 8 caracteres'
            USING HINT = 'invalid_password';
    END IF;

    -- PASO 4: Validar nombre completo
    IF LENGTH(TRIM(p_nombre_completo)) < 2 THEN
        RAISE EXCEPTION 'VALIDATION_ERROR: El nombre completo es requerido'
            USING HINT = 'invalid_name';
    END IF;

    -- PASO 5: Generar token de confirmación (RN-003)
    v_token := generate_confirmation_token();
    v_token_expiration := NOW() + INTERVAL '24 hours';

    -- PASO 6: Insertar usuario
    INSERT INTO users (
        email,
        password_hash,
        nombre_completo,
        estado,
        email_verificado,
        token_confirmacion,
        token_expiracion,
        rol
    ) VALUES (
        LOWER(p_email),
        hash_password(p_password),
        p_nombre_completo,
        'REGISTRADO',
        false,
        v_token,
        v_token_expiration,
        NULL
    )
    RETURNING id INTO v_user_id;

    -- PASO 7: Preparar respuesta JSON
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'id', v_user_id,
            'email', LOWER(p_email),
            'nombre_completo', p_nombre_completo,
            'estado', 'REGISTRADO',
            'email_verificado', false,
            'token_confirmacion', v_token,
            'token_expiracion', v_token_expiration,
            'message', 'Registro exitoso. Revisa tu email para confirmar tu cuenta'
        )
    ) INTO v_result;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        -- Capturar errores y retornar JSON
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', COALESCE(PG_EXCEPTION_HINT, 'unknown')
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 4: Function - confirm_email()
-- ============================================

CREATE OR REPLACE FUNCTION confirm_email(
    p_token TEXT
)
RETURNS JSON AS $$
DECLARE
    v_user RECORD;
    v_result JSON;
BEGIN
    -- PASO 1: Validar que el token no esté vacío
    IF p_token IS NULL OR LENGTH(TRIM(p_token)) = 0 THEN
        RAISE EXCEPTION 'VALIDATION_ERROR: Token es requerido'
            USING HINT = 'missing_token';
    END IF;

    -- PASO 2: Buscar usuario por token
    SELECT id, email, nombre_completo, estado, email_verificado, token_expiracion
    INTO v_user
    FROM users
    WHERE token_confirmacion = p_token;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'INVALID_TOKEN: Enlace de confirmación inválido o expirado'
            USING HINT = 'invalid_token';
    END IF;

    -- PASO 3: Verificar que el email no esté ya verificado
    IF v_user.email_verificado THEN
        RAISE EXCEPTION 'EMAIL_ALREADY_VERIFIED: Este email ya fue confirmado'
            USING HINT = 'already_verified';
    END IF;

    -- PASO 4: Verificar que el token no haya expirado
    IF v_user.token_expiracion < NOW() THEN
        RAISE EXCEPTION 'INVALID_TOKEN: El enlace de confirmación ha expirado. Solicita un nuevo enlace'
            USING HINT = 'expired_token';
    END IF;

    -- PASO 5: Actualizar usuario - marcar email como verificado y auto-aprobar (CP-001)
    UPDATE users
    SET
        email_verificado = true,
        estado = 'APROBADO',  -- CP-001: Auto-aprobar usuario tras verificar email
        token_confirmacion = NULL,
        token_expiracion = NULL
    WHERE id = v_user.id;

    -- PASO 6: Preparar respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Email confirmado exitosamente',
            'email_verificado', true,
            'estado', 'APROBADO',  -- CP-001: Ahora el usuario está aprobado automáticamente
            'next_step', 'Tu cuenta ha sido aprobada. Ya puedes iniciar sesión en el sistema.'
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
                'hint', COALESCE(PG_EXCEPTION_HINT, 'unknown')
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 5: Function - resend_confirmation()
-- ============================================

CREATE OR REPLACE FUNCTION resend_confirmation(
    p_email TEXT,
    p_ip_address TEXT DEFAULT 'unknown'
)
RETURNS JSON AS $$
DECLARE
    v_user RECORD;
    v_attempt_count INTEGER;
    v_new_token TEXT;
    v_new_expiration TIMESTAMP WITH TIME ZONE;
    v_oldest_attempt TIMESTAMP WITH TIME ZONE;
    v_retry_after TIMESTAMP WITH TIME ZONE;
    v_result JSON;
BEGIN
    -- PASO 1: Validar email
    IF p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 THEN
        RAISE EXCEPTION 'VALIDATION_ERROR: Email es requerido'
            USING HINT = 'missing_email';
    END IF;

    -- PASO 2: Buscar usuario por email (case-insensitive)
    SELECT id, email, nombre_completo, email_verificado
    INTO v_user
    FROM users
    WHERE LOWER(email) = LOWER(p_email);

    IF NOT FOUND THEN
        RAISE EXCEPTION 'USER_NOT_FOUND: No se encontró un usuario con ese email'
            USING HINT = 'user_not_found';
    END IF;

    -- PASO 3: Verificar que el email no esté ya verificado
    IF v_user.email_verificado THEN
        RAISE EXCEPTION 'EMAIL_ALREADY_VERIFIED: Este email ya fue confirmado'
            USING HINT = 'already_verified';
    END IF;

    -- PASO 4: Verificar límite de reenvíos (RN-003: máximo 3 por hora)
    SELECT COUNT(*) INTO v_attempt_count
    FROM confirmation_resend_attempts
    WHERE user_id = v_user.id
      AND attempted_at >= NOW() - INTERVAL '1 hour';

    IF v_attempt_count >= 3 THEN
        -- Calcular cuándo puede reintentar
        SELECT attempted_at INTO v_oldest_attempt
        FROM confirmation_resend_attempts
        WHERE user_id = v_user.id
          AND attempted_at >= NOW() - INTERVAL '1 hour'
        ORDER BY attempted_at ASC
        LIMIT 1;

        v_retry_after := v_oldest_attempt + INTERVAL '1 hour';

        RAISE EXCEPTION 'RATE_LIMIT_EXCEEDED: Máximo 3 reenvíos por hora. Intenta más tarde'
            USING HINT = 'rate_limit|' || v_retry_after::TEXT;
    END IF;

    -- PASO 5: Generar nuevo token
    v_new_token := generate_confirmation_token();
    v_new_expiration := NOW() + INTERVAL '24 hours';

    -- PASO 6: Actualizar usuario con nuevo token
    UPDATE users
    SET
        token_confirmacion = v_new_token,
        token_expiracion = v_new_expiration
    WHERE id = v_user.id;

    -- PASO 7: Registrar intento de reenvío
    INSERT INTO confirmation_resend_attempts (user_id, attempted_at, ip_address)
    VALUES (v_user.id, NOW(), p_ip_address);

    -- PASO 8: Preparar respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Email de confirmación reenviado exitosamente',
            'token_confirmacion', v_new_token,
            'token_expiracion', v_new_expiration
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
                'hint', COALESCE(PG_EXCEPTION_HINT, 'unknown')
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 6: Comentarios para documentación
-- ============================================

COMMENT ON FUNCTION register_user IS 'HU-001: Registra nuevo usuario con validaciones (RN-001, RN-002, RN-003, RN-006)';
COMMENT ON FUNCTION confirm_email IS 'HU-001: Confirma email de usuario con token (RN-003)';
COMMENT ON FUNCTION resend_confirmation IS 'HU-001: Reenvía email de confirmación con límite 3/hora (RN-003)';
COMMENT ON FUNCTION hash_password IS 'Helper: Hashea contraseña con bcrypt';
COMMENT ON FUNCTION verify_password IS 'Helper: Verifica contraseña contra hash';
COMMENT ON FUNCTION generate_confirmation_token IS 'Helper: Genera token hexadecimal de 64 caracteres';

COMMIT;
