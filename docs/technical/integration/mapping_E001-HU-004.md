# Mapping Integración - HU-004: Recuperar Contraseña

**Epic**: E001 - Autenticación
**Historia**: HU-004 - Recuperar Contraseña
**Fecha**: 2025-10-06
**Estado**: ✅ INTEGRACIÓN COMPLETA - Backend + Frontend Verificado

---

## Convenciones de Naming

### PostgreSQL (Backend)
- **Tablas**: singular, snake_case → `password_recovery`
- **Columnas**: snake_case → `user_id`, `expires_at`, `created_at`
- **Funciones**: snake_case → `request_password_reset()`
- **Parámetros**: p_ prefix → `p_email`, `p_token`, `p_new_password`

### Dart/Flutter (Frontend)
- **Classes**: PascalCase → `PasswordResetRequestModel`, `ResetPasswordModel`
- **Properties**: camelCase → `userId`, `expiresAt`, `createdAt`
- **Methods**: camelCase → `requestPasswordReset()`, `resetPassword()`
- **Files**: snake_case → `password_reset_request_model.dart`

---

## Tabla: password_recovery

| PostgreSQL (DB) | Dart (Frontend) | Tipo PostgreSQL | Tipo Dart | Notas |
|-----------------|-----------------|-----------------|-----------|-------|
| id | id | UUID | String | Identificador único del token |
| user_id | userId | UUID | String | FK a auth.users |
| email | email | TEXT | String | Email del usuario |
| token | token | TEXT | String | Token seguro URL-safe |
| expires_at | expiresAt | TIMESTAMP WITH TIME ZONE | DateTime | Expiración 24h |
| used_at | usedAt | TIMESTAMP WITH TIME ZONE | DateTime? | Nullable, marca uso |
| ip_address | ipAddress | INET | String? | Nullable, IP origen |
| created_at | createdAt | TIMESTAMP WITH TIME ZONE | DateTime | Timestamp creación |

---

## Función: request_password_reset()

### Parámetros PostgreSQL → Dart

| PostgreSQL | Dart Property | Tipo SQL | Tipo Dart | Requerido |
|------------|---------------|----------|-----------|-----------|
| p_email | email | TEXT | String | ✅ |
| p_ip_address | ipAddress | INET | String? | ❌ |

### Respuesta JSON → Dart Model

**Success Case:**
```json
{
  "success": true,
  "data": {
    "message": "Si el email existe, se enviara un enlace de recuperacion",
    "email_sent": true,
    "token": "AbCdEfGh1234...",
    "expires_at": "2025-10-07T21:45:00Z"
  }
}
```

**Dart Model:** `PasswordResetResponseModel`
```dart
class PasswordResetResponseModel {
  final String message;
  final bool emailSent;
  final String? token;
  final DateTime? expiresAt;
}
```

**Error Case:**
```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Ya se enviaron varios enlaces recientemente. Espera 15 minutos",
    "hint": "rate_limit"
  }
}
```

**Dart Model:** `PasswordResetErrorModel`
```dart
class PasswordResetErrorModel {
  final String code;
  final String message;
  final String hint;
}
```

---

## Función: validate_reset_token()

### Parámetros PostgreSQL → Dart

| PostgreSQL | Dart Property | Tipo SQL | Tipo Dart | Requerido |
|------------|---------------|----------|-----------|-----------|
| p_token | token | TEXT | String | ✅ |

### Respuesta JSON → Dart Model

**Success Case:**
```json
{
  "success": true,
  "data": {
    "is_valid": true,
    "user_id": "uuid-del-usuario",
    "email": "user@example.com",
    "expires_at": "2025-10-07T21:45:00Z"
  }
}
```

**Dart Model:** `TokenValidationResponseModel`
```dart
class TokenValidationResponseModel {
  final bool isValid;
  final String userId;
  final String email;
  final DateTime expiresAt;
}
```

### Error Hints Mapping

| PostgreSQL Hint | Dart Enum | UI Message |
|-----------------|-----------|------------|
| missing_token | TokenError.missing | "Token es requerido" |
| invalid_token | TokenError.invalid | "Enlace de recuperación inválido" |
| expired_token | TokenError.expired | "Enlace de recuperación expirado" |
| used_token | TokenError.used | "Enlace ya utilizado" |

---

## Edge Function: reset-password

**⚠️ IMPORTANTE**: Esta función migró de RPC a Edge Function para evitar conflictos con auth.users.

