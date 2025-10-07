# E002-HU-003 Implementación

**Historia**: E002-HU-003 - Gestionar Catálogo de Tipos
**Fecha Inicio**: 2025-10-07
**Estado General**: ✅ Backend Completado

---

## Backend (@supabase-expert)

**Estado**: ✅ Completado
**Fecha**: 2025-10-07

### Archivos Modificados

- `supabase/migrations/00000000000002_auth_tables.sql` (constraint audit_logs actualizado con eventos de tipos)
- `supabase/migrations/00000000000003_catalog_tables.sql` (tabla tipos agregada)
- `supabase/migrations/00000000000005_functions.sql` (6 funciones RPC de tipos)
- `supabase/migrations/00000000000006_seed_data.sql` (datos iniciales: 9 tipos)

### Tablas Agregadas

#### `tipos` (lib: public)
- **Columnas**:
  - `id` (UUID PRIMARY KEY, gen_random_uuid())
  - `nombre` (TEXT NOT NULL UNIQUE) - Case-insensitive, max 50 caracteres
  - `descripcion` (TEXT NULLABLE) - Max 200 caracteres
  - `codigo` (TEXT NOT NULL UNIQUE) - Exactamente 3 letras mayúsculas A-Z
  - `imagen_url` (TEXT NULLABLE) - URL de imagen de referencia
  - `activo` (BOOLEAN NOT NULL DEFAULT true) - Soft delete
  - `created_at` (TIMESTAMP WITH TIME ZONE DEFAULT NOW())
  - `updated_at` (TIMESTAMP WITH TIME ZONE DEFAULT NOW())

- **Índices**:
  - `idx_tipos_nombre` ON LOWER(nombre) - Para búsqueda case-insensitive
  - `idx_tipos_codigo` ON codigo - Para búsqueda rápida por código
  - `idx_tipos_activo` ON activo - Para filtrar activos/inactivos
  - `idx_tipos_created_at` ON created_at DESC - Para ordenar por fecha

- **Constraints**:
  - `tipos_nombre_unique` UNIQUE (nombre)
  - `tipos_codigo_unique` UNIQUE (codigo)
  - `tipos_codigo_length` CHECK (LENGTH(codigo) = 3)
  - `tipos_codigo_uppercase` CHECK (codigo = UPPER(codigo))
  - `tipos_codigo_only_letters` CHECK (codigo ~ '^[A-Z]{3}$')
  - `tipos_nombre_length` CHECK (LENGTH(nombre) <= 50 AND LENGTH(nombre) > 0)
  - `tipos_descripcion_length` CHECK (descripcion IS NULL OR LENGTH(descripcion) <= 200)

- **Trigger**:
  - `update_tipos_updated_at` - Actualiza updated_at automáticamente

### Funciones RPC Implementadas

#### 1. `get_tipos(p_search TEXT DEFAULT NULL, p_activo_filter BOOLEAN DEFAULT NULL) → JSON`

**Descripción**: Lista tipos con búsqueda multicriterio y filtro por estado activo/inactivo

**Criterios de Aceptación**: CA-001, CA-011

**Reglas de negocio**: RN-003-009 (búsqueda multicriterio en nombre, descripción, código)

**Parámetros**:
- `p_search` (TEXT, opcional): Término de búsqueda (case-insensitive)
- `p_activo_filter` (BOOLEAN, opcional): Filtrar por estado (true/false/null=todos)

**Response Success**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "nombre": "Invisible",
      "descripcion": "Media muy baja, no visible con zapatos",
      "codigo": "INV",
      "imagen_url": null,
      "activo": true,
      "created_at": "2025-10-07T22:09:17.812715+00:00",
      "updated_at": "2025-10-07T22:09:17.812715+00:00"
    }
  ],
  "message": "Tipos obtenidos exitosamente"
}
```

**Response Error**:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Mensaje descriptivo",
    "hint": "unknown"
  }
}
```

#### 2. `create_tipo(p_nombre TEXT, p_descripcion TEXT, p_codigo TEXT, p_imagen_url TEXT DEFAULT NULL, p_activo BOOLEAN DEFAULT true) → JSON`

**Descripción**: Crea nuevo tipo de media con validaciones

**Criterios de Aceptación**: CA-002, CA-003, CA-004

