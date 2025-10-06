# APIs/Functions - E001-HU-003: Logout Seguro

**HU**: E001-HU-003 - Logout Seguro
**Responsable**: @supabase-expert
**Fecha de diseño**: 2025-10-06

---

## 📋 FUNCIONES POSTGRESQL

### 1. logout_user() - Logout Manual/Automático

Invalida token JWT y registra evento en auditoría.

```sql
CREATE OR REPLACE FUNCTION logout_user(
    p_token TEXT,
    p_user_id UUID,
    p_logout_type TEXT DEFAULT 'manual',
    p_ip_address INET DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL,
    p_session_duration INTERVAL DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_token_expires_at TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Validaciones
    IF p_token IS NULL OR p_token = '' THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    IF p_user_id IS NULL THEN
        v_error_hint := 'missing_user_id';
        RAISE EXCEPTION 'User ID es requerido';
    END IF;

    IF p_logout_type NOT IN ('manual', 'inactivity', 'token_expired') THEN
        v_error_hint := 'invalid_logout_type';
        RAISE EXCEPTION 'Tipo de logout inválido';
    END IF;

    -- Verificar que token no esté ya en blacklist
    IF EXISTS (SELECT 1 FROM token_blacklist WHERE token = p_token) THEN
        v_error_hint := 'already_blacklisted';
        RAISE EXCEPTION 'Token ya invalidado';
    END IF;

    -- Extraer fecha de expiración del token (decodificar JWT)
    -- Por simplicidad, asumimos 8 horas desde ahora (ajustar según tu implementación)
    v_token_expires_at := NOW() + INTERVAL '8 hours';

    -- 1. Agregar token a blacklist
    INSERT INTO token_blacklist (token, user_id, expires_at, reason)
    VALUES (p_token, p_user_id, v_token_expires_at, p_logout_type);

    -- 2. Registrar en audit_logs
    INSERT INTO audit_logs (
        user_id,
        event_type,
        event_subtype,
        ip_address,
        user_agent,
        metadata
    ) VALUES (
        p_user_id,
        'logout',
        p_logout_type,
        p_ip_address,
        p_user_agent,
        json_build_object(
            'session_duration', EXTRACT(EPOCH FROM p_session_duration),
            'logout_type', p_logout_type
        )::jsonb
    );

    -- 3. Actualizar last_activity_at
    UPDATE users
    SET last_activity_at = NOW()
    WHERE id = p_user_id;

    -- Respuesta exitosa
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'message', CASE
                WHEN p_logout_type = 'manual' THEN 'Sesión cerrada exitosamente'
                WHEN p_logout_type = 'inactivity' THEN 'Sesión cerrada por inactividad'
                WHEN p_logout_type = 'token_expired' THEN 'Tu sesión ha expirado'
            END,
            'logout_type', p_logout_type,
            'blacklisted_at', NOW()
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

COMMENT ON FUNCTION logout_user IS 'HU-003: Invalida token JWT y registra logout - RN-003-LOGOUT.2, RN-003-LOGOUT.3';
```

---

### 2. check_token_blacklist() - Verificar si Token está Invalidado

```sql
CREATE OR REPLACE FUNCTION check_token_blacklist(
    p_token TEXT
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_is_blacklisted BOOLEAN;
    v_reason TEXT;
BEGIN
    -- Validación
    IF p_token IS NULL OR p_token = '' THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    -- Verificar si token está en blacklist y no expiró
    SELECT EXISTS (
        SELECT 1
        FROM token_blacklist
        WHERE token = p_token
          AND expires_at > NOW()
    ) INTO v_is_blacklisted;

    -- Obtener razón si está blacklisted
    IF v_is_blacklisted THEN
        SELECT reason INTO v_reason
        FROM token_blacklist
        WHERE token = p_token
        LIMIT 1;
    END IF;

    -- Respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'is_blacklisted', v_is_blacklisted,
            'reason', v_reason,
            'message', CASE
                WHEN v_is_blacklisted THEN 'Token inválido. Debes iniciar sesión nuevamente'
                ELSE 'Token válido'
            END
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

COMMENT ON FUNCTION check_token_blacklist IS 'HU-003: Verifica si token está invalidado - RN-003-LOGOUT.3';
```

---

### 3. check_user_inactivity() - Detectar Inactividad

