-- Migration: Simplificar envío de emails para desarrollo local
-- Fecha: 2025-10-04
-- Razón: Para desarrollo local, solo registrar el token en logs (no enviar email real)
-- En producción se configurará SMTP real

BEGIN;

-- ============================================
-- Función simplificada para "enviar" emails en desarrollo local
-- ============================================

CREATE OR REPLACE FUNCTION send_confirmation_email(
    p_to_email TEXT,
    p_to_name TEXT,
    p_token TEXT
)
RETURNS VOID AS $$
DECLARE
    v_confirm_link TEXT;
BEGIN
    -- Construir enlace de confirmación
    v_confirm_link := 'http://localhost:8080/confirm-email?token=' || p_token;

    -- En desarrollo local, solo registrar en logs
    -- El desarrollador puede:
    -- 1. Ver el token en la tabla users: SELECT token_confirmacion FROM users WHERE email = 'xxx'
    -- 2. Usar el enlace en los logs para confirmar
    -- 3. Confirmar manualmente: UPDATE users SET email_verificado = true WHERE email = 'xxx'

    RAISE NOTICE '========================================
EMAIL DE CONFIRMACIÓN (DESARROLLO LOCAL)
========================================
Para: % (%)
Asunto: Confirma tu email - Sistema de Gestión de Medias
----------------------------------------
Enlace de confirmación:
%
----------------------------------------
Token: %
========================================',
        p_to_email,
        p_to_name,
        v_confirm_link,
        p_token;

EXCEPTION
    WHEN OTHERS THEN
        -- No fallar nunca
        RAISE WARNING 'Error en send_confirmation_email: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comentario
COMMENT ON FUNCTION send_confirmation_email IS 'HU-001: Registra el email de confirmación en logs (desarrollo local). Ver logs de PostgreSQL para obtener el enlace de confirmación.';

COMMIT;
