# SPECS FOR AGENTS - E003-HU-002: Sistema de Navegación con Menús Desplegables

**Historia de Usuario**: E003-HU-002
**Épica**: E003 - Dashboard y Sistema de Navegación
**Fecha creación**: 2025-10-06
**Autor**: @web-architect-expert
**Estado**: 📋 Listo para Implementación

---

## 🎯 RESUMEN EJECUTIVO

Implementar un sistema de navegación completo con:
- Sidebar moderno con menús desplegables adaptados por rol de usuario
- Header con perfil de usuario y dropdown de logout
- Breadcrumbs dinámicos
- Sidebar colapsable con preferencia persistente

**Story Points**: 8 pts

---

## 📚 DOCUMENTACIÓN TÉCNICA

### Documentos Obligatorios a Leer:

1. **Convenciones**: [00-CONVENTIONS.md](00-CONVENTIONS.md)
2. **Historia de Usuario**: [E003-HU-002-navegacion-menus.md](../historias-usuario/E003-HU-002-navegacion-menus.md)
3. **Design Tokens**: [design/tokens.md](design/tokens.md)
4. **Backend**:
   - Schema: [backend/schema_E003-HU-002.md](backend/schema_E003-HU-002.md)
   - APIs: [backend/apis_E003-HU-002.md](backend/apis_E003-HU-002.md)
5. **Frontend**:
   - Models: [frontend/models_E003-HU-002.md](frontend/models_E003-HU-002.md)
6. **Design System**: [design/components_E003-HU-002.md](design/components_E003-HU-002.md)
7. **Mapping**: [integration/mapping_E003-HU-002.md](integration/mapping_E003-HU-002.md)

---

## 👥 TAREAS POR AGENTE

### @supabase-expert - Backend Implementation

#### Responsabilidades:

1. **Crear Schema de Base de Datos**
   - [ ] Tabla `menu_options` (maestro de opciones de menú)
   - [ ] Tabla `menu_permissions` (permisos por rol)
   - [ ] Agregar columna `sidebar_collapsed` a tabla `users`

2. **Implementar Funciones PostgreSQL**
   - [ ] `get_menu_options(p_user_id UUID)` - Devuelve menú jerárquico según rol
   - [ ] `update_sidebar_preference(p_user_id UUID, p_collapsed BOOLEAN)` - Guarda preferencia
   - [ ] `get_user_profile(p_user_id UUID)` - Obtiene datos del usuario para header

3. **Configurar Row Level Security (RLS)**
   - [ ] Policies de lectura para `menu_options` y `menu_permissions`
   - [ ] Policies de modificación solo para ADMIN

4. **Aplicar Seed Data**
   - [ ] Insertar menús base según roles (VENDEDOR, GERENTE, ADMIN)
   - [ ] Configurar permisos iniciales en `menu_permissions`

#### Archivos a Crear:

```
supabase/migrations/
└── 20250106XXXXXX_hu002_navigation_menus.sql

supabase/seed/
└── seed_menu_options.sql
```

#### Validaciones Requeridas:

```sql
-- Test 1: Menú de Vendedor
SELECT get_menu_options('uuid-vendedor-test');
-- Debe devolver: Dashboard, POS, Productos (solo catálogo), Clientes, etc.

-- Test 2: Menú de Gerente
SELECT get_menu_options('uuid-gerente-test');
-- Debe devolver: Menú de vendedor + Personas (clientes/proveedores)

-- Test 3: Menú de Admin
SELECT get_menu_options('uuid-admin-test');
-- Debe devolver: Menú completo con todas las opciones

-- Test 4: Actualizar preferencia
SELECT update_sidebar_preference('uuid-test', true);
-- Debe actualizar sidebar_collapsed = true

-- Test 5: Verificar RLS
SET ROLE authenticated;
SELECT * FROM menu_options; -- Debe devolver solo opciones activas
```

#### Documentos de Referencia:
- [backend/schema_E003-HU-002.md](backend/schema_E003-HU-002.md)
- [backend/apis_E003-HU-002.md](backend/apis_E003-HU-002.md)

---

### @flutter-expert - Clean Architecture Implementation

#### Responsabilidades:

1. **Data Layer**
   - [ ] `MenuOptionModel` con `fromJson`, `toJson`, `hasChildren`
   - [ ] `MenuResponseModel` para respuesta completa
   - [ ] `UserProfileModel` con mapping snake_case ↔ camelCase
   - [ ] `MenuRemoteDatasource` consumiendo APIs de Supabase
   - [ ] `MenuRepositoryImpl` implementando contrato del dominio

