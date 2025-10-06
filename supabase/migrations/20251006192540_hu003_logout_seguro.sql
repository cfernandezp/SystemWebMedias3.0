-- Migration: HU-003 Logout Seguro
-- Fecha: 2025-10-06
-- Descripcion: Implementa sistema de logout seguro con token blacklist, auditoria y deteccion de inactividad

BEGIN;

-- ============================================================================
-- 1. TABLA: token_blacklist
-- ============================================================================
-- Almacena tokens JWT invalidados por logout
CREATE TABLE IF NOT EXISTS token_blacklist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token TEXT NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    blacklisted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    reason TEXT CHECK (reason IN ('manual_logout', 'inactivity', 'token_expired'))
);

-- �ndices para performance
CREATE INDEX idx_token_blacklist_token ON token_blacklist(token);
CREATE INDEX idx_token_blacklist_expires_at ON token_blacklist(expires_at);
CREATE INDEX idx_token_blacklist_user_id ON token_blacklist(user_id);

-- Comentarios
COMMENT ON TABLE token_blacklist IS 'HU-003: Tokens JWT invalidados por logout - RN-003-LOGOUT.3';
COMMENT ON COLUMN token_blacklist.token IS 'Token JWT invalidado (debe ser hash en producci�n)';
COMMENT ON COLUMN token_blacklist.reason IS 'Motivo: manual_logout, inactivity, token_expired';
COMMENT ON COLUMN token_blacklist.expires_at IS 'Fecha de expiraci�n original del token';

-- ============================================================================
-- 2. TABLA: audit_logs
-- ============================================================================
-- Auditor�a de eventos de seguridad del sistema
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL CHECK (event_type IN ('login', 'logout', 'password_change', 'password_reset', 'email_change')),
    event_subtype TEXT,
    ip_address INET,
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- �ndices para consultas
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_event_type ON audit_logs(event_type);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);

-- Comentarios
COMMENT ON TABLE audit_logs IS 'HU-003: Auditor�a de eventos de seguridad - RN-003-LOGOUT.9';
COMMENT ON COLUMN audit_logs.event_type IS 'Tipo de evento: login, logout, password_change, etc.';
COMMENT ON COLUMN audit_logs.event_subtype IS 'Subtipo del evento (ej: manual, inactivity, token_expired)';
COMMENT ON COLUMN audit_logs.metadata IS 'Informaci�n adicional del evento (session_duration, etc.)';

-- ============================================================================
-- 3. TABLA: user_sessions - Tracking de actividad
-- ============================================================================
-- Como no podemos modificar auth.users directamente, creamos tabla auxiliar
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indice para consultas de inactividad
CREATE INDEX IF NOT EXISTS idx_user_sessions_last_activity_at ON user_sessions(last_activity_at);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);

-- Comentario
COMMENT ON TABLE user_sessions IS 'HU-003: Tracking de actividad del usuario - RN-003-LOGOUT.5';
COMMENT ON COLUMN user_sessions.last_activity_at IS 'Ultima actividad del usuario para deteccion de inactividad';

-- ============================================================================
-- 4. FUNCI�N: logout_user
-- ============================================================================
-- Invalida token JWT y registra evento en auditor�a
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

    IF p_user_id IS NULL THEN
        v_error_hint := 'missing_user_id';
        RAISE EXCEPTION 'User ID es requerido';
    END IF;

    IF p_logout_type NOT IN ('manual', 'inactivity', 'token_expired') THEN
        v_error_hint := 'invalid_logout_type';
        RAISE EXCEPTION 'Tipo de logout inv�lido';
    END IF;

    -- Verificar que token no est� ya en blacklist
    IF EXISTS (SELECT 1 FROM token_blacklist WHERE token = p_token) THEN
        v_error_hint := 'already_blacklisted';
        RAISE EXCEPTION 'Token ya invalidado';
    END IF;

    -- Fecha de expiraci�n del token (8 horas desde ahora por defecto)
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

    -- Respuesta exitosa
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'message', CASE
                WHEN p_logout_type = 'manual' THEN 'Sesi�n cerrada exitosamente'
                WHEN p_logout_type = 'inactivity' THEN 'Sesi�n cerrada por inactividad'
                WHEN p_logout_type = 'token_expired' THEN 'Tu sesi�n ha expirado'
            END,
            'logout_type', p_logout_type,
            'blacklisted_at', NOW()
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

COMMENT ON FUNCTION logout_user IS 'HU-003: Invalida token JWT y registra logout - RN-003-LOGOUT.2, RN-003-LOGOUT.3';

-- ============================================================================
-- 5. FUNCI�N: check_token_blacklist
-- ============================================================================
-- Verifica si token est� invalidado
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
    -- Validaci�n
    IF p_token IS NULL OR p_token = '' THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    -- Verificar si token est� en blacklist y no expir�
    SELECT EXISTS (
        SELECT 1
        FROM token_blacklist
        WHERE token = p_token
          AND expires_at > NOW()
    ) INTO v_is_blacklisted;

    -- Obtener raz�n si est� blacklisted
    IF v_is_blacklisted THEN
        SELECT reason INTO v_reason
        FROM token_blacklist
        WHERE token = p_token
        LIMIT 1;
    END IF;

    -- Respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'is_blacklisted', v_is_blacklisted,
            'reason', v_reason,
            'message', CASE
                WHEN v_is_blacklisted THEN 'Token inv�lido. Debes iniciar sesi�n nuevamente'
                ELSE 'Token v�lido'
            END
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

