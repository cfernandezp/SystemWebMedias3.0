-- ============================================
-- HU-008: Testing Manual - crear_producto_completo()
-- ============================================
-- Ejecutar en Supabase Studio → SQL Editor
-- URL Local: http://localhost:54323/project/default/sql

-- ============================================
-- PASO 0: Obtener IDs de catálogos activos
-- ============================================

-- Obtener IDs de catálogos (copiar UUIDs para usar en los tests)
SELECT 'MARCAS' as tipo, id, nombre, codigo FROM marcas WHERE activo = true LIMIT 3;
SELECT 'MATERIALES' as tipo, id, nombre, codigo FROM materiales WHERE activo = true LIMIT 3;
SELECT 'TIPOS' as tipo, id, nombre, codigo FROM tipos WHERE activo = true LIMIT 3;
SELECT 'SISTEMAS_TALLA' as tipo, id, nombre FROM sistemas_talla WHERE activo = true LIMIT 3;
SELECT 'COLORES' as tipo, id, nombre FROM colores WHERE activo = true LIMIT 5;

-- ============================================
-- CASO 1: Crear producto con 2 artículos unicolor (precios diferentes)
-- ============================================
-- Reemplazar UUIDs con los obtenidos en PASO 0

SELECT crear_producto_completo(
    -- Producto maestro
    jsonb_build_object(
        'marca_id', '11111111-1111-1111-1111-111111111111', -- Reemplazar con ID de marca activa
        'material_id', '22222222-2222-2222-2222-222222222222', -- Reemplazar con ID de material activo
        'tipo_id', '33333333-3333-3333-3333-333333333333', -- Reemplazar con ID de tipo activo
        'sistema_talla_id', '44444444-4444-4444-4444-444444444444', -- Reemplazar con ID de sistema activo
        'descripcion', 'Media deportiva prueba HU-008'
    ),
    -- Artículos
    ARRAY[
        jsonb_build_object(
            'colores_ids', jsonb_build_array('55555555-5555-5555-5555-555555555555'), -- Color Rojo
            'precio', 7000
        ),
        jsonb_build_object(
            'colores_ids', jsonb_build_array('66666666-6666-6666-6666-666666666666'), -- Color Azul
            'precio', 8000
        )
    ]::jsonb[]
);

-- Verificar resultado: Debe retornar JSON con success=true y 2 SKUs generados
-- Ejemplo esperado:
-- {
--   "success": true,
--   "data": {
--     "producto_maestro_id": "uuid-generado",
--     "articulos_creados": 2,
--     "skus_generados": ["NIK-ALG-DEP-ROJ", "NIK-ALG-DEP-AZU"]
--   }
-- }

-- ============================================
-- CASO 2: Crear producto con artículo bicolor
-- ============================================

SELECT crear_producto_completo(
    jsonb_build_object(
        'marca_id', '11111111-1111-1111-1111-111111111111',
        'material_id', '22222222-2222-2222-2222-222222222222',
        'tipo_id', '33333333-3333-3333-3333-333333333333',
        'sistema_talla_id', '44444444-4444-4444-4444-444444444444',
        'descripcion', 'Media bicolor prueba'
    ),
    ARRAY[
        jsonb_build_object(
            'colores_ids', jsonb_build_array(
                '55555555-5555-5555-5555-555555555555', -- Color 1
                '66666666-6666-6666-6666-666666666666'  -- Color 2
            ),
            'precio', 9500
        )
    ]::jsonb[]
);

-- Verificar: tipo_coloracion debe ser 'bicolor' y SKU con 2 colores

-- ============================================
-- CASO 3: Crear producto sin artículos (válido - RN-008-001)
-- ============================================

SELECT crear_producto_completo(
    jsonb_build_object(
        'marca_id', '11111111-1111-1111-1111-111111111111',
        'material_id', '22222222-2222-2222-2222-222222222222',
        'tipo_id', '77777777-7777-7777-7777-777777777777', -- Diferente tipo para evitar duplicado
        'sistema_talla_id', '44444444-4444-4444-4444-444444444444',
        'descripcion', 'Producto futuro sin artículos'
    ),
    ARRAY[]::jsonb[] -- Array vacío
);

-- Verificar:
-- - success = true
-- - articulos_creados = 0
-- - message = "Producto maestro creado exitosamente (sin artículos)"

-- ============================================
-- CASO 4: Error duplicado (RN-008-004)
-- ============================================
-- Ejecutar 2 veces el CASO 1 con mismos IDs

SELECT crear_producto_completo(
    jsonb_build_object(
        'marca_id', '11111111-1111-1111-1111-111111111111', -- Mismos IDs que CASO 1
        'material_id', '22222222-2222-2222-2222-222222222222',
        'tipo_id', '33333333-3333-3333-3333-333333333333',
        'sistema_talla_id', '44444444-4444-4444-4444-444444444444',
        'descripcion', 'Duplicado'
    ),
    ARRAY[]::jsonb[]
);

