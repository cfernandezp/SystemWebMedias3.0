# E002-HU-006: Diseño UX/UI Productos Maestros

**Historia de Usuario**: E002-HU-006 - Crear Producto Maestro
**Agente**: @ux-ui-expert
**Fecha**: 2025-10-11
**Version**: 1.0

---

## 1. OVERVIEW

### 1.1 Objetivo de Experiencia

Diseñar una interfaz intuitiva que permita a administradores gestionar productos maestros (combinaciones de marca + material + tipo + sistema de tallas) de manera eficiente, con validaciones visuales claras y prevención proactiva de errores.

### 1.2 Principios UX

1. **Claridad informativa**: Vista previa en tiempo real de combinaciones para evitar errores
2. **Feedback inmediato**: Validaciones visuales no bloqueantes con advertencias contextuales
3. **Prevención de errores**: Tooltips informativos, restricciones visuales y confirmaciones inteligentes
4. **Contexto visual**: Badges de estado que comunican salud del producto (nuevo, con artículos, catálogos inactivos)
5. **Responsividad fluida**: Adaptación mobile-first sin pérdida de funcionalidad

### 1.3 Casos de Uso Críticos

**Por orden de prioridad**:

1. **Crear producto maestro nuevo** - Flujo principal con 4 dropdowns + validaciones
2. **Filtrar productos existentes** - Panel de búsqueda con múltiples criterios
3. **Editar producto con restricciones** - Solo descripción editable si tiene artículos
4. **Reactivar producto inactivo** - Dialog especial para combinaciones duplicadas
5. **Visualizar advertencias catálogos** - Detección de catálogos inactivos en productos existentes

---

## 2. USER FLOWS

### 2.1 Flujo Principal: Crear Producto Maestro

```
[Lista Productos]
    ↓ Click FAB "Crear" (solo ADMIN)
[Formulario Vacío]
    ↓ Seleccionar Marca (dropdown)
    ↓ Seleccionar Material (dropdown)
    ↓ Seleccionar Tipo (dropdown)
    ↓ Seleccionar Sistema Tallas (dropdown + tooltip valores)
    ↓ [Vista previa nombre compuesto actualizada en tiempo real]
    ↓ Agregar Descripción (opcional, max 200 chars)
    ↓ [Validación combinaciones comerciales ejecutada automáticamente]
    ↓ Click "Guardar"
        ├─ Si hay warnings → [Card Amarillo Advertencias] → Click "Guardar de todas formas"
        ├─ Si combinación duplicada activa → [Error: Ya existe]
        ├─ Si combinación duplicada inactiva → [Dialog: Reactivar existente]
        └─ Si válido → [SnackBar Success] → Redirect [Lista Productos]
```

### 2.2 Flujo Secundario: Editar con Artículos Derivados

```
[Lista Productos]
    ↓ Click menú "Editar" en card
[Formulario Edición]
    ↓ SI tiene artículos derivados (>0):
        ├─ [Card Advertencia Naranja]: "Este producto tiene X artículos derivados"
        ├─ Campos bloqueados: Marca, Material, Tipo, Sistema Tallas (disabled)
        └─ Campo habilitado: Solo Descripción
    ↓ SI NO tiene artículos (0):
        └─ Todos los campos habilitados
    ↓ Click "Guardar" → [SnackBar Success] → Redirect [Lista]
```

### 2.3 Flujo de Eliminación Inteligente

```
[Lista Productos]
    ↓ Click menú "Eliminar"
    ↓ SI tiene artículos derivados (>0):
        ├─ [Dialog Error]: "No se puede eliminar. Tiene X artículos"
        ├─ Botón cambia a "Desactivar"
        └─ Click "Desactivar" → [Dialog Desactivación Cascada]
            ├─ Checkbox "Desactivar también X artículos derivados"
            └─ Confirmar → [SnackBar Success]
    ↓ SI NO tiene artículos (0):
        └─ [Dialog Eliminar]: "¿Eliminar permanentemente?"
            └─ Confirmar → [Eliminación permanente] → [SnackBar Success]
```

### 2.4 Flujo de Filtrado Multi-Criterio

```
[Lista Productos]
    ↓ Panel Filtros (colapsable mobile)
        ├─ Dropdown Marca (todas)
        ├─ Dropdown Material (todos)
        ├─ Dropdown Tipo (todos)
        ├─ Dropdown Sistema Tallas (todos)
        ├─ Toggle Estado (Activo/Inactivo/Todos)
        └─ Campo texto libre (busca en descripción + nombres catálogos)
    ↓ Cada cambio → [Actualización automática grid]
    ↓ Contador dinámico: "X productos encontrados"
```

---

## 3. WIREFRAMES

### 3.1 ProductosMaestrosListPage (Desktop 1200px+)

```
┌─────────────────────────────────────────────────────────────────┐
│ Header                                                           │
│ ┌─────────────────────────┐  ┌──────────────┐                  │
│ │ Catálogo Productos      │  │ Dashboard >  │                  │
│ │ Maestros                │  │ Productos    │                  │
│ └─────────────────────────┘  └──────────────┘                  │
├─────────────────────────────────────────────────────────────────┤
│ Panel Filtros (colapsable)                   [FAB Crear] ADMIN │
│ ┌──────────┬──────────┬────────┬───────────┬──────────────┐   │
│ │ Marca ▼  │Material ▼│ Tipo ▼ │Sistema ▼  │[Buscar...   ]│   │
│ └──────────┴──────────┴────────┴───────────┴──────────────┘   │
│                                                                 │
│ Contador: [48 productos activos / 5 inactivos]                │
├─────────────────────────────────────────────────────────────────┤
│ Grid 2 Columnas (Cards)                                        │
│ ┌─────────────────────┐  ┌─────────────────────┐             │
│ │ [🔵] Adidas - Futbol│  │ [🟢] Nike - Invisible│             │
│ │      Algodón        │  │      Microfibra      │             │
│ │ ─────────────────── │  │ ─────────────────── │             │
│ │ Sistema: NÚMERO     │  │ Sistema: ÚNICA       │             │
│ │ (35-36 a 43-44)    │  │                      │             │
│ │                     │  │                      │             │
│ │ [🔵 3 artículos]   │  │ [🟢 Nuevo]          │             │
│ │ ⋮ Menú             │  │ ⋮ Menú              │             │
│ └─────────────────────┘  └─────────────────────┘             │
│                                                                 │
│ ┌─────────────────────┐  ┌─────────────────────┐             │
│ │ [⚠️] Puma - Tobillera│  │ [⚫] Reebok - Futbol│             │
│ │      Bambú          │  │      Algodón         │             │
│ │ ─────────────────── │  │ ─────────────────── │             │
│ │ Sistema: LETRA      │  │ Sistema: NÚMERO      │             │
│ │ (S a XXL)          │  │ (35-36 a 43-44)     │             │
│ │                     │  │                      │             │
│ │ [⚠️ Catálogos      │  │ [⚫ 0 activos]       │             │
│ │   inactivos]       │  │ (2 inactivos)        │             │
│ │ ⋮ Menú             │  │ ⋮ Menú              │             │
│ └─────────────────────┘  └─────────────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

**Elementos clave**:
- **FAB "Crear"**: Solo visible para rol ADMIN (BlocBuilder<AuthBloc>)
- **Panel filtros**: 5 dropdowns + búsqueda texto libre
- **Cards responsive**: Grid 2 cols desktop, 1 col mobile
- **Badges visuales**:
  - 🟢 Verde "Nuevo" → 0 artículos totales
  - 🔵 Azul "X artículos" → Tiene artículos activos
  - ⚫ Gris "0 activos (Y inactivos)" → Solo artículos inactivos
  - ⚠️ Amarillo "Catálogos inactivos" → Contiene catálogos desactivados
- **Menú acciones**: PopupMenuButton con opciones contextuales

### 3.2 ProductoMaestroFormPage (Desktop 1200px+)

```
┌─────────────────────────────────────────────────────────────────┐
│ [←] Crear Producto Maestro                                      │
│     Dashboard > Productos Maestros > Crear                      │
├─────────────────────────────────────────────────────────────────┤
│                          ┌────────────────────────────┐         │
│                          │ Card Formulario (max 600px)│         │
│                          │                            │         │
│                          │ Marca *                    │         │
│                          │ [Seleccionar marca      ▼] │         │
│                          │                            │         │
│                          │ Material *                 │         │
│                          │ [Seleccionar material   ▼] │         │
│                          │                            │         │
│                          │ Tipo *                     │         │
│                          │ [Seleccionar tipo       ▼] │         │
│                          │                            │         │
│                          │ Sistema de Tallas * [ℹ️]  │         │
│                          │ [Seleccionar sistema    ▼] │         │
│                          │ Tooltip: "Valores: 35-36, │         │
│                          │ 37-38, 39-40, 41-42..."   │         │
│                          │                            │         │
│                          │ ┌────────────────────────┐ │         │
│                          │ │ Vista Previa:          │ │         │
│                          │ │ Adidas - Futbol -      │ │         │
│                          │ │ Algodón - NÚMERO       │ │         │
│                          │ │ (35-36 a 43-44)       │ │         │
│                          │ └────────────────────────┘ │         │
│                          │                            │         │
│                          │ Descripción (opcional)     │         │
│                          │ [Max 200 caracteres...  ] │         │
│                          │ 0/200                      │         │
│                          │                            │         │
│                          │ ┌────────────────────────┐ │         │
│                          │ │ ⚠️ ADVERTENCIA         │ │         │
│                          │ │ Las medias de futbol   │ │         │
│                          │ │ normalmente usan tallas│ │         │
│                          │ │ numéricas. Esta        │ │         │
│                          │ │ combinación es poco    │ │         │
│                          │ │ común.                 │ │         │
│                          │ └────────────────────────┘ │         │
│                          │                            │         │
│                          │ [Cancelar] [Guardar]       │         │
│                          └────────────────────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