**Reglas de negocio**:
- RN-003-001: Código único, exactamente 3 letras mayúsculas
- RN-003-002: Nombre único (case-insensitive), max 50 caracteres
- RN-003-003: Descripción opcional, max 200 caracteres
- RN-003-012: Registra auditoría (event_type='tipo_created')

**Parámetros**:
- `p_nombre` (TEXT): Nombre del tipo (requerido)
- `p_descripcion` (TEXT): Descripción del tipo (opcional)
- `p_codigo` (TEXT): Código de 3 letras mayúsculas (requerido)
- `p_imagen_url` (TEXT, opcional): URL de imagen de referencia
- `p_activo` (BOOLEAN, default true): Estado inicial

**Response Success**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "nombre": "Ciclismo",
    "descripcion": "Media especial para ciclistas",
    "codigo": "CIC",
    "imagen_url": null,
    "activo": true,
    "created_at": "2025-10-07T22:11:19.146155+00:00",
    "updated_at": "2025-10-07T22:11:19.146155+00:00"
  },
  "message": "Tipo creado exitosamente"
}
```

**Response Error Hints**:
- `missing_nombre`: Nombre no proporcionado
- `missing_codigo`: Código no proporcionado
- `invalid_codigo_length`: Código no tiene 3 caracteres
- `invalid_codigo_format`: Código contiene caracteres inválidos (solo A-Z permitido)
- `duplicate_nombre`: Ya existe tipo con ese nombre
- `duplicate_codigo`: Ya existe tipo con ese código
- `invalid_nombre_length`: Nombre excede 50 caracteres
- `invalid_descripcion_length`: Descripción excede 200 caracteres

#### 3. `update_tipo(p_id UUID, p_nombre TEXT, p_descripcion TEXT, p_activo BOOLEAN) → JSON`

**Descripción**: Actualiza tipo existente (código NO modificable)

**Criterios de Aceptación**: CA-005, CA-006, CA-007

**Reglas de negocio**:
- RN-003-002: Nombre único (excepto sí mismo)
- RN-003-003: Descripción max 200 caracteres
- RN-003-004: Código es inmutable (no está en parámetros)
- RN-003-012: Registra auditoría (event_type='tipo_updated')

**Parámetros**:
- `p_id` (UUID): ID del tipo a actualizar
- `p_nombre` (TEXT): Nuevo nombre
- `p_descripcion` (TEXT): Nueva descripción
- `p_activo` (BOOLEAN): Nuevo estado

**Response Success**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "nombre": "Ciclismo Pro",
    "descripcion": "Media profesional para ciclistas de competición",
    "codigo": "CIC",
    "imagen_url": null,
    "activo": true,
    "created_at": "2025-10-07T22:11:19.146155+00:00",
    "updated_at": "2025-10-07T22:11:34.28037+00:00"
  },
  "message": "Tipo actualizado exitosamente"
}
```

**Response Error Hints**:
- `tipo_not_found`: Tipo no existe
- `missing_nombre`: Nombre vacío
- `duplicate_nombre`: Nombre ya existe en otro tipo
- `invalid_nombre_length`: Nombre excede 50 caracteres
- `invalid_descripcion_length`: Descripción excede 200 caracteres

#### 4. `toggle_tipo_activo(p_id UUID) → JSON`

**Descripción**: Activa/desactiva tipo (soft delete)

**Criterios de Aceptación**: CA-008, CA-009, CA-010

**Reglas de negocio**:
- RN-003-005: Soft delete (no elimina físicamente)
- RN-003-007: Retorna cantidad de productos asociados
- RN-003-012: Registra auditoría (event_type='tipo_activated' o 'tipo_deactivated')

**Parámetros**:
- `p_id` (UUID): ID del tipo a activar/desactivar

