# Componentes UI - HU-001: Registro de Alta al Sistema

**Metodología**: Atomic Design
**HU relacionada**: E001-HU-001
**Tema**: Turquesa Moderno Retail (ver `tokens.md`)
**Estado**: 🎨 Diseño

**DISEÑADO POR**: @web-architect-expert (2025-10-04)
**IMPLEMENTADO POR**: @ux-ui-expert (Pendiente)

---

## Páginas (Templates)

### RegisterPage

**Ubicación**: `lib/features/auth/presentation/pages/register_page.dart`
**Ruta**: `/register`
**Responsive**: Mobile, Tablet, Desktop

#### Diseño Propuesto:

**Layout Desktop (≥1200px)**:
- Diseño split-screen (50/50)
- Izquierda: Imagen branding + descripción del sistema
- Derecha: Formulario de registro centrado
- Max width form: 480px

**Layout Mobile (<768px)**:
- Full width con padding 16px
- Logo centrado en top
- Formulario debajo

```dart
class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.backgroundLight, // #F9FAFB
      body: ResponsiveBuilder(
        mobile: (context) => _MobileLayout(),
        desktop: (context) => _DesktopLayout(),
      ),
    );
  }
}
```

#### Componentes incluidos:
- `RegisterForm` (Organism)
- `AuthHeader` (Molecule) - Logo + título
- `BrandingSection` (Organism) - Solo desktop

---

## Organisms

### RegisterForm

**Ubicación**: `lib/features/auth/presentation/widgets/register_form.dart`
**Estado**: 🎨 Diseño

#### Diseño Propuesto:

```dart
class RegisterForm extends StatefulWidget {
  final VoidCallback? onSuccess;

  const RegisterForm({Key? key, this.onSuccess}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreCompletoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          // Mostrar SnackBar success (tema turquesa)
          // Navegar a ConfirmEmailPage
        } else if (state is AuthRegisterError) {
          // Mostrar SnackBar error
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              Text(
                'Crear cuenta',
                style: DesignTextStyle.headlineLarge, // 28px, primaryDark
              ),
              SizedBox(height: DesignDimensions.sectionSpacing), // 16px

              // Campo Email
              CorporateFormField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) => _validateEmail(value),
              ),
              SizedBox(height: DesignDimensions.sectionSpacing),

              // Campo Contraseña
              CorporateFormField(
                controller: _passwordController,
                label: 'Contraseña',
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: (value) => _validatePassword(value),
              ),
              SizedBox(height: DesignDimensions.sectionSpacing),

              // Campo Confirmar Contraseña
              CorporateFormField(
                controller: _confirmPasswordController,
                label: 'Confirmar Contraseña',
                obscureText: true,
                prefixIcon: Icons.lock_outlined,
                validator: (value) => _validateConfirmPassword(value),
              ),
              SizedBox(height: DesignDimensions.sectionSpacing),

              // Campo Nombre Completo
              CorporateFormField(
                controller: _nombreCompletoController,
                label: 'Nombre Completo',
                prefixIcon: Icons.person_outlined,
                validator: (value) => _validateNombreCompleto(value),
              ),
              SizedBox(height: 24.0),

              // Botón Registrarse
              CorporateButton(
                text: 'Registrarse',
                onPressed: state is AuthRegisterLoading ? null : _handleRegister,
                isLoading: state is AuthRegisterLoading,
              ),
              SizedBox(height: 16.0),

              // Enlace a Login
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(color: DesignColors.primaryTurquoise),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Validaciones (RN-006, RN-002)
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email es requerido';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) return 'Formato de email inválido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Contraseña es requerida';
    if (value.length < 8) return 'Contraseña debe tener al menos 8 caracteres';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirmar contraseña es requerido';
    if (value != _passwordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  String? _validateNombreCompleto(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nombre completo es requerido';
    return null;
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final request = RegisterRequestModel(
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        nombreCompleto: _nombreCompletoController.text,
      );

      context.read<AuthBloc>().add(AuthRegisterRequested(request));
    }
  }
}
```

#### Propiedades:
| Prop | Tipo | Descripción | Requerido |
|------|------|-------------|-----------|
| `onSuccess` | VoidCallback? | Callback al registrar exitosamente | ❌ |

#### Design Tokens Usados:
- **Colores**: `DesignColors.primaryTurquoise`, `DesignColors.backgroundLight`
- **Spacing**: `DesignDimensions.sectionSpacing` (16px)
- **Typography**: `DesignTextStyle.headlineLarge` (28px, primaryDark)
- **Components**: `CorporateButton`, `CorporateFormField`

#### Estados:
- `initial`: Formulario vacío
- `loading`: Enviando registro (shimmer en botón)
- `error`: Mostrar SnackBar con mensaje de error
- `success`: Redirigir a ConfirmEmailPage

