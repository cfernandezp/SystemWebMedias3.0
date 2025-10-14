# DISEÑO DE ARQUITECTURA - Wizard Creación Productos Maestros + Artículos

**Fecha**: 2025-10-14
**Responsable**: web-architect-expert
**Épica**: E002 - Gestión de Productos de Medias
**Estado**: Diseño Aprobado

---

## 📊 RESUMEN EJECUTIVO

### Requerimientos Confirmados del Usuario

**1. Artículos derivados**: NO siempre se crean con producto maestro
   - Pueden existir productos maestros sin artículos
   - Se pueden crear artículos posteriormente

**2. Precio por color**: SÍ puede variar
   - Ejemplo: Media dorada $7,000 vs negra $5,000
   - Requiere tabla editable en wizard

**3. Tiendas**:
   - **Funcionalidad A**: Inventario inicial (stock en tienda) → ❌ NO VIABLE (ver sección 4.3)
   - **Funcionalidad B**: Precios diferenciados por tienda → ❌ NO EXISTE TABLA (ver sección 4.3)
   - **DECISIÓN**: Eliminar Paso 3 del wizard

**4. Agregar colores después**: SÍ
   - Pantalla de detalle producto maestro con secciones separadas
   - Permitir crear artículos standalone

**5. Frecuencia**: Diariamente (10-20 productos/día)
   - **MODO EXPERTO debe ser DEFAULT**

**6. SKU**: Auto-generado (MARCA-TIPO-MATERIAL-TALLA-COLOR1...)

**7. Permisos**: Solo ADMINISTRADOR puede crear productos

---

## 🎯 1. CONFIRMACIÓN DE VIABILIDAD TÉCNICA

### 1.1 Validación de Tablas Existentes

#### ✅ Tablas Confirmadas en Migraciones

**Tabla: `productos_maestros`** (líneas 526-564 en 00000000000003_catalog_tables.sql)
```sql
productos_maestros (
    id UUID PRIMARY KEY,
    marca_id UUID NOT NULL REFERENCES marcas(id),
    material_id UUID NOT NULL REFERENCES materiales(id),
    tipo_id UUID NOT NULL REFERENCES tipos(id),
    sistema_talla_id UUID NOT NULL REFERENCES sistemas_talla(id),
    descripcion TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
)
```

**Tabla: `articulos`** (líneas 577-637 en 00000000000003_catalog_tables.sql)
```sql
articulos (
    id UUID PRIMARY KEY,
    producto_maestro_id UUID NOT NULL REFERENCES productos_maestros(id),
    sku TEXT NOT NULL UNIQUE,
    tipo_coloracion VARCHAR(10) NOT NULL,  -- 'unicolor', 'bicolor', 'tricolor'
    colores_ids UUID[] NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
)
```

**Catálogos relacionados**:
- `marcas`: Códigos de 3 letras (ADS, NIK, PUM)
- `materiales`: Códigos de 3 letras (ALG, MIC, BAM)
- `tipos`: Códigos de 3 letras (FUT, INV, TOB)
- `sistemas_talla`: UNICA, NUMERO, LETRA, RANGO
- `colores`: Catálogo con códigos hex y tipo (único/compuesto)

---

### 1.2 Análisis de Inventario/Stock

#### ❌ NO EXISTE: Tabla `inventario_tiendas`

**Búsqueda realizada**:
- Migración `00000000000003_catalog_tables.sql`: ❌ No contiene tabla de inventario
- Migración `00000000000004_sales_tables.sql`: Solo `ventas`, `ventas_detalles`, `comisiones`
- Grep "inventario": ❌ No encontrada tabla en migraciones
- Grep "stock": ❌ Solo tabla `productos` legacy con campo `stock_actual` (no por tienda)

**Tabla `productos` legacy** (líneas 72-95 en 00000000000003_catalog_tables.sql):
```sql
productos (
    id UUID,
    nombre TEXT,
    precio DECIMAL(10, 2),
    stock_actual INTEGER DEFAULT 0,  -- ⚠️ Stock global, NO por tienda
    stock_maximo INTEGER DEFAULT 100,
    activo BOOLEAN
)
```
- Esta tabla es anterior al modelo productos_maestros/articulos
- No soporta stock por tienda
- No tiene relación con articulos

---

### 1.3 Conclusión: Funcionalidades Viables

| Funcionalidad | Estado | Justificación |
|--------------|--------|---------------|
| **Paso 1: Producto Maestro** | ✅ VIABLE | Tabla productos_maestros completa |
| **Paso 2: Artículos + Colores + Precios** | ✅ VIABLE | Tabla articulos con precio individual |
| **Paso 3A: Stock Inicial** | ❌ NO VIABLE | Tabla inventario_tiendas NO existe |
| **Paso 3B: Precios por Tienda** | ❌ NO VIABLE | Tabla precios_tienda NO existe |

**DECISIÓN ARQUITECTÓNICA**:
- ✅ Implementar Wizard de 2 pasos (Producto Maestro + Artículos)
- ❌ Eliminar Paso 3 (Tiendas) hasta HU-008 (Asignar Stock)
- ✅ Precio se maneja a nivel artículo (única fuente de verdad)

---

## 🏗️ 2. ARQUITECTURA DE FEATURES

### 2.1 Feature Principal: Wizard Creación Productos

**Objetivo**: Crear productos maestros con artículos especializados de forma eficiente para uso diario.

**Sub-features**:

#### A. Modo Experto (DEFAULT - Alta Frecuencia)
- Vista compacta con todo en una pantalla
- Producto maestro + N artículos en formulario único
- Tabla editable de artículos con drag & drop
- Sin validación step-by-step (validación final al guardar)

#### B. Modo Guiado (OPCIONAL - Baja Frecuencia)
- Wizard de 2 pasos con navegación secuencial
- Paso 1: Producto Maestro
- Paso 2: Artículos (tabla editable)
- Ideal para usuarios inexpertos

#### C. Pantalla Detalle Producto Maestro
- Tabs: [Características] [Artículos] [Historial]
- **Tab Características**: Editable por admin
- **Tab Artículos**:
  - Lista con botón "+ Crear Artículo"
  - Cada fila: SKU, Colores (preview), Precio, Acciones
  - Expandible: Mostrar detalles completos

#### D. Flujo Crear Artículo Standalone
- Selecciona producto maestro existente
- Configura colores (unicolor/bicolor/tricolor)
- Precio individual
- Genera SKU automático

---

### 2.2 Estructura de Archivos Propuesta

