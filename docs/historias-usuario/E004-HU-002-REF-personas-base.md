# E004-HU-002: Gestión de Personas (Entidad Base)

## INFORMACIÓN
- **Código**: E004-HU-002
- **Épica**: E004 - Gestión de Personas y Roles
- **Título**: Gestión de Personas (Entidad Base)
- **Story Points**: 5 pts
- **Estado**: Completada (COM)
- **Fecha Inicio**: 2025-10-15
- **Fecha Finalización**: 2025-10-16

## HISTORIA
**Como** usuario del sistema (admin/gerente)
**Quiero** gestionar personas identificadas por documento
**Para** tener un registro único de todas las personas que interactúan en el negocio antes de asignarles roles específicos

### Criterios Aceptación

#### CA-001: Buscar Persona por Documento
- [ ] **DADO** que necesito registrar una persona
- [ ] **CUANDO** ingreso tipo de documento y número
- [ ] **ENTONCES** el sistema debe buscar si ya existe
- [ ] **Y** si existe, debe mostrar datos de la persona encontrada

#### CA-002: Crear Nueva Persona
- [ ] **DADO** que la persona no existe en el sistema
- [ ] **CUANDO** completo los datos (tipo documento, nro documento, tipo persona, nombre/razón social, email, celular, dirección)
- [ ] **ENTONCES** el sistema debe crear la persona
- [ ] **Y** debe estar disponible para asignarle roles

#### CA-003: Validar Documento Único
- [ ] **DADO** que intento crear una persona
- [ ] **CUANDO** el número de documento ya existe en el sistema
- [ ] **ENTONCES** debo ver mensaje "Ya existe una persona con este documento"
- [ ] **Y** debe mostrar opción "Ver persona existente"

#### CA-004: Validar Formato de Documento
- [ ] **DADO** que ingreso un número de documento
- [ ] **CUANDO** el formato no coincide con el tipo seleccionado (ej: DNI con letras)
- [ ] **ENTONCES** debo ver mensaje de error "Formato inválido para DNI. Debe tener 8 dígitos"
- [ ] **Y** no debe permitir guardar

#### CA-005: Diferenciar Persona Natural vs Jurídica
- [ ] **DADO** que creo una persona
- [ ] **CUANDO** selecciono tipo "Natural"
- [ ] **ENTONCES** debe solicitar campo "Nombre completo"
- [ ] **PERO CUANDO** selecciono tipo "Jurídica"
- [ ] **ENTONCES** debe solicitar campo "Razón social"

#### CA-006: Listar Personas Registradas
- [ ] **DADO** que accedo al módulo "Personas"
- [ ] **CUANDO** se carga la lista
- [ ] **ENTONCES** debo ver todas las personas con: tipo documento, nro documento, nombre/razón social, tipo persona, roles asignados y estado
- [ ] **Y** debe permitir filtrar por tipo de documento, tipo de persona y estado

#### CA-007: Editar Datos de Persona
- [ ] **DADO** que selecciono una persona existente
- [ ] **CUANDO** edito sus datos de contacto (email, celular, dirección)
- [ ] **ENTONCES** el sistema debe actualizar la información
- [ ] **PERO** no debe permitir cambiar tipo de documento ni número de documento

#### CA-008: Desactivar Persona con Validación
- [ ] **DADO** que intento desactivar una persona
- [ ] **CUANDO** tiene roles activos (cliente activo, proveedor activo)
- [ ] **ENTONCES** debo ver advertencia "Esta persona tiene roles activos. ¿Desactivarlos también?"
- [ ] **Y** debe permitir desactivar solo la persona o en cascada (persona + roles)

#### CA-009: Prevenir Eliminación con Transacciones
- [ ] **DADO** que intento eliminar una persona
- [ ] **CUANDO** tiene transacciones registradas (ventas, compras, entregas)
- [ ] **ENTONCES** debo ver mensaje "Esta persona tiene transacciones registradas. Solo puede desactivarse"
- [ ] **Y** no debe permitir eliminar

#### CA-010: Ver Resumen de Roles Asignados
- [ ] **DADO** que visualizo una persona
- [ ] **CUANDO** veo su detalle
- [ ] **ENTONCES** debo ver badge con cada rol asignado (Cliente, Proveedor, Transportista)
- [ ] **Y** debe indicar estado de cada rol (activo/inactivo)

## REGLAS DE NEGOCIO (RN)

### RN-047: Unicidad de Documento en el Sistema
**Contexto**: Al crear una nueva persona en el sistema
**Restricción**: No permitir duplicados de documento
**Validación**:
- Combinación tipo_documento + numero_documento debe ser única en todo el sistema
- Validación antes de crear la persona
- Búsqueda debe incluir personas activas e inactivas
- Si existe: mostrar datos de la persona encontrada
**Mensaje**: "Ya existe una persona con este documento"
**Caso especial**: Persona inactiva con mismo documento puede reactivarse en lugar de crear nueva

### RN-048: Inmutabilidad de Documento de Identidad
**Contexto**: Al editar datos de una persona existente
**Restricción**: Tipo y número de documento NO pueden modificarse
**Validación**:
- Tipo de documento es inmutable después de creación
- Número de documento es inmutable después de creación
- Solo datos de contacto y estado pueden editarse
**Razón**: Documento es identificador único permanente de la persona
**Caso especial**: Si requiere cambio de documento, crear nueva persona y desactivar anterior

### RN-049: Campos Según Tipo de Persona
**Contexto**: Al registrar o editar datos de una persona
**Restricción**: Campos obligatorios varían según tipo de persona
**Validación**:
- Persona Natural: nombre_completo es obligatorio, razon_social queda vacío
- Persona Jurídica: razon_social es obligatorio, nombre_completo queda vacío
- Tipo de persona es obligatorio (Natural o Jurídica)
**Caso especial**: No se permite dejar ambos campos vacíos o ambos llenos

