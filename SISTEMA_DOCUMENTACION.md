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

### RN-003: LAYOUT RESPONSIVO Y ADAPTABLE
**Contexto**: Usuario accede al sistema desde diferentes dispositivos (desktop, tablet, móvil)
**Origen**: E003-HU-003 - Layout Responsivo y Adaptable

#### RN-003.1: Breakpoints de Dispositivos
**Regla**: El sistema debe adaptarse según el ancho de pantalla del dispositivo
**Breakpoints definidos**:
- Móvil: < 768px
- Tablet: 768px - 1024px
- Desktop: > 1024px
**Restricción**: Ningún dispositivo debe mostrar scroll horizontal
**Validación**: Layout debe reorganizarse automáticamente al cambiar tamaño de pantalla

#### RN-003.2: Visibilidad de Sidebar
**Regla Desktop**: Sidebar visible y expandido por defecto (240px ancho)
**Regla Tablet**: Sidebar colapsado por defecto, solo íconos (64px ancho)
**Regla Móvil**: Sidebar oculto por defecto, aparece como overlay al solicitar
**Restricción Móvil**: Al abrir sidebar, debe mostrarse backdrop oscuro y cerrarse al hacer clic fuera
**Validación**: Usuario debe poder alternar estado de sidebar con botón hamburguesa en todos los dispositivos

#### RN-003.3: Distribución de Cards de Métricas
**Regla Desktop**: Mostrar 4 cards por fila
**Regla Tablet**: Mostrar 2 cards por fila
**Regla Móvil**: Mostrar 1 card por fila (ancho completo)
**Restricción**: Cards deben mantener proporción de altura consistente
**Validación**: Textos y números deben ser legibles sin truncarse

#### RN-003.4: Organización de Contenido Principal
**Regla Desktop**: Gráficos ocupan 2/3 del ancho, lista de transacciones 1/3
**Regla Tablet**: Gráficos ocupan ancho completo, lista de transacciones debajo
**Regla Móvil**: Todo apilado verticalmente (gráficos arriba, transacciones debajo)
**Validación**: Usuario debe poder ver todo el contenido mediante scroll vertical únicamente

#### RN-003.5: Elementos Touch-Friendly
**Restricción**: En dispositivos táctiles (tablet/móvil), área táctil mínima de 48x48px
**Regla**: Separación entre elementos interactivos de mínimo 8px
**Validación**: Botones, links y elementos clickeables deben ser fáciles de presionar sin errores
**Restricción**: Menús desplegables deben abrirse con tap, no con hover
**Caso especial**: Estados hover en desktop deben reemplazarse por estados active en touch

#### RN-003.6: Tamaño de Texto Legible
**Restricción Móvil**: Texto mínimo de 16px para evitar zoom automático del navegador
**Regla Desktop**: Texto puede ser más pequeño (mínimo 14px)
**Validación**: Usuario debe poder leer todo el texto sin necesidad de hacer zoom
**Restricción**: Números en métricas deben ser proporcionalmente más grandes que texto descriptivo

#### RN-003.7: Header Adaptable
**Regla Desktop**: Mostrar logo + título + breadcrumbs + avatar/nombre completo (altura 64px)
**Regla Tablet**: Mostrar menú hamburguesa + título + avatar (altura 64px)
**Regla Móvil**: Mostrar menú hamburguesa + logo pequeño + avatar (altura 56px)
**Restricción**: Header debe permanecer fijo en la parte superior al hacer scroll
**Validación**: Dropdown de perfil debe alinearse a la derecha en todos los dispositivos

#### RN-003.8: Gráficos Adaptables
**Regla**: Gráficos deben adaptarse al ancho del contenedor automáticamente
**Restricción Móvil**: Si hay muchos datos, mostrar scroll horizontal en el gráfico
**Regla de Leyendas**: Desktop muestra leyenda a la derecha, móvil muestra leyenda arriba
**Validación**: Ejes, labels y tooltips deben ser legibles en todos los tamaños
**Caso especial Touch**: Tooltips deben activarse con tap, no con hover

#### RN-003.9: Orientación de Dispositivo
**Regla Tablet Horizontal**: Comportarse similar a desktop pequeño
**Regla Móvil Horizontal**: Cards de métricas en 2 columnas en lugar de 1
**Validación**: Al rotar dispositivo, layout debe reorganizarse automáticamente
**Restricción**: Al cambiar orientación, mantener posición de scroll cuando sea posible

#### RN-003.10: Transiciones Suaves
**Regla**: Cambios de layout deben tener transición suave de 200-300ms
**Restricción**: Animaciones deben usar easing natural (ease-in-out)
**Validación**: No debe haber lag, flickering o saltos bruscos
**Caso especial Sidebar**: Debe animarse el cambio de ancho/posición al colapsar/expandir
**Caso especial Grid**: Reorganización de cards debe ser fluida y sin retrasos

