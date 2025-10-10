# E002-HU-006: Crear Producto Maestro

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E002-HU-006
- **Épica**: E002 - Gestión de Productos de Medias
- **Título**: Crear Producto Maestro
- **Story Points**: 5 pts
- **Estado**: 🟢 Refinada
- **Fecha Creación**: 2025-10-10
- **Fecha Refinamiento**: 2025-10-10

## 🎯 HISTORIA DE USUARIO
**Como** administrador de la empresa de medias
**Quiero** crear productos maestros combinando catálogos base (marca, material, tipo, sistema de tallas)
**Para** definir modelos de productos sin asignar colores ni stock específico

## 🧦 CONTEXTO DEL NEGOCIO DE MEDIAS

### Concepto de Producto Maestro:
Un **producto maestro** es la definición base de un modelo de media que combina:
- Marca (ej: Adidas, Nike, Puma)
- Material (ej: Algodón, Microfibra, Bambú)
- Tipo (ej: Futbol, Invisible, Tobillera)
- Sistema de Tallas (ej: NÚMERO 35-36 a 43-44, ÚNICA, LETRA)

**NO incluye**:
- Colores específicos (eso lo define la HU-007 - Artículos)
- Stock por tienda (eso lo asigna la HU-008)
- Precio (se define a nivel artículo)

### Ejemplos de Productos Maestros:
```
Producto 1: Adidas + Algodón + Futbol + Número (35-44)
Producto 2: Nike + Microfibra + Invisible + Única
Producto 3: Puma + Bambú + Tobillera + Letra (S-XXL)
```

### Flujo de Especialización:
```
PRODUCTO MAESTRO (HU-006)
    ↓ especialización con colores
ARTÍCULO (HU-007)
    ↓ asignación de stock
INVENTARIO POR TIENDA (HU-008)
```

## 🎯 CRITERIOS DE ACEPTACIÓN

### CA-001: Acceso Exclusivo Admin
- [ ] **DADO** que soy usuario con rol ADMIN
- [ ] **CUANDO** accedo al menú "Productos"
- [ ] **ENTONCES** debo ver la opción "Crear Producto Maestro"
- [ ] **Y** usuarios con rol GERENTE o VENDEDOR NO deben ver esta opción

### CA-002: Formulario de Creación de Producto
- [ ] **DADO** que hago clic en "Crear Producto Maestro"
- [ ] **CUANDO** se carga el formulario
- [ ] **ENTONCES** debo ver los siguientes campos:
  - [ ] Dropdown "Marca" con marcas activas
  - [ ] Dropdown "Material" con materiales activos
  - [ ] Dropdown "Tipo" con tipos activos
  - [ ] Dropdown "Sistema de Tallas" con sistemas activos
  - [ ] Campo de texto "Descripción" (opcional, max 200 caracteres)
  - [ ] Botones "Guardar" y "Cancelar"

### CA-003: Validación de Catálogos Activos
- [ ] **DADO** que estoy en el formulario de producto maestro
- [ ] **CUANDO** abro cualquier dropdown de catálogo
- [ ] **ENTONCES** solo debo ver registros con estado activo=true
- [ ] **Y** catálogos inactivos NO deben aparecer en las opciones

### CA-004: Validación de Campos Obligatorios
- [ ] **DADO** que intento guardar un producto maestro
- [ ] **CUANDO** dejo vacío alguno de los campos: Marca, Material, Tipo o Sistema de Tallas
- [ ] **ENTONCES** debo ver mensaje "Todos los campos obligatorios deben completarse"
- [ ] **Y** el formulario NO debe permitir guardar

### CA-005: Validación de Combinaciones Lógicas
- [ ] **DADO** que selecciono un tipo de media y sistema de tallas
- [ ] **CUANDO** la combinación es comercialmente poco común
- [ ] **ENTONCES** debo ver advertencia específica según RN-040
- [ ] **Y** el sistema debe mostrar botón "Guardar de todas formas"
- [ ] **PERO** si confirmo, debe guardarse sin restricciones

### CA-006: Validación de Duplicados
- [ ] **DADO** que intento crear un producto maestro
- [ ] **CUANDO** ya existe la misma combinación exacta (marca+material+tipo+sistema_talla)
- [ ] **ENTONCES** debo ver "Ya existe un producto con esta combinación"
- [ ] **Y** NO debe permitir guardar

