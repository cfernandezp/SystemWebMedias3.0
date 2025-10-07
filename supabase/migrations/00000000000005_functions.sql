-- ============================================
-- Migration: 00000000000005_functions.sql
-- Descripción: TODAS las funciones RPC del sistema
-- Fecha: 2025-10-07 (Consolidado)
-- ============================================

BEGIN;

-- ============================================
-- SECCIÓN 1: FUNCIONES DE AUTENTICACIÓN (HU-001, HU-002)
-- ============================================

-- HU-001: register_user - Registra nuevo usuario en auth.users
CREATE OR REPLACE FUNCTION register_user(
    p_email TEXT,
    p_password TEXT,
    p_nombre_completo TEXT
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Validar formato de email
    IF p_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        v_error_hint := 'invalid_email';
        RAISE EXCEPTION 'Formato de email inválido';
    END IF;

    -- Validar contraseña (mínimo 8 caracteres)
    IF LENGTH(p_password) < 8 THEN
        v_error_hint := 'invalid_password';
        RAISE EXCEPTION 'La contraseña debe tener al menos 8 caracteres';
    END IF;

    -- Validar nombre completo
    IF LENGTH(TRIM(p_nombre_completo)) < 2 THEN
        v_error_hint := 'invalid_name';
        RAISE EXCEPTION 'El nombre completo es requerido';
    END IF;

    -- Verificar que el email no exista
    IF EXISTS (SELECT 1 FROM auth.users WHERE LOWER(email) = LOWER(p_email)) THEN
        v_error_hint := 'duplicate_email';
        RAISE EXCEPTION 'Este email ya está registrado';
    END IF;

    -- Insertar usuario en auth.users
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        LOWER(p_email),
        crypt(p_password, gen_salt('bf')),
        NULL,
        json_build_object('nombre_completo', p_nombre_completo),
        NOW(),
        NOW(),
        encode(gen_random_bytes(32), 'hex')
    )
    RETURNING id INTO v_user_id;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', v_user_id,
            'email', LOWER(p_email),
            'nombre_completo', p_nombre_completo,
            'email_verificado', false,
            'message', 'Registro exitoso. Revisa tu email para confirmar tu cuenta'
        )
    );

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

COMMENT ON FUNCTION register_user IS 'HU-001: Registra usuario en auth.users de Supabase Auth';

-- HU-001: confirm_email - Confirma email del usuario
CREATE OR REPLACE FUNCTION confirm_email(
    p_token TEXT
)
RETURNS JSON AS $$
DECLARE
    v_user RECORD;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Validar token no vacío
    IF p_token IS NULL OR LENGTH(TRIM(p_token)) = 0 THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    -- Buscar usuario por token de confirmación
    SELECT id, email, raw_user_meta_data, email_confirmed_at
    INTO v_user
    FROM auth.users
    WHERE confirmation_token = p_token;

    IF NOT FOUND THEN
        v_error_hint := 'invalid_token';
        RAISE EXCEPTION 'Enlace de confirmación inválido o expirado';
    END IF;

    -- Verificar que el email no esté ya confirmado
    IF v_user.email_confirmed_at IS NOT NULL THEN
        v_error_hint := 'already_verified';
        RAISE EXCEPTION 'Este email ya fue confirmado';
    END IF;

    -- Actualizar usuario - marcar email como confirmado
    UPDATE auth.users
    SET
        email_confirmed_at = NOW(),
        confirmed_at = NOW(),
        confirmation_token = NULL
    WHERE id = v_user.id;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Email confirmado exitosamente',
            'email_verificado', true,
            'next_step', 'Ya puedes iniciar sesión en el sistema.'
        )
    );

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

COMMENT ON FUNCTION confirm_email IS 'HU-001: Confirma email del usuario en auth.users';

-- HU-001: dev_confirm_email - Helper temporal para desarrollo
CREATE OR REPLACE FUNCTION dev_confirm_email(p_email TEXT)
RETURNS JSON AS $$
BEGIN
    UPDATE auth.users
    SET email_confirmed_at = NOW()
    WHERE LOWER(email) = LOWER(p_email);

    RETURN json_build_object('success', true, 'message', 'Email confirmado');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION dev_confirm_email IS 'DEV HELPER: Confirma email sin token (solo desarrollo)';

-- HU-002: check_login_rate_limit - Verifica límite de intentos de login
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

-- HU-002: login_user - Autentica usuario
CREATE OR REPLACE FUNCTION login_user(
    p_email TEXT,
    p_password TEXT,
    p_remember_me BOOLEAN DEFAULT false
)
RETURNS JSON AS $$
DECLARE
    v_user RECORD;
    v_password_match BOOLEAN;
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

    -- Verificar rate limit
    IF NOT check_login_rate_limit(p_email, 'unknown') THEN
        v_error_hint := 'rate_limit_exceeded';
        RAISE EXCEPTION 'Demasiados intentos fallidos. Intenta en 15 minutos';
    END IF;

    -- Buscar usuario por email en auth.users (case-insensitive)
    SELECT *
    INTO v_user
    FROM auth.users
    WHERE LOWER(email) = LOWER(p_email);

    -- Usuario no existe
    IF v_user IS NULL THEN
        INSERT INTO login_attempts (email, success) VALUES (p_email, false);
        v_error_hint := 'invalid_credentials';
        RAISE EXCEPTION 'Email o contraseña incorrectos';
    END IF;

    -- Verificar contraseña con bcrypt
    v_password_match := (v_user.encrypted_password = crypt(p_password, v_user.encrypted_password));

    IF NOT v_password_match THEN
        INSERT INTO login_attempts (email, success) VALUES (v_user.email, false);
        v_error_hint := 'invalid_credentials';
        RAISE EXCEPTION 'Email o contraseña incorrectos';
    END IF;

    -- Verificar email verificado
    IF v_user.email_confirmed_at IS NULL THEN
        v_error_hint := 'email_not_verified';
        RAISE EXCEPTION 'Debes confirmar tu email antes de iniciar sesión';
    END IF;

    -- Extraer nombre completo de metadata
    v_nombre_completo := COALESCE(
        v_user.raw_user_meta_data->>'nombre_completo',
        v_user.email
    );

    -- Registrar intento exitoso
    INSERT INTO login_attempts (email, success) VALUES (v_user.email, true);

    -- Crear session token (simple, no usa JWT real de Supabase Auth)
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
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

