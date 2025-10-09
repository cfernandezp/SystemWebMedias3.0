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
    v_user_rol TEXT;
    v_user_id UUID;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-003-011: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar tipos';
    END IF;

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
        v_user_id,
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
    p_imagen_url TEXT DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_result JSON;
    v_old_data RECORD;
    v_user_rol TEXT;
    v_user_id UUID;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-003-011: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar tipos';
    END IF;

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
        imagen_url = CASE WHEN p_imagen_url = '' THEN NULL ELSE COALESCE(p_imagen_url, imagen_url) END,
        activo = COALESCE(p_activo, activo)
    WHERE id = p_id;

    -- RN-003-012: Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
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
    v_user_rol TEXT;
    v_user_id UUID;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-003-011: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar tipos';
    END IF;

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
        v_user_id,
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

-- ============================================
-- SECCIÓN 7: FUNCIONES AUXILIARES SISTEMAS TALLA (E002-HU-004)
-- ============================================

-- E002-HU-004: Función auxiliar - Valida formato de rangos
CREATE OR REPLACE FUNCTION validate_range_format(
    p_valor TEXT,
    OUT is_valid BOOLEAN,
    OUT error_hint TEXT
)
AS $$
DECLARE
    v_parts TEXT[];
    v_num1 INTEGER;
    v_num2 INTEGER;
BEGIN
    is_valid := false;
    error_hint := NULL;

    -- Validar formato "N-M"
    IF p_valor !~ '^\d+-\d+$' THEN
        error_hint := 'invalid_range_format';
        RETURN;
    END IF;

    -- Separar partes
    v_parts := string_to_array(p_valor, '-');

    IF array_length(v_parts, 1) != 2 THEN
        error_hint := 'invalid_range_format';
        RETURN;
    END IF;

    -- Convertir a enteros
    BEGIN
        v_num1 := v_parts[1]::INTEGER;
        v_num2 := v_parts[2]::INTEGER;
    EXCEPTION
        WHEN OTHERS THEN
            error_hint := 'invalid_range_format';
            RETURN;
    END;

    -- RN-004-03: Validar primer número < segundo número
    IF v_num1 >= v_num2 THEN
        error_hint := 'invalid_range_order';
        RETURN;
    END IF;

    is_valid := true;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION validate_range_format IS 'E002-HU-004: Valida formato de rango "N-M" - RN-004-03, RN-004-12';

-- E002-HU-004: Función auxiliar - Verifica superposición de rangos
CREATE OR REPLACE FUNCTION validate_range_overlap(
    p_sistema_id UUID,
    p_valor_new TEXT,
    p_valor_id_exclude UUID DEFAULT NULL,
    OUT has_overlap BOOLEAN,
    OUT error_hint TEXT
)
AS $$
DECLARE
    v_existing RECORD;
    v_new_parts TEXT[];
    v_new_start INTEGER;
    v_new_end INTEGER;
    v_existing_parts TEXT[];
    v_existing_start INTEGER;
    v_existing_end INTEGER;
BEGIN
    has_overlap := false;
    error_hint := NULL;

    -- Parsear rango nuevo
    v_new_parts := string_to_array(p_valor_new, '-');
    IF array_length(v_new_parts, 1) = 2 THEN
        v_new_start := v_new_parts[1]::INTEGER;
        v_new_end := v_new_parts[2]::INTEGER;
    ELSE
        -- Si no es rango, no hay superposición
        RETURN;
    END IF;

    -- Verificar contra todos los valores existentes del sistema
    FOR v_existing IN
        SELECT valor
        FROM valores_talla
        WHERE sistema_talla_id = p_sistema_id
          AND (p_valor_id_exclude IS NULL OR id != p_valor_id_exclude)
          AND activo = true
    LOOP
        -- Parsear rango existente
        v_existing_parts := string_to_array(v_existing.valor, '-');

        IF array_length(v_existing_parts, 1) = 2 THEN
            v_existing_start := v_existing_parts[1]::INTEGER;
            v_existing_end := v_existing_parts[2]::INTEGER;

            -- RN-004-05: Verificar superposición
            -- Superposición si: (new_start <= existing_end) AND (new_end >= existing_start)
            IF (v_new_start <= v_existing_end) AND (v_new_end >= v_existing_start) THEN
                has_overlap := true;
                error_hint := 'overlapping_ranges';
                RETURN;
            END IF;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION validate_range_overlap IS 'E002-HU-004: Verifica superposición de rangos numéricos - RN-004-05';

-- ============================================
-- SECCIÓN 8: FUNCIONES RPC SISTEMAS TALLA (E002-HU-004)
-- ============================================

