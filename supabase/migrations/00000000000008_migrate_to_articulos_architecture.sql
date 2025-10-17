-- ============================================
-- Migration: 00000000000008_migrate_to_articulos_architecture.sql
-- Descripción: Migrar funciones RPC de producto_colores a articulos
-- Fecha: 2025-10-17
-- ============================================
-- CAMBIOS PRINCIPALES:
-- - Tabla: producto_colores → articulos
-- - Columna: colores TEXT[] → colores_ids UUID[]
-- - Relación: articulos.producto_maestro_id → productos_maestros.id
-- - Catálogo: colores.id (UUID) en lugar de colores.nombre (TEXT)
-- ============================================

BEGIN;

-- ============================================
-- PASO 1: DROP funciones antiguas
-- ============================================

DROP FUNCTION IF EXISTS listar_colores();
DROP FUNCTION IF EXISTS editar_color(UUID, TEXT, TEXT[]);
DROP FUNCTION IF EXISTS eliminar_color(UUID);
DROP FUNCTION IF EXISTS obtener_productos_por_color(TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS estadisticas_colores();
DROP FUNCTION IF EXISTS filtrar_productos_por_combinacion(TEXT[]);

-- ============================================
-- PASO 2: Funciones migradas a arquitectura articulos
-- ============================================

-- Función 1: listar_colores - Contar artículos por color usando colores_ids UUID[]
CREATE OR REPLACE FUNCTION listar_colores()
RETURNS JSON AS $$
BEGIN
    RETURN json_build_object(
        'success', true,
        'data', COALESCE(
            (SELECT json_agg(
                json_build_object(
                    'id', c.id,
                    'nombre', c.nombre,
                    'codigos_hex', c.codigos_hex,
                    'tipo_color', c.tipo_color,
                    'activo', c.activo,
                    'productos_count', COALESCE((
                        SELECT COUNT(DISTINCT a.id)
                        FROM articulos a
                        WHERE c.id = ANY(a.colores_ids)
                    ), 0),
                    'created_at', c.created_at,
                    'updated_at', c.updated_at
                ) ORDER BY c.nombre
            )
            FROM colores c
            WHERE c.activo = true),
            '[]'::json
        ),
        'message', 'Colores listados exitosamente'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION listar_colores() IS 'E002-HU-005-EXT: Lista colores con tipo y códigos hex - migrado a articulos';

-- Función 2: editar_color - Contar artículos afectados por edición
CREATE OR REPLACE FUNCTION editar_color(
    p_id UUID,
    p_nombre TEXT,
    p_codigos_hex TEXT[]
)
RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;
    v_user_id UUID;
    v_user_rol TEXT;
    v_tipo_color VARCHAR(10);
    v_cantidad_codigos INTEGER;
    v_productos_count INTEGER;
BEGIN
    -- Obtener usuario autenticado
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- Verificar que usuario es ADMIN o GERENTE
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR (v_user_rol != 'ADMIN' AND v_user_rol != 'GERENTE') THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN o GERENTE pueden gestionar colores';
    END IF;

    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM colores WHERE id = p_id) THEN
        v_error_hint := 'color_not_found';
        RAISE EXCEPTION 'Color no encontrado';
    END IF;

    -- Determinar tipo según cantidad de códigos
    v_cantidad_codigos := array_length(p_codigos_hex, 1);

    IF v_cantidad_codigos = 1 THEN
        v_tipo_color := 'unico';
    ELSIF v_cantidad_codigos BETWEEN 2 AND 3 THEN
        v_tipo_color := 'compuesto';
    ELSE
        v_error_hint := 'invalid_color_count';
        RAISE EXCEPTION 'Debe proporcionar entre 1 y 3 códigos hexadecimales';
    END IF;

    -- RN-025: Validar nombre único (excepto mismo color)
    IF EXISTS (SELECT 1 FROM colores WHERE LOWER(nombre) = LOWER(TRIM(p_nombre)) AND id != p_id) THEN
        v_error_hint := 'duplicate_name';
        RAISE EXCEPTION 'Ya existe otro color con el nombre "%"', p_nombre;
    END IF;

    -- RN-025: Validar longitud nombre
    IF LENGTH(TRIM(p_nombre)) < 3 OR LENGTH(TRIM(p_nombre)) > 30 THEN
        v_error_hint := 'invalid_name_length';
        RAISE EXCEPTION 'El nombre debe tener entre 3 y 30 caracteres';
    END IF;

    -- RN-025: Validar caracteres permitidos
    IF TRIM(p_nombre) !~ '^[A-Za-zÀ-ÿ\s\-]+$' THEN
        v_error_hint := 'invalid_name_chars';
        RAISE EXCEPTION 'El nombre solo puede contener letras, espacios y guiones';
    END IF;

    -- Contar artículos afectados (migrado a articulos)
    SELECT COUNT(DISTINCT a.id)
    INTO v_productos_count
    FROM articulos a
    WHERE p_id = ANY(a.colores_ids);

    -- Actualizar color (trigger validará formato hex)
    UPDATE colores
    SET nombre = TRIM(p_nombre),
        codigos_hex = p_codigos_hex,
        tipo_color = v_tipo_color,
        updated_at = NOW()
    WHERE id = p_id;

    -- Retornar éxito
    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'id', p_id,
            'nombre', TRIM(p_nombre),
            'codigos_hex', p_codigos_hex,
            'tipo_color', v_tipo_color,
            'productos_count', COALESCE(v_productos_count, 0)
        ),
        'message', 'Color actualizado exitosamente'
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

