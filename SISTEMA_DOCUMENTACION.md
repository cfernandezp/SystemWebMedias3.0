# Sistema de Venta de Medias - Documentación Técnica

## 1. ESTRUCTURA DE CARPETAS DEL PROYECTO

### Backend (Supabase Local)
```
supabase/
├── migrations/              # Migraciones SQL incrementales (snake_case)
│   └── YYYYMMDDHHMMSS_nombre_migracion.sql
├── functions/               # Edge Functions por módulo
│   ├── auth/               # Funciones de autenticación
│   ├── products/           # Funciones de productos
│   ├── sales/              # Funciones de ventas
│   ├── inventory/          # Funciones de inventario
│   ├── commissions/        # Funciones de comisiones
│   └── shared/             # Utilidades compartidas
├── seed/                   # Datos de prueba y configuración inicial
│   ├── 001_roles.sql
│   ├── 002_users_test.sql
│   └── 003_products_test.sql
└── policies/               # RLS Policies organizadas por tabla
    ├── users_policies.sql
    ├── products_policies.sql
    └── sales_policies.sql
```

### Frontend (Flutter Web - Clean Architecture)
```
lib/
├── core/                   # Funcionalidades core compartidas
│   ├── constants/         # Constantes de la app
│   ├── error/            # Manejo de errores
│   ├── network/          # Cliente HTTP, interceptores
│   ├── utils/            # Utilidades generales
│   └── injection/        # Inyección de dependencias
│
├── shared/                # Recursos compartidos entre features
│   ├── design_system/    # Design System del proyecto
│   │   ├── tokens/       # Design tokens (colores, spacing, typography)
│   │   ├── atoms/        # Componentes atómicos (Button, Input, etc)
│   │   ├── molecules/    # Componentes moleculares (Card, Form, etc)
│   │   └── organisms/    # Componentes organisms (Header, List, etc)
│   ├── widgets/          # Widgets compartidos
│   └── theme/            # Tema de la aplicación
│
└── features/             # Módulos por funcionalidad
    ├── auth/             # Autenticación y autorización
    │   ├── data/
    │   │   ├── datasources/    # Supabase datasource
    │   │   ├── models/         # Modelos de datos (camelCase)
    │   │   └── repositories/   # Implementación de repositorios
    │   ├── domain/
    │   │   ├── entities/       # Entidades del dominio
    │   │   ├── repositories/   # Interfaces de repositorios
    │   │   └── usecases/       # Casos de uso
    │   └── presentation/
    │       ├── bloc/           # Gestión de estado con Bloc
    │       ├── pages/          # Páginas de la app
    │       └── widgets/        # Widgets específicos del feature
    │
    ├── products/         # Gestión de productos (marcas, materiales, tipos, tallas)
    ├── sales/            # Proceso de ventas y punto de venta
    ├── inventory/        # Gestión de inventario y stock
    ├── commissions/      # Cálculo y seguimiento de comisiones
    └── users/            # Gestión de usuarios del sistema
```

## 2. DESIGN SYSTEM

### Design Tokens
```dart
// lib/shared/design_system/tokens/design_colors.dart
class DesignColors {
  // Colores principales
  static const primary = Color(0xFF2E7D32);      // Verde medias
  static const secondary = Color(0xFF1976D2);    // Azul
  static const accent = Color(0xFFFF9800);       // Naranja

  // Estados
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);

  // Neutrales
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

// lib/shared/design_system/tokens/design_spacing.dart
class DesignSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

// lib/shared/design_system/tokens/design_breakpoints.dart
class DesignBreakpoints {
  static const mobile = 480;
  static const tablet = 768;
  static const desktop = 1024;
  static const largeDesktop = 1440;
}
```

### Componentes Base
```
Atoms:
- PrimaryButton, SecondaryButton, TextButton
- TextField, PasswordField, SearchField
- Label, Badge, Chip
- Icon, Avatar
- Divider, Spacer

Molecules:
- ProductCard, SaleCard, UserCard
- FormField (label + input + error)
- SearchBar, FilterBar
- SnackBar, Dialog, BottomSheet

Organisms:
- ProductList, SalesList
- AppHeader, NavigationBar
- DataTable, PaginatedList
- FormContainer
```

## 3. SCHEMA DE BASE DE DATOS

_(Se completará con cada Historia de Usuario)_

### Convención: snake_case
```sql
-- Ejemplo:
CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_name TEXT NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## 4. MODELOS DART

_(Se completará con cada Historia de Usuario)_

### Convención: camelCase con mapping exacto
```dart
// Ejemplo:
class Product {
  final String productId;      // ← product_id
  final String productName;    // ← product_name
  final int stockQuantity;     // ← stock_quantity
  final DateTime createdAt;    // ← created_at

