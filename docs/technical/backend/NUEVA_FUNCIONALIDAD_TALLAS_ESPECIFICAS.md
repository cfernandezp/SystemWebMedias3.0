# Nueva Funcionalidad: Selección de Tallas Específicas en Productos Maestros

**Fecha**: 2025-10-15
**Responsable**: supabase-expert
**Status**: ✅ Completado

---

## Contexto del Negocio

Anteriormente, un producto maestro se asociaba a un `sistema_talla` completo (ej: "Tallas Numéricas Europeas" con **todas** sus tallas: 35-36, 37-38, 39-40, 41-42, 43-44).

**Nueva necesidad**: El usuario debe poder seleccionar **solo algunas tallas específicas** de ese sistema.
- **Ejemplo**: Sistema "Tallas Numéricas" pero solo: 37-38, 39-40, 41-42 (no 35-36 ni 43-44)

---

## Implementación Backend

### 1. Nueva Tabla: `productos_maestros_tallas`

**Relación N:M** entre `productos_maestros` y `valores_talla`:

```sql
CREATE TABLE productos_maestros_tallas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producto_maestro_id UUID NOT NULL REFERENCES productos_maestros(id) ON DELETE CASCADE,
    valor_talla_id UUID NOT NULL REFERENCES valores_talla(id) ON DELETE RESTRICT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE UNIQUE INDEX idx_pm_tallas_unique ON productos_maestros_tallas(producto_maestro_id, valor_talla_id);
CREATE INDEX idx_pm_tallas_producto ON productos_maestros_tallas(producto_maestro_id);
CREATE INDEX idx_pm_tallas_valor ON productos_maestros_tallas(valor_talla_id);
```

**Trigger de validación**:
```sql
CREATE OR REPLACE FUNCTION validate_pm_talla_belongs_to_system()
RETURNS TRIGGER AS $$
DECLARE
    v_sistema_talla_id UUID;
    v_talla_sistema_id UUID;
BEGIN
    -- Obtener sistema_talla_id del producto maestro
    SELECT sistema_talla_id INTO v_sistema_talla_id
    FROM productos_maestros
    WHERE id = NEW.producto_maestro_id;

    -- Obtener sistema_talla_id del valor de talla
    SELECT sistema_talla_id INTO v_talla_sistema_id
    FROM valores_talla
    WHERE id = NEW.valor_talla_id;

    -- Validar que coincidan (RN-NEW-02)
    IF v_sistema_talla_id != v_talla_sistema_id THEN
        RAISE EXCEPTION 'La talla seleccionada no pertenece al sistema de tallas del producto maestro';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_pm_tallas_system
    BEFORE INSERT OR UPDATE ON productos_maestros_tallas
    FOR EACH ROW
    EXECUTE FUNCTION validate_pm_talla_belongs_to_system();
```

---

### 2. Funciones RPC Actualizadas

#### 2.1 `crear_producto_maestro` (ACTUALIZADA)

**Nuevo parámetro**: `p_tallas_ids UUID[]`

```sql
CREATE OR REPLACE FUNCTION crear_producto_maestro(
    p_marca_id UUID,
    p_material_id UUID,
    p_tipo_id UUID,
    p_sistema_talla_id UUID,
    p_descripcion TEXT DEFAULT NULL,
    p_tallas_ids UUID[] DEFAULT NULL  -- ← NUEVO
) RETURNS JSON
```

**Validaciones agregadas**:
- **RN-NEW-01**: Al menos 1 talla debe estar seleccionada
- **RN-NEW-02**: Todas las tallas deben pertenecer al `sistema_talla_id` del producto

**Lógica de inserción**:
```sql
-- Crear producto maestro
INSERT INTO productos_maestros (...) VALUES (...) RETURNING id INTO v_producto_id;

-- Insertar tallas seleccionadas
FOREACH v_talla_id IN ARRAY p_tallas_ids
LOOP
    INSERT INTO productos_maestros_tallas (producto_maestro_id, valor_talla_id, activo)
    VALUES (v_producto_id, v_talla_id, true);
END LOOP;
```

