# E002-HU-005: Gestionar Catálogo de Colores

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E002-HU-005
- **Épica**: E002 - Gestión de Catálogo de Productos
- **Título**: Gestionar Catálogo de Colores
- **Story Points**: 8 pts
- **Estado**: ✅ Completada
- **Fecha Creación**: 2025-10-07

## 🎯 HISTORIA DE USUARIO
**Como** gerente o admin de la empresa de medias
**Quiero** gestionar un catálogo de colores unitarios y poder asignar combinaciones de colores a los productos
**Para** tener un control preciso de las variantes de color disponibles (unicolor y multicolor)

## 🧦 CONTEXTO DEL NEGOCIO DE MEDIAS

### Tipos de Productos por Color:
- **Unicolor**: Media de un solo color (ej: Rojo)
- **Bicolor**: Media con dos colores (ej: Rojo y Negro)
- **Tricolor**: Media con tres colores (ej: Azul, Rojo y Blanco)
- **Multicolor**: Media con más de tres colores

### Modelo de Datos:
```
COLORES (Catálogo Base):
- id: UUID
- nombre: "Rojo", "Negro", "Azul", "Blanco"
- codigo_hex: "#FF0000", "#000000", "#0000FF", "#FFFFFF"
- activo: boolean

PRODUCTO_COLORES (Combinaciones):
- producto_id: UUID
- colores: ["Rojo", "Negro"] (array de nombres)
- cantidad_colores: 2
- descripcion_visual: "Rojo con franjas negras"
```

## 🎯 CRITERIOS DE ACEPTACIÓN

### CA-001: Ver Catálogo de Colores Base
- [ ] **DADO** que soy gerente o admin
- [ ] **CUANDO** accedo a "Configuración > Catálogo de Colores"
- [ ] **ENTONCES** debo ver lista de colores base con:
  - [ ] Nombre del color
  - [ ] Código hexadecimal
  - [ ] Muestra visual del color
  - [ ] Estado (Activo/Inactivo)
  - [ ] Cantidad de productos que usan ese color
  - [ ] Botón "Editar" y "Eliminar/Desactivar"

### CA-002: Agregar Nuevo Color Base
- [ ] **DADO** que estoy en el catálogo de colores
- [ ] **CUANDO** hago clic en "Agregar Color"
- [ ] **ENTONCES** debo ver formulario con:
  - [ ] Campo "Nombre" (texto, requerido)
  - [ ] Campo "Código Hexadecimal" (color picker, requerido)
  - [ ] Vista previa del color
  - [ ] Botón "Guardar" y "Cancelar"

### CA-003: Validación de Colores Duplicados
- [ ] **DADO** que estoy agregando un nuevo color
- [ ] **CUANDO** ingreso un nombre que ya existe
- [ ] **ENTONCES** debo ver "Este color ya existe en el catálogo"
- [ ] **Y** no debe permitir guardar

### CA-004: Asignar Colores a Producto (Unicolor)
- [ ] **DADO** que estoy creando/editando un producto
- [ ] **CUANDO** selecciono opción "Unicolor"
- [ ] **ENTONCES** debo ver:
  - [ ] Dropdown con colores base activos
  - [ ] Posibilidad de seleccionar UN solo color
  - [ ] Vista previa visual del producto en ese color

### CA-005: Asignar Colores a Producto (Multicolor)
- [ ] **DADO** que estoy creando/editando un producto
- [ ] **CUANDO** selecciono opción "Multicolor"
- [ ] **ENTONCES** debo ver:
  - [ ] Selector múltiple de colores base
  - [ ] Posibilidad de seleccionar 2 o más colores
  - [ ] Orden de los colores seleccionados (arrastrable)
  - [ ] Campo opcional "Descripción visual" (ej: "Rojo con franjas negras")
  - [ ] Vista previa con todos los colores seleccionados
  - [ ] Etiqueta automática: "Bicolor", "Tricolor", "Multicolor"

