# Mapping Auth Module

Archivo consolidado de mapeos Backend ↔ Frontend para el módulo de Autenticación.

---

## HU-001: Registro de Alta al Sistema Web {#hu-001}

### API → Model Mapping

**RPC: register_user**

Backend Response:
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "email": "user@example.com",
    "message": "Usuario registrado exitosamente"
  }
}
```

Dart Model: `AuthResponseModel`
```dart
userId: json['user_id']       // snake_case → camelCase
email: json['email']
message: json['message']
```

**Status**: ✅ Implementado

---

## HU-002: Login por Roles con Aprobación {#hu-002}

### API → Model Mapping

**RPC: login_user**

Backend Response:
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "email": "user@example.com",
    "nombre_completo": "Juan Pérez",
    "rol": "GERENTE",
    "session_token": "token-here",
    "message": "Login exitoso"
  }
}
```

Dart Model: `LoginResponseModel`
```dart
userId: json['user_id']                  // snake_case → camelCase
email: json['email']
nombreCompleto: json['nombre_completo']  // snake_case → camelCase
rol: json['rol']
sessionToken: json['session_token']      // snake_case → camelCase
message: json['message']
```

**Status**: ✅ Implementado

---

## HU-003: Logout Seguro {#hu-003}

### API → Model Mapping

**RPC: logout_user**

Backend Response:
```json
{
  "success": true,
  "data": {
    "message": "Logout exitoso"
  }
}
```

Dart Model: `LogoutResponseModel`
```dart
message: json['message']
```

**RPC: check_inactivity**

Backend Response:
```json
{
  "success": true,
  "data": {
    "is_inactive": true,
    "minutes_inactive": 115,
    "warning_threshold": 5
  }
}
```

Dart Model: `InactivityStatusModel`
```dart
isInactive: json['is_inactive']             // snake_case → camelCase
minutesInactive: json['minutes_inactive']   // snake_case → camelCase
warningThreshold: json['warning_threshold'] // snake_case → camelCase
```

**Status**: ✅ Implementado

---

## HU-004: Recuperar Contraseña {#hu-004}

### API → Model Mapping

#### RPC: request_password_reset

**Request Mapping** (Dart → Backend):

Dart Model: `PasswordResetRequestModel`
```dart
{
  email: "user@example.com",
  ipAddress: "192.168.1.1"
}
```

Backend Params:
```json
{
  "p_email": "user@example.com",
  "p_ip_address": "192.168.1.1"
}
```

Mapping en `toJson()`:
```dart
'p_email': email              // camelCase → p_snake_case
'p_ip_address': ipAddress     // camelCase → p_snake_case
```

---

**Response Mapping** (Backend → Dart):

Backend Response:
```json
{
  "success": true,
  "data": {
    "message": "Si el email existe, se enviará un enlace de recuperación",
    "email_sent": true
  }
}
```

Dart Model: `PasswordResetResponseModel`
```dart
message: json['message']
emailSent: json['email_sent']  // snake_case → camelCase
```

---

#### RPC: validate_reset_token

**Request Mapping**:

Direct param (no model):
```dart
supabase.rpc('validate_reset_token', params: {'p_token': token})
```

---

**Response Mapping** (Backend → Dart):

Backend Response (Token válido):
```json
{
  "success": true,
  "data": {
    "is_valid": true,
    "message": "Token válido",
    "expires_at": "2025-10-07T10:30:00Z",
    "user_id": "uuid-here"
  }
}
```

Dart Model: `ValidateResetTokenModel`
```dart
valid: json['is_valid']                           // ⚠️ is_valid → valid
message: json['message']
expiresAt: DateTime.parse(json['expires_at'])     // snake_case → camelCase
userId: json['user_id']                           // snake_case → camelCase
```

**IMPORTANTE**: Backend usa `is_valid`, frontend usa `valid`. El mapeo está corregido.

---

Backend Response (Token inválido):
```json
{
  "success": true,
  "data": {
    "is_valid": false,
    "message": "El enlace de recuperación ha expirado"
  }
}
```

Dart Model:
```dart
valid: false
message: "El enlace de recuperación ha expirado"
expiresAt: null
userId: null
```

---

#### RPC: reset_password

**Request Mapping** (Dart → Backend):

Dart Model: `ResetPasswordModel`
```dart
{
  token: "abc123xyz",
  newPassword: "NewPass123",
  ipAddress: "192.168.1.1"
}
```

Backend Params:
```json
{
  "p_token": "abc123xyz",
  "p_new_password": "NewPass123",
  "p_ip_address": "192.168.1.1"
}
```