**Elementos clave**:
- **Dropdowns catálogos**: Solo muestran registros activos (CA-003)
- **Vista previa dinámica**: Actualizada con cada cambio de dropdown (CA-008)
- **Tooltip sistema tallas**: Muestra valores disponibles al hover (CA-012)
- **Card advertencia amarillo**: Aparece automáticamente si combinación inusual (CA-005, RN-040)
- **Counter descripción**: Muestra caracteres restantes de 200
- **Dialog cancelar**: Confirmación si hay cambios sin guardar (CA-011)

### 3.3 ProductoMaestroFormPage - Modo Edición con Artículos

```
┌─────────────────────────────────────────────────────────────────┐
│ [←] Editar Producto Maestro                                     │
│     Dashboard > Productos Maestros > Editar                     │
├─────────────────────────────────────────────────────────────────┤
│                          ┌────────────────────────────┐         │
│                          │ ⚠️ ADVERTENCIA             │         │
│                          │ Este producto tiene 5      │         │
│                          │ artículos derivados. Solo  │         │
│                          │ se puede editar la         │         │
│                          │ descripción.               │         │
│                          └────────────────────────────┘         │
│                          ┌────────────────────────────┐         │
│                          │ Card Formulario (max 600px)│         │
│                          │                            │         │
│                          │ Marca * [BLOQUEADO]        │         │
│                          │ [Adidas               🔒]  │         │
│                          │                            │         │
│                          │ Material * [BLOQUEADO]     │         │
│                          │ [Algodón              🔒]  │         │
│                          │                            │         │
│                          │ Tipo * [BLOQUEADO]         │         │
│                          │ [Futbol               🔒]  │         │
│                          │                            │         │
│                          │ Sistema de Tallas *        │         │
│                          │ [BLOQUEADO]                │         │
│                          │ [NÚMERO (35-44)       🔒]  │         │
│                          │                            │         │
│                          │ Descripción (opcional)     │         │
│                          │ [Línea premium 2025...  ] │         │
│                          │ 20/200                     │         │
│                          │                            │         │
│                          │ [Cancelar] [Guardar]       │         │
│                          └────────────────────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

**Elementos clave**:
- **Card advertencia naranja**: Mensaje claro sobre restricciones (CA-013)
- **Campos deshabilitados**: Icono 🔒 y color gris para campos bloqueados
- **Solo descripción editable**: Campo habilitado con focus visual

### 3.4 ProductoMaestroDetailPage (Placeholder)

```
┌─────────────────────────────────────────────────────────────────┐
│ [←] Detalle Producto Maestro                                    │
│     Dashboard > Productos Maestros > Detalle                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│              ┌────────────────────────────────┐                 │
│              │         [Icono Placeholder]     │                 │
│              │                                 │                 │
│              │    Página de Detalle            │                 │
│              │    (Implementación pendiente)   │                 │
│              │                                 │                 │
│              │    Este espacio estará          │                 │
│              │    disponible en próximas       │                 │
│              │    iteraciones.                 │                 │
│              │                                 │                 │
│              │    [Volver a Lista]             │                 │
│              └────────────────────────────────┘                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Nota**: Página placeholder simple con mensaje informativo y botón de regreso.

---

## 4. COMPONENTES UI

### 4.1 ProductosMaestrosListPage

#### 4.1.1 Layout Responsive