### RN-050: Validación de Formato de Documento
**Contexto**: Al ingresar número de documento
**Restricción**: Aplicar validaciones del tipo de documento seleccionado
**Validación**:
- Utilizar función validar_formato_documento (RN-044 de E004-HU-001)
- Formato debe coincidir con tipo seleccionado
- Longitud debe estar en rango permitido
- Solo permitir caracteres válidos según formato
**Ejemplo**: DNI solo acepta 8 dígitos numéricos, RUC solo 11 dígitos numéricos
**Caso especial**: Validación en tiempo real al ingresar documento

### RN-051: Datos de Contacto Opcionales
**Contexto**: Al registrar una persona
**Restricción**: Definir datos obligatorios vs opcionales
**Validación**:
- Email: opcional, pero si se ingresa debe tener formato válido
- Celular: opcional, pero si se ingresa debe tener formato válido
- Dirección: opcional
- Teléfono fijo: opcional
**Caso especial**: Sistema debe funcionar sin datos de contacto, pero recomendar registrarlos

### RN-052: Formato de Email Válido
**Contexto**: Al ingresar email de contacto
**Restricción**: Validar estructura de correo electrónico
**Validación**:
- Debe contener @ y dominio
- No permitir espacios
- Formato estándar: usuario@dominio.extension
- Longitud máxima 100 caracteres
**Caso especial**: Email puede quedar vacío (opcional)

### RN-053: Formato de Celular Válido
**Contexto**: Al ingresar celular de contacto
**Restricción**: Validar formato de número celular
**Validación**:
- Solo dígitos numéricos
- Longitud 9 dígitos (Perú: 9XXXXXXXX)
- No permitir letras ni caracteres especiales
**Caso especial**: Celular puede quedar vacío (opcional), sistema preparado para formatos internacionales

### RN-054: Protección de Personas con Transacciones
**Contexto**: Al intentar eliminar una persona
**Restricción**: No eliminar personas que tienen historial de transacciones
**Validación**:
- Verificar si persona tiene ventas registradas
- Verificar si persona tiene compras registradas (como proveedor)
- Verificar si persona tiene entregas registradas (como transportista)
- Si tiene al menos 1 transacción: prohibir eliminación
**Mensaje**: "Esta persona tiene transacciones registradas. Solo puede desactivarse"
**Caso especial**: Persona sin transacciones puede eliminarse físicamente

### RN-055: Desactivación en Cascada de Roles
**Contexto**: Al desactivar una persona base
**Restricción**: Gestionar roles activos asociados
**Validación**:
- Detectar si persona tiene roles activos (cliente activo, proveedor activo, transportista activo)
- Si tiene roles activos: mostrar advertencia con opciones
- Opción 1: Desactivar solo la persona (roles quedan activos)
- Opción 2: Desactivar persona y todos sus roles en cascada
**Mensaje**: "Esta persona tiene roles activos. ¿Desactivarlos también?"
**Caso especial**: Si todos los roles ya están inactivos, desactivar persona directamente

### RN-056: Búsqueda por Documento Antes de Crear
**Contexto**: Al iniciar flujo de creación de persona
**Restricción**: Evitar duplicados mediante búsqueda previa
**Validación**:
- Usuario debe ingresar tipo y número de documento primero
- Sistema busca en base de datos existente
- Si NO existe: habilitar formulario de creación
- Si existe: mostrar datos de persona existente con opción "Ver detalle"
**Caso especial**: Usuario puede cancelar y ver persona existente en lugar de crear

### RN-057: Tipos de Documento Según Tipo de Persona
**Contexto**: Al seleccionar tipo de documento para una persona
**Restricción**: Validar coherencia entre tipo de persona y tipo de documento
**Validación**:
- Persona Natural: puede usar DNI, CE (Carnet Extranjería), Pasaporte
- Persona Jurídica: debe usar RUC
- Validación al seleccionar combinación
**Mensaje**: "RUC solo aplica para Persona Jurídica" o "Persona Jurídica debe usar RUC"
**Caso especial**: Persona Natural con negocio puede tener RUC en segunda persona vinculada

### RN-058: Listado con Filtros Multi-Criterio
**Contexto**: Al visualizar lista de personas
**Restricción**: Permitir filtrado flexible para encontrar personas
**Validación**:
- Filtro por tipo de documento (DNI, RUC, CE, etc.)
- Filtro por tipo de persona (Natural, Jurídica)
- Filtro por estado (Activo, Inactivo)
- Filtro por roles asignados (tiene cliente, tiene proveedor, etc.)
- Búsqueda por nombre/razón social/número de documento
**Caso especial**: Filtros deben combinarse (operador AND)

### RN-059: Visualización de Roles Asignados
**Contexto**: Al mostrar lista de personas o detalle de persona
**Restricción**: Indicar claramente qué roles tiene asignados
**Validación**:
- Mostrar badges con cada rol asignado
- Indicar estado de cada rol (activo/inactivo)
- Roles posibles: Cliente, Proveedor, Transportista
- Una persona puede tener 0, 1, 2 o 3 roles simultáneamente
**Caso especial**: Persona sin roles asignados debe mostrar indicador "Sin roles"

### RN-060: Reactivación de Persona Inactiva
**Contexto**: Al encontrar persona inactiva en búsqueda por documento
**Restricción**: Permitir reactivar en lugar de duplicar
**Validación**:
- Si persona existe pero está inactiva: mostrar opción "Reactivar persona"
- Reactivación restaura estado activo
- Roles previos permanecen en su estado (activo/inactivo)
- Datos de contacto pueden actualizarse al reactivar
**Caso especial**: Reactivación no afecta historial de transacciones

