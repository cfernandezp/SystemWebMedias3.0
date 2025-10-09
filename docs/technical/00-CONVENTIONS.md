# Convenciones Técnicas - Sistema de Venta de Medias

**Autor**: @web-architect-expert
**Fecha creación**: 2025-10-04
**Última actualización**: 2025-10-04
**Versión**: 1.0

---

## 🎯 PROPÓSITO

Este documento es la **FUENTE ÚNICA DE VERDAD** para todas las convenciones técnicas del proyecto.

**REGLA DE ORO**:
> Todos los agentes (@supabase-expert, @flutter-expert, @ux-ui-expert, @qa-testing-expert) **DEBEN** leer este documento **ANTES** de implementar cualquier Historia de Usuario.

---

## 📐 1. NAMING CONVENTIONS

### 1.1 Base de Datos (PostgreSQL - Supabase)

| Elemento | Convención | Ejemplo Correcto | Ejemplo Incorrecto |
|----------|-----------|------------------|-------------------|
| **Tablas** | `snake_case` plural | `users`, `sales_details` | `Users`, `salesDetails`, `user` |
| **Columnas** | `snake_case` | `email`, `created_at`, `password_hash` | `Email`, `createdAt`, `passwordHash` |
| **Primary Keys** | `id` (UUID) | `id` | `user_id`, `pk_users` |
| **Foreign Keys** | `{tabla_singular}_id` | `user_id`, `product_id`, `brand_id` | `userId`, `fk_user`, `id_user` |
| **Índices** | `idx_{tabla}_{columna(s)}` | `idx_users_email`, `idx_sales_created_at` | `index_users_email` |
| **ENUM Types** | `snake_case` singular | `user_role`, `user_estado` | `UserRole`, `user_roles` |
| **ENUM Values** | `UPPER_SNAKE_CASE` | `REGISTRADO`, `APROBADO`, `ADMIN` | `registrado`, `Aprobado` |
| **Functions** | `snake_case` verbo | `register_user()`, `hash_password()` | `registerUser()`, `RegisterUser()` |
| **Triggers** | `{accion}_{tabla}_{evento}` | `update_users_updated_at` | `usersUpdateTrigger` |
| **Timestamps** | `created_at`, `updated_at`, `deleted_at` | `created_at` | `createdDate`, `created`, `timestamp` |

**Ejemplos completos**:

```sql
-- ✅ CORRECTO
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(LOWER(email));
CREATE TYPE user_role AS ENUM ('ADMIN', 'GERENTE', 'VENDEDOR');

-- ❌ INCORRECTO
CREATE TABLE Users (
    userId UUID PRIMARY KEY,
    Email TEXT,
    passwordHash TEXT,
    CreatedDate TIMESTAMP
);
```

---

### 1.2 Dart/Flutter (Frontend)

| Elemento | Convención | Ejemplo Correcto | Ejemplo Incorrecto |
|----------|-----------|------------------|-------------------|
| **Clases** | `PascalCase` | `User`, `SaleDetail`, `AuthBloc` | `user`, `sale_detail`, `authBloc` |
| **Variables** | `camelCase` | `userId`, `createdAt`, `emailVerificado` | `user_id`, `UserID`, `email_verificado` |
| **Constantes** | `lowerCamelCase` | `primaryColor`, `maxRetries` | `PRIMARY_COLOR`, `max_retries` |
| **Archivos** | `snake_case` | `user_model.dart`, `auth_bloc.dart` | `UserModel.dart`, `authBloc.dart` |
| **Enums** | `PascalCase` (clase), `camelCase` (valores) | `enum UserRole { admin, gerente }` | `enum userRole`, `ADMIN` |
| **Métodos** | `camelCase` verbo | `registerUser()`, `validateEmail()` | `register_user()`, `RegisterUser()` |
| **Widgets** | `PascalCase` | `RegisterPage`, `CorporateButton` | `registerPage`, `corporate_button` |
| **Parámetros** | `camelCase` | `userName`, `emailAddress` | `user_name`, `UserName` |

**Mapping BD ↔ Dart** (CRÍTICO):