---

### EmailConfirmationWaiting

**Ubicación**: `lib/features/auth/presentation/widgets/email_confirmation_waiting.dart`
**Propósito**: Página de espera después del registro
**Estado**: 🎨 Diseño

#### Diseño Propuesto:

```dart
class EmailConfirmationWaiting extends StatelessWidget {
  final String email;

  const EmailConfirmationWaiting({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono decorativo
              Icon(
                Icons.mark_email_unread_outlined,
                size: 120,
                color: DesignColors.primaryTurquoise,
              ),
              SizedBox(height: 32),

              // Título
              Text(
                'Confirma tu email',
                style: DesignTextStyle.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Mensaje
              Text(
                'Te enviamos un email a:',
                style: DesignTextStyle.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                email,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: DesignColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Por favor revisa tu bandeja de entrada y haz clic en el enlace de confirmación.',
                style: DesignTextStyle.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Botón reenviar
              CorporateButton(
                text: 'Reenviar email',
                variant: ButtonVariant.secondary, // Outline turquesa
                onPressed: () => _handleResend(context),
              ),
              SizedBox(height: 16),

              // Enlace a login
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text(
                  'Volver al inicio',
                  style: TextStyle(color: DesignColors.primaryTurquoise),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleResend(BuildContext context) {
    context.read<AuthBloc>().add(AuthResendConfirmationRequested(email));
  }
}
```

---

### EmailConfirmationSuccess

**Ubicación**: `lib/features/auth/presentation/widgets/email_confirmation_success.dart`
**Propósito**: Página de confirmación exitosa
**Estado**: 🎨 Diseño

#### Diseño Propuesto:

```dart
class EmailConfirmationSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono success
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: DesignColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: DesignColors.success,
                ),
              ),
              SizedBox(height: 32),

              // Título
              Text(
                'Email confirmado',
                style: DesignTextStyle.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Mensaje
              Text(
                'Tu cuenta está esperando aprobación del administrador',
                style: DesignTextStyle.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Recibirás un email cuando tu cuenta sea aprobada.',
                style: DesignTextStyle.bodyMedium.copyWith(
                  color: DesignColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Botón ir al login
              CorporateButton(
                text: 'Ir al inicio',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### EmailConfirmationError

**Ubicación**: `lib/features/auth/presentation/widgets/email_confirmation_error.dart`
**Propósito**: Enlace de confirmación inválido/expirado
**Estado**: 🎨 Diseño

#### Diseño Propuesto:

```dart
class EmailConfirmationError extends StatelessWidget {
  final String? email;

