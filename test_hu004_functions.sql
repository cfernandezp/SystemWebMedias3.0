-- TEST HU-004: Verificación de funciones de Password Recovery
-- Ejecutar con: npx supabase db reset && cat test_hu004_functions.sql | docker exec -i <container> psql -U postgres -d postgres

\echo '========================================';
\echo 'TEST 1: Verificar tabla password_recovery';
\echo '========================================';

SELECT
    table_name,
    table_schema
FROM information_schema.tables
WHERE table_name = 'password_recovery';

\echo '';
\echo '========================================';
\echo 'TEST 2: Verificar funciones creadas';
\echo '========================================';

SELECT
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'request_password_reset',
    'validate_reset_token',
    'reset_password',
    'cleanup_expired_recovery_tokens'
  )
ORDER BY routine_name;

\echo '';
\echo '========================================';
\echo 'TEST 3: request_password_reset (usuario existente)';
\echo '========================================';

SELECT request_password_reset('admin@test.com', '127.0.0.1'::INET);

\echo '';
\echo '========================================';
\echo 'TEST 4: request_password_reset (email no existente - privacidad)';
\echo '========================================';

SELECT request_password_reset('noexiste@test.com', '127.0.0.1'::INET);

\echo '';
\echo '========================================';
\echo 'TEST 5: Verificar tokens creados';
\echo '========================================';

SELECT
    id,
    email,
    substring(token, 1, 20) || '...' as token_preview,
    expires_at > NOW() as is_valid,
    used_at IS NULL as is_unused,
    created_at
FROM password_recovery
ORDER BY created_at DESC
LIMIT 5;

\echo '';
\echo '========================================';
\echo 'TEST 6: validate_reset_token (con token real)';
\echo '========================================';

DO $$
DECLARE
    v_token TEXT;
    v_result JSON;
BEGIN
    -- Obtener el token más reciente
    SELECT token INTO v_token
    FROM password_recovery
    WHERE used_at IS NULL
      AND expires_at > NOW()
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_token IS NOT NULL THEN
        -- Validar el token
        SELECT validate_reset_token(v_token) INTO v_result;
        RAISE NOTICE 'validate_reset_token result: %', v_result;
    ELSE
        RAISE NOTICE 'No hay tokens disponibles para validar';
    END IF;
END $$;

\echo '';
\echo '========================================';
\echo 'TEST 7: validate_reset_token (token inválido)';
\echo '========================================';

SELECT validate_reset_token('token_invalido_123');

\echo '';
\echo '========================================';
\echo 'TEST 8: reset_password (con token real)';
\echo '========================================';

DO $$
DECLARE
    v_token TEXT;
    v_result JSON;
BEGIN
    -- Obtener el token más reciente
    SELECT token INTO v_token
    FROM password_recovery
    WHERE used_at IS NULL
      AND expires_at > NOW()
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_token IS NOT NULL THEN
        -- Cambiar password
        SELECT reset_password(v_token, 'NewPassword123!', '127.0.0.1'::INET) INTO v_result;
        RAISE NOTICE 'reset_password result: %', v_result;
    ELSE
        RAISE NOTICE 'No hay tokens disponibles para reset';
    END IF;
END $$;

\echo '';
\echo '========================================';
\echo 'TEST 9: Verificar token marcado como usado';
\echo '========================================';

SELECT
    id,
    email,
    used_at IS NOT NULL as was_used,
    used_at
FROM password_recovery
ORDER BY created_at DESC
LIMIT 1;

\echo '';
\echo '========================================';
\echo 'TEST 10: cleanup_expired_recovery_tokens';
\echo '========================================';

SELECT cleanup_expired_recovery_tokens();

\echo '';
\echo '========================================';
\echo 'RESUMEN DE VERIFICACIÓN';
\echo '========================================';

SELECT
    COUNT(*) as total_tokens,
    COUNT(*) FILTER (WHERE used_at IS NULL) as unused_tokens,
    COUNT(*) FILTER (WHERE used_at IS NOT NULL) as used_tokens,
    COUNT(*) FILTER (WHERE expires_at > NOW()) as valid_tokens
FROM password_recovery;
