-- ============================================
-- Migration: 00000000000006_seed_data.sql
-- Descripción: Datos iniciales consolidados (marcas, materiales, tiendas, productos, clientes, usuarios, ventas)
-- Fecha: 2025-10-07 (Consolidado completo - Opción 2)
-- ============================================
--
-- CREDENCIALES DE ACCESO:
-- ADMIN:     admin@test.com    / asdasd211
-- GERENTE:   gerente@test.com  / asdasd211
-- VENDEDOR:  vendedor@test.com / asdasd211
-- ============================================

BEGIN;

-- ============================================
-- PASO 1: Marcas de ejemplo (E002-HU-001)
-- ============================================

INSERT INTO marcas (nombre, codigo, activo) VALUES
    ('Adidas', 'ADS', true),
    ('Nike', 'NIK', true),
    ('Puma', 'PUM', true),
    ('Umbro', 'UMB', true),
    ('Reebok', 'REE', true),
    ('New Balance', 'NBL', true)
ON CONFLICT (codigo) DO NOTHING;

-- ============================================
-- PASO 2: Materiales de ejemplo (E002-HU-002)
-- ============================================

INSERT INTO materiales (nombre, descripcion, codigo, activo) VALUES
    ('Algodón', 'Fibra natural transpirable', 'ALG', true),
    ('Nylon', 'Fibra sintética resistente', 'NYL', true),
    ('Bambú', 'Fibra ecológica antibacterial', 'BAM', true),
    ('Microfibra', 'Fibra sintética ultra suave', 'MIC', true),
    ('Lana Merino', 'Lana natural termorreguladora', 'MER', true),
    ('Poliéster', 'Fibra sintética duradera', 'POL', true),
    ('Lycra', 'Fibra elástica para ajuste', 'LYC', true),
    ('Seda', 'Fibra natural de lujo', 'SED', true)
ON CONFLICT (codigo) DO NOTHING;

-- ============================================
-- PASO 2B: Tipos de medias de ejemplo (E002-HU-003)
-- ============================================

INSERT INTO tipos (nombre, descripcion, codigo, activo) VALUES
    ('Invisible', 'Media muy baja, no visible con zapatos', 'INV', true),
    ('Tobillera', 'Media que llega al tobillo', 'TOB', true),
    ('Media Caña', 'Media que llega a media pantorrilla', 'MCA', true),
    ('Larga', 'Media que llega a la rodilla', 'LAR', true),
    ('Fútbol', 'Media deportiva alta para fútbol', 'FUT', true),
    ('Running', 'Media deportiva para correr', 'RUN', true),
    ('Compresión', 'Media con compresión gradual', 'COM', true),
    ('Ejecutiva', 'Media formal para uso ejecutivo', 'EJE', true),
    ('Térmica', 'Media para climas fríos', 'TER', true)
ON CONFLICT (codigo) DO NOTHING;

-- ============================================
-- PASO 2C: Sistemas de tallas de ejemplo (E002-HU-004)
-- ============================================

-- Sistema UNICA
INSERT INTO sistemas_talla (nombre, tipo_sistema, descripcion, activo) VALUES
    ('Talla Única Estándar', 'UNICA', 'Talla única que se adapta a pie 35-42', true)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO valores_talla (sistema_talla_id, valor, orden, activo)
SELECT id, 'ÚNICA', 1, true
FROM sistemas_talla
WHERE nombre = 'Talla Única Estándar'
ON CONFLICT (sistema_talla_id, valor) DO NOTHING;

-- Sistema NUMERO
INSERT INTO sistemas_talla (nombre, tipo_sistema, descripcion, activo) VALUES
    ('Tallas Numéricas Europeas', 'NUMERO', 'Sistema de tallas por números europeos', true)
ON CONFLICT (nombre) DO NOTHING;

DO $$
DECLARE
    v_sistema_id UUID;
    v_orden INTEGER := 0;
    v_valor TEXT;
BEGIN
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas Numéricas Europeas';

    IF v_sistema_id IS NOT NULL THEN
        FOR v_valor IN SELECT unnest(ARRAY['35-36', '37-38', '39-40', '41-42', '43-44'])
        LOOP
            v_orden := v_orden + 1;
            INSERT INTO valores_talla (sistema_talla_id, valor, orden, activo)
            VALUES (v_sistema_id, v_valor, v_orden, true)
            ON CONFLICT (sistema_talla_id, valor) DO NOTHING;
        END LOOP;
    END IF;
END $$;

-- Sistema LETRA
INSERT INTO sistemas_talla (nombre, tipo_sistema, descripcion, activo) VALUES
    ('Tallas por Letras Estándar', 'LETRA', 'Sistema de tallas alfabético', true)
ON CONFLICT (nombre) DO NOTHING;

DO $$
DECLARE
    v_sistema_id UUID;
    v_orden INTEGER := 0;
    v_valor TEXT;
BEGIN
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas por Letras Estándar';

    IF v_sistema_id IS NOT NULL THEN
        FOR v_valor IN SELECT unnest(ARRAY['XS', 'S', 'M', 'L', 'XL', 'XXL'])
        LOOP
            v_orden := v_orden + 1;
            INSERT INTO valores_talla (sistema_talla_id, valor, orden, activo)
            VALUES (v_sistema_id, v_valor, v_orden, true)
            ON CONFLICT (sistema_talla_id, valor) DO NOTHING;
        END LOOP;
    END IF;
END $$;

-- Sistema RANGO
INSERT INTO sistemas_talla (nombre, tipo_sistema, descripcion, activo) VALUES
    ('Rangos Amplios', 'RANGO', 'Rangos amplios para medias deportivas', true)
ON CONFLICT (nombre) DO NOTHING;