```dart
// ✅ CORRECTO: Mapping snake_case ↔ camelCase
class User {
  final String id;
  final String email;
  final String nombreCompleto;      // ← nombre_completo
  final bool emailVerificado;        // ← email_verificado
  final DateTime createdAt;          // ← created_at
  final DateTime? updatedAt;         // ← updated_at

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nombreCompleto: json['nombre_completo'],     // ← Mapeo explícito
      emailVerificado: json['email_verificado'],   // ← Mapeo explícito
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre_completo': nombreCompleto,           // ← Mapeo explícito
      'email_verificado': emailVerificado,         // ← Mapeo explícito
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
```

---

## 🔀 2. ROUTING CONVENTIONS (Flutter)

### 2.1 Estructura de Rutas

**CONVENCIÓN OFICIAL**: Rutas **FLAT** sin prefijos de módulo

```dart
// ✅ CORRECTO
routes: {
  '/': (context) => RegisterPage(),
  '/register': (context) => RegisterPage(),
  '/login': (context) => LoginPage(),
  '/dashboard': (context) => DashboardPage(),
  '/products': (context) => ProductsListPage(),
  '/product-detail': (context) => ProductDetailPage(),
}

// ❌ INCORRECTO - NO usar prefijos de módulo
routes: {
  '/auth/register': (context) => RegisterPage(),      // ❌
  '/auth/login': (context) => LoginPage(),            // ❌
  '/products/list': (context) => ProductsListPage(),  // ❌
  '/products/detail': (context) => ProductDetailPage(), // ❌
}
```

### 2.2 Navegación

```dart
// ✅ CORRECTO
Navigator.pushNamed(context, '/login');
Navigator.pushNamed(context, '/product-detail', arguments: productId);

// ❌ INCORRECTO
Navigator.pushNamed(context, '/auth/login');
Navigator.pushNamed(context, '/products/detail');
```

### 2.3 Paso de Argumentos

**Query Parameters** (para enlaces externos):
```dart
// URL: https://app.com/confirm-email?token=abc123
class ConfirmEmailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    final token = uri.queryParameters['token'];
    // ...
  }
}
```

**Route Arguments** (para navegación interna):
```dart
// Enviar
Navigator.pushNamed(context, '/product-detail', arguments: {
  'productId': '123',
  'mode': 'edit',
});

// Recibir
final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
final productId = args['productId'];
```

**Ver detalles completos**: [ROUTING_CONVENTIONS.md](frontend/ROUTING_CONVENTIONS.md)

---

## 🔧 3. ERROR HANDLING

### 3.1 PostgreSQL Functions - Manejo de Excepciones

**PATRÓN ESTÁNDAR**:

```sql
CREATE OR REPLACE FUNCTION my_function(p_param TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;  -- ⭐ Variable local para metadata de error
BEGIN
    -- Validaciones con hint asignado ANTES de RAISE
    IF p_param IS NULL THEN
        v_error_hint := 'missing_param';
        RAISE EXCEPTION 'Parámetro requerido';
    END IF;

    -- Lógica de negocio...

    -- Respuesta exitosa
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'field1', value1,
            'field2', value2
        )
    ) INTO v_result;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        -- ⭐ Usar variable local, NO PG_EXCEPTION_HINT
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

**⚠️ NO USAR**: `PG_EXCEPTION_HINT` (no existe como columna/función)

---

### 3.2 Dart/Flutter - Excepciones Personalizadas

```dart
// ✅ CORRECTO: Jerarquía de excepciones
abstract class AppException implements Exception {
  final String message;
  final int statusCode;

  AppException(this.message, this.statusCode);
}

class DuplicateEmailException extends AppException {
  DuplicateEmailException(String message, int statusCode)
      : super(message, statusCode);
}

class ValidationException extends AppException {
  final String? field;