### CA-006: Editar Color Base
- [ ] **DADO** que selecciono "Editar" en un color
- [ ] **CUANDO** modifico nombre o código hexadecimal
- [ ] **ENTONCES** debo poder guardar cambios
- [ ] **Y** debo ver advertencia: "Este cambio afectará a X productos"
- [ ] **Y** al confirmar, todos los productos con ese color deben actualizarse

### CA-007: Desactivar Color Base
- [ ] **DADO** que intento eliminar un color
- [ ] **CUANDO** ese color está siendo usado en productos
- [ ] **ENTONCES** no debe permitir eliminar
- [ ] **Y** debo ver opción "Desactivar"
- [ ] **Y** al desactivar, el color no aparece en nuevos productos
- [ ] **PERO** productos existentes mantienen ese color

### CA-008: Eliminar Color No Utilizado
- [ ] **DADO** que intento eliminar un color
- [ ] **CUANDO** ese color NO está en ningún producto
- [ ] **ENTONCES** debo ver "¿Confirmar eliminar color [Nombre]?"
- [ ] **Y** al confirmar, el color se elimina permanentemente

### CA-009: Filtrar Productos por Combinación de Colores
- [ ] **DADO** que estoy en el listado de productos
- [ ] **CUANDO** aplico filtro "Contiene color: Rojo"
- [ ] **ENTONCES** debo ver productos que incluyan rojo (unicolor y multicolor)
- [ ] **CUANDO** aplico filtro "Combinación exacta: Rojo, Negro"
- [ ] **ENTONCES** debo ver solo productos con esos dos colores específicos

### CA-010: Búsqueda de Productos por Colores
- [ ] **DADO** que estoy en búsqueda de productos
- [ ] **CUANDO** escribo "rojo negro"
- [ ] **ENTONCES** debo ver productos que contengan ambos colores
- [ ] **CUANDO** escribo "unicolor azul"
- [ ] **ENTONCES** debo ver solo productos de un solo color azul

### CA-011: Reportes por Color
- [ ] **DADO** que accedo a reportes de productos
- [ ] **CUANDO** selecciono "Análisis por Colores"
- [ ] **ENTONCES** debo ver:
  - [ ] Cantidad de productos por color base
  - [ ] Productos unicolor vs multicolor (%)
  - [ ] Combinaciones de colores más usadas
  - [ ] Ventas por color/combinación

## 📐 REGLAS DE NEGOCIO (RN)

### RN-025: Unicidad de Colores en Catálogo
**Contexto**: Al agregar o editar un color en el catálogo base
**Restricción**: No pueden existir dos colores con el mismo nombre exacto
**Validación**:
- Comparación sin distinción de mayúsculas/minúsculas (case-insensitive)
- "Rojo", "ROJO", "rojo" son considerados duplicados
- Nombre debe tener mínimo 3 caracteres, máximo 30 caracteres
- Solo permite letras, espacios y guiones (no caracteres especiales)
**Caso especial**: Colores similares permitidos: "Rojo Oscuro" vs "Rojo Claro"

