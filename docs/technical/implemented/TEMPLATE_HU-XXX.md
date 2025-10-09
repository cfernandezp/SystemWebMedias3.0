# HU-XXX Implementación

**Historia**: E001-HU-XXX - [Título HU]
**Fecha Inicio**: YYYY-MM-DD
**Estado General**: 🔄 En Progreso

---

## Backend (@supabase-expert)

**Estado**: ⏳ Pendiente | 🔄 En Progreso | ✅ Completado

### Migrations Aplicadas
- **Migration**: `YYYYMMDDHHMMSS_descripcion.sql`
- **Tablas creadas**:
  - `table_name` (columnas: id, column1, column2, created_at, updated_at)
  - Índices: `idx_table_name_column1`, `idx_table_name_column2`
  - Constraints: FK a otras tablas, UNIQUE, etc.

### Funciones RPC Implementadas

#### 1. `function_name(p_param1 TYPE, p_param2 TYPE) → JSON`
- **Descripción**: [Qué hace esta función]
- **Reglas de negocio**: RN-001, RN-002
- **Parámetros**:
  - `p_param1`: [descripción]
  - `p_param2`: [descripción]
- **Response Success**:
  ```json
  {
    "success": true,
    "data": {
      "field1": "value1",
      "field2": "value2"
    },
    "message": "Operación exitosa"
  }
  ```
- **Response Error**:
  ```json
  {
    "success": false,
    "error": {
      "code": "ERROR_CODE",
      "message": "Mensaje descriptivo",
      "hint": "hint_specific"
    }
  }
  ```

#### 2. `another_function(p_param TYPE) → JSON`
- **Descripción**: [Qué hace esta función]
- **Reglas de negocio**: RN-003
- [Similar estructura...]

### Criterios Aceptación Implementados
- **CA-001**: [Título CA] → Implementado en: [función/tabla/constraint]
- **CA-002**: [Título CA] → Implementado en: [función/tabla/constraint]

### Reglas Negocio Implementadas
- **RN-001**: [Título RN] → Cómo: [validación/constraint/lógica en SQL]
- **RN-002**: [Título RN] → Cómo: [validación/constraint/lógica en SQL]

### Verificación Backend
- [ ] TODOS los CA de HU implementados
- [ ] TODAS las RN de HU implementadas
- [ ] Migrations aplicadas sin errores
- [ ] Funciones RPC probadas
- [ ] JSON/naming/error handling según convenciones

### Notas Backend
[Cualquier consideración especial, decisiones técnicas, etc.]

---

## UI (@ux-ui-expert)

**Estado**: ⏳ Pendiente | 🔄 En Progreso | ✅ Completado

### Páginas Creadas

#### 1. `PageNamePage` → `/route-name`
- **Descripción**: [Qué hace esta página]
- **Criterios CA**: CA-001, CA-002
- **Componentes**:
  - FormField: email, password, etc.
  - Botones: "Acción Principal"
  - Estados: Loading, Success, Error

#### 2. `AnotherPage` → `/another-route`
- [Similar estructura...]

### Widgets Principales

#### 1. `WidgetName`
- **Descripción**: [Qué hace este widget]
- **Propiedades**: [propiedades principales]
- **Uso**: [dónde se usa]

#### 2. `AnotherWidget`
- [Similar estructura...]

### Rutas Configuradas
```dart
routes: {
  '/route-name': (context) => PageNamePage(),
  '/another-route': (context) => AnotherPage(),
}
```

### Design System Aplicado
- **Colores**: `Theme.of(context).colorScheme.primary`, `DesignColors.primaryTurquoise`
- **Spacing**: `DesignTokens.spacingSmall`, `spacingMedium`, `spacingLarge`
- **Typography**: `Theme.of(context).textTheme.titleLarge`
- **Responsive**: Breakpoints Mobile (< 600px), Desktop (>= 600px)

### Criterios Aceptación Cubiertos
- **CA-001**: [Título CA] → UI: [página/widget que lo cubre visualmente]
- **CA-002**: [Título CA] → UI: [página/widget que lo cubre visualmente]

### Verificación UI
- [ ] TODOS los CA de HU cubiertos en UI
- [ ] UI renderiza correctamente
- [ ] Sin colores hardcoded
- [ ] Routing flat aplicado
- [ ] Responsive funciona
- [ ] Estados loading/error visibles

### Notas UI
[Cualquier consideración especial, decisiones de diseño, etc.]

---

## Frontend (@flutter-expert)

**Estado**: ⏳ Pendiente | 🔄 En Progreso | ✅ Completado

### Models Creados

#### 1. `ModelName` (lib/features/feature/data/models/model_name.dart)
- **Propiedades**:
  - `id` (String)
  - `field1` (String) - Mapping: `field_1`
  - `field2` (DateTime) - Mapping: `field_2`
  - `createdAt` (DateTime) - Mapping: `created_at`
- **Métodos**: `fromJson()`, `toJson()`, `copyWith()`
- **Extends**: Equatable

