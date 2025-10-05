# Especificaciones para Agentes - HU-002: Login al Sistema

**Historia de Usuario**: E001-HU-002
**Estado**: 🔵 En Desarrollo

---

## 📋 INSTRUCCIONES GENERALES

### ⚠️ ANTES DE EMPEZAR:

1. ✅ **Leer obligatoriamente**: [00-CONVENTIONS.md](00-CONVENTIONS.md)
2. ✅ **Leer esta spec completa** antes de implementar
3. ✅ **Verificar dependencias**: HU-001 debe estar completada
4. ✅ **Revisar documentación específica**:
   - Backend: [apis_hu002.md](backend/apis_hu002.md)
   - Frontend: [models_hu002.md](frontend/models_hu002.md), [components_hu002.md](design/components_hu002.md)
   - Mapping: [mapping_hu002.md](integration/mapping_hu002.md)

---

## 🎯 @supabase-expert

### Responsabilidad:
Implementar funciones de base de datos para login, validación de token y rate limiting.

### Archivos a crear:

```
supabase/migrations/
└── YYYYMMDDHHMMSS_hu002_login_functions.sql
```

### Tareas:

#### 1. Crear tabla `login_attempts`

```sql
CREATE TABLE login_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address TEXT,
    success BOOLEAN NOT NULL
);

CREATE INDEX idx_login_attempts_email_time ON login_attempts(email, attempted_at);

COMMENT ON TABLE login_attempts IS 'HU-002: Registro de intentos de login para rate limiting';
```

#### 2. Implementar función `check_login_rate_limit()`