**Desktop (>= 1200px)**:
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1.8,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  // ...
)
```

**Mobile (< 1200px)**:
```dart
ListView.separated(
  separatorBuilder: (_, __) => SizedBox(height: 12),
  // ...
)
```

#### 4.1.2 Panel Filtros

**Widget**: `ProductoMaestroFilterWidget`

**Estructura**:
```dart
Card(
  child: ExpansionTile(
    title: Text('Filtros'),
    children: [
      Row(
        children: [
          Expanded(
            child: CorporateDropdown(
              label: 'Marca',
              items: marcasActivas,
              onChanged: (value) => context.read<ProductoMaestroBloc>()
                .add(FilterChanged(marcaId: value)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: CorporateDropdown(
              label: 'Material',
              // ...
            ),
          ),
          // ... más dropdowns
        ],
      ),
      SizedBox(height: 12),
      CorporateFormField(
        label: 'Buscar',
        hintText: 'Nombre, descripción...',
        prefixIcon: Icons.search,
        onChanged: (query) => context.read<ProductoMaestroBloc>()
          .add(SearchChanged(query)),
      ),
    ],
  ),
)
```

**Comportamiento**:
- Colapsable en mobile para ahorrar espacio
- Cada cambio dispara evento `FilterChanged` o `SearchChanged`
- Actualización automática del grid sin botón "Aplicar"
- Contador de resultados actualizado dinámicamente

#### 4.1.3 ProductoMaestroCard

**Widget**: `producto_maestro_card.dart`

**Elementos visuales**:
```
┌─────────────────────────────────────┐
│ [Badge Estado]  Adidas - Futbol    ⋮│
│                 Algodón             │
│ ─────────────────────────────────── │
│ Sistema: NÚMERO (35-36 a 43-44)    │
│                                     │
│ [Badge Artículos] [Badge Warning?] │
│                                     │
│ Descripción: Línea premium 2025    │
│ Creado: 2025-10-10                 │
└─────────────────────────────────────┘
```

**Badges**:
- **Estado general** (esquina superior izquierda):
  - Verde "Activo" si `activo == true`
  - Gris "Inactivo" si `activo == false`

- **Artículos derivados** (parte inferior):
  - Verde "Nuevo" si `articulos_totales == 0`
  - Azul "X artículos" si `articulos_activos > 0`
  - Gris "0 activos (Y inactivos)" si `articulos_activos == 0 && articulos_totales > 0`

- **Advertencia catálogos** (condicional):
  - Amarillo "⚠️ Contiene catálogos inactivos" si `tiene_catalogos_inactivos == true`

**Menú acciones** (PopupMenuButton):
- "Ver detalle" → Navega a `/producto-maestro-detail`
- "Editar" → Navega a `/producto-maestro-form` con `mode: edit`
- "Desactivar" / "Reactivar" → Dialog confirmación
- "Eliminar" → Dialog confirmación (bloqueado si tiene artículos)

#### 4.1.4 FAB Crear (Solo ADMIN)

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, authState) {
    final isAdmin = authState is Authenticated &&
                    authState.user.role == UserRole.admin;

    if (!isAdmin) return SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: () => context.push('/producto-maestro-form'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      icon: Icon(Icons.add),
      label: Text('Crear Producto'),
    );
  },
)
```

#### 4.1.5 Contador Productos

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    '$activos productos activos / $inactivos inactivos',
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.primary,
    ),
  ),
)
```

---

### 4.2 ProductoMaestroFormPage

#### 4.2.1 Dropdowns Catálogos

**Widget**: `CorporateDropdownField` (extender `CorporateFormField`)

**Especificación**:
- Border radius: 8px (no pill, es dropdown)
- Solo muestra catálogos con `activo == true` (CA-003)
- Loading state: Skeleton shimmer mientras cargan catálogos
- Empty state: "No hay [catálogo] activos disponibles"
- Validación: Requerido (border rojo si no seleccionado al guardar)

**Ejemplo dropdown Marca**:
```dart
BlocBuilder<MarcasBloc, MarcasState>(
  builder: (context, state) {
    if (state is MarcasLoading) {
      return ShimmerLoading(height: 56);
    }

    if (state is MarcasLoaded) {
      final marcasActivas = state.marcas.where((m) => m.activo).toList();

      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Marca *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: marcasActivas.map((marca) {
          return DropdownMenuItem(
            value: marca.id,
            child: Text(marca.nombre),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedMarcaId = value);
          _updateVistaPrevia();
        },
        validator: (value) => value == null ? 'Campo requerido' : null,
      );
    }

    return SizedBox.shrink();
  },
)
```

**Orden de dropdowns**:
1. Marca
2. Material
3. Tipo
4. Sistema de Tallas (con tooltip)

#### 4.2.2 Tooltip Sistema de Tallas (CA-012)

**Implementación**:
```dart
Row(
  children: [
    Expanded(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Sistema de Tallas *',
          // ...
        ),
        items: sistemasActivos.map((sistema) {
          return DropdownMenuItem(
            value: sistema.id,
            child: Text(sistema.nombre),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedSistemaId = value);
          _updateVistaPrevia();
        },
      ),
    ),
    SizedBox(width: 8),
    Tooltip(
      message: _getSistemaTooltip(_selectedSistemaId),
      preferBelow: false,
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      child: Icon(
        Icons.info_outline,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
    ),
  ],
)

String _getSistemaTooltip(String? sistemaId) {
  if (sistemaId == null) return 'Selecciona un sistema de tallas';

  final sistema = _sistemasActivos.firstWhere((s) => s.id == sistemaId);
  final valoresStr = sistema.valoresDisponibles.join(', ');

  return 'Sistema: ${sistema.nombre}\nValores: $valoresStr';
}
```

**Tooltip muestra**:
```
Sistema: NÚMERO
Valores: 35-36, 37-38, 39-40, 41-42, 43-44
```

#### 4.2.3 Vista Previa Nombre Compuesto (CA-008)

**Widget**: `NombreCompuestoPreview`

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFFF3F4F6),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      width: 2,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            Icons.preview_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Vista Previa',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
      SizedBox(height: 8),
      Text(
        _getNombreCompuesto(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ],
  ),
)

String _getNombreCompuesto() {
  if (_selectedMarcaId == null || _selectedMaterialId == null ||
      _selectedTipoId == null || _selectedSistemaId == null) {
    return 'Selecciona todos los campos para ver el nombre...';
  }

  final marca = _marcas.firstWhere((m) => m.id == _selectedMarcaId).nombre;
  final material = _materiales.firstWhere((m) => m.id == _selectedMaterialId).nombre;
  final tipo = _tipos.firstWhere((t) => t.id == _selectedTipoId).nombre;
  final sistema = _sistemas.firstWhere((s) => s.id == _selectedSistemaId);

  return '$marca - $tipo - $material - ${sistema.nombre} (${sistema.rangoDisplay})';
}
```

**Actualización dinámica**:
- Trigger: `onChanged` de cada dropdown
- Método: `setState(() { _updateVistaPrevia(); })`
- Debounce: No necesario (cambio instantáneo)

#### 4.2.4 Campo Descripción

**Widget**: `CorporateFormField` con `maxLines: 3`

```dart
CorporateFormField(
  controller: _descripcionController,
  label: 'Descripción (opcional)',
  hintText: 'Ej: Línea premium invierno 2025',
  maxLines: 3,
  textCapitalization: TextCapitalization.sentences,
  onChanged: (value) {
    setState(() {
      _charCount = value.length;
    });
  },
  validator: (value) {
    if (value != null && value.length > 200) {
      return 'Máximo 200 caracteres';
    }
    return null;
  },
)
// Counter debajo del campo
Text(
  '$_charCount/200',
  style: TextStyle(
    fontSize: 12,
    color: _charCount > 200 ? Color(0xFFF44336) : Color(0xFF6B7280),
  ),
)
```

#### 4.2.5 Card Advertencias Combinaciones Comerciales (CA-005, RN-040)

**Widget**: `CombinacionWarningCard`

```dart
class CombinacionWarningCard extends StatelessWidget {
  final List<String> warnings;

  const CombinacionWarningCard({required this.warnings});

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFFFFE69C),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Color(0xFF856404),
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ADVERTENCIA - Combinación poco común',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF856404),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...warnings.map((warning) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Color(0xFF856404))),
                  Expanded(
                    child: Text(
                      warning,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF856404),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 8),
          Text(
            'Esta validación NO impide guardar el producto. Puedes confirmar si la combinación es intencional.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Color(0xFF856404),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Warnings por combinación** (según RN-040):
- Futbol + ÚNICA: "Las medias de futbol normalmente usan tallas numéricas (35-44)"
- Futbol + LETRA: "Las medias de futbol normalmente usan tallas numéricas, no S/M/L"
- Invisible + LETRA: "Las medias invisibles suelen ser talla única o numérica"
- Invisible + NÚMERO: "Las medias invisibles suelen ser talla única"

**Comportamiento**:
- Se ejecuta validación automática al seleccionar Tipo + Sistema Tallas
- Event: `ValidarCombinacionComercial(tipoId, sistemaTallaId)`
- State: `CombinacionValidated(warnings: List<String>)`
- No bloquea el guardado (botón "Guardar" siempre habilitado)

#### 4.2.6 Restricciones Edición con Artículos (CA-013, RN-044)

**Advertencia Card**:
```dart
if (_isEditMode && _articulosTotales > 0)
  Container(
    padding: EdgeInsets.all(16),
    margin: EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: Color(0xFFFF9800).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Color(0xFFFF9800),
        width: 2,
      ),
    ),
    child: Row(
      children: [
        Icon(Icons.lock_outline, color: Color(0xFFFF9800)),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Este producto tiene $_articulosTotales artículo${_articulosTotales == 1 ? '' : 's'} derivado${_articulosTotales == 1 ? '' : 's'}. Solo se puede editar la descripción.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFE65100),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  ),
