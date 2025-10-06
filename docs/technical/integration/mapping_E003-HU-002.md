# Mapping BD ↔ Dart - E003-HU-002: Sistema de Navegación con Menús Desplegables

**Historia de Usuario**: E003-HU-002
**Fecha creación**: 2025-10-06
**Autor**: @web-architect-expert
**Estado**: 📋 Especificación Técnica

---

## 🎯 OBJETIVO

Documentar el mapping completo entre las tablas PostgreSQL y los modelos Dart para el sistema de navegación.

---

## 🔄 MAPPING: `menu_options` → `MenuOptionModel`

### Tabla PostgreSQL: `menu_options`

```sql
CREATE TABLE menu_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES menu_options(id),
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    icon TEXT,
    route TEXT,
    orden INTEGER NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Modelo Dart: `MenuOptionModel`

```dart
class MenuOptionModel {
  final String id;
  final String label;
  final String? icon;
  final String? route;
  final List<MenuOptionModel>? children;
}
```

### Mapping Detallado

| Campo BD | Tipo BD | Campo Dart | Tipo Dart | Transformación |
|----------|---------|------------|-----------|----------------|
| `id` | UUID | `id` | String | Directo (UUID → String) |
| `code` | TEXT | `id` | String | **Se usa `code` como `id` en Dart** |
| `label` | TEXT | `label` | String | Directo |
| `icon` | TEXT | `icon` | String? | Nullable |
| `route` | TEXT | `route` | String? | Nullable |
| N/A (join) | - | `children` | List<MenuOptionModel>? | **Construido con JOIN recursivo** |

**Notas Importantes**:
- ✅ El campo `code` de BD se mapea a `id` en Dart (más legible: "dashboard" vs UUID)
- ✅ El campo `parent_id` NO se expone en Dart, se usa solo para construir `children`
- ✅ Los campos `orden`, `activo`, `created_at`, `updated_at` NO se exponen en frontend (son internos)
- ✅ La lista `children` se construye mediante la query recursiva en `get_menu_options()`

### Ejemplo de JSON Recibido por Frontend

```json
{
  "success": true,
  "data": {
    "role": "VENDEDOR",
    "menu": [
      {
        "id": "dashboard",
        "label": "Dashboard",
        "icon": "dashboard",
        "route": "/dashboard",
        "children": null
      },
      {
        "id": "productos",
        "label": "Productos",
        "icon": "inventory",
        "route": null,
        "children": [
          {
            "id": "productos-catalogo",
            "label": "Gestionar catálogo",
            "icon": null,
            "route": "/products"
          }
        ]
      }
    ]
  }
}
```

### Código de Mapping en Dart

```dart
factory MenuOptionModel.fromJson(Map<String, dynamic> json) {
  return MenuOptionModel(
    id: json['id'] as String,                // code de BD
    label: json['label'] as String,
    icon: json['icon'] as String?,
    route: json['route'] as String?,
    children: json['children'] != null
        ? (json['children'] as List)
            .map((child) => MenuOptionModel.fromJson(child as Map<String, dynamic>))
            .toList()
        : null,
  );
}
```

---

## 🔄 MAPPING: `users` → `UserProfileModel`

### Tabla PostgreSQL: `users` (campos relevantes)

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_completo TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    rol user_role NOT NULL,
    avatar_url TEXT,
    sidebar_collapsed BOOLEAN NOT NULL DEFAULT false,
    estado user_estado NOT NULL DEFAULT 'REGISTRADO',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Modelo Dart: `UserProfileModel`

```dart
class UserProfileModel {
  final String id;
  final String nombreCompleto;
  final String email;
  final String rol;
  final String? avatarUrl;
  final bool sidebarCollapsed;
}
```

### Mapping Detallado

| Campo BD | Tipo BD | Campo Dart | Tipo Dart | Transformación |
|----------|---------|------------|-----------|----------------|
| `id` | UUID | `id` | String | UUID → String |
| `nombre_completo` | TEXT | `nombreCompleto` | String | **snake_case → camelCase** |
| `email` | TEXT | `email` | String | Directo |
| `rol` | user_role (ENUM) | `rol` | String | Enum → String |
| `avatar_url` | TEXT | `avatarUrl` | String? | **snake_case → camelCase**, Nullable |
| `sidebar_collapsed` | BOOLEAN | `sidebarCollapsed` | bool | **snake_case → camelCase** |

**Notas Importantes**:
- ✅ Todos los campos `snake_case` se convierten a `camelCase`
- ✅ El campo `estado` NO se expone (se valida en backend)
- ✅ Los campos `created_at`, `updated_at` NO se exponen

### Ejemplo de JSON Recibido por Frontend

```json
{
  "success": true,
  "data": {
    "id": "uuid-123",
    "nombre_completo": "Juan Pérez",
    "email": "juan@example.com",
    "rol": "VENDEDOR",
    "avatar_url": null,
    "sidebar_collapsed": false
  }
}
```

### Código de Mapping en Dart

```dart
factory UserProfileModel.fromJson(Map<String, dynamic> json) {
  return UserProfileModel(
    id: json['id'] as String,
    nombreCompleto: json['nombre_completo'] as String,  // ← snake_case → camelCase
    email: json['email'] as String,
    rol: json['rol'] as String,
    avatarUrl: json['avatar_url'] as String?,           // ← snake_case → camelCase
    sidebarCollapsed: json['sidebar_collapsed'] as bool, // ← snake_case → camelCase
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'nombre_completo': nombreCompleto,    // ← camelCase → snake_case
    'email': email,
    'rol': rol,
    'avatar_url': avatarUrl,              // ← camelCase → snake_case
    'sidebar_collapsed': sidebarCollapsed, // ← camelCase → snake_case
  };
}
```

---

## 🔄 MAPPING: `menu_permissions` → (No expuesto en frontend)

**Nota**: La tabla `menu_permissions` NO se expone directamente en frontend.

**Flujo**:
1. Frontend llama `get_menu_options(user_id)`
2. Backend consulta `menu_permissions` según rol del usuario
3. Backend devuelve solo las opciones permitidas
4. Frontend recibe JSON ya filtrado

**Ventajas**:
- ✅ Frontend NO necesita conocer lógica de permisos
- ✅ Cambios en permisos no afectan frontend
- ✅ Seguridad: Backend es la única fuente de verdad

---

## 📋 FLUJO COMPLETO DE DATOS

### Flujo 1: Cargar Menú al Login

```
┌─────────────┐       ┌──────────────────┐       ┌───────────────┐
│   Flutter   │──(1)─→│  Supabase RPC    │──(2)─→│  PostgreSQL   │
│  MenuBloc   │       │ get_menu_options │       │  Función SQL  │
└─────────────┘       └──────────────────┘       └───────────────┘
       ↑                                                  │
       │                                                  │
       │              ┌───────────────────────────────────┘
       │              │ (3) Ejecuta query recursiva:
       │              │     - Lee menu_options
       │              │     - Filtra por menu_permissions + rol
       │              │     - Construye árbol jerárquico
       │              ↓
       └───(4)────── JSON {success: true, data: {menu: [...]}}