**Endpoint**: `http://127.0.0.1:54321/functions/v1/reset-password`

### Parámetros PostgreSQL → Dart

| PostgreSQL | Dart Property | Tipo SQL | Tipo Dart | Requerido |
|------------|---------------|----------|-----------|-----------|
| p_token | token | TEXT | String | ✅ |
| p_new_password | newPassword | TEXT | String | ✅ |
| p_ip_address | ipAddress | INET | String? | ❌ |

### Respuesta JSON → Dart Model

**Success Case:**
```json
{
  "success": true,
  "data": {
    "message": "Contrasena cambiada exitosamente"
  }
}
```

**Dart Model:** `ResetPasswordResponseModel`
```dart
class ResetPasswordResponseModel {
  final String message;
}
```

### Error Hints Mapping

| PostgreSQL Hint | Dart Enum | UI Message |
|-----------------|-----------|------------|
| missing_token | PasswordResetError.missingToken | "Token es requerido" |
| missing_password | PasswordResetError.missingPassword | "Contraseña es requerida" |
| weak_password | PasswordResetError.weakPassword | "La contraseña debe tener al menos 8 caracteres" |
| invalid_token | PasswordResetError.invalidToken | "Enlace de recuperación inválido" |
| expired_token | PasswordResetError.expiredToken | "Enlace de recuperación expirado" |
| used_token | PasswordResetError.usedToken | "Enlace ya utilizado" |

---

## Función: cleanup_expired_recovery_tokens()

### Respuesta JSON → Dart Model

**Success Case:**
```json
{
  "success": true,
  "data": {
    "deleted_count": 42,
    "cleaned_at": "2025-10-06T21:45:00Z"
  }
}
```

**Dart Model:** `CleanupResponseModel`
```dart
class CleanupResponseModel {
  final int deletedCount;
  final DateTime cleanedAt;
}
```

---

## Rutas Frontend (GoRouter)

| Ruta | Página | Funcionalidad |
|------|--------|---------------|
| `/forgot-password` | ForgotPasswordPage | Solicitar recuperación |
| `/reset-password/:token` | ResetPasswordPage | Cambiar contraseña |

### Navegación

```dart
// Desde LoginPage (login_form.dart línea 134)
context.go('/forgot-password');

// Desde email link (pathParameter en GoRouter)
// URL: https://app.com/reset-password/AbCdEfGh1234...
// GoRouter extrae token automáticamente

// Después de reset exitoso (reset_password_page.dart línea 356)
context.go('/login');
```

---

## Eventos BLoC

### Eventos

| Evento Dart | Función PostgreSQL | Parámetros |
|-------------|-------------------|------------|
| ForgotPasswordRequested | request_password_reset() | email, ipAddress? |
| ValidateResetTokenRequested | validate_reset_token() | token |
| ResetPasswordRequested | reset_password() | token, newPassword, ipAddress? |

### Estados

| Estado Dart | Condición |
|-------------|-----------|
| ForgotPasswordInProgress | Ejecutando request_password_reset() |
| ForgotPasswordSuccess | Solicitud enviada exitosamente |
| ForgotPasswordFailure | Error en solicitud (rate limit, etc) |
| TokenValidationInProgress | Ejecutando validate_reset_token() |
| TokenValidationSuccess | Token válido |
| TokenValidationFailure | Token inválido/expirado/usado |
| ResetPasswordInProgress | Ejecutando reset_password() |
| ResetPasswordSuccess | Password cambiada exitosamente |
| ResetPasswordFailure | Error al cambiar password |

---

## Validaciones Frontend vs Backend

### Email Validation

**Frontend (Dart):**
```dart
final emailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
if (!emailRegex.hasMatch(email)) {
  return 'Formato de email inválido';
}
```

**Backend (PostgreSQL):**
```sql
IF p_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
    RAISE EXCEPTION 'Formato de email invalido';
END IF;
```

### Password Strength

**Frontend (Dart):**
```dart
if (password.length < 8) {
  return 'La contraseña debe tener al menos 8 caracteres';
}
```

**Backend (PostgreSQL):**
```sql
IF LENGTH(p_new_password) < 8 THEN
    RAISE EXCEPTION 'La contrasena debe tener al menos 8 caracteres';
END IF;
```

### Rate Limiting