### RN-026: Formato y Validación de Código Hexadecimal
**Contexto**: Al definir o modificar el código de color
**Restricción**: Solo códigos hexadecimales válidos en formato estándar
**Validación**:
- Formato obligatorio: # seguido de 6 caracteres hexadecimales (0-9, A-F)
- Ejemplos válidos: #FF0000, #000000, #A1B2C3
- Ejemplos inválidos: FF0000 (falta #), #FFF (solo 3 dígitos), #GGHHII (caracteres inválidos)
**Caso especial**: Dos colores pueden compartir el mismo código hexadecimal si tienen nombres diferentes (ej: "Negro" y "Negro Mate" ambos #000000)

### RN-027: Límite de Colores por Artículo
**Contexto**: Al asignar colores a un artículo de medias
**Restricción**: Límites según tipo de coloración
**Validación**:
- Unicolor: Exactamente 1 color (no más, no menos)
- Bicolor: Exactamente 2 colores
- Tricolor: Exactamente 3 colores
- Multicolor: Mínimo 4 colores, máximo 5 colores
**Caso especial**: No se permite crear artículo sin al menos 1 color asignado

### RN-028: Orden de Colores es Significativo
**Contexto**: Al definir combinaciones multicolor en artículos
**Restricción**: El orden determina la apariencia del producto
**Validación**:
- [Rojo, Negro] es diferente de [Negro, Rojo]
- El primer color es el predominante o base
- El último color generalmente representa detalles o bordes
- Cambiar el orden crea una combinación diferente
**Caso especial**: En unicolor el orden no aplica (solo 1 color)

### RN-029: Restricción para Desactivar Colores en Uso
**Contexto**: Al intentar desactivar un color del catálogo base
**Restricción**: Color en uso en artículos no puede eliminarse
**Validación**:
- Si existe al menos 1 artículo usando el color: solo permitir desactivar (no eliminar)
- Color desactivado no aparece en selector de nuevos artículos
- Artículos existentes mantienen el color desactivado visible
**Caso especial**: Color sin uso en ningún artículo puede eliminarse permanentemente

### RN-030: Impacto de Edición de Color en Artículos
**Contexto**: Al editar nombre o código hexadecimal de un color
**Restricción**: Cambio afecta inmediatamente a todos los artículos relacionados
**Validación**:
- Sistema debe mostrar cantidad exacta de artículos afectados antes de confirmar
- Requiere confirmación explícita del admin
- Cambio es retroactivo y automático en todos los artículos
**Caso especial**: Si artículos están en ventas activas, mostrar advertencia adicional

### RN-031: Clasificación Automática por Cantidad de Colores
**Contexto**: Al guardar un artículo con combinación de colores
**Restricción**: Sistema asigna clasificación automática no editable
**Validación**:
- 1 color → Clasificación "Unicolor"
- 2 colores → Clasificación "Bicolor"
- 3 colores → Clasificación "Tricolor"
- 4 o más colores → Clasificación "Multicolor"
**Caso especial**: Clasificación se actualiza automáticamente si se modifica cantidad de colores

### RN-032: Colores Activos en Selección de Artículos
**Contexto**: Al crear o editar un artículo
**Restricción**: Solo colores activos disponibles en selector
**Validación**:
- Dropdown/selector muestra únicamente colores con estado activo=true
- Colores inactivos no aparecen en opciones
- Al desactivar color, artículos existentes lo conservan pero nuevos artículos no pueden usarlo
**Caso especial**: Admin puede reactivar color desactivado para volver a usarlo en nuevos artículos

### RN-033: Búsqueda de Artículos por Color
**Contexto**: Al buscar artículos por combinación de colores
**Restricción**: Distinguir entre búsqueda inclusiva y exacta
**Validación**:
- Búsqueda "Contiene Rojo": muestra todos los artículos que incluyan rojo (unicolor o multicolor)
- Búsqueda "Exacta [Rojo, Negro]": muestra solo artículos con esos 2 colores en ese orden
- Búsqueda por color desactivado: incluye artículos antiguos con ese color
**Caso especial**: Búsqueda multicriterio permite combinar color + marca + tipo

### RN-034: Descripción Visual Opcional para Multicolor
**Contexto**: Al crear artículo multicolor
**Restricción**: Descripción visual ayuda a identificar el patrón
**Validación**:
- Campo opcional solo para artículos con 2 o más colores
- Máximo 100 caracteres
- Ejemplos: "Rayas horizontales rojas y negras", "Base blanca con puntos azules"
- No se valida contenido, solo longitud
**Caso especial**: Unicolor no muestra este campo (bloqueado/oculto)

### RN-035: Reportes y Estadísticas de Colores
**Contexto**: Al generar reportes de ventas o inventario
**Restricción**: Métricas deben reflejar preferencias de mercado
**Validación**:
- Cantidad de artículos por color base (incluir multicolor)
- Porcentaje unicolor vs multicolor vendidos
- Top 5 combinaciones multicolor más vendidas
- Colores con menor rotación (candidatos a descontinuar)
**Caso especial**: Colores desactivados no aparecen en reportes futuros, solo históricos

### RN-036: Generación de SKU Incluye Códigos de Color
**Contexto**: Al crear artículo y generar SKU automático
**Restricción**: SKU debe incluir códigos abreviados de colores en orden
**Validación**:
- Unicolor: Agregar 1 código de color al final del SKU
- Multicolor: Agregar códigos en el orden definido separados por guion
- Ejemplo: ADS-FUT-ALG-3738-ROJ (unicolor rojo)
- Ejemplo: NIK-INV-MIC-UNI-BLA-GRI (bicolor blanco-gris)
**Caso especial**: SKU debe ser único incluso con misma combinación pero diferente orden

## 🗄️ MODELO DE DATOS

### Tabla: `colores`
```sql
CREATE TABLE colores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR(50) UNIQUE NOT NULL,
  codigo_hex VARCHAR(7) NOT NULL, -- #RRGGBB
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Tabla: `producto_colores`
```sql
CREATE TABLE producto_colores (
  producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
  colores TEXT[] NOT NULL, -- Array de nombres de colores
  cantidad_colores INTEGER GENERATED ALWAYS AS (array_length(colores, 1)) STORED,
  tipo_color VARCHAR(20) GENERATED ALWAYS AS (
    CASE
      WHEN array_length(colores, 1) = 1 THEN 'Unicolor'
      WHEN array_length(colores, 1) = 2 THEN 'Bicolor'
      WHEN array_length(colores, 1) = 3 THEN 'Tricolor'
      ELSE 'Multicolor'
    END
  ) STORED,
  descripcion_visual TEXT, -- Opcional: "Rojo con franjas negras"
  PRIMARY KEY (producto_id)
);
```

## 🎨 ESPECIFICACIONES UX/UI

### Pantalla: Catálogo de Colores
```
┌─────────────────────────────────────────┐
│ 🎨 Catálogo de Colores        [+ Agregar]│
├─────────────────────────────────────────┤
│ 🔍 Buscar color...                       │
├──────┬──────────┬─────────┬──────┬──────┤
│Color │ Nombre   │ Código  │Prods.│ Acc. │
├──────┼──────────┼─────────┼──────┼──────┤
│ 🔴  │ Rojo     │#FF0000  │ 23   │✏️ 🗑️│
│ ⚫  │ Negro    │#000000  │ 45   │✏️ 🗑️│
│ 🔵  │ Azul     │#0000FF  │ 18   │✏️ 🗑️│
│ ⚪  │ Blanco   │#FFFFFF  │ 31   │✏️ 🗑️│
└─────────────────────────────────────────┘
```

### Selector de Colores en Producto
```
┌─────────────────────────────────────────┐
│ Tipo de Color:                           │
│ ○ Unicolor    ● Multicolor              │
│                                          │
│ Seleccionar Colores:                     │
│ ┌─────────────────────────────────────┐ │
│ │ [Rojo ×] [Negro ×]                  │ │
│ │ ▼ Agregar color...                  │ │
│ └─────────────────────────────────────┘ │
│                                          │
│ Vista Previa:                            │
│ ┌─────────────────┐                     │
│ │ 🔴⚫ Bicolor     │                     │
│ │ Rojo y Negro    │                     │
│ └─────────────────┘                     │
│                                          │
│ Descripción Visual (opcional):           │
│ [Rojo con franjas negras horizontales]  │
└─────────────────────────────────────────┘
```

## 📋 ESTADO DE IMPLEMENTACIÓN

### Backend (Supabase)
- [ ] Crear tabla `colores` con validaciones
- [ ] Crear tabla `producto_colores` con columnas generadas
- [ ] Edge Function: `GET /api/colores` - Listar colores activos
- [ ] Edge Function: `POST /api/colores` - Crear color con validación de duplicados
- [ ] Edge Function: `PUT /api/colores/:id` - Editar color
- [ ] Edge Function: `DELETE /api/colores/:id` - Eliminar/desactivar color
- [ ] RLS Policy: Solo admin/gerente puede gestionar colores
- [ ] Trigger: Validar que colores en producto_colores existen en tabla colores
- [ ] Query: Obtener productos por combinación de colores
- [ ] Query: Estadísticas de uso de colores

### Frontend (Flutter)
- [ ] Screen: `ColorCatalogPage` - CRUD de colores base
- [ ] Component: `ColorPicker` - Selector de colores con preview
- [ ] Component: `ProductColorSelector` - Selector unicolor/multicolor
- [ ] Component: `ColorChipList` - Lista de colores seleccionados (arrastrable)
- [ ] Bloc: `ColorCatalogBloc` - Estado del catálogo
- [ ] Bloc: `ProductColorBloc` - Estado de selección de colores
- [ ] Repository: `ColorRepository` - Llamadas a API
- [ ] Validación: Unicolor (1 color), Multicolor (2-5 colores)
- [ ] Feature: Búsqueda y filtrado por colores

### UX/UI Design
- [ ] Design: Pantalla de catálogo de colores
- [ ] Design: Selector de colores en formulario de producto
- [ ] Design: Vista previa visual de combinaciones
- [ ] Design: Estados de validación y errores
- [ ] Component: Color picker con hexadecimal
- [ ] Component: Drag & drop para ordenar colores
- [ ] Design: Filtros de búsqueda por color
- [ ] Design: Reportes visuales por color

### QA Testing
- [ ] Test: CRUD completo de colores base
- [ ] Test: Validación de colores duplicados
- [ ] Test: Asignar unicolor a producto
- [ ] Test: Asignar multicolor (2-5 colores) a producto
- [ ] Test: Orden de colores en combinaciones
- [ ] Test: Editar color afecta a productos existentes
- [ ] Test: Desactivar color no permite uso en nuevos productos
- [ ] Test: Eliminar color solo si no está en uso
- [ ] Test: Filtrar productos por color
- [ ] Test: Búsqueda por combinación de colores
- [ ] Test: Reportes de análisis por colores

## ✅ DEFINICIÓN DE TERMINADO (DoD)

- [ ] Todos los criterios de aceptación cumplidos
- [ ] CRUD de colores base funcional
- [ ] Selector unicolor/multicolor implementado
- [ ] Validaciones de negocio aplicadas
- [ ] Filtros y búsquedas por color operativos
- [ ] Reportes de análisis disponibles
- [ ] Tests de integración pasando
- [ ] Documentación técnica actualizada
- [ ] UX/UI sigue Design System
- [ ] QA valida todos los flujos

## 📝 NOTAS TÉCNICAS

### Ejemplos de Combinaciones:
```
Producto 1: ["Rojo"] → Unicolor
Producto 2: ["Rojo", "Negro"] → Bicolor
Producto 3: ["Azul", "Rojo", "Blanco"] → Tricolor
Producto 4: ["Negro", "Blanco", "Gris", "Rojo"] → Multicolor
```

### Query de Búsqueda por Colores:
```sql
-- Productos que contienen rojo
SELECT p.* FROM productos p
JOIN producto_colores pc ON p.id = pc.producto_id
WHERE 'Rojo' = ANY(pc.colores);

-- Productos con combinación exacta
SELECT p.* FROM productos p
JOIN producto_colores pc ON p.id = pc.producto_id
WHERE pc.colores = ARRAY['Rojo', 'Negro']::TEXT[];
```

## 🔗 DEPENDENCIAS

- **Depende de**: E002-HU-001 (Ver Catálogo de Productos)
- **Bloqueante para**: E002-HU-006 (Gestionar Tallas), E003-HU-001 (Registrar Venta)
- **Relacionada con**: E002-HU-003 (Agregar Producto), E002-HU-004 (Editar Producto)

## 📊 ESTIMACIÓN

**Story Points**: 8 pts

**Justificación**:
- Complejidad media-alta por modelo de datos con arrays
- CRUD completo de catálogo base
- Selector unicolor/multicolor con validaciones
- Filtros y búsquedas por combinaciones
- Reportes de análisis
- Testing extensivo de todas las combinaciones posibles