## CASOS DE USO ESPECÍFICOS DEL NEGOCIO

### CU-001: Registrar Cliente Natural (Consumidor Final)
**Escenario**: Vendedor registra cliente que compra para consumo personal
- Tipo Persona: Natural
- Tipo Documento: DNI
- Número Documento: 12345678 (8 dígitos)
- Nombre Completo: Juan Pérez García
- Email: juan.perez@gmail.com (opcional)
- Celular: 987654321 (opcional)
- Dirección: Av. Los Olivos 123, San Isidro (opcional)
- Estado: Activo
- **Resultado**: Persona creada, lista para asignar rol Cliente

### CU-002: Registrar Proveedor Jurídico (Empresa)
**Escenario**: Admin registra empresa proveedora de medias
- Tipo Persona: Jurídica
- Tipo Documento: RUC
- Número Documento: 20123456789 (11 dígitos)
- Razón Social: Textiles del Norte SAC
- Email: ventas@textilesnorte.com.pe
- Celular: 987123456 (representante)
- Dirección: Jr. Industrial 456, Los Olivos
- Estado: Activo
- **Resultado**: Persona creada, lista para asignar rol Proveedor

### CU-003: Evitar Duplicado al Registrar
**Escenario**: Gerente intenta registrar cliente que ya existe
1. Gerente ingresa: DNI 12345678
2. Sistema busca y encuentra persona existente: Juan Pérez García (ACTIVO, rol: Cliente)
3. Sistema muestra: "Ya existe una persona con este documento"
4. Sistema ofrece: botón "Ver persona existente"
5. **Resultado**: NO se crea duplicado, se usa persona existente

### CU-004: Editar Solo Datos de Contacto
**Escenario**: Cliente cambia número de celular
- Persona: Juan Pérez (DNI 12345678)
- Acción: Editar datos de contacto
- Permitido: cambiar email, celular, dirección
- **Bloqueado**: cambiar DNI o tipo de documento
- **Resultado**: Datos de contacto actualizados, documento inmutable

### CU-005: Desactivar Persona con Rol Activo
**Escenario**: Admin desactiva proveedor que dejó de trabajar con empresa
1. Persona: Textiles del Norte SAC (RUC 20123456789)
2. Tiene rol: Proveedor (ACTIVO)
3. Sistema pregunta: "Esta persona tiene roles activos. ¿Desactivarlos también?"
4. Admin selecciona: "Desactivar persona y roles"
5. **Resultado**: Persona INACTIVA, rol Proveedor INACTIVO

### CU-006: Prevenir Eliminación con Historial
**Escenario**: Gerente intenta eliminar cliente con compras
1. Persona: María López (DNI 87654321)
2. Tiene: 5 ventas registradas en el sistema
3. Sistema verifica transacciones: encuentra 5 ventas
4. Sistema bloquea eliminación
5. Sistema muestra: "Esta persona tiene transacciones registradas. Solo puede desactivarse"
6. **Resultado**: NO se elimina, solo opción de desactivar

### CU-007: Reactivar Persona Previamente Inactiva
**Escenario**: Proveedor que dejó de trabajar regresa
1. Admin busca: RUC 20999888777
2. Sistema encuentra: Distribuidora Central EIRL (INACTIVO)
3. Sistema muestra: datos de persona inactiva + botón "Reactivar"
4. Admin actualiza datos de contacto (nuevo email y celular)
5. Admin confirma reactivación
6. **Resultado**: Persona ACTIVA, datos actualizados, historial preservado

### CU-008: Persona con Múltiples Roles
**Escenario**: Transportista independiente también es cliente
1. Persona: Carlos Ruiz (DNI 11223344)
2. Inicialmente: rol Transportista (ACTIVO)
3. Posteriormente compra medias para su familia
4. Se le asigna: rol Cliente (ACTIVO)
5. Lista muestra: badges "Cliente" y "Transportista" ambos activos
6. **Resultado**: 1 persona con 2 roles activos, historial unificado

## NOTAS
HU define QUÉ desde perspectiva usuario. Detalles técnicos (tabla personas, campos, índices, constraints) los definen agentes especializados.

**Relación con E004-HU-001**: Utiliza tipos de documento configurados en catálogo, aplica validaciones RN-044 (formato documento)

---

## FASE 2: Diseño Backend
**Responsable**: supabase-expert
**Status**: Completado
**Fecha**: 2025-10-16

### Esquema de Base de Datos

#### Tablas Creadas

**`personas`** (00000000000003_catalog_tables.sql):
- **Columnas**: id (UUID PK), tipo_documento_id (FK), numero_documento, tipo_persona (ENUM), nombre_completo, razon_social, email, celular, telefono, direccion, activo, created_at, updated_at
- **ENUM**: tipo_persona_enum ('Natural', 'Juridica')
- **Constraints**:
  - UNIQUE (tipo_documento_id, numero_documento) - RN-047
  - CHECK tipo_persona + nombre/razón social - RN-049
  - CHECK email format - RN-052
  - CHECK celular format (9 dígitos) - RN-053
- **Índices**: tipo_documento, numero_documento, tipo_persona, email, activo, nombre_completo, razon_social
- **RLS**: Habilitado con policy SELECT para usuarios autenticados

### Funciones RPC Implementadas

CONTRATO DE API PARA flutter-expert y ux-ui-expert:

**`buscar_persona_por_documento(p_tipo_documento_id UUID, p_numero_documento TEXT) → JSON`**
- **Descripción**: Busca persona existente por tipo y número de documento (activos E inactivos)
- **Reglas de Negocio**: RN-047, RN-056
- **Parámetros**:
  - `p_tipo_documento_id`: UUID - ID del tipo de documento (obligatorio)
  - `p_numero_documento`: TEXT - Número de documento (obligatorio)