COMMENT ON FUNCTION login_user IS 'HU-002: Autentica usuario usando auth.users de Supabase Auth';

-- HU-002: validate_token - Valida JWT token
CREATE OR REPLACE FUNCTION validate_token(
    p_token TEXT
)
RETURNS JSON AS $$
DECLARE
    v_decoded JSON;
    v_user_id UUID;
    v_exp NUMERIC;
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
    v_exp := (v_decoded->>'exp')::NUMERIC;

    -- Verificar expiración
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

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'user', json_build_object(
                'id', v_user.id,
                'email', v_user.email,
                'nombre_completo', v_nombre_completo,
                'email_verificado', v_user.email_confirmed_at IS NOT NULL
            )
        )
    );

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

COMMENT ON FUNCTION validate_token IS 'HU-002: Valida JWT token usando auth.users';

-- ============================================
-- SECCIÓN 2: FUNCIONES DE LOGOUT (HU-003)
-- ============================================

-- HU-003: logout_user - Invalida token y registra logout
CREATE OR REPLACE FUNCTION logout_user(
    p_token TEXT,
    p_user_id UUID,
    p_logout_type TEXT DEFAULT 'manual',
    p_ip_address INET DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL,
    p_session_duration INT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_token_expires_at TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Validaciones
    IF p_token IS NULL OR p_token = '' THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    IF p_logout_type NOT IN ('manual', 'inactivity', 'token_expired') THEN
        v_error_hint := 'invalid_logout_type';
        RAISE EXCEPTION 'Tipo de logout inválido';
    END IF;

    -- Verificar que token no esté ya en blacklist
    IF EXISTS (SELECT 1 FROM token_blacklist WHERE token = p_token) THEN
        v_error_hint := 'already_blacklisted';
        RAISE EXCEPTION 'Token ya invalidado';
    END IF;

    v_token_expires_at := NOW() + INTERVAL '8 hours';

    -- 1. Agregar token a blacklist
    INSERT INTO token_blacklist (token, user_id, expires_at, reason)
    VALUES (p_token, p_user_id, v_token_expires_at, p_logout_type);

    -- 2. Registrar en audit_logs
    INSERT INTO audit_logs (
        user_id,
        event_type,
        event_subtype,
        ip_address,
        user_agent,
        metadata
    ) VALUES (
        p_user_id,
        'logout',
        p_logout_type,
        p_ip_address,
        p_user_agent,
        json_build_object(
            'session_duration', p_session_duration,
            'logout_type', p_logout_type
        )::jsonb
    );

    -- 3. Actualizar last_activity_at en user_sessions
    INSERT INTO user_sessions (user_id, last_activity_at)
    VALUES (p_user_id, NOW())
    ON CONFLICT (user_id)
    DO UPDATE SET last_activity_at = NOW(), updated_at = NOW();

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'message', CASE
                WHEN p_logout_type = 'manual' THEN 'Sesión cerrada exitosamente'
                WHEN p_logout_type = 'inactivity' THEN 'Sesión cerrada por inactividad'
                WHEN p_logout_type = 'token_expired' THEN 'Tu sesión ha expirado'
            END,
            'logout_type', p_logout_type,
            'blacklisted_at', NOW()
        )
    );

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

COMMENT ON FUNCTION logout_user IS 'HU-003: Invalida token JWT y registra logout';

-- HU-003: check_token_blacklist - Verifica si token está invalidado
CREATE OR REPLACE FUNCTION check_token_blacklist(
    p_token TEXT
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_is_blacklisted BOOLEAN;
    v_reason TEXT;
BEGIN
    IF p_token IS NULL OR p_token = '' THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM token_blacklist
        WHERE token = p_token
          AND expires_at > NOW()
    ) INTO v_is_blacklisted;

    IF v_is_blacklisted THEN
        SELECT reason INTO v_reason
        FROM token_blacklist
        WHERE token = p_token
        LIMIT 1;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'is_blacklisted', v_is_blacklisted,
            'reason', v_reason,
            'message', CASE
                WHEN v_is_blacklisted THEN 'Token inválido. Debes iniciar sesión nuevamente'
                ELSE 'Token válido'
            END
        )
    );

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

COMMENT ON FUNCTION check_token_blacklist IS 'HU-003: Verifica si token está invalidado';

-- HU-003: update_user_activity - Actualiza última actividad
CREATE OR REPLACE FUNCTION update_user_activity(
    p_user_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    IF p_user_id IS NULL THEN
        v_error_hint := 'missing_user_id';
        RAISE EXCEPTION 'User ID es requerido';
    END IF;

    INSERT INTO user_sessions (user_id, last_activity_at)
    VALUES (p_user_id, NOW())
    ON CONFLICT (user_id)
    DO UPDATE SET last_activity_at = NOW(), updated_at = NOW();

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'last_activity_at', NOW(),
            'message', 'Actividad actualizada'
        )
    );

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

COMMENT ON FUNCTION update_user_activity IS 'HU-003: Actualiza última actividad del usuario';

-- HU-003: cleanup_expired_blacklist - Limpia tokens expirados
CREATE OR REPLACE FUNCTION cleanup_expired_blacklist()
RETURNS JSON AS $$
DECLARE
    v_deleted_count INT;
BEGIN
    DELETE FROM token_blacklist
    WHERE expires_at < NOW();

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'deleted_count', v_deleted_count,
            'message', v_deleted_count || ' tokens expirados eliminados'
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION cleanup_expired_blacklist IS 'HU-003: Limpia tokens expirados de blacklist';

-- ============================================
-- SECCIÓN 3: FUNCIONES PASSWORD RECOVERY (HU-004)
-- ============================================