**Ver código completo en**: [apis_hu002.md](backend/apis_hu002.md#rate-limiting-ca-008---seguridad)

**Validar**:
- Cuenta intentos fallidos en últimos 15 minutos
- Retorna `false` si hay 5+ intentos fallidos
- Case-insensitive en email

#### 3. Implementar función `login_user()`

**Ver código completo en**: [apis_hu002.md](backend/apis_hu002.md#función-1-login_user)

**Validaciones obligatorias** (en orden):
1. ✅ Email no vacío → hint: `missing_email`
2. ✅ Email formato válido → hint: `invalid_email`
3. ✅ Password no vacío → hint: `missing_password`
4. ✅ Rate limiting (5 intentos/15min) → hint: `rate_limit_exceeded`
5. ✅ Usuario existe → hint: `invalid_credentials`
6. ✅ Password correcta → hint: `invalid_credentials`
7. ✅ Email verificado → hint: `email_not_verified`
8. ✅ Estado = 'APROBADO' → hint: `user_not_approved`

**Token generation**:
- Sin `rememberMe`: 8 horas
- Con `rememberMe`: 30 días
- Formato: base64 de JSON con `user_id`, `email`, `rol`, `exp`

**Response exitoso**:
```json
{
  "success": true,
  "data": {
    "token": "...",
    "user": { "id", "email", "nombre_completo", "rol", "estado" },
    "message": "Bienvenido [nombre_completo]"
  }
}
```

**IMPORTANTE**:
- ❌ **NO exponer** `password_hash`, `token_confirmacion`
- ✅ Usar `crypt()` para validar password
- ✅ Email case-insensitive con `LOWER(email)`
- ✅ `SECURITY DEFINER` para bypass RLS

#### 4. Implementar función `validate_token()`

**Ver código completo en**: [apis_hu002.md](backend/apis_hu002.md#función-2-validate_token)

**Validaciones**:
1. ✅ Token no vacío → hint: `missing_token`
2. ✅ Token decodificable (base64) → hint: `invalid_token`
3. ✅ Token no expirado → hint: `expired_token`
4. ✅ Usuario existe → hint: `user_not_found`
5. ✅ Usuario sigue APROBADO → hint: `user_not_approved`

#### 5. Testing manual en Supabase Studio

```sql
-- Test 1: Login exitoso
SELECT login_user('test@example.com', 'Test123!', false);

-- Test 2: Credenciales incorrectas
SELECT login_user('test@example.com', 'WrongPassword', false);

-- Test 3: Email no verificado (insertar usuario de prueba)
INSERT INTO users (email, password_hash, nombre_completo, estado, email_verificado)
VALUES ('unverified@test.com', crypt('Test123!', gen_salt('bf')), 'Test User', 'REGISTRADO', false);

SELECT login_user('unverified@test.com', 'Test123!', false);
-- Debe retornar hint: 'email_not_verified'

-- Test 4: Usuario no aprobado
INSERT INTO users (email, password_hash, nombre_completo, estado, email_verificado)
VALUES ('pending@test.com', crypt('Test123!', gen_salt('bf')), 'Pending User', 'REGISTRADO', true);

SELECT login_user('pending@test.com', 'Test123!', false);
-- Debe retornar hint: 'user_not_approved'

-- Test 5: Remember me (token 30 días)
SELECT login_user('test@example.com', 'Test123!', true);

-- Test 6: Validar token
SELECT validate_token('token_from_previous_response');
```

### Entrega:

- [ ] Migration aplicada exitosamente
- [ ] Todas las funciones creadas
- [ ] Tests manuales pasando
- [ ] Comentarios SQL con referencias a CA y RN
- [ ] Actualizar [apis_hu002.md](backend/apis_hu002.md) sección "SQL Final Implementado"

---

## 🎯 @flutter-expert

### Responsabilidad:
Implementar modelos, datasource, repositorio, use cases y AuthBloc para login.

### Archivos a crear:

```
lib/features/auth/
├── data/
│   ├── models/
│   │   ├── login_request_model.dart
│   │   ├── login_response_model.dart
│   │   ├── validate_token_response_model.dart
│   │   └── auth_state_model.dart
│   └── datasources/
│       └── auth_remote_datasource.dart (actualizar)
├── domain/
│   ├── usecases/
│   │   ├── login_user.dart
│   │   ├── validate_token.dart
│   │   └── logout_user.dart
│   └── repositories/
│       └── auth_repository.dart (actualizar)
├── presentation/
│   └── bloc/
│       ├── auth_bloc.dart (actualizar)
│       ├── auth_event.dart (actualizar)
│       └── auth_state.dart (actualizar)

lib/core/error/
└── exceptions.dart (actualizar)
```

### Tareas:

#### 1. Crear modelos

**Ver código completo en**: [models_hu002.md](frontend/models_hu002.md)

**Modelos a crear**:
- `LoginRequestModel`: Con `toJson()` mapping a `p_*` params
- `LoginResponseModel`: Con `fromJson()` y `toJson()`
- `ValidateTokenResponseModel`: Con `fromJson()`
- `AuthStateModel`: Con `fromJson()`, `toJson()` y getter `isExpired`

**Validar**:
- Mapping snake_case ↔ camelCase correcto
- `Equatable` implementado en todos los modelos
- Nullability correcta (`rol` nullable, resto non-nullable)

#### 2. Actualizar datasource

```dart
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<ValidateTokenResponseModel> validateToken(String token);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<EmailConfirmationResponseModel> confirmEmail(String token);
  Future<void> resendConfirmation(String email);
}
```

**Implementación**:
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

@override
Future<ValidateTokenResponseModel> validateToken(String token) async {
  final response = await supabase.rpc('validate_token', params: {'p_token': token});
  final result = response as Map<String, dynamic>;

  if (result['success'] == true) {
    return ValidateTokenResponseModel.fromJson(result['data']);
  } else {
    final error = result['error'] as Map<String, dynamic>;
    throw UnauthorizedException(error['message'], 401);
  }
}
```

#### 3. Crear excepciones

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

#### 4. Actualizar repositorio

```dart
abstract class AuthRepository {
  Future<Either<Failure, LoginResponseModel>> login(LoginRequestModel request);
  Future<Either<Failure, ValidateTokenResponseModel>> validateToken(String token);
  Future<Either<Failure, void>> logout();
  // ... métodos existentes de HU-001
}
```

#### 5. Crear use cases

**LoginUser**:
```dart
class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, LoginResponseModel>> call(LoginRequestModel request) async {
    return await repository.login(request);
  }
}
```

**ValidateToken**, **LogoutUser**: Similar estructura

#### 6. Actualizar AuthBloc

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
  final String? message;
}
```

**Event handlers**:
```dart
on<LoginRequested>((event, emit) async {
  emit(AuthLoading());

  final request = LoginRequestModel(
    email: event.email,
    password: event.password,
    rememberMe: event.rememberMe,
  );

  final result = await loginUser(request);

  result.fold(
    (failure) => emit(AuthError(failure.message)),
    (response) async {
      // Guardar en SecureStorage
      final authState = AuthStateModel(
        token: response.token,
        user: response.user,
        tokenExpiration: DateTime.now().add(
          event.rememberMe ? Duration(days: 30) : Duration(hours: 8),
        ),
      );

      await _secureStorage.write(
        key: 'auth_state',
        value: jsonEncode(authState.toJson()),
      );

      emit(AuthAuthenticated(
        user: response.user.toDomain(),
        message: response.message,
      ));
    },
  );
});

on<CheckAuthStatus>((event, emit) async {
  // Leer de SecureStorage
  final authStateJson = await _secureStorage.read(key: 'auth_state');

  if (authStateJson == null) {
    emit(AuthUnauthenticated());
    return;
  }

  final authState = AuthStateModel.fromJson(jsonDecode(authStateJson));

  if (authState.isExpired) {
    await _secureStorage.delete(key: 'auth_state');
    emit(AuthUnauthenticated(message: 'Tu sesión ha expirado'));
    return;
  }

  // Validar token con backend
  final result = await validateToken(authState.token);

  result.fold(
    (failure) {
      emit(AuthUnauthenticated(message: failure.message));
    },
    (response) {
      emit(AuthAuthenticated(user: response.user.toDomain()));
    },
  );
});

on<LogoutRequested>((event, emit) async {
  await _secureStorage.delete(key: 'auth_state');
  emit(AuthUnauthenticated());
});
```

#### 7. Actualizar main.dart

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(CheckAuthStatus()),  // ← Auto-check
      child: MaterialApp(
        // ...
      ),
    );
  }
}
```

#### 8. Testing

**Unit tests**:
```dart
test('LoginRequestModel toJson should map correctly', () {
  final model = LoginRequestModel(
    email: 'test@example.com',
    password: 'Password123!',
    rememberMe: true,
  );

  expect(model.toJson(), {
    'p_email': 'test@example.com',
    'p_password': 'Password123!',
    'p_remember_me': true,
  });
});

