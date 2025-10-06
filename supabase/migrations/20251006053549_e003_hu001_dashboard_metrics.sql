-- Migration: E003-HU-001 - Dashboard con Metricas
-- Fecha: 2025-10-06
-- Razon: Implementar infraestructura completa de negocio y dashboard
-- Impacto: Crea tablas de negocio (tiendas, productos, clientes, ventas, comisiones),
--          vistas materializadas para metricas, funciones de dashboard, indices y RLS policies

BEGIN;

-- ============================================
-- PASO 1: Crear ENUM para estados de venta
-- ============================================

CREATE TYPE venta_estado AS ENUM ('PENDIENTE', 'EN_PROCESO', 'PREPARANDO', 'COMPLETADA', 'CANCELADA', 'DEVUELTA');

COMMENT ON TYPE venta_estado IS 'E003-HU-001: Estados posibles de una venta - RN-004';

-- ============================================
-- PASO 2: Crear tablas de negocio
-- ============================================

-- 2.1 Tabla: tiendas
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

COMMENT ON TABLE tiendas IS 'E003-HU-001: Tiendas/sucursales del sistema';
COMMENT ON COLUMN tiendas.meta_mensual IS 'Meta de ventas mensuales en $$ - RN-007';

-- 2.2 Tabla: productos
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

COMMENT ON TABLE productos IS 'E003-HU-001: Catalogo de productos (medias)';
COMMENT ON COLUMN productos.stock_maximo IS 'Stock maximo para calcular umbral bajo - RN-003';

-- 2.3 Tabla: clientes
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

COMMENT ON TABLE clientes IS 'E003-HU-001: Base de datos de clientes';

-- 2.4 Tabla: ventas
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

-- Indices criticos para metricas de dashboard
CREATE INDEX idx_ventas_tienda_fecha ON ventas(tienda_id, fecha_venta DESC);
CREATE INDEX idx_ventas_vendedor_fecha ON ventas(vendedor_id, fecha_venta DESC);
CREATE INDEX idx_ventas_estado ON ventas(estado);
CREATE INDEX idx_ventas_fecha_venta ON ventas(fecha_venta DESC);

COMMENT ON TABLE ventas IS 'E003-HU-001: Registro de ventas del sistema';
COMMENT ON COLUMN ventas.estado IS 'Estados: PENDIENTE, EN_PROCESO, PREPARANDO, COMPLETADA, CANCELADA, DEVUELTA - RN-004';

-- 2.5 Tabla: ventas_detalles
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

-- 2.6 Tabla: comisiones
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

-- 2.7 Tabla: user_tiendas (asignacion)
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

COMMENT ON TABLE user_tiendas IS 'E003-HU-001: Asignacion de usuarios a tiendas';

-- ============================================
-- PASO 3: Triggers para updated_at
-- ============================================

CREATE TRIGGER update_tiendas_updated_at
    BEFORE UPDATE ON tiendas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_productos_updated_at
    BEFORE UPDATE ON productos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clientes_updated_at
    BEFORE UPDATE ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ventas_updated_at
    BEFORE UPDATE ON ventas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- PASO 4: Vistas materializadas para dashboard
-- ============================================

-- 4.1 Vista: dashboard_vendedor_metrics
CREATE MATERIALIZED VIEW dashboard_vendedor_metrics AS
SELECT
    v.vendedor_id,
    DATE_TRUNC('day', v.fecha_venta) AS fecha,

    -- Ventas de Hoy
    SUM(CASE
        WHEN DATE_TRUNC('day', v.fecha_venta) = DATE_TRUNC('day', NOW())
             AND v.estado IN ('COMPLETADA', 'PREPARANDO', 'EN_PROCESO')
        THEN v.monto_total
        ELSE 0
    END) AS ventas_hoy,

    -- Comisiones del Mes
    SUM(CASE
        WHEN DATE_TRUNC('month', v.fecha_venta) = DATE_TRUNC('month', NOW())
             AND v.estado = 'COMPLETADA'
        THEN COALESCE((SELECT SUM(c.monto_comision) FROM comisiones c WHERE c.venta_id = v.id), 0)
        ELSE 0
    END) AS comisiones_mes,

    -- Ordenes Pendientes
    COUNT(CASE
        WHEN v.estado IN ('PENDIENTE', 'EN_PROCESO', 'PREPARANDO')
        THEN 1
    END) AS ordenes_pendientes

