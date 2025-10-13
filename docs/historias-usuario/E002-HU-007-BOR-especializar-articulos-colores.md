# E002-HU-007: Especializar Artículos con Colores

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E002-HU-007
- **Épica**: E002 - Gestión de Productos de Medias
- **Título**: Especializar Artículos con Colores
- **Story Points**: 6 pts
- **Estado**: 🟡 Borrador
- **Fecha Creación**: 2025-10-11

## 🎯 HISTORIA DE USUARIO
**Como** administrador de la empresa de medias
**Quiero** especializar productos maestros asignando combinaciones de colores y generando SKU automático
**Para** crear artículos únicos vendibles con identificación precisa y control de inventario

## 🧦 CONTEXTO DEL NEGOCIO DE MEDIAS

### Concepto de Artículo Especializado:
Un **artículo** es la versión vendible de un producto maestro que incluye:
- Producto maestro base (marca + material + tipo + sistema tallas)
- Combinación específica de colores (1, 2 o 3 colores)
- SKU único generado automáticamente
- Precio de venta
- Estado activo/inactivo

**Diferencia clave**:
- **Producto Maestro** (HU-006): Genérico, sin colores → "Adidas - Futbol - Algodón - Número (35-44)"
- **Artículo** (HU-007): Específico, con colores → "Adidas - Futbol - Algodón - Número (35-44) - Rojo"

### Ejemplos de Especialización:
```
PRODUCTO MAESTRO: Adidas + Algodón + Futbol + Número (35-44)
  ↓ Genera múltiples artículos:
  ARTÍCULO 1: Misma base + Color Rojo → SKU: ADS-FUT-ALG-3738-ROJ
  ARTÍCULO 2: Misma base + Colores Blanco-Negro → SKU: ADS-FUT-ALG-3738-BLA-NEG
  ARTÍCULO 3: Misma base + Colores Azul-Rojo-Blanco → SKU: ADS-FUT-ALG-3738-AZU-ROJ-BLA
```

### Flujo de Creación Completo:
```
CATÁLOGOS (HU-001 a HU-005)
    ↓
PRODUCTO MAESTRO (HU-006) [Sin colores]
    ↓
ARTÍCULO (HU-007) [Con colores + SKU]
    ↓
INVENTARIO POR TIENDA (HU-008) [Con stock]
```

### Reglas de Generación de SKU:
```
Formato: MARCA-TIPO-MATERIAL-TALLA-COLOR1-COLOR2-COLOR3

Componentes:
- MARCA: Código 3 letras (ej: ADS=Adidas, NIK=Nike, PUM=Puma)
- TIPO: Código 3 letras (ej: FUT=Futbol, INV=Invisible, TOB=Tobillera)
- MATERIAL: Código 3 letras (ej: ALG=Algodón, MIC=Microfibra, BAM=Bambú)
- TALLA: Código de talla específica o UNI
- COLOR1, COLOR2, COLOR3: Códigos 3 letras de colores (ej: ROJ, BLA, AZU)

Ejemplos reales:
- ADS-FUT-ALG-3738-ROJ (1 color: Rojo)
- NIK-INV-MIC-UNI-BLA-GRI (2 colores: Blanco-Gris)
- PUM-TOB-BAM-M-AZU-VER-ROJ (3 colores: Azul-Verde-Rojo)
```

## 🎯 CRITERIOS DE ACEPTACIÓN

### CA-001: Acceso Exclusivo Admin
- [ ] **DADO** que soy usuario con rol ADMIN
- [ ] **CUANDO** accedo al menú "Artículos"
- [ ] **ENTONCES** debo ver la opción "Crear Artículo"
- [ ] **Y** usuarios con rol GERENTE o VENDEDOR NO deben ver esta opción

### CA-002: Seleccionar Producto Maestro Base
- [ ] **DADO** que hago clic en "Crear Artículo"
- [ ] **CUANDO** se carga el formulario
- [ ] **ENTONCES** debo ver:
  - [ ] Dropdown "Producto Maestro" con productos activos
  - [ ] Vista previa del producto seleccionado mostrando:
    - [ ] Marca, Material, Tipo, Sistema de Tallas
    - [ ] Descripción (si existe)
    - [ ] Cantidad de artículos ya derivados de este producto

