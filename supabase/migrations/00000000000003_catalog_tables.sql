-- ============================================
-- Migration: 00000000000003_catalog_tables.sql
-- Descripción: Catálogos del sistema (marcas, colores, tallas, tiendas, productos, clientes)
-- Fecha: 2025-10-07 (Consolidado)
-- ============================================

BEGIN;

-- ============================================
-- PASO 1: Tabla marcas (E002-HU-001)
-- ============================================

CREATE TABLE marcas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    codigo TEXT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT marcas_nombre_unique UNIQUE (nombre),
    CONSTRAINT marcas_codigo_unique UNIQUE (codigo),
    CONSTRAINT marcas_codigo_length CHECK (LENGTH(codigo) = 3),
    CONSTRAINT marcas_codigo_uppercase CHECK (codigo = UPPER(codigo)),
    CONSTRAINT marcas_codigo_only_letters CHECK (codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT marcas_nombre_length CHECK (LENGTH(nombre) <= 50 AND LENGTH(nombre) > 0)
);

CREATE INDEX idx_marcas_nombre ON marcas(LOWER(nombre));
CREATE INDEX idx_marcas_codigo ON marcas(codigo);
CREATE INDEX idx_marcas_activo ON marcas(activo);
CREATE INDEX idx_marcas_created_at ON marcas(created_at DESC);

CREATE TRIGGER update_marcas_updated_at
    BEFORE UPDATE ON marcas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE marcas IS 'E002-HU-001: Catálogo de marcas con códigos únicos de 3 letras';
COMMENT ON COLUMN marcas.nombre IS 'Nombre de la marca (único, case-insensitive, max 50 caracteres) - RN-001';
COMMENT ON COLUMN marcas.codigo IS 'Código de 3 letras mayúsculas (único, inmutable) - RN-002';

-- ============================================
-- PASO 2: Tabla tiendas (E003-HU-001)
-- ============================================

CREATE TABLE tiendas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    direccion TEXT,
    meta_mensual DECIMAL(12, 2) DEFAULT 0,
    activa BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_tiendas_activa ON tiendas(activa);

CREATE TRIGGER update_tiendas_updated_at
    BEFORE UPDATE ON tiendas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE tiendas IS 'E003-HU-001: Tiendas/sucursales del sistema';
COMMENT ON COLUMN tiendas.meta_mensual IS 'Meta de ventas mensuales en $$ - RN-007';

-- ============================================
-- PASO 3: Tabla productos (E003-HU-001)
-- ============================================

CREATE TABLE productos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    stock_actual INTEGER DEFAULT 0,
    stock_maximo INTEGER DEFAULT 100,
    activo BOOLEAN DEFAULT true,
    descontinuado BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_productos_activo ON productos(activo);
CREATE INDEX idx_productos_stock ON productos(stock_actual);

CREATE TRIGGER update_productos_updated_at
    BEFORE UPDATE ON productos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE productos IS 'E003-HU-001: Catálogo de productos (medias)';
COMMENT ON COLUMN productos.stock_maximo IS 'Stock máximo para calcular umbral bajo - RN-003';

-- ============================================
-- PASO 4: Tabla clientes (E003-HU-001)
-- ============================================

CREATE TABLE clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre_completo TEXT NOT NULL,
    email TEXT,
    telefono TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_clientes_email ON clientes(LOWER(email));
CREATE INDEX idx_clientes_activo ON clientes(activo);

CREATE TRIGGER update_clientes_updated_at
    BEFORE UPDATE ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE clientes IS 'E003-HU-001: Base de datos de clientes';

-- ============================================
-- PASO 5: Tabla user_tiendas (E003-HU-001)
-- ============================================

CREATE TABLE user_tiendas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tienda_id UUID NOT NULL REFERENCES tiendas(id) ON DELETE CASCADE,
    asignado_desde TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    activo BOOLEAN DEFAULT true,
    UNIQUE(user_id, tienda_id)
);

CREATE INDEX idx_user_tiendas_user ON user_tiendas(user_id, activo);
CREATE INDEX idx_user_tiendas_tienda ON user_tiendas(tienda_id, activo);

COMMENT ON TABLE user_tiendas IS 'E003-HU-001: Asignación de usuarios a tiendas';

-- ============================================
-- PASO 6: Tabla materiales (E002-HU-002)
-- ============================================