#### 2. `RequestModel`
- [Similar estructura...]

#### 3. `ResponseModel`
- [Similar estructura...]

### DataSource Methods (lib/features/feature/data/datasources/remote_datasource.dart)

#### 1. `methodName(params) → Future<ResponseModel>`
- **Descripción**: [Qué hace este método]
- **Llama RPC**: `function_name(p_param1, p_param2)`
- **Parámetros**: [lista de parámetros]
- **Retorno**: `ResponseModel`
- **Excepciones**: `ServerException` (HTTP 4xx/5xx)

#### 2. `anotherMethod(params) → Future<AnotherModel>`
- [Similar estructura...]

### Repository Methods (lib/features/feature/data/repositories/repository_impl.dart)

#### 1. `methodName(params) → Future<Either<Failure, SuccessModel>>`
- **Descripción**: [Qué hace este método]
- **Llama**: `remoteDataSource.methodName()`
- **Retorno Left**: `ServerFailure` (en caso de error)
- **Retorno Right**: `SuccessModel` (en caso de éxito)

#### 2. `anotherMethod(params) → Future<Either<Failure, AnotherModel>>`
- [Similar estructura...]

### Bloc (lib/features/feature/presentation/bloc/)

#### Estados (state.dart)
- `StateInitial` - Estado inicial
- `StateLoading` - Cargando operación
- `StateSuccess` - Operación exitosa (data: Model)
- `StateError` - Error en operación (message: String)
- `StateAnotherSuccess` - [otro estado si aplica]

#### Eventos (event.dart)
- `EventDoSomething` - [descripción del evento]
- `EventDoAnotherThing` - [descripción del evento]

#### Handlers (bloc.dart)
- **`_onEventDoSomething`**:
  1. Emit StateLoading
  2. Llama repository.methodName()
  3. Si success: Emit StateSuccess(data)
  4. Si failure: Emit StateError(message)

- **`_onEventDoAnotherThing`**:
  - [Similar estructura...]

### Integración Completa
```
UI (Page) → Bloc (Event)
          ↓
Bloc → Repository → DataSource → RPC Function (Backend)
          ↓
DataSource → Model → Repository → Bloc (State)
          ↓
Bloc (State) → UI (rebuild)
```

### Criterios Aceptación Integrados
- **CA-001**: [Título CA] → Integrado en: [bloc/repository/datasource específico]
- **CA-002**: [Título CA] → Integrado en: [bloc/repository/datasource específico]

### Reglas Negocio Validadas
- **RN-001**: [Título RN] → Validado en: [datasource/repository con lógica]

### Verificación Frontend
- [ ] TODOS los CA de HU integrados end-to-end
- [ ] TODAS las RN de HU validadas en frontend
- [ ] Models con mapping explícito (snake_case ↔ camelCase)
- [ ] DataSource llama RPC correctas
- [ ] Repository Either<Failure, Success>
- [ ] Bloc estados correctos
- [ ] `flutter analyze` sin errores
- [ ] Flujo end-to-end funciona

### Notas Frontend
[Cualquier consideración especial, decisiones arquitectónicas, etc.]

---

## QA (@qa-testing-expert)

**Estado**: ⏳ Pendiente

### Validación Convenciones
- [ ] **Naming**: snake_case (BD), camelCase (Dart), PascalCase (clases)
- [ ] **Routing**: Flat sin prefijos (`/register` ✅, `/auth/register` ❌)
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
- [ ] **CA-001**: [Descripción y verificación]
- [ ] **CA-002**: [Descripción y verificación]
- [ ] **CA-003**: [Descripción y verificación]
- [ ] [Agregar todos los CA de la HU]

### Bugs Encontrados
[Si hay errores, listarlos aquí con detalle]

**Ejemplo**:
1. **Error**: [descripción del error]
   - **Agente responsable**: @supabase-expert | @ux-ui-expert | @flutter-expert
   - **Severidad**: Crítico | Alto | Medio | Bajo
   - **Cómo reproducir**: [pasos]
   - **Esperado**: [comportamiento esperado]
   - **Actual**: [comportamiento actual]

### Resultado QA
- ⏳ **Pendiente validación**
- ❌ **Rechazado** (ver bugs arriba)
- ✅ **Aprobado** - Todos los criterios cumplidos

---

## Resumen Final

**Estado HU**: ⏳ En Progreso | ✅ Completada | ❌ Bloqueada

### Checklist General
- [ ] Backend implementado y verificado
- [ ] UI implementada y verificada
- [ ] Frontend implementado e integrado
- [ ] QA validó y aprobó
- [ ] Criterios de aceptación cumplidos
- [ ] Convenciones aplicadas correctamente
- [ ] Documentación actualizada

### Lecciones Aprendidas
[Cualquier aprendizaje, mejora para siguientes HUs, etc.]

---

**Última actualización**: YYYY-MM-DD HH:MM
**Actualizado por**: @agente-nombre