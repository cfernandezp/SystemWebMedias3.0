-- ============================================
-- TEST SCRIPT: Productos Maestros (HU-006)
-- ============================================

-- Obtener IDs de catálogos existentes (seed data)
SELECT 'MARCAS DISPONIBLES:' as seccion;
SELECT id, nombre, codigo, activo FROM marcas LIMIT 5;

SELECT 'MATERIALES DISPONIBLES:' as seccion;
SELECT id, nombre, codigo, activo FROM materiales LIMIT 5;

SELECT 'TIPOS DISPONIBLES:' as seccion;
SELECT id, nombre, codigo, activo FROM tipos LIMIT 5;

SELECT 'SISTEMAS DE TALLAS DISPONIBLES:' as seccion;
SELECT id, nombre, tipo_sistema, activo FROM sistemas_talla LIMIT 5;

-- ============================================
-- TEST 1: Validar combinación comercial
-- ============================================
SELECT '============================================' as test;
SELECT 'TEST 1: Validar combinación comercial' as test;
SELECT '============================================' as test;

-- Obtener un tipo "Futbol" y sistema "UNICA" para generar advertencia
DO $$
DECLARE
    v_tipo_futbol_id UUID;
    v_sistema_unica_id UUID;
    v_result JSON;
BEGIN
    SELECT id INTO v_tipo_futbol_id FROM tipos WHERE LOWER(nombre) LIKE '%futbol%' LIMIT 1;
    SELECT id INTO v_sistema_unica_id FROM sistemas_talla WHERE tipo_sistema = 'UNICA' LIMIT 1;

    IF v_tipo_futbol_id IS NOT NULL AND v_sistema_unica_id IS NOT NULL THEN
        SELECT validar_combinacion_comercial(v_tipo_futbol_id, v_sistema_unica_id) INTO v_result;
        RAISE NOTICE 'Validación Futbol + UNICA: %', v_result;
    ELSE
        RAISE NOTICE 'No se encontraron datos para test de validación comercial';
    END IF;
END $$;

-- ============================================
-- TEST 2: Crear producto maestro válido
-- ============================================
SELECT '============================================' as test;
SELECT 'TEST 2: Crear producto maestro válido' as test;
SELECT '============================================' as test;

DO $$
DECLARE
    v_marca_id UUID;
    v_material_id UUID;
    v_tipo_id UUID;
    v_sistema_id UUID;
    v_result JSON;
BEGIN
    -- Obtener IDs de catálogos activos
    SELECT id INTO v_marca_id FROM marcas WHERE activo = true LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE activo = true LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE activo = true LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE activo = true LIMIT 1;

    -- Crear producto maestro
    SELECT crear_producto_maestro(
        v_marca_id,
        v_material_id,
        v_tipo_id,
        v_sistema_id,
        'Producto de prueba línea deportiva'
    ) INTO v_result;

    RAISE NOTICE 'Resultado creación: %', v_result;
END $$;

-- ============================================
-- TEST 3: Intentar crear duplicado (debe fallar)
-- ============================================
SELECT '============================================' as test;
SELECT 'TEST 3: Intentar crear duplicado (debe fallar)' as test;
SELECT '============================================' as test;

DO $$
DECLARE
    v_marca_id UUID;
    v_material_id UUID;
    v_tipo_id UUID;
    v_sistema_id UUID;
    v_result JSON;
BEGIN
    -- Usar mismos IDs que test anterior
    SELECT id INTO v_marca_id FROM marcas WHERE activo = true LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE activo = true LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE activo = true LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE activo = true LIMIT 1;

    -- Intentar crear duplicado
    SELECT crear_producto_maestro(
        v_marca_id,
        v_material_id,
        v_tipo_id,
        v_sistema_id,
        'Otro producto'
    ) INTO v_result;

    RAISE NOTICE 'Resultado duplicado (debe fallar): %', v_result;
END $$;

