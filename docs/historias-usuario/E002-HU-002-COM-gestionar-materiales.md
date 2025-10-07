# E002-HU-006: Gestionar Catálogo de Materiales

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E002-HU-002
- **Épica**: E002 - Gestión de Productos de Medias
- **Título**: Gestionar Catálogo de Materiales
- **Story Points**: 4 pts
- **Estado**: ✅ Completada

## 🎯 HISTORIA DE USUARIO
**Como** administrador del sistema de medias
**Quiero** gestionar el catálogo de materiales con códigos únicos y descripciones
**Para** clasificar productos por su composición textil y generar SKUs consistentes

## ✅ CRITERIOS DE ACEPTACIÓN

### CA-001: Visualizar Lista de Materiales ✅
- [x] **DADO** que soy admin autenticado
- [x] **CUANDO** accedo a la sección "Catálogos > Materiales"
- [x] **ENTONCES** debo ver:
  - [x] Lista de materiales con: nombre, descripción, código, estado (activo/inactivo)
  - [x] Botón "Agregar Nuevo Material"
  - [x] Botones de acciones: Editar, Activar/Desactivar
  - [x] Contador total de materiales activos/inactivos
  - [x] Buscador por nombre, descripción o código

### CA-002: Agregar Nuevo Material ✅
- [x] **DADO** que quiero agregar un material
- [x] **CUANDO** presiono "Agregar Nuevo Material"
- [x] **ENTONCES** debo ver formulario con:
  - [x] Campo "Nombre" (obligatorio, máx 50 caracteres)
  - [x] Campo "Descripción" (opcional, máx 200 caracteres)
  - [x] Campo "Código" (obligatorio, 3 caracteres, solo letras mayúsculas)
  - [x] Checkbox "Activo" (marcado por defecto)
  - [x] Botones "Guardar" y "Cancelar"

### CA-003: Validaciones de Nuevo Material ✅
- [x] **DADO** que estoy creando un material
- [x] **CUANDO** dejo el nombre vacío
- [x] **ENTONCES** debo ver "Nombre es requerido"
- [x] **CUANDO** dejo el código vacío
- [x] **ENTONCES** debo ver "Código es requerido"
- [x] **CUANDO** ingreso código con menos de 3 caracteres
- [x] **ENTONCES** debo ver "Código debe tener exactamente 3 letras"
- [x] **CUANDO** ingreso código con números o símbolos
- [x] **ENTONCES** debo ver "Código solo puede contener letras mayúsculas"
- [x] **CUANDO** ingreso código ya existente
- [x] **ENTONCES** debo ver "Este código ya existe, ingresa otro"
- [x] **CUANDO** ingreso descripción de más de 200 caracteres
- [x] **ENTONCES** debo ver "Descripción máximo 200 caracteres"

### CA-004: Crear Material Exitosamente ✅
- [x] **DADO** que completo el formulario correctamente
- [x] **CUANDO** presiono "Guardar"
- [x] **ENTONCES** el sistema debe:
  - [x] Crear el material en la base de datos
  - [x] Mostrar mensaje "Material creado exitosamente"
  - [x] Volver a la lista de materiales
  - [x] Mostrar el nuevo material en la lista

### CA-005: Editar Material Existente ✅
- [x] **DADO** que quiero modificar un material
- [x] **CUANDO** presiono "Editar" en un material
- [x] **ENTONCES** debo ver:
  - [x] Formulario prellenado con datos actuales
  - [x] Campo código deshabilitado (no se puede cambiar)
  - [x] Posibilidad de cambiar nombre, descripción y estado
  - [x] Botones "Actualizar" y "Cancelar"

### CA-006: Validación de Edición ✅
- [x] **DADO** que estoy editando un material
- [x] **CUANDO** dejo el nombre vacío
- [x] **ENTONCES** debo ver "Nombre es requerido"
- [x] **CUANDO** ingreso nombre que ya existe en otro material
- [x] **ENTONCES** debo ver "Ya existe un material con este nombre"
- [x] **CUANDO** ingreso descripción de más de 200 caracteres
- [x] **ENTONCES** debo ver "Descripción máximo 200 caracteres"