DO $$
DECLARE
    v_sistema_id UUID;
    v_orden INTEGER := 0;
    v_valor TEXT;
BEGIN
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Rangos Amplios';

    IF v_sistema_id IS NOT NULL THEN
        FOR v_valor IN SELECT unnest(ARRAY['34-38', '39-42', '43-46'])
        LOOP
            v_orden := v_orden + 1;
            INSERT INTO valores_talla (sistema_talla_id, valor, orden, activo)
            VALUES (v_sistema_id, v_valor, v_orden, true)
            ON CONFLICT (sistema_talla_id, valor) DO NOTHING;
        END LOOP;
    END IF;
END $$;

-- ============================================
-- PASO 2D: Colores de ejemplo (E002-HU-005)
-- ============================================

INSERT INTO colores (nombre, codigos_hex, tipo_color, activo) VALUES
    ('Rojo', ARRAY['#FF0000'], 'unico', true),
    ('Negro', ARRAY['#000000'], 'unico', true),
    ('Blanco', ARRAY['#FFFFFF'], 'unico', true),
    ('Azul', ARRAY['#0000FF'], 'unico', true),
    ('Verde', ARRAY['#008000'], 'unico', true),
    ('Amarillo', ARRAY['#FFFF00'], 'unico', true),
    ('Naranja', ARRAY['#FFA500'], 'unico', true),
    ('Rosa', ARRAY['#FFC0CB'], 'unico', true),
    ('Gris', ARRAY['#808080'], 'unico', true),
    ('Morado', ARRAY['#800080'], 'unico', true),
    ('Café', ARRAY['#8B4513'], 'unico', true),
    ('Azul Marino', ARRAY['#000080'], 'unico', true),
    ('Verde Oscuro', ARRAY['#006400'], 'unico', true),
    ('Rojo Oscuro', ARRAY['#8B0000'], 'unico', true),
    ('Gris Oscuro', ARRAY['#404040'], 'unico', true),
    ('Beige', ARRAY['#F5F5DC'], 'unico', true),
    ('Turquesa', ARRAY['#40E0D0'], 'unico', true),
    ('Fucsia', ARRAY['#FF00FF'], 'unico', true),
    ('Verde Lima', ARRAY['#00FF00'], 'unico', true),
    ('Azul Cielo', ARRAY['#87CEEB'], 'unico', true)
ON CONFLICT (nombre) DO NOTHING;

-- ============================================
-- PASO 2E: Productos Maestros de ejemplo (E002-HU-006)
-- ============================================

DO $$
DECLARE
    v_marca_id UUID;
    v_material_id UUID;
    v_tipo_id UUID;
    v_sistema_id UUID;
    v_productos_creados INTEGER := 0;
BEGIN
    -- Producto 1: Adidas + Algodón + Fútbol + Número
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'ADS' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'ALG' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'FUT' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas Numéricas Europeas' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Línea deportiva profesional', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 2: Nike + Microfibra + Running + Número
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'NIK' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'MIC' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'RUN' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas Numéricas Europeas' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Para corredores exigentes', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 3: Puma + Lycra + Compresión + Letra
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'PUM' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'LYC' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'COM' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas por Letras Estándar' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Máxima compresión deportiva', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 4: Umbro + Poliéster + Ejecutiva + Número
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'UMB' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'POL' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'EJE' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas Numéricas Europeas' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Comodidad ejecutiva premium', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 5: Reebok + Bambú + Invisible + Única
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'REE' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'BAM' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'INV' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Talla Única Estándar' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Tecnología antibacterial avanzada', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 6: New Balance + Nylon + Tobillera + Letra
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'NBL' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'NYL' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'TOB' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas por Letras Estándar' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Ajuste perfecto tobillo', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 7: Adidas + Lana Merino + Térmica + Letra
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'ADS' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'MER' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'TER' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas por Letras Estándar' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Protección térmica invierno', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 8: Nike + Seda + Ejecutiva + Número
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'NIK' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'SED' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'EJE' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas Numéricas Europeas' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Elegancia formal diaria', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 9: Puma + Algodón + Media Caña + Número
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'PUM' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'ALG' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'MCA' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas Numéricas Europeas' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Comodidad casual diaria', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 10: Umbro + Nylon + Fútbol + Número
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'UMB' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'NYL' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'FUT' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas Numéricas Europeas' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Resistencia extrema cancha', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 11: Reebok + Poliéster + Running + Número
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'REE' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'POL' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'RUN' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas Numéricas Europeas' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Velocidad y rendimiento', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 12: New Balance + Microfibra + Larga + Letra
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'NBL' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'MIC' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'LAR' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas por Letras Estándar' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Cobertura total pierna', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 13: Adidas + Bambú + Tobillera + Número
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'ADS' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'BAM' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'TOB' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas Numéricas Europeas' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Ecológico antibacterial', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 14: Nike + Lycra + Compresión + Letra
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'NIK' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'LYC' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'COM' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas por Letras Estándar' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Tecnología de compresión', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    -- Producto 15: Puma + Lana Merino + Térmica + Número
    SELECT id INTO v_marca_id FROM marcas WHERE codigo = 'PUM' LIMIT 1;
    SELECT id INTO v_material_id FROM materiales WHERE codigo = 'MER' LIMIT 1;
    SELECT id INTO v_tipo_id FROM tipos WHERE codigo = 'TER' LIMIT 1;
    SELECT id INTO v_sistema_id FROM sistemas_talla WHERE nombre = 'Tallas Numéricas Europeas' LIMIT 1;

    IF v_marca_id IS NOT NULL AND v_material_id IS NOT NULL AND v_tipo_id IS NOT NULL AND v_sistema_id IS NOT NULL THEN
        INSERT INTO productos_maestros (marca_id, material_id, tipo_id, sistema_talla_id, descripcion, activo)
        VALUES (v_marca_id, v_material_id, v_tipo_id, v_sistema_id, 'Calor natural regulado', true)
        ON CONFLICT (marca_id, material_id, tipo_id, sistema_talla_id) DO NOTHING;
        v_productos_creados := v_productos_creados + 1;
    END IF;

    RAISE NOTICE 'Productos maestros de ejemplo creados: %', v_productos_creados;