FROM ventas v
GROUP BY v.vendedor_id, DATE_TRUNC('day', v.fecha_venta);

CREATE UNIQUE INDEX idx_mv_vendedor_metrics ON dashboard_vendedor_metrics(vendedor_id, fecha);

COMMENT ON MATERIALIZED VIEW dashboard_vendedor_metrics IS 'E003-HU-001: Metricas pre-calculadas para dashboard de vendedor';

-- 4.2 Vista: dashboard_gerente_metrics
CREATE MATERIALIZED VIEW dashboard_gerente_metrics AS
SELECT
    v.tienda_id,
    DATE_TRUNC('day', v.fecha_venta) AS fecha,

    -- Ventas Totales de la Tienda
    SUM(CASE
        WHEN v.estado IN ('COMPLETADA', 'PREPARANDO', 'EN_PROCESO')
        THEN v.monto_total
        ELSE 0
    END) AS ventas_totales,

    -- Clientes Activos (distintos clientes del mes)
    COUNT(DISTINCT CASE
        WHEN DATE_TRUNC('month', v.fecha_venta) = DATE_TRUNC('month', NOW())
             AND v.cliente_id IS NOT NULL
        THEN v.cliente_id
    END) AS clientes_activos_mes,

    -- Ordenes Pendientes
    COUNT(CASE
        WHEN v.estado IN ('PENDIENTE', 'EN_PROCESO', 'PREPARANDO')
        THEN 1
    END) AS ordenes_pendientes

FROM ventas v
GROUP BY v.tienda_id, DATE_TRUNC('day', v.fecha_venta);

CREATE UNIQUE INDEX idx_mv_gerente_metrics ON dashboard_gerente_metrics(tienda_id, fecha);

COMMENT ON MATERIALIZED VIEW dashboard_gerente_metrics IS 'E003-HU-001: Metricas pre-calculadas para dashboard de gerente';

-- 4.3 Vista: dashboard_admin_metrics
CREATE MATERIALIZED VIEW dashboard_admin_metrics AS
SELECT
    DATE_TRUNC('day', v.fecha_venta) AS fecha,

    -- Ventas Totales Consolidadas
    SUM(CASE
        WHEN v.estado IN ('COMPLETADA', 'PREPARANDO', 'EN_PROCESO')
        THEN v.monto_total
        ELSE 0
    END) AS ventas_totales_global,

    -- Clientes Activos Globales
    COUNT(DISTINCT CASE
        WHEN DATE_TRUNC('month', v.fecha_venta) = DATE_TRUNC('month', NOW())
             AND v.cliente_id IS NOT NULL
        THEN v.cliente_id
    END) AS clientes_activos_global,

    -- Ordenes Pendientes Globales
    COUNT(CASE
        WHEN v.estado IN ('PENDIENTE', 'EN_PROCESO', 'PREPARANDO')
        THEN 1
    END) AS ordenes_pendientes_global,

    -- Numero de Tiendas Activas
    COUNT(DISTINCT v.tienda_id) AS tiendas_activas

FROM ventas v
GROUP BY DATE_TRUNC('day', v.fecha_venta);

CREATE UNIQUE INDEX idx_mv_admin_metrics ON dashboard_admin_metrics(fecha);

COMMENT ON MATERIALIZED VIEW dashboard_admin_metrics IS 'E003-HU-001: Metricas pre-calculadas para dashboard de admin';

-- ============================================
-- PASO 5: Funciones de Dashboard
-- ============================================