```
lib/features/
├── productos_maestros/
│   ├── data/
│   │   ├── models/
│   │   │   ├── producto_maestro_model.dart          (✅ EXISTE - HU-006)
│   │   │   └── producto_maestro_filter_model.dart   (✅ EXISTE - HU-006)
│   │   ├── datasources/
│   │   │   └── producto_maestro_remote_datasource.dart (✅ EXISTE)
│   │   └── repositories/
│   │       └── producto_maestro_repository_impl.dart   (✅ EXISTE)
│   ├── domain/
│   │   ├── usecases/
│   │   │   ├── crear_producto_maestro.dart          (✅ EXISTE)
│   │   │   └── listar_productos_maestros.dart       (✅ EXISTE)
│   │   └── repositories/
│   │       └── producto_maestro_repository.dart     (✅ EXISTE)
│   └── presentation/
│       ├── pages/
│       │   ├── productos_maestros_list_page.dart    (✅ EXISTE - HU-006)
│       │   ├── producto_maestro_form_page.dart      (✅ EXISTE - HU-006)
│       │   ├── producto_maestro_detail_page.dart    (⚠️ EXISTE PLACEHOLDER)
│       │   ├── producto_creation_expert_page.dart   (🆕 NUEVO - Modo Experto)
│       │   └── producto_creation_wizard_page.dart   (🆕 NUEVO - Modo Guiado)
│       ├── widgets/
│       │   ├── producto_maestro_card.dart           (✅ EXISTE)
│       │   ├── articulos_table_editor.dart          (🆕 NUEVO - Tabla editable)
│       │   ├── articulo_row_form.dart               (🆕 NUEVO - Fila editable)
│       │   ├── modo_selector_toggle.dart            (🆕 NUEVO - Experto/Guiado)
│       │   └── producto_summary_widget.dart         (🆕 NUEVO - Vista previa)
│       └── bloc/
│           ├── producto_maestro_bloc.dart           (✅ EXISTE)
│           ├── producto_maestro_event.dart          (✅ EXISTE)
│           └── producto_maestro_state.dart          (✅ EXISTE)
│
├── articulos/
│   ├── data/
│   │   ├── models/
│   │   │   ├── articulo_model.dart                  (✅ EXISTE - HU-007)
│   │   │   └── crear_articulo_request.dart          (✅ EXISTE - HU-007)
│   │   ├── datasources/
│   │   │   └── articulos_remote_datasource.dart     (✅ EXISTE)
│   │   └── repositories/
│   │       └── articulos_repository_impl.dart       (✅ EXISTE)
│   ├── domain/
│   │   ├── usecases/
│   │   │   ├── generar_sku_usecase.dart             (✅ EXISTE)
│   │   │   ├── crear_articulo_usecase.dart          (✅ EXISTE)
│   │   │   └── crear_articulos_batch_usecase.dart   (🆕 NUEVO - Batch creation)
│   │   └── repositories/
│   │       └── articulos_repository.dart            (✅ EXISTE)
│   └── presentation/
│       ├── pages/
│       │   ├── articulos_list_page.dart             (✅ EXISTE - HU-007)
│       │   ├── articulo_form_page.dart              (✅ EXISTE - HU-007)
│       │   └── articulo_standalone_dialog.dart      (🆕 NUEVO - Crear standalone)
│       ├── widgets/
│       │   ├── articulo_card.dart                   (✅ EXISTE)
│       │   ├── color_selector_articulo_widget.dart  (✅ EXISTE)
│       │   ├── colores_preview_widget.dart          (✅ EXISTE)
│       │   └── sku_preview_widget.dart              (✅ EXISTE)
│       └── bloc/
│           ├── articulos_bloc.dart                  (✅ EXISTE)
│           ├── articulos_event.dart                 (✅ EXISTE)
│           └── articulos_state.dart                 (✅ EXISTE)
│
└── shared/widgets/                                   (🆕 NUEVO - Componentes reutilizables)
    ├── editable_data_table.dart                     (🆕 NUEVO - Tabla genérica)
    ├── color_multi_selector.dart                    (🆕 NUEVO - Grid de colores)
    └── precio_input_group.dart                      (🆕 NUEVO - Input con validación)
```

**Leyenda**:
- ✅ EXISTE: Componente ya implementado en HU previas
- ⚠️ EXISTE PLACEHOLDER: Componente existe pero requiere expansión
- 🆕 NUEVO: Componente a crear en esta arquitectura

---

## 🔄 3. FLUJOS DE NAVEGACIÓN

### 3.1 Flujo A: Usuario crea producto con artículos inmediatamente

```
┌─────────────────────────────────────┐
│ ProductosMaestrosListPage           │
│ - Grid responsive de productos      │
│ - Contador: X activos / Y inactivos │
│ - SearchBar + Filtros               │
└─────────────────────────────────────┘
             │ Click [+ Nuevo Producto] (FAB)
             ↓
┌─────────────────────────────────────┐
│ ProductoCreationExpertPage (DEFAULT)│
│ ┌─────────────────────────────────┐ │
│ │ [Modo: Experto ▼] [Guiado]     │ │ ← Toggle selector
│ └─────────────────────────────────┘ │
│                                     │
│ SECCIÓN 1: Producto Maestro         │
│ ┌─────────────────────────────────┐ │
│ │ Marca:     [Dropdown ▼]        │ │
│ │ Material:  [Dropdown ▼]        │ │
│ │ Tipo:      [Dropdown ▼]        │ │
│ │ Tallas:    [Dropdown ▼]        │ │
│ │ Descripción: [Textarea]        │ │
│ └─────────────────────────────────┘ │
│                                     │
│ SECCIÓN 2: Artículos (Opcional)     │
│ ┌─────────────────────────────────┐ │
│ │ ✓ Crear artículos ahora         │ │ ← Checkbox
│ │                                 │ │
│ │ Tabla Editable:                 │ │
│ │ ┌────┬──────┬──────┬─────────┐ │ │
│ │ │ #  │Tipo  │Color │Precio   │ │ │
│ │ ├────┼──────┼──────┼─────────┤ │ │
│ │ │ 1  │Uni   │Rojo  │$7,000   │ │ │
│ │ │ 2  │Bi    │N-B   │$8,500   │ │ │
│ │ │ 3  │Tri   │A-R-B │$10,000  │ │ │
│ │ └────┴──────┴──────┴─────────┘ │ │
│ │ [+ Agregar Fila]               │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Cancelar]          [Crear Todo]    │
└─────────────────────────────────────┘
             │ Click [Crear Todo]
             ↓
        ┌──────────────┐
        │ Loading...   │
        │ Creando 1+3  │
        └──────────────┘
             ↓
┌─────────────────────────────────────┐
│ ProductoMaestroDetailPage           │
│ ┌─────────────────────────────────┐ │
│ │ [Características] [Artículos]   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Tab Artículos (activo):             │
│ ┌────────┬───────┬────────┬──────┐ │
│ │ SKU    │Colores│Precio  │Stock │ │
│ ├────────┼───────┼────────┼──────┤ │
│ │ADS-... │🔴 Rojo│$7,000  │0     │ │
│ │ADS-... │⚫🔴 N-B│$8,500  │0     │ │
│ │ADS-... │🔵🔴⚪..│$10,000 │0     │ │
│ └────────┴───────┴────────┴──────┘ │
│                                     │
│ [+ Crear Artículo]                  │
└─────────────────────────────────────┘
```

---

### 3.2 Flujo B: Usuario crea producto maestro, luego artículos después

```
┌─────────────────────────────────────┐
│ ProductoCreationExpertPage          │
│                                     │
│ SECCIÓN 1: Producto Maestro         │
│ [Campos completados...]             │
│                                     │
│ SECCIÓN 2: Artículos                │
│ ┌─────────────────────────────────┐ │
│ │ ☐ Crear artículos ahora         │ │ ← UNCHECKED
│ └─────────────────────────────────┘ │
│                                     │
│ [Cancelar]  [Crear Producto Maestro]│
└─────────────────────────────────────┘
             │ Click [Crear Producto Maestro]
             ↓
┌─────────────────────────────────────┐
│ ProductoMaestroDetailPage           │
│                                     │
│ ⚠️ Warning:                         │
│ "Este producto no tiene artículos"  │
│                                     │
│ Tab Artículos:                      │
│ ┌─────────────────────────────────┐ │
│ │    📦 Sin artículos aún         │ │
│ │                                 │ │
│ │    [+ Crear Primer Artículo]    │ │ ← Botón destacado
│ │                                 │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
             │ Click [+ Crear Primer Artículo]
             ↓
┌─────────────────────────────────────┐
│ ArticuloStandaloneDialog (Modal)    │
│                                     │
│ Producto Maestro:                   │
│ [Nike - Algodón - Deportiva]        │ ← Readonly
│                                     │
│ Tipo Coloración:                    │
│ ○ Unicolor ◉ Bicolor ○ Tricolor    │
│                                     │
│ Colores:                            │
│ [Grid de colores activos]           │
│ ✓ Rojo  ✓ Negro                    │
│                                     │
│ SKU Generado:                       │
│ NIK-DEP-ALG-35-36-ROJ-NEG           │
│                                     │
│ Precio:                             │
│ $[8,500.00]                         │
│                                     │
│ [Cancelar]          [Crear Artículo]│
└─────────────────────────────────────┘
             │ Click [Crear Artículo]
             ↓
┌─────────────────────────────────────┐
│ ProductoMaestroDetailPage           │
│ (Actualizado con nuevo artículo)    │
│                                     │
│ Tab Artículos:                      │
│ ┌────────┬───────┬────────┬──────┐ │
│ │ SKU    │Colores│Precio  │Stock │ │
│ ├────────┼───────┼────────┼──────┤ │
│ │NIK-... │⚫🔴 N-R│$8,500  │0     │ │
│ └────────┴───────┴────────┴──────┘ │
│                                     │
│ [+ Crear Artículo]                  │
└─────────────────────────────────────┘
```