- **Request ejemplo**:
  ```json
  {"p_tipo_documento_id": "uuid-dni", "p_numero_documento": "12345678"}
  ```
- **Response Success**:
  ```json
  {
    "success": true,
    "data": {
      "id": "uuid",
      "tipo_documento_id": "uuid",
      "numero_documento": "12345678",
      "tipo_persona": "Natural",
      "nombre_completo": "Juan Pérez García",
      "razon_social": null,
      "email": "juan@test.com",
      "celular": "987654321",
      "telefono": null,
      "direccion": "Av. Los Olivos 123",
      "activo": true,
      "roles": [],
      "created_at": "2025-10-16T00:00:00Z",
      "updated_at": "2025-10-16T00:00:00Z"
    },
    "message": "Persona encontrada"
  }
  ```
- **Response Error - Hints específicos**:
  - `not_found` → 404 - Persona no existe
  - `missing_param` → 400 - Parámetro faltante

**`crear_persona(p_tipo_documento_id UUID, p_numero_documento TEXT, p_tipo_persona TEXT, p_nombre_completo TEXT, p_razon_social TEXT, p_email TEXT, p_celular TEXT, p_telefono TEXT, p_direccion TEXT) → JSON`**
- **Descripción**: Crea nueva persona con validaciones completas de RN
- **Reglas de Negocio**: RN-047, RN-048, RN-049, RN-050, RN-051, RN-052, RN-053, RN-057
- **Parámetros**:
  - `p_tipo_documento_id`: UUID - ID del tipo de documento (obligatorio)
  - `p_numero_documento`: TEXT - Número de documento (obligatorio)
  - `p_tipo_persona`: TEXT - 'Natural' o 'Juridica' (obligatorio)
  - `p_nombre_completo`: TEXT - Nombre completo si Natural (condicional)
  - `p_razon_social`: TEXT - Razón social si Jurídica (condicional)
  - `p_email`: TEXT - Email válido (opcional)
  - `p_celular`: TEXT - Celular 9 dígitos (opcional)
  - `p_telefono`: TEXT - Teléfono fijo (opcional)
  - `p_direccion`: TEXT - Dirección (opcional)
- **Response Success**: Persona creada con roles vacíos
- **Response Error - Hints específicos**:
  - `duplicate_document` → 409 - Documento ya existe
  - `invalid_document_format` → 400 - Formato documento inválido
  - `invalid_document_for_person_type` → 400 - Incoherencia tipo persona/documento
  - `missing_nombre` → 400 - Falta nombre para Natural
  - `missing_razon_social` → 400 - Falta razón social para Jurídica
  - `invalid_email` → 400 - Formato email inválido
  - `invalid_phone` → 400 - Celular no tiene 9 dígitos

**`listar_personas(p_tipo_documento_id UUID, p_tipo_persona TEXT, p_activo BOOLEAN, p_busqueda TEXT, p_limit INT, p_offset INT) → JSON`**
- **Descripción**: Lista personas con filtros multi-criterio y paginación
- **Reglas de Negocio**: RN-058, RN-059
- **Parámetros**: Todos opcionales excepto limit/offset
- **Response Success**:
  ```json
  {
    "success": true,
    "data": {
      "items": [...],
      "total": 10,
      "limit": 50,
      "offset": 0,
      "has_more": false
    }
  }
  ```

**`obtener_persona(p_persona_id UUID) → JSON`**
- **Descripción**: Obtiene detalle completo de persona con roles
- **Reglas de Negocio**: RN-059
- **Hints**: `not_found` → 404

**`editar_persona(p_persona_id UUID, p_email TEXT, p_celular TEXT, p_telefono TEXT, p_direccion TEXT) → JSON`**
- **Descripción**: Edita SOLO datos de contacto (documento es inmutable)
- **Reglas de Negocio**: RN-048, RN-052, RN-053
- **Hints**: `not_found` → 404, `invalid_email`, `invalid_phone`

**`desactivar_persona(p_persona_id UUID, p_desactivar_roles BOOLEAN) → JSON`**
- **Descripción**: Desactiva persona con opción de desactivar roles en cascada
- **Reglas de Negocio**: RN-055
- **Nota**: Validación de roles activos pendiente para cuando se implementen tablas clientes/proveedores

**`eliminar_persona(p_persona_id UUID) → JSON`**
- **Descripción**: Elimina persona físicamente si no tiene transacciones
- **Reglas de Negocio**: RN-054
- **Nota**: Validación de transacciones pendiente para cuando se implementen tablas ventas/compras
- **Hints**: `has_transactions` → 403

**`reactivar_persona(p_persona_id UUID, p_email TEXT, p_celular TEXT, p_telefono TEXT, p_direccion TEXT) → JSON`**
- **Descripción**: Reactiva persona inactiva y actualiza datos de contacto
- **Reglas de Negocio**: RN-060
- **Hints**: `not_found` → 404, `already_active` → 400

**Mapping Backend → Dart**:
- `tipo_documento_id` → `tipoDocumentoId`
- `numero_documento` → `numeroDocumento`
- `tipo_persona` → `tipoPersona` (enum: Natural/Juridica)
- `nombre_completo` → `nombreCompleto`
- `razon_social` → `razonSocial`
- `created_at` → `createdAt` (DateTime)
- `updated_at` → `updatedAt` (DateTime)

### Archivos Modificados
- `supabase/migrations/00000000000003_catalog_tables.sql` - Tabla personas + ENUM
- `supabase/migrations/00000000000005_functions.sql` - 8 funciones RPC