-- E002-HU-004: get_sistemas_talla - Lista sistemas con filtros
CREATE OR REPLACE FUNCTION get_sistemas_talla(
    p_search TEXT DEFAULT NULL,
    p_tipo_filter tipo_sistema_enum DEFAULT NULL,
    p_activo_filter BOOLEAN DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_sistemas JSON;
    v_search_term TEXT;
BEGIN
    v_search_term := LOWER(TRIM(COALESCE(p_search, '')));

    -- CA-001, CA-012: Listar con búsqueda multicriterio y filtros
    SELECT json_agg(
        json_build_object(
            'id', s.id,
            'nombre', s.nombre,
            'tipo_sistema', s.tipo_sistema,
            'descripcion', s.descripcion,
            'activo', s.activo,
            'valores_count', (
                SELECT COUNT(*)
                FROM valores_talla v
                WHERE v.sistema_talla_id = s.id
                  AND v.activo = true
            ),
            'created_at', s.created_at,
            'updated_at', s.updated_at
        ) ORDER BY s.nombre ASC
    ) INTO v_sistemas
    FROM sistemas_talla s
    WHERE
        (p_tipo_filter IS NULL OR s.tipo_sistema = p_tipo_filter)
        AND (p_activo_filter IS NULL OR s.activo = p_activo_filter)
        AND (
            v_search_term = ''
            OR LOWER(s.nombre) LIKE '%' || v_search_term || '%'
        );

    IF v_sistemas IS NULL THEN
        v_sistemas := '[]'::json;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', v_sistemas,
        'message', 'Sistemas de tallas obtenidos'
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

COMMENT ON FUNCTION get_sistemas_talla IS 'E002-HU-004: Lista sistemas de tallas con filtros (CA-001, CA-012, RN-004-11)';

-- E002-HU-004: create_sistema_talla - Crea nuevo sistema con valores
CREATE OR REPLACE FUNCTION create_sistema_talla(
    p_nombre TEXT,
    p_tipo_sistema tipo_sistema_enum,
    p_descripcion TEXT DEFAULT NULL,
    p_valores TEXT[] DEFAULT NULL,
    p_activo BOOLEAN DEFAULT true
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_sistema_id UUID;
    v_valor TEXT;
    v_orden INTEGER := 0;
    v_result JSON;
    v_valores_result JSON;
    v_user_rol TEXT;
    v_user_id UUID;
    v_validation RECORD;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-004-11: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar sistemas de tallas';
    END IF;

    -- CA-004: Validaciones
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        v_error_hint := 'missing_nombre';
        RAISE EXCEPTION 'Nombre es requerido';
    END IF;

    IF p_tipo_sistema IS NULL THEN
        v_error_hint := 'missing_tipo_sistema';
        RAISE EXCEPTION 'Tipo de sistema es requerido';
    END IF;

    -- RN-004-02: Validar nombre único (case-insensitive)
    IF LENGTH(TRIM(p_nombre)) > 50 THEN
        v_error_hint := 'invalid_nombre_length';
        RAISE EXCEPTION 'Nombre máximo 50 caracteres';
    END IF;

    IF EXISTS (SELECT 1 FROM sistemas_talla WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))) THEN
        v_error_hint := 'duplicate_nombre';
        RAISE EXCEPTION 'Ya existe un sistema con este nombre';
    END IF;

    -- Validar descripción
    IF p_descripcion IS NOT NULL AND LENGTH(p_descripcion) > 200 THEN
        v_error_hint := 'invalid_descripcion_length';
        RAISE EXCEPTION 'Descripción máximo 200 caracteres';
    END IF;

    -- RN-004-06: Validar mínimo 1 valor (excepto UNICA que se genera automáticamente)
    IF p_tipo_sistema != 'UNICA' THEN
        IF p_valores IS NULL OR array_length(p_valores, 1) = 0 THEN
            v_error_hint := 'missing_valores';
            RAISE EXCEPTION 'Debe configurar al menos un valor para este tipo';
        END IF;
    END IF;

    -- Insertar sistema
    INSERT INTO sistemas_talla (nombre, tipo_sistema, descripcion, activo)
    VALUES (
        TRIM(p_nombre),
        p_tipo_sistema,
        CASE WHEN p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN NULL ELSE TRIM(p_descripcion) END,
        COALESCE(p_activo, true)
    )
    RETURNING id INTO v_sistema_id;

    -- Insertar valores
    IF p_tipo_sistema = 'UNICA' THEN
        -- Tipo UNICA: agregar valor automático
        INSERT INTO valores_talla (sistema_talla_id, valor, orden, activo)
        VALUES (v_sistema_id, 'ÚNICA', 1, true);
    ELSE
        -- Otros tipos: procesar valores recibidos
        FOREACH v_valor IN ARRAY p_valores
        LOOP
            v_orden := v_orden + 1;

            -- RN-004-04: Validar no duplicados (case-insensitive para LETRA)
            IF p_tipo_sistema = 'LETRA' THEN
                IF EXISTS (
                    SELECT 1
                    FROM valores_talla
                    WHERE sistema_talla_id = v_sistema_id
                      AND LOWER(valor) = LOWER(TRIM(v_valor))
                ) THEN
                    v_error_hint := 'duplicate_valor';
                    RAISE EXCEPTION 'No se permiten valores duplicados: %', v_valor;
                END IF;
            ELSE
                IF EXISTS (
                    SELECT 1
                    FROM valores_talla
                    WHERE sistema_talla_id = v_sistema_id
                      AND valor = TRIM(v_valor)
                ) THEN
                    v_error_hint := 'duplicate_valor';
                    RAISE EXCEPTION 'No se permiten valores duplicados: %', v_valor;
                END IF;
            END IF;

            -- RN-004-03, RN-004-12: Validar formato según tipo
            IF p_tipo_sistema IN ('NUMERO', 'RANGO') THEN
                -- Validar formato rango
                SELECT * INTO v_validation FROM validate_range_format(TRIM(v_valor));

                IF NOT v_validation.is_valid THEN
                    v_error_hint := v_validation.error_hint;
                    RAISE EXCEPTION 'Formato inválido para valor: %', v_valor;
                END IF;

                -- RN-004-05: Validar no superposición
                SELECT * INTO v_validation FROM validate_range_overlap(v_sistema_id, TRIM(v_valor));

                IF v_validation.has_overlap THEN
                    v_error_hint := v_validation.error_hint;
                    RAISE EXCEPTION 'Los rangos no pueden superponerse: %', v_valor;
                END IF;
            END IF;

            -- Insertar valor
            INSERT INTO valores_talla (sistema_talla_id, valor, orden, activo)
            VALUES (v_sistema_id, TRIM(v_valor), v_orden, true);
        END LOOP;
    END IF;

    -- Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
        'sistema_talla_created',
        json_build_object(
            'sistema_id', v_sistema_id,
            'nombre', TRIM(p_nombre),
            'tipo_sistema', p_tipo_sistema
        )::jsonb
    );

    -- Obtener sistema completo con valores
    SELECT json_agg(
        json_build_object(
            'id', id,
            'valor', valor,
            'orden', orden,
            'activo', activo
        ) ORDER BY orden
    ) INTO v_valores_result
    FROM valores_talla
    WHERE sistema_talla_id = v_sistema_id;

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'tipo_sistema', tipo_sistema,
        'descripcion', descripcion,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO v_result
    FROM sistemas_talla
    WHERE id = v_sistema_id;

    v_result := jsonb_set(v_result::jsonb, '{valores}', COALESCE(v_valores_result, '[]'::json)::jsonb);

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Sistema de tallas creado'
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