-- Verificar:
-- - success = false
-- - error.hint = 'duplicate_producto'
-- - error.message contiene "Esta combinación de producto ya existe"

-- ============================================
-- CASO 5: Error color inactivo (RN-008-005)
-- ============================================
-- Primero desactivar un color

UPDATE colores SET activo = false WHERE id = '55555555-5555-5555-5555-555555555555';

-- Intentar crear producto con ese color
SELECT crear_producto_completo(
    jsonb_build_object(
        'marca_id', '11111111-1111-1111-1111-111111111111',
        'material_id', '22222222-2222-2222-2222-222222222222',
        'tipo_id', '88888888-8888-8888-8888-888888888888', -- Tipo diferente
        'sistema_talla_id', '44444444-4444-4444-4444-444444444444'
    ),
    ARRAY[
        jsonb_build_object(
            'colores_ids', jsonb_build_array('55555555-5555-5555-5555-555555555555'), -- Color inactivo
            'precio', 7000
        )
    ]::jsonb[]
);

-- Verificar:
-- - success = false
-- - error.hint = 'invalid_color'
-- - error.message = "Uno o más colores no existen o están inactivos"

-- Reactivar color para no afectar otros tests
UPDATE colores SET activo = true WHERE id = '55555555-5555-5555-5555-555555555555';

-- ============================================
-- CASO 6: Error catálogo inactivo (RN-008-006)
-- ============================================
-- Desactivar una marca

UPDATE marcas SET activo = false WHERE id = '11111111-1111-1111-1111-111111111111';

-- Intentar crear producto con esa marca
SELECT crear_producto_completo(
    jsonb_build_object(
        'marca_id', '11111111-1111-1111-1111-111111111111', -- Marca inactiva
        'material_id', '22222222-2222-2222-2222-222222222222',
        'tipo_id', '33333333-3333-3333-3333-333333333333',
        'sistema_talla_id', '44444444-4444-4444-4444-444444444444'
    ),
    ARRAY[]::jsonb[]
);

-- Verificar:
-- - success = false
-- - error.hint = 'invalid_catalog'
-- - error.message = "Marca no existe o está inactiva"

-- Reactivar marca
UPDATE marcas SET activo = true WHERE id = '11111111-1111-1111-1111-111111111111';

-- ============================================
-- CASO 7: Error parámetro faltante
-- ============================================

SELECT crear_producto_completo(
    jsonb_build_object(
        'marca_id', '11111111-1111-1111-1111-111111111111',
        'material_id', '22222222-2222-2222-2222-222222222222'
        -- Falta tipo_id y sistema_talla_id
    ),
    ARRAY[]::jsonb[]
);

-- Verificar:
-- - success = false
-- - error.hint = 'missing_param'
-- - error.message = "Marca, Material, Tipo y Sistema de Talla son obligatorios"

-- ============================================
-- CASO 8: Error precio inválido
-- ============================================

SELECT crear_producto_completo(
    jsonb_build_object(
        'marca_id', '11111111-1111-1111-1111-111111111111',
        'material_id', '22222222-2222-2222-2222-222222222222',
        'tipo_id', '99999999-9999-9999-9999-999999999999',
        'sistema_talla_id', '44444444-4444-4444-4444-444444444444'
    ),
    ARRAY[
        jsonb_build_object(
            'colores_ids', jsonb_build_array('55555555-5555-5555-5555-555555555555'),
            'precio', 0 -- Precio inválido
        )
    ]::jsonb[]
);

-- Verificar:
-- - success = false
-- - error.hint = 'missing_param'
-- - error.message = "El precio debe ser mayor a 0"

-- ============================================
-- VERIFICACIÓN FINAL: Listar productos creados
-- ============================================

SELECT
    pm.id,
    m.nombre as marca,
    mt.nombre as material,
    t.nombre as tipo,
    st.nombre as sistema_talla,
    pm.descripcion,
    pm.activo,
    pm.created_at
FROM productos_maestros pm
INNER JOIN marcas m ON pm.marca_id = m.id
INNER JOIN materiales mt ON pm.material_id = mt.id
INNER JOIN tipos t ON pm.tipo_id = t.id
INNER JOIN sistemas_talla st ON pm.sistema_talla_id = st.id
ORDER BY pm.created_at DESC
LIMIT 10;

-- Listar artículos creados con SKUs
SELECT
    a.id,
    a.sku,
    a.tipo_coloracion,
    array_length(a.colores_ids, 1) as cantidad_colores,
    a.precio,
    pm.descripcion as producto_maestro,
    a.activo,
    a.created_at
FROM articulos a
INNER JOIN productos_maestros pm ON a.producto_maestro_id = pm.id
ORDER BY a.created_at DESC
LIMIT 20;

-- ============================================
-- LIMPIEZA (OPCIONAL)
-- ============================================
-- Eliminar productos de prueba creados

-- DELETE FROM articulos WHERE created_at > NOW() - INTERVAL '1 hour';
-- DELETE FROM productos_maestros WHERE created_at > NOW() - INTERVAL '1 hour';