CREATE TABLE materiales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    codigo TEXT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT materiales_nombre_unique UNIQUE (nombre),
    CONSTRAINT materiales_codigo_unique UNIQUE (codigo),
    CONSTRAINT materiales_codigo_length CHECK (LENGTH(codigo) = 3),
    CONSTRAINT materiales_codigo_uppercase CHECK (codigo = UPPER(codigo)),
    CONSTRAINT materiales_codigo_only_letters CHECK (codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT materiales_nombre_length CHECK (LENGTH(nombre) <= 50 AND LENGTH(nombre) > 0),
    CONSTRAINT materiales_descripcion_length CHECK (descripcion IS NULL OR LENGTH(descripcion) <= 200)
);

CREATE INDEX idx_materiales_nombre ON materiales(LOWER(nombre));
CREATE INDEX idx_materiales_codigo ON materiales(codigo);
CREATE INDEX idx_materiales_activo ON materiales(activo);
CREATE INDEX idx_materiales_created_at ON materiales(created_at DESC);

CREATE TRIGGER update_materiales_updated_at
    BEFORE UPDATE ON materiales
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE materiales IS 'E002-HU-002: Catálogo de materiales con códigos únicos de 3 letras y descripción opcional';
COMMENT ON COLUMN materiales.nombre IS 'Nombre del material (único, case-insensitive, max 50 caracteres) - RN-002-002';
COMMENT ON COLUMN materiales.codigo IS 'Código de 3 letras mayúsculas (único, inmutable) - RN-002-001';
COMMENT ON COLUMN materiales.descripcion IS 'Descripción opcional del material (max 200 caracteres) - RN-002-003';
COMMENT ON COLUMN materiales.activo IS 'Estado del material (soft delete) - RN-002-005';

-- ============================================
-- PASO 7: Tabla tipos (E002-HU-003)
-- ============================================

CREATE TABLE tipos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    codigo TEXT NOT NULL,
    imagen_url TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT tipos_nombre_unique UNIQUE (nombre),
    CONSTRAINT tipos_codigo_unique UNIQUE (codigo),
    CONSTRAINT tipos_codigo_length CHECK (LENGTH(codigo) = 3),
    CONSTRAINT tipos_codigo_uppercase CHECK (codigo = UPPER(codigo)),
    CONSTRAINT tipos_codigo_only_letters CHECK (codigo ~ '^[A-Z]{3}$'),
    CONSTRAINT tipos_nombre_length CHECK (LENGTH(nombre) <= 50 AND LENGTH(nombre) > 0),
    CONSTRAINT tipos_descripcion_length CHECK (descripcion IS NULL OR LENGTH(descripcion) <= 200)
);

CREATE INDEX idx_tipos_nombre ON tipos(LOWER(nombre));
CREATE INDEX idx_tipos_codigo ON tipos(codigo);
CREATE INDEX idx_tipos_activo ON tipos(activo);
CREATE INDEX idx_tipos_created_at ON tipos(created_at DESC);

CREATE TRIGGER update_tipos_updated_at
    BEFORE UPDATE ON tipos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE tipos IS 'E002-HU-003: Catálogo de tipos de medias (altura/uso) con códigos únicos de 3 letras';
COMMENT ON COLUMN tipos.nombre IS 'Nombre del tipo (único, case-insensitive, max 50 caracteres) - RN-003-002';
COMMENT ON COLUMN tipos.codigo IS 'Código de 3 letras mayúsculas (único, inmutable) - RN-003-001, RN-003-004';
COMMENT ON COLUMN tipos.descripcion IS 'Descripción opcional del tipo (max 200 caracteres) - RN-003-003';
COMMENT ON COLUMN tipos.imagen_url IS 'URL de imagen de referencia del tipo (opcional) - RN-003-003, RN-003-013';
COMMENT ON COLUMN tipos.activo IS 'Estado del tipo (soft delete) - RN-003-005, RN-003-006';

-- ============================================
-- PASO 8: Tabla sistemas_talla (E002-HU-004)
-- ============================================

CREATE TABLE sistemas_talla (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    tipo_sistema tipo_sistema_enum NOT NULL,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT sistemas_talla_nombre_unique UNIQUE (nombre),
    CONSTRAINT sistemas_talla_nombre_length CHECK (LENGTH(nombre) <= 50 AND LENGTH(nombre) > 0),
    CONSTRAINT sistemas_talla_descripcion_length CHECK (descripcion IS NULL OR LENGTH(descripcion) <= 200)
);