**Response Success**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "nombre": "Ciclismo Pro",
    "descripcion": "Media profesional para ciclistas de competición",
    "codigo": "CIC",
    "imagen_url": null,
    "activo": false,
    "created_at": "2025-10-07T22:11:19.146155+00:00",
    "updated_at": "2025-10-07T22:11:38.425556+00:00",
    "productos_count": 30
  },
  "message": "Tipo desactivado exitosamente"
}
```

**Response Error Hints**:
- `tipo_not_found`: Tipo no existe

**Nota**: El campo `productos_count` es un placeholder hasta que exista la relación `tipo_id` en la tabla `productos`

#### 5. `get_tipo_detalle(p_id UUID) → JSON`

**Descripción**: Obtiene detalle completo del tipo con estadísticas de uso

**Criterios de Aceptación**: CA-012

**Reglas de negocio**:
- RN-003-010: Retorna estadísticas de uso (cantidad productos, lista de productos)

**Parámetros**:
- `p_id` (UUID): ID del tipo a consultar

**Response Success**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "nombre": "Ciclismo Pro",
    "descripcion": "Media profesional para ciclistas de competición",
    "codigo": "CIC",
    "imagen_url": null,
    "activo": false,
    "created_at": "2025-10-07T22:11:19.146155+00:00",
    "updated_at": "2025-10-07T22:11:38.425556+00:00",
    "productos_count": 30,
    "productos_list": [
      {"id": "uuid", "nombre": "Medias Deportivas Negras"},
      {"id": "uuid", "nombre": "Medias Ejecutivas Grises"}
    ]
  },
  "message": "Detalle del tipo obtenido exitosamente"
}
```

**Response Error Hints**:
- `tipo_not_found`: Tipo no existe

**Nota**: `productos_list` es un placeholder hasta que exista la relación `tipo_id` en la tabla `productos`

#### 6. `get_tipos_activos() → JSON`

**Descripción**: Lista solo tipos activos para formularios de productos

**Reglas de negocio**:
- RN-003-006: Solo tipos activos pueden asignarse a nuevos productos

**Parámetros**: Ninguno

**Response Success**:
```json
{
  "success": true,
  "data": [
    {"id": "uuid", "nombre": "Invisible", "codigo": "INV"},
    {"id": "uuid", "nombre": "Tobillera", "codigo": "TOB"}
  ],
  "message": "Tipos activos obtenidos"
}
```

### Reglas de Negocio Implementadas

- **RN-003-001**: Código único de tipo - Código debe ser único en todo el sistema, exactamente 3 letras mayúsculas (A-Z). Códigos existentes no se pueden reutilizar aunque el tipo esté inactivo.

- **RN-003-002**: Nombre único de tipo - Nombre debe ser único sin importar mayúsculas/minúsculas, máximo 50 caracteres. Al editar, validar que no coincida con otros tipos (excepto sí mismo).

- **RN-003-003**: Descripción e imagen opcionales - Descripción máximo 200 caracteres si se proporciona. Imagen JPG/PNG, máximo 500KB (validación futura en frontend).

- **RN-003-004**: Inmutabilidad del código - El código del tipo NO puede modificarse una vez creado. Sistema bloquea cambios al código para garantizar consistencia en SKUs.

- **RN-003-005**: Soft delete de tipos - Nunca eliminar físicamente tipos del sistema, solo cambiar estado a inactivo para preservar integridad referencial con productos existentes.

- **RN-003-006**: Tipo activo para nuevos productos - Solo tipos activos pueden asignarse a nuevos productos. Sistema debe filtrar tipos inactivos en selecciones (`get_tipos_activos()`).

- **RN-003-007**: Confirmación de desactivación - Sistema muestra cantidad de productos que usan el tipo al desactivar (advertencia: productos existentes no se ven afectados).

- **RN-003-009**: Búsqueda multicriterio - Búsqueda funciona en nombre, descripción y código simultáneamente. Filtrado en tiempo real.

- **RN-003-010**: Estadísticas de uso - Vista detallada muestra cantidad de productos que usan el tipo, fecha de creación, última modificación, imagen de referencia y lista de productos asociados.

- **RN-003-012**: Auditoría de cambios - Registrar quién, cuándo y qué cambió en la tabla `audit_logs` (event_type: tipo_created, tipo_updated, tipo_activated, tipo_deactivated).

### Datos Seed Insertados

Se insertaron 9 tipos de ejemplo del sector:

1. **Invisible (INV)** - Media muy baja, no visible con zapatos
2. **Tobillera (TOB)** - Media que llega al tobillo
3. **Media Caña (MCA)** - Media que llega a media pantorrilla
4. **Larga (LAR)** - Media que llega a la rodilla
5. **Fútbol (FUT)** - Media deportiva alta para fútbol
6. **Running (RUN)** - Media deportiva para correr
7. **Compresión (COM)** - Media con compresión gradual
8. **Ejecutiva (EJE)** - Media formal para uso ejecutivo
9. **Térmica (TER)** - Media para climas fríos

### Verificación Backend

