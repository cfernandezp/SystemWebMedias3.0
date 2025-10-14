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
    v_password_match := (crypt(p_password, v_user.encrypted_password) = v_user.encrypted_password);

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

-- HU-005-EXT: listar_colores - Lista todos los colores con soporte para colores compuestos
CREATE OR REPLACE FUNCTION listar_colores()
RETURNS JSON AS $$
BEGIN
    RETURN json_build_object(
        'success', true,
        'data', COALESCE(
            (SELECT json_agg(
                json_build_object(
                    'id', c.id,
                    'nombre', c.nombre,
                    'codigos_hex', c.codigos_hex,
                    'tipo_color', c.tipo_color,
                    'activo', c.activo,
                    'productos_count', COALESCE((
                        SELECT COUNT(DISTINCT pc.producto_id)
                        FROM producto_colores pc
                        WHERE c.nombre = ANY(pc.colores)
                    ), 0),
                    'created_at', c.created_at,
                    'updated_at', c.updated_at
                ) ORDER BY c.nombre
            )
            FROM colores c
            WHERE c.activo = true),
            '[]'::json
        ),
        'message', 'Colores listados exitosamente'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION listar_colores() IS 'E002-HU-005-EXT: Lista colores con tipo y códigos hex (array)';

-- HU-005-EXT: crear_color - Crea color único (1 hex) o compuesto (2-3 hex)
CREATE OR REPLACE FUNCTION crear_color(
    p_nombre TEXT,
    p_codigos_hex TEXT[]
)
RETURNS JSON AS $$
DECLARE
    v_color_id UUID;
    v_error_hint TEXT;
    v_user_id UUID;
    v_user_rol TEXT;
    v_tipo_color VARCHAR(10);
    v_cantidad_codigos INTEGER;
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

    -- Determinar tipo según cantidad de códigos
    v_cantidad_codigos := array_length(p_codigos_hex, 1);

    IF v_cantidad_codigos = 1 THEN
        v_tipo_color := 'unico';
    ELSIF v_cantidad_codigos BETWEEN 2 AND 3 THEN
        v_tipo_color := 'compuesto';
    ELSE
        v_error_hint := 'invalid_color_count';
        RAISE EXCEPTION 'Debe proporcionar entre 1 y 3 códigos hexadecimales';
    END IF;

    -- RN-025: Validar unicidad de nombre (case-insensitive)
    IF EXISTS (SELECT 1 FROM colores WHERE LOWER(nombre) = LOWER(TRIM(p_nombre))) THEN
        v_error_hint := 'duplicate_name';
        RAISE EXCEPTION 'Ya existe un color con el nombre "%"', p_nombre;
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

    -- Crear color (trigger validará formato hex de cada código)
    INSERT INTO colores (nombre, codigos_hex, tipo_color)
    VALUES (TRIM(p_nombre), p_codigos_hex, v_tipo_color)
    RETURNING id INTO v_color_id;

    -- Retornar éxito
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', v_color_id,
            'nombre', TRIM(p_nombre),
            'codigos_hex', p_codigos_hex,
            'tipo_color', v_tipo_color,
            'activo', true,
            'productos_count', 0,
            'created_at', NOW(),
            'updated_at', NOW()
        ),
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

COMMENT ON FUNCTION crear_color(TEXT, TEXT[]) IS 'E002-HU-005-EXT: Crea color único (1 hex) o compuesto (2-3 hex)';

-- HU-005-EXT: editar_color - Edita color y retorna productos afectados
CREATE OR REPLACE FUNCTION editar_color(
    p_id UUID,
    p_nombre TEXT,
    p_codigos_hex TEXT[]
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_user_id UUID;
    v_user_rol TEXT;
    v_tipo_color VARCHAR(10);
    v_cantidad_codigos INTEGER;
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

    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM colores WHERE id = p_id) THEN
        v_error_hint := 'color_not_found';
        RAISE EXCEPTION 'Color no encontrado';
    END IF;

    -- Determinar tipo según cantidad de códigos
    v_cantidad_codigos := array_length(p_codigos_hex, 1);

    IF v_cantidad_codigos = 1 THEN
        v_tipo_color := 'unico';
    ELSIF v_cantidad_codigos BETWEEN 2 AND 3 THEN
        v_tipo_color := 'compuesto';
    ELSE
        v_error_hint := 'invalid_color_count';
        RAISE EXCEPTION 'Debe proporcionar entre 1 y 3 códigos hexadecimales';
    END IF;

    -- RN-025: Validar nombre único (excepto mismo color)
    IF EXISTS (SELECT 1 FROM colores WHERE LOWER(nombre) = LOWER(TRIM(p_nombre)) AND id != p_id) THEN
        v_error_hint := 'duplicate_name';
        RAISE EXCEPTION 'Ya existe otro color con el nombre "%"', p_nombre;
    END IF;

    -- RN-025: Validar longitud nombre
    IF LENGTH(TRIM(p_nombre)) < 3 OR LENGTH(TRIM(p_nombre)) > 30 THEN
        v_error_hint := 'invalid_name_length';
        RAISE EXCEPTION 'El nombre debe tener entre 3 y 30 caracteres';
    END IF;

    -- RN-025: Validar caracteres permitidos
    IF TRIM(p_nombre) !~ '^[A-Za-zÀ-ÿ\s\-]+$' THEN
        v_error_hint := 'invalid_name_chars';
        RAISE EXCEPTION 'El nombre solo puede contener letras, espacios y guiones';
    END IF;

    -- Contar productos afectados
    SELECT COUNT(DISTINCT pc.producto_id)
    INTO v_productos_count
    FROM producto_colores pc
    WHERE (SELECT nombre FROM colores WHERE id = p_id) = ANY(pc.colores);

    -- Actualizar color (trigger validará formato hex)
    UPDATE colores
    SET nombre = TRIM(p_nombre),
        codigos_hex = p_codigos_hex,
        tipo_color = v_tipo_color,
        updated_at = NOW()
    WHERE id = p_id;

    -- Retornar éxito
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', p_id,
            'nombre', TRIM(p_nombre),
            'codigos_hex', p_codigos_hex,
            'tipo_color', v_tipo_color,
            'productos_count', COALESCE(v_productos_count, 0)
        ),
        'message', 'Color actualizado exitosamente'
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

COMMENT ON FUNCTION editar_color(UUID, TEXT, TEXT[]) IS 'E002-HU-005-EXT: Edita color y retorna productos afectados';

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
            'codigos_hex', c.codigos_hex,
            'tipo_color', c.tipo_color,
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
            'codigos_hex', c.codigos_hex,
            'tipo_color', c.tipo_color,
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

