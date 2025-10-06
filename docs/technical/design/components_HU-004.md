# Componentes UI/UX - HU-004: Recuperar Contraseña

**Estado**: ✅ Implementado
**Fecha**: 2025-10-06
**Agente**: @ux-ui-expert

---

## 📋 RESUMEN

Implementación completa de UI/UX para recuperación de contraseña con:
- Flujo de solicitud de recuperación
- Validación de token
- Formulario de nueva contraseña
- Indicador de fortaleza en tiempo real
- Manejo de errores (token expirado/inválido/usado)

---

## 🎨 COMPONENTES IMPLEMENTADOS

### 1. PasswordStrengthIndicator Widget

**Archivo**: `lib/features/auth/presentation/widgets/password_strength_indicator.dart`

**Características**:
- Barra de progreso con 3 niveles (débil/media/fuerte)
- Colores semánticos:
  - Rojo (#F44336) - Débil
  - Amarillo (#FFC107) - Media
  - Verde (#4CAF50) - Fuerte
- Lista de criterios con checkmarks
- Actualización en tiempo real

**Criterios de Validación**:
- ✅ Mínimo 8 caracteres
- ✅ Al menos 1 mayúscula (A-Z)
- ✅ Al menos 1 minúscula (a-z)
- ✅ Al menos 1 número (0-9)

**Niveles de Fortaleza**:
```dart
// Débil: < 8 caracteres
// Media: 8+ caracteres + letra + número
// Fuerte: 8+ caracteres + mayúscula + minúscula + número
```

---

### 2. ForgotPasswordPage

**Archivo**: `lib/features/auth/presentation/pages/forgot_password_page.dart`

**Ruta**: `/forgot-password`

**Características**:
- Formulario simple con campo email
- Validación de formato email
- Estados: loading, success, error
- Navegación: volver al login
- Vista de confirmación después de enviar

**Flujo UX**:
1. Usuario ingresa email
2. Click "Enviar enlace de recuperación"
3. Dispatch `PasswordResetRequested(email)`
4. Muestra mensaje: "Si el email existe, se enviará un enlace"
5. Vista de confirmación con opción de reenviar

**UI Elements**:
- AppBar con título y botón back
- Card centrada (max-width: 480px)
- Icono decorativo: `lock_reset`
- Formulario con CorporateFormField
- CorporateButton para enviar
- TextButton para volver al login

---

### 3. ResetPasswordPage

**Archivo**: `lib/features/auth/presentation/pages/reset_password_page.dart`

**Ruta**: `/reset-password/:token`

**Características**:
- Validación automática de token al cargar
- Formulario con 2 campos:
  - Nueva contraseña
  - Confirmar contraseña
- Indicador de fortaleza en tiempo real
- Validaciones:
  - Mínimo 8 caracteres
  - Mayúscula + minúscula + número
  - Contraseñas coinciden
- Manejo de errores de token:
  - Token inválido
  - Token expirado (24h)
  - Token ya usado

**Flujo UX**:
1. Al cargar: dispatch `ValidateResetTokenRequested(token)`
2. Si token válido → Muestra formulario
3. Si token inválido → Dialog de error + redirect
4. Usuario ingresa nueva contraseña
5. Ve indicador de fortaleza en tiempo real
6. Click "Cambiar contraseña"
7. Dispatch `ResetPasswordRequested(token, newPassword)`
8. Success → Dialog de éxito + redirect a login

**UI Elements**:
- AppBar sin back button
- Card centrada (max-width: 480px)
- Icono decorativo: `lock_open`
- Formularios con CorporateFormField
- PasswordStrengthIndicator
- Dialogs para:
  - Token expirado
  - Token inválido
  - Token usado
  - Éxito al cambiar contraseña

---

### 4. Actualización LoginForm

**Archivo**: `lib/features/auth/presentation/widgets/login_form.dart`

**Cambio**: Agregado enlace "¿Olvidaste tu contraseña?"

```dart
TextButton(
  onPressed: () => context.go('/forgot-password'),
  child: const Text('¿Olvidaste tu contraseña?'),
)
```

**Posición**: Debajo del campo password, alineado a la derecha

---

## 🛣️ RUTAS AGREGADAS

### app_router.dart

```dart
// Rutas públicas agregadas
GoRoute(
  path: '/forgot-password',
  name: 'forgot-password',
  builder: (context, state) => const ForgotPasswordPage(),
),
GoRoute(
  path: '/reset-password/:token',
  name: 'reset-password',
  builder: (context, state) {
    final token = state.pathParameters['token']!;
    return ResetPasswordPage(token: token);
  },
),
```

**Rutas públicas actualizadas**:
- `/login`
- `/register`
- `/forgot-password` ← NUEVO
- `/reset-password/:token` ← NUEVO
- `/confirm-email/:token`

---

## 🎯 VALIDADORES AGREGADOS

### validators.dart

**Nuevos validadores**:

```dart
// Validar fortaleza de contraseña
Validators.password(value)

// Validar coincidencia de contraseñas
Validators.passwordMatch(originalPassword)
```

**Reglas**:
- Mínimo 8 caracteres
- Al menos 1 mayúscula
- Al menos 1 minúscula
- Al menos 1 número

---

## 🔄 INTEGRACIÓN CON BLOC

### Estados Esperados (del @flutter-expert)

**ForgotPassword**:
- `PasswordResetRequestInProgress` - Enviando solicitud
- `PasswordResetRequestSuccess` - Email enviado
- `PasswordResetRequestFailure` - Error

**ResetPassword**:
- `ResetTokenValidationInProgress` - Validando token
- `ResetTokenValid` - Token válido
- `ResetTokenInvalid` - Token inválido/expirado/usado
- `ResetPasswordInProgress` - Cambiando contraseña
- `ResetPasswordSuccess` - Contraseña cambiada
- `AuthError` - Error general

### Eventos Disparados

```dart
// Solicitar recuperación
PasswordResetRequested(email: String)

// Validar token
ValidateResetTokenRequested(token: String)

// Cambiar contraseña
ResetPasswordRequested(token: String, newPassword: String)
```

---

## 📱 RESPONSIVE DESIGN

**Implementado**:
- ✅ Layout centrado con max-width: 480px
- ✅ Scroll vertical en pantallas pequeñas
- ✅ Cards con padding adaptativo
- ✅ Formularios responsivos con CorporateFormField

**Breakpoints**:
- Mobile: < 600px
- Tablet: 600px - 900px
- Desktop: > 900px

---

## 🎨 DESIGN SYSTEM

### Componentes Reutilizados

**Atoms**:
- ✅ `CorporateButton` (primary/secondary)
- ✅ `CorporateFormField` (pill-shaped, animaciones)

**Theme-aware**:
```dart
// ✅ CORRECTO (usa Theme)
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.error

// ❌ NO hacer hardcode
Color(0xFF4ECDC4)
```

### Colores Utilizados

```dart
// Semánticos (del theme)
primary: Color(0xFF4ECDC4)    // Turquesa
error: Color(0xFFF44336)      // Rojo

// Fortaleza de contraseña
weak: Color(0xFFF44336)       // Rojo
medium: Color(0xFFFFC107)     // Amarillo
strong: Color(0xFF4CAF50)     // Verde

// Neutrales
textPrimary: Color(0xFF212121)
textSecondary: Color(0xFF6B7280)
textDisabled: Color(0xFF9CA3AF)
background: Color(0xFFFAFAFA)
surface: Color(0xFFFFFFFF)
border: Color(0xFFE5E7EB)
```

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### Funcionalidad
- [x] ForgotPasswordPage con formulario
- [x] Validación de email formato
- [x] ResetPasswordPage con formulario
- [x] Validación de contraseña fortaleza
- [x] PasswordStrengthIndicator widget
- [x] Confirmación de contraseña
- [x] Manejo de token inválido/expirado/usado
- [x] Navegación y rutas configuradas
- [x] Enlace desde LoginForm

### Design System
- [x] Usa componentes existentes (CorporateButton, CorporateFormField)
- [x] Theme-aware (NO hardcoded colors)
- [x] Responsive layout (max-width constraints)
- [x] Animaciones consistentes
- [x] Estados loading/success/error

### UX
- [x] Mensajes descriptivos (no revelar si email existe)
- [x] Feedback visual (SnackBars, Dialogs)
- [x] Loading states claros
- [x] Navegación intuitiva
- [x] Validaciones en tiempo real

### Accesibilidad
- [x] Labels en campos de formulario
- [x] Hints descriptivos
- [x] Colores con contraste adecuado
- [x] Íconos descriptivos
- [x] Mensajes de error claros

---

## 🔗 DEPENDENCIAS

### Frontend (Requiere)
- @flutter-expert: Implementar Bloc (events/states)
- @flutter-expert: Implementar lógica de envío de email

### Backend (Requiere)
- @supabase-expert: Funciones PostgreSQL (request_password_reset, validate_reset_token, reset_password)
- @supabase-expert: Tabla password_recovery

---

## 📝 PRÓXIMOS PASOS

1. ✅ **UI/UX**: Implementado por @ux-ui-expert
2. ⏳ **Backend**: @supabase-expert debe implementar funciones PostgreSQL
3. ⏳ **Bloc**: @flutter-expert debe implementar lógica de estado
4. ⏳ **Email**: @flutter-expert debe implementar envío de emails
5. ⏳ **Testing**: Tests unitarios y de integración

---

## 📸 CAPTURAS DE FLUJO

### Flujo 1: Solicitar Recuperación
```
LoginPage → Click "¿Olvidaste tu contraseña?"
   ↓
ForgotPasswordPage
   ↓ Ingresa email
   ↓ Click "Enviar enlace"
   ↓
Vista de Confirmación
   ↓
Email enviado (backend)
```

### Flujo 2: Cambiar Contraseña
```
Email → Click enlace
   ↓
ResetPasswordPage (validando token...)
   ↓ Token válido
   ↓
Formulario nueva contraseña
   ↓ Ingresa password
   ↓ Ve indicador fortaleza
   ↓ Confirma password
   ↓ Click "Cambiar contraseña"
   ↓
Dialog de éxito
   ↓
Redirect a LoginPage
```

---

**Estado Final**: ✅ UI/UX Completado
**Fecha**: 2025-10-06