### Criterios de Aceptación Backend
- [x] **CA-001**: Implementado en `buscar_persona_por_documento()`
- [x] **CA-002**: Implementado en `crear_persona()`
- [x] **CA-003**: Validado con constraint UNIQUE y hint `duplicate_document`
- [x] **CA-004**: Validado usando `validar_formato_documento()` de HU-001
- [x] **CA-005**: Validado con CHECK constraint y validación en función
- [x] **CA-006**: Implementado en `listar_personas()` con filtros combinables
- [x] **CA-007**: Implementado en `editar_persona()` con RN-048
- [x] **CA-008**: Implementado en `desactivar_persona()` con parámetro cascada
- [x] **CA-009**: Implementado en `eliminar_persona()` (validación pendiente para tablas transaccionales)
- [x] **CA-010**: Implementado en `obtener_persona()` con campo roles (actualmente vacío)

### Reglas de Negocio Implementadas
- **RN-047**: Constraint UNIQUE (tipo_documento_id, numero_documento)
- **RN-048**: Validación en `editar_persona()` - documento inmutable
- **RN-049**: CHECK constraint tipo_persona + nombre/razón + validación en función
- **RN-050**: Llamada a `validar_formato_documento()` de HU-001
- **RN-051**: Parámetros opcionales con validación solo si se proporcionan
- **RN-052**: CHECK constraint + validación regex en función
- **RN-053**: CHECK constraint + validación 9 dígitos en función
- **RN-054**: Preparado en `eliminar_persona()` (verificación pendiente)
- **RN-055**: Implementado en `desactivar_persona()` con parámetro boolean
- **RN-056**: Implementado en `buscar_persona_por_documento()`
- **RN-057**: Validación cruzada tipo_persona/tipo_documento en `crear_persona()`
- **RN-058**: Filtros combinables con AND en `listar_personas()`
- **RN-059**: Campo roles en todas las respuestas (actualmente array vacío)
- **RN-060**: Implementado en `reactivar_persona()`

### Verificación
- [x] Migrations aplicadas con `db reset`
- [x] 8 funciones RPC creadas y testeadas
- [x] Convenciones 00-CONVENTIONS.md aplicadas
- [x] JSON response format estándar (success/error/hint)
- [x] RLS policy configurado
- [x] Validaciones completas con hints específicos
- [x] Pruebas manuales: crear Natural/Jurídica, validar duplicados, editar, desactivar, reactivar, eliminar

### Notas de Implementación
- TODO: Agregar consulta de roles en funciones cuando se implementen tablas clientes/proveedores/transportistas
- TODO: Agregar validación de transacciones en `eliminar_persona()` cuando se implementen tablas ventas/compras
- TODO: Agregar validación de roles activos en `desactivar_persona()` cuando se implementen tablas de roles
- Los campos `roles` actualmente retornan array vacío `[]` hasta que se implementen las tablas de roles específicos

---
## FASE 4: Implementación Frontend
**Responsable**: flutter-expert
**Status**: Completado
**Fecha**: 2025-10-16

### Estructura Clean Architecture

**Domain** (`lib/features/personas/domain/`):
- `entities/persona.dart`: Entidad inmutable con Equatable
  - Enum `TipoPersona`: valores(`natural`, `juridica`)
    - Métodos: `.toBackendString()`, `.fromString(String)`
- `repositories/persona_repository.dart`: Interface abstracta con 8 métodos

**Models** (`lib/features/personas/data/models/`):
- `persona_model.dart`: Mapping snake_case ↔ camelCase
  - `tipo_documento_id` → `tipoDocumentoId`
  - `numero_documento` → `numeroDocumento`
  - `tipo_persona` → `tipoPersona`
  - `nombre_completo` → `nombreCompleto`
  - `razon_social` → `razonSocial`
  - `created_at` → `createdAt`
  - `updated_at` → `updatedAt`

**DataSources** (`lib/features/personas/data/datasources/`):
- `persona_remote_datasource.dart`: 8 métodos RPC
  - Hints mapeados a excepciones:
    - `duplicate_document` → DuplicatePersonaException
    - `invalid_document_format` → InvalidDocumentFormatException
    - `invalid_document_for_person_type` → InvalidDocumentForPersonTypeException
    - `missing_nombre` → MissingNombreException
    - `missing_razon_social` → MissingRazonSocialException
    - `invalid_email` → InvalidEmailException
    - `invalid_phone` → InvalidPhoneException
    - `not_found` → PersonaNotFoundException
    - `has_transactions` → HasTransactionsException
    - `already_active` → AlreadyActiveException

**Repositories** (`lib/features/personas/data/repositories/`):
- `persona_repository_impl.dart`: Either<Failure, T> pattern
  - Mapea excepciones a Failures correspondientes

**Bloc** (`lib/features/personas/presentation/bloc/`):
- `persona_bloc.dart`: 8 handlers de eventos
- `persona_event.dart`: 8 eventos (Buscar, Crear, Listar, Obtener, Editar, Desactivar, Eliminar, Reactivar)
- `persona_state.dart`: Estados (Initial, Loading, Success, ListSuccess, DeleteSuccess, Error)

**UseCases** (`lib/features/personas/domain/usecases/`):
- `buscar_persona_por_documento.dart`
- `crear_persona.dart`
- `listar_personas.dart`
- `obtener_persona.dart`
- `editar_persona.dart`
- `desactivar_persona.dart`
- `eliminar_persona.dart`
- `reactivar_persona.dart`

**Excepciones** (`lib/core/error/exceptions.dart`):
- 10 excepciones custom agregadas para E004-HU-002
- Mapeo 1:1 con hints del backend

**Failures** (`lib/core/error/failures.dart`):
- 10 failures agregados para E004-HU-002
- Mensajes amigables para UI

**Dependency Injection** (`lib/core/injection/injection_container.dart`):
- PersonaBloc registrado como factory
- 8 UseCases registrados como lazy singletons
- PersonaRepository registrado como lazy singleton
- PersonaRemoteDataSource registrado como lazy singleton