  ValidationException(String message, int statusCode, {this.field})
      : super(message, statusCode);
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, 0);
}
```

**Manejo en Datasource**:

```dart
Future<AuthResponseModel> register(RegisterRequestModel request) async {
  try {
    final response = await supabase.rpc('register_user', params: {...});
    final result = response as Map<String, dynamic>;

    if (result['success'] == true) {
      return AuthResponseModel.fromJson(result['data']);
    } else {
      final error = result['error'] as Map<String, dynamic>;
      final hint = error['hint'] as String?;

      // Mapear hints a excepciones específicas
      if (hint == 'duplicate_email') {
        throw DuplicateEmailException(error['message'], 409);
      } else if (hint?.contains('invalid') == true) {
        throw ValidationException(error['message'], 400);
      }
      throw ServerException(error['message'], 500);
    }
  } catch (e) {
    if (e is AppException) rethrow;
    throw NetworkException('Error de conexión: $e');
  }
}
```

---

## 📦 4. API RESPONSE FORMAT

### 4.1 PostgreSQL Functions - Response JSON

**FORMATO ESTÁNDAR**:

```json
// ✅ Respuesta exitosa
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "nombre_completo": "Usuario Test",
    "message": "Operación exitosa"
  }
}

// ✅ Respuesta con error
{
  "success": false,
  "error": {
    "code": "23505",
    "message": "Este email ya está registrado",
    "hint": "duplicate_email"
  }
}
```

**HINTS ESTÁNDAR**:

| Hint | Significado | HTTP Status Flutter |
|------|-------------|---------------------|
| `duplicate_email` | Email ya existe | 409 Conflict |
| `invalid_email` | Formato email inválido | 400 Bad Request |
| `invalid_password` | Password no cumple requisitos | 400 Bad Request |
| `invalid_token` | Token inválido/expirado | 400 Bad Request |
| `expired_token` | Token expirado | 400 Bad Request |
| `already_verified` | Email ya verificado | 400 Bad Request |
| `user_not_found` | Usuario no existe | 404 Not Found |
| `rate_limit` | Límite de requests excedido | 429 Too Many Requests |
| `missing_param` | Parámetro requerido faltante | 400 Bad Request |

---

## 🎨 5. DESIGN SYSTEM

### 5.1 Colores (Tema Turquesa Moderno Retail)

**⚠️ REGLA CRÍTICA**: NUNCA hardcodear colores. SIEMPRE usar `Theme.of(context)` o `DesignColors.*`

```dart
// ✅ CORRECTO
class DesignColors {
  // Principales
  static const primaryTurquoise = Color(0xFF4ECDC4);
  static const primaryDark = Color(0xFF26A69A);
  static const accent = Color(0xFF6366F1);

  // Estados
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);

  // Neutrales
  static const backgroundLight = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
}

// Uso en widgets
Container(
  color: Theme.of(context).colorScheme.primary,  // ✅
  // O
  color: DesignColors.primaryTurquoise,          // ✅
)

// ❌ INCORRECTO
Container(
  color: Color(0xFF4ECDC4),  // ❌ Hardcoded
)
```

### 5.2 Spacing

```dart
class DesignSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
```

### 5.3 Breakpoints Responsive

```dart
class DesignBreakpoints {
  static const mobile = 768;
  static const tablet = 1024;
  static const desktop = 1200;
  static const largeDesktop = 1440;
}

// Uso
if (MediaQuery.of(context).size.width >= DesignBreakpoints.desktop) {
  // Layout desktop
} else {
  // Layout mobile
}
```

**Ver detalles completos**: [design/tokens.md](design/tokens.md)

---

## 🧪 6. TESTING REQUIREMENTS

### 6.1 Tests Obligatorios

| Tipo | Ubicación | Responsable | Cuándo |
|------|-----------|-------------|--------|
| **Unit Tests (Dart)** | `test/` | @flutter-expert | Después de implementar modelos/usecases |
| **Widget Tests (Flutter)** | `test/widgets/` | @ux-ui-expert | Después de implementar UI |
| **Integration Tests** | `integration_test/` | @qa-testing-expert | Después de integración E2E |
| **SQL Tests (Manual)** | Supabase Studio | @supabase-expert | Después de crear cada función |

### 6.2 Coverage Mínimo

- **Models**: 90%+
- **UseCases**: 85%+
- **Widgets**: 70%+
- **Integration**: 80%+ de flujos críticos

### 6.3 Naming de Tests

```dart
// ✅ CORRECTO
test('should return UserModel when JSON is valid', () { ... });
test('should throw ValidationException when email is invalid', () { ... });