CREATE INDEX idx_sistemas_talla_nombre ON sistemas_talla(LOWER(nombre));
CREATE INDEX idx_sistemas_talla_tipo_sistema ON sistemas_talla(tipo_sistema);
CREATE INDEX idx_sistemas_talla_activo ON sistemas_talla(activo);
CREATE INDEX idx_sistemas_talla_created_at ON sistemas_talla(created_at DESC);

CREATE TRIGGER update_sistemas_talla_updated_at
    BEFORE UPDATE ON sistemas_talla
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE sistemas_talla IS 'E002-HU-004: Sistemas de tallas configurables (UNICA, NUMERO, LETRA, RANGO)';
COMMENT ON COLUMN sistemas_talla.nombre IS 'Nombre del sistema (único, case-insensitive, max 50 caracteres) - RN-004-02';
COMMENT ON COLUMN sistemas_talla.tipo_sistema IS 'Tipo de sistema (inmutable) - RN-004-01, RN-004-07';
COMMENT ON COLUMN sistemas_talla.descripcion IS 'Descripción opcional del sistema (max 200 caracteres)';
COMMENT ON COLUMN sistemas_talla.activo IS 'Estado del sistema (soft delete) - RN-004-09, RN-004-13';

-- ============================================
-- PASO 9: Tabla valores_talla (E002-HU-004)
-- ============================================

CREATE TABLE valores_talla (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sistema_talla_id UUID NOT NULL REFERENCES sistemas_talla(id) ON DELETE CASCADE,
    valor TEXT NOT NULL,
    orden INTEGER NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT valores_talla_valor_length CHECK (LENGTH(valor) > 0 AND LENGTH(valor) <= 20),
    CONSTRAINT valores_talla_unique_per_system UNIQUE (sistema_talla_id, valor)
);

CREATE INDEX idx_valores_talla_sistema ON valores_talla(sistema_talla_id);
CREATE INDEX idx_valores_talla_orden ON valores_talla(sistema_talla_id, orden);
CREATE INDEX idx_valores_talla_activo ON valores_talla(activo);

CREATE TRIGGER update_valores_talla_updated_at
    BEFORE UPDATE ON valores_talla
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE valores_talla IS 'E002-HU-004: Valores individuales de cada sistema de talla';
COMMENT ON COLUMN valores_talla.valor IS 'Valor de la talla (ej: "35-36", "M", "34-38", "ÚNICA") - RN-004-03, RN-004-04';
COMMENT ON COLUMN valores_talla.orden IS 'Orden de visualización (ascendente) - RN-004-10';
COMMENT ON COLUMN valores_talla.activo IS 'Estado del valor (soft delete) - RN-004-08, RN-004-13';

-- ============================================
-- PASO 10: Tabla colores (E002-HU-005 + E002-HU-005-EXT)
-- ============================================

CREATE TABLE colores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(50) NOT NULL,
    codigos_hex TEXT[] NOT NULL,
    tipo_color VARCHAR(10) DEFAULT 'unico' NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT colores_nombre_unique UNIQUE (nombre),
    CONSTRAINT colores_nombre_length CHECK (LENGTH(nombre) >= 3 AND LENGTH(nombre) <= 30),
    CONSTRAINT colores_nombre_no_special_chars CHECK (nombre ~ '^[A-Za-zÀ-ÿ\s\-]+$'),
    CONSTRAINT colores_codigos_hex_length CHECK (array_length(codigos_hex, 1) BETWEEN 1 AND 3),
    CONSTRAINT colores_tipo_valid CHECK (tipo_color IN ('unico', 'compuesto')),
    CONSTRAINT colores_tipo_consistency CHECK (
        (tipo_color = 'unico' AND array_length(codigos_hex, 1) = 1) OR
        (tipo_color = 'compuesto' AND array_length(codigos_hex, 1) BETWEEN 2 AND 3)
    )
);

CREATE INDEX idx_colores_nombre ON colores(LOWER(nombre));
CREATE INDEX idx_colores_activo ON colores(activo);
CREATE INDEX idx_colores_created_at ON colores(created_at DESC);

CREATE TRIGGER update_colores_updated_at
    BEFORE UPDATE ON colores
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para validar formato hex en cada elemento
CREATE OR REPLACE FUNCTION validate_codigos_hex_format()
RETURNS TRIGGER AS $$
DECLARE
  codigo TEXT;