---

### 3.3 Flujo C: Modo Guiado (Wizard 2 Pasos)

```
┌─────────────────────────────────────┐
│ ProductoCreationWizardPage          │
│ ┌─────────────────────────────────┐ │
│ │ [Modo: Guiado ▼] [Experto]     │ │ ← Toggle cambia página
│ └─────────────────────────────────┘ │
│                                     │
│ Stepper: ━━━━━━━ ⚪ ⚪              │
│         Paso 1   2  (3 eliminado)  │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ PASO 1: Producto Maestro        │ │
│ │                                 │ │
│ │ Marca:     [Adidas ▼]          │ │
│ │ Material:  [Algodón ▼]         │ │
│ │ Tipo:      [Fútbol ▼]          │ │
│ │ Tallas:    [Número 35-44 ▼]    │ │
│ │ Descripción: [Línea premium]   │ │
│ │                                 │ │
│ │ Vista Previa:                   │ │
│ │ "Adidas - Fútbol - Algodón -   │ │
│ │  Número (35-44)"                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Cancelar]               [Siguiente]│
└─────────────────────────────────────┘
             │ Click [Siguiente]
             ↓
┌─────────────────────────────────────┐
│ ProductoCreationWizardPage          │
│                                     │
│ Stepper: ⚫ ━━━━━━━ ⚪              │
│         1   Paso 2  (3 eliminado)  │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ PASO 2: Artículos (Opcional)    │ │
│ │                                 │ │
│ │ Tabla Editable:                 │ │
│ │ ┌────┬──────┬──────┬─────────┐ │ │
│ │ │ #  │Tipo  │Color │Precio   │ │ │
│ │ ├────┼──────┼──────┼─────────┤ │ │
│ │ │ 1  │Uni   │[▼]   │[$     ] │ │ │
│ │ └────┴──────┴──────┴─────────┘ │ │
│ │ [+ Agregar Fila]               │ │
│ │                                 │ │
│ │ Tip: Puedes omitir este paso   │ │
│ │ y agregar artículos después.    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Atrás] [Omitir]         [Crear]   │
└─────────────────────────────────────┘
```

---

## 🎨 4. COMPONENTES UI REQUERIDOS

### 4.1 Componentes Nuevos a Crear

#### A. **ArticulosTableEditor** (Widget Clave)
**Ubicación**: `lib/shared/widgets/editable_data_table.dart`

**Funcionalidad**:
- Tabla editable con filas dinámicas
- Cada fila = 1 artículo potencial
- Columnas:
  - **#**: Número de fila
  - **Tipo**: Dropdown (Unicolor/Bicolor/Tricolor)
  - **Colores**: Selector múltiple con drag & drop
  - **Precio**: Input numérico con formato moneda
  - **Acciones**: [🗑️ Eliminar] [⬆️⬇️ Reordenar]

**Props**:
```dart
class ArticulosTableEditor extends StatefulWidget {
  final List<ArticuloRow> initialArticulos;
  final String productoMaestroId;
  final Function(List<ArticuloRow>) onArticulosChanged;
  final bool readOnly;

  const ArticulosTableEditor({
    this.initialArticulos = const [],
    required this.productoMaestroId,
    required this.onArticulosChanged,
    this.readOnly = false,
  });
}

class ArticuloRow {
  String? id;                          // null si es nuevo
  String tipoColoracion;               // 'unicolor', 'bicolor', 'tricolor'
  List<String> coloresIds;             // UUIDs ordenados
  double precio;
  String? skuGenerado;                 // Generado en tiempo real
}
```

**Validaciones en tiempo real**:
- Tipo unicolor → Solo 1 color seleccionable
- Tipo bicolor → Exactamente 2 colores
- Tipo tricolor → Exactamente 3 colores
- Precio > 0
- SKU único (advertencia si duplicado)

---

#### B. **ColorMultiSelector** (Componente de Selección)
**Ubicación**: `lib/shared/widgets/color_multi_selector.dart`

**Funcionalidad**:
- Grid responsive de colores activos
- Checkbox por cada color
- Preview visual (círculo con color hex)
- Reordenamiento drag & drop (para bicolor/tricolor)
- Indicador de orden (1, 2, 3)

**Props**:
```dart
class ColorMultiSelector extends StatefulWidget {
  final int maxSelectable;             // 1, 2 o 3
  final List<ColorModel> availableColors;
  final List<String> selectedColorIds;
  final Function(List<String>) onSelectionChanged;
  final bool enableReorder;            // true para bicolor/tricolor

  const ColorMultiSelector({
    required this.maxSelectable,
    required this.availableColors,
    required this.selectedColorIds,
    required this.onSelectionChanged,
    this.enableReorder = true,
  });
}
```

**UI**:
```
┌───────────────────────────────┐
│ Selecciona hasta 2 colores:   │
├───────────────────────────────┤
│ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐    │
│ │1⃣│ │  │ │2⃣│ │  │ │  │    │ ← Números indican orden
│ │🔴│ │⚫│ │🔵│ │⚪│ │🟡│    │ ← Preview color
│ │✓ │ │  │ │✓ │ │  │ │  │    │ ← Checkboxes
│ └──┘ └──┘ └──┘ └──┘ └──┘    │
│ Rojo Negro Azul Blanco Dorado│
└───────────────────────────────┘

Orden: Rojo → Azul  [Invertir ↕️]  ← Botón quick swap
```

---

#### C. **PrecioInputGroup** (Input con Validación)
**Ubicación**: `lib/shared/widgets/precio_input_group.dart`

**Funcionalidad**:
- Input numérico con formato moneda COP
- Validación en tiempo real (>= $0.01)
- Sugerencia de rango opcional (según tipo producto)
- Indicador visual de validez

**Props**:
```dart
class PrecioInputGroup extends StatelessWidget {
  final double? initialValue;
  final Function(double) onPrecioChanged;
  final double? minPrecio;             // Default 0.01
  final String? precioSugerido;        // Ej: "$5,000 - $15,000"
  final bool required;

  const PrecioInputGroup({
    this.initialValue,
    required this.onPrecioChanged,
    this.minPrecio = 0.01,
    this.precioSugerido,
    this.required = true,
  });
}
```

**UI**:
```
┌─────────────────────────────┐
│ Precio *                    │
│ ┌─────────────────────────┐ │
│ │ $[15,000.00]      ✓     │ │ ← Checkmark verde si válido
│ └─────────────────────────┘ │
│ 💡 Rango sugerido: $5K-$20K │ ← Hint opcional
└─────────────────────────────┘
```