// ❌ INCORRECTO
test('test user model', () { ... });
test('validate email', () { ... });
```

### 6.4 Patrón Integración Bloc (CONSISTENCIA OBLIGATORIA)

**CRÍTICO**: Todas las páginas DEBEN seguir el MISMO patrón Bloc para mantener consistencia arquitectónica.

**Patrón Estándar**:
```dart
// ✅ CORRECTO - Estructura en TODAS las páginas
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MyBloc>(),
      child: Scaffold(
        appBar: AppBar(title: Text('Título')),
        body: BlocConsumer<MyBloc, MyState>(
          listener: (context, state) {
            // Manejo errores/navegación (side effects)
            if (state is MyError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            if (state is MySuccess && state.navigateTo != null) {
              Navigator.pushNamed(context, state.navigateTo);
            }
          },
          builder: (context, state) {
            // Renderizado UI según estado
            if (state is MyLoading) return Center(child: CircularProgressIndicator());
            if (state is MySuccess) return _buildContent(state.data);
            return _buildInitial();
          },
        ),
      ),
    );
  }
}

// ❌ INCORRECTO - Patrones inconsistentes
StreamBuilder(...) // NO usar StreamBuilder con Bloc
setState(() {}) // NO usar StatefulWidget para estados Bloc
BlocBuilder + BlocListener separados // Usar BlocConsumer
```

**Reglas Consistencia**:
- ✅ `BlocProvider` → `BlocConsumer` → `Scaffold`
- ✅ `listener`: errores (SnackBar), navegación (Navigator)
- ✅ `builder`: Loading (CircularProgressIndicator), Success (contenido), Error (mensaje)
- ✅ Estados estándar: Initial, Loading, Success, Error
- ❌ NO mezclar patrones entre páginas
- ❌ NO crear variaciones custom sin justificación

**Antes de implementar nueva página**: Leer páginas existentes (`lib/features/*/presentation/pages/`) y replicar patrón.

---

## 📝 9. DOCUMENTATION STANDARDS

### 9.1 Comentarios en Código

**PostgreSQL**:
```sql
-- ✅ CORRECTO: Comentarios descriptivos
COMMENT ON TABLE users IS 'HU-001: Usuarios del sistema con autenticación y roles';
COMMENT ON COLUMN users.email IS 'Email único (case-insensitive) - RN-001';
COMMENT ON FUNCTION register_user IS 'HU-001: Registra nuevo usuario con validaciones (RN-001, RN-002, RN-003)';

-- ❌ INCORRECTO: Sin contexto
COMMENT ON TABLE users IS 'Tabla de usuarios';
```

**Dart**:
```dart
/// ✅ CORRECTO: Documentación con contexto de negocio
///
/// Modelo de usuario del sistema.
///
/// Implementa HU-001 (Registro) y HU-002 (Login).
/// Cumple RN-007: Usuario debe tener rol asignado para acceder al sistema.
///
/// Mapping BD ↔ Dart:
/// - `nombre_completo` → `nombreCompleto`
/// - `email_verificado` → `emailVerificado`
class User extends Equatable {
  // ...
}

// ❌ INCORRECTO: Sin contexto
/// Clase User
class User {
  // ...
}
```

### 9.2 Actualización de Docs Técnicos

**REGLA**: Después de implementar, actualizar sección "Código Final Implementado" en los `.md`

```markdown
## SQL Final Implementado

✅ **Status**: Implementado el 2025-10-04 por @supabase-expert

### Cambios vs Diseño Inicial:
- ✅ Agregado índice parcial en `token_confirmacion` para performance
- ✅ Agregada tabla `confirmation_resend_attempts` para RN-003 (límite 3/hora)

### Migration aplicada:
- `20251004145739_hu001_users_registration.sql`
```

---

## 🔐 7. SECURITY PATTERNS

### 7.1 Token Blacklist (Logout Seguro)

**CONVENCIÓN**: Tokens invalidados se almacenan en tabla `token_blacklist`

```sql
-- ✅ CORRECTO: Estructura de blacklist
CREATE TABLE token_blacklist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token TEXT NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blacklisted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    reason TEXT  -- 'manual_logout', 'inactivity', 'token_expired'
);

CREATE INDEX idx_token_blacklist_token ON token_blacklist(token);
CREATE INDEX idx_token_blacklist_expires_at ON token_blacklist(expires_at);
```

**Validación en Functions**:
```sql
-- Verificar si token está en blacklist
IF EXISTS (SELECT 1 FROM token_blacklist WHERE token = p_token AND expires_at > NOW()) THEN
    v_error_hint := 'token_blacklisted';
    RAISE EXCEPTION 'Token inválido';
END IF;
```

### 7.2 Inactivity Detection

**CONVENCIÓN**: Tracking de última actividad del usuario

```sql
-- ✅ CORRECTO: Columna de tracking
ALTER TABLE users ADD COLUMN last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Actualizar en cada request autenticado
CREATE OR REPLACE FUNCTION update_user_activity(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE users SET last_activity_at = NOW() WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Timeouts estándar**:
- Inactividad general: 120 minutos (2 horas)
- Warning previo: 5 minutos antes
- Cleanup de blacklist: 24 horas

### 7.3 Password Recovery (HU-004)

**CONVENCIÓN**: Sistema de recuperación seguro con tokens de un solo uso

```sql
-- ✅ CORRECTO: Tabla de tokens de recuperación
CREATE TABLE password_recovery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_password_recovery_token ON password_recovery(token);
CREATE INDEX idx_password_recovery_email ON password_recovery(email);
CREATE INDEX idx_password_recovery_expires_at ON password_recovery(expires_at);
```

**Parámetros estándar**:
- Token: 32 bytes random, URL-safe encoding
- Expiración: 24 horas desde creación
- Rate limiting: 3 solicitudes/15 minutos por email
- Uso único: `used_at` marcado al cambiar password
- Privacidad: No revelar si email existe

**Funciones RPC**:
- `request_password_reset(p_email, p_ip_address)`: Genera token
- `validate_reset_token(p_token)`: Valida estado del token
- `reset_password(p_token, p_new_password, p_ip_address)`: Cambia password
- `cleanup_expired_recovery_tokens()`: Limpieza automática

**Response hints**:
| Hint | Significado |
|------|-------------|
| `rate_limit_exceeded` | Límite de solicitudes alcanzado |
| `token_expired` | Token válido pero expirado |
| `token_invalid` | Token no existe o inválido |
| `token_used` | Token ya fue utilizado |
| `password_weak` | Password no cumple política |

### 7.4 Multi-Tab Sync (Flutter)

**CONVENCIÓN**: Usar `localStorage` events para sincronizar estado entre pestañas

```dart
// ✅ CORRECTO: Listener para cambios en storage
class AuthRepository {
  StreamController<AuthState> _authStateController = StreamController.broadcast();

  AuthRepository() {
    // Escuchar cambios en localStorage (multi-tab)
    window.addEventListener('storage', (event) {
      if (event.key == 'auth_token' && event.newValue == null) {
        // Token eliminado en otra pestaña → logout local
        _authStateController.add(AuthState.unauthenticated());
      }
    });
  }
}
```

### 7.5 Audit Logging

**CONVENCIÓN**: Tabla `audit_logs` para eventos de seguridad

```sql
-- ✅ CORRECTO: Estructura de auditoría
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL,  -- 'login', 'logout', 'password_change', etc.
    event_subtype TEXT,  -- 'manual', 'inactivity', 'token_expired'
    ip_address INET,
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_event_type ON audit_logs(event_type);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
```

**Registro en Functions**:
```sql
-- Registrar logout
INSERT INTO audit_logs (user_id, event_type, event_subtype, ip_address, metadata)
VALUES (
    p_user_id,
    'logout',
    p_logout_type,  -- 'manual', 'inactivity', 'token_expired'
    p_ip_address,
    json_build_object('session_duration', p_session_duration)::jsonb
);
```

---

## 🔄 10. GIT WORKFLOW

### 10.1 Branches

```
main                    ← Código en producción
└── develop             ← Integración de features
    └── feature/HU-XXX  ← Feature branch por Historia de Usuario
```

### 10.2 Commits

**Formato**: `[HU-XXX] tipo: descripción`

```bash
# ✅ CORRECTO
git commit -m "[HU-001] feat: Agregar función register_user() en PostgreSQL"
git commit -m "[HU-001] fix: Corregir PG_EXCEPTION_HINT en error handling"
git commit -m "[HU-001] docs: Actualizar schema_hu001.md con SQL final"

# ❌ INCORRECTO
git commit -m "fix bug"
git commit -m "update code"
```

**Tipos**:
- `feat`: Nueva funcionalidad
- `fix`: Bug fix
- `docs`: Solo documentación
- `refactor`: Refactorización sin cambio de funcionalidad
- `test`: Agregar/modificar tests
- `chore`: Tareas de mantenimiento

---

## 🚨 11. REGLAS CRÍTICAS - NO NEGOCIABLES

### ❌ PROHIBIDO:

1. **Hardcodear valores** que deberían ser configurables
2. **Usar rutas con prefijos** de módulo (`/auth/`, `/products/`)
3. **Exponer datos sensibles** (`password_hash`, `token_confirmacion`)
4. **Asumir variables PostgreSQL** sin verificar docs oficiales
5. **Implementar sin leer** este documento primero
6. **Mezclar naming conventions** (snake_case en Dart, camelCase en SQL)
7. **Crear documentación** sin actualizar después de implementar
8. **Hacer commits** sin referencia a HU

### ✅ OBLIGATORIO:

1. **Leer este documento** antes de cada HU
2. **Validar mappings** snake_case ↔ camelCase
3. **Usar Design System** (nunca hardcodear colores/spacing)
4. **Documentar cambios** vs diseño inicial
5. **Escribir tests** con coverage mínimo
6. **Actualizar docs** después de implementar
7. **Reportar al arquitecto** si encuentras algo no documentado

---

## 📞 12. PROCESO DE CONSULTA

### Si encuentras algo no documentado aquí:

```
1. ⏸️  PAUSAR implementación
2. 📝 Documentar la duda en GitHub Issue
3. 🔍 Mencionar a @web-architect-expert
4. ⏳ ESPERAR respuesta y actualización de este documento
5. ✅ Continuar implementación con convención definida
```

### Si encuentras conflicto entre docs:

**Orden de prioridad**:
1. `00-CONVENTIONS.md` (este documento) ← MAYOR AUTORIDAD
2. `SPECS-FOR-AGENTS-HU-XXX.md`
3. Archivos específicos (`schema_hu001.md`, etc.)
4. Comentarios en código

---

## 📊 CHECKLIST DE VALIDACIÓN

Antes de marcar HU como completada, validar:

- [ ] Naming conventions aplicadas (BD y Dart)
- [ ] Rutas flat sin prefijos
- [ ] Error handling con patrón estándar
- [ ] API responses con formato JSON correcto
- [ ] Design System usado (sin hardcoded colors)
- [ ] Tests con coverage mínimo
- [ ] Documentación actualizada
- [ ] Commits con formato correcto
- [ ] Código revisado por QA

---

## 📚 REFERENCIAS

- [ROUTING_CONVENTIONS.md](frontend/ROUTING_CONVENTIONS.md)
- [LESSONS_LEARNED.md](../LESSONS_LEARNED.md)
- [MIGRATION_EDGE_TO_DB_FUNCTIONS.md](backend/MIGRATION_EDGE_TO_DB_FUNCTIONS.md)

---

## 🚫 7. CÓDIGO LIMPIO

**Requisito**: `flutter analyze --no-pub` debe retornar `0 issues found`

| ❌ Incorrecto | ✅ Correcto | Razón |
|--------------|------------|-------|
| `import 'dart:html';` | `import 'package:web/web.dart';` | Deprecado |
| `.withOpacity(0.5)` | `Color.fromRGBO(r,g,b,0.5)` | Deprecado |
| Imports no usados | Solo imports necesarios | Lint |
| Variables no usadas | Solo variables usadas | Lint |

**Antes de completar HU**: `flutter analyze --no-pub` y corregir issues.

---

**Versión**: 1.2
**Última revisión**: 2025-10-09
**Cambios v1.2**: Agregada sección 6.4 Patrón Bloc consistente
**Próxima revisión**: Después de HU-010
**Mantenido por**: @web-architect-expert