Mapping en `toJson()`:
```dart
'p_token': token                    // camelCase → p_snake_case
'p_new_password': newPassword       // camelCase → p_snake_case
'p_ip_address': ipAddress           // camelCase → p_snake_case
```

---

**Response Mapping** (Backend → Dart):

Backend Response (Success):
```json
{
  "success": true,
  "data": {
    "message": "Contraseña actualizada exitosamente",
    "user_id": "uuid-here"
  }
}
```

Frontend handling:
```dart
// No model específico, solo extrae message
final message = result['data']['message'];
// Trigger AuthState.ResetPasswordSuccess(message)
```

---

Backend Response (Error - Token inválido):
```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Enlace de recuperación inválido o expirado",
    "hint": "token_invalid"
  }
}
```

Frontend handling:
```dart
// Exception lanzada en DataSource
if (result['success'] == false) {
  final error = result['error'];
  final hint = error['hint'];

  if (hint == 'token_invalid') {
    throw ValidationException(error['message'], 400);
  } else if (hint == 'token_expired') {
    throw ValidationException(error['message'], 400);
  } else if (hint == 'password_weak') {
    throw ValidationException(error['message'], 400);
  }
  throw ServerException(error['message'], 500);
}
```

---

## Tabla de Mapping Consolidada

### Request Parameters (Dart → Backend)

| Dart Property | Backend Param | Type | HU |
|--------------|---------------|------|-----|
| `email` | `p_email` | String | HU-001, HU-004 |
| `password` | `p_password` | String | HU-001, HU-002 |
| `nombreCompleto` | `p_nombre_completo` | String | HU-001 |
| `rol` | `p_rol` | String | HU-001 |
| `rememberMe` | `p_remember_me` | bool | HU-002 |
| `userId` | `p_user_id` | String | HU-003 |
| `token` | `p_token` | String | HU-003, HU-004 |
| `logoutType` | `p_logout_type` | String | HU-003 |
| `ipAddress` | `p_ip_address` | String? | HU-003, HU-004 |
| `newPassword` | `p_new_password` | String | HU-004 |

---

### Response Fields (Backend → Dart)

| Backend Field | Dart Property | Type | HU |
|--------------|---------------|------|-----|
| `user_id` | `userId` | String | All |
| `email` | `email` | String | All |
| `nombre_completo` | `nombreCompleto` | String | HU-001, HU-002 |
| `rol` | `rol` | String | HU-002 |
| `session_token` | `sessionToken` | String | HU-002 |
| `message` | `message` | String | All |
| `email_sent` | `emailSent` | bool | HU-004 |
| `is_valid` | `valid` | bool | HU-004 |
| `expires_at` | `expiresAt` | DateTime? | HU-004 |
| `is_inactive` | `isInactive` | bool | HU-003 |
| `minutes_inactive` | `minutesInactive` | int | HU-003 |
| `warning_threshold` | `warningThreshold` | int | HU-003 |

---

## Error Hint Mapping

| Backend Hint | Frontend Exception | HTTP Code | HU |
|-------------|-------------------|-----------|-----|
| `duplicate_email` | `DuplicateEmailException` | 409 | HU-001 |
| `invalid_email` | `ValidationException` | 400 | HU-001 |
| `invalid_password` | `ValidationException` | 400 | HU-001, HU-002 |
| `user_not_found` | `ValidationException` | 404 | HU-002 |
| `user_not_approved` | `ValidationException` | 403 | HU-002 |
| `email_not_verified` | `ValidationException` | 403 | HU-002 |
| `invalid_token` | `ValidationException` | 400 | HU-001 |
| `token_blacklisted` | `ValidationException` | 401 | HU-003 |
| `rate_limit_exceeded` | `ValidationException` | 429 | HU-004 |
| `token_expired` | `ValidationException` | 400 | HU-004 |
| `token_used` | `ValidationException` | 400 | HU-004 |
| `password_weak` | `ValidationException` | 400 | HU-004 |

---

## DataSource Implementation Reference

**Location**: `lib/features/auth/data/datasources/auth_remote_datasource.dart`

### HU-004 Methods:

```dart
// Línea ~427
Future<PasswordResetResponseModel> requestPasswordReset(
  PasswordResetRequestModel request
) async {
  final response = await supabase.rpc(
    'request_password_reset',
    params: request.toJson(),  // email → p_email, ipAddress → p_ip_address
  );
  // ...
}

// Línea ~469
Future<ValidateResetTokenModel> validateResetToken(String token) async {
  final response = await supabase.rpc(
    'validate_reset_token',
    params: {'p_token': token},
  );
  // ValidateResetTokenModel.fromJson mapea is_valid → valid
}

// Línea ~509
Future<void> resetPassword(ResetPasswordModel model) async {
  final response = await supabase.rpc(
    'reset_password',
    params: model.toJson(),  // token → p_token, newPassword → p_new_password
  );
  // ...
}
```