```

**Dropdowns bloqueados**:
```dart
DropdownButtonFormField<String>(
  enabled: !_isEditMode || _articulosTotales == 0, // Bloqueado si tiene artículos
  decoration: InputDecoration(
    labelText: 'Marca *',
    suffixIcon: _isEditMode && _articulosTotales > 0
      ? Icon(Icons.lock, color: Colors.grey)
      : null,
    fillColor: _isEditMode && _articulosTotales > 0
      ? Color(0xFFF3F4F6) // Gris claro
      : Colors.white,
  ),
  // ...
)
```

#### 4.2.7 Botones Acción

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    CorporateButton(
      text: 'Cancelar',
      variant: ButtonVariant.secondary,
      onPressed: _isLoading ? null : () => _handleCancel(context),
    ),
    SizedBox(width: 12),
    CorporateButton(
      text: _isEditMode ? 'Actualizar' : 'Guardar',
      variant: ButtonVariant.primary,
      isLoading: _isLoading,
      onPressed: _isLoading ? null : _handleSubmit,
    ),
  ],
)
```

**Dialog cancelar** (CA-011):
```dart
void _handleCancel(BuildContext context) {
  if (_hasUnsavedChanges) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text('¿Descartar cambios?'),
        content: Text(
          'Los cambios no guardados se perderán. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continuar editando'),
          ),
          CorporateButton(
            text: 'Descartar',
            variant: ButtonVariant.primary,
            onPressed: () {
              Navigator.pop(context); // Cierra dialog
              context.pop(); // Vuelve a lista
            },
          ),
        ],
      ),
    );
  } else {
    context.pop();
  }
}
```

---

### 4.3 ProductoMaestroDetailPage

**Implementación inicial**: Placeholder simple

```dart
class ProductoMaestroDetailPage extends StatelessWidget {
  final String productoId;

  const ProductoMaestroDetailPage({required this.productoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(0xFFE5E7EB)),
            ),
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.construction_outlined,
                    size: 64,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Página de Detalle',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Esta página estará disponible en próximas iteraciones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 32),
                  CorporateButton(
                    text: 'Volver a Lista',
                    variant: ButtonVariant.primary,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Diseño expandible futuro** (no implementar aún):
- Header con nombre completo del producto
- Tabs: Información, Artículos derivados, Historial
- Gráfico de artículos por color
- Timeline de cambios

---

## 5. ESTADOS UI

### 5.1 Loading States

**Lista de productos**:
```dart
if (state is ProductoMaestroLoading)
  Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 16),
        Text(
          'Cargando productos...',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    ),
  ),
```

**Formulario guardando**:
```dart
CorporateButton(
  text: 'Guardar',
  isLoading: true, // Muestra CircularProgressIndicator + "Cargando..."
  onPressed: null,
)
```

**Dropdowns cargando catálogos**:
```dart
if (state is MarcasLoading)
  Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
```

### 5.2 Empty States

**Lista sin productos**:
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.inventory_2_outlined,
        size: 80,
        color: Color(0xFF9CA3AF),
      ),
      SizedBox(height: 24),
      Text(
        'No hay productos maestros',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
      SizedBox(height: 12),
      Text(
        'Crea el primer producto maestro\ncombinando marca, material, tipo y tallas',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
      ),
      if (_isAdmin) ...[
        SizedBox(height: 32),
        CorporateButton(
          text: 'Crear Producto',
          icon: Icons.add,
          onPressed: () => context.push('/producto-maestro-form'),
        ),
      ],
    ],
  ),
)
```

**Dropdown sin catálogos activos**:
```dart
DropdownButtonFormField<String>(
  items: marcasActivas.isEmpty
    ? [
        DropdownMenuItem(
          value: null,
          enabled: false,
          child: Text(
            'No hay marcas activas disponibles',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ]
    : marcasActivas.map((m) => DropdownMenuItem(...)).toList(),
  // ...
)
```

**Búsqueda sin resultados**:
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.search_off,
        size: 64,
        color: Color(0xFF9CA3AF),
      ),
      SizedBox(height: 16),
      Text(
        'No se encontraron productos',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Intenta con otros criterios de búsqueda',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
      ),
      SizedBox(height: 24),
      CorporateButton(
        text: 'Limpiar Filtros',
        variant: ButtonVariant.secondary,
        onPressed: () => context.read<ProductoMaestroBloc>()
          .add(ClearFilters()),
      ),
    ],
  ),
)
```

### 5.3 Error States

**Error genérico**:
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.error_outline,
        size: 64,
        color: Color(0xFFF44336),
      ),
      SizedBox(height: 16),
      Text(
        'Error al cargar productos',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
      SizedBox(height: 8),
      Text(
        state.message, // Mensaje de error del backend
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF6B7280),
        ),
      ),
      SizedBox(height: 24),
      CorporateButton(
        text: 'Reintentar',
        icon: Icons.refresh,
        onPressed: () => context.read<ProductoMaestroBloc>()
          .add(LoadProductosMaestros()),
      ),
    ],
  ),
)
```

**Error en formulario** (validación):
```dart
if (_formKey.currentState?.validate() == false) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Por favor completa todos los campos obligatorios',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF44336),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
```

### 5.4 Success Feedback (SnackBars)

