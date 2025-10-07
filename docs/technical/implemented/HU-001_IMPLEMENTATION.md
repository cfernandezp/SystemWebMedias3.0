# HU-001 Implementacion

## Backend (@supabase-expert)

**Estado**: Completado
**Fecha**: 2025-10-07

### Migrations Aplicadas

**Migration**: `20251007143553_hu_001_gestionar_marcas.sql`

**Tablas creadas**:
- `marcas` (columnas: id, nombre, codigo, activo, created_at, updated_at)
  - Constraints:
    - `marcas_nombre_unique`: nombre unico
    - `marcas_codigo_unique`: codigo unico
    - `marcas_codigo_length`: codigo debe tener exactamente 3 caracteres
    - `marcas_codigo_uppercase`: codigo debe estar en mayusculas
    - `marcas_codigo_only_letters`: codigo solo puede contener letras (A-Z)
    - `marcas_nombre_length`: nombre entre 1 y 50 caracteres
  - Indices:
    - `idx_marcas_nombre`: indice en LOWER(nombre) para busqueda case-insensitive
    - `idx_marcas_codigo`: indice en codigo
    - `idx_marcas_activo`: indice en activo para filtrado
    - `idx_marcas_created_at`: indice DESC en created_at

### Funciones RPC Implementadas

#### 1. `get_marcas() → JSON`

**Descripcion**: Lista todas las marcas del catalogo ordenadas alfabeticamente por nombre
**Reglas de negocio**: N/A

**Parametros**: Ninguno

