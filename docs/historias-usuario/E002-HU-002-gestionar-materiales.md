# E002-HU-006: Gestionar Catálogo de Materiales

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E002-HU-006
- **Épica**: E002 - Gestión de Productos de Medias
- **Título**: Gestionar Catálogo de Materiales
- **Story Points**: 4 pts
- **Estado**: ⚪ Pendiente

## 🎯 HISTORIA DE USUARIO
**Como** administrador del sistema de medias
**Quiero** gestionar el catálogo de materiales con códigos únicos y descripciones
**Para** clasificar productos por su composición textil y generar SKUs consistentes

## ✅ CRITERIOS DE ACEPTACIÓN

### CA-001: Visualizar Lista de Materiales
- [ ] **DADO** que soy admin autenticado
- [ ] **CUANDO** accedo a la sección "Catálogos > Materiales"
- [ ] **ENTONCES** debo ver:
  - [ ] Lista de materiales con: nombre, descripción, código, estado (activo/inactivo)
  - [ ] Botón "Agregar Nuevo Material"
  - [ ] Botones de acciones: Editar, Activar/Desactivar
  - [ ] Contador total de materiales activos/inactivos
  - [ ] Buscador por nombre, descripción o código

### CA-002: Agregar Nuevo Material
- [ ] **DADO** que quiero agregar un material
- [ ] **CUANDO** presiono "Agregar Nuevo Material"
- [ ] **ENTONCES** debo ver formulario con:
  - [ ] Campo "Nombre" (obligatorio, máx 50 caracteres)
  - [ ] Campo "Descripción" (opcional, máx 200 caracteres)
  - [ ] Campo "Código" (obligatorio, 3 caracteres, solo letras mayúsculas)
  - [ ] Checkbox "Activo" (marcado por defecto)
  - [ ] Botones "Guardar" y "Cancelar"

### CA-003: Validaciones de Nuevo Material
- [ ] **DADO** que estoy creando un material
- [ ] **CUANDO** dejo el nombre vacío
- [ ] **ENTONCES** debo ver "Nombre es requerido"
- [ ] **CUANDO** dejo el código vacío
- [ ] **ENTONCES** debo ver "Código es requerido"
- [ ] **CUANDO** ingreso código con menos de 3 caracteres
- [ ] **ENTONCES** debo ver "Código debe tener exactamente 3 letras"
- [ ] **CUANDO** ingreso código con números o símbolos
- [ ] **ENTONCES** debo ver "Código solo puede contener letras mayúsculas"
- [ ] **CUANDO** ingreso código ya existente
- [ ] **ENTONCES** debo ver "Este código ya existe, ingresa otro"
- [ ] **CUANDO** ingreso descripción de más de 200 caracteres
- [ ] **ENTONCES** debo ver "Descripción máximo 200 caracteres"

### CA-004: Crear Material Exitosamente
- [ ] **DADO** que completo el formulario correctamente
- [ ] **CUANDO** presiono "Guardar"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Crear el material en la base de datos
  - [ ] Mostrar mensaje "Material creado exitosamente"
  - [ ] Volver a la lista de materiales
  - [ ] Mostrar el nuevo material en la lista

### CA-005: Editar Material Existente
- [ ] **DADO** que quiero modificar un material
- [ ] **CUANDO** presiono "Editar" en un material
- [ ] **ENTONCES** debo ver:
  - [ ] Formulario prellenado con datos actuales
  - [ ] Campo código deshabilitado (no se puede cambiar)
  - [ ] Posibilidad de cambiar nombre, descripción y estado
  - [ ] Botones "Actualizar" y "Cancelar"

### CA-006: Validación de Edición
- [ ] **DADO** que estoy editando un material
- [ ] **CUANDO** dejo el nombre vacío
- [ ] **ENTONCES** debo ver "Nombre es requerido"
- [ ] **CUANDO** ingreso nombre que ya existe en otro material
- [ ] **ENTONCES** debo ver "Ya existe un material con este nombre"
- [ ] **CUANDO** ingreso descripción de más de 200 caracteres
- [ ] **ENTONCES** debo ver "Descripción máximo 200 caracteres"

### CA-007: Actualizar Material Exitosamente
- [ ] **DADO** que modifico un material correctamente
- [ ] **CUANDO** presiono "Actualizar"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Actualizar los datos en la base de datos
  - [ ] Mostrar mensaje "Material actualizado exitosamente"
  - [ ] Volver a la lista con datos actualizados

### CA-008: Desactivar Material
- [ ] **DADO** que quiero desactivar un material
- [ ] **CUANDO** presiono "Desactivar" en un material activo
- [ ] **ENTONCES** debo ver:
  - [ ] Modal de confirmación "¿Estás seguro de desactivar este material?"
  - [ ] Advertencia "Los productos existentes no se verán afectados"
  - [ ] Información de productos asociados si los hay
  - [ ] Botones "Confirmar" y "Cancelar"