### Integración Backend
```
UI → Bloc → UseCase → Repository → DataSource → RPC → Backend
↑                                                          ↓
└──────────────── Success/Error Response ←─────────────────┘
```

**Funciones RPC Integradas**:
- `buscar_persona_por_documento`: Búsqueda por tipo y número documento
- `crear_persona`: Creación con validaciones completas
- `listar_personas`: Lista con filtros multi-criterio y paginación
- `obtener_persona`: Obtener detalle con roles
- `editar_persona`: Edición solo datos de contacto (documento inmutable)
- `desactivar_persona`: Desactivación con opción cascada roles
- `eliminar_persona`: Eliminación con validación transacciones
- `reactivar_persona`: Reactivación con actualización datos contacto

### Criterios de Aceptación Frontend
- [x] **CA-001**: BuscarPersonaPorDocumento UseCase + Evento + Handler
- [x] **CA-002**: CrearPersona UseCase + Validaciones en Repository
- [x] **CA-003**: DuplicatePersonaException mapeado a DuplicatePersonaFailure
- [x] **CA-004**: InvalidDocumentFormatException con mensaje específico
- [x] **CA-005**: TipoPersona enum con lógica Natural/Jurídica
- [x] **CA-006**: ListarPersonas UseCase con filtros opcionales
- [x] **CA-007**: EditarPersona UseCase + Documento inmutable en params
- [x] **CA-008**: DesactivarPersona UseCase con parámetro desactivarRoles
- [x] **CA-009**: HasTransactionsException mapeado a HasTransactionsFailure
- [x] **CA-010**: Campo roles en Persona entity (array dinámico)

### Patrón Bloc Aplicado
- **Estructura**: 8 eventos → 8 handlers → Either pattern → Estados específicos
- **Estados**: Loading (spinner pendiente UI), Success (persona única), ListSuccess (lista con paginación), DeleteSuccess (confirmación), Error (mensaje)
- **Consistency**: Patrón Either<Failure, T> en todos los métodos repository

### Verificación
- [x] `flutter analyze lib/features/personas`: 0 issues
- [x] Mapping explícito snake_case ↔ camelCase en PersonaModel
- [x] 10 excepciones + 10 failures agregados
- [x] Either pattern en repository con manejo completo excepciones
- [x] 8 UseCases con params classes Equatable
- [x] Bloc con 8 handlers + cast correcto List<Persona>
- [x] Dependency injection completo (Bloc, UseCases, Repository, DataSource)

### Reglas de Negocio Integradas
- **RN-047**: Validación unicidad documento en CrearPersona
- **RN-048**: Documento inmutable en EditarPersona (solo contacto editable)
- **RN-049**: Validación campos según TipoPersona enum
- **RN-050**: Formato documento validado en backend (hints específicos)
- **RN-051**: Datos contacto opcionales (nullables en params)
- **RN-052**: Formato email validado en backend
- **RN-053**: Formato celular validado en backend (9 dígitos)
- **RN-054**: Protección eliminación con transacciones (HasTransactionsException)
- **RN-055**: Desactivación cascada con parámetro booleano
- **RN-056**: BuscarPersonaPorDocumento antes de crear
- **RN-057**: Validación coherencia tipo persona/documento en backend
- **RN-058**: Filtros multi-criterio en ListarPersonas
- **RN-059**: Campo roles en todas las responses (actualmente vacío)
- **RN-060**: ReactivarPersona con actualización datos contacto

### Issues Resueltos
- Cast correcto de `List<dynamic>` a `List<Persona>` en ListarPersonas handler
- Import Persona entity en persona_bloc.dart
- Excepciones custom con parámetros opcionales mensaje y statusCode

---

## FASE 5: Diseño UX/UI
**Responsable**: ux-ui-expert
**Status**: Completado
**Fecha**: 2025-10-16

### Componentes UI Diseñados

#### Páginas
- `personas_list_page.dart`: Lista principal con filtros multi-criterio, búsqueda, paginación y acciones
- `persona_form_page.dart`: Formulario con 2 modos (crear/editar), flujo de búsqueda previa y validaciones locales
- `persona_detail_page.dart`: Detalle completo con información de persona, roles asignados y acciones

#### Widgets Reutilizables
- `buscar_persona_widget.dart`: Widget de búsqueda standalone (CA-001, RN-056)
- `persona_tipo_chip.dart`: Badge para tipo persona (Natural/Jurídica) con iconos y colores distintivos
- `roles_badges_widget.dart`: Badges horizontales de roles asignados con estado (CA-010, RN-059)
- `confirm_desactivar_dialog.dart`: Dialog para desactivación con opción cascada (CA-008, RN-055)
- `confirm_eliminar_dialog.dart`: Dialog para validación de eliminación o advertencia si tiene transacciones (CA-009, RN-054)

#### Rutas Configuradas (Routing Flat)
- `/personas`: Lista de personas con filtros
- `/personas-form`: Formulario crear/editar (mode query param)
- `/personas-detail`: Detalle de persona (arguments: personaId)

### Funcionalidad UI Implementada

**PersonasListPage**:
- **Responsive**: Desktop (DataTable), Mobile (Cards con ListTile)
- **Filtros**:
  - Tipo Documento (DropdownMenu integrado con TipoDocumentoBloc)
  - Tipo Persona (Chips: Todos/Natural/Jurídica)
  - Estado (Chips: Activos/Inactivos)
  - Búsqueda (TextField con debounce en onChange)
- **Acciones por fila**: Ver, Editar, Desactivar, Eliminar
- **Paginación**: Botones Anterior/Siguiente con estado deshabilitado
- **Estados**: Loading (CircularProgressIndicator), Empty (mensaje motivacional), Success (tabla/lista)
- **Counter**: Chip con total de personas encontradas