2. **Domain Layer**
   - [ ] `MenuOption` entity
   - [ ] `UserProfile` entity
   - [ ] `Breadcrumb` entity
   - [ ] `MenuRepository` interface
   - [ ] `GetMenuOptions` use case
   - [ ] `UpdateSidebarPreference` use case
   - [ ] `GetUserProfile` use case

3. **Presentation Layer**
   - [ ] `MenuBloc` (eventos: LoadMenu, ToggleSidebar, UpdatePreference)
   - [ ] `MenuState` (estados: MenuInitial, MenuLoading, MenuLoaded, MenuError)
   - [ ] Integración con `AuthBloc` para obtener `userId`

4. **Routing**
   - [ ] Configurar rutas en `AppRouter` (GoRouter)
   - [ ] Implementar detección de ruta activa para indicador visual
   - [ ] Generar breadcrumbs desde ruta actual

#### Estructura de Archivos:

```
lib/features/menu/
├── data/
│   ├── datasources/
│   │   └── menu_remote_datasource.dart
│   ├── models/
│   │   ├── menu_option_model.dart
│   │   └── menu_response_model.dart
│   └── repositories/
│       └── menu_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── menu_option.dart
│   │   └── breadcrumb.dart
│   ├── repositories/
│   │   └── menu_repository.dart
│   └── usecases/
│       ├── get_menu_options.dart
│       └── update_sidebar_preference.dart
└── presentation/
    └── bloc/
        ├── menu_bloc.dart
        ├── menu_event.dart
        └── menu_state.dart

lib/features/user/
├── data/
│   └── models/
│       └── user_profile_model.dart
└── domain/
    └── entities/
        └── user_profile.dart
```

#### Tests Requeridos:

```dart
test/features/menu/data/models/
├── menu_option_model_test.dart
├── menu_response_model_test.dart
└── user_profile_model_test.dart

test/features/menu/domain/usecases/
├── get_menu_options_test.dart
└── update_sidebar_preference_test.dart

test/features/menu/presentation/bloc/
└── menu_bloc_test.dart
```

#### Casos de Prueba Críticos:

1. **MenuOptionModel.fromJson()** con `children` anidados
2. **UserProfileModel** mapping `nombre_completo` → `nombreCompleto`
3. **MenuBloc** carga menú correctamente
4. **MenuBloc** actualiza preferencia de sidebar
5. **MenuBloc** maneja errores de red

#### Documentos de Referencia:
- [frontend/models_E003-HU-002.md](frontend/models_E003-HU-002.md)
- [integration/mapping_E003-HU-002.md](integration/mapping_E003-HU-002.md)
- [00-CONVENTIONS.md](00-CONVENTIONS.md)

---

### @ux-ui-expert - UI Components Implementation

#### Responsabilidades:

1. **Organisms (Componentes Complejos)**
   - [ ] `AppSidebar` con animaciones de expansión/colapso
   - [ ] `AppHeader` con dropdown de perfil de usuario
   - [ ] `MainLayout` integrando Sidebar + Header + Content

2. **Molecules (Componentes Medios)**
   - [ ] `BreadcrumbsWidget` con separadores y navegación
   - [ ] `SidebarMenuItem` con indicador de activo
   - [ ] `UserProfileDropdown` con opciones (perfil, configuración, logout)

3. **Widgets Específicos**
   - [ ] `LogoutConfirmationDialog` modal de confirmación
   - [ ] `SidebarToggleButton` botón hamburguesa
   - [ ] `MenuItemTooltip` tooltip para sidebar colapsado

4. **Animaciones y Transiciones**
   - [ ] Expansión/colapso sidebar: `Duration(milliseconds: 300)`
   - [ ] Hover en ítems de menú: `Duration(milliseconds: 200)`
   - [ ] Rotación de ícono de flecha en menús desplegables
   - [ ] Transición de color en indicador de página activa

5. **Responsive Design**
   - [ ] Desktop (≥1200px): Sidebar fijo expandido/colapsado
   - [ ] Tablet (768-1199px): Sidebar colapsado por defecto
   - [ ] Mobile (<768px): Drawer (hamburguesa)

#### Estructura de Archivos:

```
lib/shared/design_system/
├── organisms/
│   ├── app_sidebar.dart
│   ├── app_header.dart
│   └── main_layout.dart
├── molecules/
│   ├── breadcrumbs_widget.dart
│   ├── sidebar_menu_item.dart
│   └── user_profile_dropdown.dart
└── atoms/
    └── menu_item_tooltip.dart

lib/features/auth/presentation/widgets/
└── logout_confirmation_dialog.dart
```

#### Design Specs:

**Colores**:
- Primary: `#4ECDC4` (turquesa)
- Primary Dark: `#26A69A`
- Text Primary: `#1A1A1A`
- Text Secondary: `#6B7280`
- Background Light: `#F9FAFB`

