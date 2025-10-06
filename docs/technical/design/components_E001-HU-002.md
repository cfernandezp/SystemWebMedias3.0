# Componentes UI - HU-002: Login al Sistema

**HU relacionada**: E001-HU-002
**Estado**: 🔵 En Desarrollo

**DISEÑADO POR**: @web-architect-expert (2025-10-05)
**IMPLEMENTADO POR**: @ux-ui-expert (PENDIENTE)

---

## Página 1: LoginPage

### Propósito:
Página principal de autenticación con formulario de login.

### Ruta:
`/login`

### Diseño Propuesto:

```dart
// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/login_form.dart';
import '../../../../shared/design_system/atoms/corporate_button.dart';
import '../../../../shared/design_system/molecules/auth_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header con logo y título
                  const AuthHeader(
                    title: 'Iniciar Sesión',
                    subtitle: 'Ingresa a tu cuenta',
                  ),

                  const SizedBox(height: 32),

                  // Formulario de login
                  const LoginForm(),

                  const SizedBox(height: 24),

                  // Enlace a registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Regístrate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### Características:

- ✅ **Responsive**: Max width 440px en desktop, full width en mobile
- ✅ **Scrollable**: SingleChildScrollView para teclados móviles
- ✅ **Centered**: Center + MainAxisAlignment.center
- ✅ **Theme-aware**: Usa `Theme.of(context)`

---

## Widget 1: LoginForm

### Propósito:
Formulario de login con validaciones, estados y manejo de errores.

### Diseño Propuesto:

```dart
// lib/features/auth/presentation/widgets/login_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/design_system/atoms/corporate_button.dart';
import '../../../../shared/design_system/atoms/corporate_form_field.dart';
import '../../../../core/utils/validators.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              rememberMe: _rememberMe,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Redirección a /home (CA-003)
          Navigator.pushReplacementNamed(context, '/home');

          // Mostrar SnackBar de bienvenida
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Bienvenido'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthError) {
          // Mostrar error (CA-004, CA-005, CA-006, CA-007)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              action: state.errorHint == 'email_not_verified'
                  ? SnackBarAction(
                      label: 'Reenviar',
                      textColor: Colors.white,
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              ResendConfirmationRequested(
                                email: _emailController.text.trim(),
                              ),
                            );
                      },
                    )
                  : null,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo Email (CA-001, CA-002)
              CorporateFormField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'tu@email.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                enabled: !isLoading,
                validator: Validators.email,
              ),

              const SizedBox(height: 16),

              // Campo Contraseña (CA-001, CA-002)
              CorporateFormField(
                controller: _passwordController,
                labelText: 'Contraseña',
                hintText: '••••••••',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                enabled: !isLoading,
                validator: Validators.required('Contraseña es requerida'),
              ),

              const SizedBox(height: 8),

              // Link "¿Olvidaste tu contraseña?" (CA-001)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),

              const SizedBox(height: 8),

              // Checkbox "Recordarme" (CA-001, CA-008)
              RememberMeCheckbox(
                value: _rememberMe,
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
              ),

              const SizedBox(height: 24),

              // Botón "Iniciar Sesión" (CA-001)
              CorporateButton(
                text: 'Iniciar Sesión',
                onPressed: isLoading ? null : _handleSubmit,
                isLoading: isLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Características:

- ✅ **Validaciones frontend** (CA-002): Email formato, campos requeridos
- ✅ **Estados**: Loading, Success, Error con BlocConsumer
- ✅ **Navegación** (CA-003): Redirect a `/home` on success
- ✅ **Mensajes de error** (CA-004, CA-005, CA-006, CA-007): SnackBar con texto específico
- ✅ **Reenviar confirmación** (CA-006): Action en SnackBar si `hint == 'email_not_verified'`
- ✅ **Remember Me** (CA-008): Checkbox que envía parámetro al backend

---

## Widget 2: RememberMeCheckbox

### Propósito:
Checkbox personalizado para la funcionalidad "Recordarme".

### Diseño Propuesto:

```dart
// lib/features/auth/presentation/widgets/remember_me_checkbox.dart

import 'package:flutter/material.dart';
import '../../../../shared/design_system/tokens/design_colors.dart';

class RememberMeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const RememberMeCheckbox({
    Key? key,
    required this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: DesignColors.primaryTurquoise,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onChanged != null ? () => onChanged!(!value) : null,
            child: Text(
              'Recordarme',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignColors.textSecondary,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### Características:

- ✅ **Tamaño fijo**: 24x24px para touch target
- ✅ **Color corporativo**: `primaryTurquoise` cuando activo
- ✅ **Tap en label**: GestureDetector para mejor UX
- ✅ **Disabled state**: `onChanged: null` deshabilita

---

## Página 2: HomePage

### Propósito:
Página principal tras login exitoso (landing page autenticada).

### Ruta:
`/home`

### Diseño Propuesto:

```dart
// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../shared/design_system/atoms/corporate_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Venta de Medias'),
        actions: [
          // Botón de Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícono de bienvenida
                    Icon(
                      Icons.check_circle_outline,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(height: 24),

                    // Saludo personalizado (CA-003)
                    Text(
                      '¡Bienvenido!',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),

                    const SizedBox(height: 8),

                    // Nombre del usuario
                    Text(
                      state.user.nombreCompleto,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),

                    const SizedBox(height: 16),

                    // Info adicional
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _InfoRow(
                              label: 'Email:',
                              value: state.user.email,
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Rol:',
                              value: state.user.rol ?? 'Sin asignar',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Estado:',
                              value: state.user.estado,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Placeholder para futuras funcionalidades
                    const Text(
                      'Funcionalidades próximamente...',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            );
          }

          // Fallback si no autenticado
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
```

### Características:

- ✅ **AppBar**: Título + botón logout
- ✅ **Saludo personalizado** (CA-003): Muestra `nombreCompleto` del usuario
- ✅ **Info del usuario**: Email, rol, estado
- ✅ **Logout**: IconButton que dispara `LogoutRequested` event
- ✅ **Placeholder**: Mensaje para futuras features

---

## Widget 3: AuthGuard (Middleware de rutas protegidas)

### Propósito:
Wrapper para páginas protegidas que requieren autenticación (CA-010).

### Diseño Propuesto:

```dart
// lib/features/auth/presentation/widgets/auth_guard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthUnauthenticated) {
          // Redirigir a login (CA-010)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');

            // Mostrar mensaje de sesión expirada si aplica
            if (state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          });

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return child;
        }

        // Fallback
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
```

### Uso:

```dart
// En main.dart routes
'/home': (context) => const AuthGuard(
      child: HomePage(),
    ),
'/products': (context) => const AuthGuard(
      child: ProductsPage(),
    ),
```

---

## Validadores (Utils)

### Diseño Propuesto:

```dart
// lib/core/utils/validators.dart

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email es requerido';
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Formato de email inválido';
    }

    return null;
  }

  static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return message;
      }
      return null;
    };
  }
}
```

---

## Archivos a Crear:

```
lib/features/auth/presentation/
├── pages/
│   ├── login_page.dart                    ← NUEVO (HU-002)
│   ├── register_page.dart                 ← YA EXISTE (HU-001)
│   ├── confirm_email_page.dart            ← YA EXISTE (HU-001)
│   └── email_confirmation_waiting_page.dart ← YA EXISTE (HU-001)
│
├── widgets/
│   ├── login_form.dart                    ← NUEVO (HU-002)
│   ├── remember_me_checkbox.dart          ← NUEVO (HU-002)
│   ├── auth_guard.dart                    ← NUEVO (HU-002)
│   ├── register_form.dart                 ← YA EXISTE (HU-001)
│   └── email_confirmation_waiting.dart    ← YA EXISTE (HU-001)

