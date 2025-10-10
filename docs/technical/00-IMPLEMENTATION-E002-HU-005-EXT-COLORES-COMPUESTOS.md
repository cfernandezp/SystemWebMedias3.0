# E002-HU-005 EXTENSIÓN: Colores Únicos y Compuestos

## INFORMACIÓN GENERAL

- **Historia Base**: E002-HU-005 Gestionar Catálogo de Colores (COMPLETADA)
- **Extensión**: Soporte para colores compuestos (2-3 colores por registro)
- **Fecha Inicio**: 2025-10-09
- **Arquitecto**: @web-architect-expert
- **Estado**: EN DESARROLLO

---

## OBJETIVO DE LA EXTENSIÓN

Ampliar el sistema de colores (HU-005 existente) para permitir:

1. **Colores Únicos**: 1 código hexadecimal (comportamiento actual)
2. **Colores Compuestos**: 2-3 códigos hexadecimales por color

---

## CAMBIOS REQUERIDOS

### 1. BACKEND (@supabase-expert)

**Modificar tabla `colores`:**
- Cambiar: `codigo_hex VARCHAR(7)` → `codigos_hex TEXT[]` (array)
- Agregar: `tipo_color VARCHAR(10)` ('unico' o 'compuesto')
- Constraint: `array_length(codigos_hex, 1) BETWEEN 1 AND 3`
- Migración de datos existentes: `codigo_hex` → `ARRAY[codigo_hex]` + `tipo_color='unico'`

**Actualizar funciones RPC:**
- `crear_color(p_nombre, p_codigos_hex, p_tipo_color)` → validar 1-3 códigos
- `editar_color(p_id, p_nombre, p_codigos_hex, p_tipo_color)` → validar 1-3 códigos
- `listar_colores()` → incluir `tipo_color` y `codigos_hex`

**Validaciones:**
- RN-041: Tipo 'unico' → exactamente 1 código hex
- RN-042: Tipo 'compuesto' → 2-3 códigos hex
- RN-043: Cada código hex debe cumplir formato `^#[0-9A-Fa-f]{6}$`

---

### 2. FRONTEND (@flutter-expert)

**Modificar `ColorModel` y `Color` entity:**
- Cambiar: `String codigoHex` → `List<String> codigosHex`
- Agregar: `String tipoColor` ('unico' o 'compuesto')

**Actualizar DataSource:**
- `ColoresRemoteDataSource.crear()` → enviar array `codigos_hex` + `tipo_color`
- `ColoresRemoteDataSource.editar()` → enviar array `codigos_hex` + `tipo_color`
- `ColoresRemoteDataSource.listar()` → parsear `codigos_hex` como `List<String>`

**Actualizar Repository/Bloc:**
- Validar en Bloc: 1 color → 'unico', 2-3 colores → 'compuesto'
- Validar máximo 3 colores seleccionados

---

### 3. UI (@ux-ui-expert)

**Rediseñar `ColorPickerField`:**
- **Paleta**: Grid con 50+ colores clickeables (círculos)
- **Selección múltiple**: Click en círculo agrega/quita color (máximo 3)
- **Preview dinámico**:
  - 1 color → Círculo sólido con ese color
  - 2-3 colores → Rectángulo dividido horizontalmente mostrando los colores

**Actualizar `ColorCard` y `ColorPreviewCircle`:**
- Mostrar preview de colores compuestos (rectángulo dividido)
- Mantener compatibilidad con colores únicos existentes

**Paleta de 50+ Colores:**
- Incluir colores estándar: rojos, azules, verdes, amarillos, naranjas, violetas, rosas, marrones, grises, blancos, negros
- Total: 50-60 colores predefinidos

---

## REGLAS DE NEGOCIO ADICIONALES

### RN-041: Validación Tipo Único
**Contexto**: Al crear/editar color tipo 'unico'
**Restricción**: Debe tener exactamente 1 código hexadecimal
**Validación**: `codigos_hex.length === 1`

### RN-042: Validación Tipo Compuesto
**Contexto**: Al crear/editar color tipo 'compuesto'
**Restricción**: Debe tener 2 o 3 códigos hexadecimales
**Validación**: `codigos_hex.length BETWEEN 2 AND 3`

