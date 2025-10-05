-- Migration: Corregir sintaxis de pg_net.http_post para envío de emails
-- Fecha: 2025-10-04
-- Razón: Cambiar body de TEXT a JSONB según documentación oficial de pg_net

BEGIN;

-- ============================================
-- Función corregida para enviar emails via Inbucket
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
    v_email_body JSONB;
    v_response_id BIGINT;
BEGIN
    -- Construir enlace de confirmación
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

    -- Construir payload JSONB para Inbucket
    v_email_body := json_build_object(
        'from', 'noreply@hiltex.com',
        'to', p_to_email,
        'subject', 'Confirma tu email - Sistema de Gestión de Medias',
        'html', v_html_body
    )::jsonb;

    -- Enviar email vía pg_net a Inbucket
    -- IMPORTANTE: body debe ser JSONB, no TEXT
    SELECT INTO v_response_id net.http_post(
        url := 'http://inbucket:9000/api/v1/mailbox/' || split_part(p_to_email, '@', 1),
        headers := '{"Content-Type": "application/json"}'::jsonb,
        body := v_email_body
    );

    -- Log del envío (para debug)
    RAISE NOTICE 'Email de confirmación enviado a % (response_id: %)', p_to_email, v_response_id;

EXCEPTION
    WHEN OTHERS THEN
        -- No fallar si el email falla (el usuario puede reenviar)
        RAISE WARNING 'Error al enviar email a %: %', p_to_email, SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comentario
COMMENT ON FUNCTION send_confirmation_email IS 'HU-001: Envía email de confirmación vía Inbucket (local testing) - Sintaxis corregida con JSONB';

COMMIT;