END $$;

-- ============================================
-- PASO 2F: Artículos Derivados de ejemplo (E002-HU-007)
-- ============================================

DO $$
DECLARE
    v_producto_maestro_id UUID;
    v_color_rojo_id UUID;
    v_color_negro_id UUID;
    v_color_blanco_id UUID;
    v_color_azul_id UUID;
    v_color_verde_id UUID;
    v_color_amarillo_id UUID;
    v_color_naranja_id UUID;
    v_color_rosa_id UUID;
    v_color_gris_id UUID;
    v_color_morado_id UUID;
    v_color_cafe_id UUID;
    v_color_azul_marino_id UUID;
    v_color_verde_oscuro_id UUID;
    v_color_rojo_oscuro_id UUID;
    v_color_gris_oscuro_id UUID;
    v_color_beige_id UUID;
    v_color_turquesa_id UUID;
    v_color_fucsia_id UUID;
    v_color_verde_lima_id UUID;
    v_color_azul_cielo_id UUID;
    v_articulos_creados INTEGER := 0;
BEGIN
    -- Obtener IDs de colores
    SELECT id INTO v_color_rojo_id FROM colores WHERE nombre = 'Rojo' LIMIT 1;
    SELECT id INTO v_color_negro_id FROM colores WHERE nombre = 'Negro' LIMIT 1;
    SELECT id INTO v_color_blanco_id FROM colores WHERE nombre = 'Blanco' LIMIT 1;
    SELECT id INTO v_color_azul_id FROM colores WHERE nombre = 'Azul' LIMIT 1;
    SELECT id INTO v_color_verde_id FROM colores WHERE nombre = 'Verde' LIMIT 1;
    SELECT id INTO v_color_amarillo_id FROM colores WHERE nombre = 'Amarillo' LIMIT 1;
    SELECT id INTO v_color_naranja_id FROM colores WHERE nombre = 'Naranja' LIMIT 1;
    SELECT id INTO v_color_rosa_id FROM colores WHERE nombre = 'Rosa' LIMIT 1;
    SELECT id INTO v_color_gris_id FROM colores WHERE nombre = 'Gris' LIMIT 1;
    SELECT id INTO v_color_morado_id FROM colores WHERE nombre = 'Morado' LIMIT 1;
    SELECT id INTO v_color_cafe_id FROM colores WHERE nombre = 'Café' LIMIT 1;
    SELECT id INTO v_color_azul_marino_id FROM colores WHERE nombre = 'Azul Marino' LIMIT 1;
    SELECT id INTO v_color_verde_oscuro_id FROM colores WHERE nombre = 'Verde Oscuro' LIMIT 1;
    SELECT id INTO v_color_rojo_oscuro_id FROM colores WHERE nombre = 'Rojo Oscuro' LIMIT 1;
    SELECT id INTO v_color_gris_oscuro_id FROM colores WHERE nombre = 'Gris Oscuro' LIMIT 1;
    SELECT id INTO v_color_beige_id FROM colores WHERE nombre = 'Beige' LIMIT 1;
    SELECT id INTO v_color_turquesa_id FROM colores WHERE nombre = 'Turquesa' LIMIT 1;
    SELECT id INTO v_color_fucsia_id FROM colores WHERE nombre = 'Fucsia' LIMIT 1;
    SELECT id INTO v_color_verde_lima_id FROM colores WHERE nombre = 'Verde Lima' LIMIT 1;
    SELECT id INTO v_color_azul_cielo_id FROM colores WHERE nombre = 'Azul Cielo' LIMIT 1;

    -- ============================================
    -- ARTÍCULOS UNICOLOR (21 artículos - 60%)
    -- ============================================

    -- Producto 1: Adidas-Algodón-Fútbol (3 variantes)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'ADS' AND ma.codigo = 'ALG' AND t.codigo = 'FUT'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'ADS-ALG-FUT-NEG', 'unicolor', ARRAY[v_color_negro_id], 16.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    IF v_producto_maestro_id IS NOT NULL AND v_color_blanco_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'ADS-ALG-FUT-BLA', 'unicolor', ARRAY[v_color_blanco_id], 16.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    IF v_producto_maestro_id IS NOT NULL AND v_color_rojo_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'ADS-ALG-FUT-ROJ', 'unicolor', ARRAY[v_color_rojo_id], 16.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 2: Nike-Microfibra-Running (3 variantes)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'NIK' AND ma.codigo = 'MIC' AND t.codigo = 'RUN'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NIK-MIC-RUN-NEG', 'unicolor', ARRAY[v_color_negro_id], 22.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    IF v_producto_maestro_id IS NOT NULL AND v_color_azul_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NIK-MIC-RUN-AZU', 'unicolor', ARRAY[v_color_azul_id], 22.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    IF v_producto_maestro_id IS NOT NULL AND v_color_verde_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NIK-MIC-RUN-VER', 'unicolor', ARRAY[v_color_verde_id], 22.99, false)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 3: Puma-Lycra-Compresión (2 variantes)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'PUM' AND ma.codigo = 'LYC' AND t.codigo = 'COM'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'PUM-LYC-COM-NEG', 'unicolor', ARRAY[v_color_negro_id], 24.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    IF v_producto_maestro_id IS NOT NULL AND v_color_gris_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'PUM-LYC-COM-GRI', 'unicolor', ARRAY[v_color_gris_id], 24.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 4: Umbro-Poliéster-Ejecutiva (2 variantes)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'UMB' AND ma.codigo = 'POL' AND t.codigo = 'EJE'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_azul_marino_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'UMB-POL-EJE-AZM', 'unicolor', ARRAY[v_color_azul_marino_id], 14.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    IF v_producto_maestro_id IS NOT NULL AND v_color_gris_oscuro_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'UMB-POL-EJE-GRO', 'unicolor', ARRAY[v_color_gris_oscuro_id], 14.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 5: Reebok-Bambú-Invisible (2 variantes)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'REE' AND ma.codigo = 'BAM' AND t.codigo = 'INV'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_beige_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'REE-BAM-INV-BEI', 'unicolor', ARRAY[v_color_beige_id], 13.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    IF v_producto_maestro_id IS NOT NULL AND v_color_blanco_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'REE-BAM-INV-BLA', 'unicolor', ARRAY[v_color_blanco_id], 13.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 6: New Balance-Nylon-Tobillera (2 variantes)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'NBL' AND ma.codigo = 'NYL' AND t.codigo = 'TOB'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_gris_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NBL-NYL-TOB-GRI', 'unicolor', ARRAY[v_color_gris_id], 15.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NBL-NYL-TOB-NEG', 'unicolor', ARRAY[v_color_negro_id], 15.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 7: Adidas-Lana Merino-Térmica (1 variante)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'ADS' AND ma.codigo = 'MER' AND t.codigo = 'TER'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_gris_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'ADS-MER-TER-GRI', 'unicolor', ARRAY[v_color_gris_id], 27.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 8: Nike-Seda-Ejecutiva (1 variante)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'NIK' AND ma.codigo = 'SED' AND t.codigo = 'EJE'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NIK-SED-EJE-NEG', 'unicolor', ARRAY[v_color_negro_id], 32.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 9: Puma-Algodón-Media Caña (1 variante)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'PUM' AND ma.codigo = 'ALG' AND t.codigo = 'MCA'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_blanco_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'PUM-ALG-MCA-BLA', 'unicolor', ARRAY[v_color_blanco_id], 12.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 10: Umbro-Nylon-Fútbol (1 variante)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'UMB' AND ma.codigo = 'NYL' AND t.codigo = 'FUT'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_verde_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'UMB-NYL-FUT-VER', 'unicolor', ARRAY[v_color_verde_id], 14.99, false)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 11: Reebok-Poliéster-Running (1 variante)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'REE' AND ma.codigo = 'POL' AND t.codigo = 'RUN'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_naranja_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'REE-POL-RUN-NAR', 'unicolor', ARRAY[v_color_naranja_id], 18.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 12: New Balance-Microfibra-Larga (1 variante)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'NBL' AND ma.codigo = 'MIC' AND t.codigo = 'LAR'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_azul_marino_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NBL-MIC-LAR-AZM', 'unicolor', ARRAY[v_color_azul_marino_id], 19.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Producto 13: Adidas-Bambú-Tobillera (1 variante)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'ADS' AND ma.codigo = 'BAM' AND t.codigo = 'TOB'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_turquesa_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'ADS-BAM-TOB-TUR', 'unicolor', ARRAY[v_color_turquesa_id], 17.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- ============================================
    -- ARTÍCULOS BICOLOR (11 artículos - 31%)
    -- ============================================

    -- Bicolor 1: Adidas-Algodón-Fútbol Negro-Blanco
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'ADS' AND ma.codigo = 'ALG' AND t.codigo = 'FUT'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL AND v_color_blanco_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'ADS-ALG-FUT-NEG-BLA', 'bicolor', ARRAY[v_color_negro_id, v_color_blanco_id], 20.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Bicolor 2: Nike-Microfibra-Running Rojo-Negro
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'NIK' AND ma.codigo = 'MIC' AND t.codigo = 'RUN'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_rojo_id IS NOT NULL AND v_color_negro_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NIK-MIC-RUN-ROJ-NEG', 'bicolor', ARRAY[v_color_rojo_id, v_color_negro_id], 26.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Bicolor 3: Puma-Lycra-Compresión Negro-Verde
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'PUM' AND ma.codigo = 'LYC' AND t.codigo = 'COM'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL AND v_color_verde_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'PUM-LYC-COM-NEG-VER', 'bicolor', ARRAY[v_color_negro_id, v_color_verde_id], 28.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Bicolor 4: Nike-Lycra-Compresión Azul-Blanco
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'NIK' AND ma.codigo = 'LYC' AND t.codigo = 'COM'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_azul_id IS NOT NULL AND v_color_blanco_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NIK-LYC-COM-AZU-BLA', 'bicolor', ARRAY[v_color_azul_id, v_color_blanco_id], 27.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Bicolor 5: Umbro-Nylon-Fútbol Negro-Rojo
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'UMB' AND ma.codigo = 'NYL' AND t.codigo = 'FUT'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL AND v_color_rojo_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'UMB-NYL-FUT-NEG-ROJ', 'bicolor', ARRAY[v_color_negro_id, v_color_rojo_id], 18.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Bicolor 6: Reebok-Poliéster-Running Gris-Naranja
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'REE' AND ma.codigo = 'POL' AND t.codigo = 'RUN'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_gris_id IS NOT NULL AND v_color_naranja_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'REE-POL-RUN-GRI-NAR', 'bicolor', ARRAY[v_color_gris_id, v_color_naranja_id], 22.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Bicolor 7: Puma-Algodón-Media Caña Negro-Amarillo
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'PUM' AND ma.codigo = 'ALG' AND t.codigo = 'MCA'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL AND v_color_amarillo_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'PUM-ALG-MCA-NEG-AMA', 'bicolor', ARRAY[v_color_negro_id, v_color_amarillo_id], 16.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Bicolor 8: New Balance-Nylon-Tobillera Gris-Azul
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'NBL' AND ma.codigo = 'NYL' AND t.codigo = 'TOB'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_gris_id IS NOT NULL AND v_color_azul_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NBL-NYL-TOB-GRI-AZU', 'bicolor', ARRAY[v_color_gris_id, v_color_azul_id], 19.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Bicolor 9: Adidas-Bambú-Tobillera Blanco-Verde (inactivo)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'ADS' AND ma.codigo = 'BAM' AND t.codigo = 'TOB'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_blanco_id IS NOT NULL AND v_color_verde_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'ADS-BAM-TOB-BLA-VER', 'bicolor', ARRAY[v_color_blanco_id, v_color_verde_id], 21.99, false)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Bicolor 10: Nike-Seda-Ejecutiva Negro-Gris
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'NIK' AND ma.codigo = 'SED' AND t.codigo = 'EJE'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL AND v_color_gris_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NIK-SED-EJE-NEG-GRI', 'bicolor', ARRAY[v_color_negro_id, v_color_gris_id], 36.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Bicolor 11: Adidas-Lana Merino-Térmica Gris-Azul Marino
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'ADS' AND ma.codigo = 'MER' AND t.codigo = 'TER'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_gris_id IS NOT NULL AND v_color_azul_marino_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'ADS-MER-TER-GRI-AZM', 'bicolor', ARRAY[v_color_gris_id, v_color_azul_marino_id], 31.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- ============================================
    -- ARTÍCULOS TRICOLOR (3 artículos - 9%)
    -- ============================================

    -- Tricolor 1: Nike-Microfibra-Running Rojo-Blanco-Azul
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'NIK' AND ma.codigo = 'MIC' AND t.codigo = 'RUN'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_rojo_id IS NOT NULL
       AND v_color_blanco_id IS NOT NULL AND v_color_azul_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'NIK-MIC-RUN-ROJ-BLA-AZU', 'tricolor',
                ARRAY[v_color_rojo_id, v_color_blanco_id, v_color_azul_id], 29.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Tricolor 2: Puma-Lycra-Compresión Negro-Verde-Amarillo
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'PUM' AND ma.codigo = 'LYC' AND t.codigo = 'COM'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL
       AND v_color_verde_id IS NOT NULL AND v_color_amarillo_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'PUM-LYC-COM-NEG-VER-AMA', 'tricolor',
                ARRAY[v_color_negro_id, v_color_verde_id, v_color_amarillo_id], 32.99, true)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    -- Tricolor 3: Adidas-Algodón-Fútbol Negro-Blanco-Rojo (inactivo)
    SELECT pm.id INTO v_producto_maestro_id FROM productos_maestros pm
    JOIN marcas m ON pm.marca_id = m.id
    JOIN materiales ma ON pm.material_id = ma.id
    JOIN tipos t ON pm.tipo_id = t.id
    WHERE m.codigo = 'ADS' AND ma.codigo = 'ALG' AND t.codigo = 'FUT'
    LIMIT 1;

    IF v_producto_maestro_id IS NOT NULL AND v_color_negro_id IS NOT NULL
       AND v_color_blanco_id IS NOT NULL AND v_color_rojo_id IS NOT NULL THEN
        INSERT INTO articulos (producto_maestro_id, sku, tipo_coloracion, colores_ids, precio, activo)
        VALUES (v_producto_maestro_id, 'ADS-ALG-FUT-NEG-BLA-ROJ', 'tricolor',
                ARRAY[v_color_negro_id, v_color_blanco_id, v_color_rojo_id], 25.99, false)
        ON CONFLICT (sku) DO NOTHING;
        v_articulos_creados := v_articulos_creados + 1;
    END IF;

    RAISE NOTICE 'Artículos derivados de ejemplo creados: %', v_articulos_creados;