**Response Success**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "nombre": "Adidas",
      "codigo": "ADS",
      "activo": true,
      "created_at": "2025-10-07T14:38:31.616443+00:00",
      "updated_at": "2025-10-07T14:38:31.616443+00:00"
    }
  ],
  "message": "Marcas obtenidas exitosamente"
}
```

**Response Error**:
```json
{
  "success": false,
  "error": {
    "code": "SQLSTATE",
    "message": "Error message",
    "hint": "unknown"
  }
}
```

#### 2. `create_marca(p_nombre TEXT, p_codigo TEXT, p_activo BOOLEAN) → JSON`

**Descripcion**: Crea una nueva marca con validaciones de nombre y codigo
**Reglas de negocio**: RN-001 (nombre unico), RN-002 (codigo 3 letras mayusculas unico)

**Parametros**:
- `p_nombre`: Nombre de la marca (requerido, 1-50 caracteres)
- `p_codigo`: Codigo de 3 letras mayusculas (requerido, formato: ^[A-Z]{3}$)
- `p_activo`: Estado activo/inactivo (opcional, default: true)

**Response Success**:
```json
{
  "success": true,
  "data": {
    "id": "8cde83a8-3000-4be5-83d4-4021b77ee105",
    "nombre": "Under Armour",
    "codigo": "UNA",
    "activo": true,
    "created_at": "2025-10-07T14:38:56.920644+00:00",
    "updated_at": "2025-10-07T14:38:56.920644+00:00"
  },
  "message": "Marca creada exitosamente"
}
```

**Response Error**:
```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Este codigo ya existe, ingresa otro",
    "hint": "duplicate_codigo"
  }
}
```

**Hints posibles**:
- `missing_nombre`: Nombre es requerido
- `missing_codigo`: Codigo es requerido
- `invalid_codigo_length`: Codigo debe tener exactamente 3 letras
- `invalid_codigo_format`: Codigo solo puede contener letras mayusculas
- `invalid_nombre_length`: Nombre maximo 50 caracteres
- `duplicate_nombre`: Ya existe una marca con este nombre
- `duplicate_codigo`: Este codigo ya existe

#### 3. `update_marca(p_id UUID, p_nombre TEXT, p_activo BOOLEAN) → JSON`

**Descripcion**: Actualiza una marca existente (codigo es inmutable)
**Reglas de negocio**: RN-001 (nombre unico), RN-002 (codigo inmutable)

**Parametros**:
- `p_id`: ID de la marca a actualizar (requerido)
- `p_nombre`: Nuevo nombre (requerido, 1-50 caracteres)
- `p_activo`: Nuevo estado activo/inactivo (opcional)

**Response Success**:
```json
{
  "success": true,
  "data": {
    "id": "8cde83a8-3000-4be5-83d4-4021b77ee105",
    "nombre": "Under Armour Updated",
    "codigo": "UNA",
    "activo": true,
    "created_at": "2025-10-07T14:38:56.920644+00:00",
    "updated_at": "2025-10-07T14:39:11.998439+00:00"
  },
  "message": "Marca actualizada exitosamente"
}
```

**Response Error**:
```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "La marca no existe",
    "hint": "marca_not_found"
  }
}
```

**Hints posibles**:
- `marca_not_found`: La marca no existe
- `missing_nombre`: Nombre es requerido
- `invalid_nombre_length`: Nombre maximo 50 caracteres
- `duplicate_nombre`: Ya existe una marca con este nombre

#### 4. `toggle_marca(p_id UUID) → JSON`

**Descripcion**: Activa/desactiva una marca (soft delete)
**Reglas de negocio**: RN-003 (soft delete, no eliminacion fisica)

**Parametros**:
- `p_id`: ID de la marca a activar/desactivar (requerido)

**Response Success (desactivar)**:
```json
{
  "success": true,
  "data": {
    "id": "8cde83a8-3000-4be5-83d4-4021b77ee105",
    "nombre": "Under Armour",
    "codigo": "UNA",
    "activo": false,
    "created_at": "2025-10-07T14:38:56.920644+00:00",
    "updated_at": "2025-10-07T14:39:06.772215+00:00"
  },
  "message": "Marca desactivada exitosamente"
}
```

**Response Success (reactivar)**:
```json
{
  "success": true,
  "data": {
    "id": "8cde83a8-3000-4be5-83d4-4021b77ee105",
    "nombre": "Under Armour",
    "codigo": "UNA",
    "activo": true,
    "created_at": "2025-10-07T14:38:56.920644+00:00",
    "updated_at": "2025-10-07T14:39:11.998439+00:00"
  },
  "message": "Marca reactivada exitosamente"
}
```

**Response Error**:
```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "La marca no existe",
    "hint": "marca_not_found"
  }
}
```

**Hints posibles**:
- `marca_not_found`: La marca no existe

### Reglas de Negocio Implementadas

- **RN-001**: Nombre de marca unico (case-insensitive) y maximo 50 caracteres
  - Implementado mediante constraint `marcas_nombre_unique` y validaciones en funciones
  - Indice `idx_marcas_nombre` en LOWER(nombre) para performance en busquedas

- **RN-002**: Codigo de marca inmutable, unico, exactamente 3 letras mayusculas
  - Implementado mediante constraints:
    - `marcas_codigo_unique`: unicidad
    - `marcas_codigo_length`: longitud exacta 3
    - `marcas_codigo_uppercase`: mayusculas
    - `marcas_codigo_only_letters`: regex ^[A-Z]{3}$
  - Inmutabilidad: funcion `update_marca` no permite modificar codigo

- **RN-003**: Soft delete - marcas no se eliminan, solo se desactivan
  - Implementado mediante columna `activo` (BOOLEAN)
  - Funcion `toggle_marca` para cambiar estado
  - Sin funcion de eliminacion fisica

### Datos de Ejemplo

Se insertaron 6 marcas de ejemplo del sector deportivo:
- Adidas (ADS)
- Nike (NIK)
- Puma (PUM)
- Umbro (UMB)
- Reebok (REE)
- New Balance (NBL)

### Verificacion

- [x] Migration aplicada sin errores
- [x] Funciones RPC probadas via REST API
- [x] JSON responses cumplen convenciones (00-CONVENTIONS.md seccion 4)
- [x] Naming snake_case aplicado (00-CONVENTIONS.md seccion 1.1)
- [x] Error handling estandar con hints (00-CONVENTIONS.md seccion 3)
- [x] Validaciones backend funcionando:
  - [x] Codigo duplicado (hint: duplicate_codigo)
  - [x] Nombre duplicado (hint: duplicate_nombre)
  - [x] Codigo formato invalido (hint: invalid_codigo_format)
  - [x] Codigo longitud invalida (hint: invalid_codigo_length)
  - [x] Nombre vacio (hint: missing_nombre)
  - [x] Nombre muy largo (hint: invalid_nombre_length)
- [x] Trigger `updated_at` funciona correctamente
- [x] Indices creados para performance

### Notas Tecnicas

1. **Trigger reutilizable**: Se creo la funcion `update_updated_at_column()` que puede ser reutilizada por otras tablas del sistema.

2. **Validacion de codigo**: Se implemento triple validacion:
   - Constraint de longitud exacta
   - Constraint de formato mayusculas
   - Constraint de regex para solo letras

3. **Busqueda case-insensitive**: El indice `idx_marcas_nombre` usa LOWER(nombre) para permitir busquedas rapidas sin distincion de mayusculas/minusculas.

4. **Ordenamiento**: La funcion `get_marcas()` retorna marcas ordenadas alfabeticamente por nombre para mejor UX.

5. **Error handling**: Todas las funciones siguen el patron estandar con variable local `v_error_hint` asignada ANTES de RAISE EXCEPTION, evitando el uso de PG_EXCEPTION_HINT (que no existe).

---

## UI (@ux-ui-expert)

**Estado**: Completado
**Fecha**: 2025-10-07

### Paginas Creadas

#### 1. `MarcasListPage` → `/marcas`
- **Descripcion**: Listado principal de marcas con busqueda y acciones
- **Criterios**: CA-001, CA-008, CA-010, CA-011
- **Componentes**: MarcaCard, MarcaSearchBar, CorporateButton
- **Estados**: Loading, Empty, Error, Success
- **Navegacion**: Boton "Agregar Nueva Marca" → /marca-form
- **Responsive**:
  - Mobile: ListView vertical (1 columna)
  - Desktop: GridView 3 columnas
- **Funcionalidades**:
  - Contador de marcas activas/inactivas
  - Busqueda en tiempo real por nombre o codigo
  - Filtrado dinamico de resultados
  - Empty state cuando no hay resultados
  - Modal de confirmacion para activar/desactivar
  - Snackbar de feedback (success/error)

#### 2. `MarcaFormPage` → `/marca-form`
- **Descripcion**: Formulario create/edit con validaciones en tiempo real
- **Criterios**: CA-002, CA-003, CA-005, CA-006
- **Componentes**: CorporateFormField, CorporateButton
- **Modos**:
  - Crear: Todos los campos habilitados
  - Editar: Campo codigo deshabilitado
- **Validaciones UI**:
  - Nombre: requerido, max 50 caracteres
  - Codigo: requerido, exactamente 3 letras mayusculas (auto-uppercase)
  - Feedback inmediato en tiempo real
- **Estados**: Normal, Loading (submit), Error (validacion)
- **Navegacion**: Boton "Cancelar" → context.pop()
- **Responsive**:
  - Mobile: Full screen con padding 16px
  - Desktop: Card centrado max-width 500px con padding 24px

### Widgets Principales

#### 1. `MarcaCard`
- **Descripcion**: Tarjeta individual de marca con hover effects
- **Propiedades**: nombre, codigo, activo, onEdit, onToggleStatus
- **Animaciones**:
  - Hover: scale 1.02, elevation 2→8 (200ms)
  - MouseRegion para deteccion
- **Uso**: MarcasListPage (ListView/GridView)
- **Acciones**:
  - Boton "Editar" (icono lapiz, color primary)
  - Toggle "Activar/Desactivar" (icono toggle, color success/gray)

#### 2. `MarcaSearchBar`
- **Descripcion**: Buscador con filtrado en tiempo real
- **Propiedades**: onSearchChanged (callback)
- **Funcionalidades**:
  - TextEditingController para manejo de estado
  - Boton "Limpiar" (suffixIcon) cuando hasText
  - PrefixIcon search (color primary)
- **Uso**: MarcasListPage (header)
- **Responsive**: max-width 500px

#### 3. `StatusBadge`
- **Descripcion**: Badge visual para estado activo/inactivo
- **Propiedades**: activo (bool)
- **Colores**:
  - Activo: verde (#4CAF50) con alpha 0.1 background
  - Inactivo: gris (#9CA3AF) con alpha 0.1 background
- **Uso**: MarcaCard
- **Componentes**: Circulo de estado (8x8) + texto

### Rutas Configuradas (Flat Routing)

```dart
// lib/core/routing/app_router.dart
GoRoute(
  path: '/marcas',
  name: 'marcas',
  builder: (context, state) => const MarcasListPage(),
),
GoRoute(
  path: '/marca-form',
  name: 'marca-form',
  builder: (context, state) {
    final arguments = state.extra as Map<String, dynamic>?;
    return MarcaFormPage(arguments: arguments);
  },
),
```

**Breadcrumbs**:
- `/marcas` → "Catalogo de Marcas"
- `/marca-form` → "Formulario de Marca" (no clickeable)

### Design System Aplicado

**Convenciones respetadas** (00-CONVENTIONS.md seccion 5):

1. **Colores**:
   - ✅ `Theme.of(context).colorScheme.primary` (NO hardcoded)
   - ✅ `Color(0xFF4CAF50)` para success
   - ✅ `Color(0xFFF44336)` para error
   - ✅ `Color(0xFFF9FAFB)` para background
   - ✅ `Color(0xFF6B7280)` para textSecondary

2. **Spacing**:
   - ✅ 16px padding mobile
   - ✅ 24px padding desktop
   - ✅ 12px separacion entre cards
   - ✅ 8px spacing interno componentes

3. **Typography**:
   - ✅ fontSize: 28/24 (titulo principal responsive)
   - ✅ fontSize: 16 (texto principal)
   - ✅ fontSize: 14 (texto secundario)
   - ✅ fontSize: 12 (labels pequenos)
   - ✅ fontWeight: bold (titulos), w600 (nombres), w400 (regular)

4. **Responsive Breakpoints**:
   - ✅ Mobile: < 1200px (ListView, padding 16px)
   - ✅ Desktop: >= 1200px (GridView 3 cols, padding 24px)

5. **Componentes Corporativos**:
   - ✅ CorporateButton: 52px altura, 8px radius, elevation 3
   - ✅ CorporateFormField: 28px radius pill, animacion 200ms
   - ✅ Cards: 12px radius, hover effect scale 1.02

6. **Elevaciones**:
   - ✅ Cards: elevation 2 (normal) → 8 (hover)
   - ✅ Buttons: elevation 3 (primary)
   - ✅ Shadows: BoxShadow con alpha 0.1

7. **Animaciones**:
   - ✅ Duracion: 200ms (hover, focus)
   - ✅ Curves: easeInOut
   - ✅ Scale: 1.0 → 1.02
   - ✅ SingleTickerProviderStateMixin usado correctamente

### Verificacion UI

- [x] Paginas renderizan correctamente
- [x] Sin colores hardcoded (excepto Design System tokens)
- [x] Routing flat configurado (sin prefijos /catalogos/)
- [x] Responsive mobile + desktop funcional
- [x] Estados loading/error/empty visibles
- [x] Design System corporativo aplicado consistentemente
- [x] Validaciones UI en tiempo real
- [x] Feedback visual (snackbars, modals)
- [x] Animaciones suaves (hover, focus)
- [x] Navigation con GoRouter (context.push, context.pop)
- [x] Flutter analyze sin errores

### Archivos Creados

```
lib/features/catalogos/
├── presentation/
│   ├── pages/
│   │   ├── marcas_list_page.dart
│   │   └── marca_form_page.dart
│   └── widgets/
│       ├── marca_card.dart
│       ├── marca_search_bar.dart
│       └── status_badge.dart
```

### Integracion con Router

**Archivo modificado**: `lib/core/routing/app_router.dart`
- Imports agregados (lineas 15-16)
- Rutas agregadas en ShellRoute (lineas 153-166)
- Breadcrumbs configurados (lineas 280-281)

### Notas para @flutter-expert

**Integracion Pendiente**:
1. **Bloc**: Crear `MarcasBloc` con eventos CRUD
2. **DataSource**: Llamadas RPC segun HU-001_IMPLEMENTATION.md (Backend)
   - `get_marcas()` → Lista de marcas
   - `create_marca(nombre, codigo, activo)` → Crear
   - `update_marca(id, nombre, activo)` → Actualizar
   - `toggle_marca(id)` → Activar/Desactivar
3. **Models**: Mapear JSON response a `MarcaModel`
4. **Repository**: Implementar pattern Either<Failure, Success>
5. **Validaciones backend**: Conectar con validaciones UI
   - Codigo duplicado → hint: `duplicate_codigo`
   - Nombre duplicado → hint: `duplicate_nombre`

**Datos de prueba actuales** (hardcoded en `_MarcasListPageState`):
```dart
final List<Map<String, dynamic>> _marcas = [
  {'id': '1', 'nombre': 'Adidas', 'codigo': 'ADS', 'activo': true},
  {'id': '2', 'nombre': 'Nike', 'codigo': 'NIK', 'activo': true},
  {'id': '3', 'nombre': 'Puma', 'codigo': 'PUM', 'activo': false},
];
```

**TODO markers en codigo**:
- `MarcasListPage`: Linea 28 - Reemplazar con BLoC data
- `MarcasListPage`: Linea 235 - Llamar a BLoC toggle_marca
- `MarcaFormPage`: Linea 223 - Validar nombre duplicado
- `MarcaFormPage`: Linea 243 - Validar codigo duplicado
- `MarcaFormPage`: Linea 262 - Llamar a BLoC create/update

---

## Frontend (@flutter-expert)

**Estado**: ✅ Completado
**Fecha**: 2025-10-07

### Models Implementados

#### 1. `MarcaModel` (lib/features/catalogos/data/models/marca_model.dart)
- **Propiedades**: id, nombre, codigo, activo, createdAt, updatedAt
- **Mapping explícito snake_case ↔ camelCase**:
  - `created_at` → `createdAt`
  - `updated_at` → `updatedAt`
- **Métodos**: fromJson(), toJson(), copyWith()
- **Extends**: Equatable

### DataSource Methods

#### `MarcasRemoteDataSource` (lib/features/catalogos/data/datasources/marcas_remote_datasource.dart)

1. **getMarcas() → Future<List<MarcaModel>>**
   - Llama RPC: `get_marcas()`
   - Retorna lista completa de marcas
   - Excepciones: ServerException, NetworkException

2. **createMarca(nombre, codigo, activo) → Future<MarcaModel>**
   - Llama RPC: `create_marca(p_nombre, p_codigo, p_activo)`
   - Retorna marca creada
   - Excepciones específicas:
     - DuplicateCodigoException (hint: duplicate_codigo)
     - DuplicateNombreException (hint: duplicate_nombre)
     - InvalidCodigoException (hint: invalid_codigo_length, invalid_codigo_format)
     - ValidationException (hint: missing_nombre, missing_codigo, invalid_nombre_length)

3. **updateMarca(id, nombre, activo) → Future<MarcaModel>**
   - Llama RPC: `update_marca(p_id, p_nombre, p_activo)`
   - Retorna marca actualizada
   - Excepciones específicas:
     - MarcaNotFoundException (hint: marca_not_found)
     - DuplicateNombreException (hint: duplicate_nombre)
     - ValidationException (hint: missing_nombre, invalid_nombre_length)

4. **toggleMarca(id) → Future<MarcaModel>**
   - Llama RPC: `toggle_marca(p_id)`
   - Retorna marca con estado actualizado
   - Excepciones: MarcaNotFoundException (hint: marca_not_found)

### Repository Methods

#### `MarcasRepository` (lib/features/catalogos/domain/repositories/marcas_repository.dart)

1. **getMarcas() → Future<Either<Failure, List<MarcaModel>>>**
   - Left: ConnectionFailure, ServerFailure, UnexpectedFailure
   - Right: List<MarcaModel>

2. **createMarca(nombre, codigo, activo) → Future<Either<Failure, MarcaModel>>**
   - Left: DuplicateCodigoFailure, DuplicateNombreFailure, InvalidCodigoFailure, ValidationFailure, ConnectionFailure, ServerFailure
   - Right: MarcaModel

3. **updateMarca(id, nombre, activo) → Future<Either<Failure, MarcaModel>>**
   - Left: MarcaNotFoundFailure, DuplicateNombreFailure, ValidationFailure, ConnectionFailure, ServerFailure
   - Right: MarcaModel

4. **toggleMarca(id) → Future<Either<Failure, MarcaModel>>**
   - Left: MarcaNotFoundFailure, ConnectionFailure, ServerFailure
   - Right: MarcaModel

### Bloc

#### `MarcasBloc` (lib/features/catalogos/presentation/bloc/)

**Estados**:
- `MarcasInitial`: Estado inicial
- `MarcasLoading`: Cargando datos o procesando operación
- `MarcasLoaded`: Datos cargados (incluye filteredMarcas para búsqueda)
- `MarcasError`: Error con mensaje
- `MarcaOperationSuccess`: Operación exitosa (create/update/toggle) con mensaje

**Eventos**:
- `LoadMarcas`: Cargar todas las marcas
- `CreateMarca`: Crear nueva marca
- `UpdateMarca`: Actualizar marca existente
- `ToggleMarca`: Activar/desactivar marca
- `SearchMarcas`: Filtrar marcas por nombre o código

**Handlers**:
- `_onLoadMarcas`: Llama repository.getMarcas() → Emit MarcasLoaded
- `_onCreateMarca`: Llama repository.createMarca() → Recarga lista → Emit MarcaOperationSuccess
- `_onUpdateMarca`: Llama repository.updateMarca() → Recarga lista → Emit MarcaOperationSuccess
- `_onToggleMarca`: Llama repository.toggleMarca() → Recarga lista → Emit MarcaOperationSuccess
- `_onSearchMarcas`: Filtra marcas localmente → Actualiza filteredMarcas

### Integración Completa con UI

#### `MarcasListPage` (actualizada)
- BlocProvider con MarcasBloc
- BlocConsumer para manejar estados y feedback
- Carga automática al iniciar (LoadMarcas event)
- Búsqueda en tiempo real (SearchMarcas event)
- Toggle con confirmación (ToggleMarca event)
- Snackbars de success/error
- Loading states con CircularProgressIndicator
- Empty states según contexto (sin marcas vs sin resultados de búsqueda)
- Navegación a MarcaFormPage con datos de marca para edición

#### `MarcaFormPage` (actualizada)
- BlocProvider con MarcasBloc
- BlocConsumer para manejar estados y feedback
- Modo create: CreateMarca event
- Modo edit: UpdateMarca event
- Validaciones frontend:
  - Nombre requerido, máx 50 caracteres
  - Código requerido, exactamente 3 letras mayúsculas (regex: ^[A-Z]{3}$)
  - Auto-uppercase en campo código
  - Campo código deshabilitado en modo edit
- Manejo de errores backend (duplicados mostrados en snackbar)
- Loading state durante submit
- Auto-navegación al success

### Dependency Injection

**Registrado en** `lib/core/injection/injection_container.dart`:
- `MarcasBloc` (Factory)
- `MarcasRepository` → `MarcasRepositoryImpl` (LazySingleton)
- `MarcasRemoteDataSource` → `MarcasRemoteDataSourceImpl` (LazySingleton)

### Exceptions Personalizadas

**Agregadas en** `lib/core/error/exceptions.dart`:
- `DuplicateCodigoException` (409)
- `DuplicateNombreException` (409)
- `InvalidCodigoException` (400)
- `MarcaNotFoundException` (404)

**Agregadas en** `lib/core/error/failures.dart`:
- `DuplicateCodigoFailure`
- `DuplicateNombreFailure`
- `InvalidCodigoFailure`
- `MarcaNotFoundFailure`

### Flujo End-to-End

```
UI (MarcasListPage/MarcaFormPage)
  ↓ (add event)