---

#### D. **ModoSelectorToggle** (Switcher Experto/Guiado)
**Ubicación**: `lib/features/productos_maestros/presentation/widgets/modo_selector_toggle.dart`

**Funcionalidad**:
- Toggle button para cambiar entre modos
- Persiste preferencia en localStorage
- Indicador visual del modo activo
- Tooltip explicativo

**Props**:
```dart
class ModoSelectorToggle extends StatelessWidget {
  final ModoCreacion modoActual;       // 'experto' | 'guiado'
  final Function(ModoCreacion) onModoChanged;

  const ModoSelectorToggle({
    required this.modoActual,
    required this.onModoChanged,
  });
}
```

**UI**:
```
┌────────────────────────────┐
│ Modo: [Experto] [Guiado]   │ ← Pills con selected state
│       ━━━━━━━              │
│       └─ Activo             │
└────────────────────────────┘

Tooltip Experto: "Formulario compacto para creación rápida"
Tooltip Guiado: "Wizard paso a paso para usuarios nuevos"
```

---

#### E. **ProductoSummaryWidget** (Vista Previa)
**Ubicación**: `lib/features/productos_maestros/presentation/widgets/producto_summary_widget.dart`

**Funcionalidad**:
- Resumen visual del producto maestro + artículos
- Preview de SKUs generados
- Contador de artículos por tipo
- Precio mínimo/máximo

**Props**:
```dart
class ProductoSummaryWidget extends StatelessWidget {
  final ProductoMaestroModel productoMaestro;
  final List<ArticuloRow> articulos;

  const ProductoSummaryWidget({
    required this.productoMaestro,
    required this.articulos,
  });
}
```

**UI**:
```
┌────────────────────────────────────┐
│ 📊 RESUMEN                         │
├────────────────────────────────────┤
│ Producto Maestro:                  │
│ Adidas - Fútbol - Algodón - Nº     │
│                                    │
│ Artículos: 3                       │
│ ├─ Unicolor: 1 ($7,000)           │
│ ├─ Bicolor: 1 ($8,500)            │
│ └─ Tricolor: 1 ($10,000)          │
│                                    │
│ Rango de precios: $7K - $10K       │
│                                    │
│ SKUs a generar:                    │
│ • ADS-FUT-ALG-35-36-ROJ            │
│ • ADS-FUT-ALG-35-36-NEG-BLA        │
│ • ADS-FUT-ALG-35-36-AZU-ROJ-BLA    │
└────────────────────────────────────┘
```

---

### 4.2 Componentes Existentes a Reutilizar

**De HU-006 (Productos Maestros)**:
- ✅ `producto_maestro_card.dart`: Card con hover animation
- ✅ `producto_maestro_filter_widget.dart`: Panel filtros
- ✅ `combinacion_warning_card.dart`: Advertencias comerciales

**De HU-007 (Artículos)**:
- ✅ `articulo_card.dart`: Card con SKU y colores
- ✅ `color_selector_articulo_widget.dart`: Selector tipo coloración
- ✅ `colores_preview_widget.dart`: Preview círculo/rectángulo dividido
- ✅ `sku_preview_widget.dart`: Preview SKU con copy-to-clipboard

**De shared (Corporativos)**:
- ✅ `CorporateButton`: Botón estándar con variantes
- ✅ `CorporateFormField`: Input pill-shaped

---

## 🔧 5. BLOCS/EVENTOS/ESTADOS

### 5.1 Nuevo Bloc: ProductoCompletoBloc

**Responsabilidad**: Coordinar creación de producto maestro + artículos en lote.

**Archivo**: `lib/features/productos_maestros/presentation/bloc/producto_completo_bloc.dart`

#### Eventos

```dart
// 🆕 NUEVO
abstract class ProductoCompletoEvent extends Equatable {}

class CrearProductoCompletoEvent extends ProductoCompletoEvent {
  final ProductoMaestroData productoMaestro;
  final List<ArticuloData> articulos;      // Puede estar vacío

  CrearProductoCompletoEvent({
    required this.productoMaestro,
    this.articulos = const [],
  });
}

class ValidarArticulosEvent extends ProductoCompletoEvent {
  final String productoMaestroId;
  final List<ArticuloData> articulos;

  ValidarArticulosEvent({
    required this.productoMaestroId,
    required this.articulos,
  });
}

class GenerarSkusPreviewEvent extends ProductoCompletoEvent {
  final ProductoMaestroData productoMaestro;
  final List<ArticuloData> articulos;

  GenerarSkusPreviewEvent({
    required this.productoMaestro,
    required this.articulos,
  });
}

// Clases de datos
class ProductoMaestroData {
  final String marcaId;
  final String materialId;
  final String tipoId;
  final String sistemaTallaId;
  final String? descripcion;
}

class ArticuloData {
  final String tipoColoracion;         // 'unicolor', 'bicolor', 'tricolor'
  final List<String> coloresIds;       // Ordenados
  final double precio;
}
```

#### Estados

```dart
// 🆕 NUEVO
abstract class ProductoCompletoState extends Equatable {}

class ProductoCompletoInitial extends ProductoCompletoState {}

class ProductoCompletoValidating extends ProductoCompletoState {}

class ArticulosValidados extends ProductoCompletoState {
  final List<SkuPreview> skusGenerados;
  final List<String> warnings;             // Duplicados, advertencias

  ArticulosValidados({
    required this.skusGenerados,
    this.warnings = const [],
  });
}

class ProductoCompletoCreating extends ProductoCompletoState {
  final int totalArticulos;
  final int articulosCreados;              // Progress tracking

  ProductoCompletoCreating({
    required this.totalArticulos,
    required this.articulosCreados,
  });
}

class ProductoCompletoCreated extends ProductoCompletoState {
  final String productoMaestroId;
  final int articulosCreados;
  final String nombreCompleto;
  final List<String> skusCreados;

  ProductoCompletoCreated({
    required this.productoMaestroId,
    required this.articulosCreados,
    required this.nombreCompleto,
    required this.skusCreados,
  });
}

class ProductoCompletoError extends ProductoCompletoState {
  final String message;
  final String? hint;

  ProductoCompletoError({required this.message, this.hint});
}

// Clase auxiliar
class SkuPreview {
  final String sku;
  final String tipoColoracion;
  final List<String> coloresNombres;
  final double precio;
  final bool esDuplicado;

  SkuPreview({
    required this.sku,
    required this.tipoColoracion,
    required this.coloresNombres,
    required this.precio,
    this.esDuplicado = false,
  });
}
```

---

### 5.2 Extensión de Blocs Existentes

#### A. **ProductoMaestroBloc** (Existente - HU-006)
**Cambios**: ❌ NO requiere cambios
**Uso**: Crear solo producto maestro (flujo B)

#### B. **ArticulosBloc** (Existente - HU-007)
**Cambios**: ✅ Agregar evento para creación batch

```dart
// 🆕 NUEVO EVENTO
class CrearArticulosBatchEvent extends ArticulosEvent {
  final String productoMaestroId;
  final List<CrearArticuloRequest> requests;

  CrearArticulosBatchEvent({
    required this.productoMaestroId,
    required this.requests,
  });
}

// 🆕 NUEVO ESTADO
class ArticulosBatchCreating extends ArticulosState {
  final int total;
  final int completed;

  ArticulosBatchCreating({required this.total, required this.completed});
}

class ArticulosBatchCreated extends ArticulosState {
  final List<ArticuloModel> articulosCreados;
  final List<String> errores;             // Errores parciales

  ArticulosBatchCreated({
    required this.articulosCreados,
    this.errores = const [],
  });
}
```