END $$;

-- ============================================
-- PASO 3: Tiendas de ejemplo
-- ============================================

INSERT INTO tiendas (id, nombre, direccion, meta_mensual, activa) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Tienda Centro', 'Av. Principal 123', 50000.00, true),
    ('22222222-2222-2222-2222-222222222222', 'Tienda Norte', 'Calle Comercio 456', 40000.00, true),
    ('33333333-3333-3333-3333-333333333333', 'Tienda Sur', 'Blvd. Sur 789', 35000.00, true)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- PASO 4: Productos de ejemplo (30 productos con stock variado)
-- ============================================

INSERT INTO productos (nombre, descripcion, precio, stock_actual, stock_maximo, activo) VALUES
    -- Stock normal
    ('Medias Deportivas Negras', 'Medias deportivas de algodón', 15.99, 50, 100, true),
    ('Medias Ejecutivas Grises', 'Medias formales para oficina', 12.50, 80, 100, true),
    ('Medias Casuales Blancas', 'Medias casuales de uso diario', 10.00, 60, 100, true),
    ('Medias Térmicas Azules', 'Medias térmicas para invierno', 18.99, 45, 100, true),
    ('Medias Running Rojas', 'Medias especiales para running', 20.00, 35, 100, true),
    ('Medias Bambú Verdes', 'Medias ecológicas de bambú', 22.00, 40, 100, true),
    ('Medias Compresión Negras', 'Medias de compresión deportiva', 25.00, 30, 100, true),
    ('Medias Invisibles Beige', 'Medias invisibles para zapatos', 8.50, 70, 100, true),
    ('Medias Largas Grises', 'Medias largas hasta rodilla', 16.00, 55, 100, true),
    ('Medias Cortas Blancas', 'Medias cortas deportivas', 9.99, 65, 100, true),
    -- Stock bajo (< 20% = < 20 unidades)
    ('Medias Algodón Azules', 'Medias de algodón puro', 14.00, 18, 100, true),
    ('Medias Lana Grises', 'Medias de lana para invierno', 19.00, 15, 100, true),
    ('Medias Seda Negras', 'Medias de seda premium', 30.00, 12, 100, true),
    ('Medias Antiolor Blancas', 'Medias con tecnología antiolor', 17.00, 10, 100, true),
    ('Medias Reforzadas Grises', 'Medias con talón reforzado', 16.50, 8, 100, true),
    -- Stock crítico (< 5 unidades)
    ('Medias Coolmax Azules', 'Medias con tecnología Coolmax', 23.00, 4, 100, true),
    ('Medias Merino Rojas', 'Medias de lana merino', 28.00, 3, 100, true),
    ('Medias Premium Negras', 'Medias premium importadas', 35.00, 2, 100, true),
    ('Medias Antibacterial Verde', 'Medias antibacteriales', 21.00, 1, 100, true),
    -- Productos adicionales con stock normal
    ('Medias Rayas Multicolor', 'Medias con diseño de rayas', 11.00, 50, 100, true),
    ('Medias Lunares Rojas', 'Medias con lunares', 12.00, 45, 100, true),
    ('Medias Lisa Beige', 'Medias lisas color beige', 10.50, 55, 100, true),
    ('Medias Deporte Pro Negras', 'Medias profesionales deporte', 24.00, 40, 100, true),
    ('Medias Casual Premium Grises', 'Medias casuales premium', 18.00, 35, 100, true),
    ('Medias Ejecutivo Azul', 'Medias ejecutivas azul marino', 15.00, 48, 100, true),
    ('Medias Comfort Blancas', 'Medias extra comfort', 13.50, 52, 100, true),
    ('Medias Running Pro Rojas', 'Medias running profesionales', 26.00, 28, 100, true),
    ('Medias Trekking Verdes', 'Medias para trekking', 22.50, 25, 100, true),
    ('Medias Ciclismo Negras', 'Medias especiales ciclismo', 27.00, 20, 100, true),
    ('Medias Yoga Multicolor', 'Medias para yoga y pilates', 16.50, 42, 100, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- PASO 5: Clientes de ejemplo (50 clientes)
-- ============================================

INSERT INTO clientes (nombre_completo, email, telefono, activo) VALUES
    ('Carlos Ramírez', 'carlos.ramirez@example.com', '555-0101', true),
    ('Ana López', 'ana.lopez@example.com', '555-0102', true),
    ('Miguel González', 'miguel.gonzalez@example.com', '555-0103', true),
    ('Laura Martínez', 'laura.martinez@example.com', '555-0104', true),
    ('Pedro Sánchez', 'pedro.sanchez@example.com', '555-0105', true),
    ('María Rodríguez', 'maria.rodriguez@example.com', '555-0106', true),
    ('Juan Pérez', 'juan.perez@example.com', '555-0107', true),
    ('Carmen Fernández', 'carmen.fernandez@example.com', '555-0108', true),
    ('Roberto Díaz', 'roberto.diaz@example.com', '555-0109', true),
    ('Isabel Torres', 'isabel.torres@example.com', '555-0110', true),
    ('Francisco Ruiz', 'francisco.ruiz@example.com', '555-0111', true),
    ('Sofía Moreno', 'sofia.moreno@example.com', '555-0112', true),
    ('Antonio Jiménez', 'antonio.jimenez@example.com', '555-0113', true),
    ('Elena Álvarez', 'elena.alvarez@example.com', '555-0114', true),
    ('Jorge Romero', 'jorge.romero@example.com', '555-0115', true),
    ('Patricia Navarro', 'patricia.navarro@example.com', '555-0116', true),
    ('Luis Herrera', 'luis.herrera@example.com', '555-0117', true),
    ('Marta Castro', 'marta.castro@example.com', '555-0118', true),
    ('Daniel Vargas', 'daniel.vargas@example.com', '555-0119', true),
    ('Cristina Ortiz', 'cristina.ortiz@example.com', '555-0120', true),
    ('Javier Ramírez', 'javier.ramirez@example.com', '555-0121', true),
    ('Andrea Morales', 'andrea.morales@example.com', '555-0122', true),
    ('Fernando Gil', 'fernando.gil@example.com', '555-0123', true),
    ('Beatriz Mendoza', 'beatriz.mendoza@example.com', '555-0124', true),
    ('Manuel Silva', 'manuel.silva@example.com', '555-0125', true),
    ('Rosa Guerrero', 'rosa.guerrero@example.com', '555-0126', true),
    ('Alberto Santos', 'alberto.santos@example.com', '555-0127', true),
    ('Lucía Vega', 'lucia.vega@example.com', '555-0128', true),
    ('Raúl Medina', 'raul.medina@example.com', '555-0129', true),
    ('Teresa Cruz', 'teresa.cruz@example.com', '555-0130', true),
    ('Sergio Ramos', 'sergio.ramos@example.com', '555-0131', true),
    ('Pilar Ibáñez', 'pilar.ibanez@example.com', '555-0132', true),
    ('Enrique Peña', 'enrique.pena@example.com', '555-0133', true),
    ('Silvia Cortés', 'silvia.cortes@example.com', '555-0134', true),
    ('Óscar Delgado', 'oscar.delgado@example.com', '555-0135', true),
    ('Natalia Campos', 'natalia.campos@example.com', '555-0136', true),
    ('Ricardo Ortega', 'ricardo.ortega@example.com', '555-0137', true),
    ('Mónica Suárez', 'monica.suarez@example.com', '555-0138', true),
    ('Pablo Márquez', 'pablo.marquez@example.com', '555-0139', true),
    ('Verónica Rojas', 'veronica.rojas@example.com', '555-0140', true),
    ('Andrés Molina', 'andres.molina@example.com', '555-0141', true),
    ('Irene Castro', 'irene.castro@example.com', '555-0142', true),
    ('David Flores', 'david.flores@example.com', '555-0143', true),
    ('Alicia Prieto', 'alicia.prieto@example.com', '555-0144', true),
    ('Raquel Garrido', 'raquel.garrido@example.com', '555-0145', true),
    ('Víctor Pascual', 'victor.pascual@example.com', '555-0146', true),
    ('Sandra León', 'sandra.leon@example.com', '555-0147', true),
    ('Hugo Serrano', 'hugo.serrano@example.com', '555-0148', true),
    ('Eva Blanco', 'eva.blanco@example.com', '555-0149', true),
    ('Iván Rubio', 'ivan.rubio@example.com', '555-0150', true)
ON CONFLICT DO NOTHING;

COMMIT;

-- ============================================
-- PASO 6: Usuarios de Autenticación (auth.users)
-- ============================================
-- NOTA: Se crea fuera de la transacción anterior porque manipula auth.users

DO $$
DECLARE
    v_admin_id UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    v_gerente_id UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
    v_vendedor_id UUID := 'cccccccc-cccc-cccc-cccc-cccccccccccc';
    v_encrypted_pass TEXT;
BEGIN
    -- Generar contraseña encriptada para 'asdasd211'
    v_encrypted_pass := crypt('asdasd211', gen_salt('bf'));

    -- Usuario ADMIN
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = v_admin_id) THEN
        INSERT INTO auth.users (
            id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
            confirmation_token, recovery_token, email_change_token_new, email_change_token_current,
            email_change, phone_change, phone_change_token, reauthentication_token,
            raw_user_meta_data, raw_app_meta_data, created_at, updated_at
        ) VALUES (
            v_admin_id,
            '00000000-0000-0000-0000-000000000000',
            'authenticated', 'authenticated',
            'admin@test.com',
            v_encrypted_pass,
            NOW(),
            '', '', '', '',
            '', '', '', '',
            jsonb_build_object('rol', 'ADMIN', 'nombre_completo', 'Administrador Principal', 'email', 'admin@test.com'),
            jsonb_build_object('provider', 'email', 'providers', ARRAY['email']),
            NOW(), NOW()
        );
        RAISE NOTICE 'Usuario ADMIN creado: admin@test.com';
    END IF;

    -- Usuario GERENTE
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = v_gerente_id) THEN
        INSERT INTO auth.users (
            id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
            confirmation_token, recovery_token, email_change_token_new, email_change_token_current,
            email_change, phone_change, phone_change_token, reauthentication_token,
            raw_user_meta_data, raw_app_meta_data, created_at, updated_at
        ) VALUES (
            v_gerente_id,
            '00000000-0000-0000-0000-000000000000',
            'authenticated', 'authenticated',
            'gerente@test.com',
            v_encrypted_pass,
            NOW(),
            '', '', '', '',
            '', '', '', '',
            jsonb_build_object('rol', 'GERENTE', 'nombre_completo', 'Gerente Tienda Centro', 'email', 'gerente@test.com', 'tienda_id', '11111111-1111-1111-1111-111111111111'),
            jsonb_build_object('provider', 'email', 'providers', ARRAY['email']),
            NOW(), NOW()
        );
        RAISE NOTICE 'Usuario GERENTE creado: gerente@test.com';
    END IF;

    -- Usuario VENDEDOR
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = v_vendedor_id) THEN
        INSERT INTO auth.users (
            id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
            confirmation_token, recovery_token, email_change_token_new, email_change_token_current,
            email_change, phone_change, phone_change_token, reauthentication_token,
            raw_user_meta_data, raw_app_meta_data, created_at, updated_at
        ) VALUES (
            v_vendedor_id,
            '00000000-0000-0000-0000-000000000000',
            'authenticated', 'authenticated',
            'vendedor@test.com',
            v_encrypted_pass,
            NOW(),
            '', '', '', '',
            '', '', '', '',
            jsonb_build_object('rol', 'VENDEDOR', 'nombre_completo', 'Vendedor Tienda Centro', 'email', 'vendedor@test.com', 'tienda_id', '11111111-1111-1111-1111-111111111111'),
            jsonb_build_object('provider', 'email', 'providers', ARRAY['email']),
            NOW(), NOW()
        );
        RAISE NOTICE 'Usuario VENDEDOR creado: vendedor@test.com';
    END IF;

    -- Identities para login
    IF NOT EXISTS (SELECT 1 FROM auth.identities WHERE provider_id = v_admin_id::text) THEN
        INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
        VALUES (v_admin_id::text, v_admin_id, jsonb_build_object('sub', v_admin_id::text, 'email', 'admin@test.com', 'email_verified', true, 'phone_verified', false), 'email', NOW(), NOW(), NOW());
    END IF;

    IF NOT EXISTS (SELECT 1 FROM auth.identities WHERE provider_id = v_gerente_id::text) THEN
        INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
        VALUES (v_gerente_id::text, v_gerente_id, jsonb_build_object('sub', v_gerente_id::text, 'email', 'gerente@test.com', 'email_verified', true, 'phone_verified', false), 'email', NOW(), NOW(), NOW());
    END IF;

    IF NOT EXISTS (SELECT 1 FROM auth.identities WHERE provider_id = v_vendedor_id::text) THEN
        INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
        VALUES (v_vendedor_id::text, v_vendedor_id, jsonb_build_object('sub', v_vendedor_id::text, 'email', 'vendedor@test.com', 'email_verified', true, 'phone_verified', false), 'email', NOW(), NOW(), NOW());
    END IF;

    RAISE NOTICE 'Usuarios de autenticación creados exitosamente';