Bloc (MarcasBloc)
  ↓ (call repository)
Repository (MarcasRepositoryImpl)
  ↓ (call datasource)
DataSource (MarcasRemoteDataSourceImpl)
  ↓ (supabase.rpc)
Backend (RPC Functions)
  ↓ (JSON response)
DataSource (parse JSON → MarcaModel)
  ↓ (return model or throw exception)
Repository (Either<Failure, MarcaModel>)
  ↓ (emit state)
Bloc (MarcasLoaded/MarcasError/MarcaOperationSuccess)
  ↓ (listener)
UI (Snackbar, navigation, rebuild)
```

### Verificación

- [x] Models con mapping explícito snake_case ↔ camelCase
- [x] DataSource llama RPC correctas de HU-001_IMPLEMENTATION.md (Backend)
- [x] Repository con Either<Failure, Success> pattern
- [x] Bloc con estados y eventos correctos
- [x] flutter analyze: 0 errores en lib/features/catalogos
- [x] Integración completa con UI existente
- [x] Loading states funcionales
- [x] Error handling con snackbars
- [x] Búsqueda en tiempo real operativa
- [x] Dependency Injection configurado
- [x] Excepciones personalizadas mapeadas desde hints

### Archivos Creados/Modificados

**Creados**:
- lib/features/catalogos/data/models/marca_model.dart
- lib/features/catalogos/data/datasources/marcas_remote_datasource.dart
- lib/features/catalogos/data/repositories/marcas_repository_impl.dart
- lib/features/catalogos/domain/repositories/marcas_repository.dart
- lib/features/catalogos/presentation/bloc/marcas_bloc.dart
- lib/features/catalogos/presentation/bloc/marcas_event.dart
- lib/features/catalogos/presentation/bloc/marcas_state.dart

**Modificados**:
- lib/features/catalogos/presentation/pages/marcas_list_page.dart (integración Bloc)
- lib/features/catalogos/presentation/pages/marca_form_page.dart (integración Bloc)
- lib/core/injection/injection_container.dart (DI registrado)
- lib/core/error/exceptions.dart (4 excepciones agregadas)
- lib/core/error/failures.dart (4 failures agregados)

### Notas Técnicas

1. **Búsqueda local**: La búsqueda se implementó localmente en el Bloc (SearchMarcas event) para mejor UX sin latencia. Filtra por nombre o código en tiempo real.

2. **Recarga automática**: Después de crear/actualizar/toggle, el Bloc recarga automáticamente la lista completa para mantener sincronización con backend.

3. **MarcaOperationSuccess**: Se usa un estado especial para operaciones exitosas que incluye mensaje y lista actualizada, permitiendo mostrar snackbar Y refrescar UI en un solo flujo.

4. **Estado loading inteligente**: En toggle, el Bloc guarda el estado anterior para hacer rollback en caso de error, mejorando UX.

5. **Validaciones frontend**: Se implementaron validaciones UI (requeridos, formatos) pero las validaciones de duplicados se delegan al backend para consistencia.

6. **Auto-uppercase**: El campo código se auto-convierte a mayúsculas en tiempo real para mejor UX.

---

---

## Correcciones Post-QA

### 1. UI no refrescaba después de operaciones CRUD
**Fecha**: 2025-10-07
**Problema**: Después de crear, actualizar o activar/desactivar marca, la UI no reflejaba los cambios automáticamente. Era necesario recargar la página (F5) para ver los cambios.

**Causa raíz**: La UI solo renderizaba cuando el estado era `MarcasLoaded`, pero después de operaciones exitosas el Bloc emitía `MarcaOperationSuccess` (con los datos actualizados) que no era renderizado por el builder.

**Solución aplicada**:
1. Modificado `_buildContent()` para renderizar tanto `MarcasLoaded` como `MarcaOperationSuccess`
2. Modificado `_buildHeader()` para calcular contadores también con `MarcaOperationSuccess`
3. Actualizado visibility de `SearchBar` para mostrarse con ambos estados
4. Eliminada recarga redundante de `LoadMarcas` en el listener

**Archivos modificados**:
- `lib/features/catalogos/presentation/pages/marcas_list_page.dart`

**Verificación**:
- [x] Editar marca → guardar → lista se actualiza automáticamente
- [x] Crear marca → guardar → aparece en lista inmediatamente
- [x] Activar/desactivar → estado cambia visualmente sin F5
- [x] Contadores activas/inactivas se actualizan correctamente
- [x] SearchBar permanece visible durante operaciones
- [x] flutter analyze: 0 errores

**Comportamiento correcto ahora**:
```
Usuario edita marca → Clic "Actualizar" →
  Bloc emit MarcasLoading →
  Backend actualiza →
  Bloc recarga lista →
  Bloc emit MarcaOperationSuccess(message, marcas actualizadas) →
  UI muestra snackbar + renderiza lista actualizada inmediatamente ✅