-- HU-004: request_password_reset - Solicita recuperación de contraseña
CREATE OR REPLACE FUNCTION request_password_reset(
    p_email TEXT,
    p_ip_address INET DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_token TEXT;
    v_expires_at TIMESTAMP WITH TIME ZONE;
    v_last_request TIMESTAMP WITH TIME ZONE;
    v_request_count INTEGER;
    v_error_hint TEXT;
BEGIN
    -- Validar formato email
    IF p_email IS NULL OR p_email = '' THEN
        v_error_hint := 'missing_email';
        RAISE EXCEPTION 'Email es requerido';
    END IF;

    IF p_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        v_error_hint := 'invalid_email';
        RAISE EXCEPTION 'Formato de email inválido';
    END IF;

    -- Buscar usuario
    SELECT id INTO v_user_id
    FROM auth.users
    WHERE LOWER(email) = LOWER(p_email)
      AND email_confirmed_at IS NOT NULL;

    -- Si no existe, retornar mensaje genérico (privacidad)
    IF v_user_id IS NULL THEN
        RETURN json_build_object(
            'success', true,
            'data', json_build_object(
                'message', 'Si el email existe, se enviará un enlace de recuperación',
                'email_sent', false
            )
        );
    END IF;

    -- Verificar rate limiting (máximo 3 solicitudes en 15 minutos)
    SELECT created_at INTO v_last_request
    FROM password_recovery
    WHERE user_id = v_user_id
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_last_request IS NOT NULL AND
       NOW() - v_last_request < INTERVAL '15 minutes' THEN
        SELECT COUNT(*) INTO v_request_count
        FROM password_recovery
        WHERE user_id = v_user_id
          AND created_at > NOW() - INTERVAL '15 minutes';

        IF v_request_count >= 3 THEN
            v_error_hint := 'rate_limit';
            RAISE EXCEPTION 'Ya se enviaron varios enlaces recientemente. Espera 15 minutos';
        END IF;
    END IF;

    -- Invalidar tokens previos del usuario
    UPDATE password_recovery
    SET used_at = NOW()
    WHERE user_id = v_user_id
      AND used_at IS NULL
      AND expires_at > NOW();

    -- Generar token seguro (32 bytes, URL-safe)
    v_token := encode(gen_random_bytes(32), 'base64');
    v_token := replace(replace(replace(v_token, '+', '-'), '/', '_'), '=', '');
    v_expires_at := NOW() + INTERVAL '24 hours';

    -- Insertar nuevo token
    INSERT INTO password_recovery (user_id, email, token, expires_at, ip_address)
    VALUES (v_user_id, p_email, v_token, v_expires_at, p_ip_address);

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Si el email existe, se enviará un enlace de recuperación',
            'email_sent', true,
            'token', v_token,
            'expires_at', v_expires_at
        )
    );

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

COMMENT ON FUNCTION request_password_reset IS 'HU-004: Solicita recuperación de contraseña';

-- HU-004: validate_reset_token - Valida token de recuperación
CREATE OR REPLACE FUNCTION validate_reset_token(
    p_token TEXT
)
RETURNS JSON AS $$
DECLARE
    v_recovery RECORD;
    v_error_hint TEXT;
BEGIN
    IF p_token IS NULL OR p_token = '' THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    SELECT * INTO v_recovery
    FROM password_recovery
    WHERE token = p_token;

    IF NOT FOUND THEN
        v_error_hint := 'invalid_token';
        RAISE EXCEPTION 'Enlace de recuperación inválido';
    END IF;

    IF v_recovery.expires_at < NOW() THEN
        v_error_hint := 'expired_token';
        RAISE EXCEPTION 'Enlace de recuperación expirado';
    END IF;

    IF v_recovery.used_at IS NOT NULL THEN
        v_error_hint := 'used_token';
        RAISE EXCEPTION 'Enlace ya utilizado';
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'is_valid', true,
            'user_id', v_recovery.user_id,
            'email', v_recovery.email,
            'expires_at', v_recovery.expires_at
        )
    );

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

COMMENT ON FUNCTION validate_reset_token IS 'HU-004: Valida token de recuperación';

-- HU-004: reset_password - Cambia contraseña con token
CREATE OR REPLACE FUNCTION reset_password(
    p_token TEXT,
    p_new_password TEXT,
    p_ip_address INET DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_recovery RECORD;
    v_error_hint TEXT;
BEGIN
    IF p_token IS NULL OR p_token = '' THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    IF p_new_password IS NULL OR p_new_password = '' THEN
        v_error_hint := 'missing_password';
        RAISE EXCEPTION 'Contraseña es requerida';
    END IF;

    IF LENGTH(p_new_password) < 8 THEN
        v_error_hint := 'weak_password';
        RAISE EXCEPTION 'La contraseña debe tener al menos 8 caracteres';
    END IF;

    SELECT * INTO v_recovery
    FROM password_recovery
    WHERE token = p_token;

    IF NOT FOUND THEN
        v_error_hint := 'invalid_token';
        RAISE EXCEPTION 'Enlace de recuperación inválido';
    END IF;

    IF v_recovery.expires_at < NOW() THEN
        v_error_hint := 'expired_token';
        RAISE EXCEPTION 'Enlace de recuperación expirado';
    END IF;

    IF v_recovery.used_at IS NOT NULL THEN
        v_error_hint := 'used_token';
        RAISE EXCEPTION 'Enlace ya utilizado';
    END IF;

    -- Actualizar contraseña en auth.users
    UPDATE auth.users
    SET encrypted_password = crypt(p_new_password, gen_salt('bf')),
        updated_at = NOW()
    WHERE id = v_recovery.user_id;

    -- Marcar token como usado
    UPDATE password_recovery
    SET used_at = NOW()
    WHERE id = v_recovery.id;

    -- Invalidar sesiones activas
    DELETE FROM auth.refresh_tokens
    WHERE user_id = v_recovery.user_id::TEXT;

    -- Registrar en audit_logs
    INSERT INTO audit_logs (
        user_id,
        event_type,
        metadata,
        ip_address,
        created_at
    ) VALUES (
        v_recovery.user_id,
        'password_reset',
        json_build_object(
            'email', v_recovery.email,
            'token_id', v_recovery.id
        ),
        p_ip_address,
        NOW()
    );

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Contraseña cambiada exitosamente'
        )
    );

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

COMMENT ON FUNCTION reset_password IS 'HU-004: Cambia contraseña con token';

-- HU-004: cleanup_expired_recovery_tokens - Limpia tokens expirados
CREATE OR REPLACE FUNCTION cleanup_expired_recovery_tokens()
RETURNS JSON AS $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    DELETE FROM password_recovery
    WHERE expires_at < NOW();

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'deleted_count', v_deleted_count,
            'cleaned_at', NOW()
        )
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', 'cleanup_error'
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION cleanup_expired_recovery_tokens IS 'HU-004: Limpia tokens expirados';

