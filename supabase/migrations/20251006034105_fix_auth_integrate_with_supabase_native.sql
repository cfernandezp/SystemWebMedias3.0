-- Migration: Fix auth functions para integrarse con Supabase Auth nativo
-- Fecha: 2025-10-06
-- Razon: El problema es que register_user() crea usuarios en tabla 'users' (eliminada)
--        y login_user() los busca en auth.users (vacia). Necesitamos que ambas
--        funciones trabajen con auth.users de Supabase Auth.
-- Solucion: Reescribir register_user() para insertar en auth.users directamente
--           y mantener login_user() para verificar passwords con Supabase Auth
-- Impacto: Permite registro y login usando RPC functions pero con Supabase Auth como backend

BEGIN;

-- ============================================
-- PASO 1: Eliminar funciones obsoletas
-- ============================================

DROP FUNCTION IF EXISTS register_user(TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS login_user(TEXT, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS confirm_email(TEXT);
DROP FUNCTION IF EXISTS hash_password(TEXT);
DROP FUNCTION IF EXISTS verify_password(TEXT, TEXT);
DROP FUNCTION IF EXISTS generate_confirmation_token();

-- ============================================
-- PASO 2: Nueva funcion register_user() que usa auth.users
-- ============================================

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
        RAISE EXCEPTION 'Formato de email invalido';
    END IF;

    -- Validar contrasena (minimo 8 caracteres)
    IF LENGTH(p_password) < 8 THEN
        v_error_hint := 'invalid_password';
        RAISE EXCEPTION 'La contrasena debe tener al menos 8 caracteres';
    END IF;

    -- Validar nombre completo
    IF LENGTH(TRIM(p_nombre_completo)) < 2 THEN
        v_error_hint := 'invalid_name';
        RAISE EXCEPTION 'El nombre completo es requerido';
    END IF;

    -- Verificar que el email no exista
    IF EXISTS (SELECT 1 FROM auth.users WHERE LOWER(email) = LOWER(p_email)) THEN
        v_error_hint := 'duplicate_email';
        RAISE EXCEPTION 'Este email ya esta registrado';
    END IF;

    -- Insertar usuario en auth.users usando la extension de Supabase Auth
    -- Nota: Esta es una insercion directa, lo cual NO es la practica recomendada
    -- pero es necesaria para mantener compatibilidad con el frontend actual
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
        NULL,  -- Email no confirmado aun
        json_build_object('nombre_completo', p_nombre_completo),
        NOW(),
        NOW(),
        encode(gen_random_bytes(32), 'hex')
    )
    RETURNING id INTO v_user_id;

    -- Preparar respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'id', v_user_id,
            'email', LOWER(p_email),
            'nombre_completo', p_nombre_completo,
            'email_verificado', false,
            'message', 'Registro exitoso. Revisa tu email para confirmar tu cuenta'
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

COMMENT ON FUNCTION register_user IS 'HU-001: Registra usuario en auth.users de Supabase Auth';

-- ============================================
-- PASO 3: Nueva funcion login_user() que verifica con auth.users
-- ============================================

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
        RAISE EXCEPTION 'Formato de email invalido';
    END IF;

    -- Validar password no vacio
    IF p_password IS NULL OR p_password = '' THEN
        v_error_hint := 'missing_password';
        RAISE EXCEPTION 'Contrasena es requerida';
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
        RAISE EXCEPTION 'Email o contrasena incorrectos';
    END IF;

    -- Verificar contrasena con bcrypt
    v_password_match := (v_user.encrypted_password = crypt(p_password, v_user.encrypted_password));

    IF NOT v_password_match THEN
        INSERT INTO login_attempts (email, success) VALUES (v_user.email, false);
        v_error_hint := 'invalid_credentials';
        RAISE EXCEPTION 'Email o contrasena incorrectos';
    END IF;

    -- Verificar email verificado
    IF v_user.email_confirmed_at IS NULL THEN
        v_error_hint := 'email_not_verified';
        RAISE EXCEPTION 'Debes confirmar tu email antes de iniciar sesion';
    END IF;

    -- Extraer nombre completo de metadata
    v_nombre_completo := COALESCE(
        v_user.raw_user_meta_data->>'nombre_completo',
        v_user.email
    );

    -- Registrar intento exitoso
    INSERT INTO login_attempts (email, success) VALUES (v_user.email, true);

    -- Crear session token (simple, no usa JWT real de Supabase Auth)
    -- Nota: En produccion se deberia usar Supabase Auth nativo
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

-- ============================================
-- PASO 4: Funcion confirm_email() adaptada para auth.users
-- ============================================

CREATE OR REPLACE FUNCTION confirm_email(
    p_token TEXT
)
RETURNS JSON AS $$
DECLARE
    v_user RECORD;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Validar token no vacio
    IF p_token IS NULL OR LENGTH(TRIM(p_token)) = 0 THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    -- Buscar usuario por token de confirmacion
    SELECT id, email, raw_user_meta_data, email_confirmed_at
    INTO v_user
    FROM auth.users
    WHERE confirmation_token = p_token;

    IF NOT FOUND THEN
        v_error_hint := 'invalid_token';
        RAISE EXCEPTION 'Enlace de confirmacion invalido o expirado';
    END IF;

    -- Verificar que el email no este ya confirmado
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

    -- Preparar respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Email confirmado exitosamente',
            'email_verificado', true,
            'next_step', 'Ya puedes iniciar sesion en el sistema.'
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

COMMENT ON FUNCTION confirm_email IS 'HU-001: Confirma email del usuario en auth.users';

COMMIT;
