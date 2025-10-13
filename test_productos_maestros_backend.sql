-- ============================================
-- Tests Manuales Backend E002-HU-006
-- Productos Maestros
-- ============================================

-- 1. Verificar tabla creada
SELECT 'Test 1: Verificar tabla productos_maestros creada' AS test;
SELECT * FROM productos_maestros;

-- 2. Test validar_combinacion_comercial (RN-040)
SELECT 'Test 2: Validar combinación Futbol + ÚNICA (debe dar warning)' AS test;
SELECT validar_combinacion_comercial(
    p_tipo_id := (SELECT id FROM tipos WHERE LOWER(nombre) = 'futbol' LIMIT 1),
    p_sistema_talla_id := (SELECT id FROM sistemas_talla WHERE tipo_sistema = 'UNICA' LIMIT 1)
);

SELECT 'Test 2b: Validar combinación Futbol + NÚMERO (sin warning)' AS test;
SELECT validar_combinacion_comercial(
    p_tipo_id := (SELECT id FROM tipos WHERE LOWER(nombre) = 'futbol' LIMIT 1),
    p_sistema_talla_id := (SELECT id FROM sistemas_talla WHERE tipo_sistema = 'NUMERO' LIMIT 1)
);

-- 3. Test crear_producto_maestro exitoso
SELECT 'Test 3: Crear producto maestro Adidas-Algodón-Futbol-NÚMERO' AS test;
SELECT crear_producto_maestro(
    p_marca_id := (SELECT id FROM marcas WHERE codigo = 'ADI' LIMIT 1),
    p_material_id := (SELECT id FROM materiales WHERE codigo = 'ALG' LIMIT 1),
    p_tipo_id := (SELECT id FROM tipos WHERE codigo = 'FUT' LIMIT 1),
    p_sistema_talla_id := (SELECT id FROM sistemas_talla WHERE tipo_sistema = 'NUMERO' LIMIT 1),
    p_descripcion := 'Producto de prueba deportivo'
);

-- 4. Test validar duplicado activo (RN-037)
SELECT 'Test 4: Intentar crear producto duplicado (debe fallar con hint duplicate_combination)' AS test;
SELECT crear_producto_maestro(
    p_marca_id := (SELECT id FROM marcas WHERE codigo = 'ADI' LIMIT 1),
    p_material_id := (SELECT id FROM materiales WHERE codigo = 'ALG' LIMIT 1),
    p_tipo_id := (SELECT id FROM tipos WHERE codigo = 'FUT' LIMIT 1),
    p_sistema_talla_id := (SELECT id FROM sistemas_talla WHERE tipo_sistema = 'NUMERO' LIMIT 1),
    p_descripcion := 'Intento duplicado'
);

-- 5. Test listar_productos_maestros
SELECT 'Test 5: Listar todos los productos maestros' AS test;
SELECT listar_productos_maestros();

-- 6. Test listar con filtros
SELECT 'Test 6: Listar productos maestros filtrados por marca Adidas' AS test;
SELECT listar_productos_maestros(
    p_marca_id := (SELECT id FROM marcas WHERE codigo = 'ADI' LIMIT 1)
);

-- 7. Test editar descripción
SELECT 'Test 7: Editar descripción del producto creado' AS test;
SELECT editar_producto_maestro(
    p_producto_id := (SELECT id FROM productos_maestros LIMIT 1),
    p_descripcion := 'Nueva descripción editada'
);

-- 8. Test desactivar producto
SELECT 'Test 8: Desactivar producto maestro' AS test;
SELECT desactivar_producto_maestro(
    p_producto_id := (SELECT id FROM productos_maestros LIMIT 1)
);

-- 9. Test reactivar producto
SELECT 'Test 9: Reactivar producto maestro' AS test;
SELECT reactivar_producto_maestro(
    p_producto_id := (SELECT id FROM productos_maestros LIMIT 1)
);

-- 10. Test crear producto con combinación inactiva (CA-016)
SELECT 'Test 10: Desactivar producto y volver a crear (debe detectar inactivo)' AS test;
-- Primero desactivar
SELECT desactivar_producto_maestro(
    p_producto_id := (SELECT id FROM productos_maestros LIMIT 1)
);
-- Intentar crear misma combinación
SELECT crear_producto_maestro(
    p_marca_id := (SELECT id FROM marcas WHERE codigo = 'ADI' LIMIT 1),
    p_material_id := (SELECT id FROM materiales WHERE codigo = 'ALG' LIMIT 1),
    p_tipo_id := (SELECT id FROM tipos WHERE codigo = 'FUT' LIMIT 1),
    p_sistema_talla_id := (SELECT id FROM sistemas_talla WHERE tipo_sistema = 'NUMERO' LIMIT 1),
    p_descripcion := 'Intento con inactivo'
);