### CA-007: Actualizar Material Exitosamente ✅
- [x] **DADO** que modifico un material correctamente
- [x] **CUANDO** presiono "Actualizar"
- [x] **ENTONCES** el sistema debe:
  - [x] Actualizar los datos en la base de datos
  - [x] Mostrar mensaje "Material actualizado exitosamente"
  - [x] Volver a la lista con datos actualizados

### CA-008: Desactivar Material ✅
- [x] **DADO** que quiero desactivar un material
- [x] **CUANDO** presiono "Desactivar" en un material activo
- [x] **ENTONCES** debo ver:
  - [x] Modal de confirmación "¿Estás seguro de desactivar este material?"
  - [x] Advertencia "Los productos existentes no se verán afectados"
  - [x] Información de productos asociados si los hay
  - [x] Botones "Confirmar" y "Cancelar"

### CA-009: Confirmar Desactivación ✅
- [x] **DADO** que confirmo la desactivación
- [x] **CUANDO** presiono "Confirmar"
- [x] **ENTONCES** el sistema debe:
  - [x] Marcar el material como inactivo (no eliminar)
  - [x] Mostrar mensaje "Material desactivado exitosamente"
  - [x] Actualizar la lista mostrando estado inactivo
  - [x] El material no aparece en selecciones para nuevos productos

### CA-010: Reactivar Material ✅
- [x] **DADO** que quiero reactivar un material inactivo
- [x] **CUANDO** presiono "Activar" en un material inactivo
- [x] **ENTONCES** el sistema debe:
  - [x] Marcar el material como activo
  - [x] Mostrar mensaje "Material reactivado exitosamente"
  - [x] El material vuelve a estar disponible para nuevos productos

### CA-011: Búsqueda de Materiales ✅
- [x] **DADO** que quiero buscar un material específico
- [x] **CUANDO** escribo en el campo de búsqueda
- [x] **ENTONCES** debo ver:
  - [x] Filtrado en tiempo real por nombre, descripción o código
  - [x] Resultados actualizados al escribir
  - [x] Mensaje "No se encontraron materiales" si no hay coincidencias
  - [x] Opción de limpiar búsqueda

### CA-012: Vista Detallada de Material ✅
- [x] **DADO** que quiero ver detalles de un material
- [x] **CUANDO** hago clic en el nombre del material
- [x] **ENTONCES** debo ver:
  - [x] Modal con información completa del material
  - [x] Lista de productos que usan este material
  - [x] Fecha de creación y última modificación
  - [x] Estadísticas de uso (cantidad de productos)

## 📋 ESTADOS DE IMPLEMENTACIÓN

### Backend (Supabase)
- [x] **COMPLETADO** - Tabla `materiales`:
  - [x] id (UUID, PRIMARY KEY)
  - [x] nombre (TEXT, NOT NULL, UNIQUE)
  - [x] descripcion (TEXT, NULLABLE)
  - [x] codigo (TEXT, NOT NULL, UNIQUE, LENGTH=3)
  - [x] activo (BOOLEAN, DEFAULT true)
  - [x] created_at (TIMESTAMP)
  - [x] updated_at (TIMESTAMP)

- [x] **COMPLETADO** - RPC Functions `catalogos/materiales`:
  - [x] listar_materiales() - Listar todos los materiales
  - [x] crear_material() - Crear nuevo material
  - [x] actualizar_material() - Actualizar material
  - [x] toggle_material_activo() - Activar/desactivar material
  - [x] buscar_materiales() - Buscar materiales
  - [x] obtener_detalle_material() - Ver detalle de material