### CA-007: Guardar Producto Maestro Exitosamente
- [ ] **DADO** que he completado todos los campos obligatorios
- [ ] **CUANDO** hago clic en "Guardar"
- [ ] **ENTONCES** debo ver mensaje "Producto maestro creado exitosamente"
- [ ] **Y** debo ser redirigido a la lista de productos maestros
- [ ] **Y** el nuevo producto debe aparecer en la lista

### CA-008: Vista Previa de Combinación
- [ ] **DADO** que estoy completando el formulario
- [ ] **CUANDO** selecciono todos los catálogos obligatorios
- [ ] **ENTONCES** debo ver vista previa con:
  - [ ] Nombre compuesto: "[Marca] - [Tipo] - [Material] - [Sistema Talla]"
  - [ ] Ejemplo: "Adidas - Futbol - Algodón - Número (35-44)"

### CA-009: Listar Productos Maestros Creados
- [ ] **DADO** que accedo a "Productos > Productos Maestros"
- [ ] **CUANDO** se carga la lista
- [ ] **ENTONCES** debo ver tabla con:
  - [ ] Marca
  - [ ] Material
  - [ ] Tipo
  - [ ] Sistema de Tallas
  - [ ] Descripción (si existe)
  - [ ] Fecha de creación
  - [ ] Cantidad de artículos derivados (0 si aún no se especializó)
  - [ ] Estado (Activo/Inactivo)
  - [ ] Acciones: "Ver detalles", "Editar", "Desactivar"

### CA-010: Búsqueda y Filtrado de Productos Maestros
- [ ] **DADO** que estoy en la lista de productos maestros
- [ ] **CUANDO** uso los filtros de búsqueda
- [ ] **ENTONCES** debo poder filtrar por:
  - [ ] Marca
  - [ ] Material
  - [ ] Tipo
  - [ ] Sistema de Tallas
  - [ ] Estado (Activo/Inactivo)
  - [ ] Texto libre en descripción

### CA-011: Cancelar Creación sin Guardar
- [ ] **DADO** que estoy en el formulario de creación
- [ ] **CUANDO** hago clic en "Cancelar"
- [ ] **ENTONCES** debo ver confirmación "¿Descartar cambios sin guardar?"
- [ ] **Y** al confirmar, debo volver a la lista sin crear el producto

### CA-012: Información de Tallas Disponibles
- [ ] **DADO** que selecciono un sistema de tallas en el formulario
- [ ] **CUANDO** paso el cursor sobre el dropdown o el campo seleccionado
- [ ] **ENTONCES** debo ver información emergente mostrando:
  - [ ] Nombre del sistema (ej: "NÚMERO", "ÚNICA", "LETRA")
  - [ ] Valores disponibles configurados (ej: "35-36, 37-38, 39-40, 41-42, 43-44")
- [ ] **PARA** entender qué tallas abarcará este producto maestro antes de guardar

### CA-013: Editar Producto Maestro con Artículos Derivados
- [ ] **DADO** que intento editar un producto maestro con artículos derivados
- [ ] **CUANDO** accedo al formulario de edición
- [ ] **ENTONCES** debo ver:
  - [ ] Campo "Descripción" habilitado (editable)
  - [ ] Campos "Marca", "Material", "Tipo", "Sistema Tallas" deshabilitados (no editables)
  - [ ] Advertencia: "Este producto tiene X artículos derivados. Solo se puede editar la descripción"
- [ ] **Y** solo el campo descripción debe permitir cambios

### CA-014: Eliminar vs Desactivar Producto Maestro
- [ ] **DADO** que hago clic en acción "Eliminar" sobre un producto maestro
- [ ] **CUANDO** el producto NO tiene artículos derivados (total = 0)
- [ ] **ENTONCES** debo ver confirmación "¿Eliminar permanentemente este producto?"
- [ ] **Y** al confirmar, debe eliminarse de la base de datos
- [ ] **PERO CUANDO** el producto tiene artículos derivados (total > 0)
- [ ] **ENTONCES** debo ver mensaje "No se puede eliminar. Este producto tiene X artículos. Solo puede desactivarlo"
- [ ] **Y** el botón debe cambiar a "Desactivar"