BEGIN
  FOREACH codigo IN ARRAY NEW.codigos_hex
  LOOP
    IF codigo !~ '^#[0-9A-Fa-f]{6}$' THEN
      RAISE EXCEPTION 'Código hexadecimal inválido: %. Formato esperado: #RRGGBB', codigo;
    END IF;
  END LOOP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_colores_hex_format
  BEFORE INSERT OR UPDATE ON colores
  FOR EACH ROW
  EXECUTE FUNCTION validate_codigos_hex_format();

COMMENT ON TABLE colores IS 'E002-HU-005-EXT: Catálogo de colores únicos (1 hex) o compuestos (2-3 hex)';
COMMENT ON COLUMN colores.nombre IS 'Nombre del color (único case-insensitive, 3-30 caracteres, solo letras/espacios/guiones) - RN-025';
COMMENT ON COLUMN colores.codigos_hex IS 'Array de códigos hexadecimales (1-3 códigos formato #RRGGBB) - RN-026';
COMMENT ON COLUMN colores.tipo_color IS 'Tipo: unico (1 color) o compuesto (2-3 colores)';
COMMENT ON COLUMN colores.activo IS 'Estado del color (soft delete) - RN-029, RN-032';
COMMENT ON FUNCTION validate_codigos_hex_format IS 'E002-HU-005-EXT: Valida formato #RRGGBB en cada elemento del array codigos_hex';

-- ============================================
-- PASO 11: Tabla producto_colores (E002-HU-005)
-- ============================================

CREATE TABLE producto_colores (
    producto_id UUID PRIMARY KEY REFERENCES productos(id) ON DELETE CASCADE,
    colores TEXT[] NOT NULL,
    cantidad_colores INTEGER GENERATED ALWAYS AS (array_length(colores, 1)) STORED,
    tipo_color VARCHAR(20) GENERATED ALWAYS AS (
        CASE
            WHEN array_length(colores, 1) = 1 THEN 'Unicolor'
            WHEN array_length(colores, 1) = 2 THEN 'Bicolor'
            WHEN array_length(colores, 1) = 3 THEN 'Tricolor'
            ELSE 'Multicolor'
        END
    ) STORED,
    descripcion_visual TEXT,

    -- Constraints
    CONSTRAINT producto_colores_min_colores CHECK (array_length(colores, 1) >= 1),
    CONSTRAINT producto_colores_max_colores CHECK (array_length(colores, 1) <= 5),
    CONSTRAINT producto_colores_descripcion_length CHECK (
        descripcion_visual IS NULL OR
        LENGTH(descripcion_visual) <= 100
    ),
    CONSTRAINT producto_colores_descripcion_only_multicolor CHECK (
        (array_length(colores, 1) >= 2 AND descripcion_visual IS NOT NULL) OR
        (array_length(colores, 1) = 1 AND descripcion_visual IS NULL) OR
        descripcion_visual IS NULL
    )
);

CREATE INDEX idx_producto_colores_tipo ON producto_colores(tipo_color);
CREATE INDEX idx_producto_colores_cantidad ON producto_colores(cantidad_colores);
CREATE INDEX idx_producto_colores_gin ON producto_colores USING GIN(colores);

COMMENT ON TABLE producto_colores IS 'E002-HU-005: Combinaciones de colores asignadas a productos';
COMMENT ON COLUMN producto_colores.colores IS 'Array de nombres de colores en orden (orden significativo) - RN-027, RN-028';
COMMENT ON COLUMN producto_colores.cantidad_colores IS 'Cantidad de colores (columna generada automática) - RN-031';
COMMENT ON COLUMN producto_colores.tipo_color IS 'Clasificación automática (Unicolor/Bicolor/Tricolor/Multicolor) - RN-031';
COMMENT ON COLUMN producto_colores.descripcion_visual IS 'Descripción opcional solo para multicolor (max 100 caracteres) - RN-034';

-- ============================================
-- PASO 12: Trigger para validar colores existentes
-- ============================================

CREATE OR REPLACE FUNCTION validate_producto_colores()
RETURNS TRIGGER AS $$
DECLARE
    color_name TEXT;
    color_exists BOOLEAN;