lib/features/home/presentation/
└── pages/
    └── home_page.dart                     ← NUEVO (HU-002)

lib/core/utils/
└── validators.dart                        ← ACTUALIZAR (agregar .required())
```

---

## Implementación Final:

✅ **COMPLETADO** - Implementado el 2025-10-05 por @ux-ui-expert

### Checklist de Validación:

- [x] LoginPage responsive (max 440px)
- [x] LoginForm con validaciones frontend
- [x] RememberMeCheckbox con diseño corporativo
- [x] HomePage con saludo personalizado
- [x] AuthGuard implementado en rutas protegidas
- [x] SnackBar con mensajes específicos por error
- [x] Navegación a /home tras login exitoso
- [x] Botón "Reenviar" en error `email_not_verified`
- [x] Validators actualizado con método `required()`
- [x] AuthState actualizado con estados AuthAuthenticated y AuthUnauthenticated
- [x] AuthEvent actualizado con eventos LoginRequested, LogoutRequested, CheckAuthStatus
- [x] main.dart actualizado con rutas /login y /home (con AuthGuard)
- [x] Widget tests creados con cobertura de casos principales

---

## Cambios vs Diseño Inicial:

### Archivos Creados:
1. ✅ `lib/features/auth/presentation/pages/login_page.dart`
2. ✅ `lib/features/auth/presentation/widgets/login_form.dart`
3. ✅ `lib/features/auth/presentation/widgets/remember_me_checkbox.dart`
4. ✅ `lib/features/auth/presentation/widgets/auth_guard.dart`
5. ✅ `lib/features/home/presentation/pages/home_page.dart`
6. ✅ `lib/core/utils/validators.dart`

### Archivos Actualizados:
1. ✅ `lib/features/auth/presentation/bloc/auth_state.dart` - Agregados estados `AuthAuthenticated` y `AuthUnauthenticated`
2. ✅ `lib/features/auth/presentation/bloc/auth_event.dart` - Agregados eventos `LoginRequested`, `LogoutRequested`, `CheckAuthStatus`
3. ✅ `lib/features/auth/presentation/widgets/register_form.dart` - Corregida ruta de login de `/auth/login` a `/login`
4. ✅ `lib/main.dart` - Agregadas rutas `/login` y `/home`, BlocProvider con CheckAuthStatus

### Tests Creados:
1. ✅ `test/features/auth/presentation/widgets/login_form_test.dart`
2. ✅ `test/features/home/presentation/pages/home_page_test.dart`
3. ✅ `test/core/utils/validators_test.dart`

### Ajustes Realizados:

1. **AuthState y AuthEvent actualizados**:
   - Agregado campo `errorHint` en `AuthError` para permitir acciones contextuales en SnackBar
   - Props cambiado de `List<Object>` a `List<Object?>` para soportar nullables

2. **CorporateFormField**:
   - Campo `labelText` cambiado a `label` para consistencia
   - Ya existía toggle de password visibility (no se requirió cambio)

3. **Validators**:
   - Creado desde cero con métodos: `email()`, `required()`, `minLength()`, `maxLength()`
   - Todos retornan `String? Function(String?)` para uso en TextFormField

4. **HomePage**:
   - Agregado campo "Email verificado" en la card de información
   - Responsive con `ConstrainedBox(maxWidth: 600)`
   - BlocListener para redirección tras logout

5. **AuthGuard**:
   - Usa `addPostFrameCallback` para evitar setState durante build
   - Muestra mensaje de sesión expirada si está presente en state

### Notas Importantes:

- ⚠️ **Dependencia backend**: Los componentes UI están listos pero requieren que @flutter-expert implemente:
  - Models: `LoginRequestModel`, `LoginResponseModel`, `ValidateTokenResponseModel`, `AuthStateModel`
  - Datasource: `login()`, `validateToken()`
  - UseCases: `LoginUser`, `ValidateToken`, `LogoutUser`
  - AuthBloc: Handlers para `LoginRequested`, `LogoutRequested`, `CheckAuthStatus`
  - Persistencia con FlutterSecureStorage

- ✅ **Theme-aware**: Todos los componentes usan `Theme.of(context)` y Design Tokens
- ✅ **Responsive**: LoginPage y HomePage soportan mobile y desktop
- ✅ **Rutas flat**: Todas las rutas sin prefijos (`/login`, `/home`)
- ✅ **Reutilización**: `CorporateButton`, `CorporateFormField`, `AuthHeader` reutilizados de HU-001

### Próximos Pasos:

1. @flutter-expert debe implementar la capa de datos y lógica de negocio
2. Integrar con backend de Supabase (funciones `login_user`, `validate_token`)
3. Ejecutar widget tests tras completar implementación completa
4. Validar flujo E2E con @qa-testing-expert
