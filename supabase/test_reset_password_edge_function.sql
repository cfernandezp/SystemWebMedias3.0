-- ========================================
-- TEST MANUAL: Edge Function reset-password
-- HU-004: Recuperar Contraseña
-- ========================================

-- PREREQUISITO: Tener un usuario de prueba
-- Si no existe, ejecutar:
DO $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Intentar obtener usuario de prueba
    SELECT id INTO v_user_id
    FROM auth.users
    WHERE email = 'test@example.com'
    LIMIT 1;

    -- Si no existe, informar
    IF v_user_id IS NULL THEN
        RAISE NOTICE 'Usuario test@example.com no existe. Crear primero.';
    ELSE
        RAISE NOTICE 'Usuario test@example.com encontrado: %', v_user_id;
    END IF;
END $$;

-- ========================================
-- PASO 1: Generar token de recuperación
-- ========================================
SELECT request_password_reset('test@example.com', '127.0.0.1'::INET);

-- ========================================
-- PASO 2: Obtener el token generado
-- ========================================
SELECT
    token,
    email,
    expires_at,
    used_at,
    created_at
FROM password_recovery
WHERE email = 'test@example.com'
ORDER BY created_at DESC
LIMIT 1;

-- Copiar el token para usarlo en el siguiente paso

-- ========================================
-- PASO 3: Validar token (opcional)
-- ========================================
-- Reemplazar 'TOKEN_AQUI' con el token del PASO 2
SELECT validate_reset_token('TOKEN_AQUI');

-- ========================================
-- PASO 4: Probar Edge Function con curl
-- ========================================
-- Ejecutar en terminal (reemplazar TOKEN_AQUI):

/*
curl -X POST "http://127.0.0.1:54321/functions/v1/reset-password" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH" \
  -d '{
    "token": "TOKEN_AQUI",
    "newPassword": "NewTestPassword123!",
    "ipAddress": "127.0.0.1"
  }'
*/

-- ========================================
-- PASO 5: Verificar resultado
-- ========================================

-- A. Verificar token marcado como usado
SELECT
    token,
    used_at IS NOT NULL as fue_usado,
    used_at
FROM password_recovery
WHERE email = 'test@example.com'
ORDER BY created_at DESC
LIMIT 1;

-- B. Verificar auditoría
SELECT
    event_type,
    user_id,
    ip_address,
    details,
    created_at
FROM audit_log
WHERE event_type = 'password_reset'
ORDER BY created_at DESC
LIMIT 5;

-- C. Intentar login con nueva contraseña (desde Flutter)
-- Email: test@example.com
-- Password: NewTestPassword123!

-- ========================================
-- TESTS DE VALIDACIÓN
-- ========================================

-- TEST 1: Token vacío (debe fallar)
/*
curl -X POST "http://127.0.0.1:54321/functions/v1/reset-password" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "",
    "newPassword": "Password123!"
  }'

ESPERADO:
{
  "success": false,
  "error": {
    "message": "Token y nueva contraseña son requeridos",
    "hint": "missing_params"
  }
}
*/

-- TEST 2: Password débil (debe fallar)
/*
curl -X POST "http://127.0.0.1:54321/functions/v1/reset-password" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "valid-token",
    "newPassword": "Pass1"
  }'

ESPERADO:
{
  "success": false,
  "error": {
    "message": "La contraseña debe tener al menos 8 caracteres",
    "hint": "weak_password"
  }
}
*/

-- TEST 3: Token inválido (debe fallar)
/*
curl -X POST "http://127.0.0.1:54321/functions/v1/reset-password" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "token-inexistente",
    "newPassword": "NewPassword123!"
  }'

ESPERADO:
{
  "success": false,
  "error": {
    "message": "Enlace de recuperacion invalido",
    "hint": "invalid_token"
  }
}
*/

-- TEST 4: Token expirado (debe fallar)
-- Primero expiramos un token manualmente
UPDATE password_recovery
SET expires_at = NOW() - INTERVAL '1 hour'
WHERE email = 'test@example.com'
  AND used_at IS NULL
LIMIT 1;

/*
curl con el token expirado...

ESPERADO:
{
  "success": false,
  "error": {
    "message": "Enlace de recuperacion expirado",
    "hint": "expired_token"
  }
}
*/

-- TEST 5: Token ya usado (debe fallar)
-- Usar un token que ya fue utilizado

/*
ESPERADO:
{
  "success": false,
  "error": {
    "message": "Enlace ya utilizado",
    "hint": "used_token"
  }
}
*/

-- ========================================
-- LIMPIEZA
-- ========================================
-- Eliminar tokens de prueba (opcional)
DELETE FROM password_recovery
WHERE email = 'test@example.com';

-- Eliminar logs de auditoría de prueba (opcional)
-- DELETE FROM audit_log
-- WHERE event_type = 'password_reset'
--   AND details->>'method' = 'edge_function';

-- ========================================
-- NOTAS IMPORTANTES
-- ========================================
/*
1. La Edge Function debe estar corriendo localmente:
   npx supabase functions serve reset-password --no-verify-jwt

2. Supabase local debe estar activo:
   npx supabase status

3. Variables de entorno necesarias en supabase/.env.local:
   - SUPABASE_URL=http://127.0.0.1:54321
   - SUPABASE_SERVICE_ROLE_KEY=sb_secret_...

4. Para deployment en producción:
   npx supabase functions deploy reset-password

5. Verificar logs de la función:
   npx supabase functions logs reset-password
*/