-- 5.1 Funcion: get_dashboard_metrics()
CREATE OR REPLACE FUNCTION get_dashboard_metrics(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_rol TEXT;
    v_user_estado TEXT;
    v_email_verificado BOOLEAN;
    v_tienda_id UUID;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Obtener rol, estado y email_verificado del usuario
    SELECT
        raw_user_meta_data->>'rol',
        CASE
            WHEN email_confirmed_at IS NOT NULL THEN 'APROBADO'
            ELSE 'REGISTRADO'
        END,
        email_confirmed_at IS NOT NULL
    INTO v_user_rol, v_user_estado, v_email_verificado
    FROM auth.users
    WHERE id = p_user_id;

    -- Validar usuario encontrado
    IF v_user_rol IS NULL THEN
        v_error_hint := 'user_not_authorized';
        RAISE EXCEPTION 'Usuario no autorizado para acceder al dashboard';
    END IF;

    -- Validar email verificado
    IF NOT v_email_verificado THEN
        v_error_hint := 'email_not_verified';
        RAISE EXCEPTION 'Debes verificar tu email antes de acceder al dashboard';
    END IF;

    -- CASO 1: VENDEDOR - Metricas individuales
    IF v_user_rol = 'VENDEDOR' THEN
        SELECT json_build_object(
            'success', true,
            'data', json_build_object(
                'rol', 'VENDEDOR',
                'ventas_hoy', COALESCE(vm.ventas_hoy, 0),
                'comisiones_mes', COALESCE(vm.comisiones_mes, 0),
                'ordenes_pendientes', COALESCE(vm.ordenes_pendientes, 0),
                'productos_stock_bajo', (
                    SELECT COUNT(*)
                    FROM productos p
                    WHERE p.activo = true
                      AND (p.stock_actual < 5 OR p.stock_actual < (p.stock_maximo * 0.1))
                )
            )
        ) INTO v_result
        FROM dashboard_vendedor_metrics vm
        WHERE vm.vendedor_id = p_user_id
          AND vm.fecha = DATE_TRUNC('day', NOW());

        -- Si no hay datos, retornar ceros
        IF v_result IS NULL THEN
            v_result := json_build_object(
                'success', true,
                'data', json_build_object(
                    'rol', 'VENDEDOR',
                    'ventas_hoy', 0,
                    'comisiones_mes', 0,
                    'ordenes_pendientes', 0,
                    'productos_stock_bajo', (
                        SELECT COUNT(*)
                        FROM productos p
                        WHERE p.activo = true
                          AND (p.stock_actual < 5 OR p.stock_actual < (p.stock_maximo * 0.1))
                    )
                )
            );
        END IF;

        RETURN v_result;
    END IF;

    -- CASO 2: GERENTE - Metricas de tienda
    IF v_user_rol = 'GERENTE' THEN
        -- Obtener tienda asignada al gerente
        SELECT ut.tienda_id INTO v_tienda_id
        FROM user_tiendas ut
        WHERE ut.user_id = p_user_id AND ut.activo = true
        LIMIT 1;

        IF v_tienda_id IS NULL THEN
            v_error_hint := 'no_tienda_assigned';
            RAISE EXCEPTION 'Gerente sin tienda asignada';
        END IF;

        SELECT json_build_object(
            'success', true,
            'data', json_build_object(
                'rol', 'GERENTE',
                'tienda_id', v_tienda_id,
                'ventas_totales', COALESCE(gm.ventas_totales, 0),
                'clientes_activos', COALESCE(gm.clientes_activos_mes, 0),
                'ordenes_pendientes', COALESCE(gm.ordenes_pendientes, 0),
                'productos_stock_bajo', (
                    SELECT COUNT(*)
                    FROM productos p
                    WHERE p.activo = true
                      AND (p.stock_actual < 5 OR p.stock_actual < (p.stock_maximo * 0.1))
                ),
                'meta_mensual', (SELECT meta_mensual FROM tiendas WHERE id = v_tienda_id),
                'ventas_mes_actual', (
                    SELECT COALESCE(SUM(monto_total), 0)
                    FROM ventas
                    WHERE tienda_id = v_tienda_id
                      AND DATE_TRUNC('month', fecha_venta) = DATE_TRUNC('month', NOW())
                      AND estado IN ('COMPLETADA', 'PREPARANDO', 'EN_PROCESO')
                )
            )
        ) INTO v_result
        FROM dashboard_gerente_metrics gm
        WHERE gm.tienda_id = v_tienda_id
          AND gm.fecha = DATE_TRUNC('day', NOW());

        -- Si no hay datos, retornar con valores por defecto
        IF v_result IS NULL THEN
            v_result := json_build_object(
                'success', true,
                'data', json_build_object(
                    'rol', 'GERENTE',
                    'tienda_id', v_tienda_id,
                    'ventas_totales', 0,
                    'clientes_activos', 0,
                    'ordenes_pendientes', 0,
                    'productos_stock_bajo', (
                        SELECT COUNT(*)
                        FROM productos p
                        WHERE p.activo = true
                          AND (p.stock_actual < 5 OR p.stock_actual < (p.stock_maximo * 0.1))
                    ),
                    'meta_mensual', (SELECT COALESCE(meta_mensual, 0) FROM tiendas WHERE id = v_tienda_id),
                    'ventas_mes_actual', 0
                )
            );
        END IF;

        RETURN v_result;
    END IF;

    -- CASO 3: ADMIN - Metricas globales
    IF v_user_rol = 'ADMIN' THEN
        SELECT json_build_object(
            'success', true,
            'data', json_build_object(
                'rol', 'ADMIN',
                'ventas_totales_global', COALESCE(am.ventas_totales_global, 0),
                'clientes_activos_global', COALESCE(am.clientes_activos_global, 0),
                'ordenes_pendientes_global', COALESCE(am.ordenes_pendientes_global, 0),
                'tiendas_activas', COALESCE(am.tiendas_activas, 0),
                'productos_stock_critico', (
                    SELECT COUNT(*)
                    FROM productos p
                    WHERE p.activo = true AND p.stock_actual < 5
                )
            )
        ) INTO v_result
        FROM dashboard_admin_metrics am
        WHERE am.fecha = DATE_TRUNC('day', NOW());

        -- Si no hay datos, retornar ceros
        IF v_result IS NULL THEN
            v_result := json_build_object(
                'success', true,
                'data', json_build_object(
                    'rol', 'ADMIN',
                    'ventas_totales_global', 0,
                    'clientes_activos_global', 0,
                    'ordenes_pendientes_global', 0,
                    'tiendas_activas', 0,
                    'productos_stock_critico', (
                        SELECT COUNT(*)
                        FROM productos p
                        WHERE p.activo = true AND p.stock_actual < 5
                    )
                )
            );
        END IF;

        RETURN v_result;
    END IF;

    -- Fallback (no deberia llegar aqui)
    v_error_hint := 'invalid_role';
    RAISE EXCEPTION 'Rol de usuario no reconocido';

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

COMMENT ON FUNCTION get_dashboard_metrics IS 'E003-HU-001: Obtiene metricas de dashboard segun rol del usuario - RN-001';

-- 5.2 Funcion: get_sales_chart_data()
CREATE OR REPLACE FUNCTION get_sales_chart_data(
    p_user_id UUID,
    p_months INTEGER DEFAULT 6
)
RETURNS JSON AS $$
DECLARE
    v_user_rol TEXT;
    v_tienda_id UUID;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Obtener rol del usuario
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = p_user_id;

    IF v_user_rol IS NULL THEN
        v_error_hint := 'user_not_found';
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    -- VENDEDOR: Ventas mensuales del vendedor
    IF v_user_rol = 'VENDEDOR' THEN
        SELECT json_build_object(
            'success', true,
            'data', COALESCE(json_agg(
                json_build_object(
                    'mes', TO_CHAR(mes, 'YYYY-MM'),
                    'ventas', COALESCE(total_ventas, 0)
                )
            ), '[]'::json)
        ) INTO v_result
        FROM (
            SELECT
                DATE_TRUNC('month', v.fecha_venta) AS mes,
                SUM(v.monto_total) AS total_ventas
            FROM ventas v
            WHERE v.vendedor_id = p_user_id
              AND v.estado IN ('COMPLETADA', 'PREPARANDO', 'EN_PROCESO')
              AND v.fecha_venta >= NOW() - INTERVAL '1 month' * p_months
            GROUP BY DATE_TRUNC('month', v.fecha_venta)
            ORDER BY mes DESC
        ) AS monthly_sales;

        RETURN v_result;
    END IF;

    -- GERENTE: Ventas mensuales de la tienda
    IF v_user_rol = 'GERENTE' THEN
        SELECT ut.tienda_id INTO v_tienda_id
        FROM user_tiendas ut
        WHERE ut.user_id = p_user_id AND ut.activo = true
        LIMIT 1;

        SELECT json_build_object(
            'success', true,
            'data', COALESCE(json_agg(
                json_build_object(
                    'mes', TO_CHAR(mes, 'YYYY-MM'),
                    'ventas', COALESCE(total_ventas, 0)
                )
            ), '[]'::json)
        ) INTO v_result
        FROM (
            SELECT
                DATE_TRUNC('month', v.fecha_venta) AS mes,
                SUM(v.monto_total) AS total_ventas
            FROM ventas v
            WHERE v.tienda_id = v_tienda_id
              AND v.estado IN ('COMPLETADA', 'PREPARANDO', 'EN_PROCESO')
              AND v.fecha_venta >= NOW() - INTERVAL '1 month' * p_months
            GROUP BY DATE_TRUNC('month', v.fecha_venta)
            ORDER BY mes DESC
        ) AS monthly_sales;

        RETURN v_result;
    END IF;

    -- ADMIN: Ventas mensuales consolidadas
    IF v_user_rol = 'ADMIN' THEN
        SELECT json_build_object(
            'success', true,
            'data', COALESCE(json_agg(
                json_build_object(
                    'mes', TO_CHAR(mes, 'YYYY-MM'),
                    'ventas', COALESCE(total_ventas, 0)
                )
            ), '[]'::json)
        ) INTO v_result
        FROM (
            SELECT
                DATE_TRUNC('month', v.fecha_venta) AS mes,
                SUM(v.monto_total) AS total_ventas
            FROM ventas v
            WHERE v.estado IN ('COMPLETADA', 'PREPARANDO', 'EN_PROCESO')
              AND v.fecha_venta >= NOW() - INTERVAL '1 month' * p_months
            GROUP BY DATE_TRUNC('month', v.fecha_venta)
            ORDER BY mes DESC
        ) AS monthly_sales;

        RETURN v_result;
    END IF;

    v_error_hint := 'invalid_role';
    RAISE EXCEPTION 'Rol no reconocido';

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

COMMENT ON FUNCTION get_sales_chart_data IS 'E003-HU-001: Obtiene datos de grafico de ventas mensuales segun rol';

-- 5.3 Funcion: get_top_productos()
CREATE OR REPLACE FUNCTION get_top_productos(p_user_id UUID, p_limit INTEGER DEFAULT 5)
RETURNS JSON AS $$
DECLARE
    v_user_rol TEXT;
    v_tienda_id UUID;
    v_result JSON;
BEGIN
    SELECT raw_user_meta_data->>'rol' INTO v_user_rol
    FROM auth.users
    WHERE id = p_user_id;

    -- Para GERENTE, filtrar por tienda
    IF v_user_rol = 'GERENTE' THEN
        SELECT ut.tienda_id INTO v_tienda_id
        FROM user_tiendas ut
        WHERE ut.user_id = p_user_id AND ut.activo = true
        LIMIT 1;
    END IF;

    SELECT json_build_object(
        'success', true,
        'data', COALESCE(json_agg(
            json_build_object(
                'producto_id', producto_id,
                'nombre', producto_nombre,
                'cantidad_vendida', cantidad_total
            )
        ), '[]'::json)
    ) INTO v_result
    FROM (
        SELECT
            p.id AS producto_id,
            p.nombre AS producto_nombre,
            SUM(vd.cantidad) AS cantidad_total
        FROM ventas_detalles vd
        INNER JOIN ventas v ON vd.venta_id = v.id
        INNER JOIN productos p ON vd.producto_id = p.id
        WHERE v.estado IN ('COMPLETADA', 'PREPARANDO', 'EN_PROCESO')
          AND DATE_TRUNC('month', v.fecha_venta) = DATE_TRUNC('month', NOW())
          AND (v_tienda_id IS NULL OR v.tienda_id = v_tienda_id)
        GROUP BY p.id, p.nombre
        ORDER BY cantidad_total DESC
        LIMIT p_limit
    ) AS top_products;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_top_productos IS 'E003-HU-001: Obtiene top N productos mas vendidos del mes';

-- 5.4 Funcion: refresh_dashboard_metrics()
CREATE OR REPLACE FUNCTION refresh_dashboard_metrics()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY dashboard_vendedor_metrics;
    REFRESH MATERIALIZED VIEW CONCURRENTLY dashboard_gerente_metrics;
    REFRESH MATERIALIZED VIEW CONCURRENTLY dashboard_admin_metrics;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION refresh_dashboard_metrics IS 'E003-HU-001: Refresca todas las vistas materializadas del dashboard';

-- ============================================
-- PASO 6: RLS Policies
-- ============================================

-- 6.1 Habilitar RLS en todas las tablas
ALTER TABLE tiendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE ventas_detalles ENABLE ROW LEVEL SECURITY;
ALTER TABLE comisiones ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_tiendas ENABLE ROW LEVEL SECURITY;

-- 6.2 Policies para ventas
CREATE POLICY "vendedor_view_own_sales"
    ON ventas
    FOR SELECT
    USING (
        (SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'VENDEDOR'
        AND vendedor_id = auth.uid()
    );

CREATE POLICY "gerente_view_tienda_sales"
    ON ventas
    FOR SELECT
    USING (
        (SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'GERENTE'
        AND tienda_id IN (
            SELECT tienda_id
            FROM user_tiendas
            WHERE user_id = auth.uid() AND activo = true
        )
    );

CREATE POLICY "admin_view_all_sales"
    ON ventas
    FOR SELECT
    USING ((SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'ADMIN');

-- 6.3 Policies para productos
CREATE POLICY "authenticated_view_productos"
    ON productos
    FOR SELECT
    USING (activo = true);

-- 6.4 Policies para tiendas
CREATE POLICY "authenticated_view_tiendas"
    ON tiendas
    FOR SELECT
    USING (activa = true);

-- 6.5 Policies para clientes
CREATE POLICY "authenticated_view_clientes"
    ON clientes
    FOR SELECT
    TO authenticated
    USING (true);

-- 6.6 Policies para ventas_detalles
CREATE POLICY "authenticated_view_ventas_detalles"
    ON ventas_detalles
    FOR SELECT
    TO authenticated
    USING (true);

-- 6.7 Policies para comisiones
CREATE POLICY "vendedor_view_own_comisiones"
    ON comisiones
    FOR SELECT
    USING (vendedor_id = auth.uid());

CREATE POLICY "admin_view_all_comisiones"
    ON comisiones
    FOR SELECT
    USING ((SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'ADMIN');

-- 6.8 Policies para user_tiendas
CREATE POLICY "users_view_own_tiendas"
    ON user_tiendas
    FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "admin_view_all_user_tiendas"
    ON user_tiendas
    FOR SELECT
    USING ((SELECT raw_user_meta_data->>'rol' FROM auth.users WHERE id = auth.uid()) = 'ADMIN');

COMMIT;