- [x] Tabla `tipos` creada con todas las columnas y constraints
- [x] Índices creados correctamente
- [x] Trigger `update_tipos_updated_at` funcional
- [x] RLS policy `authenticated_view_tipos` activa
- [x] Migration aplicada sin errores (`npx supabase db reset`)
- [x] Función `get_tipos()` probada (búsqueda multicriterio funcional)
- [x] Función `create_tipo()` probada (validaciones correctas)
- [x] Función `update_tipo()` probada (código inmutable)
- [x] Función `toggle_tipo_activo()` probada (soft delete)
- [x] Función `get_tipo_detalle()` probada (estadísticas)
- [x] Función `get_tipos_activos()` probada (filtro activos)
- [x] Retornos JSON cumplen `00-CONVENTIONS.md` (success/error format)
- [x] Naming conventions aplicadas (snake_case tablas/columnas)
- [x] Error handling con patrón estándar (v_error_hint + EXCEPTION block)
- [x] Seed data insertado (9 tipos)
- [x] Constraint `audit_logs.event_type` actualizado con eventos de tipos

### Notas Backend

#### Cambios realizados:

1. **Tabla `tipos` agregada** a `00000000000003_catalog_tables.sql` siguiendo el mismo patrón que `marcas` y `materiales`.

2. **Constraint `audit_logs.event_type` actualizado** en `00000000000002_auth_tables.sql` para incluir:
   - `tipo_created`
   - `tipo_updated`
   - `tipo_activated`
   - `tipo_deactivated`

3. **6 funciones RPC implementadas** en `00000000000005_functions.sql` (SECCIÓN 6):
   - `get_tipos()` - Lista con búsqueda y filtros
   - `create_tipo()` - Crea con validaciones
   - `update_tipo()` - Actualiza (código inmutable)
   - `toggle_tipo_activo()` - Soft delete
   - `get_tipo_detalle()` - Vista detallada con estadísticas
   - `get_tipos_activos()` - Solo activos para formularios

4. **Seed data agregado** a `00000000000006_seed_data.sql` con 9 tipos del sector.

#### Placeholders futuros:

- **Relación `tipo_id` en tabla `productos`**: Actualmente las funciones cuentan todos los productos como placeholder. Cuando se agregue la columna `tipo_id` a la tabla `productos`, las funciones `toggle_tipo_activo()`, `get_tipo_detalle()` y validaciones relacionadas funcionarán correctamente con el JOIN real.

- **Validación de imágenes**: La validación de formato (JPG/PNG) y tamaño (500KB) de imágenes se implementará en el frontend. El backend solo almacena la URL.

- **Combinaciones lógicas de productos** (RN-003-014): Sistema de advertencia de combinaciones poco comunes (ej. "Fútbol + Invisible") se implementará cuando existan las relaciones completas entre catálogos y productos.

#### Decisiones técnicas:

- **Código inmutable**: Se implementó NO incluyendo `p_codigo` en los parámetros de `update_tipo()`, forzando la inmutabilidad a nivel de interfaz de función (RN-003-004).

- **Búsqueda case-insensitive**: Índice `idx_tipos_nombre ON LOWER(nombre)` permite búsqueda eficiente sin importar mayúsculas.

- **Soft delete**: Campo `activo` permite desactivar tipos sin perder integridad referencial con productos existentes (RN-003-005).

---

## UI (@ux-ui-expert)

**Estado**: ⏳ Pendiente

### Páginas a Crear

#### 1. `TiposListPage` → `/tipos`

**Descripción**: Página principal de gestión de tipos

**Criterios CA**: CA-001, CA-011

**Componentes**:
- Lista de tipos con estado visual (activo/inactivo)
- Buscador con filtrado en tiempo real
- Botones de acción por tipo (Editar, Activar/Desactivar, Ver Detalle)
- Contador total de tipos activos/inactivos
- Botón "Agregar Nuevo Tipo"

#### 2. `TipoFormPage` → `/tipos/nuevo` o `/tipos/:id/editar`

**Descripción**: Formulario crear/editar tipo

**Criterios CA**: CA-002, CA-003, CA-004, CA-005, CA-006, CA-007