COMMENT ON FUNCTION create_sistema_talla IS 'E002-HU-004: Crea sistema de tallas con valores (CA-002 a CA-005, RN-004-01 a RN-004-06)';

-- E002-HU-004: update_sistema_talla - Actualiza sistema (nombre, descripción, activo)
CREATE OR REPLACE FUNCTION update_sistema_talla(
    p_id UUID,
    p_nombre TEXT,
    p_descripcion TEXT DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_result JSON;
    v_old_data RECORD;
    v_user_rol TEXT;
    v_user_id UUID;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-004-11: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar sistemas de tallas';
    END IF;

    -- Verificar que sistema existe
    SELECT * INTO v_old_data FROM sistemas_talla WHERE id = p_id;

    IF NOT FOUND THEN
        v_error_hint := 'sistema_not_found';
        RAISE EXCEPTION 'El sistema no existe';
    END IF;

    -- CA-006: Validaciones
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        v_error_hint := 'missing_nombre';
        RAISE EXCEPTION 'Nombre es requerido';
    END IF;

    -- RN-004-02: Validar nombre único (excepto sí mismo)
    IF LENGTH(TRIM(p_nombre)) > 50 THEN
        v_error_hint := 'invalid_nombre_length';
        RAISE EXCEPTION 'Nombre máximo 50 caracteres';
    END IF;

    IF EXISTS (
        SELECT 1 FROM sistemas_talla
        WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))
        AND id != p_id
    ) THEN
        v_error_hint := 'duplicate_nombre';
        RAISE EXCEPTION 'Ya existe un sistema con este nombre';
    END IF;

    -- Validar descripción
    IF p_descripcion IS NOT NULL AND LENGTH(p_descripcion) > 200 THEN
        v_error_hint := 'invalid_descripcion_length';
        RAISE EXCEPTION 'Descripción máximo 200 caracteres';
    END IF;

    -- RN-004-07: tipo_sistema NO se puede modificar (no está en parámetros)

    -- CA-009: Actualizar sistema
    UPDATE sistemas_talla
    SET
        nombre = TRIM(p_nombre),
        descripcion = CASE WHEN p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN NULL ELSE TRIM(p_descripcion) END,
        activo = COALESCE(p_activo, activo)
    WHERE id = p_id;

    -- Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
        'sistema_talla_updated',
        json_build_object(
            'sistema_id', p_id,
            'old_nombre', v_old_data.nombre,
            'new_nombre', TRIM(p_nombre)
        )::jsonb
    );

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'tipo_sistema', tipo_sistema,
        'descripcion', descripcion,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO v_result
    FROM sistemas_talla
    WHERE id = p_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Sistema actualizado exitosamente'
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

COMMENT ON FUNCTION update_sistema_talla IS 'E002-HU-004: Actualiza sistema (CA-006, CA-009, RN-004-07 tipo inmutable)';

-- E002-HU-004: get_sistema_talla_valores - Obtiene sistema con todos sus valores
CREATE OR REPLACE FUNCTION get_sistema_talla_valores(
    p_sistema_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_sistema RECORD;
    v_valores JSON;
    v_error_hint TEXT;
BEGIN
    -- CA-010: Obtener sistema completo
    SELECT * INTO v_sistema
    FROM sistemas_talla
    WHERE id = p_sistema_id;

    IF NOT FOUND THEN
        v_error_hint := 'sistema_not_found';
        RAISE EXCEPTION 'El sistema no existe';
    END IF;

    -- Obtener valores con estadísticas
    SELECT json_agg(
        json_build_object(
            'id', v.id,
            'valor', v.valor,
            'orden', v.orden,
            'activo', v.activo,
            'productos_count', 0  -- Placeholder: cuando exista relación con productos
        ) ORDER BY v.orden
    ) INTO v_valores
    FROM valores_talla v
    WHERE v.sistema_talla_id = p_sistema_id;

    IF v_valores IS NULL THEN
        v_valores := '[]'::json;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'sistema', json_build_object(
                'id', v_sistema.id,
                'nombre', v_sistema.nombre,
                'tipo_sistema', v_sistema.tipo_sistema,
                'descripcion', v_sistema.descripcion,
                'activo', v_sistema.activo,
                'created_at', v_sistema.created_at,
                'updated_at', v_sistema.updated_at
            ),
            'valores', v_valores
        ),
        'message', 'Sistema con valores obtenido'
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

COMMENT ON FUNCTION get_sistema_talla_valores IS 'E002-HU-004: Obtiene sistema con todos sus valores (CA-010)';