```sql
CREATE OR REPLACE FUNCTION check_user_inactivity(
    p_user_id UUID,
    p_timeout_minutes INT DEFAULT 120
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_last_activity TIMESTAMP WITH TIME ZONE;
    v_inactive_duration INTERVAL;
    v_is_inactive BOOLEAN;
    v_minutes_until_logout INT;
BEGIN
    -- Validación
    IF p_user_id IS NULL THEN
        v_error_hint := 'missing_user_id';
        RAISE EXCEPTION 'User ID es requerido';
    END IF;

    -- Obtener última actividad
    SELECT last_activity_at INTO v_last_activity
    FROM users
    WHERE id = p_user_id;

    IF v_last_activity IS NULL THEN
        v_error_hint := 'user_not_found';
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    -- Calcular duración de inactividad
    v_inactive_duration := NOW() - v_last_activity;
    v_is_inactive := v_inactive_duration > (p_timeout_minutes || ' minutes')::INTERVAL;
    v_minutes_until_logout := p_timeout_minutes - EXTRACT(EPOCH FROM v_inactive_duration) / 60;

    -- Respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'is_inactive', v_is_inactive,
            'last_activity_at', v_last_activity,
            'inactive_minutes', EXTRACT(EPOCH FROM v_inactive_duration) / 60,
            'minutes_until_logout', GREATEST(0, v_minutes_until_logout),
            'should_warn', v_minutes_until_logout <= 5 AND NOT v_is_inactive,
            'message', CASE
                WHEN v_is_inactive THEN 'Usuario inactivo. Sesión debe cerrarse'
                WHEN v_minutes_until_logout <= 5 THEN 'Tu sesión expirará en ' || v_minutes_until_logout || ' minutos'
                ELSE 'Usuario activo'
            END
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

COMMENT ON FUNCTION check_user_inactivity IS 'HU-003: Verifica inactividad del usuario - RN-003-LOGOUT.5';
```

---

### 4. update_user_activity() - Actualizar Última Actividad

```sql
CREATE OR REPLACE FUNCTION update_user_activity(
    p_user_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Validación
    IF p_user_id IS NULL THEN
        v_error_hint := 'missing_user_id';
        RAISE EXCEPTION 'User ID es requerido';
    END IF;

    -- Actualizar actividad
    UPDATE users
    SET last_activity_at = NOW()
    WHERE id = p_user_id;

    IF NOT FOUND THEN
        v_error_hint := 'user_not_found';
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    -- Respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'last_activity_at', NOW(),
            'message', 'Actividad actualizada'
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

COMMENT ON FUNCTION update_user_activity IS 'HU-003: Actualiza última actividad del usuario - RN-003-LOGOUT.5';
```

---

### 5. cleanup_expired_blacklist() - Limpiar Tokens Expirados

Función para ejecutar diariamente (cron job).

```sql
CREATE OR REPLACE FUNCTION cleanup_expired_blacklist()
RETURNS JSON AS $$
DECLARE
    v_deleted_count INT;
BEGIN
    -- Eliminar tokens expirados
    DELETE FROM token_blacklist
    WHERE expires_at < NOW();

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    -- Respuesta
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'deleted_count', v_deleted_count,
            'message', v_deleted_count || ' tokens expirados eliminados'
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION cleanup_expired_blacklist IS 'HU-003: Limpia tokens expirados de blacklist - ejecutar diariamente';
```

---

### 6. get_user_audit_logs() - Obtener Historial de Auditoría

```sql
CREATE OR REPLACE FUNCTION get_user_audit_logs(
    p_user_id UUID,
    p_event_type TEXT DEFAULT NULL,
    p_limit INT DEFAULT 20
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_logs JSON;
BEGIN
    -- Validación
    IF p_user_id IS NULL THEN
        v_error_hint := 'missing_user_id';
        RAISE EXCEPTION 'User ID es requerido';
    END IF;

    -- Obtener logs
    SELECT json_agg(
        json_build_object(
            'id', id,
            'event_type', event_type,
            'event_subtype', event_subtype,
            'ip_address', ip_address,
            'user_agent', user_agent,
            'metadata', metadata,
            'created_at', created_at
        )
        ORDER BY created_at DESC
    )
    INTO v_logs
    FROM audit_logs
    WHERE user_id = p_user_id
      AND (p_event_type IS NULL OR event_type = p_event_type)
    LIMIT p_limit;

    -- Respuesta
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'logs', COALESCE(v_logs, '[]'::json),
            'count', (SELECT COUNT(*) FROM audit_logs WHERE user_id = p_user_id)
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

COMMENT ON FUNCTION get_user_audit_logs IS 'HU-003: Obtiene historial de auditoría del usuario - RN-003-LOGOUT.9';
```

