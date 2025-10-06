-- Script de diagnóstico para problema de login

-- 1. Verificar usuario en auth.users
SELECT
    id,
    email,
    email_confirmed_at,
    confirmed_at,
    raw_user_meta_data->>'nombre_completo' as nombre_completo,
    encrypted_password IS NOT NULL as tiene_password,
    created_at
FROM auth.users
WHERE LOWER(email) = LOWER('admin@email.com');

-- 2. Verificar intentos de login recientes
SELECT
    email,
    success,
    attempted_at
FROM login_attempts
WHERE LOWER(email) = LOWER('admin@email.com')
ORDER BY attempted_at DESC
LIMIT 10;

-- 3. Probar la verificación de contraseña
-- Nota: Esta es la línea que está causando el problema en login_user
SELECT
    email,
    encrypted_password,
    crypt('Admin123456', encrypted_password) = encrypted_password as password_match_test
FROM auth.users
WHERE LOWER(email) = LOWER('admin@email.com');
