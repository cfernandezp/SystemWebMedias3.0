# Convenciones de Routing - Flutter Web

**Fecha**: 2025-10-04
**Propósito**: Definir estructura estándar de rutas para evitar inconsistencias

---

## 📋 PROBLEMA IDENTIFICADO

Durante la implementación de HU-001 se encontró **inconsistencia entre documentación y código**:

- **Documentación** (SPECS-FOR-AGENTS-HU001.md:270): Rutas sin prefijo `/auth`
- **Código** (register_form.dart:66): Navega a `/auth/email-confirmation-waiting`
- **Resultado**: Error `Could not find a generator for route`

**Causa raíz**: Falta de convención clara y documentada sobre estructura de rutas.

---

## ✅ CONVENCIÓN OFICIAL - RUTAS FLAT (SIN PREFIJOS)

Para **simplicidad y compatibilidad con named routes de Flutter**, usaremos **rutas FLAT sin prefijos de módulo**:

### ❌ INCORRECTO (NO usar):
```dart
routes: {
  '/auth/register': (context) => RegisterPage(),
  '/auth/login': (context) => LoginPage(),
  '/products/list': (context) => ProductsListPage(),
}
```

### ✅ CORRECTO (Usar):
```dart
routes: {
  '/register': (context) => RegisterPage(),
  '/login': (context) => LoginPage(),
  '/email-confirmation-waiting': (context) => EmailConfirmationWaitingPage(),
  '/confirm-email': (context) => ConfirmEmailPage(),
  '/products': (context) => ProductsListPage(),
  '/product-detail': (context) => ProductDetailPage(),
}
```

---

## 📐 ESTRUCTURA DE RUTAS POR MÓDULO

### **Auth (Autenticación)**
```dart
'/': RegisterPage()                          // Página inicial (por ahora registro)
'/login': LoginPage()                        // Login
'/register': RegisterPage()                  // Registro
'/email-confirmation-waiting': EmailConfirmationWaitingPage()
'/confirm-email': ConfirmEmailPage()         // Confirmación de email (query: token)
'/forgot-password': ForgotPasswordPage()     // Recuperar contraseña
'/reset-password': ResetPasswordPage()       // Resetear contraseña (query: token)
```

### **Dashboard**
```dart
'/dashboard': DashboardPage()                // Dashboard principal
```

### **Products (Gestión de Productos)**
```dart
'/products': ProductsListPage()              // Lista de productos
'/product-detail': ProductDetailPage()       // Detalle (args: productId)
'/product-create': ProductCreatePage()       // Crear producto
'/product-edit': ProductEditPage()           // Editar producto (args: productId)
'/brands': BrandsPage()                      // Gestión de marcas
'/materials': MaterialsPage()                // Gestión de materiales
'/product-types': ProductTypesPage()         // Gestión de tipos de producto
'/size-systems': SizeSystemsPage()           // Gestión de sistemas de tallas
```

### **Sales (Ventas)**
```dart
'/sales': SalesListPage()                    // Lista de ventas
'/sale-detail': SaleDetailPage()             // Detalle venta (args: saleId)
'/pos': PointOfSalePage()                    // Punto de venta
```

### **Inventory**
```dart
'/inventory': InventoryPage()                // Gestión de inventario
'/inventory-entry': InventoryEntryPage()     // Ingreso de stock
'/inventory-adjustment': InventoryAdjustmentPage()
```

### **Commissions**
```dart
'/commissions': CommissionsPage()            // Seguimiento de comisiones
'/commission-detail': CommissionDetailPage() // Detalle (args: userId)
```

### **Users (Gestión de Usuarios - ADMIN)**
```dart
'/users': UsersListPage()                    // Lista de usuarios
'/user-detail': UserDetailPage()             // Detalle (args: userId)
'/user-approve': UserApprovePage()           // Aprobar usuarios pendientes
```

---

## 🔧 IMPLEMENTACIÓN EN main.dart

```dart
import 'package:flutter/material.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/auth/presentation/pages/register_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/login_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/confirm_email_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/email_confirmation_waiting_page.dart';
// ... otros imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestión de Medias',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4ECDC4),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/register', // O '/' si es la misma
      routes: {
        '/': (context) => const RegisterPage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/confirm-email': (context) => const ConfirmEmailPage(),
        '/email-confirmation-waiting': (context) => const EmailConfirmationWaitingPage(),
        // ... más rutas
      },
    );
  }
}
```

---

## 🎯 NAVEGACIÓN EN CÓDIGO

### ✅ CORRECTO:
```dart
// En register_form.dart
Navigator.pushNamed(context, '/email-confirmation-waiting', arguments: email);

// En email_confirmation_waiting.dart
Navigator.pushNamed(context, '/login');
```

### ❌ INCORRECTO:
```dart
// NO hacer esto:
Navigator.pushNamed(context, '/auth/email-confirmation-waiting');
```

---

## 📦 PASO DE ARGUMENTOS

### Opción 1: Query Parameters (para enlaces externos)
```dart
// Para confirm-email que recibe token de URL externa
class ConfirmEmailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    final token = uri.queryParameters['token'];
    // ...
  }
}

// URL: https://app.com/confirm-email?token=abc123
```

### Opción 2: Route Arguments (para navegación interna)
```dart
// Enviar
Navigator.pushNamed(
  context,
  '/product-detail',
  arguments: {'productId': '123', 'mode': 'view'},
);

// Recibir
final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
final productId = args['productId'];
```

---

## 🛡️ VALIDACIÓN Y TESTING

### Checklist antes de hacer PR:
- [ ] Todas las rutas están en `main.dart` sin prefijos de módulo
- [ ] Todas las navegaciones usan `Navigator.pushNamed()` con rutas flat
- [ ] Documentación actualizada en `SPECS-FOR-AGENTS-*.md`
- [ ] No hay rutas hardcodeadas con prefijos `/auth/`, `/products/`, etc.

### Testing de rutas:
```dart
// test/routing_test.dart
void main() {
  testWidgets('Todas las rutas deben ser navegables', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Navegar a cada ruta
    await tester.tap(find.text('Ir a Login'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    // ... más tests
  });
}
```

---

## 📚 ACTUALIZACIÓN DE DOCUMENTACIÓN

**Todos los agentes** deben actualizar sus specs cuando implementen páginas:

### SPECS-FOR-AGENTS-HU00X.md
```markdown
**Navegación** (configurar en MaterialApp):
routes: {
  '/register': (context) => RegisterPage(),
  '/login': (context) => LoginPage(),
  '/email-confirmation-waiting': (context) => EmailConfirmationWaitingPage(),
}
```

### components_huXXX.md
```markdown
## Navegación desde RegisterForm

dart
Navigator.pushNamed(context, '/email-confirmation-waiting', arguments: email);
```

---

## 🚨 REGLA DE ORO

> **NUNCA usar prefijos de módulo en rutas (`/auth/`, `/products/`, etc.)**
>
> **SIEMPRE usar rutas flat (`/login`, `/products`, `/dashboard`)**

---

## 📞 CONTACTO

**Dudas sobre routing**: Consultar este documento
**Propuestas de cambio**: Reportar a @web-architect-expert
**Conflictos de rutas**: Documentar en este archivo

---

**Última actualización**: 2025-10-04
**Autor**: @web-architect-expert