---

## 🗄️ 6. BACKEND - ENDPOINTS NECESARIOS

### 6.1 Validación: Funciones RPC Existentes

#### ✅ Funciones de HU-006 (Producto Maestro)
- `crear_producto_maestro(marca_id, material_id, tipo_id, sistema_talla_id, descripcion)`
- `listar_productos_maestros(filtros)`
- `obtener_producto_maestro(producto_id)`
- `editar_producto_maestro(producto_id, ...)`
- `desactivar_producto_maestro(producto_id, desactivar_articulos)`
- `eliminar_producto_maestro(producto_id)`
- `validar_combinacion_comercial(tipo_id, sistema_talla_id)`

#### ✅ Funciones de HU-007 (Artículos)
- `generar_sku(producto_maestro_id, colores_ids[])`
- `validar_sku_unico(sku, articulo_id?)`
- `crear_articulo(producto_maestro_id, colores_ids[], precio)`
- `listar_articulos(filtros, limit, offset)`
- `obtener_articulo(articulo_id)`
- `editar_articulo(articulo_id, precio?, activo?)`
- `eliminar_articulo(articulo_id)`
- `desactivar_articulo(articulo_id)`

---

### 6.2 Nueva Función RPC Requerida

#### 🆕 `crear_producto_completo()`

**Propósito**: Creación transaccional de producto maestro + N artículos en una sola operación.

**Archivo**: `supabase/migrations/00000000000005_functions.sql`

**Signature**:
```sql
CREATE OR REPLACE FUNCTION crear_producto_completo(
    p_producto_maestro JSONB,
    p_articulos JSONB[]
) RETURNS JSONB AS $$
DECLARE
    v_producto_maestro_id UUID;
    v_articulo JSONB;
    v_articulo_id UUID;
    v_sku TEXT;
    v_articulos_creados JSONB[] := ARRAY[]::JSONB[];
    v_error_hint TEXT;
BEGIN
    -- Validar permisos (solo ADMIN)
    IF (SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) != 'ADMIN' THEN
        v_error_hint := 'permission_denied';
        RAISE EXCEPTION 'Solo administradores pueden crear productos';
    END IF;

    -- 1. Crear producto maestro
    INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion)
    VALUES (
        (p_producto_maestro->>'marca_id')::UUID,
        (p_producto_maestro->>'material_id')::UUID,
        (p_producto_maestro->>'tipo_id')::UUID,
        (p_producto_maestro->>'sistema_talla_id')::UUID,
        p_producto_maestro->>'descripcion'
    )
    RETURNING id INTO v_producto_maestro_id;

    -- 2. Crear artículos (si hay)
    IF p_articulos IS NOT NULL AND array_length(p_articulos, 1) > 0 THEN
        FOREACH v_articulo IN ARRAY p_articulos
        LOOP
            -- Generar SKU
            SELECT generar_sku(
                v_producto_maestro_id,
                ARRAY(SELECT jsonb_array_elements_text(v_articulo->'colores_ids'))::UUID[]
            ) INTO v_sku;

            -- Validar SKU único
            IF EXISTS (SELECT 1 FROM articulos WHERE sku = v_sku) THEN
                v_error_hint := 'duplicate_sku';
                RAISE EXCEPTION 'SKU duplicado: %', v_sku;
            END IF;

            -- Insertar artículo
            INSERT INTO articulos (
                producto_maestro_id,
                sku,
                tipo_coloracion,
                colores_ids,
                precio,
                activo
            )
            VALUES (
                v_producto_maestro_id,
                v_sku,
                v_articulo->>'tipo_coloracion',
                ARRAY(SELECT jsonb_array_elements_text(v_articulo->'colores_ids'))::UUID[],
                (v_articulo->>'precio')::DECIMAL(10,2),
                true
            )
            RETURNING id INTO v_articulo_id;

            -- Acumular para response
            v_articulos_creados := array_append(v_articulos_creados,
                jsonb_build_object(
                    'id', v_articulo_id,
                    'sku', v_sku,
                    'precio', v_articulo->>'precio'
                )
            );
        END LOOP;
    END IF;

    -- 3. Retornar resumen
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'producto_maestro_id', v_producto_maestro_id,
            'articulos_creados', array_length(v_articulos_creados, 1),
            'articulos', v_articulos_creados
        )
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', COALESCE(v_error_hint, 'unknown')
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION crear_producto_completo IS 'Crea producto maestro + artículos en transacción única (HU-WIZARD)';
```

**Request Example**:
```json
{
  "p_producto_maestro": {
    "marca_id": "uuid-adidas",
    "material_id": "uuid-algodon",
    "tipo_id": "uuid-futbol",
    "sistema_talla_id": "uuid-numero",
    "descripcion": "Línea deportiva premium"
  },
  "p_articulos": [
    {
      "tipo_coloracion": "unicolor",
      "colores_ids": ["uuid-rojo"],
      "precio": 7000.00
    },
    {
      "tipo_coloracion": "bicolor",
      "colores_ids": ["uuid-negro", "uuid-blanco"],
      "precio": 8500.00
    }
  ]
}
```

**Response Success**:
```json
{
  "success": true,
  "data": {
    "producto_maestro_id": "uuid-123",
    "articulos_creados": 2,
    "articulos": [
      {"id": "uuid-art1", "sku": "ADS-FUT-ALG-35-36-ROJ", "precio": 7000.00},
      {"id": "uuid-art2", "sku": "ADS-FUT-ALG-35-36-NEG-BLA", "precio": 8500.00}
    ]
  }
}
```

**Response Error**:
```json
{
  "success": false,
  "error": {
    "code": "23505",
    "message": "SKU duplicado: ADS-FUT-ALG-35-36-ROJ",
    "hint": "duplicate_sku"
  }
}
```

**Hints estándar**:
- `permission_denied`: Usuario no es ADMIN
- `duplicate_sku`: SKU ya existe
- `invalid_color_count`: Cantidad de colores no coincide con tipo
- `producto_maestro_duplicate`: Combinación ya existe
- `catalog_inactive`: Algún catálogo relacionado está inactivo

---

### 6.3 Función RPC Auxiliar (Opcional)

#### 🆕 `validar_articulos_batch()`

**Propósito**: Validación pre-creación sin guardar (para preview).

