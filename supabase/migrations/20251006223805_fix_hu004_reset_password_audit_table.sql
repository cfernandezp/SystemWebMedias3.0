-- Migration: FIX HU-004 - Corregir reset_password() para usar tabla audit_logs correcta
-- Fecha: 2025-10-06
-- Razón: ISSUE #1 - reset_password() usa tabla audit_log incorrecta (debe ser audit_logs)
-- Impacto: Corrige nombre de tabla y campos en INSERT de auditoría
-- Referencias: docs/technical/00-QA-REPORT-E001-HU-004.md

BEGIN;

-- =====================================================
-- CORRECCIÓN: reset_password()
-- =====================================================
-- Fix: Cambiar audit_log por audit_logs y usar campos correctos
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
    UPDATE auth.users
    SET encrypted_password = crypt(p_new_password, gen_salt('bf')),
        updated_at = NOW()
    WHERE id = v_recovery.user_id;

    -- RN-004.9: Marcar token como usado
    UPDATE password_recovery
    SET used_at = NOW()
    WHERE id = v_recovery.id;

    -- RN-004.10: Invalidar sesiones activas del usuario (seguridad)
    -- CAST: user_id en refresh_tokens es VARCHAR, no UUID
    DELETE FROM auth.refresh_tokens
    WHERE user_id = v_recovery.user_id::TEXT;

    -- RN-004.11: Registrar en audit_logs (FIX: tabla correcta + campos correctos)
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

COMMENT ON FUNCTION reset_password(TEXT, TEXT, INET) IS 'HU-004: Cambia contrasena con token - RN-004 (FIXED: audit_logs table)';

COMMIT;