---

### RN-003-LOGOUT: CIERRE DE SESIÓN SEGURO
**Contexto**: Usuario autenticado desea cerrar sesión o sistema detecta inactividad
**Origen**: E001-HU-003 - Logout Seguro

#### RN-003-LOGOUT.1: Confirmación de Logout Manual
**Regla**: Antes de cerrar sesión, sistema debe pedir confirmación al usuario
**Validación**: Usuario debe confirmar acción con modal "¿Estás seguro que quieres cerrar sesión?"
**Restricción**: Usuario puede cancelar acción y permanecer autenticado
**Mensaje confirmación**: Botones "Sí, cerrar sesión" y "Cancelar"

#### RN-003-LOGOUT.2: Limpieza Completa de Sesión
**Regla**: Al confirmar logout, eliminar todos los rastros de sesión del usuario
**Restricción**: Debe limpiar:
- Token de autenticación almacenado
- Datos de usuario en memoria
- Preferencias de sesión temporal
- Token de "Recordarme" (si existe)
**Validación**: Usuario NO puede acceder a contenido protegido después de logout

#### RN-003-LOGOUT.3: Invalidación de Token
**Regla**: Token JWT debe ser invalidado inmediatamente al hacer logout
**Restricción**: Token invalidado NO puede usarse para futuras peticiones
**Validación**: Intentar usar token después de logout debe retornar error de autenticación
**Caso especial**: Si logout falla en servidor, aún así limpiar sesión local

#### RN-003-LOGOUT.4: Redirección Post-Logout
**Regla**: Tras logout exitoso, usuario debe ser redirigido a página de login
**Mensaje**: Mostrar "Sesión cerrada exitosamente"
**Validación**: Intentar acceder a páginas protegidas post-logout → redirigir a login
**Mensaje de acceso denegado**: "Debes iniciar sesión para acceder"

#### RN-003-LOGOUT.5: Logout por Inactividad
**Regla**: Si usuario inactivo por más de 2 horas, sistema debe cerrar sesión automáticamente
**Regla de aviso**: 5 minutos antes del logout, mostrar warning con opción "Extender sesión"
**Validación**: Cualquier interacción del usuario resetea contador de inactividad
**Mensaje logout automático**: "Sesión cerrada por inactividad"
**Caso especial**: Al hacer clic en "Extender sesión", resetear timer y mantener sesión activa

#### RN-003-LOGOUT.6: Sincronización Multi-Pestaña
**Regla**: Si usuario hace logout en una pestaña, todas las demás pestañas deben cerrarse también
**Validación**: Todas las pestañas abiertas deben detectar cambio de estado de sesión
**Acción**: Redirigir todas las pestañas a login automáticamente
**Mensaje en otras pestañas**: "Sesión cerrada en otra pestaña"

#### RN-003-LOGOUT.7: Logout con "Recordarme"
**Regla**: Si usuario inició sesión con "Recordarme" activado, logout manual debe eliminar también sesión persistente
**Restricción**: En próximo acceso, usuario debe hacer login completo nuevamente
**Validación**: No debe mantener sesión automática después de logout manual
**Caso especial**: Logout por inactividad NO aplica cuando hay "Recordarme" activo

#### RN-003-LOGOUT.8: Logout por Token Expirado
**Regla**: Cuando token JWT expira, hacer logout automático inmediatamente
**Validación**: Sistema debe detectar expiración al intentar cualquier acción protegida
**Acción**: Redirigir a login automáticamente
**Mensaje**: "Tu sesión ha expirado. Inicia sesión nuevamente"
**Restricción**: Usuario NO debe poder continuar en la aplicación con token expirado

#### RN-003-LOGOUT.9: Auditoría de Logouts
**Regla**: Sistema debe registrar todos los eventos de logout (manual y automático)
**Información a registrar**: Usuario, fecha/hora, tipo de logout (manual/inactividad/token expirado)
**Validación**: Logs deben ser consultables para auditorías de seguridad
**Restricción**: Información sensible NO debe almacenarse en logs

#### RN-003-LOGOUT.10: Visibilidad de Opción Logout
**Regla**: En cualquier página del sistema, usuario autenticado debe ver opción de cerrar sesión
**Ubicación**: Dropdown menu del usuario en header/navbar
**Restricción**: Opción debe ser fácilmente accesible (máximo 2 clics)
**Validación**: Header debe mostrar nombre de usuario y rol actual junto a opción logout

---

### RN-004: RECUPERACIÓN DE CONTRASEÑA
**Contexto**: Usuario registrado olvidó su contraseña y desea recuperar acceso
**Origen**: E001-HU-004 - Recuperar Contraseña

#### RN-004.1: Solicitud de Recuperación
**Regla**: Usuario puede solicitar recuperación de contraseña ingresando solo su email
**Restricción**: Email es obligatorio y debe tener formato válido
**Validación**: Verificar que email tiene formato correcto antes de procesar
**Mensaje de error formato**: "Formato de email inválido"