-- ============================================
-- SECCIÓN 4: FUNCIONES DE MARCAS (E002-HU-001)
-- ============================================

-- E002-HU-001: get_marcas - Lista todas las marcas
CREATE OR REPLACE FUNCTION get_marcas()
RETURNS JSON AS $$
DECLARE
    v_marcas JSON;
BEGIN
    SELECT json_agg(
        json_build_object(
            'id', id,
            'nombre', nombre,
            'codigo', codigo,
            'activo', activo,
            'created_at', created_at,
            'updated_at', updated_at
        ) ORDER BY nombre ASC
    ) INTO v_marcas
    FROM marcas;

    IF v_marcas IS NULL THEN
        v_marcas := '[]'::json;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', v_marcas,
        'message', 'Marcas obtenidas exitosamente'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', 'unknown'
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_marcas IS 'E002-HU-001: Lista todas las marcas del catálogo';

-- E002-HU-001: create_marca - Crea nueva marca
CREATE OR REPLACE FUNCTION create_marca(
    p_nombre TEXT,
    p_codigo TEXT,
    p_activo BOOLEAN DEFAULT true
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_marca_id UUID;
    v_result JSON;
BEGIN
    -- Validaciones
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        v_error_hint := 'missing_nombre';
        RAISE EXCEPTION 'Nombre es requerido';
    END IF;

    IF p_codigo IS NULL OR TRIM(p_codigo) = '' THEN
        v_error_hint := 'missing_codigo';
        RAISE EXCEPTION 'Código es requerido';
    END IF;

    IF LENGTH(TRIM(p_codigo)) != 3 THEN
        v_error_hint := 'invalid_codigo_length';
        RAISE EXCEPTION 'Código debe tener exactamente 3 letras';
    END IF;

    IF UPPER(TRIM(p_codigo)) != TRIM(p_codigo) OR TRIM(p_codigo) !~ '^[A-Z]{3}$' THEN
        v_error_hint := 'invalid_codigo_format';
        RAISE EXCEPTION 'Código solo puede contener letras mayúsculas';
    END IF;

    IF LENGTH(TRIM(p_nombre)) > 50 THEN
        v_error_hint := 'invalid_nombre_length';
        RAISE EXCEPTION 'Nombre máximo 50 caracteres';
    END IF;

    IF EXISTS (SELECT 1 FROM marcas WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))) THEN
        v_error_hint := 'duplicate_nombre';
        RAISE EXCEPTION 'Ya existe una marca con este nombre';
    END IF;

    IF EXISTS (SELECT 1 FROM marcas WHERE codigo = TRIM(p_codigo)) THEN
        v_error_hint := 'duplicate_codigo';
        RAISE EXCEPTION 'Este código ya existe, ingresa otro';
    END IF;

    -- Insertar marca
    INSERT INTO marcas (nombre, codigo, activo)
    VALUES (TRIM(p_nombre), TRIM(p_codigo), COALESCE(p_activo, true))
    RETURNING id INTO v_marca_id;

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'codigo', codigo,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO v_result
    FROM marcas
    WHERE id = v_marca_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Marca creada exitosamente'
    );

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

COMMENT ON FUNCTION create_marca IS 'E002-HU-001: Crea nueva marca con validaciones';

-- E002-HU-001: update_marca - Actualiza marca
CREATE OR REPLACE FUNCTION update_marca(
    p_id UUID,
    p_nombre TEXT,
    p_activo BOOLEAN
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_result JSON;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM marcas WHERE id = p_id) THEN
        v_error_hint := 'marca_not_found';
        RAISE EXCEPTION 'La marca no existe';
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        v_error_hint := 'missing_nombre';
        RAISE EXCEPTION 'Nombre es requerido';
    END IF;

    IF LENGTH(TRIM(p_nombre)) > 50 THEN
        v_error_hint := 'invalid_nombre_length';
        RAISE EXCEPTION 'Nombre máximo 50 caracteres';
    END IF;

    IF EXISTS (
        SELECT 1 FROM marcas
        WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))
        AND id != p_id
    ) THEN
        v_error_hint := 'duplicate_nombre';
        RAISE EXCEPTION 'Ya existe una marca con este nombre';
    END IF;

    UPDATE marcas
    SET
        nombre = TRIM(p_nombre),
        activo = COALESCE(p_activo, activo)
    WHERE id = p_id;

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'codigo', codigo,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO v_result
    FROM marcas
    WHERE id = p_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Marca actualizada exitosamente'
    );

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

COMMENT ON FUNCTION update_marca IS 'E002-HU-001: Actualiza marca existente (código inmutable)';

-- E002-HU-001: toggle_marca - Activa/desactiva marca
CREATE OR REPLACE FUNCTION toggle_marca(p_id UUID)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_result JSON;
    v_new_state BOOLEAN;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM marcas WHERE id = p_id) THEN
        v_error_hint := 'marca_not_found';
        RAISE EXCEPTION 'La marca no existe';
    END IF;

    UPDATE marcas
    SET activo = NOT activo
    WHERE id = p_id
    RETURNING activo INTO v_new_state;

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'codigo', codigo,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO v_result
    FROM marcas
    WHERE id = p_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', CASE
            WHEN v_new_state THEN 'Marca reactivada exitosamente'
            ELSE 'Marca desactivada exitosamente'
        END
    );

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

COMMENT ON FUNCTION toggle_marca IS 'E002-HU-001: Activa/desactiva marca (soft delete)';

-- ============================================
-- SECCIÓN 5: FUNCIONES DE MATERIALES (E002-HU-002)
-- ============================================

-- E002-HU-002: listar_materiales - Lista todos los materiales con contador de productos
CREATE OR REPLACE FUNCTION listar_materiales()
RETURNS JSON AS $$
DECLARE
    v_materiales JSON;
BEGIN
    SELECT json_agg(
        json_build_object(
            'id', m.id,
            'nombre', m.nombre,
            'descripcion', m.descripcion,
            'codigo', m.codigo,
            'activo', m.activo,
            'created_at', m.created_at,
            'updated_at', m.updated_at,
            'productos_count', COALESCE(
                (SELECT COUNT(*) FROM productos p WHERE p.id IS NOT NULL),
                0
            )
        ) ORDER BY m.nombre ASC
    ) INTO v_materiales
    FROM materiales m;

    IF v_materiales IS NULL THEN
        v_materiales := '[]'::json;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', v_materiales,
        'message', 'Materiales obtenidos exitosamente'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', 'unknown'
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION listar_materiales IS 'E002-HU-002: Lista todos los materiales con contador de productos asociados';