### CA-003: Validación de Catálogos Activos en Producto
- [ ] **DADO** que estoy viendo lista de productos maestros
- [ ] **CUANDO** un producto maestro tiene catálogos inactivos
- [ ] **ENTONCES** NO debe aparecer en el dropdown
- [ ] **Y** debo poder filtrar para ver solo productos válidos

### CA-004: Asignar Colores al Artículo (Unicolor)
- [ ] **DADO** que he seleccionado un producto maestro
- [ ] **CUANDO** selecciono opción "Unicolor"
- [ ] **ENTONCES** debo ver:
  - [ ] Dropdown con colores activos del catálogo
  - [ ] Posibilidad de seleccionar EXACTAMENTE 1 color
  - [ ] Vista previa visual del color con código hexadecimal
  - [ ] Generación automática de SKU provisional

### CA-005: Asignar Colores al Artículo (Bicolor)
- [ ] **DADO** que he seleccionado un producto maestro
- [ ] **CUANDO** selecciono opción "Bicolor"
- [ ] **ENTONCES** debo ver:
  - [ ] Selector múltiple de colores activos
  - [ ] Posibilidad de seleccionar EXACTAMENTE 2 colores
  - [ ] Orden de colores ajustable (arrastrar y soltar)
  - [ ] Vista previa visual de combinación
  - [ ] Generación automática de SKU provisional
  - [ ] Etiqueta "Bicolor" en vista previa

### CA-006: Asignar Colores al Artículo (Tricolor)
- [ ] **DADO** que he seleccionado un producto maestro
- [ ] **CUANDO** selecciono opción "Tricolor"
- [ ] **ENTONCES** debo ver:
  - [ ] Selector múltiple de colores activos
  - [ ] Posibilidad de seleccionar EXACTAMENTE 3 colores
  - [ ] Orden de colores ajustable (arrastrar y soltar)
  - [ ] Vista previa visual de combinación
  - [ ] Generación automática de SKU provisional
  - [ ] Etiqueta "Tricolor" en vista previa

### CA-007: Generación Automática de SKU
- [ ] **DADO** que he completado producto maestro y colores
- [ ] **CUANDO** el sistema genera el SKU
- [ ] **ENTONCES** debo ver:
  - [ ] SKU generado con formato: MARCA-TIPO-MATERIAL-TALLA-COLOR1-COLOR2-COLOR3
  - [ ] Ejemplo: "ADS-FUT-ALG-3738-ROJ"
  - [ ] SKU actualizado en tiempo real al cambiar colores u orden
  - [ ] Advertencia si SKU ya existe (duplicado)

### CA-008: Validación de SKU Único
- [ ] **DADO** que el sistema genera un SKU
- [ ] **CUANDO** ya existe un artículo con ese SKU exacto
- [ ] **ENTONCES** debo ver "Este SKU ya existe para otro artículo"
- [ ] **Y** NO debe permitir guardar
- [ ] **Y** debo poder modificar el orden de colores o selección para generar SKU diferente

### CA-009: Asignar Precio al Artículo
- [ ] **DADO** que estoy creando un artículo
- [ ] **CUANDO** completo el formulario
- [ ] **ENTONCES** debo ver:
  - [ ] Campo "Precio" (numérico, requerido, mínimo 0.01)
  - [ ] Formato de moneda (ej: $15,000.00)
  - [ ] Validación de precio mayor a cero
  - [ ] Sugerencia de rango de precios según tipo de producto (opcional)

### CA-010: Guardar Artículo Exitosamente
- [ ] **DADO** que he completado todos los campos obligatorios
- [ ] **CUANDO** hago clic en "Guardar"
- [ ] **ENTONCES** debo ver mensaje "Artículo creado exitosamente"
- [ ] **Y** debo ser redirigido a la lista de artículos
- [ ] **Y** el nuevo artículo debe aparecer en la lista con:
  - [ ] SKU generado
  - [ ] Nombre completo (Marca-Tipo-Material-Talla-Colores)
  - [ ] Precio
  - [ ] Estado Activo
  - [ ] Fecha de creación