-- ============================================
-- TEST 4: Listar productos maestros
-- ============================================
SELECT '============================================' as test;
SELECT 'TEST 4: Listar productos maestros' as test;
SELECT '============================================' as test;

SELECT listar_productos_maestros(
    NULL, -- p_marca_id
    NULL, -- p_material_id
    NULL, -- p_tipo_id
    NULL, -- p_sistema_talla_id
    NULL, -- p_activo
    NULL  -- p_search_text
) as productos;

-- ============================================
-- TEST 5: Editar descripción de producto maestro
-- ============================================
SELECT '============================================' as test;
SELECT 'TEST 5: Editar descripción' as test;
SELECT '============================================' as test;

DO $$
DECLARE
    v_producto_id UUID;
    v_result JSON;
BEGIN
    -- Obtener ID del producto creado
    SELECT id INTO v_producto_id FROM productos_maestros ORDER BY created_at DESC LIMIT 1;

    IF v_producto_id IS NOT NULL THEN
        SELECT editar_producto_maestro(
            v_producto_id,
            NULL, -- marca_id
            NULL, -- material_id
            NULL, -- tipo_id
            NULL, -- sistema_talla_id
            'Descripción actualizada exitosamente'
        ) INTO v_result;

        RAISE NOTICE 'Resultado edición: %', v_result;
    END IF;
END $$;

-- ============================================
-- TEST 6: Desactivar producto maestro
-- ============================================
SELECT '============================================' as test;
SELECT 'TEST 6: Desactivar producto maestro' as test;
SELECT '============================================' as test;

DO $$
DECLARE
    v_producto_id UUID;
    v_result JSON;
BEGIN
    SELECT id INTO v_producto_id FROM productos_maestros WHERE activo = true ORDER BY created_at DESC LIMIT 1;

    IF v_producto_id IS NOT NULL THEN
        SELECT desactivar_producto_maestro(v_producto_id, false) INTO v_result;
        RAISE NOTICE 'Resultado desactivación: %', v_result;
    END IF;
END $$;

-- ============================================
-- TEST 7: Reactivar producto maestro
-- ============================================
SELECT '============================================' as test;
SELECT 'TEST 7: Reactivar producto maestro' as test;
SELECT '============================================' as test;

DO $$
DECLARE
    v_producto_id UUID;
    v_result JSON;
BEGIN
    SELECT id INTO v_producto_id FROM productos_maestros WHERE activo = false ORDER BY created_at DESC LIMIT 1;

    IF v_producto_id IS NOT NULL THEN
        SELECT reactivar_producto_maestro(v_producto_id) INTO v_result;
        RAISE NOTICE 'Resultado reactivación: %', v_result;
    END IF;
END $$;

-- ============================================
-- TEST 8: Eliminar producto maestro (debe funcionar si no tiene artículos)
-- ============================================
SELECT '============================================' as test;
SELECT 'TEST 8: Eliminar producto maestro' as test;
SELECT '============================================' as test;

DO $$
DECLARE
    v_producto_id UUID;
    v_result JSON;
BEGIN
    SELECT id INTO v_producto_id FROM productos_maestros ORDER BY created_at DESC LIMIT 1;

    IF v_producto_id IS NOT NULL THEN
        SELECT eliminar_producto_maestro(v_producto_id) INTO v_result;
        RAISE NOTICE 'Resultado eliminación: %', v_result;
    END IF;
END $$;

-- ============================================
-- RESUMEN FINAL
-- ============================================
SELECT '============================================' as resumen;
SELECT 'RESUMEN FINAL: Productos Maestros en BD' as resumen;
SELECT '============================================' as resumen;

SELECT
    COUNT(*) as total_productos,
    COUNT(CASE WHEN activo = true THEN 1 END) as activos,
    COUNT(CASE WHEN activo = false THEN 1 END) as inactivos
FROM productos_maestros;

SELECT * FROM productos_maestros ORDER BY created_at DESC;
