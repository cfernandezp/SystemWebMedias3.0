# Modelos Frontend - E003-HU-002: Sistema de Navegación con Menús Desplegables

**Historia de Usuario**: E003-HU-002
**Fecha creación**: 2025-10-06
**Autor**: @web-architect-expert
**Última actualización**: 2025-10-06 (Implementación completada por @flutter-expert)
**Estado**: ✅ IMPLEMENTADO

---

## 🎯 OBJETIVO

Documentar los modelos Dart (Data Layer) necesarios para el sistema de navegación con menús dinámicos.

---

## 📦 MODELOS (Data Layer)

### 1. `MenuOptionModel` - Opción de Menú

**Ubicación**: `lib/features/menu/data/models/menu_option_model.dart`

```dart
import 'package:equatable/equatable.dart';

class MenuOptionModel extends Equatable {
  final String id;
  final String label;
  final String? icon;
  final String? route;
  final List<MenuOptionModel>? children;

  const MenuOptionModel({
    required this.id,
    required this.label,
    this.icon,
    this.route,
    this.children,
  });

  /// Factory: Desde JSON del backend
  factory MenuOptionModel.fromJson(Map<String, dynamic> json) {
    return MenuOptionModel(
      id: json['id'] as String,
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

  /// Convertir a JSON (para almacenamiento local si es necesario)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': icon,
      'route': route,
      'children': children?.map((child) => child.toJson()).toList(),
    };
  }

  /// Helper: Verificar si tiene sub-menús
  bool get hasChildren => children != null && children!.isNotEmpty;

  @override
  List<Object?> get props => [id, label, icon, route, children];
}
```

**Validaciones**:
- ✅ `id` es obligatorio
- ✅ `label` es obligatorio
- ✅ `icon` es opcional (puede ser null para sub-menús)
- ✅ `route` es obligatorio si no tiene `children`, opcional si tiene `children`
- ✅ `children` es opcional (null para opciones sin sub-menús)

**Ejemplo de JSON**:
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

---

### 2. `MenuResponseModel` - Respuesta Completa de Menú

**Ubicación**: `lib/features/menu/data/models/menu_response_model.dart`

```dart
import 'package:equatable/equatable.dart';
import 'menu_option_model.dart';

class MenuResponseModel extends Equatable {
  final String role;
  final List<MenuOptionModel> menu;

  const MenuResponseModel({
    required this.role,
    required this.menu,
  });

  /// Factory: Desde JSON del backend
  factory MenuResponseModel.fromJson(Map<String, dynamic> json) {
    return MenuResponseModel(
      role: json['role'] as String,
      menu: (json['menu'] as List)
          .map((item) => MenuOptionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'menu': menu.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [role, menu];
}
```

**Ejemplo de JSON completo del backend**:
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

---

### 3. `UserProfileModel` - Perfil de Usuario (para Header)

**Ubicación**: `lib/features/user/data/models/user_profile_model.dart`

```dart
import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final String id;
  final String nombreCompleto;
  final String email;
  final String rol;
  final String? avatarUrl;
  final bool sidebarCollapsed;

  const UserProfileModel({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.rol,
    this.avatarUrl,
    required this.sidebarCollapsed,
  });

  /// Factory: Desde JSON del backend
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      nombreCompleto: json['nombre_completo'] as String,  // ← snake_case → camelCase
      email: json['email'] as String,
      rol: json['rol'] as String,
      avatarUrl: json['avatar_url'] as String?,
      sidebarCollapsed: json['sidebar_collapsed'] as bool,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_completo': nombreCompleto,  // ← camelCase → snake_case
      'email': email,
      'rol': rol,
      'avatar_url': avatarUrl,
      'sidebar_collapsed': sidebarCollapsed,
    };
  }

  /// Helper: Obtener inicial del nombre
  String get initials {
    final parts = nombreCompleto.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombreCompleto[0].toUpperCase();
  }

  /// Helper: Obtener badge de rol con estilo
  String get roleBadge {
    switch (rol) {
      case 'ADMIN':
        return 'Administrador';
      case 'GERENTE':
        return 'Gerente';
      case 'VENDEDOR':
        return 'Vendedor';
      default:
        return rol;
    }
  }

  /// CopyWith para actualizar sidebar_collapsed
  UserProfileModel copyWith({
    String? id,
    String? nombreCompleto,
    String? email,
    String? rol,
    String? avatarUrl,
    bool? sidebarCollapsed,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
    );
  }

  @override
  List<Object?> get props => [id, nombreCompleto, email, rol, avatarUrl, sidebarCollapsed];
}
```

**Mapping BD ↔ Dart**:
- `nombre_completo` → `nombreCompleto`
- `avatar_url` → `avatarUrl`
- `sidebar_collapsed` → `sidebarCollapsed`

---

### 4. `BreadcrumbModel` - Migas de Pan

**Ubicación**: `lib/features/navigation/data/models/breadcrumb_model.dart`

