# HU-002: Login al Sistema - Índice Técnico

**Historia de Usuario**: E001-HU-002
**Estado**: 🔵 En Desarrollo
**Story Points**: 3 pts

---

## 📋 RESUMEN

Login básico con email/contraseña para usuarios registrados y aprobados. Incluye validaciones de estado, sesiones persistentes con "Recordarme" y manejo de tokens expirados.

---

## 📐 DOCUMENTACIÓN TÉCNICA

### Backend (Supabase)

| Documento | Descripción | Estado |
|-----------|-------------|--------|
| [apis_hu002.md](backend/apis_hu002.md) | Funciones `login_user()`, `validate_token()`, rate limiting | 🔵 Diseñado |
| [schema_hu001.md](backend/schema_hu001.md) | Tabla `users` (reutilizada de HU-001) | ✅ Implementado |

### Frontend (Flutter)

| Documento | Descripción | Estado |
|-----------|-------------|--------|
| [models_hu002.md](frontend/models_hu002.md) | `LoginRequestModel`, `LoginResponseModel`, `AuthStateModel` | 🔵 Diseñado |
| [design/components_hu002.md](design/components_hu002.md) | `LoginPage`, `LoginForm`, `HomePage`, `AuthGuard` | 🔵 Diseñado |

### Integración

| Documento | Descripción | Estado |
|-----------|-------------|--------|
| [integration/mapping_hu002.md](integration/mapping_hu002.md) | Mapping completo BD ↔ Dart para login | 🔵 Diseñado |

---

## 🔄 FLUJO DE IMPLEMENTACIÓN

### 1️⃣ Backend (@supabase-expert)

**Archivo a crear**: `supabase/migrations/YYYYMMDDHHMMSS_hu002_login_functions.sql`

**Implementar**:
- ✅ Tabla `login_attempts` para rate limiting
- ✅ Función `check_login_rate_limit()`
- ✅ Función `login_user()` con validaciones completas
- ✅ Función `validate_token()` para sesiones persistentes

**Testing**:
```sql
-- Test 1: Login exitoso
SELECT login_user('user@example.com', 'Password123!', false);

-- Test 2: Credenciales incorrectas
SELECT login_user('user@example.com', 'WrongPassword', false);

-- Test 3: Email no verificado
SELECT login_user('unverified@example.com', 'Password123!', false);

-- Test 4: Usuario no aprobado
SELECT login_user('pending@example.com', 'Password123!', false);

-- Test 5: Remember me (token 30 días)
SELECT login_user('user@example.com', 'Password123!', true);

-- Test 6: Validar token
SELECT validate_token('token_from_login_response');
```

**Referencia**: [apis_hu002.md](backend/apis_hu002.md)

---

### 2️⃣ Frontend - Models (@flutter-expert)

**Archivos a crear**:
```
lib/features/auth/data/models/
├── login_request_model.dart
├── login_response_model.dart
├── validate_token_response_model.dart
└── auth_state_model.dart
```

**Implementar**:
- ✅ `LoginRequestModel` con `toJson()` mapping a `p_*` params
- ✅ `LoginResponseModel.fromJson()` parseando token + user + message
- ✅ `ValidateTokenResponseModel.fromJson()` parseando user
- ✅ `AuthStateModel` con getter `isExpired` y serialización para SecureStorage

**Testing**:
```dart
// Unit tests con coverage 90%+
test('LoginRequestModel toJson should map correctly', () { ... });
test('LoginResponseModel fromJson should parse valid JSON', () { ... });
test('AuthStateModel isExpired should return true when expired', () { ... });
```

**Referencia**: [models_hu002.md](frontend/models_hu002.md)

---

### 3️⃣ Frontend - AuthBloc (@flutter-expert)

**Archivo a actualizar**: `lib/features/auth/presentation/bloc/auth_bloc.dart`

**Nuevos eventos**:
```dart
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}
```

**Nuevos estados**:
```dart
class AuthAuthenticated extends AuthState {
  final User user;
  final String? message;
}

class AuthUnauthenticated extends AuthState {
  final String? message;  // Para mostrar "Sesión expirada"
}
```

**Implementar**:
- ✅ Evento `LoginRequested` → llama `login_user()` via datasource
- ✅ Evento `LogoutRequested` → limpia SecureStorage y emite `AuthUnauthenticated`
- ✅ Evento `CheckAuthStatus` → valida token al iniciar app (CA-009)
- ✅ Persistencia en SecureStorage usando `AuthStateModel`