**Backend Only:**
```sql
-- Máximo 3 solicitudes en 15 minutos
SELECT COUNT(*) INTO v_request_count
FROM password_recovery
WHERE user_id = v_user_id
  AND created_at > NOW() - INTERVAL '15 minutes';

IF v_request_count >= 3 THEN
    RAISE EXCEPTION 'Ya se enviaron varios enlaces recientemente. Espera 15 minutos';
END IF;
```

**Frontend (Dart):**
```dart
// Mostrar error del backend
if (error.hint == 'rate_limit') {
  showErrorSnackbar('Ya se enviaron varios enlaces. Espera 15 minutos');
}
```

---

## Ejemplo de Integración Completa

### 1. Solicitar Recuperación

**Frontend:**
```dart
// Event
context.read<AuthBloc>().add(
  ForgotPasswordRequested(email: emailController.text),
);

// Listener
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is ForgotPasswordSuccess) {
      showSuccessSnackbar(state.message);
    } else if (state is ForgotPasswordFailure) {
      showErrorSnackbar(state.error.message);
    }
  },
)
```

**Backend Call (RPC):**
```dart
// request_password_reset() y validate_reset_token() usan RPC
final response = await supabase.rpc('request_password_reset', params: {
  'p_email': email,
  'p_ip_address': null, // Opcional
});

final result = response as Map<String, dynamic>;
if (result['success'] == true) {
  return PasswordResetResponseModel.fromJson(result['data']);
} else {
  final error = result['error'] as Map<String, dynamic>;
  throw RateLimitException(error['message']); // Según hint
}
```

**Backend Call (Edge Function):**
```dart
// reset_password() usa Edge Function
final response = await supabase.functions.invoke(
  'reset-password',
  body: {
    'token': token,
    'new_password': newPassword,
  },
);

if (response.status != 200) {
  final error = response.data['error'];
  throw InvalidTokenException(error['message']); // Según hint
}
```

### 2. Validar Token

**Frontend:**
```dart
// Event
context.read<AuthBloc>().add(
  ValidateResetTokenRequested(token: token),
);

// State
if (state is TokenValidationSuccess) {
  // Mostrar formulario
} else if (state is TokenValidationFailure) {
  // Mostrar error según hint
  switch (state.error.hint) {
    case 'expired_token':
      showExpiredTokenDialog();
      break;
    case 'invalid_token':
      showInvalidTokenDialog();
      break;
    case 'used_token':
      showUsedTokenDialog();
      break;
  }
}
```

### 3. Cambiar Password

**Frontend:**
```dart
// Event
context.read<AuthBloc>().add(
  ResetPasswordRequested(
    token: token,
    newPassword: passwordController.text,
  ),
);

// State
if (state is ResetPasswordSuccess) {
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
    arguments: {'message': 'Contraseña cambiada exitosamente'},
  );
}
```

---

## Casos de Uso

### Caso 1: Usuario olvidó contraseña

1. Usuario → `/login` → Click "¿Olvidaste tu contraseña?"
2. Navega a `/forgot-password`
3. Ingresa email → Click "Enviar enlace"
4. AuthBloc → `request_password_reset(email)`
5. Backend valida y genera token
6. Frontend muestra "Si el email existe, se enviará un enlace"
7. (TODO) Enviar email con enlace

### Caso 2: Usuario recibe email y cambia contraseña

1. Usuario click enlace en email
2. Navega a `/reset-password?token=XXX`
3. AuthBloc → `validate_reset_token(token)`
4. Si válido → Muestra formulario
5. Usuario ingresa nueva contraseña
6. AuthBloc → `reset_password(token, password)`
7. Backend actualiza password + invalida sesiones
8. Redirige a `/login` con mensaje éxito

### Caso 3: Token expirado

1. Usuario click enlace expirado (>24h)
2. Navega a `/reset-password?token=XXX`
3. AuthBloc → `validate_reset_token(token)`
4. Backend retorna error `expired_token`
5. Frontend muestra dialog "Enlace expirado"
6. Opción "Solicitar nuevo enlace" → `/forgot-password`

### Caso 4: Rate limiting

1. Usuario solicita recuperación
2. Usuario intenta solicitar otra vez inmediatamente
3. Backend retorna error `rate_limit`
4. Frontend muestra "Ya se envió un enlace. Espera 15 minutos"

---

## Error Handling

### Error Types