#### RN-004.2: Privacidad de Emails
**Regla**: Sistema NO debe revelar si un email existe o no en la base de datos
**Restricción**: Mostrar siempre el mismo mensaje genérico, independiente de si email existe
**Mensaje estándar**: "Si el email existe, se enviará un enlace de recuperación"
**Caso especial**: Registrar en logs intentos con emails no registrados (para seguridad)

#### RN-004.3: Usuario No Aprobado
**Regla**: Solo usuarios en estado APROBADO pueden recuperar contraseña
**Restricción**: Si usuario existe pero NO está aprobado, no generar token de recuperación
**Acción**: Enviar email informando que cuenta no está aprobada y sugerir contactar administrador
**Mensaje público**: Mantener mensaje genérico de envío

#### RN-004.4: Generación de Token
**Regla**: Token de recuperación debe ser único, aleatorio y seguro
**Especificaciones técnicas**: 32 bytes random con URL-safe encoding
**Restricción**: Token debe asociarse a un usuario específico y tener fecha de expiración
**Validación**: Token debe ser único en toda la tabla password_recovery

#### RN-004.5: Expiración de Token
**Regla**: Token de recuperación es válido por 24 horas desde su creación
**Restricción**: Después de 24 horas, token NO puede usarse para cambiar contraseña
**Mensaje token expirado**: "Enlace de recuperación expirado. Solicita uno nuevo"
**Acción**: Ofrecer botón para solicitar nuevo enlace

#### RN-004.6: Token de Uso Único
**Regla**: Cada token puede usarse solo UNA vez para cambiar contraseña
**Restricción**: Una vez usado exitosamente, token debe marcarse como usado (used_at)
**Validación**: Intentar reutilizar token usado debe rechazarse con mensaje "Enlace ya utilizado"
**Caso especial**: Token usado no puede reactivarse, debe solicitarse uno nuevo

#### RN-004.7: Rate Limiting de Solicitudes
**Regla**: Usuario puede solicitar recuperación máximo 1 vez cada 15 minutos
**Restricción**: Intentos adicionales dentro de 15 minutos deben ser rechazados
**Mensaje**: "Ya se envió un enlace recientemente. Espera [X] minutos"
**Validación**: Mostrar tiempo restante hasta poder solicitar nuevamente
**Caso especial**: Ofrecer opción "No recibí el email" con troubleshooting

#### RN-004.8: Contenido del Email
**Regla**: Email de recuperación debe incluir enlace seguro con token, instrucciones y aviso de expiración
**Restricción**: Email debe enviarse solo si usuario está APROBADO y verificado
**Contenido obligatorio**:
- Enlace: `{URL_APP}/reset-password?token={TOKEN}`
- Instrucciones claras del proceso
- Aviso de expiración en 24 horas
- Nota de seguridad si no solicitó el cambio
**Asunto**: "Recuperación de Contraseña - Sistema Medias"

#### RN-004.9: Validación de Nueva Contraseña
**Regla**: Nueva contraseña debe cumplir política de seguridad mínima
**Restricciones**:
- Mínimo 8 caracteres
- Debe contener al menos 1 letra y 1 número
- Campos "Nueva Contraseña" y "Confirmar Contraseña" deben coincidir
**Validación**: Mostrar indicador de fortaleza en tiempo real
**Mensajes de error**:
- "Contraseña debe tener mínimo 8 caracteres"
- "Las contraseñas no coinciden"
- "Contraseña debe incluir letras y números"

#### RN-004.10: Cambio de Contraseña Exitoso
**Regla**: Al cambiar contraseña exitosamente, actualizar password_hash e invalidar token
**Proceso**:
1. Validar token existe, no expiró y no fue usado
2. Validar nueva contraseña cumple política
3. Hash de nueva contraseña con bcrypt
4. Actualizar password_hash en tabla users
5. Marcar token como usado (used_at = NOW())
**Mensaje**: "Contraseña cambiada exitosamente"
**Acción**: Redirigir automáticamente a página de login

#### RN-004.11: Token Inválido o Manipulado
**Regla**: Si token no existe en BD o fue manipulado, rechazar cambio de contraseña
**Mensaje**: "Enlace de recuperación inválido"
**Acción**: Ofrecer botón "Solicitar nuevo enlace" y redirigir a formulario de recuperación
**Restricción**: No revelar detalles del error (seguridad)

#### RN-004.12: Limpieza de Tokens Expirados
**Regla**: Sistema debe limpiar automáticamente tokens expirados de la base de datos
**Frecuencia**: Job automático ejecutado diariamente
**Criterio de limpieza**: Eliminar tokens con expires_at < NOW()
**Validación**: Mantener registro de limpieza en logs de sistema

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