**Componentes**:
- FormField: nombre (obligatorio, max 50 caracteres)
- FormField: descripción (opcional, max 200 caracteres)
- FormField: código (obligatorio, 3 letras mayúsculas) - **DESHABILITADO en edición**
- ImagePicker: imagen_url (opcional)
- Checkbox: activo (marcado por defecto)
- Botones: "Guardar" y "Cancelar"
- Validaciones en tiempo real
- Estados: Loading, Success, Error

#### 3. Modal `TipoDetalleModal`

**Descripción**: Vista detallada del tipo con estadísticas

**Criterios CA**: CA-012

**Componentes**:
- Información completa del tipo
- Imagen de referencia (si existe)
- Estadísticas de uso (cantidad de productos)
- Lista de productos que usan el tipo
- Fecha de creación y última modificación
- Botones: "Editar", "Activar/Desactivar", "Cerrar"

#### 4. Modal `ConfirmarDesactivarModal`

**Descripción**: Confirmación antes de desactivar tipo

**Criterios CA**: CA-008, CA-009

**Componentes**:
- Mensaje: "¿Estás seguro de desactivar este tipo?"
- Advertencia: "Los productos existentes no se verán afectados"
- Información de productos asociados (X productos usan este tipo)
- Botones: "Confirmar" y "Cancelar"

### Rutas Configuradas

```dart
routes: {
  '/tipos': (context) => TiposListPage(),
  '/tipos/nuevo': (context) => TipoFormPage(mode: FormMode.create),
  '/tipos/:id/editar': (context) => TipoFormPage(mode: FormMode.edit),
}
```

### Design System Aplicado

- **Colores**: `Theme.of(context).colorScheme.primary`, `DesignColors.primaryTurquoise`
- **Spacing**: `DesignTokens.spacingSmall` (8px), `spacingMedium` (16px), `spacingLarge` (24px)
- **Typography**: `Theme.of(context).textTheme.titleLarge`, `bodyMedium`
- **Responsive**: Breakpoints Mobile (< 768px), Desktop (>= 768px)
- **Estados visuales**:
  - Activo: Badge verde con texto "Activo"
  - Inactivo: Badge gris con texto "Inactivo"

---

## Frontend (@flutter-expert)

**Estado**: ⏳ Pendiente

### Models a Crear

#### 1. `TipoModel` (lib/features/catalogos/data/models/tipo_model.dart)

**Propiedades**:
- `id` (String) - Mapping: `id`
- `nombre` (String) - Mapping: `nombre`
- `descripcion` (String?) - Mapping: `descripcion`
- `codigo` (String) - Mapping: `codigo`
- `imagenUrl` (String?) - Mapping: `imagen_url`
- `activo` (bool) - Mapping: `activo`
- `createdAt` (DateTime) - Mapping: `created_at`
- `updatedAt` (DateTime) - Mapping: `updated_at`
- `productosCount` (int?) - Mapping: `productos_count` (opcional, solo en detalle/toggle)

**Métodos**: `fromJson()`, `toJson()`, `copyWith()`

**Extends**: Equatable

#### 2. `CreateTipoRequest`

**Propiedades**:
- `nombre` (String)
- `descripcion` (String?)
- `codigo` (String)
- `imagenUrl` (String?)
- `activo` (bool)

#### 3. `UpdateTipoRequest`

**Propiedades**:
- `id` (String)
- `nombre` (String)
- `descripcion` (String?)
- `activo` (bool)

### DataSource Methods (lib/features/catalogos/data/datasources/catalogos_remote_datasource.dart)

#### 1. `getTipos({String? search, bool? activoFilter}) → Future<List<TipoModel>>`

**Descripción**: Obtiene lista de tipos con filtros

**Llama RPC**: `get_tipos(p_search, p_activo_filter)`

**Retorno**: `List<TipoModel>`

**Excepciones**: `ServerException` (HTTP 4xx/5xx)

#### 2. `createTipo(CreateTipoRequest request) → Future<TipoModel>`

**Descripción**: Crea nuevo tipo

**Llama RPC**: `create_tipo(p_nombre, p_descripcion, p_codigo, p_imagen_url, p_activo)`

**Retorno**: `TipoModel`

**Excepciones**:
- `DuplicateNameException` (hint: duplicate_nombre)
- `DuplicateCodeException` (hint: duplicate_codigo)
- `ValidationException` (hint: invalid_*)
- `ServerException` (otros errores)

#### 3. `updateTipo(UpdateTipoRequest request) → Future<TipoModel>`

**Descripción**: Actualiza tipo existente