END $$;

-- ============================================
-- PASO 7: Asignaciones user-tiendas
-- ============================================

BEGIN;

INSERT INTO user_tiendas (user_id, tienda_id, activo) VALUES
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', true),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', true)
ON CONFLICT (user_id, tienda_id) DO NOTHING;

COMMIT;

-- ============================================
-- PASO 7.5: CORREGIR ROLES DE USUARIOS (FIX)
-- ============================================
-- Este script fuerza la actualización de roles para usuarios existentes

DO $$
BEGIN
    -- Actualizar rol de admin si existe
    UPDATE auth.users
    SET raw_user_meta_data = jsonb_set(
        COALESCE(raw_user_meta_data, '{}'::jsonb),
        '{rol}',
        '"ADMIN"'::jsonb
    )
    WHERE email = 'admin@test.com'
      AND (raw_user_meta_data->>'rol' IS NULL OR raw_user_meta_data->>'rol' != 'ADMIN');

    -- Actualizar rol de gerente si existe
    UPDATE auth.users
    SET raw_user_meta_data = jsonb_set(
        COALESCE(raw_user_meta_data, '{}'::jsonb),
        '{rol}',
        '"GERENTE"'::jsonb
    )
    WHERE email = 'gerente@test.com'
      AND (raw_user_meta_data->>'rol' IS NULL OR raw_user_meta_data->>'rol' != 'GERENTE');

    -- Actualizar rol de vendedor si existe
    UPDATE auth.users
    SET raw_user_meta_data = jsonb_set(
        COALESCE(raw_user_meta_data, '{}'::jsonb),
        '{rol}',
        '"VENDEDOR"'::jsonb
    )
    WHERE email = 'vendedor@test.com'
      AND (raw_user_meta_data->>'rol' IS NULL OR raw_user_meta_data->>'rol' != 'VENDEDOR');

    RAISE NOTICE 'Roles de usuarios actualizados correctamente';