---

## 📊 RESPONSE FORMATS

### logout_user() - Respuesta Exitosa

```json
{
  "success": true,
  "data": {
    "message": "Sesión cerrada exitosamente",
    "logout_type": "manual",
    "blacklisted_at": "2025-10-06T10:30:00Z"
  }
}
```

### check_token_blacklist() - Token Invalidado

```json
{
  "success": true,
  "data": {
    "is_blacklisted": true,
    "reason": "manual_logout",
    "message": "Token inválido. Debes iniciar sesión nuevamente"
  }
}
```

### check_user_inactivity() - Usuario Inactivo

```json
{
  "success": true,
  "data": {
    "is_inactive": true,
    "last_activity_at": "2025-10-06T08:00:00Z",
    "inactive_minutes": 125,
    "minutes_until_logout": 0,
    "should_warn": false,
    "message": "Usuario inactivo. Sesión debe cerrarse"
  }
}
```

### check_user_inactivity() - Warning de Inactividad

```json
{
  "success": true,
  "data": {
    "is_inactive": false,
    "last_activity_at": "2025-10-06T10:10:00Z",
    "inactive_minutes": 115,
    "minutes_until_logout": 5,
    "should_warn": true,
    "message": "Tu sesión expirará en 5 minutos"
  }
}
```

---

## 🔍 HINTS DE ERROR

| Hint | Significado | HTTP Status (Flutter) |
|------|-------------|----------------------|
| `missing_token` | Token no proporcionado | 400 Bad Request |
| `missing_user_id` | User ID no proporcionado | 400 Bad Request |
| `invalid_logout_type` | Tipo de logout inválido | 400 Bad Request |
| `already_blacklisted` | Token ya invalidado | 400 Bad Request |
| `token_blacklisted` | Token está en blacklist | 401 Unauthorized |
| `user_not_found` | Usuario no existe | 404 Not Found |

---

## 🔄 INTEGRACIÓN CON OTRAS FUNCIONES

### Interceptor en Todas las Funciones Autenticadas

Agregar verificación de blacklist al inicio de TODAS las funciones que requieren autenticación:

```sql
-- En cada función autenticada, agregar:
-- 1. Verificar token blacklist
IF EXISTS (SELECT 1 FROM token_blacklist WHERE token = p_token AND expires_at > NOW()) THEN
    v_error_hint := 'token_blacklisted';
    RAISE EXCEPTION 'Token inválido';
END IF;

-- 2. Actualizar actividad del usuario
PERFORM update_user_activity(p_user_id);
```

---

## 📝 NOTAS DE IMPLEMENTACIÓN

1. **Token Hashing**: Considerar hashear tokens antes de almacenar en blacklist (SHA-256)
2. **Cron Job**: Configurar `cleanup_expired_blacklist()` para ejecutar diariamente
3. **Performance**: Índices en `token` y `expires_at` son críticos
4. **JWT Expiration**: Extraer `exp` claim del JWT para `expires_at` preciso
5. **IP Address**: Capturar desde headers HTTP (`X-Forwarded-For`, `X-Real-IP`)

---

## ✅ TESTING

```sql
-- Test 1: Logout manual
SELECT logout_user(
    'fake-jwt-token-123',
    'user-uuid-here',
    'manual',
    '192.168.1.1'::INET,
    'Mozilla/5.0',
    INTERVAL '45 minutes'
);

-- Test 2: Verificar blacklist
SELECT check_token_blacklist('fake-jwt-token-123');

-- Test 3: Inactividad
SELECT check_user_inactivity('user-uuid-here', 120);

-- Test 4: Cleanup
SELECT cleanup_expired_blacklist();
```

---

**Estado**: ⏳ Pendiente de implementación
**Próximo paso**: Implementar modelos Dart en `models_E001-HU-003.md`