  // Constructor, fromJson, toJson con mapping
}
```

## 5. REGLAS DE NEGOCIO (RN)

### RN-002: LOGIN DE USUARIOS
**Contexto**: Usuario intenta iniciar sesión en el sistema
**Origen**: HU-002 - Login al Sistema

#### RN-002.1: Credenciales Válidas
**Restricción**: Solo usuarios con email y contraseña correctos pueden acceder
**Validación**: El sistema debe verificar que email existe y contraseña coincide
**Caso especial**: El mensaje de error NO debe indicar si el email existe o no (seguridad)
**Mensaje error**: "Email o contraseña incorrectos"

#### RN-002.2: Email Verificado Obligatorio
**Restricción**: Solo usuarios con email confirmado pueden hacer login
**Validación**: email_verificado debe ser true
**Mensaje error**: "Debes confirmar tu email antes de iniciar sesión"
**Acción adicional**: Mostrar opción "Reenviar email de confirmación"

#### RN-002.3: Usuario Aprobado
**Restricción**: Solo usuarios en estado APROBADO pueden acceder al sistema
**Validación**: estado = 'APROBADO'
**Caso especial**: Estados REGISTRADO, RECHAZADO, SUSPENDIDO no pueden acceder
**Mensaje error**: "No tienes acceso al sistema. Contacta al administrador"

#### RN-002.4: Sesión Persistente
**Regla**: Si usuario marca "Recordarme", la sesión debe mantenerse 30 días
**Regla**: Si usuario NO marca "Recordarme", la sesión dura 8 horas
**Validación**: Al reabrir aplicación, usuario debe seguir autenticado (si marcó "Recordarme")
**Restricción**: Sesión debe almacenarse de forma segura

#### RN-002.5: Token Expirado
**Regla**: Cuando token expira, usuario debe ser deslogueado automáticamente
**Validación**: Detectar token expirado al intentar acceder a página protegida
**Acción**: Redirigir a login
**Mensaje**: "Tu sesión ha expirado. Inicia sesión nuevamente"

#### RN-002.6: Protección Anti-Fuerza Bruta
**Restricción**: Máximo 5 intentos fallidos de login por email en 15 minutos
**Validación**: Sistema debe contar intentos fallidos por email
**Acción**: Después de 5 intentos, bloquear temporalmente (15 minutos)
**Mensaje**: "Demasiados intentos fallidos. Intenta nuevamente en 15 minutos"

#### RN-002.7: Validación de Campos
**Restricción**: Email y contraseña son obligatorios
**Validación email**: Debe tener formato válido (contener @ y dominio)
**Validación contraseña**: No puede estar vacía
**Mensajes**:
- "Email es requerido"
- "Contraseña es requerida"
- "Formato de email inválido"

#### RN-002.8: Redirección Post-Login
**Regla**: Tras login exitoso, usuario va a página principal (/home)
**Mensaje**: Mostrar "Bienvenido [nombre_completo]"
**Restricción**: Si usuario ya está autenticado y accede a /login, redirigir a /home

---

_(Se completará con cada Épica/Historia de Usuario desde docs/)_

## 6. CONVENCIONES DE NOMENCLATURA

### Base de Datos (Supabase - PostgreSQL)
- **Tablas**: snake_case plural (ej: `products`, `sales_details`)
- **Columnas**: snake_case (ej: `product_id`, `created_at`)
- **PKs**: `{tabla}_id` (ej: `product_id`, `user_id`)
- **FKs**: `{tabla_referenciada}_id` (ej: `brand_id`, `material_id`)
- **Timestamps**: `created_at`, `updated_at`, `deleted_at`

### Dart/Flutter
- **Clases**: PascalCase (ej: `Product`, `SaleDetail`)
- **Variables**: camelCase (ej: `productId`, `createdAt`)
- **Archivos**: snake_case (ej: `product_card.dart`, `sale_detail_model.dart`)
- **Componentes UI**: PascalCase (ej: `PrimaryButton`, `ProductCard`)
- **Constantes**: lowerCamelCase o UPPER_SNAKE_CASE según contexto

### Mapping BD ↔ Dart
```dart
// BD: product_id (snake_case) → Dart: productId (camelCase)
factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    productId: json['product_id'],
    productName: json['product_name'],
  );
}
```

## 7. CONFIGURACIÓN DEL ENTORNO

### Supabase Local
```bash
# Iniciar
npx supabase start

# URLs
API: http://localhost:54321
Studio: http://localhost:54323

# Crear migración
npx supabase migration new <nombre>

# Detener
npx supabase stop
```

### Flutter Web
```bash
# Ejecutar en modo desarrollo
flutter run -d web-server --web-port 8080

# Build para producción
flutter build web
```

## 8. FLUJOS UX

_(Se completará con cada Historia de Usuario)_

---

**Última actualización**: 2025-10-05
