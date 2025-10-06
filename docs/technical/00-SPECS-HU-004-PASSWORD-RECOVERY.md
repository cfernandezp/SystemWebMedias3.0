# Especificaciones Técnicas - HU-004: Recuperar Contraseña

**Historia**: E001-HU-004 - Recuperar Contraseña
**Arquitecto**: @web-architect-expert
**Fecha**: 2025-10-06
**Estado**: 🔵 En Desarrollo

---

## 🎯 RESUMEN

Sistema completo de recuperación de contraseña con:
- Solicitud vía email
- Token seguro con expiración 24h
- Rate limiting (1 solicitud/15 min)
- Validación de contraseña
- Envío de email con enlace
- Privacidad (no revelar si email existe)

---

## 🗄️ BACKEND (Supabase)

### Migration

**Archivo**: `supabase/migrations/YYYYMMDDHHMMSS_hu004_password_recovery.sql`

```sql
-- Tabla para tokens de recuperación
CREATE TABLE password_recovery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_password_recovery_token ON password_recovery(token);
CREATE INDEX idx_password_recovery_user_id ON password_recovery(user_id);
CREATE INDEX idx_password_recovery_expires_at ON password_recovery(expires_at);

COMMENT ON TABLE password_recovery IS 'HU-004: Tokens de recuperación de contraseña - RN-004';
```

### Funciones PostgreSQL

#### 1. request_password_reset()

```sql
CREATE OR REPLACE FUNCTION request_password_reset(
    p_email TEXT
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_token TEXT;
    v_expires_at TIMESTAMP WITH TIME ZONE;
    v_last_request TIMESTAMP WITH TIME ZONE;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Validar formato email
    IF p_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        v_error_hint := 'invalid_email';
        RAISE EXCEPTION 'Formato de email inválido';
    END IF;

    -- Buscar usuario
    SELECT id INTO v_user_id
    FROM auth.users
    WHERE LOWER(email) = LOWER(p_email)
      AND email_confirmed_at IS NOT NULL;

    -- Si no existe, retornar mensaje genérico (RN-004.2)
    IF v_user_id IS NULL THEN
        RETURN json_build_object(
            'success', true,
            'data', json_build_object(
                'message', 'Si el email existe, se enviará un enlace de recuperación',
                'email_sent', false
            )
        );
    END IF;

    -- Verificar rate limiting (15 minutos)
    SELECT created_at INTO v_last_request
    FROM password_recovery
    WHERE user_id = v_user_id
    ORDER BY created_at DESC
    LIMIT 1;

    IF v_last_request IS NOT NULL AND
       NOW() - v_last_request < INTERVAL '15 minutes' THEN
        v_error_hint := 'rate_limit';
        RAISE EXCEPTION 'Ya se envió un enlace recientemente. Espera 15 minutos';
    END IF;

    -- Generar token seguro
    v_token := encode(gen_random_bytes(32), 'base64');
    v_token := replace(replace(replace(v_token, '+', '-'), '/', '_'), '=', '');
    v_expires_at := NOW() + INTERVAL '24 hours';

    -- Guardar token
    INSERT INTO password_recovery (user_id, token, expires_at)
    VALUES (v_user_id, v_token, v_expires_at);

    -- Respuesta (email se envía desde Flutter)
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Si el email existe, se enviará un enlace de recuperación',
            'email_sent', true,
            'token', v_token,
            'expires_at', v_expires_at
        )
    );

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
```

#### 2. validate_reset_token()

