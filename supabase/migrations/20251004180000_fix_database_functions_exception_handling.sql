-- Migration: Fix Database Functions - Exception Handling
-- Fecha: 2025-10-04
-- Razón: Corregir uso de PG_EXCEPTION_HINT que no existe como columna
-- Fix: Usar variables locales para capturar HINT en el bloque EXCEPTION

BEGIN;

-- ============================================
-- PASO 1: Recrear register_user() con manejo correcto de excepciones
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
    v_error_hint TEXT;
BEGIN
    -- PASO 1: Validar que el email no exista (RN-001)
    IF EXISTS (SELECT 1 FROM users WHERE LOWER(email) = LOWER(p_email)) THEN
        v_error_hint := 'duplicate_email';
        RAISE EXCEPTION 'Este email ya está registrado';
    END IF;

    -- PASO 2: Validar formato de email
    IF p_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        v_error_hint := 'invalid_email';
        RAISE EXCEPTION 'Formato de email inválido';
    END IF;

    -- PASO 3: Validar contraseña (mínimo 8 caracteres - RN-006)
    IF LENGTH(p_password) < 8 THEN
        v_error_hint := 'invalid_password';
        RAISE EXCEPTION 'La contraseña debe tener al menos 8 caracteres';
    END IF;

    -- PASO 4: Validar nombre completo
    IF LENGTH(TRIM(p_nombre_completo)) < 2 THEN
        v_error_hint := 'invalid_name';
        RAISE EXCEPTION 'El nombre completo es requerido';
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
                'hint', COALESCE(v_error_hint, 'unknown')
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 2: Recrear confirm_email() con manejo correcto
-- ============================================

CREATE OR REPLACE FUNCTION confirm_email(
    p_token TEXT
)
RETURNS JSON AS $$
DECLARE
    v_user RECORD;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- PASO 1: Validar que el token no esté vacío
    IF p_token IS NULL OR LENGTH(TRIM(p_token)) = 0 THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    -- PASO 2: Buscar usuario por token
    SELECT id, email, nombre_completo, estado, email_verificado, token_expiracion
    INTO v_user
    FROM users
    WHERE token_confirmacion = p_token;

    IF NOT FOUND THEN
        v_error_hint := 'invalid_token';
        RAISE EXCEPTION 'Enlace de confirmación inválido o expirado';
    END IF;

    -- PASO 3: Verificar que el email no esté ya verificado
    IF v_user.email_verificado THEN
        v_error_hint := 'already_verified';
        RAISE EXCEPTION 'Este email ya fue confirmado';
    END IF;

    -- PASO 4: Verificar que el token no haya expirado
    IF v_user.token_expiracion < NOW() THEN
        v_error_hint := 'expired_token';
        RAISE EXCEPTION 'El enlace de confirmación ha expirado. Solicita un nuevo enlace';
    END IF;

    -- PASO 5: Actualizar usuario - marcar email como verificado
    UPDATE users
    SET
        email_verificado = true,
        token_confirmacion = NULL,
        token_expiracion = NULL
    WHERE id = v_user.id;

    -- PASO 6: Preparar respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Email confirmado exitosamente',
            'email_verificado', true,
            'estado', v_user.estado,
            'next_step', 'Tu cuenta está esperando aprobación del administrador. Recibirás un email cuando tu cuenta sea aprobada.'
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

-- ============================================
-- PASO 3: Recrear resend_confirmation() con manejo correcto
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
    v_error_hint TEXT;
BEGIN
    -- PASO 1: Validar email
    IF p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 THEN
        v_error_hint := 'missing_email';
        RAISE EXCEPTION 'Email es requerido';
    END IF;

    -- PASO 2: Buscar usuario por email (case-insensitive)
    SELECT id, email, nombre_completo, email_verificado
    INTO v_user
    FROM users
    WHERE LOWER(email) = LOWER(p_email);

    IF NOT FOUND THEN
        v_error_hint := 'user_not_found';
        RAISE EXCEPTION 'No se encontró un usuario con ese email';
    END IF;

    -- PASO 3: Verificar que el email no esté ya verificado
    IF v_user.email_verificado THEN
        v_error_hint := 'already_verified';
        RAISE EXCEPTION 'Este email ya fue confirmado';
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
        v_error_hint := 'rate_limit|' || v_retry_after::TEXT;
        RAISE EXCEPTION 'Máximo 3 reenvíos por hora. Intenta más tarde';
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
                'hint', COALESCE(v_error_hint, 'unknown')
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMIT;