**Producto creado**:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Producto maestro creado exitosamente',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
    backgroundColor: Color(0xFF4CAF50),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    duration: Duration(seconds: 3),
  ),
)
```

**Producto editado**:
```dart
SnackBar(
  content: Row(
    children: [
      Icon(Icons.check_circle, color: Colors.white),
      SizedBox(width: 12),
      Text('Producto actualizado correctamente'),
    ],
  ),
  backgroundColor: Color(0xFF4CAF50),
  // ...
)
```

**Producto desactivado**:
```dart
SnackBar(
  content: Row(
    children: [
      Icon(Icons.info, color: Colors.white),
      SizedBox(width: 12),
      Text('Producto desactivado. 3 artículos también desactivados.'),
    ],
  ),
  backgroundColor: Color(0xFF2196F3),
  // ...
)
```

**Producto reactivado**:
```dart
SnackBar(
  content: Row(
    children: [
      Icon(Icons.check_circle, color: Colors.white),
      SizedBox(width: 12),
      Text('Producto reactivado exitosamente'),
    ],
  ),
  backgroundColor: Color(0xFF4CAF50),
  // ...
)
```

---

## 6. INTERACCIONES

### 6.1 Hover States

**Card producto**:
```dart
MouseRegion(
  onEnter: (_) => setState(() => _isHovered = true),
  onExit: (_) => setState(() => _isHovered = false),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 200),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _isHovered
          ? Theme.of(context).colorScheme.primary
          : Color(0xFFE5E7EB),
        width: _isHovered ? 2 : 1,
      ),
      boxShadow: _isHovered
        ? [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ]
        : [],
    ),
    // ...
  ),
)
```

**Botones** (ya implementado en `CorporateButton`):
- Normal: Color sólido
- Hover: Overlay blanco 10% alpha
- Pressed: Overlay blanco 20% alpha

**Dropdown items**:
```dart
DropdownMenuItem(
  child: MouseRegion(
    cursor: SystemMouseCursors.click,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _isHovered ? Color(0xFFF3F4F6) : Colors.transparent,
      ),
      child: Text(marca.nombre),
    ),
  ),
)
```

### 6.2 Click Behaviors

**Card completo clickeable** (navega a detalle):
```dart
InkWell(
  onTap: () => context.push('/producto-maestro-detail', extra: producto.id),
  borderRadius: BorderRadius.circular(12),
  child: ProductoMaestroCard(...),
)
```

**Menú acciones** (PopupMenuButton):
```dart
PopupMenuButton<String>(
  icon: Icon(Icons.more_vert),
  onSelected: (value) {
    switch (value) {
      case 'edit':
        _handleEdit(context, producto);
        break;
      case 'deactivate':
        _handleDeactivate(context, producto);
        break;
      case 'delete':
        _handleDelete(context, producto);
        break;
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          Icon(Icons.edit_outlined, size: 20),
          SizedBox(width: 12),
          Text('Editar'),
        ],
      ),
    ),
    PopupMenuItem(
      value: producto.activo ? 'deactivate' : 'reactivate',
      child: Row(
        children: [
          Icon(
            producto.activo ? Icons.block : Icons.check_circle_outline,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(producto.activo ? 'Desactivar' : 'Reactivar'),
        ],
      ),
    ),
    if (producto.articulosTotales == 0)
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline, size: 20, color: Colors.red),
            SizedBox(width: 12),
            Text('Eliminar', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
  ],
)
```

**Badge clickeable** (navega a artículos derivados):
```dart
if (producto.articulosActivos > 0)
  InkWell(
    onTap: () => context.push(
      '/articulos',
      extra: {'productoMaestroId': producto.id},
    ),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF2196F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${producto.articulosActivos} artículos',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
```

### 6.3 Confirmation Dialogs

#### 6.3.1 Dialog Eliminar (Sin artículos - CA-014)

```dart
showDialog(
  context: context,
  barrierColor: Colors.black54,
  builder: (dialogContext) => AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    title: Row(
      children: [
        Icon(Icons.delete_outline, color: Color(0xFFF44336)),
        SizedBox(width: 12),
        Text('¿Eliminar producto?'),
      ],
    ),
    content: Text(
      '¿Estás seguro de eliminar permanentemente "${producto.nombreCompleto}"?\n\nEsta acción no se puede deshacer.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext),
        child: Text('Cancelar'),
      ),
      CorporateButton(
        text: 'Eliminar',
        variant: ButtonVariant.primary,
        onPressed: () {
          Navigator.pop(dialogContext);
          context.read<ProductoMaestroBloc>()
            .add(EliminarProductoMaestro(producto.id));
        },
      ),
    ],
  ),
)
```

#### 6.3.2 Dialog Desactivar con Artículos (CA-014, RN-042)

```dart
showDialog(
  context: context,
  barrierColor: Colors.black54,
  builder: (dialogContext) {
    bool desactivarArticulos = false;

    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.block, color: Color(0xFFFF9800)),
            SizedBox(width: 12),
            Text('¿Desactivar producto?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Deseas desactivar "${producto.nombreCompleto}"?',
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF856404)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Este producto tiene ${producto.articulosActivos} artículo${producto.articulosActivos == 1 ? '' : 's'} activo${producto.articulosActivos == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF856404),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            CheckboxListTile(
              title: Text(
                'Desactivar también los ${producto.articulosActivos} artículos derivados',
                style: TextStyle(fontSize: 14),
              ),
              value: desactivarArticulos,
              onChanged: (value) {
                setState(() => desactivarArticulos = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancelar'),
          ),
          CorporateButton(
            text: 'Desactivar',
            variant: ButtonVariant.primary,
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProductoMaestroBloc>().add(
                DesactivarProductoMaestro(
                  producto.id,
                  desactivarArticulos: desactivarArticulos,
                ),
              );
            },
          ),
        ],
      ),
    );
  },
)
```

#### 6.3.3 Dialog Reactivar Producto Inactivo (CA-016)

```dart
if (state is ProductoMaestroError &&
    state.failure is DuplicateCombinationInactiveFailure) {
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF2196F3)),
          SizedBox(width: 12),
          Text('Producto existente inactivo'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ya existe un producto maestro con esta combinación, pero está inactivo:',
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              state.failure.nombreCompleto,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '¿Deseas reactivar el producto existente en lugar de crear uno nuevo?',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            context.pop(); // Volver al formulario
          },
          child: Text('Cancelar'),
        ),
        CorporateButton(
          text: 'Reactivar Producto',
          variant: ButtonVariant.primary,
          onPressed: () {
            Navigator.pop(dialogContext);
            context.read<ProductoMaestroBloc>().add(
              ReactivarProductoMaestro(state.failure.productoId),
            );
          },
        ),
      ],
    ),
  );
}
```

#### 6.3.4 Dialog Cancelar con Cambios (CA-011)

```dart
void _handleBackPress(BuildContext context) {
  if (_hasUnsavedChanges()) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text('¿Descartar cambios?'),
        content: Text(
          'Tienes cambios sin guardar que se perderán. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Continuar editando'),
          ),
          CorporateButton(
            text: 'Descartar',
            variant: ButtonVariant.primary,
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pop();
            },
          ),
        ],
      ),
    );
  } else {
    context.pop();
  }
}

bool _hasUnsavedChanges() {
  if (_isEditMode) {
    return _descripcionController.text != _originalDescripcion;
  } else {
    return _selectedMarcaId != null ||
           _selectedMaterialId != null ||
           _selectedTipoId != null ||
           _selectedSistemaId != null ||
           _descripcionController.text.isNotEmpty;
  }
}
```

**Integración con PopScope**:
```dart
PopScope(
  canPop: !_hasUnsavedChanges(),
  onPopInvoked: (didPop) {
    if (!didPop) {
      _handleBackPress(context);
    }
  },
  child: Scaffold(
    // ...
  ),
)
```

### 6.4 Tooltips

**Sistema de tallas** (ya especificado en 4.2.2)

**Badge catálogos inactivos**:
```dart
Tooltip(
  message: 'Este producto contiene catálogos desactivados:\n• ${producto.catalogosInactivosDetalle.join('\n• ')}',
  preferBelow: true,
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.grey[800],
    borderRadius: BorderRadius.circular(8),
  ),
  textStyle: TextStyle(color: Colors.white, fontSize: 13),
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Color(0xFFFF9800),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.warning_amber, color: Colors.white, size: 14),
        SizedBox(width: 6),
        Text(
          'Catálogos inactivos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  ),
)
```

**Info íconos en labels**:
```dart
Row(
  children: [
    Text('Sistema de Tallas *'),
    SizedBox(width: 6),
    Tooltip(
      message: 'Selecciona el rango de tallas que abarcará este producto',
      child: Icon(Icons.help_outline, size: 16, color: Colors.grey),
    ),
  ],
)
```

---

## 7. RESPONSIVE BREAKPOINTS

### 7.1 Breakpoints Definidos

```dart
class DesignBreakpoints {
  static const mobile = 768;
  static const tablet = 1024;
  static const desktop = 1200;
}