### RN-043: Formato Hexadecimal Obligatorio
**Contexto**: Cada código en array `codigos_hex`
**Restricción**: Formato `#RRGGBB` (6 dígitos hex)
**Validación**: Regex `^#[0-9A-Fa-f]{6}$` aplicado a cada elemento

### RN-044: Migración de Datos Existentes
**Contexto**: Al aplicar migración
**Restricción**: Colores existentes se convierten a tipo 'unico'
**Validación**: `codigos_hex = ARRAY[codigo_hex]`, `tipo_color = 'unico'`

---

## MAPEO CRITERIOS DE ACEPTACIÓN

### CA-EXT-001: Crear Color Único
- Usuario escribe nombre (ej: "Rojo carmesí")
- Selecciona 1 color de paleta
- Preview muestra círculo con ese color
- Guarda 1 código hex + tipo 'unico'

### CA-EXT-002: Crear Color Compuesto (2 colores)
- Usuario escribe nombre (ej: "Rojo y Blanco")
- Selecciona 2 colores de paleta
- Preview muestra rectángulo dividido con ambos colores
- Guarda 2 códigos hex + tipo 'compuesto'

### CA-EXT-003: Crear Color Compuesto (3 colores)
- Usuario escribe nombre (ej: "Verde Amarillo Azul")
- Selecciona 3 colores de paleta
- Preview muestra rectángulo dividido en 3 partes
- Guarda 3 códigos hex + tipo 'compuesto'

### CA-EXT-004: Validación Máximo 3 Colores
- Usuario intenta seleccionar 4to color
- Sistema muestra "Máximo 3 colores permitidos"
- No permite agregar más colores

### CA-EXT-005: Visualización en Lista
- Lista de colores muestra:
  - Nombre del color
  - Preview (círculo o rectángulo según tipo)
  - Cantidad de códigos (1, 2 o 3)
  - Tipo (Único/Compuesto)

---

## IMPLEMENTACIÓN

### Backend
**Status**: ✅ COMPLETADO y CONSOLIDADO
**Asignado a**: @supabase-expert
**Archivos modificados**:
- ✅ **Consolidado** en: `supabase/migrations/00000000000003_catalog_tables.sql`
- ✅ Funciones RPC actualizadas en: `supabase/migrations/00000000000005_functions.sql`
- ✅ Eliminado archivo temporal: `20251009223631_extend_colores_compuestos.sql`
**Cambios aplicados**:
- Tabla `colores`: `codigo_hex` → `codigos_hex TEXT[]` + `tipo_color`
- Trigger `validate_codigos_hex_format()` para validar formato #RRGGBB
- Funciones actualizadas: `crear_color()`, `editar_color()`, `listar_colores()`

### Frontend
**Status**: Pendiente
**Asignado a**: @flutter-expert
**Archivos a modificar**:
- `lib/features/catalogos/domain/entities/color.dart`
- `lib/features/catalogos/data/models/color_model.dart`
- `lib/features/catalogos/data/datasources/colores_remote_datasource.dart`
- `lib/features/catalogos/data/repositories/colores_repository_impl.dart`
- `lib/features/catalogos/presentation/bloc/colores_bloc.dart`

### UI
**Status**: Pendiente
**Asignado a**: @ux-ui-expert
**Archivos a modificar**:
- `lib/features/catalogos/presentation/widgets/color_picker_field.dart`
- `lib/features/catalogos/presentation/widgets/color_preview_circle.dart`
- `lib/features/catalogos/presentation/widgets/color_card.dart`
- `lib/features/catalogos/presentation/pages/color_form_page.dart`

### QA
**Status**: Pendiente
**Asignado a**: @qa-testing-expert
**Validar**:
- CRUD colores únicos (1 hex)
- CRUD colores compuestos (2-3 hex)
- Validación máximo 3 colores
- Preview dinámico (círculo vs rectángulo)
- Migración de datos existentes
- Convenciones aplicadas

---

## CHECKLIST FINAL

- [x] Backend: Migration consolidada en archivos permanentes, funciones RPC actualizadas
- [ ] Frontend: Models/DataSource/Bloc actualizados
- [ ] UI: Selector múltiple + preview dinámico implementado
- [ ] QA: Validación end-to-end aprobada
- [ ] Migración: Datos existentes convertidos correctamente (pendiente aplicar)
- [ ] Convenciones: Naming/error handling/design system aplicados

---

**Coordinador**: @web-architect-expert
**Fecha última actualización**: 2025-10-09
