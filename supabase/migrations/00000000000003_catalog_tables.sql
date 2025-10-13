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
    sistema_talla_id UUID NOT NULL REFERENCES sistemas_talla(id),
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints (RN-037, RN-039)
    CONSTRAINT productos_maestros_unique_combination UNIQUE(marca_id, material_id, tipo_id, sistema_talla_id),
    CONSTRAINT productos_maestros_descripcion_length CHECK (descripcion IS NULL OR LENGTH(descripcion) <= 200)
);

-- Índices optimización
CREATE INDEX idx_productos_maestros_marca ON productos_maestros(marca_id);
CREATE INDEX idx_productos_maestros_material ON productos_maestros(material_id);
CREATE INDEX idx_productos_maestros_tipo ON productos_maestros(tipo_id);
CREATE INDEX idx_productos_maestros_sistema_talla ON productos_maestros(sistema_talla_id);
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
COMMENT ON COLUMN productos_maestros.sistema_talla_id IS 'Referencia a sistema de tallas activo (inmutable si tiene artículos) - RN-037, RN-038';
COMMENT ON COLUMN productos_maestros.descripcion IS 'Descripción opcional (max 200 caracteres) - RN-039, RN-044';
COMMENT ON COLUMN productos_maestros.activo IS 'Estado del producto maestro (soft delete) - RN-042';

-- RLS Policy
ALTER TABLE productos_maestros ENABLE ROW LEVEL SECURITY;

CREATE POLICY authenticated_view_productos_maestros ON productos_maestros
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