END $$;

-- ============================================
-- PASO 8: Resumen de Seed
-- ============================================

DO $$
DECLARE
    v_marcas INTEGER;
    v_materiales INTEGER;
    v_tipos INTEGER;
    v_sistemas_talla INTEGER;
    v_valores_talla INTEGER;
    v_colores INTEGER;
    v_productos_maestros INTEGER;
    v_articulos INTEGER;
    v_articulos_unicolor INTEGER;
    v_articulos_bicolor INTEGER;
    v_articulos_tricolor INTEGER;
    v_tiendas INTEGER;
    v_productos INTEGER;
    v_clientes INTEGER;
    v_usuarios INTEGER;
    v_asignaciones INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_marcas FROM marcas;
    SELECT COUNT(*) INTO v_materiales FROM materiales;
    SELECT COUNT(*) INTO v_tipos FROM tipos;
    SELECT COUNT(*) INTO v_sistemas_talla FROM sistemas_talla;
    SELECT COUNT(*) INTO v_valores_talla FROM valores_talla;
    SELECT COUNT(*) INTO v_colores FROM colores;
    SELECT COUNT(*) INTO v_productos_maestros FROM productos_maestros;
    SELECT COUNT(*) INTO v_articulos FROM articulos;
    SELECT COUNT(*) INTO v_articulos_unicolor FROM articulos WHERE tipo_coloracion = 'unicolor';
    SELECT COUNT(*) INTO v_articulos_bicolor FROM articulos WHERE tipo_coloracion = 'bicolor';
    SELECT COUNT(*) INTO v_articulos_tricolor FROM articulos WHERE tipo_coloracion = 'tricolor';
    SELECT COUNT(*) INTO v_tiendas FROM tiendas;
    SELECT COUNT(*) INTO v_productos FROM productos;
    SELECT COUNT(*) INTO v_clientes FROM clientes;
    SELECT COUNT(*) INTO v_usuarios FROM auth.users WHERE email LIKE '%@test.com';
    SELECT COUNT(*) INTO v_asignaciones FROM user_tiendas;

    RAISE NOTICE '========================================';
    RAISE NOTICE 'SEED DATA MIGRATION COMPLETADA';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Marcas: %', v_marcas;
    RAISE NOTICE 'Materiales: %', v_materiales;
    RAISE NOTICE 'Tipos: %', v_tipos;
    RAISE NOTICE 'Sistemas de tallas: %', v_sistemas_talla;
    RAISE NOTICE 'Valores de tallas: %', v_valores_talla;
    RAISE NOTICE 'Colores: %', v_colores;
    RAISE NOTICE 'Productos maestros: %', v_productos_maestros;
    RAISE NOTICE 'Artículos derivados: % (Unicolor: %, Bicolor: %, Tricolor: %)', v_articulos, v_articulos_unicolor, v_articulos_bicolor, v_articulos_tricolor;
    RAISE NOTICE 'Tiendas: %', v_tiendas;
    RAISE NOTICE 'Productos: %', v_productos;
    RAISE NOTICE 'Clientes: %', v_clientes;
    RAISE NOTICE 'Usuarios de prueba: %', v_usuarios;
    RAISE NOTICE 'Asignaciones user-tienda: %', v_asignaciones;
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CREDENCIALES:';
    RAISE NOTICE 'admin@test.com / asdasd211';
    RAISE NOTICE 'gerente@test.com / asdasd211';
    RAISE NOTICE 'vendedor@test.com / asdasd211';
    RAISE NOTICE '========================================';
END $$;