// Uso en código
final isDesktop = MediaQuery.of(context).size.width >= DesignBreakpoints.desktop;
final isMobile = MediaQuery.of(context).size.width < DesignBreakpoints.mobile;
```

### 7.2 ProductosMaestrosListPage Responsive

**Desktop (>= 1200px)**:
```dart
GridView.builder(
  padding: EdgeInsets.all(24),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1.8,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  // ...
)
```

**Tablet (768px - 1199px)**:
```dart
GridView.builder(
  padding: EdgeInsets.all(20),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1.6,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  ),
  // ...
)
```

**Mobile (< 768px)**:
```dart
ListView.separated(
  padding: EdgeInsets.all(16),
  separatorBuilder: (_, __) => SizedBox(height: 12),
  // ...
)
```

**Panel filtros responsive**:
```dart
if (isDesktop)
  Row( // Horizontal en desktop
    children: [
      Expanded(child: DropdownMarca()),
      SizedBox(width: 12),
      Expanded(child: DropdownMaterial()),
      SizedBox(width: 12),
      Expanded(child: DropdownTipo()),
      SizedBox(width: 12),
      Expanded(child: DropdownSistema()),
    ],
  )
else
  Column( // Vertical en mobile
    children: [
      DropdownMarca(),
      SizedBox(height: 12),
      DropdownMaterial(),
      SizedBox(height: 12),
      DropdownTipo(),
      SizedBox(height: 12),
      DropdownSistema(),
    ],
  )
```

### 7.3 ProductoMaestroFormPage Responsive

**Centrado en desktop**:
```dart
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 600),
    child: Card(
      // Formulario
    ),
  ),
)
```

**Full width en mobile**:
```dart
SingleChildScrollView(
  padding: EdgeInsets.all(isDesktop ? 24 : 16),
  child: Card(
    // Formulario sin ConstrainedBox
  ),
)
```

**Botones responsive**:
```dart
if (isDesktop)
  Row( // Inline en desktop
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      CorporateButton(text: 'Cancelar'),
      SizedBox(width: 12),
      CorporateButton(text: 'Guardar'),
    ],
  )
else
  Column( // Stacked en mobile
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CorporateButton(text: 'Guardar'),
      SizedBox(height: 12),
      CorporateButton(text: 'Cancelar', variant: ButtonVariant.secondary),
    ],
  )
```

### 7.4 Dialogs Responsive

**Ancho adaptativo**:
```dart
AlertDialog(
  // Desktop: width controlado por contenido (max 500px)
  // Mobile: ocupa casi todo el ancho (margin 16px)
  insetPadding: EdgeInsets.all(isMobile ? 16 : 24),
  content: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: isMobile ? double.infinity : 500,
    ),
    child: // Contenido
  ),
)
```

### 7.5 Typography Responsive

```dart
Text(
  'Catálogo Productos Maestros',
  style: TextStyle(
    fontSize: isDesktop ? 28 : 24,
    fontWeight: FontWeight.bold,
  ),
)

Text(
  'Descripción',
  style: TextStyle(
    fontSize: isDesktop ? 16 : 14,
  ),
)
```

### 7.6 Spacing Responsive

```dart
Padding(
  padding: EdgeInsets.all(isDesktop ? 24 : 16),
  // ...
)

SizedBox(height: isDesktop ? 32 : 24)

Row(
  children: [
    // ...
    SizedBox(width: isDesktop ? 16 : 12),
    // ...
  ],
)
```

---

## 8. DESIGN TOKENS

### 8.1 Colores (Theme-Aware)

```dart
// CORRECTO: Usar Theme.of(context)
Theme.of(context).colorScheme.primary       // #4ECDC4 turquesa
Theme.of(context).colorScheme.secondary     // #45B7AA
Theme.of(context).colorScheme.error         // #F44336

// O DesignColors si no hay context
DesignColors.primaryTurquoise               // #4ECDC4
DesignColors.success                        // #4CAF50
DesignColors.warning                        // #FF9800
DesignColors.error                          // #F44336
DesignColors.info                           // #2196F3
DesignColors.backgroundLight                // #F9FAFB
DesignColors.textPrimary                    // #374151
DesignColors.textSecondary                  // #6B7280
DesignColors.border                         // #E5E7EB
```

**PROHIBIDO**: Hardcodear colores directamente
```dart
// ❌ INCORRECTO
Container(color: Color(0xFF4ECDC4))

// ✅ CORRECTO
Container(color: Theme.of(context).colorScheme.primary)
```

### 8.2 Spacing

```dart
class DesignSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

// Uso
Padding(padding: EdgeInsets.all(DesignSpacing.md))
SizedBox(height: DesignSpacing.lg)
```

**PROHIBIDO**: Magic numbers
```dart
// ❌ INCORRECTO
SizedBox(height: 24)

// ✅ CORRECTO
SizedBox(height: DesignSpacing.lg)
```

### 8.3 Typography

```dart
class DesignTypography {
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
}
```

### 8.4 Border Radius

```dart
class DesignBorderRadius {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const pill = 28.0; // Para CorporateFormField
}

// Uso
BorderRadius.circular(DesignBorderRadius.medium)
```

### 8.5 Elevation

```dart
class DesignElevation {
  static const none = 0.0;
  static const low = 2.0;
  static const medium = 4.0;
  static const high = 8.0;
}

// Uso
Card(elevation: DesignElevation.low)
CorporateButton(elevation: DesignElevation.medium) // 3 en implementación actual
```

### 8.6 Animation Durations

```dart
class DesignAnimation {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 300);
}

// Uso
AnimatedContainer(
  duration: DesignAnimation.normal,
  // ...
)
```

---

## 9. VALIDACIONES UX

### 9.1 Validaciones Visuales en Formulario

#### Campos Obligatorios (CA-004)

**Indicador visual**:
```dart
Text.rich(
  TextSpan(
    children: [
      TextSpan(text: 'Marca'),
      TextSpan(
        text: ' *',
        style: TextStyle(color: Color(0xFFF44336)),
      ),
    ],
  ),
)
```

**Validación al guardar**:
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es obligatorio';
  }
  return null;
}
```

**Border rojo si error**:
```dart
errorBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(8),
  borderSide: BorderSide(
    color: Color(0xFFF44336),
    width: 2,
  ),
)
```

#### Descripción Opcional (RN-039)

**Counter de caracteres**:
```dart
TextFormField(
  controller: _descripcionController,
  maxLength: 200,
  buildCounter: (context, {currentLength, isFocused, maxLength}) {
    return Text(
      '$currentLength/$maxLength',
      style: TextStyle(
        fontSize: 12,
        color: currentLength > maxLength
          ? Color(0xFFF44336)
          : Color(0xFF6B7280),
      ),
    );
  },
  // ...
)
```

**Validación longitud**:
```dart
validator: (value) {
  if (value != null && value.length > 200) {
    return 'La descripción no puede exceder 200 caracteres';
  }
  return null;
}
```

#### Validación Combinaciones Comerciales (CA-005, RN-040)

**Trigger automático**:
```dart
void _onTipoOrSistemaChanged() {
  if (_selectedTipoId != null && _selectedSistemaId != null) {
    context.read<ProductoMaestroBloc>().add(
      ValidarCombinacionComercial(
        tipoId: _selectedTipoId!,
        sistemaTallaId: _selectedSistemaId!,
      ),
    );
  }
}
```