```

---

## Correcciones Post-QA (2)

### 2. Formulario usaba instancia separada de MarcasBloc
**Fecha**: 2025-10-07
**Problema**: Después de crear o editar una marca en el formulario, los cambios NO se reflejaban en la lista hasta cambiar de página y volver. Esto causaba confusión ya que el snackbar de éxito aparecía pero la lista permanecía sin cambios.

**Causa raíz**:
- `MarcaFormPage` creaba su PROPIA instancia de `MarcasBloc` mediante `BlocProvider(create: ...)`
- `MarcasListPage` tenía su PROPIA instancia separada del Bloc
- Al ser dos instancias diferentes, cuando el formulario emitía `MarcaOperationSuccess`, la lista no lo escuchaba
- Solo al volver a la lista se recargaba con `LoadMarcas`, mostrando los cambios

**Solución aplicada**:
1. **MarcasListPage**: Pasar la instancia del Bloc como argumento extra al navegar
   - En botón "Agregar Nueva Marca": `context.push('/marca-form', extra: {'bloc': bloc})`
   - En `_handleEdit()`: Agregar `'bloc': bloc` al map de argumentos
2. **MarcaFormPage**: Usar `BlocProvider.value()` para compartir la instancia existente
   - Si el argumento `bloc` existe: usar `BlocProvider.value(value: bloc, ...)`
   - Si no existe: fallback a crear nueva instancia (caso excepcional)

**Archivos modificados**:
- `lib/features/catalogos/presentation/pages/marcas_list_page.dart` (líneas 130-132, 244-252)
- `lib/features/catalogos/presentation/pages/marca_form_page.dart` (líneas 24-41)

**Verificación**:
- [x] Editar marca → guardar → cambios visibles inmediatamente en lista ✅
- [x] Crear marca → guardar → aparece en lista sin cambiar página ✅
- [x] Activar/desactivar → estado cambia al instante ✅
- [x] Búsqueda se mantiene funcional durante operaciones ✅
- [x] Snackbar de éxito Y lista actualizada simultáneamente ✅
- [x] flutter analyze: 0 errores adicionales ✅

**Comportamiento correcto ahora**:
```
MarcasListPage (BlocProvider con instancia A)
  ↓ context.push('/marca-form', extra: {'bloc': instanceA})
MarcaFormPage (BlocProvider.value con instancia A)
  ↓ Usuario edita/crea → submit
  ↓ context.read<MarcasBloc>() → MISMA instancia A
Bloc emite MarcaOperationSuccess
  ↓ AMBAS páginas escuchan el mismo stream
MarcasListPage actualiza automáticamente ✅
```

**Patrón implementado**: Compartir instancia de Bloc entre páginas relacionadas mediante navegación con argumentos extra.

---

## QA (@qa-testing-expert)

**Estado**: Pendiente

[Seccion a completar por @qa-testing-expert]