-- E002-HU-002: crear_material - Crea nuevo material
CREATE OR REPLACE FUNCTION crear_material(
    p_nombre TEXT,
    p_descripcion TEXT,
    p_codigo TEXT
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_material_id UUID;
    v_result JSON;
    v_user_rol TEXT;
    v_user_id UUID;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-002-011: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar materiales';
    END IF;

    -- Validaciones
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        v_error_hint := 'missing_nombre';
        RAISE EXCEPTION 'Nombre es requerido';
    END IF;

    IF p_codigo IS NULL OR TRIM(p_codigo) = '' THEN
        v_error_hint := 'missing_codigo';
        RAISE EXCEPTION 'Código es requerido';
    END IF;

    -- RN-002-001: Validar formato de código (exactamente 3 letras mayúsculas)
    IF LENGTH(TRIM(p_codigo)) != 3 THEN
        v_error_hint := 'invalid_code_length';
        RAISE EXCEPTION 'Código debe tener exactamente 3 caracteres';
    END IF;

    IF TRIM(p_codigo) !~ '^[A-Z]{3}$' THEN
        v_error_hint := 'invalid_code_format';
        RAISE EXCEPTION 'Código solo puede contener letras mayúsculas (A-Z)';
    END IF;

    -- RN-002-002: Validar longitud de nombre
    IF LENGTH(TRIM(p_nombre)) > 50 THEN
        v_error_hint := 'invalid_nombre_length';
        RAISE EXCEPTION 'Nombre máximo 50 caracteres';
    END IF;

    -- RN-002-003: Validar longitud de descripción si se proporciona
    IF p_descripcion IS NOT NULL AND LENGTH(p_descripcion) > 200 THEN
        v_error_hint := 'invalid_descripcion_length';
        RAISE EXCEPTION 'Descripción máximo 200 caracteres';
    END IF;

    -- RN-002-002: Validar nombre único (case-insensitive)
    IF EXISTS (SELECT 1 FROM materiales WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))) THEN
        v_error_hint := 'duplicate_name';
        RAISE EXCEPTION 'Ya existe un material con este nombre';
    END IF;

    -- RN-002-001: Validar código único
    IF EXISTS (SELECT 1 FROM materiales WHERE codigo = TRIM(p_codigo)) THEN
        v_error_hint := 'duplicate_code';
        RAISE EXCEPTION 'Este código ya existe, ingresa otro';
    END IF;

    -- Insertar material
    INSERT INTO materiales (nombre, descripcion, codigo, activo)
    VALUES (
        TRIM(p_nombre),
        CASE WHEN p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN NULL ELSE TRIM(p_descripcion) END,
        TRIM(p_codigo),
        true
    )
    RETURNING id INTO v_material_id;

    -- RN-002-012: Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
        'material_management',
        json_build_object(
            'action', 'create',
            'material_id', v_material_id,
            'nombre', TRIM(p_nombre),
            'codigo', TRIM(p_codigo)
        )::jsonb
    );

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'descripcion', descripcion,
        'codigo', codigo,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO v_result
    FROM materiales
    WHERE id = v_material_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Material creado exitosamente'
    );

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

COMMENT ON FUNCTION crear_material IS 'E002-HU-002: Crea nuevo material con validaciones (RN-002-001, RN-002-002, RN-002-003, RN-002-011)';

-- E002-HU-002: actualizar_material - Actualiza material existente
CREATE OR REPLACE FUNCTION actualizar_material(
    p_id UUID,
    p_nombre TEXT,
    p_descripcion TEXT,
    p_activo BOOLEAN
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_result JSON;
    v_user_rol TEXT;
    v_old_data RECORD;
    v_user_id UUID;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-002-011: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar materiales';
    END IF;

    -- Verificar que material existe
    SELECT * INTO v_old_data FROM materiales WHERE id = p_id;

    IF NOT FOUND THEN
        v_error_hint := 'material_not_found';
        RAISE EXCEPTION 'El material no existe';
    END IF;

    -- Validaciones
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        v_error_hint := 'missing_nombre';
        RAISE EXCEPTION 'Nombre es requerido';
    END IF;

    -- RN-002-002: Validar longitud de nombre
    IF LENGTH(TRIM(p_nombre)) > 50 THEN
        v_error_hint := 'invalid_nombre_length';
        RAISE EXCEPTION 'Nombre máximo 50 caracteres';
    END IF;

    -- RN-002-003: Validar longitud de descripción si se proporciona
    IF p_descripcion IS NOT NULL AND LENGTH(p_descripcion) > 200 THEN
        v_error_hint := 'invalid_descripcion_length';
        RAISE EXCEPTION 'Descripción máximo 200 caracteres';
    END IF;

    -- RN-002-002: Validar nombre único (excepto sí mismo)
    IF EXISTS (
        SELECT 1 FROM materiales
        WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))
        AND id != p_id
    ) THEN
        v_error_hint := 'duplicate_name';
        RAISE EXCEPTION 'Ya existe un material con este nombre';
    END IF;

    -- RN-002-004: Código es inmutable (no se puede cambiar)
    -- No se incluye p_codigo en los parámetros para forzar inmutabilidad

    -- Actualizar material
    UPDATE materiales
    SET
        nombre = TRIM(p_nombre),
        descripcion = CASE WHEN p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN NULL ELSE TRIM(p_descripcion) END,
        activo = COALESCE(p_activo, activo)
    WHERE id = p_id;

    -- RN-002-012: Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
        'material_management',
        json_build_object(
            'action', 'update',
            'material_id', p_id,
            'old_nombre', v_old_data.nombre,
            'new_nombre', TRIM(p_nombre),
            'old_activo', v_old_data.activo,
            'new_activo', COALESCE(p_activo, v_old_data.activo)
        )::jsonb
    );

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'descripcion', descripcion,
        'codigo', codigo,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO v_result
    FROM materiales
    WHERE id = p_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Material actualizado exitosamente'
    );

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