**Listener de estado**:
```dart
BlocListener<ProductoMaestroBloc, ProductoMaestroState>(
  listener: (context, state) {
    if (state is CombinacionValidated) {
      setState(() {
        _warnings = state.warnings;
      });
    }
  },
  child: // ...
)
```

**Display warnings** (no bloqueante):
```dart
if (_warnings.isNotEmpty)
  CombinacionWarningCard(warnings: _warnings)
// Botón "Guardar" sigue habilitado
```

### 9.2 Validaciones de Duplicados (CA-006, CA-016)

**Duplicado activo**:
```dart
if (state is ProductoMaestroError &&
    state.failure is DuplicateCombinationFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ya existe un producto con esta combinación',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF44336),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
```

**Duplicado inactivo** (ver dialog en 6.3.3)

### 9.3 Validaciones de Eliminación (CA-014)

**Con artículos derivados**:
```dart
void _handleDelete(BuildContext context, ProductoMaestro producto) {
  if (producto.articulosTotales > 0) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('No se puede eliminar'),
        content: Text(
          'Este producto tiene ${producto.articulosTotales} artículo${producto.articulosTotales == 1 ? '' : 's'} derivado${producto.articulosTotales == 1 ? '' : 's'}. Solo puedes desactivarlo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Entendido'),
          ),
          CorporateButton(
            text: 'Desactivar',
            variant: ButtonVariant.primary,
            onPressed: () {
              Navigator.pop(dialogContext);
              _handleDeactivate(context, producto);
            },
          ),
        ],
      ),
    );
  } else {
    // Proceder con eliminación (ver dialog en 6.3.1)
  }
}
```

### 9.4 Validaciones de Edición (CA-013, RN-044)

**Campos bloqueados visualmente**:
```dart
DropdownButtonFormField<String>(
  enabled: _articulosTotales == 0,
  decoration: InputDecoration(
    suffixIcon: _articulosTotales > 0
      ? Icon(Icons.lock, color: Colors.grey)
      : null,
    fillColor: _articulosTotales > 0
      ? Color(0xFFF3F4F6)
      : Colors.white,
  ),
  // ...
)
```

**Validación backend** (ya implementado en `editar_producto_maestro` RPC)

---

## 10. MANEJO DE COMPLEJIDAD

### 10.1 Problema: 4 Dropdowns + Validaciones

**Solución**: Carga paralela de catálogos con MultiBlocProvider

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => sl<MarcasBloc>()..add(LoadMarcas())),
    BlocProvider(create: (_) => sl<MaterialesBloc>()..add(LoadMateriales())),
    BlocProvider(create: (_) => sl<TiposBloc>()..add(LoadTipos())),
    BlocProvider(create: (_) => sl<SistemasTallaBloc>()..add(LoadSistemasTalla())),
    BlocProvider(create: (_) => sl<ProductoMaestroBloc>()),
  ],
  child: ProductoMaestroFormPage(),
)
```

**Loading state unificado**:
```dart
bool _isLoadingCatalogs = false;

@override
void initState() {
  super.initState();
  // Los 4 blocs emiten sus estados independientemente
}

bool get _allCatalogsLoaded {
  return context.read<MarcasBloc>().state is MarcasLoaded &&
         context.read<MaterialesBloc>().state is MaterialesLoaded &&
         context.read<TiposBloc>().state is TiposLoaded &&
         context.read<SistemasTallaBloc>().state is SistemasTallaLoaded;
}

@override
Widget build(BuildContext context) {
  if (!_allCatalogsLoaded) {
    return Center(child: CircularProgressIndicator());
  }

  return // Formulario
}
```

### 10.2 Problema: Validaciones Cruzadas

**Solución**: Validación en cascada con debounce

```dart
Timer? _validationTimer;

void _onFieldChanged() {
  _validationTimer?.cancel();
  _validationTimer = Timer(Duration(milliseconds: 500), () {
    if (_canValidateCombinacion) {
      context.read<ProductoMaestroBloc>().add(
        ValidarCombinacionComercial(
          tipoId: _selectedTipoId!,
          sistemaTallaId: _selectedSistemaId!,
        ),
      );
    }
  });
}

bool get _canValidateCombinacion {
  return _selectedTipoId != null && _selectedSistemaId != null;
}
```

### 10.3 Problema: Feedback Visual para Combinaciones Inusuales

**Solución**: Card no bloqueante con estilo claro

- **Color amarillo suave** (#FFF3CD): Advertencia sin alarma
- **Icono warning_amber**: Reconocible pero no crítico
- **Texto explicativo**: "Esta validación NO impide guardar"
- **Botón "Guardar" siempre habilitado**: Usuario tiene control final

**UX Goal**: Informar sin frustrar. El sistema asesora, el usuario decide.

---

## 11. CASOS EXTREMOS

### 11.1 Sin Catálogos Activos Disponibles

**Escenario**: Todos los catálogos de un tipo están desactivados.

**UI**:
```dart
if (marcasActivas.isEmpty)
  Container(
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Color(0xFFFFF3CD),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFFFFE69C)),
    ),
    child: Column(
      children: [
        Icon(Icons.warning_amber, size: 48, color: Color(0xFF856404)),
        SizedBox(height: 16),
        Text(
          'No hay marcas activas disponibles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF856404),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Debes activar al menos una marca antes de crear productos maestros.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF856404),
          ),
        ),
        SizedBox(height: 16),
        CorporateButton(
          text: 'Ir a Gestión de Marcas',
          variant: ButtonVariant.primary,
          onPressed: () => context.push('/marcas'),
        ),
      ],
    ),
  )
```

### 11.2 Producto con Catálogos Inactivos en Lista

**Escenario**: Marca/Material/Tipo/Sistema fue desactivado después de crear el producto.

**UI Badge** (CA-015):
```dart
if (producto.tieneCatalogosInactivos)
  Tooltip(
    message: 'Contiene catálogos inactivos:\n${producto.catalogosInactivosDetalle}',
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFFF9800),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Text(
            'Catálogos inactivos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  )
```

**Restricción**: No permitir crear artículos derivados desde este producto (validación en HU-007).

### 11.3 Intento de Reactivar Producto con Catálogos Inactivos

**Escenario**: Usuario intenta reactivar producto pero marca/material/tipo/sistema está inactivo.

**Backend**: Función `reactivar_producto_maestro` valida todos los catálogos.

**UI Error**:
```dart
if (state is ProductoMaestroError &&
    state.failure is InactiveCatalogFailure) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.block, color: Color(0xFFF44336)),
          SizedBox(width: 12),
          Text('No se puede reactivar'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.failure.message),
          SizedBox(height: 12),
          Text(
            'Debes reactivar primero los catálogos inactivos:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...state.failure.inactiveCatalogs.map((catalog) {
            return Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.close, size: 16, color: Color(0xFFF44336)),
                  SizedBox(width: 8),
                  Text(catalog),
                ],
              ),
            );
          }).toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Entendido'),
        ),
      ],
    ),
  );
}
```

### 11.4 Búsqueda Sin Resultados con Filtros Activos

**UI**:
```dart
if (filteredProductos.isEmpty && hasActiveFilters)
  Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.filter_alt_off, size: 64, color: Color(0xFF9CA3AF)),
        SizedBox(height: 16),
        Text(
          'No se encontraron productos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Intenta ajustar los filtros de búsqueda',
          style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
        ),
        SizedBox(height: 24),
        CorporateButton(
          text: 'Limpiar Filtros',
          variant: ButtonVariant.secondary,
          icon: Icons.clear,
          onPressed: () => context.read<ProductoMaestroBloc>()
            .add(ClearFilters()),
        ),
      ],
    ),
  )