test('LoginResponseModel fromJson should parse correctly', () {
  final json = {
    'token': 'test_token',
    'user': {
      'id': 'uuid',
      'email': 'test@example.com',
      'nombre_completo': 'Test User',
      'rol': 'VENDEDOR',
      'estado': 'APROBADO',
      'email_verificado': true,
      'created_at': '2025-10-05T12:00:00Z',
    },
    'message': 'Bienvenido Test User',
  };

  final model = LoginResponseModel.fromJson(json);

  expect(model.token, 'test_token');
  expect(model.user.nombreCompleto, 'Test User');
  expect(model.message, 'Bienvenido Test User');
});
```

**Coverage**: Mínimo 90% en models y use cases

### Entrega:

- [ ] Todos los modelos creados con tests unitarios
- [ ] Datasource actualizado con manejo de hints
- [ ] AuthBloc con eventos Login, Logout, CheckAuthStatus
- [ ] Persistencia en SecureStorage funcionando
- [ ] Tests unitarios con coverage 90%+
- [ ] Actualizar [models_hu002.md](frontend/models_hu002.md) sección "Código Final Implementado"

---

## 🎯 @ux-ui-expert

### Responsabilidad:
Implementar UI de login, home y guards de autenticación.

### Archivos a crear:

```
lib/features/auth/presentation/
├── pages/
│   └── login_page.dart
└── widgets/
    ├── login_form.dart
    ├── remember_me_checkbox.dart
    └── auth_guard.dart

lib/features/home/presentation/
└── pages/
    └── home_page.dart