**Llama RPC**: `update_tipo(p_id, p_nombre, p_descripcion, p_activo)`

**Retorno**: `TipoModel`

**Excepciones**:
- `NotFoundException` (hint: tipo_not_found)
- `DuplicateNameException` (hint: duplicate_nombre)
- `ValidationException` (hint: invalid_*)

#### 4. `toggleTipoActivo(String id) → Future<TipoModel>`

**Descripción**: Activa/desactiva tipo

**Llama RPC**: `toggle_tipo_activo(p_id)`

**Retorno**: `TipoModel` (con productos_count)

**Excepciones**: `NotFoundException` (hint: tipo_not_found)

#### 5. `getTipoDetalle(String id) → Future<TipoModel>`

**Descripción**: Obtiene detalle completo con estadísticas

**Llama RPC**: `get_tipo_detalle(p_id)`

**Retorno**: `TipoModel` (con productos_count y productos_list)

**Excepciones**: `NotFoundException` (hint: tipo_not_found)

#### 6. `getTiposActivos() → Future<List<TipoModel>>`

**Descripción**: Obtiene solo tipos activos para formularios

**Llama RPC**: `get_tipos_activos()`

**Retorno**: `List<TipoModel>` (solo id, nombre, codigo)

### Repository Methods (lib/features/catalogos/data/repositories/catalogos_repository_impl.dart)

#### 1. `getTipos({String? search, bool? activoFilter}) → Future<Either<Failure, List<TipoModel>>>`

**Llama**: `remoteDataSource.getTipos(search, activoFilter)`

**Retorno Left**: `ServerFailure`, `NetworkFailure`

**Retorno Right**: `List<TipoModel>`

#### 2. `createTipo(CreateTipoRequest request) → Future<Either<Failure, TipoModel>>`

**Llama**: `remoteDataSource.createTipo(request)`

**Retorno Left**: `ValidationFailure`, `DuplicateFailure`, `ServerFailure`

**Retorno Right**: `TipoModel`

#### 3. `updateTipo(UpdateTipoRequest request) → Future<Either<Failure, TipoModel>>`

**Llama**: `remoteDataSource.updateTipo(request)`

**Retorno Left**: `ValidationFailure`, `NotFoundFailure`, `DuplicateFailure`

**Retorno Right**: `TipoModel`

#### 4. `toggleTipoActivo(String id) → Future<Either<Failure, TipoModel>>`

**Llama**: `remoteDataSource.toggleTipoActivo(id)`

**Retorno Left**: `NotFoundFailure`, `ServerFailure`

**Retorno Right**: `TipoModel`

#### 5. `getTipoDetalle(String id) → Future<Either<Failure, TipoModel>>`

**Llama**: `remoteDataSource.getTipoDetalle(id)`

**Retorno Left**: `NotFoundFailure`, `ServerFailure`

**Retorno Right**: `TipoModel`

#### 6. `getTiposActivos() → Future<Either<Failure, List<TipoModel>>>`

**Llama**: `remoteDataSource.getTiposActivos()`

**Retorno Left**: `ServerFailure`

**Retorno Right**: `List<TipoModel>`

### Bloc (lib/features/catalogos/presentation/bloc/tipos/)

#### Estados (tipos_state.dart)

- `TiposInitial` - Estado inicial
- `TiposLoading` - Cargando operación
- `TiposLoaded` - Lista cargada (data: List<TipoModel>)
- `TipoCreated` - Tipo creado exitosamente (data: TipoModel)
- `TipoUpdated` - Tipo actualizado (data: TipoModel)
- `TipoToggled` - Tipo activado/desactivado (data: TipoModel)
- `TipoDetalleLoaded` - Detalle cargado (data: TipoModel)
- `TiposActivosLoaded` - Solo activos (data: List<TipoModel>)
- `TiposError` - Error en operación (message: String)

#### Eventos (tipos_event.dart)

- `LoadTipos` - Cargar lista (search, activoFilter)
- `CreateTipo` - Crear nuevo (request: CreateTipoRequest)
- `UpdateTipo` - Actualizar existente (request: UpdateTipoRequest)
- `ToggleTipoActivo` - Activar/desactivar (id: String)
- `LoadTipoDetalle` - Cargar detalle (id: String)
- `LoadTiposActivos` - Cargar solo activos

#### Handlers (tipos_bloc.dart)