-- E002-HU-004: add_valor_talla - Agrega nuevo valor a sistema
CREATE OR REPLACE FUNCTION add_valor_talla(
    p_sistema_id UUID,
    p_valor TEXT,
    p_orden INTEGER DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_sistema RECORD;
    v_orden_final INTEGER;
    v_valor_id UUID;
    v_result JSON;
    v_user_rol TEXT;
    v_user_id UUID;
    v_validation RECORD;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-004-11: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar sistemas de tallas';
    END IF;

    -- Verificar que sistema existe
    SELECT * INTO v_sistema FROM sistemas_talla WHERE id = p_sistema_id;

    IF NOT FOUND THEN
        v_error_hint := 'sistema_not_found';
        RAISE EXCEPTION 'El sistema no existe';
    END IF;

    -- CA-007: Validaciones
    IF p_valor IS NULL OR TRIM(p_valor) = '' THEN
        v_error_hint := 'missing_valor';
        RAISE EXCEPTION 'Valor es requerido';
    END IF;

    IF LENGTH(TRIM(p_valor)) > 20 THEN
        v_error_hint := 'invalid_valor_length';
        RAISE EXCEPTION 'Valor máximo 20 caracteres';
    END IF;

    -- RN-004-04: Validar no duplicados
    IF v_sistema.tipo_sistema = 'LETRA' THEN
        IF EXISTS (
            SELECT 1
            FROM valores_talla
            WHERE sistema_talla_id = p_sistema_id
              AND LOWER(valor) = LOWER(TRIM(p_valor))
        ) THEN
            v_error_hint := 'duplicate_valor';
            RAISE EXCEPTION 'Ya existe este valor en el sistema';
        END IF;
    ELSE
        IF EXISTS (
            SELECT 1
            FROM valores_talla
            WHERE sistema_talla_id = p_sistema_id
              AND valor = TRIM(p_valor)
        ) THEN
            v_error_hint := 'duplicate_valor';
            RAISE EXCEPTION 'Ya existe este valor en el sistema';
        END IF;
    END IF;

    -- RN-004-03, RN-004-12: Validar formato según tipo
    IF v_sistema.tipo_sistema IN ('NUMERO', 'RANGO') THEN
        -- Validar formato rango
        SELECT * INTO v_validation FROM validate_range_format(TRIM(p_valor));

        IF NOT v_validation.is_valid THEN
            v_error_hint := v_validation.error_hint;
            RAISE EXCEPTION 'Formato inválido para valor de tipo %', v_sistema.tipo_sistema;
        END IF;

        -- RN-004-05: Validar no superposición
        SELECT * INTO v_validation FROM validate_range_overlap(p_sistema_id, TRIM(p_valor));

        IF v_validation.has_overlap THEN
            v_error_hint := v_validation.error_hint;
            RAISE EXCEPTION 'Los rangos no pueden superponerse';
        END IF;
    END IF;

    -- Calcular orden final
    IF p_orden IS NULL THEN
        SELECT COALESCE(MAX(orden), 0) + 1
        INTO v_orden_final
        FROM valores_talla
        WHERE sistema_talla_id = p_sistema_id;
    ELSE
        v_orden_final := p_orden;
    END IF;

    -- Insertar valor
    INSERT INTO valores_talla (sistema_talla_id, valor, orden, activo)
    VALUES (p_sistema_id, TRIM(p_valor), v_orden_final, true)
    RETURNING id INTO v_valor_id;

    -- Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
        'valor_talla_added',
        json_build_object(
            'sistema_id', p_sistema_id,
            'valor_id', v_valor_id,
            'valor', TRIM(p_valor)
        )::jsonb
    );

    SELECT json_build_object(
        'id', id,
        'valor', valor,
        'orden', orden,
        'activo', activo
    ) INTO v_result
    FROM valores_talla
    WHERE id = v_valor_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Valor agregado exitosamente'
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

COMMENT ON FUNCTION add_valor_talla IS 'E002-HU-004: Agrega nuevo valor a sistema (CA-007, RN-004-03 a RN-004-05)';

-- E002-HU-004: update_valor_talla - Actualiza valor existente
CREATE OR REPLACE FUNCTION update_valor_talla(
    p_valor_id UUID,
    p_valor TEXT,
    p_orden INTEGER DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_old_data RECORD;
    v_sistema RECORD;
    v_result JSON;
    v_user_rol TEXT;
    v_user_id UUID;
    v_validation RECORD;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-004-11: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar sistemas de tallas';
    END IF;

    -- Verificar que valor existe
    SELECT v.*, s.tipo_sistema
    INTO v_old_data
    FROM valores_talla v
    JOIN sistemas_talla s ON v.sistema_talla_id = s.id
    WHERE v.id = p_valor_id;

    IF NOT FOUND THEN
        v_error_hint := 'valor_not_found';
        RAISE EXCEPTION 'El valor no existe';
    END IF;

    -- CA-007: Validaciones
    IF p_valor IS NULL OR TRIM(p_valor) = '' THEN
        v_error_hint := 'missing_valor';
        RAISE EXCEPTION 'Valor es requerido';
    END IF;

    IF LENGTH(TRIM(p_valor)) > 20 THEN
        v_error_hint := 'invalid_valor_length';
        RAISE EXCEPTION 'Valor máximo 20 caracteres';
    END IF;

    -- RN-004-04: Validar no duplicados (excepto sí mismo)
    IF v_old_data.tipo_sistema = 'LETRA' THEN
        IF EXISTS (
            SELECT 1
            FROM valores_talla
            WHERE sistema_talla_id = v_old_data.sistema_talla_id
              AND LOWER(valor) = LOWER(TRIM(p_valor))
              AND id != p_valor_id
        ) THEN
            v_error_hint := 'duplicate_valor';
            RAISE EXCEPTION 'Ya existe este valor en el sistema';
        END IF;
    ELSE
        IF EXISTS (
            SELECT 1
            FROM valores_talla
            WHERE sistema_talla_id = v_old_data.sistema_talla_id
              AND valor = TRIM(p_valor)
              AND id != p_valor_id
        ) THEN
            v_error_hint := 'duplicate_valor';
            RAISE EXCEPTION 'Ya existe este valor en el sistema';
        END IF;
    END IF;

    -- RN-004-03, RN-004-12: Validar formato según tipo
    IF v_old_data.tipo_sistema IN ('NUMERO', 'RANGO') THEN
        -- Validar formato rango
        SELECT * INTO v_validation FROM validate_range_format(TRIM(p_valor));

        IF NOT v_validation.is_valid THEN
            v_error_hint := v_validation.error_hint;
            RAISE EXCEPTION 'Formato inválido para valor de tipo %', v_old_data.tipo_sistema;
        END IF;

        -- RN-004-05: Validar no superposición (excluyendo este valor)
        SELECT * INTO v_validation FROM validate_range_overlap(v_old_data.sistema_talla_id, TRIM(p_valor), p_valor_id);

        IF v_validation.has_overlap THEN
            v_error_hint := v_validation.error_hint;
            RAISE EXCEPTION 'Los rangos no pueden superponerse';
        END IF;
    END IF;

    -- Actualizar valor
    UPDATE valores_talla
    SET
        valor = TRIM(p_valor),
        orden = COALESCE(p_orden, orden)
    WHERE id = p_valor_id;

    -- Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
        'valor_talla_updated',
        json_build_object(
            'valor_id', p_valor_id,
            'old_valor', v_old_data.valor,
            'new_valor', TRIM(p_valor)
        )::jsonb
    );

    SELECT json_build_object(
        'id', id,
        'valor', valor,
        'orden', orden,
        'activo', activo
    ) INTO v_result
    FROM valores_talla
    WHERE id = p_valor_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Valor actualizado exitosamente'
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