### CA-011: Listar Artículos Creados
- [ ] **DADO** que accedo a "Artículos > Lista de Artículos"
- [ ] **CUANDO** se carga la lista
- [ ] **ENTONCES** debo ver tabla con:
  - [ ] SKU (único)
  - [ ] Producto maestro base (nombre completo)
  - [ ] Colores (con vista previa visual)
  - [ ] Precio
  - [ ] Cantidad de tiendas con stock (0 si nuevo)
  - [ ] Stock total (suma de todas las tiendas)
  - [ ] Estado (Activo/Inactivo)
  - [ ] Fecha de creación
  - [ ] Acciones: "Ver detalles", "Editar", "Desactivar"

### CA-012: Validación de Cantidad de Colores
- [ ] **DADO** que estoy asignando colores a un artículo
- [ ] **CUANDO** selecciono cantidad de colores
- [ ] **ENTONCES** debo poder elegir:
  - [ ] Unicolor: EXACTAMENTE 1 color (no más, no menos)
  - [ ] Bicolor: EXACTAMENTE 2 colores (no más, no menos)
  - [ ] Tricolor: EXACTAMENTE 3 colores (no más, no menos)
- [ ] **Y** el sistema debe bloquear guardar si no cumple la cantidad exacta

### CA-013: Orden de Colores es Significativo
- [ ] **DADO** que estoy creando un artículo bicolor o tricolor
- [ ] **CUANDO** cambio el orden de los colores
- [ ] **ENTONCES** el SKU debe actualizarse reflejando el nuevo orden
- [ ] **Y** debo ver advertencia: "El orden de colores cambia el SKU. Verifica que no exista duplicado"
- [ ] **EJEMPLO**: [Rojo, Negro] genera SKU diferente a [Negro, Rojo]

### CA-014: Editar Artículo con Restricciones
- [ ] **DADO** que intento editar un artículo existente
- [ ] **CUANDO** el artículo tiene stock asignado en tiendas (stock > 0)
- [ ] **ENTONCES** debo ver:
  - [ ] Campo "Precio" habilitado (editable)
  - [ ] Campo "Estado" habilitado (editable)
  - [ ] Campos "Producto Maestro" y "Colores" deshabilitados (no editables)
  - [ ] Advertencia: "Este artículo tiene stock en X tiendas. Solo se puede editar precio y estado"
- [ ] **PERO CUANDO** el artículo NO tiene stock (stock = 0)
- [ ] **ENTONCES** debo poder editar todos los campos

### CA-015: Eliminar vs Desactivar Artículo
- [ ] **DADO** que hago clic en acción "Eliminar" sobre un artículo
- [ ] **CUANDO** el artículo NO tiene stock en ninguna tienda (stock total = 0)
- [ ] **ENTONCES** debo ver confirmación "¿Eliminar permanentemente este artículo?"
- [ ] **Y** al confirmar, debe eliminarse de la base de datos
- [ ] **PERO CUANDO** el artículo tiene stock en alguna tienda (stock > 0)
- [ ] **ENTONCES** debo ver mensaje "No se puede eliminar. Este artículo tiene stock en X tiendas. Solo puede desactivarlo"
- [ ] **Y** el botón debe cambiar a "Desactivar"

### CA-016: Búsqueda y Filtrado de Artículos
- [ ] **DADO** que estoy en la lista de artículos
- [ ] **CUANDO** uso los filtros de búsqueda
- [ ] **ENTONCES** debo poder filtrar por:
  - [ ] SKU (texto libre)
  - [ ] Producto maestro (dropdown)
  - [ ] Marca (dropdown)
  - [ ] Material (dropdown)
  - [ ] Tipo (dropdown)
  - [ ] Colores (selector múltiple - inclusivo)
  - [ ] Rango de precio (desde - hasta)
  - [ ] Estado (Activo/Inactivo)
  - [ ] Stock disponible (Con stock / Sin stock)