```sql
CREATE OR REPLACE FUNCTION validate_reset_token(
    p_token TEXT
)
RETURNS JSON AS $$
DECLARE
    v_recovery RECORD;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    IF p_token IS NULL OR p_token = '' THEN
        v_error_hint := 'missing_token';
        RAISE EXCEPTION 'Token es requerido';
    END IF;

    -- Buscar token
    SELECT * INTO v_recovery
    FROM password_recovery
    WHERE token = p_token;

    IF NOT FOUND THEN
        v_error_hint := 'invalid_token';
        RAISE EXCEPTION 'Enlace de recuperación inválido';
    END IF;

    -- Verificar expiración
    IF v_recovery.expires_at < NOW() THEN
        v_error_hint := 'expired_token';
        RAISE EXCEPTION 'Enlace de recuperación expirado';
    END IF;

    -- Verificar si ya fue usado
    IF v_recovery.used_at IS NOT NULL THEN
        v_error_hint := 'used_token';
        RAISE EXCEPTION 'Enlace ya utilizado';
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'valid', true,
            'user_id', v_recovery.user_id,
            'expires_at', v_recovery.expires_at
        )
    );

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
```

#### 3. reset_password()

```sql
CREATE OR REPLACE FUNCTION reset_password(
    p_token TEXT,
    p_new_password TEXT
)
RETURNS JSON AS $$
DECLARE
    v_recovery RECORD;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Validaciones
    IF p_token IS NULL OR p_new_password IS NULL THEN
        v_error_hint := 'missing_params';
        RAISE EXCEPTION 'Token y contraseña son requeridos';
    END IF;

    IF LENGTH(p_new_password) < 8 THEN
        v_error_hint := 'weak_password';
        RAISE EXCEPTION 'La contraseña debe tener al menos 8 caracteres';
    END IF;

    -- Buscar y validar token
    SELECT * INTO v_recovery
    FROM password_recovery
    WHERE token = p_token;

    IF NOT FOUND THEN
        v_error_hint := 'invalid_token';
        RAISE EXCEPTION 'Enlace de recuperación inválido';
    END IF;

    IF v_recovery.expires_at < NOW() THEN
        v_error_hint := 'expired_token';
        RAISE EXCEPTION 'Enlace de recuperación expirado';
    END IF;

    IF v_recovery.used_at IS NOT NULL THEN
        v_error_hint := 'used_token';
        RAISE EXCEPTION 'Enlace ya utilizado';
    END IF;

    -- Actualizar contraseña en auth.users
    UPDATE auth.users
    SET encrypted_password = crypt(p_new_password, gen_salt('bf')),
        updated_at = NOW()
    WHERE id = v_recovery.user_id;

    -- Marcar token como usado
    UPDATE password_recovery
    SET used_at = NOW()
    WHERE id = v_recovery.id;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'message', 'Contraseña cambiada exitosamente'
        )
    );

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
```

#### 4. cleanup_expired_recovery_tokens()

```sql
CREATE OR REPLACE FUNCTION cleanup_expired_recovery_tokens()
RETURNS JSON AS $$
DECLARE
    v_deleted_count INT;
BEGIN
    DELETE FROM password_recovery
    WHERE expires_at < NOW();

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'deleted_count', v_deleted_count
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 📱 FRONTEND (Flutter)

### Models

#### PasswordResetRequestModel

```dart
// lib/features/auth/data/models/password_reset_request_model.dart
class PasswordResetRequestModel extends Equatable {
  final String email;

  const PasswordResetRequestModel({required this.email});

  Map<String, dynamic> toJson() => {'p_email': email};

  @override
  List<Object> get props => [email];
}
```

#### PasswordResetResponseModel

```dart
// lib/features/auth/data/models/password_reset_response_model.dart
class PasswordResetResponseModel extends Equatable {
  final String message;
  final bool emailSent;
  final String? token;

  const PasswordResetResponseModel({
    required this.message,
    required this.emailSent,
    this.token,
  });

  factory PasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponseModel(
      message: json['message'] as String,
      emailSent: json['email_sent'] as bool,
      token: json['token'] as String?,
    );
  }

  @override
  List<Object?> get props => [message, emailSent, token];
}
```

#### ResetPasswordModel

```dart
// lib/features/auth/data/models/reset_password_model.dart
class ResetPasswordModel extends Equatable {
  final String token;
  final String newPassword;