**Request ejemplo**:
```json
{
  "p_marca_id": "uuid-marca",
  "p_material_id": "uuid-material",
  "p_tipo_id": "uuid-tipo",
  "p_sistema_talla_id": "uuid-sistema-talla",
  "p_descripcion": "Producto de prueba",
  "p_tallas_ids": ["uuid-talla1", "uuid-talla2", "uuid-talla3"]
}
```

**Response success**:
```json
{
  "success": true,
  "data": {
    "id": "uuid-producto",
    "nombre_completo": "Adidas - Tobilleras - Algodón - Tallas Numéricas",
    "warnings": []
  }
}
```

**Response error - Sin tallas** (RN-NEW-01):
```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Debe seleccionar al menos una talla",
    "hint": "missing_tallas"
  }
}
```

**Response error - Talla de sistema incorrecto** (RN-NEW-02):
```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Todas las tallas deben pertenecer al sistema seleccionado",
    "hint": "talla_wrong_system"
  }
}
```

---

#### 2.2 `listar_productos_maestros` (ACTUALIZADA)

**Cambio**: Agregado campo `tallas_seleccionadas` en la respuesta

**Response JSON**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "marca_id": "uuid-marca",
      "marca_nombre": "Adidas",
      "marca_codigo": "ADI",
      "material_id": "uuid-material",
      "material_nombre": "Algodón",
      "material_codigo": "ALG",
      "tipo_id": "uuid-tipo",
      "tipo_nombre": "Tobilleras",
      "tipo_codigo": "TOB",
      "sistema_talla_id": "uuid-sistema",
      "sistema_talla_nombre": "Tallas Numéricas Europeas",
      "sistema_talla_tipo": "NUMERO",
      "descripcion": "Producto de prueba",
      "activo": true,
      "articulos_activos": 0,
      "articulos_totales": 0,
      "tiene_catalogos_inactivos": false,
      "nombre_completo": "Adidas - Tobilleras - Algodón - Tallas Numéricas",
      "tallas_seleccionadas": [
        {"id": "uuid-talla1", "valor": "37-38", "orden": 2},
        {"id": "uuid-talla2", "valor": "39-40", "orden": 3},
        {"id": "uuid-talla3", "valor": "41-42", "orden": 4}
      ],
      "created_at": "2025-10-15T...",
      "updated_at": "2025-10-15T..."
    }
  ]
}
```

**Implementación SQL**:
```sql
SELECT
    pm.id,
    -- ... otros campos
    (
        SELECT json_agg(json_build_object(
            'id', vt.id,
            'valor', vt.valor,
            'orden', vt.orden
        ) ORDER BY vt.orden)
        FROM productos_maestros_tallas pmt
        INNER JOIN valores_talla vt ON pmt.valor_talla_id = vt.id
        WHERE pmt.producto_maestro_id = pm.id AND pmt.activo = true
    ) as tallas_seleccionadas