lib/core/utils/
└── validators.dart (actualizar)
```

### Tareas:

#### 1. Crear LoginPage

**Ver código completo en**: [components_hu002.md](design/components_hu002.md#página-1-loginpage)

**Características**:
- Max width: 440px en desktop
- Centered con SingleChildScrollView
- AuthHeader + LoginForm + link a registro

#### 2. Crear LoginForm

**Ver código completo en**: [components_hu002.md](design/components_hu002.md#widget-1-loginform)

**Características**:
- BlocConsumer para estados
- CorporateFormField para email y password
- RememberMeCheckbox
- CorporateButton con loading state
- Validaciones con `Validators.email` y `Validators.required`
- SnackBar para errores con action "Reenviar" si `hint == 'email_not_verified'`
- Navegación a `/home` on success

**Mapeo de errores**:
```dart
if (state is AuthError) {
  String errorMessage = state.message;
  SnackBarAction? action;

  if (state.errorHint == 'email_not_verified') {
    action = SnackBarAction(
      label: 'Reenviar',
      textColor: Colors.white,
      onPressed: () {
        context.read<AuthBloc>().add(
          ResendConfirmationRequested(email: _emailController.text.trim()),
        );
      },
    );
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Theme.of(context).colorScheme.error,
      action: action,
    ),
  );
}
```

#### 3. Crear RememberMeCheckbox

**Ver código completo en**: [components_hu002.md](design/components_hu002.md#widget-2-remembermecheckbox)

**Características**:
- Tamaño fijo 24x24px
- Color corporativo `primaryTurquoise`
- Label clickeable con GestureDetector

#### 4. Crear HomePage

**Ver código completo en**: [components_hu002.md](design/components_hu002.md#página-2-homepage)

**Características**:
- AppBar con título + botón logout
- Saludo "¡Bienvenido!" + nombre completo
- Card con info: email, rol, estado
- IconButton logout que dispara `LogoutRequested`

#### 5. Crear AuthGuard

**Ver código completo en**: [components_hu002.md](design/components_hu002.md#widget-3-authguard-middleware-de-rutas-protegidas)

**Características**:
- Wrapper para páginas protegidas
- Redirige a `/login` si `AuthUnauthenticated`
- Muestra CircularProgressIndicator si `AuthLoading`
- Renderiza `child` si `AuthAuthenticated`

#### 6. Actualizar main.dart (rutas)

```dart
routes: {
  '/': (context) => const RegisterPage(),
  '/register': (context) => const RegisterPage(),
  '/login': (context) => const LoginPage(),
  '/home': (context) => const AuthGuard(child: HomePage()),
  '/confirm-email': (context) => const ConfirmEmailPage(),
  '/email-confirmation-waiting': (context) => const EmailConfirmationWaitingPage(),
},
```

#### 7. Actualizar Validators

```dart
static String? Function(String?) required(String message) {
  return (String? value) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null;
  };
}
```

#### 8. Testing

**Widget tests**:
```dart
testWidgets('LoginForm should show error when email is empty', (tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage()));

  final submitButton = find.text('Iniciar Sesión');
  await tester.tap(submitButton);
  await tester.pump();

  expect(find.text('Email es requerido'), findsOneWidget);
});