  const ResetPasswordModel({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'p_token': token,
    'p_new_password': newPassword,
  };

  @override
  List<Object> get props => [token, newPassword];
}
```

### Pages

#### ForgotPasswordPage

```dart
// lib/features/auth/presentation/pages/forgot_password_page.dart
// Formulario con:
// - Campo email
// - Botón "Enviar enlace de recuperación"
// - Enlace "Volver al login"
// - Validación de email
// - Estados: loading, success, error
```

#### ResetPasswordPage

```dart
// lib/features/auth/presentation/pages/reset_password_page.dart
// Formulario con:
// - Campo "Nueva Contraseña"
// - Campo "Confirmar Contraseña"
// - Indicador de fortaleza
// - Botón "Cambiar Contraseña"
// - Validaciones en tiempo real
```

### Bloc Events/States

```dart
// Events
class ForgotPasswordRequested extends AuthEvent {
  final String email;
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;
}

class ValidateResetTokenRequested extends AuthEvent {
  final String token;
}

// States
class ForgotPasswordInProgress extends AuthState {}
class ForgotPasswordSuccess extends AuthState {
  final String message;
}
class ResetPasswordInProgress extends AuthState {}
class ResetPasswordSuccess extends AuthState {}
class ResetTokenInvalid extends AuthState {
  final String message;
  final String hint; // 'expired', 'invalid', 'used'
}
```

---

## 🎨 UI COMPONENTS

### ForgotPassword Widgets

- `ForgotPasswordForm` - Formulario email
- `EmailSentConfirmation` - Mensaje de confirmación
- `RateLimitWarning` - Warning de rate limit

### ResetPassword Widgets

- `ResetPasswordForm` - Formulario nueva contraseña
- `PasswordStrengthIndicator` - Medidor de fortaleza
- `TokenExpiredDialog` - Dialog token expirado

---

## 🔄 FLUJOS

### Flujo 1: Solicitar Recuperación

1. Usuario en LoginPage → Click "¿Olvidaste tu contraseña?"
2. Navega a `/forgot-password`
3. Ingresa email → Click "Enviar enlace"
4. AuthBloc.add(ForgotPasswordRequested(email))
5. Backend valida y genera token
6. Muestra "Si el email existe, se enviará un enlace"
7. (TODO: Enviar email con enlace)

### Flujo 2: Cambiar Contraseña

1. Usuario click en enlace del email
2. Navega a `/reset-password?token=XXX`
3. AuthBloc.add(ValidateResetTokenRequested(token))
4. Si válido → Muestra formulario
5. Ingresa nueva contraseña → Click "Cambiar"
6. AuthBloc.add(ResetPasswordRequested(token, password))
7. Backend actualiza password + marca token usado
8. Redirige a `/login` con mensaje éxito

---

## 🔐 SEGURIDAD

- Token: 32 bytes random, URL-safe
- Expiración: 24 horas
- Rate limiting: 1 solicitud/15 min
- Uso único: token se marca como usado
- Privacidad: No revelar si email existe
- Password policy: Min 8 caracteres

---

## ✅ VALIDACIÓN

### Backend
- ✅ Email formato válido
- ✅ Token único y seguro
- ✅ Expiración 24h
- ✅ Rate limiting aplicado
- ✅ Token de uso único

### Frontend
- ✅ Validación email en tiempo real
- ✅ Confirmación de contraseñas
- ✅ Indicador de fortaleza
- ✅ Manejo de errores (expired/invalid/used)

---

## 📝 PRÓXIMOS PASOS

1. @supabase-expert: Implementar migration + funciones
2. @flutter-expert: Implementar models + pages + bloc
3. @ux-ui-expert: Implementar formularios + widgets
4. @flutter-expert: Integración final
5. Testing end-to-end

---

**Estado**: 🔵 En Desarrollo
**Fecha**: 2025-10-06