COMMENT ON FUNCTION update_valor_talla IS 'E002-HU-004: Actualiza valor existente (CA-007, RN-004-03 a RN-004-05)';

-- E002-HU-004: delete_valor_talla - Elimina (soft delete) valor
CREATE OR REPLACE FUNCTION delete_valor_talla(
    p_valor_id UUID,
    p_force BOOLEAN DEFAULT false
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_valor RECORD;
    v_valores_count INTEGER;
    v_productos_count INTEGER;
    v_user_rol TEXT;
    v_user_id UUID;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-004-11: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar sistemas de tallas';
    END IF;

    -- Verificar que valor existe
    SELECT * INTO v_valor FROM valores_talla WHERE id = p_valor_id;

    IF NOT FOUND THEN
        v_error_hint := 'valor_not_found';
        RAISE EXCEPTION 'El valor no existe';
    END IF;

    -- RN-004-06: Validar que no es el último valor del sistema
    SELECT COUNT(*)
    INTO v_valores_count
    FROM valores_talla
    WHERE sistema_talla_id = v_valor.sistema_talla_id
      AND activo = true;

    IF v_valores_count <= 1 THEN
        v_error_hint := 'last_value_cannot_delete';
        RAISE EXCEPTION 'No se puede eliminar el último valor del sistema';
    END IF;

    -- RN-004-08: Verificar si hay productos usando este valor
    v_productos_count := 0;  -- Placeholder: cuando exista relación con productos
    -- SELECT COUNT(*) INTO v_productos_count FROM productos WHERE valor_talla_id = p_valor_id;

    IF v_productos_count > 0 THEN
        IF NOT p_force THEN
            v_error_hint := 'valor_used_by_products';
            RETURN json_build_object(
                'success', false,
                'error', json_build_object(
                    'code', '45000',
                    'message', 'Este valor está siendo usado en ' || v_productos_count || ' productos',
                    'hint', v_error_hint,
                    'productos_count', v_productos_count
                )
            );
        END IF;
    END IF;

    -- CA-008: Soft delete (desactivar)
    UPDATE valores_talla
    SET activo = false
    WHERE id = p_valor_id;

    -- Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
        'valor_talla_deleted',
        json_build_object(
            'valor_id', p_valor_id,
            'valor', v_valor.valor,
            'force', p_force,
            'productos_count', v_productos_count
        )::jsonb
    );

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', p_valor_id,
            'productos_affected', v_productos_count,
            'message', 'Valor eliminado exitosamente'
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

COMMENT ON FUNCTION delete_valor_talla IS 'E002-HU-004: Elimina (soft delete) valor (CA-008, RN-004-06, RN-004-08, RN-004-13)';

-- E002-HU-004: toggle_sistema_talla_activo - Activa/desactiva sistema
CREATE OR REPLACE FUNCTION toggle_sistema_talla_activo(
    p_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_result JSON;
    v_new_state BOOLEAN;
    v_productos_count INTEGER;
    v_user_rol TEXT;
    v_user_id UUID;
BEGIN
    -- Obtener user_id del contexto de autenticación
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        v_error_hint := 'not_authenticated';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- RN-004-11: Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden gestionar sistemas de tallas';
    END IF;

    -- Verificar que sistema existe
    IF NOT EXISTS (SELECT 1 FROM sistemas_talla WHERE id = p_id) THEN
        v_error_hint := 'sistema_not_found';
        RAISE EXCEPTION 'El sistema no existe';
    END IF;

    -- Obtener contador de productos asociados (placeholder)
    v_productos_count := 0;
    -- SELECT COUNT(*) INTO v_productos_count FROM productos WHERE sistema_talla_id = p_id;

    -- CA-011, RN-004-09: Toggle estado (soft delete)
    UPDATE sistemas_talla
    SET activo = NOT activo
    WHERE id = p_id
    RETURNING activo INTO v_new_state;

    -- Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
        CASE WHEN v_new_state THEN 'sistema_talla_activated' ELSE 'sistema_talla_deactivated' END,
        json_build_object(
            'sistema_id', p_id,
            'productos_count', v_productos_count
        )::jsonb
    );

    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'tipo_sistema', tipo_sistema,
        'descripcion', descripcion,
        'activo', activo,
        'created_at', created_at,
        'updated_at', updated_at,
        'productos_count', v_productos_count
    ) INTO v_result
    FROM sistemas_talla
    WHERE id = p_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', CASE
            WHEN v_new_state THEN 'Sistema reactivado exitosamente'
            ELSE 'Sistema desactivado exitosamente. Los productos existentes no se verán afectados'
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

