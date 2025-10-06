# Integration Tests E2E - E003-HU-002

## Sistema de Navegacion con Menus Desplegables

Este directorio contiene los tests de integracion end-to-end (E2E) para validar el Sistema de Navegacion con Menus Desplegables.

### Archivo de Tests

- **navigation_menu_test.dart**: Suite completa de tests E2E que valida todos los Criterios de Aceptacion de la HU-002.

### Criterios de Aceptacion Cubiertos

#### CA-001: Sidebar con Menus segun Rol de Vendedor
- Valida que vendedores vean solo opciones permitidas
- Verifica que NO vean opciones de admin/gerente

#### CA-002: Sidebar con Menus segun Rol de Gerente
- Valida opciones adicionales para gerentes
- Verifica que NO vean opciones de admin

#### CA-003: Sidebar con Menus segun Rol de Admin
- Valida que admin vea TODAS las opciones del sistema

#### CA-004: Comportamiento de Menus Desplegables
- Valida expansion y colapso de menus al hacer clic
- Verifica rotacion de iconos de flecha

#### CA-005: Sidebar Colapsable
- Valida colapso de sidebar con boton hamburguesa
- Verifica tooltips en modo colapsado

#### CA-006: Header con Perfil de Usuario y Logout
- Valida visualizacion de elementos del usuario en header
- Verifica dropdown de perfil con opciones
- Valida modal de confirmacion de logout

#### CA-007: Indicador de Pagina Activa
- Valida resaltado visual de opcion activa en menu
- Verifica cambio de indicador al navegar

#### CA-008: Breadcrumbs de Navegacion
- Valida visualizacion de breadcrumbs en dashboard
- Verifica ruta completa en sub-paginas
- Valida navegacion al hacer clic en breadcrumbs

### Como Ejecutar los Tests

#### Ejecutar todos los tests E2E

```bash
flutter test integration_test/navigation_menu_test.dart
```

#### Ejecutar en un dispositivo especifico (Chrome)

```bash
flutter test integration_test/navigation_menu_test.dart -d chrome
```

#### Ejecutar con verbose output

```bash
flutter test integration_test/navigation_menu_test.dart --verbose
```

### Estructura del Test

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E003-HU-002: Sistema de Navegacion con Menus Desplegables', () {
    setUpAll(() async {
      await di.init(); // Inicializar Dependency Injection
    });

    group('CA-001: ...', () {
      testWidgets('Test case description', (tester) async {
        // Arrange: Configuracion inicial
        app.main();
        await tester.pumpAndSettle();

        // Act: Login como usuario especifico
        await _loginAsUser(tester, email: '...', password: '...');

        // Assert: Verificaciones
        expect(find.text('Dashboard'), findsOneWidget);
      });
    });

    // ... mas grupos de tests
  });
}
```

### Helper Functions

#### _loginAsUser()

Funcion auxiliar para hacer login con credenciales especificas:

```dart
await _loginAsUser(
  tester,
  email: 'vendedor@tienda1.com',
  password: 'password123',
);
```

### Usuarios de Prueba

Los tests utilizan las siguientes cuentas de usuario (deben existir en la BD de test):

- **Vendedor**: `vendedor@tienda1.com` / `password123`
- **Gerente**: `gerente@tienda1.com` / `password123`
- **Admin**: `admin@sistemasmedias.com` / `password123`

### Notas Importantes

1. **Prerequisitos**:
   - Backend de Supabase debe estar corriendo
   - Base de datos debe tener seed data con usuarios de prueba
   - Dependency Injection debe estar configurado

2. **Timeouts**:
   - Login: 5 segundos de timeout
   - Navegacion: pumpAndSettle() default

3. **Validaciones**:
   - Todos los tests validan presencia/ausencia de elementos UI
   - Se verifica seguridad de acceso por rol
   - Se valida comportamiento interactivo (clicks, hovers)

### Troubleshooting

#### Error: "Target of URI doesn't exist: integration_test"

Solucion: Agregar integration_test al pubspec.yaml

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

Luego ejecutar: `flutter pub get`

#### Error: "Login failed"

Verificar que:
- Backend de Supabase esta corriendo
- Usuarios de prueba existen en la BD
- Credenciales son correctas

#### Tests timeout

Aumentar timeout en casos especificos:

```dart
await tester.pumpAndSettle(const Duration(seconds: 10));
```

### Proximos Pasos

Una vez que el backend y frontend esten implementados:

1. Ejecutar suite completa de tests
2. Verificar que todos los CA pasen
3. Reportar resultados al arquitecto
4. Validar manualmente en localhost:8080

### Referencias

- Historia de Usuario: `docs/historias-usuario/E003-HU-002-navegacion-menus.md`
- Specs Tecnicas: `docs/technical/SPECS-FOR-AGENTS-E003-HU-002.md`
- Backend Schema: `docs/technical/backend/schema_E003-HU-002.md`
- Frontend Models: `docs/technical/frontend/models_E003-HU-002.md`