- [x] **COMPLETADO** - Validaciones backend:
  - [x] Código único, 3 letras mayúsculas
  - [x] Nombre único, máximo 50 caracteres
  - [x] Descripción máximo 200 caracteres
  - [x] Solo admin puede gestionar materiales

### Frontend (Flutter)
- [x] **COMPLETADO** - MaterialesListPage:
  - [x] Lista de materiales con estado visual
  - [x] Buscador con filtrado en tiempo real
  - [x] Botones de acción por material
  - [x] Vista detallada en modal

- [x] **COMPLETADO** - MaterialFormPage:
  - [x] Formulario crear/editar material
  - [x] Validaciones en tiempo real
  - [x] Campo descripción opcional
  - [x] Manejo de estados (loading, success, error)

- [x] **COMPLETADO** - MaterialesBloc:
  - [x] Estados para gestión de materiales
  - [x] Eventos CRUD completos
  - [x] Integración con Repository

### UX/UI
- [x] **COMPLETADO** - Materiales Components:
  - [x] MaterialCard con descripción expandible
  - [x] MaterialForm responsive con descripción
  - [x] Estados visuales (activo/inactivo)
  - [x] Modal de detalles con estadísticas
  - [x] Feedback visual para acciones

### QA
- [x] **COMPLETADO** - Tests todos los criterios:
  - [x] CRUD completo de materiales
  - [x] Validaciones de nombre, código y descripción
  - [x] Búsqueda y filtrado avanzado
  - [x] Activar/desactivar materiales
  - [x] Vista detallada y estadísticas

## 📐 REGLAS DE NEGOCIO (RN)

### RN-002-001: Código Único de Material
**Contexto**: Al crear un nuevo material
**Restricción**: No pueden existir dos materiales con el mismo código
**Validación**: Código debe ser único en todo el sistema
**Formato**: Exactamente 3 letras mayúsculas (A-Z)
**Caso especial**: Códigos existentes no se pueden reutilizar aunque el material esté inactivo

### RN-002-002: Nombre Único de Material
**Contexto**: Al crear o editar un material
**Restricción**: No pueden existir dos materiales con el mismo nombre
**Validación**: Nombre debe ser único sin importar mayúsculas/minúsculas
**Longitud**: Máximo 50 caracteres
**Caso especial**: Al editar, validar que no coincida con otros materiales (excepto sí mismo)

### RN-002-003: Descripción Opcional
**Contexto**: Al crear o editar un material
**Restricción**: La descripción es opcional pero si se proporciona tiene límite
**Validación**: Si se ingresa, máximo 200 caracteres
**Caso especial**: Puede quedar vacía o null sin afectar funcionalidad

### RN-002-004: Inmutabilidad del Código
**Contexto**: Al editar un material existente
**Restricción**: El código del material NO puede modificarse una vez creado
**Validación**: Sistema debe bloquear cambios al código
**Razón**: Garantizar consistencia en SKUs y trazabilidad de productos
**Caso especial**: Ninguno - regla absoluta sin excepciones

### RN-002-005: Soft Delete de Materiales
**Contexto**: Al desactivar un material
**Restricción**: Nunca eliminar físicamente materiales del sistema
**Validación**: Solo cambiar estado a inactivo
**Razón**: Preservar integridad referencial con productos existentes
**Caso especial**: Productos creados con material inactivo mantienen su referencia

### RN-002-006: Material Activo para Nuevos Productos
**Contexto**: Al crear un nuevo producto
**Restricción**: Solo materiales activos pueden asignarse a nuevos productos
**Validación**: Sistema debe filtrar materiales inactivos en selecciones
**Caso especial**: Productos existentes mantienen materiales aunque se desactiven después

### RN-002-007: Confirmación de Desactivación
**Contexto**: Al desactivar un material
**Validación**: Sistema debe mostrar advertencia y solicitar confirmación
**Información requerida**: Cantidad de productos que usan el material
**Advertencia**: "Los productos existentes no se verán afectados"
**Caso especial**: Si material no tiene productos asociados, advertencia es más simple