### CA-015: Detección de Catálogos Inactivos en Producto Existente
- [ ] **DADO** que un producto maestro usa catálogos que luego se desactivaron
- [ ] **CUANDO** visualizo la lista de productos maestros
- [ ] **ENTONCES** debo ver badge "⚠️ Contiene catálogos inactivos" junto al producto
- [ ] **Y** al ver detalles, debe indicar cuál catálogo está inactivo
- [ ] **Y** NO debe permitir crear artículos derivados desde ese producto

### CA-016: Reactivar Producto Maestro Existente Inactivo
- [ ] **DADO** que intento crear un producto maestro con combinación ya existente pero inactiva
- [ ] **CUANDO** hago clic en "Guardar"
- [ ] **ENTONCES** debo ver mensaje "Ya existe un producto inactivo con esta combinación"
- [ ] **Y** debo ver botón "Reactivar producto existente"
- [ ] **Y** al hacer clic, debe activarse el producto existente sin duplicar

## 📐 REGLAS DE NEGOCIO (RN)

### RN-037: Unicidad de Combinación de Producto Maestro
**Contexto**: Al crear un nuevo producto maestro
**Restricción**: No pueden existir dos productos maestros con la misma combinación exacta
**Validación**:
- Combinación única = marca_id + material_id + tipo_id + sistema_talla_id
- Si existe registro con esa combinación (incluso inactivo), rechazar creación
- Mensaje: "Ya existe un producto con esta combinación. Puede reactivarlo si está inactivo."
**Caso especial**: Si el producto existente está inactivo, ofrecer opción "Reactivar producto existente"

### RN-038: Catálogos Deben Estar Activos
**Contexto**: Al seleccionar catálogos en formulario de producto maestro
**Restricción**: Solo mostrar y permitir selección de registros activos
**Validación en formulario**:
- Dropdown de marcas: WHERE activo = true
- Dropdown de materiales: WHERE activo = true
- Dropdown de tipos: WHERE activo = true
- Dropdown de sistemas_talla: WHERE activo = true
**Caso especial - Catálogo desactivado después de crear producto**:
- El producto maestro conserva las relaciones (foreign keys válidas)
- En la lista de productos maestros mostrar badge "⚠️ Contiene catálogos inactivos"
- Al editar el producto, mostrar advertencia: "Marca/Material/Tipo/Talla X está inactivo. No se puede usar en nuevos productos"
- No permitir crear artículos derivados de productos con catálogos inactivos

### RN-039: Descripción Opcional con Límite
**Contexto**: Al agregar descripción a producto maestro
**Restricción**: Campo opcional pero con longitud controlada
**Validación**:
- Longitud mínima: 0 caracteres (campo opcional)
- Longitud máxima: 200 caracteres
- Permite letras, números, espacios y puntuación básica
- Ejemplos válidos: "Para uso deportivo", "Línea premium invierno 2025"
**Caso especial**: Si descripción vacía, mostrar en lista como "-" o "Sin descripción"

### RN-040: Validación de Combinaciones Comerciales
**Contexto**: Al combinar tipo de media con sistema de tallas
**Restricción**: Advertir sobre combinaciones poco comunes o ilógicas del negocio
**Validación de advertencias (NO bloqueantes)**:
- Tipo "Futbol" + Sistema "ÚNICA" → ⚠️ "Las medias de futbol normalmente usan tallas numéricas (35-44)"
- Tipo "Futbol" + Sistema "LETRA" → ⚠️ "Las medias de futbol normalmente usan tallas numéricas, no S/M/L"
- Tipo "Invisible" + Sistema "LETRA" → ⚠️ "Las medias invisibles suelen ser talla única o numérica"
- Tipo "Invisible" + Sistema "NÚMERO" → ⚠️ "Las medias invisibles suelen ser talla única"
- Tipo "Tobillera" + Sistema "ÚNICA" → Advertencia opcional (menos crítica)
**Combinaciones válidas SIN advertencia**:
- Futbol + NÚMERO
- Invisible + ÚNICA
- Tobillera + NÚMERO o LETRA
**Caso especial**: Admin puede hacer clic en "Guardar de todas formas" para confirmar combinación inusual