**Referencia**: [components_hu002.md](design/components_hu002.md)

---

### 4️⃣ Frontend - Datasource (@flutter-expert)

**Archivo a actualizar**: `lib/features/auth/data/datasources/auth_remote_datasource.dart`

**Nuevos métodos**:
```dart
abstract class AuthRemoteDataSource {
  // Método nuevo para HU-002
  Future<LoginResponseModel> login(LoginRequestModel request);

  // Método nuevo para HU-002
  Future<ValidateTokenResponseModel> validateToken(String token);

  // Métodos existentes de HU-001
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<EmailConfirmationResponseModel> confirmEmail(String token);
  Future<void> resendConfirmation(String email);
}
```

**Implementar**:
```dart
@override
Future<LoginResponseModel> login(LoginRequestModel request) async {
  final response = await supabase.rpc('login_user', params: request.toJson());
  final result = response as Map<String, dynamic>;

  if (result['success'] == true) {
    return LoginResponseModel.fromJson(result['data']);
  } else {
    final error = result['error'] as Map<String, dynamic>;
    final hint = error['hint'] as String?;

    if (hint == 'invalid_credentials') {
      throw UnauthorizedException(error['message'], 401);
    } else if (hint == 'email_not_verified') {
      throw EmailNotVerifiedException(error['message'], 403);
    } else if (hint == 'user_not_approved') {
      throw UserNotApprovedException(error['message'], 403);
    }
    throw ServerException(error['message'], 500);
  }
}
```

---

### 5️⃣ UI Components (@ux-ui-expert)

**Archivos a crear**:
```
lib/features/auth/presentation/
├── pages/
│   └── login_page.dart
├── widgets/
│   ├── login_form.dart
│   ├── remember_me_checkbox.dart
│   └── auth_guard.dart

lib/features/home/presentation/
└── pages/
    └── home_page.dart
```

**Implementar**:
- ✅ `LoginPage`: Layout responsive con max 440px
- ✅ `LoginForm`: Validaciones, BlocConsumer, SnackBar con errores
- ✅ `RememberMeCheckbox`: Checkbox corporativo con label clickeable
- ✅ `HomePage`: Saludo personalizado + info usuario + logout
- ✅ `AuthGuard`: Wrapper para rutas protegidas

**Testing**:
```dart
testWidgets('LoginForm should show error when email is invalid', (tester) async { ... });
testWidgets('LoginForm should call LoginRequested when submitted', (tester) async { ... });
testWidgets('HomePage should display user name', (tester) async { ... });
```

**Referencia**: [components_hu002.md](design/components_hu002.md)

---

### 6️⃣ Routing (@ux-ui-expert o @flutter-expert)

**Archivo a actualizar**: `lib/main.dart`

**Agregar rutas**:
```dart
routes: {
  '/': (context) => const RegisterPage(),
  '/register': (context) => const RegisterPage(),
  '/login': (context) => const LoginPage(),        // ← NUEVO
  '/home': (context) => const AuthGuard(           // ← NUEVO
        child: HomePage(),
      ),
  '/confirm-email': (context) => const ConfirmEmailPage(),
  '/email-confirmation-waiting': (context) => const EmailConfirmationWaitingPage(),
},
```

**Nota**: Usar rutas flat sin prefijos (ej: `/login`, NO `/auth/login`)

**Referencia**: [ROUTING_CONVENTIONS.md](frontend/ROUTING_CONVENTIONS.md)

---

### 7️⃣ Excepciones (@flutter-expert)

**Archivo a actualizar**: `lib/core/error/exceptions.dart`

**Agregar excepciones**:
```dart
class UnauthorizedException extends AppException {
  UnauthorizedException(String message, int statusCode)
      : super(message, statusCode);
}

class EmailNotVerifiedException extends AppException {
  EmailNotVerifiedException(String message, int statusCode)
      : super(message, statusCode);
}

class UserNotApprovedException extends AppException {
  UserNotApprovedException(String message, int statusCode)
      : super(message, statusCode);
}
```

---

### 8️⃣ QA Testing (@qa-testing-expert)

**Tests de integración E2E**:

```dart
// test/integration/login_flow_test.dart

testWidgets('Login exitoso con usuario aprobado', (tester) async {
  // 1. Navegar a /login
  // 2. Ingresar credenciales válidas
  // 3. Presionar "Iniciar Sesión"
  // 4. Verificar redirección a /home
  // 5. Verificar mensaje "Bienvenido [nombre]"
});

testWidgets('Login falla con credenciales incorrectas', (tester) async {
  // 1. Navegar a /login
  // 2. Ingresar credenciales inválidas
  // 3. Presionar "Iniciar Sesión"
  // 4. Verificar error "Email o contraseña incorrectos"
  // 5. Verificar permanece en /login
});

testWidgets('Login falla con email no verificado', (tester) async {
  // 1. Navegar a /login
  // 2. Ingresar credenciales de usuario sin verificar
  // 3. Presionar "Iniciar Sesión"
  // 4. Verificar error "Debes confirmar tu email..."
  // 5. Verificar botón "Reenviar" visible
});

testWidgets('Remember me persiste sesión al reiniciar app', (tester) async {
  // 1. Login con "Recordarme" marcado
  // 2. Cerrar app
  // 3. Abrir app
  // 4. Verificar redirección automática a /home
});

testWidgets('Token expirado redirige a login', (tester) async {
  // 1. Login exitoso
  // 2. Simular token expirado
  // 3. Intentar acceder a /home
  // 4. Verificar redirección a /login
  // 5. Verificar mensaje "Tu sesión ha expirado"
});
```

**Checklist de validación**:
- [ ] Todos los CA (CA-001 a CA-010) validados
- [ ] Coverage mínimo: 80% en flujos críticos
- [ ] Tests manuales en mobile (< 768px) y desktop (≥ 1200px)

---

## 🔗 DEPENDENCIAS

### HU-001 (Registro) - ✅ Completado
- Tabla `users` con campos necesarios
- UserModel con `rol`, `estado`, `emailVerificado`
- AuthBloc base (se extiende en HU-002)

---

## 📊 CRITERIOS DE ACEPTACIÓN - MAPEO

| CA | Descripción | Implementado en |
|----|-------------|-----------------|
| CA-001 | Formulario de login | `LoginForm` widget |
| CA-002 | Validaciones de campos | `Validators` + frontend validations |
| CA-003 | Login exitoso | `login_user()` + `AuthBloc.LoginRequested` |
| CA-004 | Usuario no registrado | `login_user()` hint: `invalid_credentials` |
| CA-005 | Contraseña incorrecta | `login_user()` hint: `invalid_credentials` |
| CA-006 | Email sin verificar | `login_user()` hint: `email_not_verified` |
| CA-007 | Usuario no aprobado | `login_user()` hint: `user_not_approved` |
| CA-008 | Función "Recordarme" | `p_remember_me` param → token 30 días |
| CA-009 | Sesión persistente | `AuthBloc.CheckAuthStatus` + SecureStorage |
| CA-010 | Token expirado | `validate_token()` + `AuthGuard` redirect |

---

## ✅ DEFINITION OF DONE (DoD)

- [ ] **Backend**: Funciones `login_user()` y `validate_token()` implementadas y testeadas
- [ ] **Frontend**: LoginPage, HomePage, AuthGuard implementados
- [ ] **AuthBloc**: Eventos Login, Logout, CheckAuthStatus funcionando
- [ ] **Persistencia**: SecureStorage guarda token y restaura sesión
- [ ] **Navegación**: Rutas `/login`, `/home` con AuthGuard
- [ ] **Validaciones**: Todos los errores muestran mensaje específico
- [ ] **QA**: Tests E2E de todos los CA pasando
- [ ] **Documentación**: Archivos `*_hu002.md` actualizados con código final

---

## 📞 COORDINACIÓN DE AGENTES

### Orden de ejecución:

1. **@supabase-expert**: Implementa funciones BD (1-2 horas)
2. **@flutter-expert** (paralelo con @ux-ui-expert):
   - Models + Datasource + AuthBloc (2-3 horas)
3. **@ux-ui-expert** (paralelo con @flutter-expert):
   - LoginPage + LoginForm + HomePage (2-3 horas)
4. **@qa-testing-expert**: Tests E2E (1-2 horas)

**Total estimado**: 4-5 horas de trabajo distribuido

---

**Última actualización**: 2025-10-05
**Mantenido por**: @web-architect-expert