### RN-002-008: Reactivación Libre
**Contexto**: Al reactivar un material inactivo
**Restricción**: Ninguna - materiales inactivos pueden reactivarse sin restricciones
**Validación**: Verificar que código y nombre sigan siendo únicos
**Efecto**: Material vuelve a estar disponible inmediatamente para nuevos productos

### RN-002-009: Búsqueda Multicriterio
**Contexto**: Al buscar materiales en el catálogo
**Validación**: Búsqueda debe funcionar en nombre, descripción y código simultáneamente
**Comportamiento**: Filtrado en tiempo real mientras se escribe
**Caso especial**: Búsqueda vacía muestra todos los materiales

### RN-002-010: Estadísticas de Uso
**Contexto**: Al ver detalles de un material
**Información requerida**: Cantidad de productos que usan el material
**Validación**: Mostrar fecha de creación y última modificación
**Caso especial**: Si material no tiene productos, mostrar "Sin productos asociados"

### RN-002-011: Control de Acceso a Gestión
**Contexto**: Al intentar acceder a gestión de materiales
**Restricción**: Solo usuarios con rol ADMIN pueden gestionar catálogo
**Validación**: Verificar rol antes de permitir crear, editar o desactivar
**Caso especial**: Usuarios no admin no deben ver opciones de gestión

### RN-002-012: Auditoría de Cambios
**Contexto**: Al crear, modificar o desactivar materiales
**Validación**: Registrar quién hizo el cambio, cuándo y qué cambió
**Información a guardar**: Usuario, fecha/hora, acción realizada, valores anteriores
**Razón**: Trazabilidad de cambios en catálogos maestros

## ✅ DEFINICIÓN DE TERMINADO (DoD)
- [x] Todos los criterios de aceptación cumplidos ✅
- [x] CRUD completo de materiales implementado ✅
- [x] Validaciones frontend y backend funcionando ✅
- [x] Solo admin puede gestionar catálogo ✅
- [x] Códigos únicos de 3 letras generados correctamente ✅
- [x] Campo descripción opcional implementado ✅
- [x] Búsqueda por múltiples campos ✅
- [x] Vista detallada con estadísticas de uso ✅
- [x] QA validó todos los flujos ✅
- [x] Documentación actualizada ✅

**📄 Documentación de implementación**: [E002-HU-002_IMPLEMENTATION.md](../technical/implemented/E002-HU-002_IMPLEMENTATION.md)

## 🔗 DEPENDENCIAS
- **E002-HU-005**: Gestionar Catálogo de Marcas (patrón establecido)

## 🧵 EJEMPLOS DE MATERIALES DEL SECTOR
```
Nombre: "Algodón"          → Código: "ALG" → Descripción: "Fibra natural transpirable"
Nombre: "Nylon"            → Código: "NYL" → Descripción: "Fibra sintética resistente"
Nombre: "Bambú"            → Código: "BAM" → Descripción: "Fibra ecológica antibacterial"
Nombre: "Microfibra"       → Código: "MIC" → Descripción: "Fibra sintética ultra suave"
Nombre: "Lana Merino"      → Código: "MER" → Descripción: "Lana natural termorreguladora"
Nombre: "Poliéster"        → Código: "POL" → Descripción: "Fibra sintética duradera"
Nombre: "Lycra"            → Código: "LYC" → Descripción: "Fibra elástica para ajuste"
Nombre: "Seda"             → Código: "SED" → Descripción: "Fibra natural de lujo"
```

## 🔐 RESTRICCIONES DE SEGURIDAD
- **Solo ADMIN** puede acceder a gestión de materiales
- **Códigos inmutables** una vez creados (para consistencia de SKU)
- **Soft delete** - nunca eliminar, solo desactivar
- **Auditoría** de cambios en catálogos maestros
- **Validación** de combinaciones lógicas en productos