FROM productos_maestros pm
```

---

#### 2.3 `editar_producto_maestro` (ACTUALIZADA)

**Nuevo parámetro**: `p_tallas_ids UUID[] DEFAULT NULL`

```sql
CREATE OR REPLACE FUNCTION editar_producto_maestro(
    p_producto_id UUID,
    p_marca_id UUID DEFAULT NULL,
    p_material_id UUID DEFAULT NULL,
    p_tipo_id UUID DEFAULT NULL,
    p_sistema_talla_id UUID DEFAULT NULL,
    p_descripcion TEXT DEFAULT NULL,
    p_tallas_ids UUID[] DEFAULT NULL  -- ← NUEVO
) RETURNS JSON
```

**Lógica de edición de tallas** (solo si **NO** tiene artículos derivados - RN-NEW-03):

```sql
IF p_tallas_ids IS NOT NULL THEN
    -- Validar al menos 1 talla (RN-NEW-01)
    IF array_length(p_tallas_ids, 1) < 1 THEN
        RAISE EXCEPTION 'Debe seleccionar al menos una talla';
    END IF;

    -- Validar pertenencia al sistema (RN-NEW-02)
    FOREACH v_talla_id IN ARRAY p_tallas_ids
    LOOP
        -- Validaciones...
    END LOOP;

    -- Actualizar tallas: DELETE + INSERT
    DELETE FROM productos_maestros_tallas WHERE producto_maestro_id = p_producto_id;

    FOREACH v_talla_id IN ARRAY p_tallas_ids
    LOOP
        INSERT INTO productos_maestros_tallas (producto_maestro_id, valor_talla_id, activo)
        VALUES (p_producto_id, v_talla_id, true);
    END LOOP;
END IF;
```

**Request ejemplo**:
```json
{
  "p_producto_id": "uuid-producto",
  "p_tallas_ids": ["uuid-talla1", "uuid-talla4", "uuid-talla5"]
}
```

**Response error - Tiene artículos derivados** (RN-NEW-03):
```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Este producto tiene 10 artículos derivados. Solo se puede editar la descripción",
    "hint": "has_derived_articles"
  }
}
```

---

## Reglas de Negocio Implementadas

| Código | Descripción | Implementación |
|--------|-------------|----------------|
| **RN-NEW-01** | Al menos 1 talla debe estar seleccionada | Validación en `crear_producto_maestro` y `editar_producto_maestro` |
| **RN-NEW-02** | Todas las tallas deben pertenecer al `sistema_talla_id` del producto | Validación en funciones + trigger `validate_pm_tallas_system` |
| **RN-NEW-03** | Si producto tiene artículos derivados, tallas NO son editables | Validación en `editar_producto_maestro` |
| **RN-NEW-04** | Validación de duplicados sigue siendo: marca+material+tipo+sistema (NO incluye tallas) | Mantiene constraint `productos_maestros_unique_combination` |

---

## Archivos Modificados

### Nuevos archivos:
- ✅ `supabase/migrations/00000000000008_productos_maestros_tallas.sql`

### Archivos actualizados:
- ✅ `supabase/migrations/00000000000005_functions.sql`
  - Función `crear_producto_maestro`: Agregado parámetro `p_tallas_ids` + validaciones + inserción en tabla relacional
  - Función `listar_productos_maestros`: Agregado campo `tallas_seleccionadas` en response
  - Función `editar_producto_maestro`: Agregado parámetro `p_tallas_ids` + lógica DELETE+INSERT

---

## Testing

### Verificación manual (Supabase Studio - http://localhost:54323)

**1. Obtener IDs de prueba**:
```sql
-- Obtener sistema de tallas
SELECT id, nombre, tipo_sistema FROM sistemas_talla WHERE nombre = 'Tallas Numéricas Europeas';

-- Obtener valores de talla del sistema
SELECT id, valor, orden FROM valores_talla WHERE sistema_talla_id = 'uuid-sistema' ORDER BY orden;

-- Obtener catálogos
SELECT id, nombre, codigo FROM marcas WHERE codigo = 'ADI';
SELECT id, nombre, codigo FROM materiales WHERE codigo = 'ALG';
SELECT id, nombre, codigo FROM tipos WHERE codigo = 'TOB';
```

**2. Crear producto maestro con tallas específicas**:
```sql
SELECT crear_producto_maestro(
    'uuid-marca-adi',
    'uuid-material-alg',
    'uuid-tipo-tob',
    'uuid-sistema-tallas-numericas',
    'Producto con tallas específicas',
    ARRAY['uuid-talla-37-38', 'uuid-talla-39-40', 'uuid-talla-41-42']::UUID[]
);
```

**3. Listar y verificar**:
```sql
SELECT listar_productos_maestros();
```

**4. Verificar tabla relacional**:
```sql
SELECT
    pm.id as producto_id,
    vt.valor as talla,
    vt.orden
