-- ============================================
-- Migration: 00000000000004_sales_tables.sql
-- Descripción: Tablas de ventas, detalles y comisiones
-- Fecha: 2025-10-07 (Consolidado)
-- ============================================

BEGIN;

-- ============================================
-- PASO 1: Tabla ventas (E003-HU-001)
-- ============================================

CREATE TABLE ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relaciones
    tienda_id UUID NOT NULL REFERENCES tiendas(id),
    vendedor_id UUID NOT NULL REFERENCES auth.users(id),
    cliente_id UUID REFERENCES clientes(id),

    -- Datos de venta
    monto_total DECIMAL(12, 2) NOT NULL,
    estado venta_estado NOT NULL DEFAULT 'PENDIENTE',

    -- Metadatos
    fecha_venta TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices críticos para métricas de dashboard
CREATE INDEX idx_ventas_tienda_fecha ON ventas(tienda_id, fecha_venta DESC);
CREATE INDEX idx_ventas_vendedor_fecha ON ventas(vendedor_id, fecha_venta DESC);
CREATE INDEX idx_ventas_estado ON ventas(estado);
CREATE INDEX idx_ventas_fecha_venta ON ventas(fecha_venta DESC);

CREATE TRIGGER update_ventas_updated_at
    BEFORE UPDATE ON ventas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE ventas IS 'E003-HU-001: Registro de ventas del sistema';
COMMENT ON COLUMN ventas.estado IS 'Estados: PENDIENTE, EN_PROCESO, PREPARANDO, COMPLETADA, CANCELADA, DEVUELTA - RN-004';

-- ============================================
-- PASO 2: Tabla ventas_detalles (E003-HU-001)
-- ============================================

CREATE TABLE ventas_detalles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venta_id UUID NOT NULL REFERENCES ventas(id) ON DELETE CASCADE,
    producto_id UUID NOT NULL REFERENCES productos(id),
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_ventas_detalles_venta ON ventas_detalles(venta_id);
CREATE INDEX idx_ventas_detalles_producto ON ventas_detalles(producto_id);

COMMENT ON TABLE ventas_detalles IS 'E003-HU-001: Detalles de productos en cada venta';

-- ============================================
-- PASO 3: Tabla comisiones (E003-HU-001)
-- ============================================

CREATE TABLE comisiones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendedor_id UUID NOT NULL REFERENCES auth.users(id),
    venta_id UUID NOT NULL REFERENCES ventas(id),
    monto_comision DECIMAL(10, 2) NOT NULL,
    porcentaje DECIMAL(5, 2) NOT NULL,
    fecha_comision TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_comisiones_vendedor_fecha ON comisiones(vendedor_id, fecha_comision DESC);

COMMENT ON TABLE comisiones IS 'E003-HU-001: Comisiones generadas por ventas';

-- ============================================
-- PASO 4: Habilitar RLS
-- ============================================

ALTER TABLE ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas_detalles ENABLE ROW LEVEL SECURITY;
ALTER TABLE comisiones ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PASO 5: Policies para ventas
-- ============================================

-- VENDEDOR: solo sus propias ventas
CREATE POLICY vendedor_view_own_sales ON ventas
    FOR SELECT
    USING (
        (SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'VENDEDOR'
        AND vendedor_id = auth.uid()
    );

-- GERENTE: ventas de su tienda
CREATE POLICY gerente_view_tienda_sales ON ventas
    FOR SELECT
    USING (
        (SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'GERENTE'
        AND tienda_id IN (
            SELECT tienda_id
            FROM user_tiendas
            WHERE user_id = auth.uid() AND activo = true
        )
    );

-- ADMIN: todas las ventas
CREATE POLICY admin_view_all_sales ON ventas
    FOR SELECT
    USING ((SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'ADMIN');

-- ============================================
-- PASO 6: Policies para ventas_detalles
-- ============================================

CREATE POLICY authenticated_view_ventas_detalles ON ventas_detalles
    FOR SELECT
    TO authenticated
    USING (true);

-- ============================================
-- PASO 7: Policies para comisiones
-- ============================================

-- VENDEDOR: solo sus propias comisiones
CREATE POLICY vendedor_view_own_comisiones ON comisiones
    FOR SELECT
    USING (vendedor_id = auth.uid());

-- ADMIN: todas las comisiones
CREATE POLICY admin_view_all_comisiones ON comisiones
    FOR SELECT
    USING ((SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'ADMIN');

COMMIT;

-- ============================================
-- RESUMEN
-- ============================================
-- Tablas creadas:
--   - ventas (transacciones de venta)
--   - ventas_detalles (líneas de productos)
--   - comisiones (comisiones por ventas)
-- ============================================