(1) Frontend: menuRepository.getMenuOptions(userId)
(2) Supabase: supabase.rpc('get_menu_options', params: {p_user_id: userId})
(3) PostgreSQL: Función SQL construye menú según rol
(4) Frontend: MenuOptionModel.fromJson() mapea datos
```

### Flujo 2: Actualizar Preferencia de Sidebar

```
┌─────────────┐       ┌─────────────────────────┐       ┌───────────┐
│   Flutter   │──(1)─→│  Supabase RPC           │──(2)─→│   users   │
│  MenuBloc   │       │ update_sidebar_preference│       │  UPDATE   │
└─────────────┘       └─────────────────────────┘       └───────────┘
       ↑                                                       │
       │                                                       │
       └───(3)────────────────────────────────────────────────┘
                  {success: true, data: {sidebar_collapsed: true}}

(1) Frontend: menuRepository.updateSidebarPreference(userId, collapsed)
(2) PostgreSQL: UPDATE users SET sidebar_collapsed = p_collapsed WHERE id = p_user_id
(3) Frontend: Actualiza estado local (Bloc)
```

---

## 🔍 VALIDACIONES DE MAPPING

### Checklist de Validación:

- [ ] **Nombres de campos**: Todos los `snake_case` se convirtieron a `camelCase`
- [ ] **Tipos de datos**: UUID → String, BOOLEAN → bool, TEXT → String
- [ ] **Campos nullable**: Correctamente tipados con `?` en Dart
- [ ] **Listas**: `children` maneja `null` correctamente
- [ ] **Enums**: `user_role` se convierte a String en Dart
- [ ] **JSON parsing**: Todos los modelos tienen `fromJson` y `toJson`
- [ ] **Campos omitidos**: `created_at`, `updated_at`, `estado`, `activo` NO se exponen

---

## 📝 CASOS DE PRUEBA

### Test 1: Mapeo de Menú Simple (sin children)

**Input (JSON)**:
```json
{
  "id": "dashboard",
  "label": "Dashboard",
  "icon": "dashboard",
  "route": "/dashboard",
  "children": null
}
```

**Output (Dart)**:
```dart
MenuOptionModel(
  id: 'dashboard',
  label: 'Dashboard',
  icon: 'dashboard',
  route: '/dashboard',
  children: null,
)
```

### Test 2: Mapeo de Menú con Children

**Input (JSON)**:
```json
{
  "id": "productos",
  "label": "Productos",
  "icon": "inventory",
  "route": null,
  "children": [
    {
      "id": "productos-catalogo",
      "label": "Gestionar catálogo",
      "icon": null,
      "route": "/products"
    }
  ]
}
```

**Output (Dart)**:
```dart
MenuOptionModel(
  id: 'productos',
  label: 'Productos',
  icon: 'inventory',
  route: null,
  children: [
    MenuOptionModel(
      id: 'productos-catalogo',
      label: 'Gestionar catálogo',
      icon: null,
      route: '/products',
      children: null,
    ),
  ],
)
```

### Test 3: Mapeo de UserProfile

**Input (JSON)**:
```json
{
  "id": "uuid-123",
  "nombre_completo": "Juan Pérez",
  "email": "juan@example.com",
  "rol": "VENDEDOR",
  "avatar_url": null,
  "sidebar_collapsed": true
}
```

**Output (Dart)**:
```dart
UserProfileModel(
  id: 'uuid-123',
  nombreCompleto: 'Juan Pérez',
  email: 'juan@example.com',
  rol: 'VENDEDOR',
  avatarUrl: null,
  sidebarCollapsed: true,
)
```

---

## 🧪 TESTS REQUERIDOS PARA @flutter-expert

### Unit Tests - MenuOptionModel:

```dart
group('MenuOptionModel', () {
  test('should parse JSON with children correctly', () {
    final json = {
      'id': 'productos',
      'label': 'Productos',
      'icon': 'inventory',
      'route': null,
      'children': [
        {
          'id': 'productos-catalogo',
          'label': 'Gestionar catálogo',
          'icon': null,
          'route': '/products',
        },
      ],
    };

    final model = MenuOptionModel.fromJson(json);

    expect(model.id, 'productos');
    expect(model.hasChildren, true);
    expect(model.children!.length, 1);
    expect(model.children![0].id, 'productos-catalogo');
  });

  test('should handle null children correctly', () {
    final json = {
      'id': 'dashboard',
      'label': 'Dashboard',
      'icon': 'dashboard',
      'route': '/dashboard',
      'children': null,
    };

    final model = MenuOptionModel.fromJson(json);

    expect(model.hasChildren, false);
    expect(model.children, null);
  });
});
```

### Unit Tests - UserProfileModel:

```dart
group('UserProfileModel', () {
  test('should map snake_case to camelCase correctly', () {
    final json = {
      'id': 'uuid-123',
      'nombre_completo': 'Juan Pérez',
      'email': 'juan@example.com',
      'rol': 'VENDEDOR',
      'avatar_url': null,
      'sidebar_collapsed': true,
    };

    final model = UserProfileModel.fromJson(json);

    expect(model.nombreCompleto, 'Juan Pérez');
    expect(model.avatarUrl, null);
    expect(model.sidebarCollapsed, true);
  });

  test('should generate initials correctly', () {
    final model = UserProfileModel(
      id: 'uuid',
      nombreCompleto: 'Juan Pérez',
      email: 'juan@example.com',
      rol: 'VENDEDOR',
      avatarUrl: null,
      sidebarCollapsed: false,
    );

    expect(model.initials, 'JP');
  });
});
```

---

**Próximos pasos**: Crear `SPECS-FOR-AGENTS-E003-HU-002.md`