### CA-017: Vista Previa Visual de Colores
- [ ] **DADO** que estoy visualizando un artículo en lista o detalle
- [ ] **CUANDO** el artículo tiene colores asignados
- [ ] **ENTONCES** debo ver:
  - [ ] Unicolor: Círculo con el color único
  - [ ] Bicolor: Rectángulo dividido en dos secciones con los colores
  - [ ] Tricolor: Rectángulo dividido en tres secciones con los colores
  - [ ] Nombres de colores debajo de la vista previa
  - [ ] Códigos hexadecimales al pasar cursor (tooltip)

### CA-018: Cancelar Creación sin Guardar
- [ ] **DADO** que estoy en el formulario de creación de artículo
- [ ] **CUANDO** hago clic en "Cancelar"
- [ ] **ENTONCES** debo ver confirmación "¿Descartar cambios sin guardar?"
- [ ] **Y** al confirmar, debo volver a la lista sin crear el artículo

### CA-019: Contador de Artículos por Producto Maestro
- [ ] **DADO** que estoy en la lista de productos maestros
- [ ] **CUANDO** veo un producto maestro
- [ ] **ENTONCES** debo ver:
  - [ ] Contador "X artículos derivados"
  - [ ] Enlace "Ver artículos derivados" que filtra lista de artículos por ese producto maestro
  - [ ] Si contador = 0: Badge "Sin artículos" en color gris

### CA-020: Validación de Colores Activos
- [ ] **DADO** que estoy creando un artículo
- [ ] **CUANDO** abro el selector de colores
- [ ] **ENTONCES** solo debo ver colores con estado activo = true
- [ ] **Y** colores inactivos NO deben aparecer en las opciones
- [ ] **Y** si un artículo existente tiene color inactivo, debe mostrar badge "⚠️ Color descontinuado"

## 📐 REGLAS DE NEGOCIO (RN)

### RN-047: Unicidad de SKU en Todo el Sistema
**Contexto**: Al generar SKU para un nuevo artículo
**Restricción**: No pueden existir dos artículos con el mismo SKU exacto
**Validación**:
- SKU se genera automáticamente con formato: MARCA-TIPO-MATERIAL-TALLA-COLOR1-COLOR2-COLOR3
- Antes de guardar, verificar que no exista otro artículo con ese SKU
- Incluir artículos inactivos en la verificación (no reutilizar SKU de inactivos)
**Caso especial**: Si orden de colores cambia, genera SKU diferente ([Rojo, Negro] ≠ [Negro, Rojo])

### RN-048: Cantidad Exacta de Colores por Tipo
**Contexto**: Al asignar colores a un artículo
**Restricción**: Cantidad debe corresponder exactamente con el tipo seleccionado
**Validación**:
- Unicolor: EXACTAMENTE 1 color (ni más ni menos)
- Bicolor: EXACTAMENTE 2 colores (ni más ni menos)
- Tricolor: EXACTAMENTE 3 colores (ni más ni menos)
- NO se permite guardar si cantidad no coincide
**Caso especial**: NO existe opción "Multicolor (4+ colores)" en el negocio de medias actual

### RN-049: Orden de Colores es Significativo
**Contexto**: Al definir combinación de colores en artículo bicolor o tricolor
**Restricción**: El orden determina el SKU y la apariencia del producto
**Validación**:
- [Rojo, Negro] genera SKU: ...-ROJ-NEG
- [Negro, Rojo] genera SKU: ...-NEG-ROJ
- Ambos son artículos DIFERENTES aunque usen mismos colores
- El primer color es el predominante o base
**Caso especial**: Unicolor no tiene orden (solo 1 color)

### RN-050: Producto Maestro Debe Estar Activo y Válido
**Contexto**: Al seleccionar producto maestro para crear artículo
**Restricción**: Solo productos maestros con todos sus catálogos activos
**Validación**:
- Producto maestro debe tener activo = true
- Marca relacionada debe estar activa
- Material relacionado debe estar activo
- Tipo relacionado debe estar activo
- Sistema de tallas relacionado debe estar activo
**Caso especial**: Si cualquier catálogo se desactiva después, artículo existente conserva referencia pero muestra badge de advertencia