-- HU-005: filtrar_productos_por_combinacion - Filtra productos por combinación exacta de colores
CREATE OR REPLACE FUNCTION filtrar_productos_por_combinacion(
    p_colores TEXT[]
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_color_nombre TEXT;
BEGIN
    -- Validar que array no esté vacío
    IF p_colores IS NULL OR array_length(p_colores, 1) IS NULL THEN
        v_error_hint := 'missing_colors';
        RAISE EXCEPTION 'Debe proporcionar al menos un color';
    END IF;

    -- Validar que todos los colores existan en el catálogo
    FOREACH v_color_nombre IN ARRAY p_colores
    LOOP
        IF NOT EXISTS (SELECT 1 FROM colores WHERE LOWER(nombre) = LOWER(TRIM(v_color_nombre))) THEN
            v_error_hint := 'color_not_found';
            RAISE EXCEPTION 'El color "%" no existe en el catálogo', v_color_nombre;
        END IF;
    END LOOP;

    -- CA-009: Buscar productos con combinación EXACTA de colores (mismo orden)
    SELECT json_agg(
        json_build_object(
            'id', p.id,
            'nombre', p.nombre,
            'descripcion', p.descripcion,
            'precio', p.precio,
            'stock_actual', p.stock_actual,
            'colores', pc.colores,
            'tipo_color', pc.tipo_color,
            'cantidad_colores', pc.cantidad_colores,
            'descripcion_visual', pc.descripcion_visual
        )
    ) INTO v_result
    FROM productos p
    INNER JOIN producto_colores pc ON p.id = pc.producto_id
    WHERE pc.colores = p_colores
      AND p.activo = true;

    RETURN json_build_object(
        'success', true,
        'data', COALESCE(v_result, '[]'::json),
        'message', 'Productos con combinación exacta encontrados: ' || array_to_string(p_colores, ', ')
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

COMMENT ON FUNCTION filtrar_productos_por_combinacion IS 'E002-HU-005: Filtra productos por combinación exacta de colores en orden - CA-009, RN-028';

-- ============================================
-- PASO 15: Funciones Productos Maestros (E002-HU-006)
-- ============================================

-- Función 1: validar_combinacion_comercial
CREATE OR REPLACE FUNCTION validar_combinacion_comercial(
    p_tipo_id UUID,
    p_sistema_talla_id UUID
) RETURNS JSON AS $$
DECLARE
    v_tipo_nombre TEXT;
    v_sistema_tipo tipo_sistema_enum;
    v_warnings TEXT[] := ARRAY[]::TEXT[];
    v_error_hint TEXT;
BEGIN
    -- Validar tipo existe
    SELECT nombre INTO v_tipo_nombre
    FROM tipos
    WHERE id = p_tipo_id;

    IF v_tipo_nombre IS NULL THEN
        v_error_hint := 'tipo_not_found';
        RAISE EXCEPTION 'Tipo no encontrado';
    END IF;

    -- Validar sistema existe
    SELECT tipo_sistema INTO v_sistema_tipo
    FROM sistemas_talla
    WHERE id = p_sistema_talla_id;

    IF v_sistema_tipo IS NULL THEN
        v_error_hint := 'sistema_not_found';
        RAISE EXCEPTION 'Sistema de tallas no encontrado';
    END IF;

    -- Validaciones combinaciones comerciales (RN-040)
    -- Normalizar tildes para comparación case-insensitive
    IF translate(v_tipo_nombre, 'áéíóúÁÉÍÓÚ', 'aeiouAEIOU') ILIKE '%futbol%' AND v_sistema_tipo = 'UNICA' THEN
        v_warnings := array_append(v_warnings, 'Las medias de fútbol normalmente usan tallas numéricas (35-44)');
    END IF;

    IF translate(v_tipo_nombre, 'áéíóúÁÉÍÓÚ', 'aeiouAEIOU') ILIKE '%futbol%' AND v_sistema_tipo = 'LETRA' THEN
        v_warnings := array_append(v_warnings, 'Las medias de fútbol normalmente usan tallas numéricas, no S/M/L');
    END IF;

    IF translate(v_tipo_nombre, 'áéíóúÁÉÍÓÚ', 'aeiouAEIOU') ILIKE '%invisible%' AND v_sistema_tipo = 'LETRA' THEN
        v_warnings := array_append(v_warnings, 'Las medias invisibles suelen ser talla única o numérica');
    END IF;

    IF translate(v_tipo_nombre, 'áéíóúÁÉÍÓÚ', 'aeiouAEIOU') ILIKE '%invisible%' AND v_sistema_tipo = 'NUMERO' THEN
        v_warnings := array_append(v_warnings, 'Las medias invisibles suelen ser talla única');
    END IF;

    -- Respuesta con warnings
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'warnings', v_warnings,
            'has_warnings', array_length(v_warnings, 1) > 0
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

COMMENT ON FUNCTION validar_combinacion_comercial IS 'E002-HU-006: Valida combinaciones comerciales tipo + sistema tallas (advertencias no bloqueantes) - CA-005, RN-040';

-- Función 2: crear_producto_maestro
CREATE OR REPLACE FUNCTION crear_producto_maestro(
    p_marca_id UUID,
    p_material_id UUID,
    p_tipo_id UUID,
    p_sistema_talla_id UUID,
    p_descripcion TEXT DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    v_producto_id UUID;
    v_marca_activo BOOLEAN;
    v_material_activo BOOLEAN;
    v_tipo_activo BOOLEAN;
    v_sistema_activo BOOLEAN;
    v_exists_activo BOOLEAN;
    v_exists_inactivo UUID;
    v_nombre_completo TEXT;
    v_warnings TEXT[] := ARRAY[]::TEXT[];
    v_error_hint TEXT;
BEGIN
    -- Validar descripción longitud (RN-039)
    IF p_descripcion IS NOT NULL AND LENGTH(p_descripcion) > 200 THEN
        v_error_hint := 'invalid_description_length';
        RAISE EXCEPTION 'Descripción excede 200 caracteres';
    END IF;

    -- Validar catálogos activos (RN-038)
    SELECT activo INTO v_marca_activo FROM marcas WHERE id = p_marca_id;
    SELECT activo INTO v_material_activo FROM materiales WHERE id = p_material_id;
    SELECT activo INTO v_tipo_activo FROM tipos WHERE id = p_tipo_id;
    SELECT activo INTO v_sistema_activo FROM sistemas_talla WHERE id = p_sistema_talla_id;

    IF v_marca_activo = false THEN
        v_error_hint := 'inactive_catalog';
        RAISE EXCEPTION 'La marca está inactiva. Reactívela primero';
    END IF;

    IF v_material_activo = false THEN
        v_error_hint := 'inactive_catalog';
        RAISE EXCEPTION 'El material está inactivo. Reactívelo primero';
    END IF;

    IF v_tipo_activo = false THEN
        v_error_hint := 'inactive_catalog';
        RAISE EXCEPTION 'El tipo está inactivo. Reactívelo primero';
    END IF;

    IF v_sistema_activo = false THEN
        v_error_hint := 'inactive_catalog';
        RAISE EXCEPTION 'El sistema de tallas está inactivo. Reactívelo primero';
    END IF;

    -- Validar combinación única (RN-037)
    SELECT EXISTS(
        SELECT 1 FROM productos_maestros
        WHERE marca_id = p_marca_id
        AND material_id = p_material_id
        AND tipo_id = p_tipo_id
        AND sistema_talla_id = p_sistema_talla_id
        AND activo = true
    ) INTO v_exists_activo;

    IF v_exists_activo THEN
        v_error_hint := 'duplicate_combination';
        RAISE EXCEPTION 'Ya existe un producto activo con esta combinación';
    END IF;

    -- Verificar si existe inactivo (CA-016)
    SELECT id INTO v_exists_inactivo
    FROM productos_maestros
    WHERE marca_id = p_marca_id
    AND material_id = p_material_id
    AND tipo_id = p_tipo_id
    AND sistema_talla_id = p_sistema_talla_id
    AND activo = false
    LIMIT 1;

    IF v_exists_inactivo IS NOT NULL THEN
        -- Construir nombre completo para response
        SELECT ma.nombre || ' - ' || t.nombre || ' - ' || mat.nombre || ' - ' || st.nombre
        INTO v_nombre_completo
        FROM marcas ma, materiales mat, tipos t, sistemas_talla st
        WHERE ma.id = p_marca_id
        AND mat.id = p_material_id
        AND t.id = p_tipo_id
        AND st.id = p_sistema_talla_id;

        v_error_hint := 'duplicate_combination_inactive';
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', '23505',
                'message', 'Ya existe un producto inactivo con esta combinación. Puedes reactivarlo',
                'hint', v_error_hint,
                'producto_id', v_exists_inactivo,
                'nombre_completo', v_nombre_completo
            )
        );
    END IF;

    -- Validar combinación comercial (RN-040) - solo warnings
    DECLARE
        v_validacion JSON;
    BEGIN
        SELECT validar_combinacion_comercial(p_tipo_id, p_sistema_talla_id) INTO v_validacion;
        IF (v_validacion->'data'->>'has_warnings')::BOOLEAN THEN
            SELECT ARRAY(SELECT json_array_elements_text(v_validacion->'data'->'warnings')) INTO v_warnings;
        END IF;
    END;

    -- Crear producto maestro
    INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
    VALUES (p_marca_id, p_material_id, p_tipo_id, p_sistema_talla_id, p_descripcion, true)
    RETURNING id INTO v_producto_id;

    -- Construir nombre completo
    SELECT ma.nombre || ' - ' || t.nombre || ' - ' || mat.nombre || ' - ' || st.nombre
    INTO v_nombre_completo
    FROM marcas ma, materiales mat, tipos t, sistemas_talla st
    WHERE ma.id = p_marca_id
    AND mat.id = p_material_id
    AND t.id = p_tipo_id
    AND st.id = p_sistema_talla_id;

    -- Respuesta exitosa
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', v_producto_id,
            'nombre_completo', v_nombre_completo,
            'warnings', v_warnings
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

COMMENT ON FUNCTION crear_producto_maestro IS 'E002-HU-006: Crea producto maestro con validaciones unicidad y catálogos activos - CA-006, CA-016, RN-037, RN-038, RN-039, RN-040';

-- Función 3: listar_productos_maestros
CREATE OR REPLACE FUNCTION listar_productos_maestros(
    p_marca_id UUID DEFAULT NULL,
    p_material_id UUID DEFAULT NULL,
    p_tipo_id UUID DEFAULT NULL,
    p_sistema_talla_id UUID DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL,
    p_search_text TEXT DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    v_productos JSON;
    v_error_hint TEXT;
BEGIN
    SELECT json_agg(row_to_json(subq))
    INTO v_productos
    FROM (
        SELECT
            pm.id,
            pm.marca_id,
            ma.nombre as marca_nombre,
            ma.codigo as marca_codigo,
            pm.material_id,
            mat.nombre as material_nombre,
            mat.codigo as material_codigo,
            pm.tipo_id,
            t.nombre as tipo_nombre,
            t.codigo as tipo_codigo,
            pm.sistema_talla_id,
            st.nombre as sistema_talla_nombre,
            st.tipo_sistema as sistema_talla_tipo,
            pm.descripcion,
            pm.activo,
            0 as articulos_activos,
            0 as articulos_totales,
            CASE WHEN (ma.activo = false OR mat.activo = false OR t.activo = false OR st.activo = false)
                 THEN true ELSE false END as tiene_catalogos_inactivos,
            ma.nombre || ' - ' || t.nombre || ' - ' || mat.nombre || ' - ' || st.nombre as nombre_completo,
            pm.created_at,
            pm.updated_at
        FROM productos_maestros pm
        INNER JOIN marcas ma ON pm.marca_id = ma.id
        INNER JOIN materiales mat ON pm.material_id = mat.id
        INNER JOIN tipos t ON pm.tipo_id = t.id
        INNER JOIN sistemas_talla st ON pm.sistema_talla_id = st.id
        WHERE (p_marca_id IS NULL OR pm.marca_id = p_marca_id)
        AND (p_material_id IS NULL OR pm.material_id = p_material_id)
        AND (p_tipo_id IS NULL OR pm.tipo_id = p_tipo_id)
        AND (p_sistema_talla_id IS NULL OR pm.sistema_talla_id = p_sistema_talla_id)
        AND (p_activo IS NULL OR pm.activo = p_activo)
        AND (p_search_text IS NULL OR
             LOWER(pm.descripcion) LIKE LOWER('%' || p_search_text || '%') OR
             LOWER(ma.nombre) LIKE LOWER('%' || p_search_text || '%') OR
             LOWER(mat.nombre) LIKE LOWER('%' || p_search_text || '%') OR
             LOWER(t.nombre) LIKE LOWER('%' || p_search_text || '%') OR
             LOWER(st.nombre) LIKE LOWER('%' || p_search_text || '%')
        )
        ORDER BY pm.created_at DESC
    ) subq;

    RETURN json_build_object(
        'success', true,
        'data', COALESCE(v_productos, '[]'::json)
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

COMMENT ON FUNCTION listar_productos_maestros IS 'E002-HU-006: Lista productos maestros con filtros y detección catálogos inactivos - CA-009, CA-010, RN-038, RN-043';

-- Función 4: editar_producto_maestro
CREATE OR REPLACE FUNCTION editar_producto_maestro(
    p_producto_id UUID,
    p_marca_id UUID DEFAULT NULL,
    p_material_id UUID DEFAULT NULL,
    p_tipo_id UUID DEFAULT NULL,
    p_sistema_talla_id UUID DEFAULT NULL,
    p_descripcion TEXT DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    v_articulos_totales INTEGER := 0;
    v_error_hint TEXT;
BEGIN
    -- Validar producto existe
    IF NOT EXISTS(SELECT 1 FROM productos_maestros WHERE id = p_producto_id) THEN
        v_error_hint := 'producto_not_found';
        RAISE EXCEPTION 'Producto maestro no encontrado';
    END IF;

    -- Contar artículos derivados (preparado para HU-007)
    -- En el futuro: SELECT COUNT(*) INTO v_articulos_totales FROM articulos WHERE producto_maestro_id = p_producto_id;

    -- Validación RN-044: Restricciones según artículos
    IF v_articulos_totales > 0 THEN
        -- Solo permitir editar descripción
        IF p_marca_id IS NOT NULL OR p_material_id IS NOT NULL OR p_tipo_id IS NOT NULL OR p_sistema_talla_id IS NOT NULL THEN
            v_error_hint := 'has_derived_articles';
            RAISE EXCEPTION 'Este producto tiene % artículos derivados. Solo se puede editar la descripción', v_articulos_totales;
        END IF;

        -- Actualizar solo descripción
        UPDATE productos_maestros
        SET descripcion = COALESCE(p_descripcion, descripcion),
            updated_at = NOW()
        WHERE id = p_producto_id;
    ELSE
        -- Sin artículos: permitir editar todos los campos
        IF p_descripcion IS NOT NULL AND LENGTH(p_descripcion) > 200 THEN
            v_error_hint := 'invalid_description_length';
            RAISE EXCEPTION 'Descripción excede 200 caracteres';
        END IF;

        -- Validar catálogos activos si se están cambiando (RN-038)
        IF p_marca_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM marcas WHERE id = p_marca_id AND activo = true) THEN
            v_error_hint := 'inactive_catalog';
            RAISE EXCEPTION 'La marca seleccionada está inactiva';
        END IF;

        IF p_material_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM materiales WHERE id = p_material_id AND activo = true) THEN
            v_error_hint := 'inactive_catalog';
            RAISE EXCEPTION 'El material seleccionado está inactivo';
        END IF;

        IF p_tipo_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM tipos WHERE id = p_tipo_id AND activo = true) THEN
            v_error_hint := 'inactive_catalog';
            RAISE EXCEPTION 'El tipo seleccionado está inactivo';
        END IF;

        IF p_sistema_talla_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM sistemas_talla WHERE id = p_sistema_talla_id AND activo = true) THEN
            v_error_hint := 'inactive_catalog';
            RAISE EXCEPTION 'El sistema de tallas seleccionado está inactivo';
        END IF;

        -- Actualizar todos los campos
        UPDATE productos_maestros
        SET marca_id = COALESCE(p_marca_id, marca_id),
            material_id = COALESCE(p_material_id, material_id),
            tipo_id = COALESCE(p_tipo_id, tipo_id),
            sistema_talla_id = COALESCE(p_sistema_talla_id, sistema_talla_id),
            descripcion = COALESCE(p_descripcion, descripcion),
            updated_at = NOW()
        WHERE id = p_producto_id;
    END IF;

    -- Devolver producto completo actualizado (mismo formato que listar_productos_maestros)
    RETURN json_build_object(
        'success', true,
        'data', (
            SELECT json_build_object(
                'id', pm.id,
                'marca_id', pm.marca_id,
                'marca_nombre', ma.nombre,
                'marca_codigo', ma.codigo,
                'material_id', pm.material_id,
                'material_nombre', mat.nombre,
                'material_codigo', mat.codigo,
                'tipo_id', pm.tipo_id,
                'tipo_nombre', t.nombre,
                'tipo_codigo', t.codigo,
                'sistema_talla_id', pm.sistema_talla_id,
                'sistema_talla_nombre', st.nombre,
                'sistema_talla_tipo', st.tipo_sistema,
                'descripcion', pm.descripcion,
                'activo', pm.activo,
                'articulos_activos', 0,
                'articulos_totales', 0,
                'tiene_catalogos_inactivos', (
                    NOT ma.activo OR NOT mat.activo OR NOT t.activo OR NOT st.activo
                ),
                'nombre_completo', ma.nombre || ' - ' || t.nombre || ' - ' || mat.nombre || ' - ' || st.nombre,
                'created_at', pm.created_at,
                'updated_at', pm.updated_at
            )
            FROM productos_maestros pm
            INNER JOIN marcas ma ON pm.marca_id = ma.id
            INNER JOIN materiales mat ON pm.material_id = mat.id
            INNER JOIN tipos t ON pm.tipo_id = t.id
            INNER JOIN sistemas_talla st ON pm.sistema_talla_id = st.id
            WHERE pm.id = p_producto_id
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

COMMENT ON FUNCTION editar_producto_maestro IS 'E002-HU-006: Edita producto maestro con restricciones según artículos derivados - CA-013, RN-044';

-- Función 5: eliminar_producto_maestro
CREATE OR REPLACE FUNCTION eliminar_producto_maestro(
    p_producto_id UUID
) RETURNS JSON AS $$
DECLARE
    v_articulos_totales INTEGER := 0;
    v_error_hint TEXT;
BEGIN
    -- Validar producto existe
    IF NOT EXISTS(SELECT 1 FROM productos_maestros WHERE id = p_producto_id) THEN
        v_error_hint := 'producto_not_found';
        RAISE EXCEPTION 'Producto maestro no encontrado';
    END IF;

    -- Contar artículos derivados (preparado para HU-007)
    -- En el futuro: SELECT COUNT(*) INTO v_articulos_totales FROM articulos WHERE producto_maestro_id = p_producto_id;

    -- Validación RN-043: Solo eliminar si no tiene artículos
    IF v_articulos_totales > 0 THEN
        v_error_hint := 'has_derived_articles';
        RAISE EXCEPTION 'No se puede eliminar. Este producto tiene % artículo% derivado%. Solo puede desactivarlo',
            v_articulos_totales,
            CASE WHEN v_articulos_totales = 1 THEN '' ELSE 's' END,
            CASE WHEN v_articulos_totales = 1 THEN '' ELSE 's' END;
    END IF;

    -- Eliminar permanentemente
    DELETE FROM productos_maestros WHERE id = p_producto_id;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', p_producto_id
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

COMMENT ON FUNCTION eliminar_producto_maestro IS 'E002-HU-006: Elimina permanentemente producto maestro solo si no tiene artículos - CA-014, RN-043';

-- Función 6: desactivar_producto_maestro
CREATE OR REPLACE FUNCTION desactivar_producto_maestro(
    p_producto_id UUID,
    p_desactivar_articulos BOOLEAN DEFAULT false
) RETURNS JSON AS $$
DECLARE
    v_articulos_activos_afectados INTEGER := 0;
    v_error_hint TEXT;
BEGIN
    -- Validar producto existe
    IF NOT EXISTS(SELECT 1 FROM productos_maestros WHERE id = p_producto_id) THEN
        v_error_hint := 'producto_not_found';
        RAISE EXCEPTION 'Producto maestro no encontrado';
    END IF;

    -- Desactivar producto maestro
    UPDATE productos_maestros
    SET activo = false,
        updated_at = NOW()
    WHERE id = p_producto_id;

    -- Si se solicita desactivar artículos en cascada (RN-042)
    IF p_desactivar_articulos THEN
        -- En el futuro: UPDATE articulos SET activo = false WHERE producto_maestro_id = p_producto_id AND activo = true;
        -- En el futuro: GET DIAGNOSTICS v_articulos_activos_afectados = ROW_COUNT;
        v_articulos_activos_afectados := 0;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', p_producto_id,
            'articulos_activos_afectados', v_articulos_activos_afectados
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

COMMENT ON FUNCTION desactivar_producto_maestro IS 'E002-HU-006: Desactiva producto maestro y opcionalmente artículos derivados - CA-014, RN-042';

-- Función 7: reactivar_producto_maestro
CREATE OR REPLACE FUNCTION reactivar_producto_maestro(
    p_producto_id UUID
) RETURNS JSON AS $$
DECLARE
    v_marca_activo BOOLEAN;
    v_material_activo BOOLEAN;
    v_tipo_activo BOOLEAN;
    v_sistema_activo BOOLEAN;
    v_marca_nombre TEXT;
    v_material_nombre TEXT;
    v_tipo_nombre TEXT;
    v_sistema_nombre TEXT;
    v_error_hint TEXT;
BEGIN
    -- Validar producto existe
    IF NOT EXISTS(SELECT 1 FROM productos_maestros WHERE id = p_producto_id) THEN
        v_error_hint := 'producto_not_found';
        RAISE EXCEPTION 'Producto maestro no encontrado';
    END IF;

    -- Validar que todos los catálogos estén activos (RN-038)
    SELECT ma.activo, ma.nombre, mat.activo, mat.nombre, t.activo, t.nombre, st.activo, st.nombre
    INTO v_marca_activo, v_marca_nombre, v_material_activo, v_material_nombre,
         v_tipo_activo, v_tipo_nombre, v_sistema_activo, v_sistema_nombre
    FROM productos_maestros pm
    INNER JOIN marcas ma ON pm.marca_id = ma.id
    INNER JOIN materiales mat ON pm.material_id = mat.id
    INNER JOIN tipos t ON pm.tipo_id = t.id
    INNER JOIN sistemas_talla st ON pm.sistema_talla_id = st.id
    WHERE pm.id = p_producto_id;

    IF v_marca_activo = false THEN
        v_error_hint := 'inactive_catalog';
        RAISE EXCEPTION 'La marca "%" está inactiva. Reactívela primero', v_marca_nombre;
    END IF;

    IF v_material_activo = false THEN
        v_error_hint := 'inactive_catalog';
        RAISE EXCEPTION 'El material "%" está inactivo. Reactívelo primero', v_material_nombre;
    END IF;

    IF v_tipo_activo = false THEN
        v_error_hint := 'inactive_catalog';
        RAISE EXCEPTION 'El tipo "%" está inactivo. Reactívelo primero', v_tipo_nombre;
    END IF;

    IF v_sistema_activo = false THEN
        v_error_hint := 'inactive_catalog';
        RAISE EXCEPTION 'El sistema de tallas "%" está inactivo. Reactívelo primero', v_sistema_nombre;
    END IF;

    -- Reactivar producto maestro
    UPDATE productos_maestros
    SET activo = true,
        updated_at = NOW()
    WHERE id = p_producto_id;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', p_producto_id
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

COMMENT ON FUNCTION reactivar_producto_maestro IS 'E002-HU-006: Reactiva producto maestro solo si todos los catálogos están activos - CA-016, RN-038';


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
-- ARTICULOS (E002-HU-007):
--   - generar_sku, validar_sku_unico, crear_articulo
--   - listar_articulos, obtener_articulo, editar_articulo
--   - eliminar_articulo, desactivar_articulo

-- ============================================
-- SECCIÓN 9: FUNCIONES DE ARTÍCULOS (E002-HU-007)
-- ============================================

-- HU-007: generar_sku - Genera SKU automático con formato MARCA-TIPO-MATERIAL-TALLA-COLOR1-COLOR2-COLOR3
CREATE OR REPLACE FUNCTION generar_sku(
    p_producto_maestro_id UUID,
    p_colores_ids UUID[]
)
RETURNS JSON AS $$
DECLARE
    v_marca_codigo TEXT;
    v_tipo_codigo TEXT;
    v_material_codigo TEXT;
    v_talla_codigo TEXT;
    v_colores_codigos TEXT[];
    v_color_id UUID;
    v_sku TEXT;
    v_error_hint TEXT;
BEGIN
    -- Validar producto maestro existe
    IF NOT EXISTS (SELECT 1 FROM productos_maestros WHERE id = p_producto_maestro_id) THEN
        v_error_hint := 'producto_maestro_not_found';
        RAISE EXCEPTION 'Producto maestro no encontrado';
    END IF;

    -- Validar colores no vacío
    IF array_length(p_colores_ids, 1) IS NULL OR array_length(p_colores_ids, 1) = 0 THEN
        v_error_hint := 'colores_required';
        RAISE EXCEPTION 'Debe especificar al menos un color';
    END IF;

    -- Obtener códigos de catálogos del producto maestro
    SELECT
        ma.codigo,
        ti.codigo,
        mt.codigo,
        CASE
            WHEN st.tipo_sistema = 'UNICA' THEN 'UNI'
            ELSE COALESCE(
                (SELECT valor FROM valores_talla WHERE sistema_talla_id = st.id AND activo = true ORDER BY orden LIMIT 1),
                'UNI'
            )
        END
    INTO v_marca_codigo, v_tipo_codigo, v_material_codigo, v_talla_codigo
    FROM productos_maestros pm
    INNER JOIN marcas ma ON pm.marca_id = ma.id
    INNER JOIN tipos ti ON pm.tipo_id = ti.id
    INNER JOIN materiales mt ON pm.material_id = mt.id
    INNER JOIN sistemas_talla st ON pm.sistema_talla_id = st.id
    WHERE pm.id = p_producto_maestro_id;

    -- Validar que todos los códigos existan (RN-057)
    IF v_marca_codigo IS NULL OR v_tipo_codigo IS NULL OR v_material_codigo IS NULL THEN
        v_error_hint := 'missing_catalog_codes';
        RAISE EXCEPTION 'Faltan códigos en los catálogos relacionados';
    END IF;

    -- Obtener códigos de colores en orden (RN-049)
    v_colores_codigos := ARRAY[]::TEXT[];
    FOREACH v_color_id IN ARRAY p_colores_ids
    LOOP
        -- Extraer los primeros 3 caracteres del nombre del color en mayúsculas
        DECLARE
            v_color_codigo TEXT;
        BEGIN
            SELECT UPPER(SUBSTRING(nombre FROM 1 FOR 3))
            INTO v_color_codigo
            FROM colores
            WHERE id = v_color_id AND activo = true;

            IF v_color_codigo IS NULL THEN
                v_error_hint := 'color_not_found';
                RAISE EXCEPTION 'Color no encontrado o inactivo: %', v_color_id;
            END IF;

            v_colores_codigos := array_append(v_colores_codigos, v_color_codigo);
        END;
    END LOOP;

    -- Construir SKU con formato: MARCA-TIPO-MATERIAL-TALLA-COLOR1-COLOR2-COLOR3
    v_sku := UPPER(v_marca_codigo || '-' || v_tipo_codigo || '-' || v_material_codigo || '-' || v_talla_codigo);

    -- Agregar códigos de colores
    FOR i IN 1..array_length(v_colores_codigos, 1)
    LOOP
        v_sku := v_sku || '-' || v_colores_codigos[i];
    END LOOP;

    -- Retornar SKU generado
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'sku', v_sku
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

COMMENT ON FUNCTION generar_sku IS 'E002-HU-007: Genera SKU único con formato MARCA-TIPO-MATERIAL-TALLA-COLOR1-COLOR2-COLOR3 (RN-053)';

-- HU-007: validar_sku_unico - Verifica si SKU ya existe en el sistema
CREATE OR REPLACE FUNCTION validar_sku_unico(
    p_sku TEXT,
    p_articulo_id UUID DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_exists BOOLEAN;
    v_error_hint TEXT;
BEGIN
    -- Validar SKU no vacío
    IF p_sku IS NULL OR LENGTH(TRIM(p_sku)) = 0 THEN
        v_error_hint := 'sku_required';
        RAISE EXCEPTION 'SKU es requerido';
    END IF;

    -- Verificar si existe (excluyendo el artículo actual si se está editando)
    IF p_articulo_id IS NULL THEN
        SELECT EXISTS(SELECT 1 FROM articulos WHERE sku = UPPER(p_sku)) INTO v_exists;
    ELSE
        SELECT EXISTS(SELECT 1 FROM articulos WHERE sku = UPPER(p_sku) AND id != p_articulo_id) INTO v_exists;
    END IF;

    -- Retornar resultado
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'es_unico', NOT v_exists,
            'existe', v_exists
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

COMMENT ON FUNCTION validar_sku_unico IS 'E002-HU-007: Valida unicidad de SKU en el sistema (RN-047)';

-- HU-007: crear_articulo - Crea artículo especializado con colores y SKU
CREATE OR REPLACE FUNCTION crear_articulo(
    p_producto_maestro_id UUID,
    p_colores_ids UUID[],
    p_precio DECIMAL
)
RETURNS JSON AS $$
DECLARE
    v_articulo_id UUID;
    v_sku TEXT;
    v_tipo_coloracion VARCHAR(10);
    v_cantidad_colores INTEGER;
    v_producto_maestro_activo BOOLEAN;
    v_catalogo_inactivo TEXT;
    v_color_inactivo BOOLEAN;
    v_sku_generado JSON;
    v_error_hint TEXT;
BEGIN
    -- Validar cantidad de colores (RN-048)
    v_cantidad_colores := array_length(p_colores_ids, 1);

    IF v_cantidad_colores IS NULL OR v_cantidad_colores = 0 THEN
        v_error_hint := 'colores_required';
        RAISE EXCEPTION 'Debe seleccionar al menos un color';
    END IF;

    IF v_cantidad_colores = 1 THEN
        v_tipo_coloracion := 'unicolor';
    ELSIF v_cantidad_colores = 2 THEN
        v_tipo_coloracion := 'bicolor';
    ELSIF v_cantidad_colores = 3 THEN
        v_tipo_coloracion := 'tricolor';
    ELSE
        v_error_hint := 'invalid_color_count';
        RAISE EXCEPTION 'Solo se permiten 1, 2 o 3 colores. Cantidad recibida: %', v_cantidad_colores;
    END IF;

    -- Validar producto maestro activo y con catálogos activos (RN-050)
    SELECT pm.activo INTO v_producto_maestro_activo
    FROM productos_maestros pm
    WHERE pm.id = p_producto_maestro_id;

    IF v_producto_maestro_activo IS NULL THEN
        v_error_hint := 'producto_maestro_not_found';
        RAISE EXCEPTION 'Producto maestro no encontrado';
    END IF;

    IF NOT v_producto_maestro_activo THEN
        v_error_hint := 'producto_maestro_inactive';
        RAISE EXCEPTION 'Producto maestro está inactivo';
    END IF;

    -- Validar catálogos activos del producto maestro
    SELECT
        CASE
            WHEN NOT ma.activo THEN 'marca'
            WHEN NOT mt.activo THEN 'material'
            WHEN NOT ti.activo THEN 'tipo'
            WHEN NOT st.activo THEN 'sistema_talla'
            ELSE NULL
        END
    INTO v_catalogo_inactivo
    FROM productos_maestros pm
    INNER JOIN marcas ma ON pm.marca_id = ma.id
    INNER JOIN materiales mt ON pm.material_id = mt.id
    INNER JOIN tipos ti ON pm.tipo_id = ti.id
    INNER JOIN sistemas_talla st ON pm.sistema_talla_id = st.id
    WHERE pm.id = p_producto_maestro_id;

    IF v_catalogo_inactivo IS NOT NULL THEN
        v_error_hint := 'catalog_inactive';
        RAISE EXCEPTION 'El catálogo % del producto maestro está inactivo', v_catalogo_inactivo;
    END IF;

    -- Validar colores activos (RN-051)
    SELECT EXISTS(
        SELECT 1 FROM unnest(p_colores_ids) AS color_id
        WHERE NOT EXISTS(SELECT 1 FROM colores WHERE id = color_id AND activo = true)
    ) INTO v_color_inactivo;

    IF v_color_inactivo THEN
        v_error_hint := 'color_inactive';
        RAISE EXCEPTION 'Uno o más colores seleccionados están inactivos';
    END IF;

    -- Validar precio mínimo (RN-052)
    IF p_precio IS NULL OR p_precio < 0.01 THEN
        v_error_hint := 'invalid_price';
        RAISE EXCEPTION 'El precio debe ser mayor o igual a 0.01';
    END IF;

    -- Generar SKU automático (RN-053)
    SELECT generar_sku(p_producto_maestro_id, p_colores_ids) INTO v_sku_generado;

    IF (v_sku_generado->>'success')::BOOLEAN = false THEN
        v_error_hint := 'sku_generation_failed';
        RAISE EXCEPTION 'Error al generar SKU: %', v_sku_generado->'error'->>'message';
    END IF;

    v_sku := v_sku_generado->'data'->>'sku';

    -- Validar SKU único (RN-047)
    IF EXISTS(SELECT 1 FROM articulos WHERE sku = v_sku) THEN
        v_error_hint := 'duplicate_sku';
        RAISE EXCEPTION 'Ya existe un artículo con este SKU: %', v_sku;
    END IF;

    -- Insertar artículo
    INSERT INTO articulos (
        producto_maestro_id,
        sku,
        tipo_coloracion,
        colores_ids,
        precio,
        activo
    ) VALUES (
        p_producto_maestro_id,
        v_sku,
        v_tipo_coloracion,
        p_colores_ids,
        p_precio,
        true
    )
    RETURNING id INTO v_articulo_id;

    -- Retornar artículo creado con detalles
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', v_articulo_id,
            'sku', v_sku,
            'tipo_coloracion', v_tipo_coloracion,
            'precio', p_precio,
            'activo', true
        ),
        'message', 'Artículo creado exitosamente'
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

COMMENT ON FUNCTION crear_articulo IS 'E002-HU-007: Crea artículo con validaciones RN-047 a RN-053';

-- HU-007: listar_articulos - Lista artículos con filtros y joins a catálogos
CREATE OR REPLACE FUNCTION listar_articulos(
    p_producto_maestro_id UUID DEFAULT NULL,
    p_marca_id UUID DEFAULT NULL,
    p_tipo_id UUID DEFAULT NULL,
    p_material_id UUID DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL,
    p_search TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS JSON AS $$
DECLARE
    v_articulos JSON;
    v_total INTEGER;
    v_error_hint TEXT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*)
    INTO v_total
    FROM articulos a
    INNER JOIN productos_maestros pm ON a.producto_maestro_id = pm.id
    INNER JOIN marcas ma ON pm.marca_id = ma.id
    INNER JOIN materiales mt ON pm.material_id = mt.id
    INNER JOIN tipos ti ON pm.tipo_id = ti.id
    INNER JOIN sistemas_talla st ON pm.sistema_talla_id = st.id
    WHERE
        (p_producto_maestro_id IS NULL OR a.producto_maestro_id = p_producto_maestro_id) AND
        (p_marca_id IS NULL OR pm.marca_id = p_marca_id) AND
        (p_tipo_id IS NULL OR pm.tipo_id = p_tipo_id) AND
        (p_material_id IS NULL OR pm.material_id = p_material_id) AND
        (p_activo IS NULL OR a.activo = p_activo) AND
        (p_search IS NULL OR a.sku ILIKE '%' || p_search || '%');

    -- Obtener artículos con detalles
    SELECT json_agg(
        json_build_object(
            'id', a.id,
            'sku', a.sku,
            'tipo_coloracion', a.tipo_coloracion,
            'precio', a.precio,
            'activo', a.activo,
            'created_at', a.created_at,
            'producto_maestro', json_build_object(
                'id', pm.id,
                'marca', json_build_object('id', ma.id, 'nombre', ma.nombre, 'codigo', ma.codigo),
                'material', json_build_object('id', mt.id, 'nombre', mt.nombre, 'codigo', mt.codigo),
                'tipo', json_build_object('id', ti.id, 'nombre', ti.nombre, 'codigo', ti.codigo),
                'sistema_talla', json_build_object('id', st.id, 'nombre', st.nombre, 'tipo_sistema', st.tipo_sistema)
            ),
            'colores', (
                SELECT json_agg(
                    json_build_object(
                        'id', c.id,
                        'nombre', c.nombre,
                        'codigos_hex', c.codigos_hex,
                        'tipo_color', c.tipo_color,
                        'activo', c.activo
                    ) ORDER BY array_position(a.colores_ids, c.id)
                )
                FROM colores c
                WHERE c.id = ANY(a.colores_ids)
            )
        ) ORDER BY a.created_at DESC
    )
    INTO v_articulos
    FROM articulos a
    INNER JOIN productos_maestros pm ON a.producto_maestro_id = pm.id
    INNER JOIN marcas ma ON pm.marca_id = ma.id
    INNER JOIN materiales mt ON pm.material_id = mt.id
    INNER JOIN tipos ti ON pm.tipo_id = ti.id
    INNER JOIN sistemas_talla st ON pm.sistema_talla_id = st.id
    WHERE
        (p_producto_maestro_id IS NULL OR a.producto_maestro_id = p_producto_maestro_id) AND
        (p_marca_id IS NULL OR pm.marca_id = p_marca_id) AND
        (p_tipo_id IS NULL OR pm.tipo_id = p_tipo_id) AND
        (p_material_id IS NULL OR pm.material_id = p_material_id) AND
        (p_activo IS NULL OR a.activo = p_activo) AND
        (p_search IS NULL OR a.sku ILIKE '%' || p_search || '%')
    LIMIT p_limit
    OFFSET p_offset;

    -- Retornar resultado paginado
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'articulos', COALESCE(v_articulos, '[]'::json),
            'total', v_total,
            'limit', p_limit,
            'offset', p_offset
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

COMMENT ON FUNCTION listar_articulos IS 'E002-HU-007: Lista artículos con joins a productos_maestros y catálogos';

-- HU-007: obtener_articulo - Obtiene detalle completo de un artículo
CREATE OR REPLACE FUNCTION obtener_articulo(
    p_articulo_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_articulo JSON;
    v_error_hint TEXT;
BEGIN
    -- Validar artículo existe
    IF NOT EXISTS (SELECT 1 FROM articulos WHERE id = p_articulo_id) THEN
        v_error_hint := 'articulo_not_found';
        RAISE EXCEPTION 'Artículo no encontrado';
    END IF;

    -- Obtener artículo con todos los detalles
    SELECT json_build_object(
        'id', a.id,
        'sku', a.sku,
        'tipo_coloracion', a.tipo_coloracion,
        'precio', a.precio,
        'activo', a.activo,
        'created_at', a.created_at,
        'updated_at', a.updated_at,
        'producto_maestro', json_build_object(
            'id', pm.id,
            'descripcion', pm.descripcion,
            'activo', pm.activo,
            'marca', json_build_object(
                'id', ma.id,
                'nombre', ma.nombre,
                'codigo', ma.codigo,
                'activo', ma.activo
            ),
            'material', json_build_object(
                'id', mt.id,
                'nombre', mt.nombre,
                'codigo', mt.codigo,
                'descripcion', mt.descripcion,
                'activo', mt.activo
            ),
            'tipo', json_build_object(
                'id', ti.id,
                'nombre', ti.nombre,
                'codigo', ti.codigo,
                'descripcion', ti.descripcion,
                'imagen_url', ti.imagen_url,
                'activo', ti.activo
            ),
            'sistema_talla', json_build_object(
                'id', st.id,
                'nombre', st.nombre,
                'tipo_sistema', st.tipo_sistema,
                'descripcion', st.descripcion,
                'activo', st.activo,
                'valores', (
                    SELECT json_agg(
                        json_build_object(
                            'id', vt.id,
                            'valor', vt.valor,
                            'orden', vt.orden,
                            'activo', vt.activo
                        ) ORDER BY vt.orden
                    )
                    FROM valores_talla vt
                    WHERE vt.sistema_talla_id = st.id
                )
            )
        ),
        'colores', (
            SELECT json_agg(
                json_build_object(
                    'id', c.id,
                    'nombre', c.nombre,
                    'codigos_hex', c.codigos_hex,
                    'tipo_color', c.tipo_color,
                    'activo', c.activo
                ) ORDER BY array_position(a.colores_ids, c.id)
            )
            FROM colores c
            WHERE c.id = ANY(a.colores_ids)
        )
    )
    INTO v_articulo
    FROM articulos a
    INNER JOIN productos_maestros pm ON a.producto_maestro_id = pm.id
    INNER JOIN marcas ma ON pm.marca_id = ma.id
    INNER JOIN materiales mt ON pm.material_id = mt.id
    INNER JOIN tipos ti ON pm.tipo_id = ti.id
    INNER JOIN sistemas_talla st ON pm.sistema_talla_id = st.id
    WHERE a.id = p_articulo_id;

    -- Retornar artículo
    RETURN json_build_object(
        'success', true,
        'data', v_articulo
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

COMMENT ON FUNCTION obtener_articulo IS 'E002-HU-007: Obtiene detalle completo de un artículo con todos los datos relacionados';

-- HU-007: editar_articulo - Edita artículo con restricciones según stock
CREATE OR REPLACE FUNCTION editar_articulo(
    p_articulo_id UUID,
    p_precio DECIMAL DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_articulo_actual RECORD;
    v_tiene_stock BOOLEAN := false;
    v_error_hint TEXT;
BEGIN
    -- Validar artículo existe
    SELECT * INTO v_articulo_actual
    FROM articulos
    WHERE id = p_articulo_id;

    IF v_articulo_actual.id IS NULL THEN
        v_error_hint := 'articulo_not_found';
        RAISE EXCEPTION 'Artículo no encontrado';
    END IF;

    -- TODO: Verificar stock cuando se implemente HU-008
    -- Por ahora asumimos stock = 0
    v_tiene_stock := false;

    -- Validar restricciones de edición (RN-055)
    -- Si tiene stock > 0, solo permitir editar precio y estado
    -- Esta función ya está limitada a esos campos por diseño

    -- Actualizar campos permitidos
    UPDATE articulos
    SET
        precio = COALESCE(p_precio, precio),
        activo = COALESCE(p_activo, activo),
        updated_at = NOW()
    WHERE id = p_articulo_id;

    -- Retornar artículo actualizado
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', p_articulo_id,
            'precio', COALESCE(p_precio, v_articulo_actual.precio),
            'activo', COALESCE(p_activo, v_articulo_actual.activo),
            'updated_at', NOW()
        ),
        'message', 'Artículo actualizado exitosamente'
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

COMMENT ON FUNCTION editar_articulo IS 'E002-HU-007: Edita precio y estado de artículo con restricciones RN-055 (solo permite editar precio/activo)';

-- HU-007: eliminar_articulo - Elimina artículo solo si stock = 0
CREATE OR REPLACE FUNCTION eliminar_articulo(
    p_articulo_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_tiene_stock BOOLEAN := false;
    v_articulo_exists BOOLEAN;
    v_error_hint TEXT;
BEGIN
    -- Validar artículo existe
    SELECT EXISTS(SELECT 1 FROM articulos WHERE id = p_articulo_id) INTO v_articulo_exists;

    IF NOT v_articulo_exists THEN
        v_error_hint := 'articulo_not_found';
        RAISE EXCEPTION 'Artículo no encontrado';
    END IF;

    -- TODO: Verificar stock cuando se implemente HU-008
    -- Por ahora asumimos stock = 0
    v_tiene_stock := false;

    -- Validar stock = 0 (RN-056)
    IF v_tiene_stock THEN
        v_error_hint := 'has_stock';
        RAISE EXCEPTION 'No se puede eliminar. El artículo tiene stock en tiendas. Solo puede desactivarlo';
    END IF;

    -- Eliminar artículo permanentemente
    DELETE FROM articulos WHERE id = p_articulo_id;

    -- Retornar confirmación
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', p_articulo_id,
            'deleted', true
        ),
        'message', 'Artículo eliminado permanentemente'
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

COMMENT ON FUNCTION eliminar_articulo IS 'E002-HU-007: Elimina artículo permanentemente solo si stock = 0 (RN-056)';

-- HU-007: desactivar_articulo - Desactiva artículo (soft delete)
CREATE OR REPLACE FUNCTION desactivar_articulo(
    p_articulo_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_articulo_exists BOOLEAN;
    v_error_hint TEXT;
BEGIN
    -- Validar artículo existe
    SELECT EXISTS(SELECT 1 FROM articulos WHERE id = p_articulo_id) INTO v_articulo_exists;

    IF NOT v_articulo_exists THEN
        v_error_hint := 'articulo_not_found';
        RAISE EXCEPTION 'Artículo no encontrado';
    END IF;

    -- Desactivar artículo (soft delete)
    UPDATE articulos
    SET activo = false, updated_at = NOW()
    WHERE id = p_articulo_id;

    -- Retornar confirmación
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', p_articulo_id,
            'activo', false
        ),
        'message', 'Artículo desactivado exitosamente'
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

COMMENT ON FUNCTION desactivar_articulo IS 'E002-HU-007: Desactiva artículo (soft delete) sin eliminar datos (RN-054, RN-056)';

-- ============================================
-- HU-008: Wizard Producto Maestro - Modo Experto
-- ============================================

-- HU-008: generar_sku_simple - Helper function para generar SKU único (versión simplificada)
CREATE OR REPLACE FUNCTION generar_sku_simple(
    p_marca_codigo TEXT,
    p_material_codigo TEXT,
    p_tipo_codigo TEXT,
    p_colores_nombres TEXT[]
)
RETURNS TEXT AS $$
DECLARE
    v_sku TEXT;
    v_color_codigo TEXT;
    v_color_nombre TEXT;
BEGIN
    -- Iniciar con marca-material-tipo
    v_sku := UPPER(p_marca_codigo || '-' || p_material_codigo || '-' || p_tipo_codigo);

    -- Agregar códigos de colores (primeras 3 letras en mayúsculas)
    FOREACH v_color_nombre IN ARRAY p_colores_nombres
    LOOP
        -- Tomar primeras 3 letras del nombre del color
        v_color_codigo := UPPER(LEFT(TRIM(v_color_nombre), 3));
        v_sku := v_sku || '-' || v_color_codigo;
    END LOOP;

    RETURN v_sku;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION generar_sku_simple IS 'E002-HU-008: Genera SKU único con formato MARCA-MATERIAL-TIPO-COLOR1-COLOR2-COLOR3 (RN-008-006)';

-- HU-008: crear_producto_completo - Crea producto maestro + artículos de forma transaccional
CREATE OR REPLACE FUNCTION crear_producto_completo(
    p_producto_maestro JSONB,
    p_articulos JSONB[]
)
RETURNS JSON AS $$
DECLARE
    v_producto_maestro_id UUID;
    v_marca_id UUID;
    v_material_id UUID;
    v_tipo_id UUID;
    v_sistema_talla_id UUID;
    v_descripcion TEXT;

    v_marca_record RECORD;
    v_material_record RECORD;
    v_tipo_record RECORD;
    v_sistema_talla_record RECORD;

    v_articulo JSONB;
    v_colores_ids UUID[];
    v_precio DECIMAL(10, 2);
    v_tipo_coloracion TEXT;
    v_sku TEXT;
    v_colores_nombres TEXT[] := ARRAY[]::TEXT[];
    v_color_id UUID;
    v_color_nombre TEXT;
    v_articulo_id UUID;

    v_articulos_creados INTEGER := 0;
    v_skus_generados TEXT[] := ARRAY[]::TEXT[];
    v_error_hint TEXT;
BEGIN
    -- Validar permisos: Solo ADMIN puede crear
    IF NOT EXISTS (
        SELECT 1 FROM auth.users
        WHERE id = auth.uid()
        AND raw_user_meta_data->>'rol' = 'ADMIN'
    ) THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo administradores pueden crear productos';
    END IF;

    -- Extraer datos del producto maestro
    v_marca_id := (p_producto_maestro->>'marca_id')::UUID;
    v_material_id := (p_producto_maestro->>'material_id')::UUID;
    v_tipo_id := (p_producto_maestro->>'tipo_id')::UUID;
    v_sistema_talla_id := (p_producto_maestro->>'sistema_talla_id')::UUID;
    v_descripcion := p_producto_maestro->>'descripcion';

    -- Validar parámetros requeridos
    IF v_marca_id IS NULL OR v_material_id IS NULL OR v_tipo_id IS NULL OR v_sistema_talla_id IS NULL THEN
        v_error_hint := 'missing_param';
        RAISE EXCEPTION 'Marca, Material, Tipo y Sistema de Talla son obligatorios';
    END IF;

    -- Validar que catálogos existen y están activos (RN-008-006)
    SELECT * INTO v_marca_record FROM marcas WHERE id = v_marca_id AND activo = true;
    IF v_marca_record.id IS NULL THEN
        v_error_hint := 'invalid_catalog';
        RAISE EXCEPTION 'Marca no existe o está inactiva';
    END IF;

    SELECT * INTO v_material_record FROM materiales WHERE id = v_material_id AND activo = true;
    IF v_material_record.id IS NULL THEN
        v_error_hint := 'invalid_catalog';
        RAISE EXCEPTION 'Material no existe o está inactivo';
    END IF;

    SELECT * INTO v_tipo_record FROM tipos WHERE id = v_tipo_id AND activo = true;
    IF v_tipo_record.id IS NULL THEN
        v_error_hint := 'invalid_catalog';
        RAISE EXCEPTION 'Tipo no existe o está inactivo';
    END IF;

    SELECT * INTO v_sistema_talla_record FROM sistemas_talla WHERE id = v_sistema_talla_id AND activo = true;
    IF v_sistema_talla_record.id IS NULL THEN
        v_error_hint := 'invalid_catalog';
        RAISE EXCEPTION 'Sistema de Talla no existe o está inactivo';
    END IF;

    -- Crear producto maestro (RN-008-004: constraint verifica combinación única)
    BEGIN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_talla_id, v_descripcion)
        RETURNING id INTO v_producto_maestro_id;
    EXCEPTION
        WHEN unique_violation THEN
            v_error_hint := 'duplicate_producto';
            RAISE EXCEPTION 'Esta combinación de producto ya existe (Marca + Material + Tipo + Sistema Talla)';
    END;

    -- Crear artículos (si hay)
    IF p_articulos IS NOT NULL AND array_length(p_articulos, 1) > 0 THEN
        FOREACH v_articulo IN ARRAY p_articulos
        LOOP
            -- Extraer datos del artículo
            v_colores_ids := ARRAY(
                SELECT jsonb_array_elements_text(v_articulo->'colores_ids')::UUID
            );
            v_precio := (v_articulo->>'precio')::DECIMAL(10, 2);

            -- Validar precio
            IF v_precio IS NULL OR v_precio <= 0 THEN
                v_error_hint := 'missing_param';
                RAISE EXCEPTION 'El precio debe ser mayor a 0';
            END IF;

            -- Validar colores (1-3)
            IF array_length(v_colores_ids, 1) IS NULL OR
               array_length(v_colores_ids, 1) < 1 OR
               array_length(v_colores_ids, 1) > 3 THEN
                v_error_hint := 'invalid_color';
                RAISE EXCEPTION 'Debe seleccionar entre 1 y 3 colores';
            END IF;

            -- Determinar tipo_coloracion según cantidad de colores
            CASE array_length(v_colores_ids, 1)
                WHEN 1 THEN v_tipo_coloracion := 'unicolor';
                WHEN 2 THEN v_tipo_coloracion := 'bicolor';
                WHEN 3 THEN v_tipo_coloracion := 'tricolor';
            END CASE;

            -- Validar que colores existen y están activos (RN-008-005)
            v_colores_nombres := ARRAY[]::TEXT[];
            FOREACH v_color_id IN ARRAY v_colores_ids
            LOOP
                SELECT nombre INTO v_color_nombre FROM colores WHERE id = v_color_id AND activo = true;

                IF v_color_nombre IS NULL THEN
                    v_error_hint := 'invalid_color';
                    RAISE EXCEPTION 'Uno o más colores no existen o están inactivos';
                END IF;

                v_colores_nombres := array_append(v_colores_nombres, v_color_nombre);
            END LOOP;

            -- Generar SKU (RN-008-006)
            v_sku := generar_sku_simple(
                v_marca_record.codigo,
                v_material_record.codigo,
                v_tipo_record.codigo,
                v_colores_nombres
            );

            -- Validar SKU único
            IF EXISTS (SELECT 1 FROM articulos WHERE sku = v_sku) THEN
                v_error_hint := 'duplicate_sku';
                RAISE EXCEPTION 'Ya existe un artículo con el SKU: %', v_sku;
            END IF;

            -- Crear artículo
            INSERT INTO articulos (
                producto_maestro_id,
                sku,
                tipo_coloracion,
                colores_ids,
                precio
            )
            VALUES (
                v_producto_maestro_id,
                v_sku,
                v_tipo_coloracion,
                v_colores_ids,
                v_precio
            )
            RETURNING id INTO v_articulo_id;

            -- Incrementar contador y agregar SKU a lista
            v_articulos_creados := v_articulos_creados + 1;
            v_skus_generados := array_append(v_skus_generados, v_sku);
        END LOOP;
    END IF;

    -- Retornar resultado exitoso
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'producto_maestro_id', v_producto_maestro_id,
            'articulos_creados', v_articulos_creados,
            'skus_generados', v_skus_generados
        ),
        'message', CASE
            WHEN v_articulos_creados = 0 THEN 'Producto maestro creado exitosamente (sin artículos)'
            ELSE 'Producto maestro creado con ' || v_articulos_creados || ' artículo(s)'
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

COMMENT ON FUNCTION crear_producto_completo IS 'E002-HU-008: Crea producto maestro + artículos de forma transaccional con validaciones RN-008-001 a RN-008-006';

COMMIT;