COMMENT ON FUNCTION toggle_sistema_talla_activo IS 'E002-HU-004: Activa/desactiva sistema (CA-011, RN-004-09, RN-004-13)';

-- ============================================
-- SECCIÓN 6: FUNCIONES DE COLORES (E002-HU-005)
-- ============================================

-- HU-005: listar_colores - Lista todos los colores con contador de productos
CREATE OR REPLACE FUNCTION listar_colores()
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- CA-001: Retornar todos los colores ordenados por nombre con contador de productos
    SELECT json_agg(
        json_build_object(
            'id', c.id,
            'nombre', c.nombre,
            'codigo_hex', c.codigo_hex,
            'activo', c.activo,
            'productos_count', COALESCE((
                SELECT COUNT(*)
                FROM producto_colores pc
                WHERE c.nombre = ANY(pc.colores)
            ), 0),
            'created_at', c.created_at,
            'updated_at', c.updated_at
        ) ORDER BY LOWER(c.nombre)
    ) INTO v_result
    FROM colores c;

    RETURN json_build_object(
        'success', true,
        'data', COALESCE(v_result, '[]'::json),
        'message', 'Colores listados exitosamente'
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

COMMENT ON FUNCTION listar_colores IS 'E002-HU-005: Lista todos los colores con contador de productos (CA-001)';

-- HU-005: crear_color - Crea nuevo color base
CREATE OR REPLACE FUNCTION crear_color(
    p_nombre TEXT,
    p_codigo_hex TEXT
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_user_id UUID;
    v_user_rol TEXT;
    v_color_id UUID;
BEGIN
    -- Obtener usuario autenticado
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- Verificar que usuario es ADMIN o GERENTE
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR (v_user_rol != 'ADMIN' AND v_user_rol != 'GERENTE') THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN o GERENTE pueden gestionar colores';
    END IF;

    -- RN-025: Validar unicidad de nombre (case-insensitive)
    IF EXISTS (SELECT 1 FROM colores WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))) THEN
        v_error_hint := 'duplicate_name';
        RAISE EXCEPTION 'Este color ya existe en el catálogo';
    END IF;

    -- RN-026: Validar formato hexadecimal
    IF p_codigo_hex !~ '^#[0-9A-Fa-f]{6}$' THEN
        v_error_hint := 'invalid_hex_format';
        RAISE EXCEPTION 'El código hexadecimal debe tener formato #RRGGBB (ej: #FF0000)';
    END IF;

    -- RN-025: Validar longitud del nombre (3-30 caracteres)
    IF LENGTH(TRIM(p_nombre)) < 3 OR LENGTH(TRIM(p_nombre)) > 30 THEN
        v_error_hint := 'invalid_name_length';
        RAISE EXCEPTION 'El nombre debe tener entre 3 y 30 caracteres';
    END IF;

    -- RN-025: Validar solo letras, espacios y guiones
    IF TRIM(p_nombre) !~ '^[A-Za-zÀ-ÿ\s\-]+$' THEN
        v_error_hint := 'invalid_name_chars';
        RAISE EXCEPTION 'El nombre solo puede contener letras, espacios y guiones';
    END IF;

    -- CA-002: Crear color
    INSERT INTO colores (nombre, codigo_hex)
    VALUES (TRIM(p_nombre), UPPER(p_codigo_hex))
    RETURNING id INTO v_color_id;

    -- Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
        'color_created',
        json_build_object(
            'color_id', v_color_id,
            'nombre', p_nombre,
            'codigo_hex', p_codigo_hex
        )::jsonb
    );

    -- Obtener color creado
    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'codigo_hex', codigo_hex,
        'activo', activo,
        'productos_count', 0,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO v_result
    FROM colores
    WHERE id = v_color_id;

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Color creado exitosamente'
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

COMMENT ON FUNCTION crear_color IS 'E002-HU-005: Crea nuevo color base (CA-002, CA-003, RN-025, RN-026)';