### RN-041: Producto Maestro Sin Colores ni Stock
**Contexto**: Al crear producto maestro
**Restricción**: Es solo una definición base sin atributos de artículo
**Validación**:
- NO tiene campo de colores (eso es responsabilidad de artículos/HU-007)
- NO tiene campo de stock (eso lo asigna inventario/HU-008)
- NO tiene campo de precio (se define a nivel artículo)
- NO tiene SKU (se genera al crear artículo con colores)
**Caso especial**: Producto maestro puede existir sin artículos derivados (aún no especializado)

### RN-042: Impacto de Desactivar Producto Maestro
**Contexto**: Al desactivar un producto maestro
**Restricción**: Afecta visibilidad pero no elimina artículos derivados
**Validación**:
- Producto maestro inactivo NO aparece en selector de nuevos artículos
- Artículos derivados existentes conservan referencia pero muestran advertencia
- Mostrar mensaje: "Este producto tiene X artículos derivados activos. ¿Desactivarlos también?"
**Caso especial**: Admin puede desactivar solo el maestro o en cascada (maestro + artículos)

### RN-043: Cantidad de Artículos Derivados
**Contexto**: Al listar productos maestros
**Restricción**: Mostrar cuántos artículos se han especializado desde este maestro
**Validación**:
- Contador de artículos ACTIVOS = COUNT de registros en tabla articulos WHERE producto_id = maestro.id AND activo = true
- Contador de artículos TOTALES = COUNT de registros en tabla articulos WHERE producto_id = maestro.id (incluye inactivos)
**Visualización en lista**:
- Si total = 0: Mostrar "Sin artículos" y badge verde "Nuevo"
- Si activos > 0: Mostrar "X artículos activos" + enlace "Ver artículos derivados"
- Si activos = 0 pero total > 0: Mostrar "0 activos (Y inactivos)" + enlace
**Caso especial - Eliminación vs Desactivación**:
- Producto con 0 artículos totales: permitir **eliminar** permanentemente
- Producto con artículos (activos o inactivos): solo permitir **desactivar**

### RN-044: Edición de Producto Maestro
**Contexto**: Al editar un producto maestro existente
**Restricción**: Cambios estructurales afectan artículos derivados
**Validación por campos**:
- **Si producto tiene 0 artículos totales**: permitir editar TODOS los campos (marca, material, tipo, sistema_talla, descripción)
- **Si producto tiene artículos derivados (activos o inactivos)**:
  - ✅ PERMITIR editar: descripción (campo independiente sin impacto)
  - ❌ BLOQUEAR editar: marca, material, tipo, sistema_talla (afectaría SKU y lógica de artículos)
  - Mostrar advertencia: "Este producto tiene X artículos derivados. No se pueden cambiar atributos estructurales (marca/material/tipo/tallas)"
**Caso especial**:
- Para cambiar atributos estructurales con artículos existentes, admin debe:
  1. Desactivar producto maestro actual
  2. Crear nuevo producto maestro con combinación deseada
  3. Opcionalmente migrar artículos manualmente (fuera del alcance de esta HU)

### RN-045: Orden de Llenado de Formulario
**Contexto**: Al crear producto maestro
**Restricción**: No hay orden específico obligatorio
**Validación**:
- Admin puede seleccionar catálogos en cualquier orden
- Validación se ejecuta solo al hacer clic en "Guardar"
- Vista previa se actualiza dinámicamente al completar cada campo
**Caso especial**: Si faltan campos al guardar, resaltar en rojo los incompletos

### RN-046: Nombres Compuestos para Visualización
**Contexto**: Al mostrar producto maestro en listas o reportes
**Restricción**: Formato estándar legible
**Validación**:
- Formato corto: "[Marca] - [Tipo] - [Material]"
- Formato largo: "[Marca] - [Tipo] - [Material] - [Sistema Talla]"
- Ejemplo corto: "Adidas - Futbol - Algodón"
- Ejemplo largo: "Adidas - Futbol - Algodón - Número (35-44)"
**Caso especial**: En dropdowns usar formato corto; en detalles usar formato largo

## 🔗 DEPENDENCIAS

- **Depende de**:
  - E002-HU-001 - Gestionar Catálogo de Marcas (COMPLETADA)
  - E002-HU-002 - Gestionar Catálogo de Materiales (COMPLETADA)
  - E002-HU-003 - Gestionar Catálogo de Tipos (COMPLETADA)
  - E002-HU-004 - Gestionar Sistemas de Tallas (COMPLETADA)