COMMENT ON FUNCTION check_token_blacklist IS 'HU-003: Verifica si token est� invalidado - RN-003-LOGOUT.3';

-- ============================================================================
-- 6. FUNCI�N: check_user_inactivity
-- ============================================================================
-- Detecta inactividad del usuario
CREATE OR REPLACE FUNCTION check_user_inactivity(
    p_user_id UUID,
    p_timeout_minutes INT DEFAULT 120
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_last_activity TIMESTAMP WITH TIME ZONE;
    v_inactive_duration INTERVAL;
    v_is_inactive BOOLEAN;
    v_minutes_until_logout INT;
BEGIN
    -- Validaci�n
    IF p_user_id IS NULL THEN
        v_error_hint := 'missing_user_id';
        RAISE EXCEPTION 'User ID es requerido';
    END IF;

    -- Obtener ultima actividad
    SELECT last_activity_at INTO v_last_activity
    FROM user_sessions
    WHERE user_id = p_user_id;

    IF v_last_activity IS NULL THEN
        v_error_hint := 'user_not_found';
        RAISE EXCEPTION 'Usuario no encontrado o sin sesion activa';
    END IF;

    -- Calcular duraci�n de inactividad
    v_inactive_duration := NOW() - v_last_activity;
    v_is_inactive := v_inactive_duration > (p_timeout_minutes || ' minutes')::INTERVAL;
    v_minutes_until_logout := p_timeout_minutes - EXTRACT(EPOCH FROM v_inactive_duration) / 60;

    -- Respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'is_inactive', v_is_inactive,
            'last_activity_at', v_last_activity,
            'inactive_minutes', EXTRACT(EPOCH FROM v_inactive_duration) / 60,
            'minutes_until_logout', GREATEST(0, v_minutes_until_logout),
            'should_warn', v_minutes_until_logout <= 5 AND NOT v_is_inactive,
            'message', CASE
                WHEN v_is_inactive THEN 'Usuario inactivo. Sesi�n debe cerrarse'
                WHEN v_minutes_until_logout <= 5 THEN 'Tu sesi�n expirar� en ' || v_minutes_until_logout || ' minutos'
                ELSE 'Usuario activo'
            END
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

COMMENT ON FUNCTION check_user_inactivity IS 'HU-003: Verifica inactividad del usuario - RN-003-LOGOUT.5';

-- ============================================================================
-- 7. FUNCI�N: update_user_activity
-- ============================================================================
-- Actualiza �ltima actividad del usuario
CREATE OR REPLACE FUNCTION update_user_activity(
    p_user_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Validaci�n
    IF p_user_id IS NULL THEN
        v_error_hint := 'missing_user_id';
        RAISE EXCEPTION 'User ID es requerido';
    END IF;

    -- Actualizar actividad (upsert)
    INSERT INTO user_sessions (user_id, last_activity_at)
    VALUES (p_user_id, NOW())
    ON CONFLICT (user_id)
    DO UPDATE SET last_activity_at = NOW(), updated_at = NOW();

    -- Respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'last_activity_at', NOW(),
            'message', 'Actividad actualizada'
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

COMMENT ON FUNCTION update_user_activity IS 'HU-003: Actualiza �ltima actividad del usuario - RN-003-LOGOUT.5';

-- ============================================================================
-- 8. FUNCI�N: cleanup_expired_blacklist
-- ============================================================================
-- Limpia tokens expirados de blacklist (ejecutar diariamente)
CREATE OR REPLACE FUNCTION cleanup_expired_blacklist()
RETURNS JSON AS $$
DECLARE
    v_deleted_count INT;
BEGIN
    -- Eliminar tokens expirados
    DELETE FROM token_blacklist
    WHERE expires_at < NOW();

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    -- Respuesta
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'deleted_count', v_deleted_count,
            'message', v_deleted_count || ' tokens expirados eliminados'
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION cleanup_expired_blacklist IS 'HU-003: Limpia tokens expirados de blacklist - ejecutar diariamente';

-- ============================================================================
-- 9. FUNCI�N: get_user_audit_logs
-- ============================================================================
-- Obtiene historial de auditor�a del usuario
CREATE OR REPLACE FUNCTION get_user_audit_logs(
    p_user_id UUID,
    p_event_type TEXT DEFAULT NULL,
    p_limit INT DEFAULT 20
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_logs JSON;
BEGIN
    -- Validaci�n
    IF p_user_id IS NULL THEN
        v_error_hint := 'missing_user_id';
        RAISE EXCEPTION 'User ID es requerido';
    END IF;

    -- Obtener logs
    SELECT json_agg(
        json_build_object(
            'id', id,
            'event_type', event_type,
            'event_subtype', event_subtype,
            'ip_address', ip_address,
            'user_agent', user_agent,
            'metadata', metadata,
            'created_at', created_at
        )
        ORDER BY created_at DESC
    )
    INTO v_logs
    FROM audit_logs
    WHERE user_id = p_user_id
      AND (p_event_type IS NULL OR event_type = p_event_type)
    LIMIT p_limit;

    -- Respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'logs', COALESCE(v_logs, '[]'::json),
            'count', (SELECT COUNT(*) FROM audit_logs WHERE user_id = p_user_id)
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

COMMENT ON FUNCTION get_user_audit_logs IS 'HU-003: Obtiene historial de auditor�a del usuario - RN-003-LOGOUT.9';

COMMIT;