-- HU-005: editar_color - Edita color existente
CREATE OR REPLACE FUNCTION editar_color(
    p_id UUID,
    p_nombre TEXT,
    p_codigo_hex TEXT
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_user_id UUID;
    v_user_rol TEXT;
    v_productos_count INTEGER;
BEGIN
    -- Obtener usuario autenticado
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- Verificar que usuario es ADMIN o GERENTE
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR (v_user_rol != 'ADMIN' AND v_user_rol != 'GERENTE') THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN o GERENTE pueden gestionar colores';
    END IF;

    -- Verificar que color existe
    IF NOT EXISTS (SELECT 1 FROM colores WHERE id = p_id) THEN
        v_error_hint := 'color_not_found';
        RAISE EXCEPTION 'El color no existe';
    END IF;

    -- RN-025: Validar unicidad de nombre (excepto mismo registro)
    IF EXISTS (
        SELECT 1 FROM colores
        WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))
        AND id != p_id
    ) THEN
        v_error_hint := 'duplicate_name';
        RAISE EXCEPTION 'Ya existe otro color con este nombre';
    END IF;

    -- RN-026: Validar formato hexadecimal
    IF p_codigo_hex !~ '^#[0-9A-Fa-f]{6}$' THEN
        v_error_hint := 'invalid_hex_format';
        RAISE EXCEPTION 'El código hexadecimal debe tener formato #RRGGBB (ej: #FF0000)';
    END IF;

    -- RN-025: Validar longitud del nombre (3-30 caracteres)
    IF LENGTH(TRIM(p_nombre)) < 3 OR LENGTH(TRIM(p_nombre)) > 30 THEN
        v_error_hint := 'invalid_name_length';
        RAISE EXCEPTION 'El nombre debe tener entre 3 y 30 caracteres';
    END IF;

    -- RN-025: Validar solo letras, espacios y guiones
    IF TRIM(p_nombre) !~ '^[A-Za-zÀ-ÿ\s\-]+$' THEN
        v_error_hint := 'invalid_name_chars';
        RAISE EXCEPTION 'El nombre solo puede contener letras, espacios y guiones';
    END IF;

    -- RN-030: Contar productos afectados
    SELECT COUNT(*) INTO v_productos_count
    FROM producto_colores pc
    WHERE (SELECT nombre FROM colores WHERE id = p_id) = ANY(pc.colores);

    -- CA-006: Actualizar color
    UPDATE colores
    SET nombre = TRIM(p_nombre),
        codigo_hex = UPPER(p_codigo_hex)
    WHERE id = p_id;

    -- Registrar auditoría
    INSERT INTO audit_logs (user_id, event_type, metadata)
    VALUES (
        v_user_id,
        'color_updated',
        json_build_object(
            'color_id', p_id,
            'nombre', p_nombre,
            'codigo_hex', p_codigo_hex,
            'productos_afectados', v_productos_count
        )::jsonb
    );

    -- Obtener color actualizado
    SELECT json_build_object(
        'id', id,
        'nombre', nombre,
        'codigo_hex', codigo_hex,
        'activo', activo,
        'productos_count', v_productos_count,
        'created_at', created_at,
        'updated_at', updated_at
    ) INTO v_result
    FROM colores
    WHERE id = p_id;

    v_error_hint := 'products_affected';
    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', CASE
            WHEN v_productos_count > 0 THEN
                'Color actualizado exitosamente. Este cambio afecta a ' || v_productos_count || ' producto(s)'
            ELSE
                'Color actualizado exitosamente'
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

COMMENT ON FUNCTION editar_color IS 'E002-HU-005: Edita color existente (CA-006, RN-025, RN-026, RN-030)';