- **Bloqueante para**:
  - E002-HU-007 - Especializar Artículos con Colores (pendiente)
  - E002-HU-008 - Asignar Stock por Tienda (pendiente)

- **Relacionada con**:
  - E002-HU-005 - Gestionar Catálogo de Colores (COMPLETADA - se usará en HU-007)

## 📊 ESTIMACIÓN

**Story Points**: 5 pts

**Justificación**:
- Complejidad media por combinación de 4 catálogos
- Formulario con validaciones múltiples
- Lógica de unicidad de combinaciones
- Advertencias de combinaciones comerciales
- Impacto en artículos derivados
- CRUD básico sin colores ni stock (más simple que HU-007)

## 📝 NOTAS TÉCNICAS

### Flujo Completo de Producto:
```
1. CATÁLOGOS (HU-001 a HU-005) → Marcas, Materiales, Tipos, Tallas, Colores
2. PRODUCTO MAESTRO (HU-006) → Combina Marca+Material+Tipo+Sistema Talla
3. ARTÍCULO (HU-007) → Especializa Producto con Colores, genera SKU
4. INVENTARIO (HU-008) → Asigna Stock por Artículo-Tienda
```

### Ejemplo de Datos:
```json
{
  "producto_maestro_id": "uuid-123",
  "marca_id": "uuid-adidas",
  "material_id": "uuid-algodon",
  "tipo_id": "uuid-futbol",
  "sistema_talla_id": "uuid-numero-35-44",
  "descripcion": "Línea deportiva premium",
  "activo": true,
  "articulos_derivados_count": 0,
  "created_at": "2025-10-10T10:00:00Z"
}
```

### Validaciones al Guardar:
```
1. ✓ Marca activa existe
2. ✓ Material activo existe
3. ✓ Tipo activo existe
4. ✓ Sistema de tallas activo existe
5. ✓ Combinación única (no duplicada)
6. ⚠ Validar advertencias comerciales (no bloqueante)
7. ✓ Descripción ≤ 200 caracteres
```

## ✅ DEFINICIÓN DE TERMINADO (DoD)

### Funcionalidad Core:
- [ ] Todos los criterios de aceptación implementados (CA-001 a CA-016)
- [ ] Formulario de creación funcional solo para rol ADMIN
- [ ] Validación de catálogos activos en dropdowns
- [ ] Validación de combinaciones únicas (marca+material+tipo+tallas)
- [ ] Advertencias de combinaciones comerciales según RN-040
- [ ] Vista previa de nombre compuesto actualizada dinámicamente

### Gestión de Productos:
- [ ] Listado de productos maestros con filtros por marca/material/tipo/tallas/estado
- [ ] Contador de artículos derivados (activos/totales) según RN-043
- [ ] Edición con restricciones según artículos derivados (RN-044)
- [ ] Eliminación solo si 0 artículos, desactivación si tiene artículos
- [ ] Reactivación de productos inactivos con misma combinación (RN-037)

### Casos Especiales:
- [ ] Detección de catálogos inactivos en productos existentes (RN-038)
- [ ] Bloqueo de creación de artículos desde productos con catálogos inactivos
- [ ] Tooltip con valores de tallas disponibles en formulario (CA-012)
- [ ] Desactivación en cascada (producto + artículos derivados)

### Calidad:
- [ ] Tests unitarios para validaciones de negocio (RN-037 a RN-046)
- [ ] Tests de integración para flujo completo CRUD
- [ ] Tests de permisos (solo admin puede crear/editar/eliminar)
- [ ] Tests de validación de combinaciones comerciales
- [ ] QA valida flujo completo end-to-end

### Integración:
- [ ] Producto maestro se puede usar en HU-007 (crear artículos derivados)
- [ ] Relación correcta con catálogos (marcas, materiales, tipos, sistemas_talla)
- [ ] Documentación técnica de implementación actualizada
- [ ] Documentación de usuario actualizada

---

**Notas del Product Owner**:
Esta HU define QUÉ debe hacer el sistema desde la perspectiva del negocio. Los detalles técnicos de implementación (modelo de datos, componentes UI, APIs, tecnologías) serán definidos por los agentes especializados: supabase-expert, ux-ui-expert, web-architect-expert, flutter-expert y qa-testing-expert.