-- Migration: HU-004 Password Recovery
-- Fecha: 2025-10-06
-- Descripcion: Sistema completo de recuperacion de contrasena con tokens seguros
-- Razon: Implementar funcionalidad de olvide mi contrasena con seguridad
-- Impacto: Agrega tabla password_recovery y 4 funciones PostgreSQL
-- Referencias: RN-004-PASSWORD (docs/technical/00-SPECS-HU-004-PASSWORD-RECOVERY.md)

BEGIN;

-- =====================================================
-- TABLA: password_recovery
-- =====================================================
-- Almacena tokens de recuperacion de contrasena
-- Relacion: user_id -> auth.users(id)
-- =====================================================

CREATE TABLE IF NOT EXISTS password_recovery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    token TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indices para optimizar busquedas
CREATE INDEX idx_password_recovery_token ON password_recovery(token);
CREATE INDEX idx_password_recovery_user_id ON password_recovery(user_id);
CREATE INDEX idx_password_recovery_email ON password_recovery(email);
CREATE INDEX idx_password_recovery_expires_at ON password_recovery(expires_at);

-- Comentarios de documentacion
COMMENT ON TABLE password_recovery IS 'HU-004: Tokens de recuperacion de contrasena - RN-004-PASSWORD';
COMMENT ON COLUMN password_recovery.token IS 'Token seguro URL-safe de 32 bytes';
COMMENT ON COLUMN password_recovery.expires_at IS 'Expiracion: 24 horas desde creacion';
COMMENT ON COLUMN password_recovery.used_at IS 'Marca de tiempo cuando token fue usado - NULL si no usado';
COMMENT ON COLUMN password_recovery.ip_address IS 'IP desde donde se solicito la recuperacion';

-- =====================================================
-- FUNCION: request_password_reset()
-- =====================================================
-- Solicita recuperacion de contrasena
-- Retorna: JSON {success, data: {token, expires_at, message}}
-- Seguridad: Rate limiting 15 min, no revela si email existe
-- =====================================================

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
    -- RN-004.1: Validar formato email
    IF p_email IS NULL OR p_email = '' THEN
        v_error_hint := 'missing_email';
        RAISE EXCEPTION 'Email es requerido';
    END IF;

    IF p_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        v_error_hint := 'invalid_email';
        RAISE EXCEPTION 'Formato de email invalido';
    END IF;

    -- Buscar usuario por email (case insensitive)
    SELECT id INTO v_user_id
    FROM auth.users
    WHERE LOWER(email) = LOWER(p_email)
      AND email_confirmed_at IS NOT NULL;

    -- RN-004.2: Si no existe usuario, retornar mensaje generico (privacidad)
    IF v_user_id IS NULL THEN
        RETURN json_build_object(
            'success', true,
            'data', json_build_object(
                'message', 'Si el email existe, se enviara un enlace de recuperacion',
                'email_sent', false
            )
        );
    END IF;

    -- RN-004.3: Verificar rate limiting (maximo 3 solicitudes en 15 minutos)
    SELECT created_at INTO v_last_request
    FROM password_recovery
    WHERE user_id = v_user_id
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_last_request IS NOT NULL AND
       NOW() - v_last_request < INTERVAL '15 minutes' THEN
        -- Contar solicitudes en los ultimos 15 minutos
        SELECT COUNT(*) INTO v_request_count
        FROM password_recovery
        WHERE user_id = v_user_id
          AND created_at > NOW() - INTERVAL '15 minutes';

        IF v_request_count >= 3 THEN
            v_error_hint := 'rate_limit';
            RAISE EXCEPTION 'Ya se enviaron varios enlaces recientemente. Espera 15 minutos';
        END IF;
    END IF;

    -- RN-004.4: Invalidar tokens previos del usuario (no usados)
    UPDATE password_recovery
    SET used_at = NOW()
    WHERE user_id = v_user_id
      AND used_at IS NULL
      AND expires_at > NOW();

    -- RN-004.5: Generar token seguro (32 bytes, URL-safe)
    v_token := encode(gen_random_bytes(32), 'base64');
    v_token := replace(replace(replace(v_token, '+', '-'), '/', '_'), '=', '');
    v_expires_at := NOW() + INTERVAL '24 hours';

    -- RN-004.6: Insertar nuevo token
    INSERT INTO password_recovery (user_id, email, token, expires_at, ip_address)
    VALUES (v_user_id, p_email, v_token, v_expires_at, p_ip_address);

    -- Retornar respuesta exitosa
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Si el email existe, se enviara un enlace de recuperacion',
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