-- HU-005: eliminar_color - Elimina o desactiva color según uso
CREATE OR REPLACE FUNCTION eliminar_color(
    p_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_user_id UUID;
    v_user_rol TEXT;
    v_productos_count INTEGER;
    v_color_nombre TEXT;
    v_deleted BOOLEAN := false;
    v_deactivated BOOLEAN := false;
BEGIN
    -- Obtener usuario autenticado
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden eliminar colores';
    END IF;

    -- Verificar que color existe
    SELECT nombre INTO v_color_nombre
    FROM colores
    WHERE id = p_id;

    IF v_color_nombre IS NULL THEN
        v_error_hint := 'color_not_found';
        RAISE EXCEPTION 'El color no existe';
    END IF;

    -- RN-029: Verificar si color está en uso
    SELECT COUNT(*) INTO v_productos_count
    FROM producto_colores
    WHERE v_color_nombre = ANY(colores);

    IF v_productos_count > 0 THEN
        -- RN-029: Color en uso → solo desactivar
        v_error_hint := 'has_products_use_deactivate';

        UPDATE colores
        SET activo = false
        WHERE id = p_id;

        v_deactivated := true;

        -- Registrar auditoría
        INSERT INTO audit_logs (user_id, event_type, metadata)
        VALUES (
            v_user_id,
            'color_deactivated',
            json_build_object(
                'color_id', p_id,
                'nombre', v_color_nombre,
                'productos_count', v_productos_count
            )::jsonb
        );

        RETURN json_build_object(
            'success', true,
            'data', json_build_object(
                'deleted', v_deleted,
                'deactivated', v_deactivated,
                'productos_count', v_productos_count
            ),
            'message', 'El color está en uso en ' || v_productos_count || ' producto(s). Se ha desactivado en lugar de eliminarse'
        );
    ELSE
        -- RN-029: Color sin uso → eliminar permanente
        DELETE FROM colores WHERE id = p_id;
        v_deleted := true;

        -- Registrar auditoría
        INSERT INTO audit_logs (user_id, event_type, metadata)
        VALUES (
            v_user_id,
            'color_deleted',
            json_build_object(
                'color_id', p_id,
                'nombre', v_color_nombre
            )::jsonb
        );

        RETURN json_build_object(
            'success', true,
            'data', json_build_object(
                'deleted', v_deleted,
                'deactivated', v_deactivated,
                'productos_count', 0
            ),
            'message', 'Color eliminado permanentemente'
        );
    END IF;

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

COMMENT ON FUNCTION eliminar_color IS 'E002-HU-005: Elimina o desactiva color según uso (CA-007, CA-008, RN-029)';

-- HU-005: obtener_productos_por_color - Busca productos por color
CREATE OR REPLACE FUNCTION obtener_productos_por_color(
    p_color_nombre TEXT,
    p_exacto BOOLEAN DEFAULT false
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Validar que color existe
    IF NOT EXISTS (SELECT 1 FROM colores WHERE LOWER(nombre) = LOWER(p_color_nombre)) THEN
        v_error_hint := 'color_not_found';
        RAISE EXCEPTION 'El color no existe en el catálogo';
    END IF;

    IF p_exacto THEN
        -- RN-033: Búsqueda exacta (solo ese color, unicolor)
        SELECT json_agg(
            json_build_object(
                'id', p.id,
                'nombre', p.nombre,
                'descripcion', p.descripcion,
                'precio', p.precio,
                'colores', pc.colores,
                'tipo_color', pc.tipo_color,
                'cantidad_colores', pc.cantidad_colores,
                'descripcion_visual', pc.descripcion_visual
            )
        ) INTO v_result
        FROM productos p
        INNER JOIN producto_colores pc ON p.id = pc.producto_id
        WHERE pc.colores = ARRAY[p_color_nombre]::TEXT[]
        AND p.activo = true;
    ELSE
        -- RN-033: Búsqueda inclusiva (contiene el color)
        SELECT json_agg(
            json_build_object(
                'id', p.id,
                'nombre', p.nombre,
                'descripcion', p.descripcion,
                'precio', p.precio,
                'colores', pc.colores,
                'tipo_color', pc.tipo_color,
                'cantidad_colores', pc.cantidad_colores,
                'descripcion_visual', pc.descripcion_visual
            )
        ) INTO v_result
        FROM productos p
        INNER JOIN producto_colores pc ON p.id = pc.producto_id
        WHERE p_color_nombre = ANY(pc.colores)
        AND p.activo = true;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', COALESCE(v_result, '[]'::json),
        'message', CASE
            WHEN p_exacto THEN 'Productos con color exacto listados exitosamente'
            ELSE 'Productos que contienen el color listados exitosamente'
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

COMMENT ON FUNCTION obtener_productos_por_color IS 'E002-HU-005: Busca productos por color (CA-009, CA-010, RN-033)';

-- HU-005: estadisticas_colores - Estadísticas de uso de colores
CREATE OR REPLACE FUNCTION estadisticas_colores()
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_total_productos INTEGER;
    v_productos_unicolor INTEGER;
    v_productos_multicolor INTEGER;
    v_porcentaje_unicolor DECIMAL;
    v_porcentaje_multicolor DECIMAL;
    v_productos_por_color JSON;
    v_top_combinaciones JSON;
    v_colores_menos_usados JSON;
BEGIN
    -- RN-035: Cantidad total de productos con colores
    SELECT COUNT(*) INTO v_total_productos
    FROM producto_colores;

    -- RN-035: Productos unicolor vs multicolor
    SELECT COUNT(*) INTO v_productos_unicolor
    FROM producto_colores
    WHERE tipo_color = 'Unicolor';

    SELECT COUNT(*) INTO v_productos_multicolor
    FROM producto_colores
    WHERE tipo_color IN ('Bicolor', 'Tricolor', 'Multicolor');

    -- Calcular porcentajes
    IF v_total_productos > 0 THEN
        v_porcentaje_unicolor := ROUND((v_productos_unicolor::DECIMAL / v_total_productos * 100), 2);
        v_porcentaje_multicolor := ROUND((v_productos_multicolor::DECIMAL / v_total_productos * 100), 2);
    ELSE
        v_porcentaje_unicolor := 0;
        v_porcentaje_multicolor := 0;
    END IF;

    -- RN-035: Cantidad de productos por color base
    SELECT json_agg(
        json_build_object(
            'color', c.nombre,
            'codigo_hex', c.codigo_hex,
            'cantidad_productos', COALESCE((
                SELECT COUNT(*)
                FROM producto_colores pc
                WHERE c.nombre = ANY(pc.colores)
            ), 0)
        ) ORDER BY COALESCE((
            SELECT COUNT(*)
            FROM producto_colores pc
            WHERE c.nombre = ANY(pc.colores)
        ), 0) DESC
    ) INTO v_productos_por_color
    FROM colores c
    WHERE c.activo = true;

    -- RN-035: Top 5 combinaciones más usadas
    SELECT json_agg(
        json_build_object(
            'colores', pc.colores,
            'tipo_color', pc.tipo_color,
            'cantidad_productos', count
        ) ORDER BY count DESC
    ) INTO v_top_combinaciones
    FROM (
        SELECT colores, tipo_color, COUNT(*) as count
        FROM producto_colores
        GROUP BY colores, tipo_color
        ORDER BY COUNT(*) DESC
        LIMIT 5
    ) pc;

    -- RN-035: Colores con menor uso (candidatos a descontinuar)
    SELECT json_agg(
        json_build_object(
            'color', c.nombre,
            'codigo_hex', c.codigo_hex,
            'cantidad_productos', COALESCE((
                SELECT COUNT(*)
                FROM producto_colores pc
                WHERE c.nombre = ANY(pc.colores)
            ), 0)
        ) ORDER BY COALESCE((
            SELECT COUNT(*)
            FROM producto_colores pc
            WHERE c.nombre = ANY(pc.colores)
        ), 0) ASC
    ) INTO v_colores_menos_usados
    FROM colores c
    WHERE c.activo = true
    LIMIT 5;

    -- CA-011: Construir respuesta completa
    v_result := json_build_object(
        'total_productos', v_total_productos,
        'productos_unicolor', v_productos_unicolor,
        'productos_multicolor', v_productos_multicolor,
        'porcentaje_unicolor', v_porcentaje_unicolor,
        'porcentaje_multicolor', v_porcentaje_multicolor,
        'productos_por_color', COALESCE(v_productos_por_color, '[]'::json),
        'top_combinaciones', COALESCE(v_top_combinaciones, '[]'::json),
        'colores_menos_usados', COALESCE(v_colores_menos_usados, '[]'::json)
    );

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Estadísticas de colores generadas exitosamente'
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

COMMENT ON FUNCTION estadisticas_colores IS 'E002-HU-005: Estadísticas de uso de colores (CA-011, RN-035)';

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
-- SISTEMAS TALLA (E002-HU-004):
--   - listar_sistemas_talla, crear_sistema_talla, actualizar_sistema_talla
--   - toggle_sistema_talla_activo
-- COLORES (E002-HU-005):
--   - listar_colores, crear_color, editar_color, eliminar_color
--   - obtener_productos_por_color, estadisticas_colores
-- ============================================