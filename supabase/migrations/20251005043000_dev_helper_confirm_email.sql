-- Helper temporal para desarrollo: confirmar email de usuario
CREATE OR REPLACE FUNCTION dev_confirm_email(p_email TEXT)
RETURNS JSON AS $$
BEGIN
    UPDATE auth.users
    SET email_confirmed_at = NOW()
    WHERE LOWER(email) = LOWER(p_email);

    RETURN json_build_object('success', true, 'message', 'Email confirmado');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
