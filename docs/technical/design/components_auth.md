# Components Auth Module

Archivo consolidado de componentes UI para el módulo de Autenticación.

---

## HU-001: Registro de Alta al Sistema Web {#hu-001}

### Page: RegisterPage
- Formulario con campos: email, password, nombreCompleto, rol
- Validaciones en tiempo real
- Estados: loading, success, error
- Navegación: → `/login` (después de registro exitoso)

### Components:
- CorporateButton (Atom)
- CorporateFormField (Atom)
- RegisterForm (Molecule)

**Status**: ✅ Implementado
**Location**: `lib/features/auth/presentation/pages/register_page.dart`

---

## HU-002: Login por Roles con Aprobación {#hu-002}

### Page: LoginPage
- Formulario con campos: email, password, rememberMe
- Validaciones de email/password
- Estados: loading, success, error
- Navegación: → `/dashboard` (después de login exitoso)

### Widget: LoginForm
- Campos email, password
- Checkbox "Recordarme"
- Link "¿Olvidaste tu contraseña?" → `/forgot-password` (HU-004)
- Botón "Iniciar Sesión"

**Status**: ✅ Implementado
**Location**: `lib/features/auth/presentation/widgets/login_form.dart`

---

## HU-003: Logout Seguro {#hu-003}

### Components:
- LogoutButton (Atom): Botón de logout en AppBar
- LogoutConfirmationDialog (Molecule): Dialog de confirmación antes de logout
- InactivityWarningDialog (Organism): Dialog de aviso de inactividad con countdown
- SessionExpiredSnackbar (Atom): Snackbar para sesión expirada
- UserMenuDropdown (Organism): Menú desplegable con opciones de usuario

**Status**: ✅ Implementado
**Locations**:
- `lib/shared/design_system/atoms/logout_button.dart`
- `lib/features/auth/presentation/widgets/logout_confirmation_dialog.dart`
- `lib/features/auth/presentation/widgets/inactivity_warning_dialog.dart`
- `lib/features/auth/presentation/widgets/session_expired_snackbar.dart`
- `lib/features/auth/presentation/widgets/user_menu_dropdown.dart`

---

## HU-004: Recuperar Contraseña {#hu-004}

### Page: ForgotPasswordPage

**Ruta**: `/forgot-password`

**Diseño**:
```
┌─────────────────────────────────────┐
│   [Logo]                            │
│                                     │
│   Recuperar Contraseña              │
│                                     │
│   Ingresa tu email y te enviaremos │
│   un enlace para recuperar tu      │
│   contraseña.                       │
│                                     │
│   ┌─────────────────────────────┐  │
│   │ Email                       │  │
│   └─────────────────────────────┘  │
│                                     │
│   [Enviar enlace de recuperación]  │
│                                     │
│   ← Volver al login                │
└─────────────────────────────────────┘
```

**Estados**:
1. **Inicial**: Formulario vacío
2. **Loading**: Spinner mientras procesa solicitud
3. **Success**: Mensaje de confirmación + instrucciones de revisar email
4. **Error**: Mensaje de error (rate limit, network, etc.)

**Componentes utilizados**:
- `CorporateFormField` (email input)
- `CorporateButton` (submit)
- `CircularProgressIndicator` (loading)
- `SnackBar` (feedback)

**Validaciones Frontend**:
- Email no vacío
- Email formato válido
- Deshabilitar botón durante loading

**Navegación**:
- Link "← Volver al login" → `/login`
- Auto-redirect a `/login` después de 10 segundos (success)

**Status**: ✅ Implementado
**Location**: `lib/features/auth/presentation/pages/forgot_password_page.dart`

**Bloc Events**:
- `PasswordResetRequested(email: string)`

**Bloc States**:
- `PasswordResetRequestInProgress`
- `PasswordResetRequestSuccess(message: string)`
- `PasswordResetRequestFailure(error: string)`

---

### Page: ResetPasswordPage

**Ruta**: `/reset-password/:token`

**Diseño**:
```
┌─────────────────────────────────────┐
│   [Logo]                            │
│                                     │
│   Crear Nueva Contraseña            │
│                                     │
│   ┌─────────────────────────────┐  │
│   │ Nueva Contraseña            │  │
│   │ [👁]                        │  │
│   └─────────────────────────────┘  │
│                                     │
│   [Indicador de Fortaleza]          │
│   ████░░░░ Débil                    │
│                                     │
│   ┌─────────────────────────────┐  │
│   │ Confirmar Contraseña        │  │
│   │ [👁]                        │  │
│   └─────────────────────────────┘  │
│                                     │
│   ✓ Mínimo 8 caracteres             │
│   ✓ Al menos una mayúscula          │
│   ✓ Al menos una minúscula          │
│   ✓ Al menos un número              │
│                                     │
│   [Cambiar Contraseña]              │
└─────────────────────────────────────┘
```

