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
-- PASO 8: Habilitar RLS
-- ============================================

ALTER TABLE marcas ENABLE ROW LEVEL SECURITY;
ALTER TABLE tiendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_tiendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE materiales ENABLE ROW LEVEL SECURITY;
ALTER TABLE tipos ENABLE ROW LEVEL SECURITY;

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

-- Políticas de INSERT/UPDATE/DELETE NO son necesarias porque las funciones
-- SECURITY DEFINER (crear_material, actualizar_material, toggle_material_activo,
-- create_tipo, update_tipo, toggle_tipo_activo) manejan la autorización internamente

COMMIT;

-- ============================================
-- RESUMEN
-- ============================================
-- Tablas creadas:
--   - marcas (códigos 3 letras)
--   - materiales (códigos 3 letras, descripción opcional)
--   - tipos (códigos 3 letras, descripción e imagen opcional)
--   - tiendas (sucursales)
--   - productos (medias)
--   - clientes
--   - user_tiendas (asignaciones)
-- ============================================