FROM productos_maestros pm
INNER JOIN productos_maestros_tallas pmt ON pm.id = pmt.producto_maestro_id
INNER JOIN valores_talla vt ON pmt.valor_talla_id = vt.id
WHERE pmt.activo = true
ORDER BY pm.id, vt.orden;
```

**5. Editar tallas**:
```sql
SELECT editar_producto_maestro(
    'uuid-producto',
    NULL, NULL, NULL, NULL, NULL,
    ARRAY['uuid-talla-35-36', 'uuid-talla-37-38']::UUID[]
);
```

---

## Endpoints Disponibles (REST API)

**Base URL**: `http://127.0.0.1:54321/rest/v1/rpc/`

### Crear producto maestro con tallas:
```bash
curl -X POST "http://127.0.0.1:54321/rest/v1/rpc/crear_producto_maestro" \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "p_marca_id": "uuid-marca",
    "p_material_id": "uuid-material",
    "p_tipo_id": "uuid-tipo",
    "p_sistema_talla_id": "uuid-sistema",
    "p_descripcion": "Producto de prueba",
    "p_tallas_ids": ["uuid-talla1", "uuid-talla2", "uuid-talla3"]
  }'
```

### Listar productos maestros (con tallas):
```bash
curl -X POST "http://127.0.0.1:54321/rest/v1/rpc/listar_productos_maestros" \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json"
```

### Editar tallas de producto:
```bash
curl -X POST "http://127.0.0.1:54321/rest/v1/rpc/editar_producto_maestro" \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "p_producto_id": "uuid-producto",
    "p_tallas_ids": ["uuid-talla4", "uuid-talla5"]
  }'
```

---

## Migración Aplicada

```bash
npx supabase db reset
```

**Output**:
```
Applying migration 00000000000008_productos_maestros_tallas.sql...
✅ Migration aplicada exitosamente
```

---

## Checklist Final

- [x] Tabla `productos_maestros_tallas` creada
- [x] Índices y constraints aplicados
- [x] Trigger de validación `validate_pm_tallas_system` implementado
- [x] Función `crear_producto_maestro` actualizada con parámetro `p_tallas_ids`
- [x] Función `listar_productos_maestros` actualizada con campo `tallas_seleccionadas`
- [x] Función `editar_producto_maestro` actualizada con lógica DELETE+INSERT
- [x] Validaciones RN-NEW-01, RN-NEW-02, RN-NEW-03 implementadas
- [x] RLS policies configuradas
- [x] Migración aplicada exitosamente
- [x] JSON response format estándar aplicado
- [x] Documentación técnica completa

---

## Próximos Pasos (Frontend)

**Para @flutter-expert**:

1. **Actualizar modelo `ProductoMaestro`**:
   ```dart
   class ProductoMaestro {
     // ... campos existentes
     final List<TallaSeleccionada> tallasSeleccionadas;
   }

   class TallaSeleccionada {
     final String id;
     final String valor;
     final int orden;
   }
   ```

2. **Widget de selección de tallas**:
   - Cargar valores_talla del `sistema_talla_id` seleccionado
   - Permitir selección múltiple (Checkbox list)
   - Validar al menos 1 talla seleccionada

3. **Actualizar formularios**:
   - `ProductoMaestroFormPage`: Agregar selector de tallas
   - Enviar `p_tallas_ids` en requests a `crear_producto_maestro` y `editar_producto_maestro`
   - Mostrar tallas seleccionadas en lista de productos

4. **Validaciones UI**:
   - Si producto tiene artículos: deshabilitar selector de tallas
   - Mostrar mensaje: "Tallas no editables (tiene artículos derivados)"

---

**Versión**: 1.0
**Fecha última actualización**: 2025-10-15
**Responsable**: supabase-expert