### CA-009: Confirmar Desactivación
- [ ] **DADO** que confirmo la desactivación
- [ ] **CUANDO** presiono "Confirmar"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Marcar el material como inactivo (no eliminar)
  - [ ] Mostrar mensaje "Material desactivado exitosamente"
  - [ ] Actualizar la lista mostrando estado inactivo
  - [ ] El material no aparece en selecciones para nuevos productos

### CA-010: Reactivar Material
- [ ] **DADO** que quiero reactivar un material inactivo
- [ ] **CUANDO** presiono "Activar" en un material inactivo
- [ ] **ENTONCES** el sistema debe:
  - [ ] Marcar el material como activo
  - [ ] Mostrar mensaje "Material reactivado exitosamente"
  - [ ] El material vuelve a estar disponible para nuevos productos

### CA-011: Búsqueda de Materiales
- [ ] **DADO** que quiero buscar un material específico
- [ ] **CUANDO** escribo en el campo de búsqueda
- [ ] **ENTONCES** debo ver:
  - [ ] Filtrado en tiempo real por nombre, descripción o código
  - [ ] Resultados actualizados al escribir
  - [ ] Mensaje "No se encontraron materiales" si no hay coincidencias
  - [ ] Opción de limpiar búsqueda

### CA-012: Vista Detallada de Material
- [ ] **DADO** que quiero ver detalles de un material
- [ ] **CUANDO** hago clic en el nombre del material
- [ ] **ENTONCES** debo ver:
  - [ ] Modal con información completa del material
  - [ ] Lista de productos que usan este material
  - [ ] Fecha de creación y última modificación
  - [ ] Estadísticas de uso (cantidad de productos)

## 📋 ESTADOS DE IMPLEMENTACIÓN

### Backend (Supabase)
- [ ] **PENDIENTE** - Tabla `materiales`:
  - [ ] id (UUID, PRIMARY KEY)
  - [ ] nombre (TEXT, NOT NULL, UNIQUE)
  - [ ] descripcion (TEXT, NULLABLE)
  - [ ] codigo (TEXT, NOT NULL, UNIQUE, LENGTH=3)
  - [ ] activo (BOOLEAN, DEFAULT true)
  - [ ] created_at (TIMESTAMP)
  - [ ] updated_at (TIMESTAMP)

- [ ] **PENDIENTE** - Edge Function `catalogos/materiales`:
  - [ ] GET /materiales - Listar todos los materiales
  - [ ] POST /materiales - Crear nuevo material
  - [ ] PUT /materiales/:id - Actualizar material
  - [ ] PATCH /materiales/:id/toggle - Activar/desactivar material
  - [ ] GET /materiales/:id/productos - Productos que usan el material

- [ ] **PENDIENTE** - Validaciones backend:
  - [ ] Código único, 3 letras mayúsculas
  - [ ] Nombre único, máximo 50 caracteres
  - [ ] Descripción máximo 200 caracteres
  - [ ] Solo admin puede gestionar materiales

### Frontend (Flutter)
- [ ] **PENDIENTE** - MaterialesListPage:
  - [ ] Lista de materiales con estado visual
  - [ ] Buscador con filtrado en tiempo real
  - [ ] Botones de acción por material
  - [ ] Vista detallada en modal

- [ ] **PENDIENTE** - MaterialFormPage:
  - [ ] Formulario crear/editar material
  - [ ] Validaciones en tiempo real
  - [ ] Campo descripción opcional
  - [ ] Manejo de estados (loading, success, error)

- [ ] **PENDIENTE** - MaterialesBloc:
  - [ ] Estados para gestión de materiales
  - [ ] Eventos CRUD completos
  - [ ] Cache local de materiales activos

### UX/UI
- [ ] **PENDIENTE** - Materiales Components:
  - [ ] MaterialCard con descripción expandible
  - [ ] MaterialForm responsive con descripción
  - [ ] Estados visuales (activo/inactivo)
  - [ ] Modal de detalles con estadísticas
  - [ ] Feedback visual para acciones

### QA
- [ ] **PENDIENTE** - Tests todos los criterios:
  - [ ] CRUD completo de materiales
  - [ ] Validaciones de nombre, código y descripción
  - [ ] Búsqueda y filtrado avanzado
  - [ ] Activar/desactivar materiales
  - [ ] Vista detallada y estadísticas

## ✅ DEFINICIÓN DE TERMINADO (DoD)
- [ ] Todos los criterios de aceptación cumplidos
- [ ] CRUD completo de materiales implementado
- [ ] Validaciones frontend y backend funcionando
- [ ] Solo admin puede gestionar catálogo
- [ ] Códigos únicos de 3 letras generados correctamente
- [ ] Campo descripción opcional implementado
- [ ] Búsqueda por múltiples campos
- [ ] Vista detallada con estadísticas de uso
- [ ] QA valida todos los flujos
- [ ] Documentación actualizada

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