COMMENT ON FUNCTION actualizar_material IS 'E002-HU-002: Actualiza material existente (RN-002-002, RN-002-004 código inmutable, RN-002-011)';

-- E002-HU-002: toggle_material_activo - Activa/desactiva material
CREATE OR REPLACE FUNCTION toggle_material_activo(
    p_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_result JSON;
    v_new_state BOOLEAN;
    v_user_rol TEXT;
    v_productos_count INTEGER;
    v_user_id UUID;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-002-011: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar materiales';
    END IF;

    -- Verificar que material existe
    IF NOT EXISTS (SELECT 1 FROM materiales WHERE id = p_id) THEN
        v_error_hint := 'material_not_found';
        RAISE EXCEPTION 'El material no existe';
    END IF;

    -- RN-002-007: Obtener contador de productos asociados
    SELECT COUNT(*) INTO v_productos_count
    FROM productos
    WHERE id IS NOT NULL; -- Placeholder: cuando exista relación, usar WHERE material_id = p_id

    -- RN-002-005: Soft delete (cambiar estado, no eliminar)
    UPDATE materiales
    SET activo = NOT activo
    WHERE id = p_id
    RETURNING activo INTO v_new_state;

    -- RN-002-012: Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
        'material_management',
        json_build_object(
            'action', CASE WHEN v_new_state THEN 'activate' ELSE 'deactivate' END,
            'material_id', p_id,
            'productos_count', v_productos_count
        )::jsonb
    );

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'descripcion', descripcion,
        'codigo', codigo,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at,
        'productos_count', v_productos_count
    ) INTO v_result
    FROM materiales
    WHERE id = p_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', CASE
            WHEN v_new_state THEN 'Material reactivado exitosamente'
            ELSE 'Material desactivado exitosamente. Los productos existentes no se verán afectados'
        END
    );

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

COMMENT ON FUNCTION toggle_material_activo IS 'E002-HU-002: Activa/desactiva material (RN-002-005 soft delete, RN-002-007 confirmación)';

-- E002-HU-002: buscar_materiales - Búsqueda multicriterio
CREATE OR REPLACE FUNCTION buscar_materiales(
    p_query TEXT
)
RETURNS JSON AS $$
DECLARE
    v_materiales JSON;
    v_search_term TEXT;
BEGIN
    -- RN-002-009: Búsqueda en nombre, descripción y código
    v_search_term := LOWER(TRIM(p_query));

    IF v_search_term IS NULL OR v_search_term = '' THEN
        -- Búsqueda vacía retorna todos
        RETURN listar_materiales();
    END IF;

    SELECT json_agg(
        json_build_object(
            'id', m.id,
            'nombre', m.nombre,
            'descripcion', m.descripcion,
            'codigo', m.codigo,
            'activo', m.activo,
            'created_at', m.created_at,
            'updated_at', m.updated_at,
            'productos_count', COALESCE(
                (SELECT COUNT(*) FROM productos p WHERE p.id IS NOT NULL),
                0
            )
        ) ORDER BY m.nombre ASC
    ) INTO v_materiales
    FROM materiales m
    WHERE LOWER(m.nombre) LIKE '%' || v_search_term || '%'
       OR LOWER(COALESCE(m.descripcion, '')) LIKE '%' || v_search_term || '%'
       OR LOWER(m.codigo) LIKE '%' || v_search_term || '%';

    IF v_materiales IS NULL THEN
        v_materiales := '[]'::json;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', v_materiales,
        'message', CASE
            WHEN json_array_length(v_materiales) = 0 THEN 'No se encontraron materiales'
            ELSE 'Materiales encontrados'
        END
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', 'unknown'
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION buscar_materiales IS 'E002-HU-002: Búsqueda multicriterio por nombre, descripción o código (RN-002-009)';

-- E002-HU-002: obtener_detalle_material - Vista detallada con estadísticas
CREATE OR REPLACE FUNCTION obtener_detalle_material(
    p_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_material RECORD;
    v_productos_count INTEGER;
    v_productos JSON;
    v_error_hint TEXT;
BEGIN
    -- RN-002-010: Obtener info completa del material
    SELECT * INTO v_material
    FROM materiales
    WHERE id = p_id;

    IF NOT FOUND THEN
        v_error_hint := 'material_not_found';
        RAISE EXCEPTION 'El material no existe';
    END IF;

    -- Contador de productos asociados
    SELECT COUNT(*) INTO v_productos_count
    FROM productos
    WHERE id IS NOT NULL; -- Placeholder: cuando exista relación, usar WHERE material_id = p_id

    -- Lista de productos asociados (placeholder)
    v_productos := '[]'::json;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', v_material.id,
            'nombre', v_material.nombre,
            'descripcion', v_material.descripcion,
            'codigo', v_material.codigo,
            'activo', v_material.activo,
            'created_at', v_material.created_at,
            'updated_at', v_material.updated_at,
            'estadisticas', json_build_object(
                'productos_count', v_productos_count,
                'tiene_productos', v_productos_count > 0
            ),
            'productos', v_productos
        ),
        'message', 'Detalle del material obtenido exitosamente'
    );

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

COMMENT ON FUNCTION obtener_detalle_material IS 'E002-HU-002: Obtiene detalle completo del material con estadísticas (RN-002-010)';

-- ============================================
-- SECCIÓN 6: FUNCIONES DE TIPOS (E002-HU-003)
-- ============================================