**PersonaFormPage**:
- **Modo Crear**:
  - Paso 1 (Búsqueda Obligatoria - RN-056):
    * BuscarPersonaWidget integrado
    * Si existe persona activa: Card info + botón "Ver Persona Existente"
    * Si existe persona inactiva: Card info + botón "Reactivar Persona"
    * Si NO existe: Habilitar Paso 2
  - Paso 2 (Datos Completos):
    * Radio buttons Tipo Persona (Natural/Jurídica)
    * Campos condicionales (nombreCompleto si Natural, razonSocial si Jurídica)
    * Campos opcionales: Email, Celular (9 dígitos), Teléfono, Dirección (multiline)
    * Validaciones locales en tiempo real (regex email, 9 dígitos celular)
    * Botones Cancelar/Guardar
- **Modo Editar (RN-048)**:
  - Tipo y Número Documento: Mostrados pero disabled (inmutables)
  - Solo permite editar: Email, Celular, Teléfono, Dirección
  - Carga datos existentes con ObtenerPersonaEvent
  - Botones Cancelar/Guardar Cambios
- **Responsive**: Desktop (max-width 800px centrado), Mobile (full-width)

**PersonaDetailPage**:
- **Layout**:
  - Header con avatar circular (icono persona/empresa según tipo)
  - Nombre/Razón Social (título grande)
  - Chips: Tipo Persona + Estado (Activo/Inactivo)
  - Info detallada con iconos: Tipo Doc, Nro Doc, Email, Celular, Teléfono, Dirección
  - Sección Roles Asignados con RolesBadgesWidget
  - Fechas creación y última actualización (formato DD/MM/YYYY HH:mm)
- **Card de Acciones**:
  - Editar Datos de Contacto (icon info blue)
  - Desactivar Persona (icon warning orange) / Reactivar (icon success green)
  - Eliminar Persona (icon error red)
- **Responsive**: Desktop (max-width 900px centrado), Mobile (full-width)

**BuscarPersonaWidget**:
- Integración con TipoDocumentoBloc para dropdown de tipos activos
- Input Número Documento
- Botón Buscar con disabled state (requiere tipo y número)
- Loading state con CircularProgressIndicator + mensaje
- Success state: Callback onPersonaFound con entidad Persona
- Not found state: Banner verde "Persona no encontrada. Puedes proceder" + callback onPersonaNotFound

**ConfirmDesactivarDialog**:
- Detección automática de roles activos (props: hasRolesActivos)
- Si tiene roles activos:
  * Radio buttons: "Desactivar solo persona" / "Desactivar persona y roles"
  * Warning banner naranja con explicación
- Botones: Cancelar / Desactivar (color warning)
- Callback: onConfirm(bool desactivar, bool desactivarRoles)

**ConfirmEliminarDialog**:
- Validación de transacciones (props: hasTransacciones)
- Si tiene transacciones:
  * Warning banner naranja "No se puede eliminar"
  * Botón único: "Entendido" (cierra dialog)
- Si NO tiene transacciones:
  * Error banner rojo "Acción irreversible"
  * Botones: Cancelar / Eliminar (color error)
- Callback: onConfirm()

### Design System Aplicado

**Colores (DesignColors)**:
- primary: Turquesa #4ECDC4
- success: Verde #4CAF50 (activo, success messages)
- warning: Naranja #FFC107 (desactivar, advertencias)
- error: Rojo #F44336 (eliminar, errores)
- info: Azul #2196F3 (persona natural)
- accent: Violeta #6366F1 (persona jurídica)
- disabled: Gris #9CA3AF (inactivo, sin roles)
- backgroundLight: #F9FAFB

**Spacing (DesignSpacing)**:
- xs: 4px, sm: 8px, md: 16px, lg: 24px, xl: 32px

**Radius (DesignRadius)**:
- xs: 4px (chips pequeños), sm: 8px (cards), md: 12px (dialogs), full: 9999px (chips circulares)

**Typography (DesignTypography)**:
- fontXs: 12px (timestamps), fontSm: 14px (subtítulos), fontMd: 16px, fontLg: 18px, fontXl: 20px, font2xl: 24px (títulos), font3xl: 30px (headers)

**Breakpoints (DesignBreakpoints)**:
- mobile: <768px, desktop: ≥1200px
- Helpers: `DesignBreakpoints.isDesktop(context)`, `isMobile(context)`

### Criterios de Aceptación UI Cubiertos

- [x] **CA-001**: BuscarPersonaWidget con integración TipoDocumentoBloc + PersonaBloc
- [x] **CA-002**: PersonaFormPage Paso 2 con todos los campos y validaciones locales
- [x] **CA-003**: BuscarPersonaWidget muestra card info + botón "Ver Persona Existente" si persona activa encontrada
- [x] **CA-004**: Validaciones formato en PersonaFormPage (regex email, 9 dígitos celular, feedback inline)
- [x] **CA-005**: Radio buttons Tipo Persona + campos condicionales (nombreCompleto/razonSocial)
- [x] **CA-006**: PersonasListPage con DataTable/Cards responsive + filtros multi-criterio (tipo doc, tipo persona, estado, búsqueda)
- [x] **CA-007**: PersonaFormPage modo edit con campos contacto editables y documento disabled (inmutable)
- [x] **CA-008**: ConfirmDesactivarDialog con radio buttons para desactivación cascada
- [x] **CA-009**: ConfirmEliminarDialog con validación hasTransacciones y mensaje bloqueante
- [x] **CA-010**: RolesBadgesWidget con badges por rol + indicador estado (activo verde/inactivo gris) y "Sin roles" si vacío

### Reglas de Negocio UI Aplicadas