### RN-051: Colores Activos en Selección
**Contexto**: Al seleccionar colores para artículo
**Restricción**: Solo colores activos disponibles en selector
**Validación**:
- Dropdown/selector muestra únicamente colores con activo = true
- Colores inactivos no aparecen en opciones
- Artículos existentes con colores inactivos conservan el color pero muestran advertencia
**Caso especial**: Admin puede reactivar color para volver a usarlo en nuevos artículos

### RN-052: Precio Debe Ser Mayor a Cero
**Contexto**: Al asignar precio a un artículo
**Restricción**: Precio mínimo válido para venta
**Validación**:
- Precio mínimo: 0.01 (un centavo)
- Precio NO puede ser cero
- Precio NO puede ser negativo
- Formato decimal con 2 decimales (ej: 15000.00)
**Caso especial**: Precio se puede actualizar posteriormente si artículo tiene stock

### RN-053: Generación Automática de SKU
**Contexto**: Al guardar un artículo con todos los campos completos
**Restricción**: SKU se genera automáticamente, NO es editable manualmente
**Validación**:
- Formato fijo: MARCA-TIPO-MATERIAL-TALLA-COLOR1-COLOR2-COLOR3
- Todos los códigos en MAYÚSCULAS
- Separados por guion (-)
- Códigos de 3 letras para marca, tipo, material, colores
- Talla según sistema (puede variar: UNI, 3738, M, XL, etc.)
**Caso especial**: Si falta algún dato de catálogo (código no definido), no permitir guardar

### RN-054: Impacto de Desactivar Artículo
**Contexto**: Al desactivar un artículo
**Restricción**: Artículo no se elimina, conserva stock y relaciones
**Validación**:
- Artículo inactivo NO aparece en selector de ventas
- Artículo inactivo NO aparece en búsquedas de productos disponibles
- Artículo inactivo SÍ aparece en reportes históricos e inventario
- Stock existente se conserva pero no se puede vender
**Caso especial**: Admin puede reactivar artículo si todos sus catálogos relacionados están activos

### RN-055: Restricciones de Edición con Stock Asignado
**Contexto**: Al editar un artículo con stock en tiendas
**Restricción**: Cambios estructurales afectan inventario y ventas
**Validación por campos**:
- **Si artículo tiene stock = 0 en todas las tiendas**: permitir editar TODOS los campos
- **Si artículo tiene stock > 0 en alguna tienda**:
  - ✅ PERMITIR editar: precio, estado activo/inactivo
  - ❌ BLOQUEAR editar: producto maestro, colores (cambiaría SKU)
  - Mostrar advertencia: "Este artículo tiene stock en X tiendas. No se pueden cambiar atributos estructurales"
**Caso especial**: Para cambiar colores/SKU con stock existente, admin debe desactivar artículo actual y crear nuevo

### RN-056: Eliminación vs Desactivación de Artículo
**Contexto**: Al intentar eliminar un artículo
**Restricción**: Artículos con historial de stock no se pueden eliminar
**Validación**:
- **Si artículo tiene stock total = 0 en todas las tiendas**: permitir ELIMINAR permanentemente
- **Si artículo tiene stock > 0 en alguna tienda**: solo permitir DESACTIVAR
- Mostrar contador de tiendas afectadas
- Mensaje: "Este artículo tiene stock en X tiendas (Y unidades totales). Solo puede desactivarlo"
**Caso especial**: Artículos desactivados con stock=0 pueden eliminarse posteriormente

### RN-057: Validación de Códigos en Catálogos
**Contexto**: Al generar SKU, todos los catálogos deben tener códigos válidos
**Restricción**: Códigos de 3 letras obligatorios para marca, tipo, material, color
**Validación**:
- Marca debe tener codigo definido (3 letras)
- Tipo debe tener codigo definido (3 letras)
- Material debe tener codigo definido (3 letras)
- Color debe tener codigo definido (3 letras)
- Si falta algún código, NO permitir crear artículo
**Caso especial**: Sistemas de tallas pueden tener códigos variables (UNI, 3738, M, etc.)