  const EmailConfirmationError({Key? key, this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono error
              Icon(
                Icons.error_outline,
                size: 120,
                color: DesignColors.error,
              ),
              SizedBox(height: 32),

              // Título
              Text(
                'Enlace inválido',
                style: DesignTextStyle.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Mensaje
              Text(
                'El enlace de confirmación es inválido o ha expirado',
                style: DesignTextStyle.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Botón reenviar (si tenemos email)
              if (email != null) ...[
                CorporateButton(
                  text: 'Reenviar email de confirmación',
                  onPressed: () => _handleResend(context),
                ),
                SizedBox(height: 16),
              ],

              // Enlace a registro
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text(
                  'Volver a registrarse',
                  style: TextStyle(color: DesignColors.primaryTurquoise),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleResend(BuildContext context) {
    if (email != null) {
      context.read<AuthBloc>().add(AuthResendConfirmationRequested(email!));
    }
  }
}
```

---

## Molecules (Reutilizables)

### AuthHeader

**Ubicación**: `lib/shared/design_system/molecules/auth_header.dart`
**Propósito**: Header consistente para páginas de auth
**Estado**: 🎨 Diseño

```dart
class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AuthHeader({
    Key? key,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Image.asset(
          'assets/logo.png',
          height: 48,
        ),
        SizedBox(height: 24),

        // Título
        Text(
          title,
          style: DesignTextStyle.headlineLarge,
        ),

        // Subtítulo (opcional)
        if (subtitle != null) ...[
          SizedBox(height: 8),
          Text(
            subtitle!,
            style: DesignTextStyle.bodyMedium.copyWith(
              color: DesignColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
```

---

## Atoms (ya definidos en tokens.md)

Componentes que se usan en HU-001:

### CorporateButton
- Ubicación: `lib/shared/design_system/atoms/corporate_button.dart`
- Ver especificaciones en `tokens.md`
- Variantes: primary (turquesa) / secondary (outline)

### CorporateFormField
- Ubicación: `lib/shared/design_system/atoms/corporate_form_field.dart`
- Ver especificaciones en `tokens.md`
- Border radius: 28px (pill-shaped)
- Animación focus: 200ms

---

## SnackBars (Feedback)

### Success SnackBar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
          child: Text('Registro exitoso. Revisa tu email para confirmar tu cuenta'),
        ),
      ],
    ),
    backgroundColor: DesignColors.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
```

### Error SnackBar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.error, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
          child: Text(errorMessage),
        ),
      ],
    ),
    backgroundColor: DesignColors.error,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
```

---

## Código Final Implementado:

**IMPLEMENTADO POR**: @ux-ui-expert (2025-10-04)
**ESTADO**: ✅ Completado

### Componentes Implementados:

#### Atoms
- ✅ `lib/shared/design_system/atoms/corporate_button.dart`
- ✅ `lib/shared/design_system/atoms/corporate_form_field.dart`

#### Molecules
- ✅ `lib/shared/design_system/molecules/auth_header.dart`

#### Widgets
- ✅ `lib/features/auth/presentation/widgets/register_form.dart`
- ✅ `lib/features/auth/presentation/widgets/email_confirmation_waiting.dart`
- ✅ `lib/features/auth/presentation/widgets/email_confirmation_success.dart`
- ✅ `lib/features/auth/presentation/widgets/email_confirmation_error.dart`

#### Pages
- ✅ `lib/features/auth/presentation/pages/register_page.dart`
- ✅ `lib/features/auth/presentation/pages/confirm_email_page.dart`
- ✅ `lib/features/auth/presentation/pages/email_confirmation_waiting_page.dart`

### Características Implementadas:

1. **Design System Turquesa Moderno Retail**:
   - ✅ Todos los componentes usan `Theme.of(context)` (theme-aware)
   - ✅ Colores corporativos aplicados correctamente
   - ✅ Border radius según especificación (8px botones, 28px form fields)
   - ✅ Animaciones de 200ms en form fields
   - ✅ Estados hover/pressed con overlays

2. **Integración con AuthBloc**:
   - ✅ BlocProvider en todas las páginas
   - ✅ BlocConsumer en RegisterForm
   - ✅ BlocListener para SnackBars
   - ✅ Estados loading, success, error manejados

3. **Responsive**:
   - ✅ Desktop (≥1200px): Split-screen con branding
   - ✅ Mobile (<1200px): Full-width con scroll
   - ✅ ConstrainedBox maxWidth 480px en formularios

4. **Validaciones**:
   - ✅ Email formato válido
   - ✅ Password ≥8 caracteres
   - ✅ Confirmar password coincide
   - ✅ Nombre completo no vacío
   - ✅ Validación en tiempo real

5. **Navegación**:
   - ✅ RegisterPage → EmailConfirmationWaitingPage
   - ✅ ConfirmEmailPage con token desde URL
   - ✅ Links a login preparados (HU futura)

## Cambios vs Diseño Inicial:

### Mejoras Implementadas:

1. **CorporateButton**:
   - ✅ Usa WidgetStateProperty (reemplazo de MaterialStateProperty deprecated)
   - ✅ Usa withValues(alpha:) en lugar de withOpacity() deprecated
   - ✅ Loading indicator recibe context y color como parámetros

2. **CorporateFormField**:
   - ✅ Toggle automático de visibilidad para campos password
   - ✅ Animación de scale(1.02) en focus
   - ✅ Icono cambia de color (gris → turquesa) en focus
   - ✅ Border focus usa color azul #6366F1 según especificación

3. **AuthHeader**:
   - ✅ Logo placeholder con icono + texto (hasta que exista assets/logo.png)
   - ✅ Propiedad showLogo para controlar visibilidad

4. **RegisterPage**:
   - ✅ Layout desktop con gradiente turquesa en sección branding
   - ✅ AppBar transparente en páginas de confirmación

5. **EmailConfirmationWaitingPage**:
   - ✅ Página separada con scaffold completo
   - ✅ Recibe email desde argumentos de navegación

### Sin Cambios Funcionales:

- Todas las validaciones según RN-001, RN-002, RN-006 implementadas
- Estructura de componentes Atomic Design respetada
- SnackBars con colores y formatos correctos
- Responsive breakpoints según especificación

---

## Navegación

```dart
// Rutas en MaterialApp
routes: {
  '/register': (context) => RegisterPage(),
  '/confirm-email': (context) => ConfirmEmailPage(),
  '/confirm-email/success': (context) => EmailConfirmationSuccessPage(),
  '/confirm-email/error': (context) => EmailConfirmationErrorPage(),
  '/login': (context) => LoginPage(), // HU futura
}

// Deep linking para email confirmation
// URL: https://app.com/confirm?token=abc123
```

---

## Assets Requeridos:

```
assets/
├── logo.png              # Logo del sistema (SVG preferido)
├── branding_image.png    # Imagen para split-screen desktop
└── icons/
    └── (Material Icons - incluidos en Flutter)
```