```dart
import 'package:equatable/equatable.dart';

class BreadcrumbModel extends Equatable {
  final String label;
  final String? route;

  const BreadcrumbModel({
    required this.label,
    this.route,
  });

  /// Factory: Desde Map
  factory BreadcrumbModel.fromMap(Map<String, String?> map) {
    return BreadcrumbModel(
      label: map['label']!,
      route: map['route'],
    );
  }

  /// Helper: Verificar si es clickeable
  bool get isClickable => route != null;

  @override
  List<Object?> get props => [label, route];
}
```

**Ejemplo de uso**:
```dart
final breadcrumbs = [
  BreadcrumbModel(label: 'Dashboard', route: '/dashboard'),
  BreadcrumbModel(label: 'Productos', route: '/products'),
  BreadcrumbModel(label: 'Gestionar catálogo', route: null), // No clickeable (página actual)
];
```

---

## 🏛️ ENTIDADES (Domain Layer)

### 1. `MenuOption` - Entidad de Opción de Menú

**Ubicación**: `lib/features/menu/domain/entities/menu_option.dart`

```dart
import 'package:equatable/equatable.dart';

class MenuOption extends Equatable {
  final String id;
  final String label;
  final String? icon;
  final String? route;
  final List<MenuOption>? children;

  const MenuOption({
    required this.id,
    required this.label,
    this.icon,
    this.route,
    this.children,
  });

  bool get hasChildren => children != null && children!.isNotEmpty;

  @override
  List<Object?> get props => [id, label, icon, route, children];
}
```

**Conversión Model → Entity**:
```dart
// En MenuRepository implementation
MenuOption toEntity(MenuOptionModel model) {
  return MenuOption(
    id: model.id,
    label: model.label,
    icon: model.icon,
    route: model.route,
    children: model.children?.map((child) => toEntity(child)).toList(),
  );
}
```

---

### 2. `UserProfile` - Entidad de Perfil de Usuario

**Ubicación**: `lib/features/user/domain/entities/user_profile.dart`

```dart
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String nombreCompleto;
  final String email;
  final String rol;
  final String? avatarUrl;
  final bool sidebarCollapsed;

  const UserProfile({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.rol,
    this.avatarUrl,
    required this.sidebarCollapsed,
  });

  String get initials {
    final parts = nombreCompleto.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombreCompleto[0].toUpperCase();
  }

  String get roleBadge {
    switch (rol) {
      case 'ADMIN':
        return 'Administrador';
      case 'GERENTE':
        return 'Gerente';
      case 'VENDEDOR':
        return 'Vendedor';
      default:
        return rol;
    }
  }

  @override
  List<Object?> get props => [id, nombreCompleto, email, rol, avatarUrl, sidebarCollapsed];
}
```

---

### 3. `Breadcrumb` - Entidad de Miga de Pan

**Ubicación**: `lib/features/navigation/domain/entities/breadcrumb.dart`

```dart
import 'package:equatable/equatable.dart';

class Breadcrumb extends Equatable {
  final String label;
  final String? route;

  const Breadcrumb({
    required this.label,
    this.route,
  });

  bool get isClickable => route != null;

  @override
  List<Object?> get props => [label, route];
}
```

---

## 📋 CHECKLIST DE IMPLEMENTACIÓN PARA @flutter-expert

### Data Layer (Models):
- [ ] `MenuOptionModel` con `fromJson`, `toJson`, `hasChildren`
- [ ] `MenuResponseModel` con `fromJson`, `toJson`
- [ ] `UserProfileModel` con mapping snake_case ↔ camelCase
- [ ] `BreadcrumbModel` con `isClickable`

### Domain Layer (Entities):
- [ ] `MenuOption` entity
- [ ] `UserProfile` entity
- [ ] `Breadcrumb` entity

### Mappers:
- [ ] `MenuOptionModel.toEntity()` en Repository
- [ ] `UserProfileModel.toEntity()` en Repository

### Tests:
- [ ] Unit tests para `MenuOptionModel.fromJson()`
- [ ] Unit tests para `MenuResponseModel.fromJson()`
- [ ] Unit tests para `UserProfileModel` mapping
- [ ] Unit tests para helpers (`initials`, `roleBadge`, `hasChildren`, `isClickable`)

---

## 📝 NOTAS IMPORTANTES

### Mapping BD ↔ Dart:

| Campo BD | Modelo Dart |
|----------|-------------|
| `nombre_completo` | `nombreCompleto` |
| `avatar_url` | `avatarUrl` |
| `sidebar_collapsed` | `sidebarCollapsed` |

### Validaciones en Models:

- ✅ Todos los campos obligatorios deben lanzar excepción si son `null` en JSON
- ✅ Campos opcionales deben manejar `null` correctamente
- ✅ Listas deben devolver lista vacía en lugar de `null` (si aplica)

### Ejemplos de JSON completo:

**get_menu_options response**:
```json
{
  "success": true,
  "data": {
    "role": "VENDEDOR",
    "menu": [...]
  }
}
```

**get_user_profile response**:
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

---

**Próximos pasos**: Documentar componentes UI en `components_E003-HU-002.md`