**`_onLoadTipos`**:
1. Emit TiposLoading
2. Llama repository.getTipos(search, activoFilter)
3. Si success: Emit TiposLoaded(tipos)
4. Si failure: Emit TiposError(message)

**`_onCreateTipo`**:
1. Emit TiposLoading
2. Llama repository.createTipo(request)
3. Si success: Emit TipoCreated(tipo)
4. Si failure: Emit TiposError(message con hint específico)

**`_onUpdateTipo`**:
1. Emit TiposLoading
2. Llama repository.updateTipo(request)
3. Si success: Emit TipoUpdated(tipo)
4. Si failure: Emit TiposError(message)

**`_onToggleTipoActivo`**:
1. Emit TiposLoading
2. Llama repository.toggleTipoActivo(id)
3. Si success: Emit TipoToggled(tipo con productos_count)
4. Si failure: Emit TiposError(message)

**`_onLoadTipoDetalle`**:
1. Emit TiposLoading
2. Llama repository.getTipoDetalle(id)
3. Si success: Emit TipoDetalleLoaded(tipo)
4. Si failure: Emit TiposError(message)

**`_onLoadTiposActivos`**:
1. Emit TiposLoading
2. Llama repository.getTiposActivos()
3. Si success: Emit TiposActivosLoaded(tipos)
4. Si failure: Emit TiposError(message)

---

## QA (@qa-testing-expert)

**Estado**: ⏳ Pendiente

### Validación Convenciones

- [ ] **Naming**: snake_case (BD), camelCase (Dart), PascalCase (clases)
- [ ] **Routing**: Flat sin prefijos (`/tipos` ✅, `/catalogos/tipos` ❌)
- [ ] **Error Handling**: Patrón estándar JSON con success/error
- [ ] **API Response**: Formato correcto según `00-CONVENTIONS.md`
- [ ] **Design System**: Theme.of(context) usado (sin hardcoded)
- [ ] **Mapping**: Explícito snake_case ↔ camelCase en Models

### Validación Técnica

- [ ] Compilación: `flutter analyze` sin errores
- [ ] Integración: Backend ↔ Frontend funcional
- [ ] UI: Responsive (mobile + desktop)
- [ ] Navegación: Rutas funcionan correctamente
- [ ] Estados Bloc: Loading/Success/Error se muestran
- [ ] Manejo de errores: Mensajes claros al usuario

### Validación Criterios de Aceptación

- [ ] **CA-001**: Visualizar lista de tipos con nombre, descripción, código, estado
- [ ] **CA-002**: Formulario agregar con todos los campos
- [ ] **CA-003**: Validaciones de nombre, código, descripción
- [ ] **CA-004**: Crear tipo exitosamente
- [ ] **CA-005**: Formulario editar con código deshabilitado
- [ ] **CA-006**: Validaciones de edición (nombre único)
- [ ] **CA-007**: Actualizar tipo exitosamente
- [ ] **CA-008**: Modal confirmación al desactivar con advertencia
- [ ] **CA-009**: Desactivar tipo (soft delete)
- [ ] **CA-010**: Reactivar tipo inactivo
- [ ] **CA-011**: Búsqueda multicriterio por nombre/descripción/código
- [ ] **CA-012**: Vista detallada con estadísticas de uso
- [ ] **CA-013**: Validación combinaciones lógicas (futuro)

### Bugs Encontrados

[Si hay errores, listarlos aquí con detalle]

### Resultado QA

- ⏳ **Pendiente validación** - Backend completado, esperando UI y Frontend

---

## Resumen Final

**Estado HU**: 🔄 Backend Completado - Pendiente UI/Frontend/QA

### Checklist General

- [x] Backend implementado y verificado
- [ ] UI implementada y verificada
- [ ] Frontend implementado e integrado
- [ ] QA validó y aprobó
- [ ] Criterios de aceptación cumplidos
- [x] Convenciones backend aplicadas correctamente
- [x] Documentación actualizada

### Próximos Pasos

1. **@ux-ui-expert**: Implementar `TiposListPage`, `TipoFormPage`, modales de confirmación y detalle
2. **@flutter-expert**: Implementar Models, DataSource, Repository, Bloc completo
3. **@qa-testing-expert**: Validar integración E2E y todos los criterios de aceptación

---

**Última actualización**: 2025-10-07 17:15 (hora local)
**Actualizado por**: @supabase-expert