```sql
CREATE OR REPLACE FUNCTION validar_articulos_batch(
    p_producto_maestro_id UUID,
    p_articulos JSONB[]
) RETURNS JSONB AS $$
DECLARE
    v_articulo JSONB;
    v_sku TEXT;
    v_warnings TEXT[] := ARRAY[]::TEXT[];
    v_skus JSONB[] := ARRAY[]::JSONB[];
BEGIN
    FOREACH v_articulo IN ARRAY p_articulos
    LOOP
        -- Generar SKU sin guardar
        SELECT generar_sku(
            p_producto_maestro_id,
            ARRAY(SELECT jsonb_array_elements_text(v_articulo->'colores_ids'))::UUID[]
        ) INTO v_sku;

        -- Verificar duplicado
        IF EXISTS (SELECT 1 FROM articulos WHERE sku = v_sku) THEN
            v_warnings := array_append(v_warnings,
                format('SKU duplicado: %s', v_sku)
            );
        END IF;

        -- Acumular SKU generado
        v_skus := array_append(v_skus,
            jsonb_build_object(
                'sku', v_sku,
                'tipo_coloracion', v_articulo->>'tipo_coloracion',
                'precio', v_articulo->>'precio',
                'duplicado', EXISTS (SELECT 1 FROM articulos WHERE sku = v_sku)
            )
        );
    END LOOP;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'skus', v_skus,
            'warnings', v_warnings,
            'has_warnings', array_length(v_warnings, 1) > 0
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 📋 7. PLAN DE IMPLEMENTACIÓN SECUENCIAL

### Fase 1: MVP - Modo Experto (1 semana)
**Prioridad**: CRÍTICA (alta frecuencia de uso)

#### HU-WIZARD-001: Modo Experto Creación Completa
**Story Points**: 8 pts

**Descripción**: Formulario compacto todo-en-uno para crear producto maestro + artículos en una sola pantalla.

**Tareas Backend** (@supabase-expert):
- [x] Función `crear_producto_completo()` transaccional (4h)
- [x] Función `validar_articulos_batch()` para preview (2h)
- [x] Tests manuales con curl (1h)

**Tareas Frontend** (@flutter-expert):
- [ ] UseCase `CrearProductoCompletoUseCase` (2h)
- [ ] UseCase `ValidarArticulosBatchUseCase` (1h)
- [ ] Modelo `ProductoCompletoRequest` (1h)
- [ ] Datasource con 2 nuevas funciones RPC (2h)
- [ ] Repository con Either pattern (2h)
- [ ] ProductoCompletoBloc + eventos + estados (3h)
- [ ] Tests unitarios bloc/usecases (3h)

**Tareas UI** (@ux-ui-expert):
- [ ] `ArticulosTableEditor` widget (6h)
- [ ] `ColorMultiSelector` widget (4h)
- [ ] `PrecioInputGroup` widget (2h)
- [ ] `ProductoSummaryWidget` widget (3h)
- [ ] `ProductoCreationExpertPage` (8h)
- [ ] Integración con ProductoCompletoBloc (4h)
- [ ] Validaciones en tiempo real (3h)
- [ ] Responsive design mobile/desktop (3h)

**Tareas QA** (@qa-testing-expert):
- [ ] Tests unitarios widgets (4h)
- [ ] Tests integración backend (2h)
- [ ] Tests E2E flujo completo (4h)
- [ ] Validación reglas de negocio (2h)

**Criterios de Aceptación**:
- [ ] Admin puede crear producto maestro + N artículos en una pantalla
- [ ] Tabla editable con drag & drop de colores
- [ ] SKUs generados en tiempo real
- [ ] Advertencia de SKUs duplicados
- [ ] Precios individuales por artículo
- [ ] Validación de cantidad de colores según tipo
- [ ] Responsive mobile/desktop
- [ ] Transacción atómica (todo-o-nada)

---

### Fase 2: Wizard Guiado + Detalle (2 semanas)

#### HU-WIZARD-002: Modo Guiado 2 Pasos
**Story Points**: 5 pts

**Descripción**: Wizard step-by-step para usuarios inexpertos.

**Tareas UI** (@ux-ui-expert):
- [ ] `ProductoCreationWizardPage` (6h)
- [ ] `ModoSelectorToggle` widget (2h)
- [ ] Stepper navigation (2h)
- [ ] Paso 1: Reutilizar form HU-006 (1h)
- [ ] Paso 2: Reutilizar `ArticulosTableEditor` (2h)
- [ ] Persistencia preferencia modo (localStorage) (1h)
- [ ] Validación por step (2h)

**Criterios de Aceptación**:
- [ ] Toggle entre Modo Experto/Guiado
- [ ] Stepper 2 pasos con navegación Atrás/Siguiente
- [ ] Validación al avanzar de paso
- [ ] Botón "Omitir" en Paso 2
- [ ] Preferencia de modo persiste
- [ ] Mismo backend que Modo Experto

---

#### HU-WIZARD-003: Pantalla Detalle Producto Maestro
**Story Points**: 6 pts

**Descripción**: Página de detalle con tabs y gestión de artículos.

**Tareas UI** (@ux-ui-expert):
- [ ] Expandir `producto_maestro_detail_page.dart` placeholder (8h)
- [ ] Tab "Características" con form editable (3h)
- [ ] Tab "Artículos" con tabla + acciones (5h)
- [ ] Botón "+ Crear Artículo" destacado (2h)
- [ ] Empty state "Sin artículos" (1h)
- [ ] Expandible detalles de artículo (3h)

**Criterios de Aceptación**:
- [ ] 2 tabs: Características y Artículos
- [ ] Características editables por admin
- [ ] Lista de artículos con SKU, colores, precio
- [ ] Botón crear artículo visible si admin
- [ ] Warning si producto sin artículos
- [ ] Responsive

---

#### HU-WIZARD-004: Crear Artículo Standalone
**Story Points**: 4 pts

**Descripción**: Diálogo para crear artículo desde producto maestro existente.

**Tareas UI** (@ux-ui-expert):
- [ ] `ArticuloStandaloneDialog` modal (5h)
- [ ] Selector producto maestro (dropdown) (2h)
- [ ] Reutilizar `ColorSelectorArticuloWidget` (1h)
- [ ] Reutilizar `SkuPreviewWidget` (1h)
- [ ] Integración con ArticulosBloc existente (2h)

**Criterios de Aceptación**:
- [ ] Modal se abre desde detalle producto maestro
- [ ] Producto maestro pre-seleccionado (readonly)
- [ ] Selector de colores unicolor/bicolor/tricolor
- [ ] SKU generado en tiempo real
- [ ] Precio editable
- [ ] Validación completa antes de guardar

---

### Fase 3: Optimizaciones (1 semana)

#### HU-WIZARD-005: Funcionalidades Avanzadas
**Story Points**: 5 pts

**Descripción**: Mejoras de UX y productividad.

**Tareas UI** (@ux-ui-expert):
- [ ] Importación CSV para creación masiva (6h)
- [ ] Duplicar producto existente (template) (4h)
- [ ] Filtros avanzados en lista productos (3h)
- [ ] Bulk edit precios de artículos (4h)
- [ ] Exportar lista productos a Excel (3h)

**Criterios de Aceptación**:
- [ ] Subir CSV con columnas: Marca, Material, Tipo, Talla, Colores, Precio
- [ ] Validar CSV antes de guardar
- [ ] Botón "Duplicar" en card de producto
- [ ] Filtros: Marca, Material, Tipo, Tallas, Rango precio
- [ ] Editar precios múltiples artículos
- [ ] Exportar con formato estándar

---

## 🎨 8. WIREFRAMES DETALLADOS

### 8.1 Modo Experto Desktop (>=1200px)

```
┌────────────────────────────────────────────────────────────────┐
│ SystemWebMedias                    Admin | [Logout ▼]          │
├────────────────────────────────────────────────────────────────┤
│ [← Volver a Productos]              Crear Producto Completo    │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ Modo: [Experto ▼] [Guiado]     💾 [Guardar Borrador]         │
│                                                                │
│ ┌────────────────────────────────────────────────────────────┐ │
│ │ 📦 SECCIÓN 1: PRODUCTO MAESTRO                             │ │
│ ├────────────────────────────────────────────────────────────┤ │
│ │                                                            │ │
│ │ Marca *              Material *                            │ │
│ │ [Adidas        ▼]   [Algodón      ▼]                      │ │
│ │                                                            │ │
│ │ Tipo *               Sistema Tallas *                      │ │
│ │ [Fútbol        ▼]   [Número (35-44) ▼] [i]               │ │
│ │                                                            │ │
│ │ Descripción (opcional)                                     │ │
│ │ ┌────────────────────────────────────────────────────────┐ │ │
│ │ │ Línea deportiva premium para temporada 2025           │ │ │
│ │ └────────────────────────────────────────────────────────┘ │ │
│ │                                                            │ │
│ │ Vista Previa:                                              │ │
│ │ 🏷️ Adidas - Fútbol - Algodón - Número (35-44)             │ │
│ │                                                            │ │
│ └────────────────────────────────────────────────────────────┘ │
│                                                                │
│ ┌────────────────────────────────────────────────────────────┐ │
│ │ 🎨 SECCIÓN 2: ARTÍCULOS (Opcional)                         │ │
│ ├────────────────────────────────────────────────────────────┤ │
│ │                                                            │ │
│ │ ☑ Crear artículos ahora                                    │ │
│ │                                                            │ │
│ │ Tabla Editable:                                            │ │
│ │ ┌───┬──────────┬──────────────────┬──────────┬─────────┐  │ │
│ │ │ # │ Tipo     │ Colores          │ Precio   │ Acciones│  │ │
│ │ ├───┼──────────┼──────────────────┼──────────┼─────────┤  │ │
│ │ │ 1 │Unicolor ▼│🔴 Rojo          │$7,000  ✓│🗑️ ⬆️⬇️ │  │ │
│ │ ├───┼──────────┼──────────────────┼──────────┼─────────┤  │ │
│ │ │ 2 │Bicolor  ▼│⚫🔴 Negro-Rojo   │$8,500  ✓│🗑️ ⬆️⬇️ │  │ │
│ │ ├───┼──────────┼──────────────────┼──────────┼─────────┤  │ │
│ │ │ 3 │Tricolor ▼│🔵🔴⚪ A-R-B [⚙️] │$10,000 ✓│🗑️ ⬆️⬇️ │  │ │
│ │ └───┴──────────┴──────────────────┴──────────┴─────────┘  │ │
│ │                                                            │ │
│ │ [+ Agregar Fila]                                           │ │
│ │                                                            │ │
│ │ 💡 Tip: Puedes omitir artículos y agregarlos después     │ │
│ │                                                            │ │
│ └────────────────────────────────────────────────────────────┘ │
│                                                                │
│ ┌────────────────────────────────────────────────────────────┐ │
│ │ 📊 RESUMEN                                   [▲ Colapsar] │ │
│ ├────────────────────────────────────────────────────────────┤ │
│ │ Artículos: 3                                               │ │
│ │ ├─ Unicolor: 1 ($7,000)                                   │ │
│ │ ├─ Bicolor: 1 ($8,500)                                    │ │
│ │ └─ Tricolor: 1 ($10,000)                                  │ │
│ │                                                            │ │
│ │ SKUs a generar:                                            │ │
│ │ • ADS-FUT-ALG-35-36-ROJ                                   │ │
│ │ • ADS-FUT-ALG-35-36-NEG-ROJ                               │ │
│ │ • ADS-FUT-ALG-35-36-AZU-ROJ-BLA                           │ │
│ │                                                            │ │
│ │ ⚠️ Advertencias: 0                                         │ │
│ └────────────────────────────────────────────────────────────┘ │
│                                                                │
│ [Cancelar]                            [Crear Producto Completo]│
└────────────────────────────────────────────────────────────────┘
```

**Interacciones clave**:
1. Click en fila "Colores" → Abre `ColorMultiSelector` modal
2. Cambio en "Tipo" → Ajusta cantidad de colores seleccionables
3. Cambio en cualquier campo → Actualiza SKU en Resumen (debounce 500ms)
4. Click [🗑️] → Elimina fila con confirmación
5. Drag fila → Reordena artículos
6. Click [Crear Producto Completo] → Validación + loading + creación transaccional

---

### 8.2 Modo Experto Mobile (<1200px)

```
┌────────────────────────┐
│ [← Volver]  Crear ☰   │
├────────────────────────┤
│ Modo: [Experto ▼]      │
│                        │
│ 📦 PRODUCTO MAESTRO    │
│ ┌──────────────────┐   │
│ │ Marca *          │   │
│ │ [Adidas     ▼]  │   │
│ └──────────────────┘   │
│ ┌──────────────────┐   │
│ │ Material *       │   │
│ │ [Algodón    ▼]  │   │
│ └──────────────────┘   │
│ ┌──────────────────┐   │
│ │ Tipo *           │   │
│ │ [Fútbol     ▼]  │   │
│ └──────────────────┘   │
│ ┌──────────────────┐   │
│ │ Tallas *         │   │
│ │ [Número     ▼]  │   │
│ └──────────────────┘   │
│ ┌──────────────────┐   │
│ │ Descripción      │   │
│ │ [            ]   │   │
│ └──────────────────┘   │
│                        │
│ 🎨 ARTÍCULOS           │
│ ☑ Crear ahora          │
│                        │
│ Artículo 1:            │
│ ┌──────────────────┐   │
│ │Tipo: Unicolor ▼ │   │
│ │🔴 Rojo          │   │
│ │Precio: $7,000   │   │
│ │SKU: ADS-FUT-... │   │
│ └──────────────────┘   │
│ [+ Agregar]            │
│                        │
│ ┌──────────────────┐   │
│ │ [Crear Todo]     │   │ ← Full width
│ └──────────────────┘   │
└────────────────────────┘
```

**Ajustes responsive**:
- Stack vertical (no grid)
- Botones full-width
- Tabla de artículos → Cards verticales
- Resumen colapsado por defecto

---

### 8.3 Modal ColorMultiSelector

```
┌────────────────────────────────────┐
│ Seleccionar Colores - Bicolor      │ [X]
├────────────────────────────────────┤
│ Selecciona exactamente 2 colores:  │
│                                    │
│ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐   │
│ │1⃣│ │  │ │  │ │  │ │2⃣│ │  │   │
│ │🔴│ │⚫│ │🔵│ │⚪│ │🟡│ │🟤│   │
│ │✓ │ │  │ │  │ │  │ │✓ │ │  │   │
│ └──┘ └──┘ └──┘ └──┘ └──┘ └──┘   │
│ Rojo Negro Azul Blanco Dor. Café  │
│                                    │
│ ┌──┐ ┌──┐ ┌──┐                    │
│ │  │ │  │ │  │                    │
│ │🟢│ │🟣│ │🟠│                    │
│ │  │ │  │ │  │                    │
│ └──┘ └──┘ └──┘                    │
│ Verde Morado Naranja               │
│                                    │
│ ────────────────────────────────   │
│ Orden de colores (arrastra):       │
│ ┌──────────────────────────────┐   │
│ │ 1. 🔴 Rojo      [↕️]         │   │ ← Drag handle
│ │ 2. 🟡 Dorado    [↕️]         │   │
│ └──────────────────────────────┘   │
│                                    │
│ SKU Preview:                       │
│ ADS-FUT-ALG-35-36-ROJ-DOR          │
│                                    │
│ [Cancelar]        [Aplicar Colores]│
└────────────────────────────────────┘
```

---

### 8.4 Pantalla Detalle Producto Maestro

```
┌────────────────────────────────────────────────────────────────┐
│ [← Volver]              Adidas - Fútbol - Algodón - Número    │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ ┌──────────────────────────────────────────────────────────┐   │
│ │ [Características]  [Artículos (3)]  [Historial]          │   │ ← Tabs
│ └──────────────────────────────────────────────────────────┘   │
│                                                                │
│ ╔══════════════════════════════════════════════════════════╗   │
│ ║ TAB: ARTÍCULOS                                           ║   │
│ ╚══════════════════════════════════════════════════════════╝   │
│                                                                │
│ 📊 Resumen:                                                    │
│ • Total artículos: 3 activos, 0 inactivos                     │
│ • Rango de precios: $7,000 - $10,000                          │
│ • Stock total: 0 unidades (sin asignar)                       │
│                                                                │
│ [+ Crear Artículo]    [Editar Precios Masivo]                │
│                                                                │
│ ┌────────────────────────────────────────────────────────────┐ │
│ │ SKU                    Colores     Precio   Stock  Acciones │ │
│ ├────────────────────────────────────────────────────────────┤ │
│ │ ADS-FUT-ALG-35-36-ROJ 🔴 Rojo    $7,000    0    [⋮ ▼]     │ │
│ │                                                            │ │
│ ├────────────────────────────────────────────────────────────┤ │
│ │ ADS-FUT-ALG-35-36-NEG-BLA ⚫🔴 N-B $8,500  0    [⋮ ▼]     │ │
│ │                                                            │ │
│ ├────────────────────────────────────────────────────────────┤ │
│ │ ADS-FUT-ALG-35-36-AZU-ROJ-BLA        $10,000 0    [⋮ ▼]   │ │
│ │ 🔵🔴⚪ Azul-Rojo-Blanco                                    │ │
│ └────────────────────────────────────────────────────────────┘ │
│                                                                │
│ Click [⋮] → Dropdown:                                          │
│ ┌──────────────────┐                                           │
│ │ Editar Precio    │                                           │
│ │ Ver Stock/Tiendas│                                           │
│ │ Duplicar         │                                           │
│ │ ──────────────── │                                           │
│ │ Desactivar       │                                           │
│ └──────────────────┘                                           │
└────────────────────────────────────────────────────────────────┘
```

---

## 🚀 9. RESUMEN DE DECISIONES ARQUITECTÓNICAS

### 9.1 Decisiones Confirmadas

| Decisión | Justificación |
|----------|---------------|
| **Modo Experto DEFAULT** | Alta frecuencia (10-20/día) requiere velocidad |
| **Wizard 2 pasos (NO 3)** | Tabla inventario_tiendas NO existe |
| **Precio a nivel artículo** | Tabla articulos.precio existe, flexible por color |
| **Creación transaccional** | Producto maestro + artículos en una operación atómica |
| **Tabla editable inline** | Más rápido que modal por cada artículo |
| **SKU generación backend** | Mantiene consistencia y evita duplicados |
| **Drag & drop de colores** | Orden de colores es significativo en SKU |

### 9.2 Decisiones Técnicas

| Aspecto | Solución |
|---------|----------|
| **Backend** | Nueva función RPC `crear_producto_completo()` transaccional |
| **Frontend** | Nuevo bloc `ProductoCompletoBloc` + extensión `ArticulosBloc` |
| **UI** | 5 widgets nuevos + reutilización HU-006/HU-007 |
| **Routing** | Rutas flat: `/producto-creation-expert`, `/producto-creation-wizard` |
| **Validación** | Tiempo real en UI + validación final en backend |
| **Error Handling** | Either pattern + hints estándar (duplicate_sku, etc.) |

### 9.3 Componentes Reutilizables

**De HU-006** (Productos Maestros):
- ProductoMaestroBloc (solo maestro)
- producto_maestro_card.dart
- producto_maestro_filter_widget.dart
- combinacion_warning_card.dart

**De HU-007** (Artículos):
- ArticulosBloc (crear standalone)
- articulo_card.dart
- color_selector_articulo_widget.dart
- colores_preview_widget.dart
- sku_preview_widget.dart

**Nuevos Shared**:
- ArticulosTableEditor (clave)
- ColorMultiSelector (clave)
- PrecioInputGroup
- ProductoSummaryWidget

---

## 📊 10. MATRIZ DE VIABILIDAD FINAL

| Feature | Viable | Tabla Backend | Estado |
|---------|--------|---------------|--------|
| **Paso 1: Producto Maestro** | ✅ SÍ | productos_maestros | ✅ EXISTE (HU-006) |
| **Paso 2A: Artículos + Colores** | ✅ SÍ | articulos | ✅ EXISTE (HU-007) |
| **Paso 2B: Precio por Artículo** | ✅ SÍ | articulos.precio | ✅ EXISTE |
| **Paso 3A: Stock Inicial** | ❌ NO | inventario_tiendas | ❌ NO EXISTE |
| **Paso 3B: Precios por Tienda** | ❌ NO | precios_tienda | ❌ NO EXISTE |
| **Generación SKU Automática** | ✅ SÍ | Función RPC | ✅ EXISTE (HU-007) |
| **Validación SKU Único** | ✅ SÍ | Constraint + RPC | ✅ EXISTE |
| **Creación Standalone Artículo** | ✅ SÍ | RPC crear_articulo | ✅ EXISTE |
| **Creación Batch Transaccional** | ⚠️ PARCIAL | crear_producto_completo | 🆕 NUEVO |

**Conclusión**: Sistema viable para wizard 2 pasos. Stock/precios por tienda requiere HU-008 futura.

---

## 🎯 11. PRÓXIMOS PASOS

### Inmediatos (Antes de Implementación)

1. **Validación de Diseño**: Revisión con stakeholders (usuario final)
2. **Priorización**: Confirmar Fase 1 (MVP Modo Experto) como crítica
3. **Asignación**: Coordinar con agentes especializados

### Coordinaciones Requeridas

- **@supabase-expert**:
  - Implementar `crear_producto_completo()` transaccional
  - Validar performance con 20+ artículos en batch
  - Tests con transacciones fallidas (rollback)

- **@flutter-expert**:
  - Diseñar `ArticulosTableEditor` con estado interno
  - Implementar `ProductoCompletoBloc` con progress tracking
  - Tests unitarios para validaciones inline

- **@ux-ui-expert**:
  - Wireframes finales responsive
  - Design system para tabla editable
  - Prototipo interactivo Modo Experto

- **@qa-testing-expert**:
  - Plan de tests transaccionales
  - Validación de reglas de negocio RN-047 a RN-060
  - Tests de performance con 50+ artículos

---

## 📚 12. REFERENCIAS

**Documentos Relacionados**:
- HU-006: Crear Producto Maestro (COMPLETADA)
- HU-007: Especializar Artículos con Colores (COMPLETADA)
- HU-008: Asignar Stock por Tienda (PENDIENTE - dependencia futura)
- 00-CONVENTIONS.md: Naming, routing, design system
- E002-gestion-productos.md: Épica completa

**Migraciones**:
- 00000000000003_catalog_tables.sql: Tablas productos_maestros, articulos
- 00000000000005_functions.sql: Funciones RPC existentes + nuevas

**Reglas de Negocio Críticas**:
- RN-047: Unicidad de SKU
- RN-048: Cantidad exacta de colores
- RN-049: Orden de colores significativo
- RN-052: Precio > 0
- RN-053: Generación automática SKU

---

**Versión**: 1.0
**Fecha Aprobación**: Pendiente
**Próxima Revisión**: Después de Fase 1 MVP
**Autor**: web-architect-expert

---

## ✅ CHECKLIST DE VALIDACIÓN ARQUITECTÓNICA

Antes de iniciar implementación:

- [x] Tablas backend validadas existentes
- [x] Función RPC transaccional diseñada
- [x] Blocs y estados definidos
- [x] Componentes UI identificados (nuevos vs reutilizables)
- [x] Flujos de navegación documentados
- [x] Wireframes completos desktop/mobile
- [x] Plan de implementación secuencial (3 fases)
- [x] Matriz de viabilidad confirmada
- [x] Decisiones técnicas justificadas
- [ ] Revisión con stakeholders
- [ ] Aprobación de prioridades

---

**ESTADO**: ✅ DISEÑO COMPLETO - LISTO PARA REVISIÓN