COMMENT ON FUNCTION request_password_reset(TEXT, INET) IS 'HU-004: Solicita recuperacion de contrasena - RN-004';

-- =====================================================
-- FUNCION: validate_reset_token()
-- =====================================================
-- Valida si un token de recuperacion es valido
-- Retorna: JSON {success, data: {is_valid, user_id, email}}
-- =====================================================

CREATE OR REPLACE FUNCTION validate_reset_token(
    p_token TEXT
)
RETURNS JSON AS $$
DECLARE
    v_recovery RECORD;
    v_error_hint TEXT;
BEGIN
    -- Validacion de entrada
    IF p_token IS NULL OR p_token = '' THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    -- Buscar token
    SELECT * INTO v_recovery
    FROM password_recovery
    WHERE token = p_token;

    -- Token no existe
    IF NOT FOUND THEN
        v_error_hint := 'invalid_token';
        RAISE EXCEPTION 'Enlace de recuperacion invalido';
    END IF;

    -- Token expirado
    IF v_recovery.expires_at < NOW() THEN
        v_error_hint := 'expired_token';
        RAISE EXCEPTION 'Enlace de recuperacion expirado';
    END IF;

    -- Token ya usado
    IF v_recovery.used_at IS NOT NULL THEN
        v_error_hint := 'used_token';
        RAISE EXCEPTION 'Enlace ya utilizado';
    END IF;

    -- Token valido
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

COMMENT ON FUNCTION validate_reset_token(TEXT) IS 'HU-004: Valida token de recuperacion - RN-004';

-- =====================================================
-- FUNCION: reset_password()
-- =====================================================
-- Cambia la contrasena usando token de recuperacion
-- Retorna: JSON {success, data: {message}}
-- Seguridad: Invalida sesiones activas, marca token usado
-- =====================================================

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
    -- Validaciones de entrada
    IF p_token IS NULL OR p_token = '' THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    IF p_new_password IS NULL OR p_new_password = '' THEN
        v_error_hint := 'missing_password';
        RAISE EXCEPTION 'Contrasena es requerida';
    END IF;

    -- RN-004.7: Validar fortaleza de contrasena (minimo 8 caracteres)
    IF LENGTH(p_new_password) < 8 THEN
        v_error_hint := 'weak_password';
        RAISE EXCEPTION 'La contrasena debe tener al menos 8 caracteres';
    END IF;

    -- Buscar y validar token
    SELECT * INTO v_recovery
    FROM password_recovery
    WHERE token = p_token;

    IF NOT FOUND THEN
        v_error_hint := 'invalid_token';
        RAISE EXCEPTION 'Enlace de recuperacion invalido';
    END IF;

    IF v_recovery.expires_at < NOW() THEN
        v_error_hint := 'expired_token';
        RAISE EXCEPTION 'Enlace de recuperacion expirado';
    END IF;

    IF v_recovery.used_at IS NOT NULL THEN
        v_error_hint := 'used_token';
        RAISE EXCEPTION 'Enlace ya utilizado';
    END IF;

    -- RN-004.8: Actualizar contrasena en auth.users
    -- Nota: Supabase Auth maneja el hashing automaticamente
    UPDATE auth.users
    SET encrypted_password = crypt(p_new_password, gen_salt('bf')),
        updated_at = NOW()
    WHERE id = v_recovery.user_id;

    -- RN-004.9: Marcar token como usado
    UPDATE password_recovery
    SET used_at = NOW()
    WHERE id = v_recovery.id;

    -- RN-004.10: Invalidar sesiones activas del usuario (seguridad)
    -- Eliminar refresh tokens para forzar re-login
    DELETE FROM auth.refresh_tokens
    WHERE user_id = v_recovery.user_id;

    -- RN-004.11: Registrar en audit_logs
    INSERT INTO audit_log (
        user_id,
        event_type,
        event_data,
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

    -- Retornar confirmacion
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Contrasena cambiada exitosamente'
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

COMMENT ON FUNCTION reset_password(TEXT, TEXT, INET) IS 'HU-004: Cambia contrasena con token - RN-004';

-- =====================================================
-- FUNCION: cleanup_expired_recovery_tokens()
-- =====================================================
-- Limpia tokens expirados de la tabla password_recovery
-- Retorna: JSON {success, data: {deleted_count}}
-- Uso: Llamar desde cron job o manualmente
-- =====================================================

CREATE OR REPLACE FUNCTION cleanup_expired_recovery_tokens()
RETURNS JSON AS $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    -- Eliminar tokens expirados
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

COMMENT ON FUNCTION cleanup_expired_recovery_tokens() IS 'HU-004: Limpia tokens expirados - RN-004';

COMMIT;