BEGIN
    -- Validar que cada color exista en tabla colores
    FOREACH color_name IN ARRAY NEW.colores
    LOOP
        SELECT EXISTS(
            SELECT 1 FROM colores WHERE LOWER(nombre) = LOWER(color_name)
        ) INTO color_exists;

        IF NOT color_exists THEN
            RAISE EXCEPTION 'El color "%" no existe en el catálogo', color_name;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_producto_colores_trigger
    BEFORE INSERT OR UPDATE ON producto_colores
    FOR EACH ROW
    EXECUTE FUNCTION validate_producto_colores();

COMMENT ON FUNCTION validate_producto_colores IS 'E002-HU-005: Valida que todos los colores en producto_colores existan en tabla colores';

-- ============================================
-- PASO 13: Habilitar RLS
-- ============================================

ALTER TABLE marcas ENABLE ROW LEVEL SECURITY;
ALTER TABLE tiendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_tiendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE materiales ENABLE ROW LEVEL SECURITY;
ALTER TABLE tipos ENABLE ROW LEVEL SECURITY;
ALTER TABLE sistemas_talla ENABLE ROW LEVEL SECURITY;
ALTER TABLE valores_talla ENABLE ROW LEVEL SECURITY;
ALTER TABLE colores ENABLE ROW LEVEL SECURITY;
ALTER TABLE producto_colores ENABLE ROW LEVEL SECURITY;

