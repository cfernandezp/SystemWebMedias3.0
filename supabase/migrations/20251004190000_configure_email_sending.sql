-- Migration: Configurar envío de emails vía Inbucket (local testing)
-- Fecha: 2025-10-04
-- Razón: Agregar capacidad de envío de emails de confirmación usando pg_net + Inbucket
-- Contexto: Opción A de LESSONS_LEARNED.md - Testing local sin SMTP real

BEGIN;

-- ============================================
-- PASO 1: Habilitar extensión pg_net
-- ============================================

-- pg_net ya está instalado, solo habilitamos en el schema
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- ============================================
-- PASO 2: Función helper para enviar emails via Inbucket
-- ============================================

CREATE OR REPLACE FUNCTION send_confirmation_email(
    p_to_email TEXT,
    p_to_name TEXT,
    p_token TEXT
)
RETURNS VOID AS $$
DECLARE
    v_confirm_link TEXT;
    v_html_body TEXT;
    v_response_id BIGINT;
BEGIN
    -- Construir enlace de confirmación
    -- TODO: En producción, cambiar localhost por dominio real
    v_confirm_link := 'http://localhost:8080/confirm-email?token=' || p_token;

    -- Construir HTML del email con tema turquesa corporativo
    v_html_body := '
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #F9FAFB;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #F9FAFB; padding: 40px 0;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #FFFFFF; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                    <!-- Header con gradiente turquesa -->
                    <tr>
                        <td style="background: linear-gradient(135deg, #4ECDC4 0%, #26A69A 100%); padding: 40px; text-align: center;">
                            <h1 style="color: #FFFFFF; margin: 0; font-size: 28px; font-weight: 600;">
                                Sistema de Gestión de Medias
                            </h1>
                        </td>
                    </tr>

                    <!-- Contenido -->
                    <tr>
                        <td style="padding: 40px;">
                            <h2 style="color: #111827; margin: 0 0 16px 0; font-size: 24px;">
                                ¡Hola ' || p_to_name || '!
                            </h2>
                            <p style="color: #6B7280; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
                                Gracias por registrarte en nuestro sistema. Para completar tu registro,
                                por favor confirma tu dirección de email haciendo clic en el botón de abajo.
                            </p>

                            <!-- Botón de confirmación -->
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" style="padding: 24px 0;">
                                        <a href="' || v_confirm_link || '"
                                           style="background-color: #4ECDC4;
                                                  color: #FFFFFF;
                                                  padding: 16px 32px;
                                                  text-decoration: none;
                                                  border-radius: 8px;
                                                  font-size: 16px;
                                                  font-weight: 600;
                                                  display: inline-block;">
                                            Confirmar mi email
                                        </a>
                                    </td>
                                </tr>
                            </table>

                            <p style="color: #6B7280; font-size: 14px; line-height: 1.5; margin: 24px 0 0 0;">
                                Si no puedes hacer clic en el botón, copia y pega este enlace en tu navegador:
                            </p>
                            <p style="color: #4ECDC4; font-size: 14px; word-break: break-all; margin: 8px 0 0 0;">
                                ' || v_confirm_link || '
                            </p>

                            <p style="color: #9CA3AF; font-size: 12px; line-height: 1.5; margin: 24px 0 0 0;">
                                Este enlace expira en 24 horas. Si no solicitaste este registro,
                                puedes ignorar este email de forma segura.
                            </p>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="background-color: #F9FAFB; padding: 24px; text-align: center; border-top: 1px solid #E5E7EB;">
                            <p style="color: #9CA3AF; font-size: 12px; margin: 0;">
                                © 2025 Importadora Hiltex. Todos los derechos reservados.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>';

    -- Enviar email vía pg_net a Inbucket
    -- Inbucket está en http://inbucket:9000 dentro de la red Docker de Supabase
    SELECT INTO v_response_id net.http_post(
        url := 'http://inbucket:9000/api/v1/mailbox/' || split_part(p_to_email, '@', 1),
        body := json_build_object(
            'from', 'noreply@hiltex.com',
            'to', p_to_email,
            'subject', 'Confirma tu email - Sistema de Gestión de Medias',
            'html', v_html_body
        )::text,
        headers := '{"Content-Type": "application/json"}'::jsonb
    );

    -- Log del envío (opcional, para debug)
    RAISE NOTICE 'Email de confirmación enviado a % (response_id: %)', p_to_email, v_response_id;

EXCEPTION
    WHEN OTHERS THEN
        -- No fallar si el email falla (el usuario puede reenviar)
        RAISE WARNING 'Error al enviar email a %: %', p_to_email, SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 3: Actualizar register_user() para enviar email
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

    -- PASO 7: Enviar email de confirmación (NO BLOQUEA si falla)
    BEGIN
        PERFORM send_confirmation_email(
            p_to_email := LOWER(p_email),
            p_to_name := p_nombre_completo,
            p_token := v_token
        );
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'Error al enviar email: %', SQLERRM;
            -- Continuar aunque falle el email
    END;

    -- PASO 8: Preparar respuesta JSON
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'id', v_user_id,
            'email', LOWER(p_email),
            'nombre_completo', p_nombre_completo,
            'estado', 'REGISTRADO',
            'email_verificado', false,
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
-- PASO 4: Actualizar resend_confirmation() para enviar email
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

    -- PASO 8: Enviar email de confirmación (NO BLOQUEA si falla)
    BEGIN
        PERFORM send_confirmation_email(
            p_to_email := v_user.email,
            p_to_name := v_user.nombre_completo,
            p_token := v_new_token
        );
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'Error al enviar email: %', SQLERRM;
            -- Continuar aunque falle el email
    END;

    -- PASO 9: Preparar respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Email de confirmación reenviado exitosamente',
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

-- ============================================
-- PASO 5: Comentarios para documentación
-- ============================================

COMMENT ON FUNCTION send_confirmation_email IS 'HU-001: Envía email de confirmación vía Inbucket (local testing)';

COMMIT;