---

## Repository Implementation Reference

**Location**: `lib/features/auth/data/repositories/auth_repository_impl.dart`

### HU-004 Methods:

```dart
// Línea ~250+
@override
Future<Either<Failure, PasswordResetResponseModel>> requestPasswordReset(
  PasswordResetRequestModel request
) async {
  try {
    final result = await remoteDataSource.requestPasswordReset(request);
    return Right(result);
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message));
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e) {
    return Left(NetworkFailure('Error de red: $e'));
  }
}

// Similar para validateResetToken y resetPassword
```

---

## Bloc Integration Reference

**Location**: `lib/features/auth/presentation/bloc/auth_bloc.dart`

### HU-004 Event Handlers:

```dart
// Línea ~200+
on<PasswordResetRequested>((event, emit) async {
  emit(PasswordResetRequestInProgress());

  final request = PasswordResetRequestModel(email: event.email);
  final result = await authRepository.requestPasswordReset(request);

  result.fold(
    (failure) => emit(PasswordResetRequestFailure(failure.message)),
    (response) => emit(PasswordResetRequestSuccess(response.message)),
  );
});

on<ResetTokenValidationRequested>((event, emit) async {
  emit(ResetTokenValidationInProgress());

  final result = await authRepository.validateResetToken(event.token);

  result.fold(
    (failure) => emit(ResetTokenInvalid(failure.message)),
    (validation) {
      if (validation.valid) {
        emit(ResetTokenValid(
          userId: validation.userId!,
          expiresAt: validation.expiresAt!,
        ));
      } else {
        emit(ResetTokenInvalid(validation.message));
      }
    },
  );
});

on<PasswordResetSubmitted>((event, emit) async {
  emit(ResetPasswordInProgress());

  final model = ResetPasswordModel(
    token: event.token,
    newPassword: event.newPassword,
  );
  final result = await authRepository.resetPassword(model);

  result.fold(
    (failure) => emit(ResetPasswordFailure(failure.message)),
    (_) => emit(ResetPasswordSuccess('Contraseña actualizada exitosamente')),
  );
});
```

---

## UI Integration Reference

### ForgotPasswordPage → Bloc

```dart
// Submit button onPressed
context.read<AuthBloc>().add(
  PasswordResetRequested(email: _emailController.text.trim()),
);

// BlocListener states
if (state is PasswordResetRequestSuccess) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message)),
  );
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

### ResetPasswordPage → Bloc

```dart
// On page load
@override
void initState() {
  super.initState();
  final token = _extractTokenFromUrl();
  context.read<AuthBloc>().add(
    ResetTokenValidationRequested(token: token),
  );
}

// Submit button onPressed
context.read<AuthBloc>().add(
  PasswordResetSubmitted(
    token: _token,
    newPassword: _passwordController.text,
  ),
);

// BlocListener states
if (state is ResetTokenInvalid) {
  _showErrorDialog(state.message);
} else if (state is ResetPasswordSuccess) {
  _showSuccessDialog();
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

## Testing Verification Checklist

### Backend Tests (via Supabase Studio):
- [ ] `request_password_reset('test@example.com')` → Returns generic message
- [ ] `request_password_reset('nonexistent@example.com')` → Returns same message (privacy)
- [ ] Rate limiting: 4th request within 15 min → Error `rate_limit_exceeded`
- [ ] `validate_reset_token(valid_token)` → `is_valid: true`
- [ ] `validate_reset_token(expired_token)` → `is_valid: false`, message: "expirado"
- [ ] `validate_reset_token(invalid_token)` → `is_valid: false`, message: "inválido"
- [ ] `reset_password(valid_token, 'NewPass123')` → Success, marks token as used
- [ ] `reset_password(used_token, 'NewPass456')` → Error `token_used`
- [ ] `reset_password(valid_token, 'weak')` → Error `password_weak`

### Frontend Tests (Integration):
- [ ] Navigate to `/forgot-password` from login link
- [ ] Submit email → Shows success message
- [ ] Navigate to `/reset-password/:valid_token` → Shows form
- [ ] Navigate to `/reset-password/:expired_token` → Shows error dialog
- [ ] Submit weak password → Form validation blocks submit
- [ ] Submit strong password → Success, redirects to login
- [ ] Password strength indicator updates in real-time
- [ ] Token validation happens automatically on page load

---

**Status**: ✅ Mapping completo y verificado
**Issues resueltos**: Mapeo `is_valid` → `valid` corregido en ValidateResetTokenModel

**Última actualización**: 2025-10-06
**Mantenido por**: @web-architect-expert