-- Policies básicas
CREATE POLICY authenticated_view_marcas ON marcas
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY admin_insert_marcas ON marcas
    FOR INSERT
    TO authenticated
    WITH CHECK (
        (SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'ADMIN'
    );

CREATE POLICY admin_update_marcas ON marcas
    FOR UPDATE
    TO authenticated
    USING (
        (SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'ADMIN'
    )
    WITH CHECK (
        (SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'ADMIN'
    );

CREATE POLICY admin_delete_marcas ON marcas
    FOR DELETE
    TO authenticated
    USING (
        (SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'ADMIN'
    );

CREATE POLICY authenticated_view_tiendas ON tiendas
    FOR SELECT
    USING (activa = true);

CREATE POLICY authenticated_view_productos ON productos
    FOR SELECT
    USING (activo = true);

CREATE POLICY authenticated_view_clientes ON clientes
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY users_view_own_tiendas ON user_tiendas
    FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY admin_view_all_user_tiendas ON user_tiendas
    FOR SELECT
    USING ((SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'ADMIN');

CREATE POLICY authenticated_view_materiales ON materiales
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY authenticated_view_tipos ON tipos
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY authenticated_view_sistemas_talla ON sistemas_talla
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY authenticated_view_valores_talla ON valores_talla
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY authenticated_view_colores ON colores
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY authenticated_view_producto_colores ON producto_colores
    FOR SELECT
    TO authenticated
    USING (true);

-- Políticas de INSERT/UPDATE/DELETE NO son necesarias porque las funciones
-- SECURITY DEFINER manejan la autorización internamente

-- ============================================
-- PASO 14: Tabla productos_maestros (E002-HU-006)
-- ============================================

CREATE TABLE productos_maestros (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    marca_id UUID NOT NULL REFERENCES marcas(id),
    material_id UUID NOT NULL REFERENCES materiales(id),
    tipo_id UUID NOT NULL REFERENCES tipos(id),
    valor_talla_id UUID NOT NULL REFERENCES valores_talla(id),
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints (RN-037, RN-039)
    CONSTRAINT productos_maestros_unique_combination UNIQUE(marca_id, material_id, tipo_id, valor_talla_id),
    CONSTRAINT productos_maestros_descripcion_length CHECK (descripcion IS NULL OR LENGTH(descripcion) <= 200)
);

-- Índices optimización
CREATE INDEX idx_productos_maestros_marca ON productos_maestros(marca_id);
CREATE INDEX idx_productos_maestros_material ON productos_maestros(material_id);
CREATE INDEX idx_productos_maestros_tipo ON productos_maestros(tipo_id);
CREATE INDEX idx_productos_maestros_valor_talla ON productos_maestros(valor_talla_id);
CREATE INDEX idx_productos_maestros_activo ON productos_maestros(activo);
CREATE INDEX idx_productos_maestros_created_at ON productos_maestros(created_at DESC);

-- Trigger updated_at
CREATE TRIGGER update_productos_maestros_updated_at
    BEFORE UPDATE ON productos_maestros
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios
COMMENT ON TABLE productos_maestros IS 'E002-HU-006: Productos maestros (definición base sin colores ni stock)';
COMMENT ON COLUMN productos_maestros.marca_id IS 'Referencia a marca activa (inmutable si tiene artículos) - RN-037, RN-038';
COMMENT ON COLUMN productos_maestros.material_id IS 'Referencia a material activo (inmutable si tiene artículos) - RN-037, RN-038';
COMMENT ON COLUMN productos_maestros.tipo_id IS 'Referencia a tipo activo (inmutable si tiene artículos) - RN-037, RN-038';
COMMENT ON COLUMN productos_maestros.valor_talla_id IS 'Referencia a valor de talla específico (inmutable si tiene artículos) - RN-037, RN-038';
COMMENT ON COLUMN productos_maestros.descripcion IS 'Descripción opcional (max 200 caracteres) - RN-039, RN-044';
COMMENT ON COLUMN productos_maestros.activo IS 'Estado del producto maestro (soft delete) - RN-042';

-- RLS Policy
ALTER TABLE productos_maestros ENABLE ROW LEVEL SECURITY;

CREATE POLICY authenticated_view_productos_maestros ON productos_maestros
    FOR SELECT
    TO authenticated
    USING (true);

-- ============================================
-- PASO 15: Tabla articulos (E002-HU-007)
-- ============================================

CREATE TABLE articulos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producto_maestro_id UUID NOT NULL REFERENCES productos_maestros(id),
    sku TEXT NOT NULL,
    tipo_coloracion VARCHAR(10) NOT NULL,
    colores_ids UUID[] NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT articulos_sku_unique UNIQUE (sku),
    CONSTRAINT articulos_tipo_coloracion_valid CHECK (tipo_coloracion IN ('unicolor', 'bicolor', 'tricolor')),
    CONSTRAINT articulos_colores_count_unicolor CHECK (
        (tipo_coloracion = 'unicolor' AND array_length(colores_ids, 1) = 1) OR
        tipo_coloracion != 'unicolor'
    ),
    CONSTRAINT articulos_colores_count_bicolor CHECK (
        (tipo_coloracion = 'bicolor' AND array_length(colores_ids, 1) = 2) OR
        tipo_coloracion != 'bicolor'
    ),
    CONSTRAINT articulos_colores_count_tricolor CHECK (
        (tipo_coloracion = 'tricolor' AND array_length(colores_ids, 1) = 3) OR
        tipo_coloracion != 'tricolor'
    ),
    CONSTRAINT articulos_precio_positive CHECK (precio >= 0.01),
    CONSTRAINT articulos_sku_uppercase CHECK (sku = UPPER(sku))
);

-- Índices optimización
CREATE INDEX idx_articulos_producto_maestro ON articulos(producto_maestro_id);
CREATE INDEX idx_articulos_sku ON articulos(sku);
CREATE INDEX idx_articulos_tipo_coloracion ON articulos(tipo_coloracion);
CREATE INDEX idx_articulos_activo ON articulos(activo);
CREATE INDEX idx_articulos_created_at ON articulos(created_at DESC);
CREATE INDEX idx_articulos_colores_gin ON articulos USING GIN(colores_ids);

-- Trigger updated_at
CREATE TRIGGER update_articulos_updated_at
    BEFORE UPDATE ON articulos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios
COMMENT ON TABLE articulos IS 'E002-HU-007: Artículos especializados (producto maestro + colores + SKU único)';
COMMENT ON COLUMN articulos.producto_maestro_id IS 'Referencia a producto maestro (inmutable si tiene stock) - RN-050, RN-055';
COMMENT ON COLUMN articulos.sku IS 'SKU único generado automáticamente (formato: MARCA-TIPO-MATERIAL-TALLA-COLOR1-COLOR2-COLOR3) - RN-047, RN-053';
COMMENT ON COLUMN articulos.tipo_coloracion IS 'Tipo de coloración: unicolor (1), bicolor (2), tricolor (3) - RN-048';
COMMENT ON COLUMN articulos.colores_ids IS 'Array ordenado de UUIDs de colores (orden significativo) - RN-049, RN-051';
COMMENT ON COLUMN articulos.precio IS 'Precio de venta (mínimo 0.01, editable con stock) - RN-052, RN-060';
COMMENT ON COLUMN articulos.activo IS 'Estado del artículo (soft delete) - RN-054';

-- RLS Policy
ALTER TABLE articulos ENABLE ROW LEVEL SECURITY;

CREATE POLICY authenticated_view_articulos ON articulos
    FOR SELECT
    TO authenticated
    USING (true);

-- ============================================
-- PASO 16: Tabla tipos_documento (E004-HU-001)
-- ============================================

-- ENUM para formato de documento
CREATE TYPE tipo_documento_formato AS ENUM ('NUMERICO', 'ALFANUMERICO');

COMMENT ON TYPE tipo_documento_formato IS 'E004-HU-001: Formato de validación del documento (NUMERICO o ALFANUMERICO)';

CREATE TABLE tipos_documento (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT NOT NULL,
    nombre TEXT NOT NULL,
    formato tipo_documento_formato NOT NULL,
    longitud_minima INTEGER NOT NULL,
    longitud_maxima INTEGER NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints (RN-040, RN-041, RN-046)
    CONSTRAINT tipos_documento_codigo_unique UNIQUE (codigo),
    CONSTRAINT tipos_documento_codigo_length CHECK (LENGTH(codigo) <= 10 AND LENGTH(codigo) > 0),
    CONSTRAINT tipos_documento_codigo_no_spaces CHECK (codigo !~ '\s'),
    CONSTRAINT tipos_documento_codigo_uppercase CHECK (codigo = UPPER(codigo)),
    CONSTRAINT tipos_documento_nombre_unique UNIQUE (nombre),
    CONSTRAINT tipos_documento_nombre_length CHECK (LENGTH(nombre) <= 100 AND LENGTH(nombre) > 0),
    CONSTRAINT tipos_documento_longitud_minima_positive CHECK (longitud_minima > 0),
    CONSTRAINT tipos_documento_longitud_maxima_gte_minima CHECK (longitud_maxima >= longitud_minima)
);

-- Índices optimización
CREATE INDEX idx_tipos_documento_codigo ON tipos_documento(codigo);
CREATE INDEX idx_tipos_documento_nombre ON tipos_documento(LOWER(nombre));
CREATE INDEX idx_tipos_documento_activo ON tipos_documento(activo);
CREATE INDEX idx_tipos_documento_created_at ON tipos_documento(created_at DESC);

-- Trigger updated_at
CREATE TRIGGER update_tipos_documento_updated_at
    BEFORE UPDATE ON tipos_documento
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios
COMMENT ON TABLE tipos_documento IS 'E004-HU-001: Catálogo de tipos de documentos de identidad con validaciones por formato y longitud - RN-040, RN-041, RN-045, RN-046';
COMMENT ON COLUMN tipos_documento.codigo IS 'Código único del tipo de documento (max 10 caracteres, mayúsculas, sin espacios, case-insensitive) - RN-040, RN-046';
COMMENT ON COLUMN tipos_documento.nombre IS 'Nombre del tipo de documento (único case-insensitive, max 100 caracteres) - RN-046';
COMMENT ON COLUMN tipos_documento.formato IS 'Formato de validación: NUMERICO (solo dígitos 0-9) o ALFANUMERICO (letras y números) - RN-041, RN-044';
COMMENT ON COLUMN tipos_documento.longitud_minima IS 'Longitud mínima del documento (mayor a 0) - RN-041, RN-046';
COMMENT ON COLUMN tipos_documento.longitud_maxima IS 'Longitud máxima del documento (mayor o igual a mínima) - RN-041, RN-046';
COMMENT ON COLUMN tipos_documento.activo IS 'Estado del tipo de documento (soft delete, controla visibilidad en selectores) - RN-042';

-- RLS Policy
ALTER TABLE tipos_documento ENABLE ROW LEVEL SECURITY;

CREATE POLICY authenticated_view_tipos_documento ON tipos_documento
    FOR SELECT
    TO authenticated
    USING (true);

-- ============================================
-- PASO 17: Tabla personas (E004-HU-002)
-- ============================================

-- ENUM para tipo de persona
CREATE TYPE tipo_persona_enum AS ENUM ('Natural', 'Juridica');

COMMENT ON TYPE tipo_persona_enum IS 'E004-HU-002: Tipo de persona (Natural o Jurídica) - RN-049';

CREATE TABLE personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tipo_documento_id UUID NOT NULL REFERENCES tipos_documento(id),
    numero_documento TEXT NOT NULL,
    tipo_persona tipo_persona_enum NOT NULL,
    nombre_completo TEXT,
    razon_social TEXT,
    email TEXT,
    celular TEXT,
    telefono TEXT,
    direccion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints (RN-047, RN-048, RN-049, RN-052, RN-053)
    CONSTRAINT personas_documento_unique UNIQUE (tipo_documento_id, numero_documento),
    CONSTRAINT personas_numero_documento_not_empty CHECK (LENGTH(TRIM(numero_documento)) > 0),
    CONSTRAINT personas_tipo_persona_nombre_check CHECK (
        (tipo_persona = 'Natural' AND nombre_completo IS NOT NULL AND LENGTH(TRIM(nombre_completo)) > 0 AND razon_social IS NULL) OR
        (tipo_persona = 'Juridica' AND razon_social IS NOT NULL AND LENGTH(TRIM(razon_social)) > 0 AND nombre_completo IS NULL)
    ),
    CONSTRAINT personas_email_format CHECK (
        email IS NULL OR
        (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' AND LENGTH(email) <= 100)
    ),
    CONSTRAINT personas_celular_format CHECK (
        celular IS NULL OR
        (celular ~ '^[0-9]{9}$')
    )
);

-- Índices optimización
CREATE INDEX idx_personas_tipo_documento ON personas(tipo_documento_id);
CREATE INDEX idx_personas_numero_documento ON personas(numero_documento);
CREATE INDEX idx_personas_tipo_persona ON personas(tipo_persona);
CREATE INDEX idx_personas_email ON personas(LOWER(email));
CREATE INDEX idx_personas_activo ON personas(activo);
CREATE INDEX idx_personas_created_at ON personas(created_at DESC);
CREATE INDEX idx_personas_nombre_completo ON personas(LOWER(nombre_completo));
CREATE INDEX idx_personas_razon_social ON personas(LOWER(razon_social));

-- Trigger updated_at
CREATE TRIGGER update_personas_updated_at
    BEFORE UPDATE ON personas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentarios
COMMENT ON TABLE personas IS 'E004-HU-002: Entidad base de personas identificadas por documento (sin roles asignados) - RN-047 a RN-060';
COMMENT ON COLUMN personas.tipo_documento_id IS 'Referencia a tipo de documento (inmutable después de creación) - RN-048, RN-050';
COMMENT ON COLUMN personas.numero_documento IS 'Número de documento (único por tipo, inmutable) - RN-047, RN-048, RN-050';
COMMENT ON COLUMN personas.tipo_persona IS 'Tipo de persona: Natural o Jurídica - RN-049, RN-057';
COMMENT ON COLUMN personas.nombre_completo IS 'Nombre completo (obligatorio si tipo_persona = Natural) - RN-049';
COMMENT ON COLUMN personas.razon_social IS 'Razón social (obligatorio si tipo_persona = Jurídica) - RN-049';
COMMENT ON COLUMN personas.email IS 'Email de contacto (opcional, formato válido) - RN-051, RN-052';
COMMENT ON COLUMN personas.celular IS 'Celular de contacto (opcional, 9 dígitos) - RN-051, RN-053';
COMMENT ON COLUMN personas.telefono IS 'Teléfono fijo (opcional) - RN-051';
COMMENT ON COLUMN personas.direccion IS 'Dirección (opcional) - RN-051';
COMMENT ON COLUMN personas.activo IS 'Estado de la persona (soft delete, permite reactivación) - RN-060';

-- RLS Policy
ALTER TABLE personas ENABLE ROW LEVEL SECURITY;

CREATE POLICY authenticated_view_personas ON personas
    FOR SELECT
    TO authenticated
    USING (true);


COMMIT;

-- ============================================
-- RESUMEN
-- ============================================
-- Tablas creadas:
--   - marcas (códigos 3 letras)
--   - materiales (códigos 3 letras, descripción opcional)
--   - tipos (códigos 3 letras, descripción e imagen opcional)
--   - sistemas_talla (UNICA, NUMERO, LETRA, RANGO)
--   - valores_talla (valores por sistema)
--   - colores (catálogo base con código hex)
--   - producto_colores (combinaciones con clasificación automática)
--   - tiendas (sucursales)
--   - productos (medias)
--   - clientes
--   - user_tiendas (asignaciones)
-- ============================================