**Sidebar**:
- Expandido: 280px
- Colapsado: 80px
- Header: 64px altura
- Menú ítem: 48px altura
- Sub-menú ítem: 40px altura
- Indentación sub-menú: 24px

**Header**:
- Altura: 64px
- Padding horizontal: 24px
- Avatar: 40px diámetro
- Badge rol: 8px padding horizontal, 2px vertical

**Breadcrumbs**:
- Separador: `Icons.chevron_right` 16px
- Espaciado entre ítems: 8px

#### Tests de UI:

```dart
testWidgets('AppSidebar should expand and collapse', (tester) async {
  // Test expansión/colapso
});

testWidgets('AppSidebar should highlight active menu item', (tester) async {
  // Test indicador de página activa
});

testWidgets('AppHeader should show user profile correctly', (tester) async {
  // Test avatar, nombre, rol
});

testWidgets('BreadcrumbsWidget should navigate on tap', (tester) async {
  // Test navegación al hacer clic
});

testWidgets('LogoutConfirmationDialog should show confirmation', (tester) async {
  // Test modal de confirmación
});
```

#### Documentos de Referencia:
- [design/components_E003-HU-002.md](design/components_E003-HU-002.md)
- [design/tokens.md](design/tokens.md)
- [00-CONVENTIONS.md](00-CONVENTIONS.md)

---

### @qa-testing-expert - QA & Integration Testing

#### Responsabilidades:

1. **Validación de Criterios de Aceptación**
   - [ ] **CA-001**: Sidebar con menús según rol de Vendedor
   - [ ] **CA-002**: Sidebar con menús según rol de Gerente
   - [ ] **CA-003**: Sidebar con menús según rol de Admin
   - [ ] **CA-004**: Comportamiento de menús desplegables (expandir/colapsar)
   - [ ] **CA-005**: Sidebar colapsable con tooltips
   - [ ] **CA-006**: Header con perfil de usuario y logout
   - [ ] **CA-007**: Indicador de página activa
   - [ ] **CA-008**: Breadcrumbs de navegación

2. **Integration Tests**
   - [ ] Test E2E: Login → Cargar menú → Navegar a página → Verificar breadcrumbs
   - [ ] Test E2E: Colapsar sidebar → Verificar persistencia → Recargar página
   - [ ] Test E2E: Logout con confirmación → Redirigir a login
   - [ ] Test E2E: Cambio de rol → Verificar menú actualizado

3. **Tests de Seguridad**
   - [ ] Vendedor NO puede ver opciones de Admin
   - [ ] Gerente NO puede ver opciones de Admin
   - [ ] URLs protegidas rechazan acceso no autorizado

4. **Tests de Performance**
   - [ ] Menú carga en <500ms
   - [ ] Animaciones fluidas (60fps)
   - [ ] Sin memory leaks en navegación

#### Test Cases:

```dart
// integration_test/navigation_menu_test.dart

testWidgets('CA-001: Vendedor should see only allowed menu options', (tester) async {
  // 1. Login como vendedor
  // 2. Verificar que sidebar muestra: Dashboard, POS, Productos (solo catálogo), Clientes, Reportes
  // 3. Verificar que NO muestra: Personas, Admin
});

testWidgets('CA-004: Expandable menu should toggle children', (tester) async {
  // 1. Login como admin
  // 2. Hacer clic en "Productos" (tiene children)
  // 3. Verificar que se expanden sub-opciones
  // 4. Verificar que ícono rotó
  // 5. Hacer clic nuevamente
  // 6. Verificar que se colapsaron sub-opciones
});

testWidgets('CA-005: Collapsed sidebar should show tooltips', (tester) async {
  // 1. Colapsar sidebar
  // 2. Hacer hover en ícono de menú
  // 3. Verificar que aparece tooltip con label
});

testWidgets('CA-006: Logout should show confirmation dialog', (tester) async {
  // 1. Hacer clic en avatar de usuario
  // 2. Hacer clic en "Cerrar sesión"
  // 3. Verificar que aparece modal de confirmación
  // 4. Hacer clic en "Cerrar sesión"
  // 5. Verificar redirección a /login
});

testWidgets('CA-007: Active menu item should be highlighted', (tester) async {
  // 1. Navegar a /dashboard
  // 2. Verificar que "Dashboard" tiene background turquesa
  // 3. Verificar que tiene border-left de 4px
  // 4. Navegar a /products
  // 5. Verificar que "Productos > Gestionar catálogo" está activo
});

testWidgets('CA-008: Breadcrumbs should update on navigation', (tester) async {
  // 1. Navegar a /dashboard
  // 2. Verificar breadcrumbs: "Dashboard"
  // 3. Navegar a /products
  // 4. Verificar breadcrumbs: "Productos > Gestionar catálogo"
  // 5. Hacer clic en "Productos" en breadcrumbs
  // 6. Verificar navegación a /products
});
```