testWidgets('LoginForm should navigate to /home on success', (tester) async {
  // Mock AuthBloc con estado AuthAuthenticated
  // Verificar Navigator.pushReplacementNamed llamado con '/home'
});
```

**Coverage**: Mínimo 70% en widgets

### Entrega:

- [ ] LoginPage responsive implementada
- [ ] LoginForm con validaciones y manejo de errores
- [ ] HomePage con saludo personalizado
- [ ] AuthGuard funcionando
- [ ] Rutas actualizadas en main.dart
- [ ] Widget tests con coverage 70%+
- [ ] Actualizar [components_hu002.md](design/components_hu002.md) sección "Código Final Implementado"

---

## 🎯 @qa-testing-expert

### Responsabilidad:
Validar todos los criterios de aceptación mediante tests de integración E2E.

### Archivos a crear:

```
test/integration/
└── login_flow_test.dart
```

### Tareas:

#### Tests E2E obligatorios

**CA-001: Formulario de login**
```dart
testWidgets('CA-001: Formulario debe mostrar todos los elementos', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();

  await tester.tap(find.text('¿Ya tienes cuenta? Inicia sesión'));
  await tester.pumpAndSettle();

  expect(find.text('Email'), findsOneWidget);
  expect(find.text('Contraseña'), findsOneWidget);
  expect(find.text('Recordarme'), findsOneWidget);
  expect(find.text('Iniciar Sesión'), findsOneWidget);
  expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
  expect(find.text('¿No tienes cuenta? Regístrate'), findsOneWidget);
});
```

**CA-002: Validaciones de campos**
```dart
testWidgets('CA-002: Debe validar campos vacíos', (tester) async {
  // Navegar a login
  // Presionar "Iniciar Sesión" sin llenar campos
  // Verificar mensajes de error
});
```

**CA-003: Login exitoso**
```dart
testWidgets('CA-003: Login exitoso redirige a /home', (tester) async {
  // Ingresar credenciales de usuario APROBADO
  // Presionar "Iniciar Sesión"
  // Verificar redirección a /home
  // Verificar SnackBar "Bienvenido [nombre]"
});
```

**CA-004/CA-005: Credenciales incorrectas**
```dart
testWidgets('CA-004/CA-005: Debe mostrar error con credenciales incorrectas', (tester) async {
  // Ingresar email o password incorrectos
  // Presionar "Iniciar Sesión"
  // Verificar error "Email o contraseña incorrectos"
  // Verificar permanece en /login
});
```

**CA-006: Email sin verificar**
```dart
testWidgets('CA-006: Debe mostrar error y botón reenviar', (tester) async {
  // Ingresar credenciales de usuario sin verificar
  // Presionar "Iniciar Sesión"
  // Verificar error "Debes confirmar tu email..."
  // Verificar botón "Reenviar" visible
});
```

**CA-007: Usuario no aprobado**
```dart
testWidgets('CA-007: Debe mostrar error de acceso denegado', (tester) async {
  // Ingresar credenciales de usuario REGISTRADO/RECHAZADO
  // Presionar "Iniciar Sesión"
  // Verificar error "No tienes acceso al sistema..."
});
```

**CA-008/CA-009: Remember me y sesión persistente**
```dart
testWidgets('CA-008/CA-009: Remember me persiste sesión', (tester) async {
  // Login con "Recordarme" marcado
  // Verificar token guardado en SecureStorage
  // Reiniciar app (rebuild widget tree)
  // Verificar redirección automática a /home
});
```

**CA-010: Token expirado**
```dart
testWidgets('CA-010: Token expirado redirige a login', (tester) async {
  // Mock AuthStateModel con token expirado
  // Intentar acceder a /home
  // Verificar redirección a /login
  // Verificar mensaje "Tu sesión ha expirado"
});
```

#### Checklist de validación manual

**Mobile (< 768px)**:
- [ ] Formulario responsive (full width)
- [ ] Teclado no oculta campos
- [ ] Touch targets mínimo 44px

**Desktop (≥ 1200px)**:
- [ ] Max width 440px centrado
- [ ] Hover states en botones
- [ ] Focus states en form fields

**Flujos críticos**:
- [ ] Login exitoso → /home → logout → /login
- [ ] Error "email no verificado" → Reenviar → Confirmación
- [ ] 5 intentos fallidos → Rate limit error

### Entrega:

- [ ] Tests E2E de todos los CA (CA-001 a CA-010)
- [ ] Coverage 80%+ en flujos críticos
- [ ] Tests manuales mobile y desktop completados
- [ ] Reporte de bugs encontrados (si aplica)
- [ ] Validación de DoD completa

---

## ✅ DEFINITION OF DONE (DoD)

**Criterios para marcar HU-002 como completada**:

### Backend
- [ ] Funciones `login_user()` y `validate_token()` implementadas
- [ ] Rate limiting configurado (5 intentos/15min)
- [ ] Tests manuales pasando
- [ ] Comentarios SQL con referencias a CA y RN

### Frontend
- [ ] Models con mapping correcto y tests unitarios 90%+
- [ ] AuthBloc con eventos Login, Logout, CheckAuthStatus
- [ ] Persistencia en SecureStorage funcionando
- [ ] LoginPage, HomePage, AuthGuard implementados
- [ ] Widget tests con coverage 70%+

### Integración
- [ ] Login exitoso redirige a /home
- [ ] Todos los errores muestran mensaje específico
- [ ] "Recordarme" persiste sesión al reiniciar
- [ ] Token expirado redirige a /login

### QA
- [ ] Tests E2E de todos los CA pasando
- [ ] Coverage 80%+ en flujos críticos
- [ ] Validación manual mobile y desktop

### Documentación
- [ ] Archivos `*_hu002.md` actualizados con sección "Código Final Implementado"
- [ ] HU-002 actualizada con checkboxes marcados

---

## 📞 COORDINACIÓN

### Orden de ejecución:

1. **@supabase-expert** (3 horas): Implementa funciones BD
2. **@flutter-expert** (4 horas, paralelo con @ux-ui-expert): Models + Datasource + AuthBloc
3. **@ux-ui-expert** (3 horas, paralelo con @flutter-expert): UI components
4. **@qa-testing-expert** (2 horas): Tests E2E

**Total**: ~6 horas distribuidas

### Comunicación:

- **@supabase-expert** avisa en Slack cuando termina → @flutter-expert puede iniciar
- **@flutter-expert** y **@ux-ui-expert** trabajan en paralelo
- **@qa-testing-expert** espera a que ambos terminen

---

**Última actualización**: 2025-10-05
**Mantenido por**: @web-architect-expert