### RN-058: Un Producto Maestro Genera Múltiples Artículos
**Contexto**: Al crear artículos desde un producto maestro
**Restricción**: Relación 1:N (un producto maestro puede tener muchos artículos)
**Validación**:
- Un producto maestro puede generar N artículos (uno por cada combinación de colores)
- Cada artículo tiene SKU único
- Artículos comparten producto maestro pero difieren en colores y SKU
- Contador de artículos derivados se actualiza automáticamente
**Caso especial**: Producto maestro sin artículos derivados (contador = 0) es válido

### RN-059: Búsqueda por Colores es Inclusiva
**Contexto**: Al buscar artículos por color
**Restricción**: Búsqueda debe encontrar artículos que contengan el color en cualquier posición
**Validación**:
- Búsqueda "Rojo" encuentra:
  - Artículos unicolor rojo
  - Artículos bicolor con rojo (Rojo-Negro, Negro-Rojo)
  - Artículos tricolor con rojo (Rojo-Azul-Blanco, etc.)
- Búsqueda múltiple "Rojo, Negro" encuentra artículos con AMBOS colores
**Caso especial**: Búsqueda exacta por SKU es precisa (no inclusiva)

### RN-060: Precio se Puede Actualizar con Stock Existente
**Contexto**: Al editar precio de artículo con stock en tiendas
**Restricción**: Cambio de precio no afecta stock ni SKU
**Validación**:
- Admin puede cambiar precio en cualquier momento
- Cambio aplica inmediatamente a todas las tiendas
- NO se crea nuevo artículo (SKU permanece igual)
- Ventas futuras usan el nuevo precio
**Caso especial**: Ventas pasadas conservan el precio histórico (registrado en transacción)

## 🔗 DEPENDENCIAS

- **Depende de**:
  - E002-HU-001 - Gestionar Catálogo de Marcas (COMPLETADA)
  - E002-HU-002 - Gestionar Catálogo de Materiales (COMPLETADA)
  - E002-HU-003 - Gestionar Catálogo de Tipos (COMPLETADA)
  - E002-HU-004 - Gestionar Sistemas de Tallas (COMPLETADA)
  - E002-HU-005 - Gestionar Catálogo de Colores (COMPLETADA)
  - E002-HU-006 - Crear Producto Maestro (COMPLETADA)

- **Bloqueante para**:
  - E002-HU-008 - Asignar Stock por Tienda (pendiente)
  - E002-HU-009 - Transferencias Entre Tiendas (pendiente)
  - E002-HU-010 - Búsqueda Avanzada de Artículos (pendiente)

## 📊 ESTIMACIÓN

**Story Points**: 6 pts

**Justificación**:
- Complejidad media-alta por generación automática de SKU
- Validación de unicidad de SKU en sistema completo
- Selector de colores con cantidades exactas (1, 2 o 3)
- Orden de colores significativo (arrastrar y soltar)
- Vista previa visual dinámica de combinaciones
- Restricciones de edición según stock en tiendas
- Relación con 6 HUs previas (catálogos + producto maestro)
- CRUD completo con reglas de negocio complejas

## 📝 NOTAS TÉCNICAS

### Flujo Completo de Creación:
```
1. Admin selecciona Producto Maestro activo con catálogos válidos
2. Sistema carga datos del producto maestro (marca, material, tipo, tallas)
3. Admin selecciona tipo de coloración (Unicolor/Bicolor/Tricolor)
4. Admin selecciona colores activos según tipo:
   - Unicolor: 1 color
   - Bicolor: 2 colores + orden
   - Tricolor: 3 colores + orden
5. Sistema genera SKU automáticamente en tiempo real
6. Sistema valida unicidad de SKU
7. Admin ingresa precio (mínimo 0.01)
8. Admin guarda artículo
9. Sistema crea registro en tabla articulos
10. Contador de artículos derivados del producto maestro se incrementa
```