#### Documentos de Referencia:
- [../historias-usuario/E003-HU-002-navegacion-menus.md](../historias-usuario/E003-HU-002-navegacion-menus.md)
- Todos los archivos técnicos

---

## 🔄 FLUJO DE IMPLEMENTACIÓN (PARALELO)

### Fase 1: Implementación Base (Paralelo)

**@supabase-expert** (2-3 horas):
1. Crear schema de tablas
2. Implementar funciones PostgreSQL
3. Aplicar seed data

**@flutter-expert** (3-4 horas):
1. Crear models (Data Layer)
2. Crear entities (Domain Layer)
3. Crear repositories y datasources
4. Implementar MenuBloc

**@ux-ui-expert** (3-4 horas):
1. Crear AppSidebar
2. Crear AppHeader
3. Crear BreadcrumbsWidget
4. Crear MainLayout

### Fase 2: Integración (Secuencial)

**@flutter-expert** (1-2 horas):
1. Integrar MenuBloc con AppSidebar
2. Integrar AuthBloc con AppHeader
3. Configurar rutas y navegación
4. Implementar generación de breadcrumbs

**@ux-ui-expert** (1 hora):
1. Ajustar animaciones
2. Validar responsive design

### Fase 3: Testing & Validación (Paralelo)

**@flutter-expert** (1 hora):
- Unit tests de models, use cases, bloc

**@ux-ui-expert** (1 hora):
- Widget tests de componentes

**@qa-testing-expert** (2-3 horas):
- Integration tests E2E
- Validación de todos los CA

---

## 📋 DEFINITION OF DONE (DoD)

- [ ] **Backend**:
  - [ ] Tablas creadas y migradas
  - [ ] Funciones PostgreSQL implementadas y testeadas
  - [ ] RLS configurado
  - [ ] Seed data aplicado

- [ ] **Frontend**:
  - [ ] Models con mapping correcto
  - [ ] Entities del dominio
  - [ ] Repositories y datasources
  - [ ] MenuBloc funcionando
  - [ ] Unit tests con >85% coverage

- [ ] **UI/UX**:
  - [ ] Componentes siguiendo Design System
  - [ ] Animaciones fluidas
  - [ ] Responsive design
  - [ ] Widget tests

- [ ] **QA**:
  - [ ] Todos los CA validados
  - [ ] Integration tests pasando
  - [ ] No memory leaks
  - [ ] Performance aceptable (<500ms carga)

- [ ] **Documentación**:
  - [ ] Código comentado
  - [ ] README actualizado
  - [ ] Diagramas de flujo (si aplica)

---

## 🚨 REGLAS CRÍTICAS

1. **NUNCA hardcodear colores** → Usar `Theme.of(context)` o `DesignColors.*`
2. **SIEMPRE mapear snake_case ↔ camelCase** correctamente
3. **VALIDAR permisos en backend** → Frontend solo muestra lo que backend permite
4. **ANIMACIONES suaves** → 200ms (hover), 300ms (transiciones)
5. **RESPONSIVE obligatorio** → Desktop, Tablet, Mobile
6. **TESTS obligatorios** → Unit, Widget, Integration

---

## 📞 COMUNICACIÓN ENTRE AGENTES

### @supabase-expert → @flutter-expert:
- ✅ Notificar cuando funciones PostgreSQL estén listas
- ✅ Proveer ejemplos de JSON de respuesta
- ✅ Informar si hay cambios en schema

### @flutter-expert → @ux-ui-expert:
- ✅ Notificar cuando Bloc esté listo
- ✅ Proveer entities y states para UI
- ✅ Coordinar estructura de componentes

### @ux-ui-expert → @qa-testing-expert:
- ✅ Notificar cuando componentes estén listos
- ✅ Proveer guía de navegación manual
- ✅ Informar de cambios en UI

---

## 📊 MÉTRICAS DE ÉXITO

- **Backend**: Funciones devuelven JSON correcto en <100ms
- **Frontend**: Menú carga en <500ms
- **UI**: Animaciones a 60fps
- **Tests**: Coverage >85% (models, use cases, widgets)
- **QA**: Todos los CA (8/8) pasando

---

**Fecha de inicio esperada**: 2025-10-06
**Fecha de entrega esperada**: 2025-10-08 (2 días)

---

**Última actualización**: 2025-10-06
**Mantenido por**: @web-architect-expert