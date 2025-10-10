-- ============================================
-- Script de Diagnóstico: Login Troubleshooting
-- ============================================
-- Este script ayuda a diagnosticar problemas de login

-- PASO 1: Verificar usuario existe
SELECT
    'PASO 1: Usuario admin@test.com' as paso,
    EXISTS(SELECT 1 FROM auth.users WHERE email = 'admin@test.com') as existe,
    (SELECT id FROM auth.users WHERE email = 'admin@test.com') as user_id;

-- PASO 2: Verificar email confirmado
SELECT
    'PASO 2: Email confirmado' as paso,
    email_confirmed_at IS NOT NULL as email_confirmado,
    email_confirmed_at
FROM auth.users
WHERE email = 'admin@test.com';

-- PASO 3: Verificar contraseña hasheada
SELECT
    'PASO 3: Contraseña' as paso,
    substring(encrypted_password, 1, 10) || '...' as hash_preview,
    crypt('asdasd211', encrypted_password) = encrypted_password as password_correcta
FROM auth.users
WHERE email = 'admin@test.com';

-- PASO 4: Verificar intentos de login previos
SELECT
    'PASO 4: Intentos de login (últimos 15 min)' as paso,
    COUNT(*) FILTER (WHERE success = false) as intentos_fallidos,
    COUNT(*) FILTER (WHERE success = true) as intentos_exitosos
FROM login_attempts
WHERE email = 'admin@test.com'
  AND attempted_at > NOW() - INTERVAL '15 minutes';

-- PASO 5: Verificar rate limit
SELECT
    'PASO 5: Rate limit check' as paso,
    check_login_rate_limit('admin@test.com', 'unknown') as rate_limit_ok;

-- PASO 6: Probar función login_user
SELECT
    'PASO 6: Ejecutar login_user()' as paso,
    login_user('admin@test.com', 'asdasd211', false) as resultado;

-- PASO 7: Limpiar intentos fallidos (en caso de bloqueo)
-- Descomenta la línea siguiente si hay bloqueo por rate limit:
-- DELETE FROM login_attempts WHERE email = 'admin@test.com';