-- E002-HU-003: get_tipos - Lista tipos con filtros
CREATE OR REPLACE FUNCTION get_tipos(
    p_search TEXT DEFAULT NULL,
    p_activo_filter BOOLEAN DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_tipos JSON;
    v_search_term TEXT;
BEGIN
    v_search_term := LOWER(TRIM(COALESCE(p_search, '')));

    -- CA-001, CA-011: Listar con búsqueda multicriterio y filtro por estado
    SELECT json_agg(
        json_build_object(
            'id', t.id,
            'nombre', t.nombre,
            'descripcion', t.descripcion,
            'codigo', t.codigo,
            'imagen_url', t.imagen_url,
            'activo', t.activo,
            'created_at', t.created_at,
            'updated_at', t.updated_at
        ) ORDER BY t.nombre ASC
    ) INTO v_tipos
    FROM tipos t
    WHERE
        (p_activo_filter IS NULL OR t.activo = p_activo_filter)
        AND (
            v_search_term = ''
            OR LOWER(t.nombre) LIKE '%' || v_search_term || '%'
            OR LOWER(COALESCE(t.descripcion, '')) LIKE '%' || v_search_term || '%'
            OR LOWER(t.codigo) LIKE '%' || v_search_term || '%'
        );

    IF v_tipos IS NULL THEN
        v_tipos := '[]'::json;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', v_tipos,
        'message', 'Tipos obtenidos exitosamente'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', 'unknown'
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_tipos IS 'E002-HU-003: Lista tipos con búsqueda multicriterio (CA-001, CA-011, RN-003-009)';

-- E002-HU-003: create_tipo - Crea nuevo tipo
CREATE OR REPLACE FUNCTION create_tipo(
    p_nombre TEXT,
    p_descripcion TEXT,
    p_codigo TEXT,
    p_imagen_url TEXT DEFAULT NULL,
    p_activo BOOLEAN DEFAULT true
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_tipo_id UUID;
    v_result JSON;
BEGIN
    -- Validaciones CA-003
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        v_error_hint := 'missing_nombre';
        RAISE EXCEPTION 'Nombre es requerido';
    END IF;

    IF p_codigo IS NULL OR TRIM(p_codigo) = '' THEN
        v_error_hint := 'missing_codigo';
        RAISE EXCEPTION 'Código es requerido';
    END IF;

    -- RN-003-001: Validar código - exactamente 3 letras mayúsculas
    IF LENGTH(TRIM(p_codigo)) != 3 THEN
        v_error_hint := 'invalid_codigo_length';
        RAISE EXCEPTION 'Código debe tener exactamente 3 letras';
    END IF;

    IF TRIM(p_codigo) !~ '^[A-Z]{3}$' THEN
        v_error_hint := 'invalid_codigo_format';
        RAISE EXCEPTION 'Código solo puede contener letras mayúsculas';
    END IF;

    -- RN-003-002: Validar nombre único (case-insensitive) y longitud
    IF LENGTH(TRIM(p_nombre)) > 50 THEN
        v_error_hint := 'invalid_nombre_length';
        RAISE EXCEPTION 'Nombre máximo 50 caracteres';
    END IF;

    IF EXISTS (SELECT 1 FROM tipos WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))) THEN
        v_error_hint := 'duplicate_nombre';
        RAISE EXCEPTION 'Ya existe un tipo con este nombre';
    END IF;

    -- RN-003-001: Validar código único
    IF EXISTS (SELECT 1 FROM tipos WHERE codigo = TRIM(p_codigo)) THEN
        v_error_hint := 'duplicate_codigo';
        RAISE EXCEPTION 'Este código ya existe, ingresa otro';
    END IF;

    -- RN-003-003: Validar descripción (opcional, max 200 caracteres)
    IF p_descripcion IS NOT NULL AND LENGTH(p_descripcion) > 200 THEN
        v_error_hint := 'invalid_descripcion_length';
        RAISE EXCEPTION 'Descripción máximo 200 caracteres';
    END IF;

    -- CA-004: Insertar tipo
    INSERT INTO tipos (nombre, descripcion, codigo, imagen_url, activo)
    VALUES (
        TRIM(p_nombre),
        CASE WHEN p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN NULL ELSE TRIM(p_descripcion) END,
        TRIM(p_codigo),
        CASE WHEN p_imagen_url IS NULL OR TRIM(p_imagen_url) = '' THEN NULL ELSE TRIM(p_imagen_url) END,
        COALESCE(p_activo, true)
    )
    RETURNING id INTO v_tipo_id;

    -- RN-003-012: Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        auth.uid(),
        'tipo_created',
        json_build_object(
            'tipo_id', v_tipo_id,
            'nombre', TRIM(p_nombre),
            'codigo', TRIM(p_codigo)
        )::jsonb
    );

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'descripcion', descripcion,
        'codigo', codigo,
        'imagen_url', imagen_url,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO v_result
    FROM tipos
    WHERE id = v_tipo_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Tipo creado exitosamente'
    );

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

COMMENT ON FUNCTION create_tipo IS 'E002-HU-003: Crea nuevo tipo con validaciones (CA-002, CA-003, CA-004, RN-003-001 a RN-003-003)';

-- E002-HU-003: update_tipo - Actualiza tipo existente
CREATE OR REPLACE FUNCTION update_tipo(
    p_id UUID,
    p_nombre TEXT,
    p_descripcion TEXT,
    p_activo BOOLEAN
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_result JSON;
    v_old_data RECORD;
BEGIN
    -- Verificar que tipo existe
    SELECT * INTO v_old_data FROM tipos WHERE id = p_id;

    IF NOT FOUND THEN
        v_error_hint := 'tipo_not_found';
        RAISE EXCEPTION 'El tipo no existe';
    END IF;

    -- Validaciones CA-006
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        v_error_hint := 'missing_nombre';
        RAISE EXCEPTION 'Nombre es requerido';
    END IF;

    -- RN-003-002: Validar nombre único (excepto sí mismo)
    IF LENGTH(TRIM(p_nombre)) > 50 THEN
        v_error_hint := 'invalid_nombre_length';
        RAISE EXCEPTION 'Nombre máximo 50 caracteres';
    END IF;

    IF EXISTS (
        SELECT 1 FROM tipos
        WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))
        AND id != p_id
    ) THEN
        v_error_hint := 'duplicate_nombre';
        RAISE EXCEPTION 'Ya existe un tipo con este nombre';
    END IF;

    -- RN-003-003: Validar descripción (opcional, max 200 caracteres)
    IF p_descripcion IS NOT NULL AND LENGTH(p_descripcion) > 200 THEN
        v_error_hint := 'invalid_descripcion_length';
        RAISE EXCEPTION 'Descripción máximo 200 caracteres';
    END IF;

    -- RN-003-004: Código NO se puede modificar (no está en parámetros)

    -- CA-007: Actualizar tipo
    UPDATE tipos
    SET
        nombre = TRIM(p_nombre),
        descripcion = CASE WHEN p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN NULL ELSE TRIM(p_descripcion) END,
        activo = COALESCE(p_activo, activo)
    WHERE id = p_id;

    -- RN-003-012: Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        auth.uid(),
        'tipo_updated',
        json_build_object(
            'tipo_id', p_id,
            'old_nombre', v_old_data.nombre,
            'new_nombre', TRIM(p_nombre),
            'old_activo', v_old_data.activo,
            'new_activo', COALESCE(p_activo, v_old_data.activo)
        )::jsonb
    );

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'descripcion', descripcion,
        'codigo', codigo,
        'imagen_url', imagen_url,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO v_result
    FROM tipos
    WHERE id = p_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Tipo actualizado exitosamente'
    );

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