**Flujo de Validación**:
1. **Al cargar página**:
   - Extraer token de URL
   - Llamar `validate_reset_token(token)`
   - Mostrar loading mientras valida

2. **Token válido**:
   - Mostrar formulario de nueva contraseña
   - Habilitar interacción

3. **Token inválido/expirado/usado**:
   - Mostrar Dialog con mensaje específico
   - Botón "Solicitar nuevo enlace" → `/forgot-password`

**Estados del Token**:
- ✅ **Válido**: Formulario habilitado
- ❌ **Inválido**: "Enlace de recuperación inválido"
- ⏰ **Expirado**: "Enlace expirado (24h)"
- ✔️ **Usado**: "Este enlace ya fue utilizado"

**Componentes utilizados**:
- `CorporateFormField` (password inputs con obscureText)
- `PasswordStrengthIndicator` (widget custom)
- `CorporateButton` (submit)
- `AlertDialog` (errores de token)

**Validaciones Frontend**:
- Mínimo 8 caracteres
- Al menos 1 mayúscula
- Al menos 1 minúscula
- Al menos 1 número
- Contraseñas coinciden
- Deshabilitar botón si no cumple reglas

**Navegación**:
- Success → `/login` (auto-redirect con dialog de confirmación)
- Token inválido → `/forgot-password` (manual via button)

**Status**: ✅ Implementado
**Location**: `lib/features/auth/presentation/pages/reset_password_page.dart`

**Bloc Events**:
- `ResetTokenValidationRequested(token: string)`
- `PasswordResetSubmitted(token: string, newPassword: string)`

**Bloc States**:
- `ResetTokenValidationInProgress`
- `ResetTokenValid(userId: string, expiresAt: DateTime)`
- `ResetTokenInvalid(message: string)`
- `ResetPasswordInProgress`
- `ResetPasswordSuccess(message: string)`
- `ResetPasswordFailure(error: string)`

---

### Widget: PasswordStrengthIndicator

**Diseño**:
```dart
/// Widget que muestra la fortaleza de una contraseña en tiempo real
///
/// Niveles:
/// - Muy débil: 0-1 criterios (rojo)
/// - Débil: 2 criterios (naranja)
/// - Media: 3 criterios (amarillo)
/// - Fuerte: 4 criterios (verde)
///
/// Criterios evaluados:
/// 1. Mínimo 8 caracteres
/// 2. Al menos una mayúscula
/// 3. Al menos una minúscula
/// 4. Al menos un número
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showDetails;  // Mostrar checklist de criterios

  // ...
}
```

**Visual**:
- Barra de progreso animada
- Color dinámico según fortaleza
- Lista de criterios con checkmarks
- Actualización en tiempo real (onChanged)

**Colores**:
- Muy débil: `DesignColors.error` (rojo)
- Débil: `DesignColors.warning` (naranja)
- Media: `Color(0xFFFFC107)` (amarillo)
- Fuerte: `DesignColors.success` (verde)

**Status**: ✅ Implementado
**Location**: `lib/features/auth/presentation/widgets/password_strength_indicator.dart`

---

## Routing Actualizado

```dart
// lib/core/routing/app_router.dart
routes: {
  '/': (context) => RegisterPage(),
  '/register': (context) => RegisterPage(),
  '/login': (context) => LoginPage(),
  '/forgot-password': (context) => ForgotPasswordPage(),  // ⭐ HU-004
  '/reset-password': (context) => ResetPasswordPage(),    // ⭐ HU-004
  '/dashboard': (context) => DashboardPage(),
  // ...
}
```

**Convenciones**:
- Rutas FLAT (sin prefijos `/auth/`)
- Kebab-case para rutas multi-palabra
- Token pasado via query parameter en ResetPasswordPage

---

## Design System - Tokens Utilizados

### Colores
- Primary: `Theme.of(context).colorScheme.primary` (#4ECDC4)
- Error: `DesignColors.error` (#F44336)
- Success: `DesignColors.success` (#4CAF50)
- Warning: `DesignColors.warning` (#FF9800)

### Spacing
- Form field spacing: `DesignSpacing.md` (16px)
- Button padding: `DesignSpacing.lg` (24px)
- Card padding: `DesignSpacing.xl` (32px)

### Typography
- Page title: `Theme.of(context).textTheme.headlineMedium`
- Body text: `Theme.of(context).textTheme.bodyMedium`
- Helper text: `Theme.of(context).textTheme.bodySmall`

### Responsive
- Mobile: `< 768px` (1 column)
- Desktop: `>= 768px` (centered form, max-width 500px)

---

**Status**: ✅ Todos los componentes implementados
**Pendiente**: Tests de widgets (responsabilidad de @qa-testing-expert)

**Última actualización**: 2025-10-06
**Mantenido por**: @web-architect-expert