- **RN-047**: BuscarPersonaWidget valida duplicados antes de habilitar Paso 2
- **RN-048**: PersonaFormPage modo edit bloquea tipo y número documento (TextField disabled)
- **RN-049**: Radio buttons Natural/Jurídica con campos condicionales y validación obligatoria
- **RN-051**: Campos Email/Celular/Teléfono/Dirección marcados como opcionales (sin asterisco rojo)
- **RN-052**: Validación regex email en PersonaFormPage (_validarEmail)
- **RN-053**: Validación 9 dígitos celular en PersonaFormPage (_validarCelular) + maxLength: 9
- **RN-054**: ConfirmEliminarDialog muestra banner bloqueante si hasTransacciones
- **RN-055**: ConfirmDesactivarDialog con opción "desactivar solo persona" o "desactivar persona y roles"
- **RN-056**: PersonaFormPage fuerza búsqueda antes de crear (Paso 1 obligatorio)
- **RN-058**: PersonasListPage combina filtros con operador AND (tipoDocId + tipoPersona + activo + búsqueda)
- **RN-059**: RolesBadgesWidget muestra badges con estado y badge "Sin roles" si vacío
- **RN-060**: BuscarPersonaWidget muestra botón "Reactivar Persona" si persona inactiva encontrada

### Verificación

- [x] Responsive verificado en 375px (mobile), 1200px (desktop)
- [x] Sin overflow warnings (SingleChildScrollView en formularios, Expanded en textos)
- [x] Design System aplicado (sin colores hardcoded, uso de DesignColors/DesignSpacing/DesignRadius)
- [x] Componentes consistentes (patrón BlocProvider → BlocConsumer → Scaffold)
- [x] Routing flat configurado (/personas, /personas-form, /personas-detail)
- [x] Validaciones locales con feedback inline (errores en rojo debajo de campos)
- [x] Loading states (CircularProgressIndicator centrado)
- [x] Empty states (iconos grandes + mensajes motivacionales)
- [x] SnackBars para feedback success/error (verde/rojo, bordes redondeados, floating)
- [x] Dialogs con scroll interno (ConstrainedBox + maxHeight 50% viewport)

### Flujos Principales Implementados

**Flujo CU-001: Registrar Cliente Natural**:
1. Usuario entra a `/personas` → PersonasListPage
2. Click FAB "Nueva Persona" → `/personas-form`
3. Paso 1: Seleccionar "DNI" + Ingresar "12345678" + Click "Buscar"
4. Sistema busca → No encontrada → Habilita Paso 2
5. Seleccionar "Natural" → Campo "Nombre Completo" habilitado
6. Ingresar datos: Nombre, Email, Celular
7. Click "Guardar" → Validaciones locales pass → dispatch CrearPersonaEvent
8. Success → SnackBar verde + Navegación a `/personas-detail`

**Flujo CU-003: Evitar Duplicado**:
1. Paso 1 en `/personas-form`
2. Ingresar DNI existente + Click "Buscar"
3. Sistema encuentra persona → BuscarPersonaWidget muestra card info
4. Card con datos persona + estado + botón "Ver Persona Existente"
5. Click botón → Navegación a `/personas-detail` con personaId

**Flujo CU-004: Editar Solo Contacto**:
1. En `/personas-detail`, click "Editar Datos de Contacto"
2. Navegación a `/personas-form?mode=edit&personaId=xxx`
3. dispatch ObtenerPersonaEvent → carga datos
4. Formulario muestra campos contacto editables
5. Tipo/Nro Documento mostrados pero disabled (inmutables)
6. Modificar Email/Celular → Click "Guardar Cambios"
7. dispatch EditarPersonaEvent (solo campos editables)
8. Success → SnackBar + Navegación a detalle

**Flujo CU-005: Desactivar con Rol Activo**:
1. En PersonasListPage o PersonaDetailPage, click "Desactivar"
2. showDialog ConfirmDesactivarDialog con hasRolesActivos: true
3. Dialog muestra radio buttons con opciones cascada
4. Usuario selecciona "Desactivar persona y roles"
5. Click "Desactivar" → dispatch DesactivarPersonaEvent(desactivarRoles: true)
6. Success → SnackBar + Recarga lista

### Wireframe ASCII (PersonasListPage Desktop)

```
┌────────────────────────────────────────────────────────────────┐
│ HEADER: "Gestión de Personas" + Subtítulo                    │
├────────────────────────────────────────────────────────────────┤
│ [Búsqueda TextField                            ] [Filtros]    │
│ [Tipo Doc ▼] [Todos] [Natural] [Jurídica] [Activos]          │
├────────────────────────────────────────────────────────────────┤
│ Chip: "10 personas encontradas"                               │
├────────────────────────────────────────────────────────────────┤
│ DataTable                                                      │
│ ┌──────┬────────┬──────────────┬────────┬────────┬──────────┐ │
│ │Tipo  │Nro Doc │Nombre        │Tipo    │Roles   │Acciones  │ │
│ ├──────┼────────┼──────────────┼────────┼────────┼──────────┤ │
│ │ DNI  │12345678│Juan Pérez    │Natural │Cliente │👁 ✏ 🚫 ❌│ │
│ │ RUC  │2012345 │Textiles SAC  │Juridica│Proveedo│👁 ✏ 🚫 ❌│ │
│ └──────┴────────┴──────────────┴────────┴────────┴──────────┘ │
├────────────────────────────────────────────────────────────────┤
│ [< Anterior]  Página 1  [Siguiente >]                         │
└────────────────────────────────────────────────────────────────┘
                                    [FAB: + Nueva Persona]
```

### Issues Conocidos (Lints)

- 50+ lints de `prefer_const_constructors` (no afectan funcionalidad)
- 0 errores críticos en `flutter analyze lib/features/personas`
- Todos los lints son optimizaciones de performance (const widgets)

---