### Ejemplo de Datos:
```json
{
  "articulo_id": "uuid-456",
  "producto_maestro_id": "uuid-123",
  "sku": "ADS-FUT-ALG-3738-ROJ-NEG",
  "tipo_coloracion": "bicolor",
  "colores": ["Rojo", "Negro"],
  "colores_ids": ["uuid-col-roj", "uuid-col-neg"],
  "precio": 15000.00,
  "activo": true,
  "stock_total": 0,
  "tiendas_con_stock": 0,
  "created_at": "2025-10-11T10:00:00Z"
}
```

### Validaciones al Guardar:
```
1. ✓ Producto maestro activo existe
2. ✓ Todos los catálogos del producto maestro están activos
3. ✓ Cantidad de colores coincide con tipo (unicolor=1, bicolor=2, tricolor=3)
4. ✓ Colores seleccionados están activos
5. ✓ Códigos de catálogos existen (marca, tipo, material, colores)
6. ✓ SKU generado es único (no existe en sistema)
7. ✓ Precio > 0
8. ✓ Orden de colores definido (si bicolor/tricolor)
```

### Ejemplos de SKU Generados:
```
UNICOLOR:
- ADS-FUT-ALG-3738-ROJ (Adidas Futbol Algodón 37-38 Rojo)
- NIK-INV-MIC-UNI-BLA (Nike Invisible Microfibra Única Blanco)

BICOLOR:
- PUM-TOB-BAM-M-AZU-NEG (Puma Tobillera Bambú M Azul-Negro)
- ADS-FUT-ALG-4142-ROJ-BLA (Adidas Futbol Algodón 41-42 Rojo-Blanco)

TRICOLOR:
- NIK-FUT-MIC-3940-AZU-VER-BLA (Nike Futbol Microfibra 39-40 Azul-Verde-Blanco)
- PUM-TOB-ALG-L-ROJ-NEG-GRI (Puma Tobillera Algodón L Rojo-Negro-Gris)
```

## ✅ DEFINICIÓN DE TERMINADO (DoD)

### Funcionalidad Core:
- [ ] Todos los criterios de aceptación implementados (CA-001 a CA-020)
- [ ] Formulario de creación funcional solo para rol ADMIN
- [ ] Selector de producto maestro con filtro de catálogos activos
- [ ] Selector de colores con validación de cantidad exacta (1, 2 o 3)
- [ ] Generación automática de SKU en tiempo real
- [ ] Validación de unicidad de SKU en sistema completo
- [ ] Vista previa visual de combinaciones de colores

### Gestión de Artículos:
- [ ] Listado de artículos con filtros por producto maestro, marca, material, tipo, colores, precio, estado
- [ ] Edición con restricciones según stock en tiendas (RN-055)
- [ ] Eliminación solo si stock = 0, desactivación si stock > 0
- [ ] Contador de artículos derivados por producto maestro
- [ ] Búsqueda inclusiva por colores (RN-059)

### Reglas de Negocio:
- [ ] Tests unitarios para validaciones de negocio (RN-047 a RN-060)
- [ ] Tests de generación de SKU con diferentes combinaciones
- [ ] Tests de orden de colores significativo
- [ ] Tests de restricciones de edición con stock
- [ ] QA valida flujo completo end-to-end

### Integración:
- [ ] Artículo se puede usar en HU-008 (asignar stock por tienda)
- [ ] Relación correcta con producto maestro y catálogos
- [ ] Contador de artículos derivados actualizado en producto maestro
- [ ] Documentación técnica de implementación actualizada
- [ ] Documentación de usuario actualizada

---

**Notas del Product Owner**:
Esta HU define QUÉ debe hacer el sistema desde la perspectiva del negocio. Los detalles técnicos de implementación (modelo de datos, componentes UI, APIs, tecnologías) serán definidos por los agentes especializados: supabase-expert, ux-ui-expert, web-architect-expert, flutter-expert y qa-testing-expert.