```dart
enum PasswordRecoveryError {
  // Solicitud
  invalidEmail,
  rateLimited,
  networkError,

  // Validación
  missingToken,
  invalidToken,
  expiredToken,
  usedToken,

  // Reset
  weakPassword,
  passwordMismatch,

  // General
  unknown,
}
```

### Error Messages

```dart
Map<PasswordRecoveryError, String> errorMessages = {
  PasswordRecoveryError.invalidEmail: 'Formato de email inválido',
  PasswordRecoveryError.rateLimited: 'Ya se enviaron varios enlaces. Espera 15 minutos',
  PasswordRecoveryError.networkError: 'Error de conexión. Intenta nuevamente',
  PasswordRecoveryError.missingToken: 'Token es requerido',
  PasswordRecoveryError.invalidToken: 'Enlace de recuperación inválido',
  PasswordRecoveryError.expiredToken: 'Enlace de recuperación expirado',
  PasswordRecoveryError.usedToken: 'Enlace ya utilizado',
  PasswordRecoveryError.weakPassword: 'La contraseña debe tener al menos 8 caracteres',
  PasswordRecoveryError.passwordMismatch: 'Las contraseñas no coinciden',
  PasswordRecoveryError.unknown: 'Error desconocido. Contacta soporte',
};
```

---

## Testing

### Unit Tests

```dart
// Test models
test('PasswordResetRequestModel toJson()', () {
  final model = PasswordResetRequestModel(email: 'test@example.com');
  expect(model.toJson(), {'p_email': 'test@example.com'});
});

// Test response parsing
test('PasswordResetResponseModel fromJson()', () {
  final json = {
    'message': 'Si el email existe...',
    'email_sent': true,
    'token': 'abc123',
    'expires_at': '2025-10-07T21:45:00Z',
  };
  final model = PasswordResetResponseModel.fromJson(json);
  expect(model.emailSent, true);
  expect(model.token, 'abc123');
});
```

### Integration Tests

```dart
testWidgets('Complete password recovery flow', (tester) async {
  // 1. Navigate to forgot password
  await tester.tap(find.text('¿Olvidaste tu contraseña?'));
  await tester.pumpAndSettle();

  // 2. Enter email
  await tester.enterText(find.byType(TextField), 'test@example.com');
  await tester.tap(find.text('Enviar enlace'));
  await tester.pumpAndSettle();

  // 3. Verify success message
  expect(find.text('Si el email existe...'), findsOneWidget);

  // ... rest of flow
});
```

---

## Estado de Integración

### Backend
- ✅ 3 RPCs implementadas: `request_password_reset()`, `validate_reset_token()`, `cleanup_expired_recovery_tokens()`
- ✅ Edge Function implementada: `reset-password` (migrado de RPC)
- ✅ Tabla `password_recovery` con campos completos
- ✅ Rate limiting: 3 solicitudes cada 15 minutos
- ✅ Tokens con expiración 24h

### Frontend
- ✅ Models: `PasswordResetRequestModel`, `PasswordResetResponseModel`, `ResetPasswordModel`, `ValidateResetTokenModel`
- ✅ DataSource: `AuthRemoteDataSourceImpl` con 3 métodos HU-004
- ✅ Repository: `AuthRepositoryImpl` con manejo robusto de excepciones
- ✅ Bloc: `AuthBloc` con 3 event handlers (PasswordResetRequested, ResetPasswordRequested, ValidateResetTokenRequested)
- ✅ UI: `ForgotPasswordPage` y `ResetPasswordPage` implementadas
- ✅ Routing: `/forgot-password` y `/reset-password/:token` configurados
- ✅ Validaciones frontend: Email formato, password strength, confirmación
- ✅ Manejo de errores: Token inválido/expirado/usado con dialogs específicos

### Integración Verificada
- ✅ DataSource usa Edge Function `supabase.functions.invoke('reset-password')`
- ✅ Flujo completo: LoginPage → ForgotPasswordPage → ResetPasswordPage → LoginPage
- ✅ Dependency Injection: AuthBloc/AuthRepository registrados correctamente
- ✅ Compilación sin errores (solo warnings menores)
- ✅ Navegación GoRouter funcionando

### Pendientes
- ⏳ Configurar envío real de emails (actualmente retorna token para testing)
- ⏳ Testing end-to-end con Supabase real (@qa-testing-expert)
- ⏳ Deployment de Edge Function a producción

---

**Documentado por**: @supabase-expert + @flutter-expert
**Última actualización**: 2025-10-06 (Integración completa verificada)
