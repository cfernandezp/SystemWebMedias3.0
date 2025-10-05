# Rutas a Configurar en main.dart

## Imports Necesarios

```dart
import 'package:system_web_medias/features/auth/presentation/pages/register_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/confirm_email_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/email_confirmation_waiting_page.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
```

## Inicializar GetIt en main()

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar inyección de dependencias
  await di.init();

  runApp(const MyApp());
}
```

## Configurar Tema

```dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestión de Medias',
      debugShowCheckedModeBanner: false,

      // Tema corporativo turquesa
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4ECDC4), // primaryTurquoise
          primary: const Color(0xFF4ECDC4),
          secondary: const Color(0xFF45B7AA),
          error: const Color(0xFFF44336),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),

      // Rutas
      initialRoute: '/auth/register',
      routes: _buildRoutes(),
    );
  }
}
```

## Definir Rutas

```dart
Map<String, WidgetBuilder> _buildRoutes() {
  return {
    // Auth routes
    '/auth/register': (context) => const RegisterPage(),
    '/auth/email-confirmation-waiting': (context) => const EmailConfirmationWaitingPage(),

    // Ruta futura (HU siguiente)
    // '/auth/login': (context) => const LoginPage(),
  };
}
```

## Configurar onGenerateRoute (para token en URL)

```dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestión de Medias',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4ECDC4),
          primary: const Color(0xFF4ECDC4),
          secondary: const Color(0xFF45B7AA),
          error: const Color(0xFFF44336),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      initialRoute: '/auth/register',
      routes: {
        '/auth/register': (context) => const RegisterPage(),
        '/auth/email-confirmation-waiting': (context) => const EmailConfirmationWaitingPage(),
      },
      onGenerateRoute: (settings) {
        // Ruta con query params: /auth/confirm-email?token=XXX
        if (settings.name?.startsWith('/auth/confirm-email') ?? false) {
          // Extraer token desde query params
          final uri = Uri.parse(settings.name!);
          final token = uri.queryParameters['token'];

          return MaterialPageRoute(
            builder: (context) => ConfirmEmailPage(token: token),
          );
        }

        return null; // Dejar que routes maneje el resto
      },
    );
  }
}
```

## Ejemplo Completo de main.dart

```dart
import 'package:flutter/material.dart';
import 'package:system_web_medias/features/auth/presentation/pages/register_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/confirm_email_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/email_confirmation_waiting_page.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar inyección de dependencias (GetIt)
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestión de Medias',
      debugShowCheckedModeBanner: false,

      // Tema corporativo turquesa
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4ECDC4), // primaryTurquoise
          primary: const Color(0xFF4ECDC4),
          secondary: const Color(0xFF45B7AA),
          error: const Color(0xFFF44336),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),

      // Ruta inicial
      initialRoute: '/auth/register',

      // Rutas definidas
      routes: {
        '/auth/register': (context) => const RegisterPage(),
        '/auth/email-confirmation-waiting': (context) => const EmailConfirmationWaitingPage(),
      },

      // Rutas dinámicas (con query params)
      onGenerateRoute: (settings) {
        // Ruta: /auth/confirm-email?token=XXX
        if (settings.name?.startsWith('/auth/confirm-email') ?? false) {
          final uri = Uri.parse(settings.name!);
          final token = uri.queryParameters['token'];

          return MaterialPageRoute(
            builder: (context) => ConfirmEmailPage(token: token),
          );
        }

        return null;
      },
    );
  }
}
```

---

## Deep Linking (Opcional - Para Web)

Si deseas que los enlaces de email funcionen directamente en la web:

### pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  get_it: ^7.6.4
  http: ^1.1.0
  url_strategy: ^0.2.0  # Para remover # en URLs web
```

### main.dart (con deep linking web)

```dart
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Remover # de URLs en web
  setPathUrlStrategy();

  await di.init();

  runApp(const MyApp());
}
```

---

## Navegación Programática

### Desde cualquier widget:

```dart
// Ir a registro
Navigator.pushNamed(context, '/auth/register');

// Ir a espera de confirmación (con email)
Navigator.pushNamed(
  context,
  '/auth/email-confirmation-waiting',
  arguments: 'usuario@example.com',
);

// Ir a confirmación con token
Navigator.pushNamed(
  context,
  '/auth/confirm-email?token=abc123xyz',
);

// Ir a login (futura HU)
Navigator.pushNamed(context, '/auth/login');
```

---

## Notas Importantes

1. **GetIt debe estar inicializado** antes de usar las páginas (todas usan `sl<AuthBloc>()`)
2. **Theme.of(context)** funciona porque MaterialApp define el tema
3. **EmailConfirmationWaitingPage** recibe email desde `ModalRoute.of(context)?.settings.arguments`
4. **ConfirmEmailPage** recibe token desde constructor (extraído de query params)

---

✅ **Con esta configuración, todas las páginas de HU-001 funcionarán correctamente**