COMMENT ON FUNCTION editar_color(UUID, TEXT, TEXT[]) IS 'E002-HU-005-EXT: Edita color y retorna artículos afectados - migrado a articulos';

-- Función 3: eliminar_color - Verificar si color está en uso en articulos
CREATE OR REPLACE FUNCTION eliminar_color(
    p_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_user_id UUID;
    v_user_rol TEXT;
    v_productos_count INTEGER;
    v_color_nombre TEXT;
    v_deleted BOOLEAN := false;
    v_deactivated BOOLEAN := false;
BEGIN
    -- Obtener usuario autenticado
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Usuario no autenticado';
    END IF;

    -- Verificar que usuario es ADMIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = v_user_id;

    IF v_user_rol IS NULL OR v_user_rol != 'ADMIN' THEN
        v_error_hint := 'unauthorized';
        RAISE EXCEPTION 'Solo usuarios ADMIN pueden eliminar colores';
    END IF;

    -- Verificar que color existe
    SELECT nombre INTO v_color_nombre
    FROM colores
    WHERE id = p_id;

    IF v_color_nombre IS NULL THEN
        v_error_hint := 'color_not_found';
        RAISE EXCEPTION 'El color no existe';
    END IF;

    -- RN-029: Verificar si color está en uso en articulos
    SELECT COUNT(*) INTO v_productos_count
    FROM articulos
    WHERE p_id = ANY(colores_ids);

    IF v_productos_count > 0 THEN
        -- RN-029: Color en uso → solo desactivar
        v_error_hint := 'has_products_use_deactivate';

        UPDATE colores
        SET activo = false
        WHERE id = p_id;

        v_deactivated := true;

        -- Registrar auditoría
        INSERT INTO audit_logs (user_id, event_type, metadata)
        VALUES (
            v_user_id,
            'color_deactivated',
            json_build_object(
                'color_id', p_id,
                'nombre', v_color_nombre,
                'productos_count', v_productos_count
            )::jsonb
        );

        RETURN json_build_object(
            'success', true,
            'data', json_build_object(
                'deleted', v_deleted,
                'deactivated', v_deactivated,
                'productos_count', v_productos_count
            ),
            'message', 'El color está en uso en ' || v_productos_count || ' artículo(s). Se ha desactivado en lugar de eliminarse'
        );
    ELSE
        -- RN-029: Color sin uso → eliminar permanente
        DELETE FROM colores WHERE id = p_id;
        v_deleted := true;

        -- Registrar auditoría
        INSERT INTO audit_logs (user_id, event_type, metadata)
        VALUES (
            v_user_id,
            'color_deleted',
            json_build_object(
                'color_id', p_id,
                'nombre', v_color_nombre
            )::jsonb
        );

        RETURN json_build_object(
            'success', true,
            'data', json_build_object(
                'deleted', v_deleted,
                'deactivated', v_deactivated,
                'productos_count', 0
            ),
            'message', 'Color eliminado permanentemente'
        );
    END IF;

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

COMMENT ON FUNCTION eliminar_color IS 'E002-HU-005: Elimina o desactiva color según uso - migrado a articulos';

-- Función 4: obtener_productos_por_color - Buscar artículos con color específico (cambio de parámetro TEXT a UUID)
CREATE OR REPLACE FUNCTION obtener_productos_por_color(
    p_color_id UUID,
    p_exacto BOOLEAN DEFAULT false
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Validar que color existe
    IF NOT EXISTS (SELECT 1 FROM colores WHERE id = p_color_id) THEN
        v_error_hint := 'color_not_found';
        RAISE EXCEPTION 'El color no existe en el catálogo';
    END IF;

    IF p_exacto THEN
        -- RN-033: Búsqueda exacta (solo ese color, unicolor)
        SELECT json_agg(
            json_build_object(
                'id', a.id,
                'sku', a.sku,
                'tipo_coloracion', a.tipo_coloracion,
                'precio', a.precio,
                'colores_ids', a.colores_ids,
                'producto_maestro', json_build_object(
                    'id', pm.id,
                    'marca_id', pm.marca_id,
                    'material_id', pm.material_id,
                    'tipo_id', pm.tipo_id,
                    'valor_talla_id', pm.valor_talla_id,
                    'descripcion', pm.descripcion
                )
            )
        ) INTO v_result
        FROM articulos a
        INNER JOIN productos_maestros pm ON a.producto_maestro_id = pm.id
        WHERE a.colores_ids = ARRAY[p_color_id]::UUID[]
        AND a.activo = true;
    ELSE
        -- RN-033: Búsqueda inclusiva (contiene el color)
        SELECT json_agg(
            json_build_object(
                'id', a.id,
                'sku', a.sku,
                'tipo_coloracion', a.tipo_coloracion,
                'precio', a.precio,
                'colores_ids', a.colores_ids,
                'producto_maestro', json_build_object(
                    'id', pm.id,
                    'marca_id', pm.marca_id,
                    'material_id', pm.material_id,
                    'tipo_id', pm.tipo_id,
                    'valor_talla_id', pm.valor_talla_id,
                    'descripcion', pm.descripcion
                )
            )
        ) INTO v_result
        FROM articulos a
        INNER JOIN productos_maestros pm ON a.producto_maestro_id = pm.id
        WHERE p_color_id = ANY(a.colores_ids)
        AND a.activo = true;
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', COALESCE(v_result, '[]'::json),
        'message', CASE
            WHEN p_exacto THEN 'Artículos con color exacto listados exitosamente'
            ELSE 'Artículos que contienen el color listados exitosamente'
        END
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

COMMENT ON FUNCTION obtener_productos_por_color IS 'E002-HU-005: Busca artículos por color UUID - migrado a articulos';

-- Función 5: estadisticas_colores - Generar estadísticas usando articulos
CREATE OR REPLACE FUNCTION estadisticas_colores()
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_total_productos INTEGER;
    v_productos_unicolor INTEGER;
    v_productos_multicolor INTEGER;
    v_porcentaje_unicolor DECIMAL;
    v_porcentaje_multicolor DECIMAL;
    v_productos_por_color JSON;
    v_top_combinaciones JSON;
    v_colores_menos_usados JSON;
BEGIN
    -- RN-035: Cantidad total de artículos
    SELECT COUNT(*) INTO v_total_productos
    FROM articulos;

    -- RN-035: Artículos unicolor vs multicolor
    SELECT COUNT(*) INTO v_productos_unicolor
    FROM articulos
    WHERE tipo_coloracion = 'unicolor';

    SELECT COUNT(*) INTO v_productos_multicolor
    FROM articulos
    WHERE tipo_coloracion IN ('bicolor', 'tricolor');

    -- Calcular porcentajes
    IF v_total_productos > 0 THEN
        v_porcentaje_unicolor := ROUND((v_productos_unicolor::DECIMAL / v_total_productos * 100), 2);
        v_porcentaje_multicolor := ROUND((v_productos_multicolor::DECIMAL / v_total_productos * 100), 2);
    ELSE
        v_porcentaje_unicolor := 0;
        v_porcentaje_multicolor := 0;
    END IF;

    -- RN-035: Cantidad de artículos por color base
    SELECT json_agg(
        json_build_object(
            'color', c.nombre,
            'codigos_hex', c.codigos_hex,
            'tipo_color', c.tipo_color,
            'cantidad_productos', COALESCE((
                SELECT COUNT(*)
                FROM articulos a
                WHERE c.id = ANY(a.colores_ids)
            ), 0)
        ) ORDER BY COALESCE((
            SELECT COUNT(*)
            FROM articulos a
            WHERE c.id = ANY(a.colores_ids)
        ), 0) DESC
    ) INTO v_productos_por_color
    FROM colores c
    WHERE c.activo = true;

    -- RN-035: Top 5 combinaciones más usadas
    SELECT json_agg(
        json_build_object(
            'colores_ids', a.colores_ids,
            'tipo_coloracion', a.tipo_coloracion,
            'cantidad_productos', count
        ) ORDER BY count DESC
    ) INTO v_top_combinaciones
    FROM (
        SELECT colores_ids, tipo_coloracion, COUNT(*) as count
        FROM articulos
        WHERE array_length(colores_ids, 1) > 1
        GROUP BY colores_ids, tipo_coloracion
        ORDER BY COUNT(*) DESC
        LIMIT 5
    ) a;

    -- RN-035: Colores con menor uso (candidatos a descontinuar)
    SELECT json_agg(
        json_build_object(
            'color', c.nombre,
            'codigos_hex', c.codigos_hex,
            'tipo_color', c.tipo_color,
            'cantidad_productos', COALESCE((
                SELECT COUNT(*)
                FROM articulos a
                WHERE c.id = ANY(a.colores_ids)
            ), 0)
        ) ORDER BY COALESCE((
            SELECT COUNT(*)
            FROM articulos a
            WHERE c.id = ANY(a.colores_ids)
        ), 0) ASC
    ) INTO v_colores_menos_usados
    FROM colores c
    WHERE c.activo = true
    LIMIT 5;

    -- CA-011: Construir respuesta completa
    v_result := json_build_object(
        'total_productos', v_total_productos,
        'productos_unicolor', v_productos_unicolor,
        'productos_multicolor', v_productos_multicolor,
        'porcentaje_unicolor', v_porcentaje_unicolor,
        'porcentaje_multicolor', v_porcentaje_multicolor,
        'productos_por_color', COALESCE(v_productos_por_color, '[]'::json),
        'top_combinaciones', COALESCE(v_top_combinaciones, '[]'::json),
        'colores_menos_usados', COALESCE(v_colores_menos_usados, '[]'::json)
    );

    RETURN json_build_object(
        'success', true,
        'data', v_result,
        'message', 'Estadísticas de colores generadas exitosamente'
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

COMMENT ON FUNCTION estadisticas_colores IS 'E002-HU-005: Estadísticas de uso de colores - migrado a articulos';

-- Función 6: filtrar_productos_por_combinacion - Buscar artículos por combinación exacta de colores (cambio de parámetro TEXT[] a UUID[])
CREATE OR REPLACE FUNCTION filtrar_productos_por_combinacion(
    p_colores_ids UUID[]
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_error_hint TEXT;
    v_color_id UUID;
BEGIN
    -- Validar que array no esté vacío
    IF p_colores_ids IS NULL OR array_length(p_colores_ids, 1) IS NULL THEN
        v_error_hint := 'missing_colors';
        RAISE EXCEPTION 'Debe proporcionar al menos un color';
    END IF;

    -- Validar que todos los colores existan en el catálogo
    FOREACH v_color_id IN ARRAY p_colores_ids
    LOOP
        IF NOT EXISTS (SELECT 1 FROM colores WHERE id = v_color_id) THEN
            v_error_hint := 'color_not_found';
            RAISE EXCEPTION 'El color con ID "%" no existe en el catálogo', v_color_id;
        END IF;
    END LOOP;

    -- CA-009: Buscar artículos con combinación EXACTA de colores (mismo orden)
    SELECT json_agg(
        json_build_object(
            'id', a.id,
            'sku', a.sku,
            'tipo_coloracion', a.tipo_coloracion,
            'precio', a.precio,
            'colores_ids', a.colores_ids,
            'producto_maestro', json_build_object(
                'id', pm.id,
                'marca_id', pm.marca_id,
                'material_id', pm.material_id,
                'tipo_id', pm.tipo_id,
                'valor_talla_id', pm.valor_talla_id,
                'descripcion', pm.descripcion
            )
        )
    ) INTO v_result
    FROM articulos a
    INNER JOIN productos_maestros pm ON a.producto_maestro_id = pm.id
    WHERE a.colores_ids = p_colores_ids
      AND a.activo = true;

    RETURN json_build_object(
        'success', true,
        'data', COALESCE(v_result, '[]'::json),
        'message', 'Artículos con combinación exacta encontrados'
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

COMMENT ON FUNCTION filtrar_productos_por_combinacion IS 'E002-HU-005: Filtra artículos por combinación exacta de colores UUID - migrado a articulos';

-- ============================================
-- PASO 3: Eliminar tabla obsoleta producto_colores
-- ============================================

DROP TRIGGER IF EXISTS validate_producto_colores_trigger ON producto_colores;
DROP FUNCTION IF EXISTS validate_producto_colores();
DROP TABLE IF EXISTS producto_colores CASCADE;

COMMIT;

-- ============================================
-- RESUMEN DE MIGRACIÓN
-- ============================================
-- Funciones migradas (6):
--   1. listar_colores() - Cuenta artículos en lugar de producto_colores
--   2. editar_color(UUID, TEXT, TEXT[]) - Cuenta artículos afectados
--   3. eliminar_color(UUID) - Verifica uso en articulos
--   4. obtener_productos_por_color(UUID, BOOLEAN) - Parámetro cambiado de TEXT a UUID
--   5. estadisticas_colores() - Estadísticas basadas en articulos
--   6. filtrar_productos_por_combinacion(UUID[]) - Parámetro cambiado de TEXT[] a UUID[]
--
-- Cambios principales:
--   - producto_colores → articulos
--   - colores TEXT[] → colores_ids UUID[]
--   - Búsqueda por nombre → Búsqueda por UUID
--   - JOIN con productos → JOIN con productos_maestros
--
-- Tabla eliminada:
--   - producto_colores (ya no necesaria)
-- ============================================