COMMENT ON FUNCTION update_tipo IS 'E002-HU-003: Actualiza tipo existente (CA-005, CA-006, CA-007, RN-003-004 código inmutable)';

-- E002-HU-003: toggle_tipo_activo - Activa/desactiva tipo
CREATE OR REPLACE FUNCTION toggle_tipo_activo(
    p_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_result JSON;
    v_new_state BOOLEAN;
    v_productos_count INTEGER;
BEGIN
    -- Verificar que tipo existe
    IF NOT EXISTS (SELECT 1 FROM tipos WHERE id = p_id) THEN
        v_error_hint := 'tipo_not_found';
        RAISE EXCEPTION 'El tipo no existe';
    END IF;

    -- RN-003-007: Obtener contador de productos asociados
    SELECT COUNT(*) INTO v_productos_count
    FROM productos
    WHERE id IS NOT NULL; -- Placeholder: cuando exista relación, usar WHERE tipo_id = p_id

    -- RN-003-005: Soft delete (cambiar estado, no eliminar)
    -- CA-008, CA-009, CA-010
    UPDATE tipos
    SET activo = NOT activo
    WHERE id = p_id
    RETURNING activo INTO v_new_state;

    -- RN-003-012: Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        auth.uid(),
        CASE WHEN v_new_state THEN 'tipo_activated' ELSE 'tipo_deactivated' END,
        json_build_object(
            'tipo_id', p_id,
            'productos_count', v_productos_count
        )::jsonb
    );

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'descripcion', descripcion,
        'codigo', codigo,
        'imagen_url', imagen_url,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at,
        'productos_count', v_productos_count
    ) INTO v_result
    FROM tipos
    WHERE id = p_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', CASE
            WHEN v_new_state THEN 'Tipo reactivado exitosamente'
            ELSE 'Tipo desactivado exitosamente'
        END
    );

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

COMMENT ON FUNCTION toggle_tipo_activo IS 'E002-HU-003: Activa/desactiva tipo (CA-008, CA-009, CA-010, RN-003-005 soft delete, RN-003-007)';

-- E002-HU-003: get_tipo_detalle - Vista detallada con estadísticas
CREATE OR REPLACE FUNCTION get_tipo_detalle(
    p_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_tipo RECORD;
    v_productos_count INTEGER;
    v_productos JSON;
    v_error_hint TEXT;
BEGIN
    -- CA-012, RN-003-010: Obtener info completa del tipo
    SELECT * INTO v_tipo
    FROM tipos
    WHERE id = p_id;

    IF NOT FOUND THEN
        v_error_hint := 'tipo_not_found';
        RAISE EXCEPTION 'El tipo no existe';
    END IF;

    -- Contador de productos asociados
    SELECT COUNT(*) INTO v_productos_count
    FROM productos
    WHERE id IS NOT NULL; -- Placeholder: cuando exista relación, usar WHERE tipo_id = p_id

    -- Lista de productos asociados (placeholder)
    SELECT json_agg(
        json_build_object(
            'id', id,
            'nombre', nombre
        )
    ) INTO v_productos
    FROM productos
    WHERE id IS NOT NULL
    LIMIT 10; -- Placeholder: cuando exista relación, usar WHERE tipo_id = p_id

    IF v_productos IS NULL THEN
        v_productos := '[]'::json;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', v_tipo.id,
            'nombre', v_tipo.nombre,
            'descripcion', v_tipo.descripcion,
            'codigo', v_tipo.codigo,
            'imagen_url', v_tipo.imagen_url,
            'activo', v_tipo.activo,
            'created_at', v_tipo.created_at,
            'updated_at', v_tipo.updated_at,
            'productos_count', v_productos_count,
            'productos_list', v_productos
        ),
        'message', 'Detalle del tipo obtenido exitosamente'
    );

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

COMMENT ON FUNCTION get_tipo_detalle IS 'E002-HU-003: Obtiene detalle completo del tipo con estadísticas (CA-012, RN-003-010)';

-- E002-HU-003: get_tipos_activos - Lista solo tipos activos para selecciones
CREATE OR REPLACE FUNCTION get_tipos_activos()
RETURNS JSON AS $$
DECLARE
    v_tipos JSON;
BEGIN
    -- RN-003-006: Solo tipos activos para nuevos productos
    SELECT json_agg(
        json_build_object(
            'id', id,
            'nombre', nombre,
            'codigo', codigo
        ) ORDER BY nombre ASC
    ) INTO v_tipos
    FROM tipos
    WHERE activo = true;

    IF v_tipos IS NULL THEN
        v_tipos := '[]'::json;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', v_tipos,
        'message', 'Tipos activos obtenidos'
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', 'unknown'
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_tipos_activos IS 'E002-HU-003: Lista solo tipos activos para formularios de productos (RN-003-006)';

COMMIT;

-- ============================================
-- RESUMEN
-- ============================================
-- Funciones creadas:
-- AUTH (HU-001, HU-002):
--   - register_user, confirm_email, dev_confirm_email
--   - check_login_rate_limit, login_user, validate_token
-- LOGOUT (HU-003):
--   - logout_user, check_token_blacklist
--   - update_user_activity, cleanup_expired_blacklist
-- PASSWORD (HU-004):
--   - request_password_reset, validate_reset_token
--   - reset_password, cleanup_expired_recovery_tokens
-- MARCAS (E002-HU-001):
--   - get_marcas, create_marca, update_marca, toggle_marca
-- MATERIALES (E002-HU-002):
--   - listar_materiales, crear_material, actualizar_material
--   - toggle_material_activo, buscar_materiales, obtener_detalle_material
-- TIPOS (E002-HU-003):
--   - get_tipos, create_tipo, update_tipo, toggle_tipo_activo
--   - get_tipo_detalle, get_tipos_activos
-- ============================================