-- 11. Test crear producto con catálogo inactivo (RN-038)
SELECT 'Test 11: Intentar crear con marca inactiva (debe fallar)' AS test;
-- Primero desactivar una marca
UPDATE marcas SET activo = false WHERE codigo = 'NIK';
-- Intentar crear producto con esa marca
SELECT crear_producto_maestro(
    p_marca_id := (SELECT id FROM marcas WHERE codigo = 'NIK'),
    p_material_id := (SELECT id FROM materiales WHERE codigo = 'MIC' LIMIT 1),
    p_tipo_id := (SELECT id FROM tipos WHERE codigo = 'INV' LIMIT 1),
    p_sistema_talla_id := (SELECT id FROM sistemas_talla WHERE tipo_sistema = 'UNICA' LIMIT 1)
);
-- Reactivar marca
UPDATE marcas SET activo = true WHERE codigo = 'NIK';

-- 12. Test eliminar producto sin artículos (RN-043)
SELECT 'Test 12: Eliminar producto maestro (debe permitir si no tiene artículos)' AS test;
-- Crear producto para eliminar
SELECT crear_producto_maestro(
    p_marca_id := (SELECT id FROM marcas WHERE codigo = 'PUM' LIMIT 1),
    p_material_id := (SELECT id FROM materiales WHERE codigo = 'BAM' LIMIT 1),
    p_tipo_id := (SELECT id FROM tipos WHERE codigo = 'TOB' LIMIT 1),
    p_sistema_talla_id := (SELECT id FROM sistemas_talla WHERE tipo_sistema = 'LETRA' LIMIT 1)
);
-- Eliminar
SELECT eliminar_producto_maestro(
    p_producto_id := (SELECT id FROM productos_maestros WHERE descripcion IS NULL ORDER BY created_at DESC LIMIT 1)
);

-- 13. Test validar descripción max 200 chars (RN-039)
SELECT 'Test 13: Intentar crear con descripción > 200 chars (debe fallar)' AS test;
SELECT crear_producto_maestro(
    p_marca_id := (SELECT id FROM marcas WHERE codigo = 'REE' LIMIT 1),
    p_material_id := (SELECT id FROM materiales WHERE codigo = 'MOD' LIMIT 1),
    p_tipo_id := (SELECT id FROM tipos WHERE codigo = 'CLA' LIMIT 1),
    p_sistema_talla_id := (SELECT id FROM sistemas_talla WHERE tipo_sistema = 'NUMERO' LIMIT 1),
    p_descripcion := REPEAT('A', 201)
);

-- 14. Test búsqueda por texto (CA-010)
SELECT 'Test 14: Buscar productos por texto' AS test;
SELECT listar_productos_maestros(
    p_search_text := 'deportivo'
);

-- 15. Test obtener productos con catálogos inactivos (RN-038, CA-015)
SELECT 'Test 15: Crear producto, desactivar material y listar (debe detectar catálogo inactivo)' AS test;
-- Crear producto nuevo
SELECT crear_producto_maestro(
    p_marca_id := (SELECT id FROM marcas WHERE codigo = 'UMB' LIMIT 1),
    p_material_id := (SELECT id FROM materiales WHERE codigo = 'LAN' LIMIT 1),
    p_tipo_id := (SELECT id FROM tipos WHERE codigo = 'DEP' LIMIT 1),
    p_sistema_talla_id := (SELECT id FROM sistemas_talla WHERE tipo_sistema = 'LETRA' LIMIT 1)
);
-- Desactivar material
UPDATE materiales SET activo = false WHERE codigo = 'LAN';
-- Listar (debe mostrar tiene_catalogos_inactivos = true)
SELECT listar_productos_maestros();
-- Reactivar para no contaminar otros tests
UPDATE materiales SET activo = true WHERE codigo = 'LAN';

-- Resumen final
SELECT 'RESUMEN FINAL' AS titulo;
SELECT COUNT(*) AS total_productos_maestros FROM productos_maestros;
SELECT COUNT(*) AS productos_activos FROM productos_maestros WHERE activo = true;
SELECT COUNT(*) AS productos_inactivos FROM productos_maestros WHERE activo = false;