```

### 11.5 Timeout de Red en Carga de Catálogos

**UI**:
```dart
if (state is MarcasError || state is MaterialesError ||
    state is TiposError || state is SistemasTallaError)
  Container(
    padding: EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.wifi_off, size: 64, color: Color(0xFFF44336)),
        SizedBox(height: 16),
        Text(
          'Error al cargar catálogos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Verifica tu conexión a internet e intenta nuevamente',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        SizedBox(height: 24),
        CorporateButton(
          text: 'Reintentar',
          icon: Icons.refresh,
          onPressed: _reloadAllCatalogs,
        ),
      ],
    ),
  )
```

---

## 12. CHECKLIST DE IMPLEMENTACIÓN

### Fase 1: Lista de Productos Maestros

- [ ] `ProductosMaestrosListPage` con grid responsive 2 cols
- [ ] `ProductoMaestroCard` con badges de estado
- [ ] `ProductoMaestroFilterWidget` con 5 dropdowns + búsqueda
- [ ] Contador productos activos/inactivos
- [ ] FAB "Crear" visible solo para ADMIN
- [ ] Menú acciones (Editar, Desactivar, Eliminar)
- [ ] Loading state con CircularProgressIndicator
- [ ] Empty state con mensaje e ícono
- [ ] Error state con botón reintentar
- [ ] Integración con `ProductoMaestroBloc`

### Fase 2: Formulario de Creación/Edición

- [ ] `ProductoMaestroFormPage` con 4 dropdowns catálogos
- [ ] Dropdowns filtran solo catálogos activos
- [ ] Campo descripción opcional (max 200 chars)
- [ ] Vista previa nombre compuesto dinámica
- [ ] Tooltip sistema tallas con valores disponibles
- [ ] `CombinacionWarningCard` para advertencias no bloqueantes
- [ ] Validación campos obligatorios con UI feedback
- [ ] Restricciones edición si tiene artículos derivados
- [ ] Dialog confirmación cancelar si hay cambios
- [ ] Integración con 4 Blocs de catálogos
- [ ] Integración con `ProductoMaestroBloc`

### Fase 3: Dialogs y Confirmaciones

- [ ] Dialog eliminar (sin artículos)
- [ ] Dialog desactivar (con artículos) + cascada opcional
- [ ] Dialog reactivar producto inactivo existente
- [ ] Dialog cancelar con cambios sin guardar
- [ ] SnackBars success/error según resultado

### Fase 4: Página de Detalle

- [ ] `ProductoMaestroDetailPage` placeholder con diseño básico
- [ ] Mensaje "Implementación pendiente"
- [ ] Botón "Volver a Lista"

### Fase 5: Routing y Navegación

- [ ] Rutas flat registradas en `app_router.dart`:
  - `/productos-maestros`
  - `/producto-maestro-form`
  - `/producto-maestro-detail`
- [ ] Breadcrumbs agregados en routeMap
- [ ] Navegación con `context.push()` y argumentos

### Fase 6: Responsive y Anti-Overflow

- [ ] Grid adapts a 1 col en mobile (< 1200px)
- [ ] Panel filtros colapsable en mobile
- [ ] Formulario con SingleChildScrollView
- [ ] Dropdowns con ConstrainedBox si es necesario
- [ ] Textos con Expanded + TextOverflow.ellipsis en Row
- [ ] Dialogs con maxHeight responsive
- [ ] Probado en anchos 375px, 768px, 1200px

### Fase 7: Design System

- [ ] Colores usando `Theme.of(context)` (sin hardcoded)
- [ ] Spacing con `DesignSpacing.*`
- [ ] Border radius con `DesignBorderRadius.*`
- [ ] Typography consistente
- [ ] Componentes corporativos: `CorporateButton`, `CorporateFormField`

### Fase 8: Testing Visual

- [ ] `flutter analyze --no-pub`: 0 errores críticos
- [ ] Sin overflow warnings en consola
- [ ] Verificado en breakpoints 375px, 768px, 1200px
- [ ] Todos los CAs de UI cubiertos
- [ ] Navegación funcional entre páginas
- [ ] Feedback visual correcto (SnackBars, Dialogs)

---

## 13. NOTAS FINALES

### 13.1 Criterios de Aceptación UI Mapeados

| CA | Componente UI | Widget Responsable |
|----|--------------|-------------------|
| CA-001 | FAB visible solo ADMIN | `FloatingActionButton` + `BlocBuilder<AuthBloc>` |
| CA-002 | Formulario con 4 dropdowns | `ProductoMaestroFormPage` |
| CA-003 | Solo catálogos activos | Dropdowns filtran `activo == true` |
| CA-004 | Validación campos obligatorios | `validator` en `DropdownButtonFormField` |
| CA-005 | Advertencias combinaciones | `CombinacionWarningCard` |
| CA-006 | Validación duplicados | SnackBar error desde `ProductoMaestroBloc` |
| CA-007 | Guardar exitosamente | SnackBar success + navegación |
| CA-008 | Vista previa nombre | `NombreCompuestoPreview` actualizado dinámicamente |
| CA-009 | Listar productos | `ProductosMaestrosListPage` con grid |
| CA-010 | Filtrado multi-criterio | `ProductoMaestroFilterWidget` |
| CA-011 | Cancelar sin guardar | Dialog confirmación con `PopScope` |
| CA-012 | Tooltip sistema tallas | `Tooltip` en dropdown sistemas |
| CA-013 | Edición con restricciones | Campos deshabilitados + advertencia card |
| CA-014 | Eliminar vs Desactivar | Dialogs distintos según artículos |
| CA-015 | Badge catálogos inactivos | `CatalogosInactivosBadge` en card |
| CA-016 | Reactivar producto inactivo | Dialog especial desde error bloc |

### 13.2 Reglas de Negocio UI Mapeadas

| RN | Implementación UI |
|----|-------------------|
| RN-037 | Error SnackBar duplicado + Dialog reactivar |
| RN-038 | Dropdowns filtran activos + Badge warning en cards |
| RN-039 | Counter 200 chars + validación |
| RN-040 | `CombinacionWarningCard` no bloqueante |
| RN-042 | Dialog desactivación cascada con checkbox |
| RN-043 | Badges contadores artículos en cards |
| RN-044 | Campos bloqueados + advertencia naranja |
| RN-046 | Vista previa con formato largo |

### 13.3 Próximos Pasos (Post-Diseño)

1. **@flutter-expert**: Implementar componentes UI según este diseño
2. **@qa-testing-expert**: Widget tests + Integration tests
3. **@ux-ui-expert**: Validar implementación vs wireframes
4. **Iteración**: Ajustes según feedback de testing

### 13.4 Riesgos Identificados

| Riesgo | Mitigación |
|--------|-----------|
| Complejidad 4 dropdowns | MultiBlocProvider con carga paralela |
| Overflow en mobile | SingleChildScrollView + ConstrainedBox |
| Validaciones cruzadas | Debounce + estados intermedios |
| Catálogos inactivos confusos | Badges visuales claros + tooltips |
| Usuarios frustrados por restricciones | Mensajes explicativos + sugerencias acción |

---

**Fin del Documento de Diseño UX/UI E002-HU-006**

**Versión**: 1.0
**Fecha**: 2025-10-11
**Aprobado para implementación**: ✅
