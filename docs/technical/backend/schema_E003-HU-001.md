# Schema BD - E003-HU-001: Dashboard con Métricas

**Historia de Usuario**: E003-HU-001
**Responsable Diseño**: @web-architect-expert
**Fecha Diseño**: 2025-10-06
**Estado**: 🎨 Especificación de Diseño

---

## 📋 ÍNDICE

1. [Tablas de Negocio Base](#tablas-de-negocio-base)
2. [Vistas Materializadas para Dashboard](#vistas-materializadas-para-dashboard)
3. [Funciones de Métricas](#funciones-de-métricas)
4. [Índices de Performance](#índices-de-performance)
5. [RLS Policies](#rls-policies)

---

## 1. TABLAS DE NEGOCIO BASE

### 1.1 Tabla: `tiendas`

```sql
-- Tabla de tiendas/sucursales del negocio
CREATE TABLE tiendas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    direccion TEXT,
    meta_mensual DECIMAL(12, 2) DEFAULT 0, -- Meta de ventas del mes
    activa BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_tiendas_activa ON tiendas(activa);

COMMENT ON TABLE tiendas IS 'E003-HU-001: Tiendas/sucursales del sistema';
COMMENT ON COLUMN tiendas.meta_mensual IS 'Meta de ventas mensuales en $$ - RN-007';
```

---

### 1.2 Tabla: `productos`

```sql
-- Tabla de productos (medias)
CREATE TABLE productos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    stock_actual INTEGER DEFAULT 0,
    stock_maximo INTEGER DEFAULT 100, -- Para calcular stock bajo (RN-003)
    activo BOOLEAN DEFAULT true,
    descontinuado BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_productos_activo ON productos(activo);
CREATE INDEX idx_productos_stock ON productos(stock_actual);

COMMENT ON TABLE productos IS 'E003-HU-001: Catálogo de productos (medias)';
COMMENT ON COLUMN productos.stock_maximo IS 'Stock máximo para calcular umbral bajo - RN-003';
```

---

### 1.3 Tabla: `clientes`

```sql
-- Tabla de clientes
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
```

---

### 1.4 Tabla: `ventas`

```sql
-- ENUM para estados de venta
CREATE TYPE venta_estado AS ENUM ('PENDIENTE', 'EN_PROCESO', 'PREPARANDO', 'COMPLETADA', 'CANCELADA', 'DEVUELTA');

-- Tabla de ventas (transacciones)
CREATE TABLE ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relaciones
    tienda_id UUID NOT NULL REFERENCES tiendas(id),
    vendedor_id UUID NOT NULL REFERENCES users(id), -- FK a users con rol VENDEDOR
    cliente_id UUID REFERENCES clientes(id), -- Nullable para ventas anónimas

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

COMMENT ON TABLE ventas IS 'E003-HU-001: Registro de ventas del sistema';
COMMENT ON COLUMN ventas.estado IS 'Estados: PENDIENTE, EN_PROCESO, PREPARANDO, COMPLETADA, CANCELADA, DEVUELTA - RN-004';
```

---

### 1.5 Tabla: `ventas_detalles`

```sql
-- Detalles de productos vendidos
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
```

---

### 1.6 Tabla: `comisiones`

```sql
-- Tabla de comisiones de vendedores
CREATE TABLE comisiones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendedor_id UUID NOT NULL REFERENCES users(id),
    venta_id UUID NOT NULL REFERENCES ventas(id),
    monto_comision DECIMAL(10, 2) NOT NULL,
    porcentaje DECIMAL(5, 2) NOT NULL, -- % de comisión aplicado
    fecha_comision TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_comisiones_vendedor_fecha ON comisiones(vendedor_id, fecha_comision DESC);

COMMENT ON TABLE comisiones IS 'E003-HU-001: Comisiones generadas por ventas';
```

---

### 1.7 Tabla: `user_tiendas` (Asignación)

```sql
-- Relación muchos a muchos: usuarios y tiendas asignadas
CREATE TABLE user_tiendas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tienda_id UUID NOT NULL REFERENCES tiendas(id) ON DELETE CASCADE,
    asignado_desde TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    activo BOOLEAN DEFAULT true,
    UNIQUE(user_id, tienda_id)
);

CREATE INDEX idx_user_tiendas_user ON user_tiendas(user_id, activo);
CREATE INDEX idx_user_tiendas_tienda ON user_tiendas(tienda_id, activo);

COMMENT ON TABLE user_tiendas IS 'E003-HU-001: Asignación de usuarios a tiendas';
```

---

## 2. VISTAS MATERIALIZADAS PARA DASHBOARD

### 2.1 Vista: `dashboard_vendedor_metrics`

```sql
-- Vista materializada para métricas de vendedor (optimización de queries)
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
        THEN (SELECT SUM(c.monto_comision) FROM comisiones c WHERE c.venta_id = v.id)
        ELSE 0
    END) AS comisiones_mes,

    -- Órdenes Pendientes
    COUNT(CASE
        WHEN v.estado IN ('PENDIENTE', 'EN_PROCESO', 'PREPARANDO')
        THEN 1
    END) AS ordenes_pendientes

FROM ventas v
GROUP BY v.vendedor_id, DATE_TRUNC('day', v.fecha_venta);

CREATE UNIQUE INDEX idx_mv_vendedor_metrics ON dashboard_vendedor_metrics(vendedor_id, fecha);

COMMENT ON MATERIALIZED VIEW dashboard_vendedor_metrics IS 'E003-HU-001: Métricas pre-calculadas para dashboard de vendedor';
```

---

### 2.2 Vista: `dashboard_gerente_metrics`

```sql
-- Vista materializada para métricas de gerente (por tienda)
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

    -- Órdenes Pendientes
    COUNT(CASE
        WHEN v.estado IN ('PENDIENTE', 'EN_PROCESO', 'PREPARANDO')
        THEN 1
    END) AS ordenes_pendientes

FROM ventas v
GROUP BY v.tienda_id, DATE_TRUNC('day', v.fecha_venta);

CREATE UNIQUE INDEX idx_mv_gerente_metrics ON dashboard_gerente_metrics(tienda_id, fecha);

COMMENT ON MATERIALIZED VIEW dashboard_gerente_metrics IS 'E003-HU-001: Métricas pre-calculadas para dashboard de gerente';
```

---

### 2.3 Vista: `dashboard_admin_metrics`

```sql
-- Vista materializada para métricas de admin (consolidado global)
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

    -- Órdenes Pendientes Globales
    COUNT(CASE
        WHEN v.estado IN ('PENDIENTE', 'EN_PROCESO', 'PREPARANDO')
        THEN 1
    END) AS ordenes_pendientes_global,

    -- Número de Tiendas Activas
    COUNT(DISTINCT v.tienda_id) AS tiendas_activas

FROM ventas v
GROUP BY DATE_TRUNC('day', v.fecha_venta);

CREATE UNIQUE INDEX idx_mv_admin_metrics ON dashboard_admin_metrics(fecha);

COMMENT ON MATERIALIZED VIEW dashboard_admin_metrics IS 'E003-HU-001: Métricas pre-calculadas para dashboard de admin';
```

---

## 3. FUNCIONES DE MÉTRICAS

### 3.1 Función: `get_dashboard_metrics()`

```sql
-- Función unificada que devuelve métricas según rol del usuario
CREATE OR REPLACE FUNCTION get_dashboard_metrics(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_rol user_role;
    v_tienda_id UUID;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Obtener rol del usuario
    SELECT rol INTO v_user_rol
    FROM users
    WHERE id = p_user_id AND estado = 'APROBADO' AND email_verificado = true;

    -- Validar usuario encontrado
    IF v_user_rol IS NULL THEN
        v_error_hint := 'user_not_authorized';
        RAISE EXCEPTION 'Usuario no autorizado para acceder al dashboard';
    END IF;

    -- CASO 1: VENDEDOR - Métricas individuales
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

        RETURN v_result;
    END IF;

    -- CASO 2: GERENTE - Métricas de tienda
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

        RETURN v_result;
    END IF;

    -- CASO 3: ADMIN - Métricas globales
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

        RETURN v_result;
    END IF;

    -- Fallback (no debería llegar aquí)
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

COMMENT ON FUNCTION get_dashboard_metrics IS 'E003-HU-001: Obtiene métricas de dashboard según rol del usuario - RN-001';
```

---

### 3.2 Función: `get_sales_chart_data()`

```sql
-- Función para obtener datos de gráficos de ventas (últimos 6 meses)
CREATE OR REPLACE FUNCTION get_sales_chart_data(
    p_user_id UUID,
    p_months INTEGER DEFAULT 6
)
RETURNS JSON AS $$
DECLARE
    v_user_rol user_role;
    v_tienda_id UUID;
    v_result JSON;
    v_error_hint TEXT;
BEGIN
    -- Obtener rol del usuario
    SELECT rol INTO v_user_rol
    FROM users
    WHERE id = p_user_id;

    IF v_user_rol IS NULL THEN
        v_error_hint := 'user_not_found';
        RAISE EXCEPTION 'Usuario no encontrado';
    END IF;

    -- VENDEDOR: Ventas mensuales del vendedor
    IF v_user_rol = 'VENDEDOR' THEN
        SELECT json_build_object(
            'success', true,
            'data', json_agg(
                json_build_object(
                    'mes', TO_CHAR(mes, 'YYYY-MM'),
                    'ventas', COALESCE(total_ventas, 0)
                )
            )
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
            'data', json_agg(
                json_build_object(
                    'mes', TO_CHAR(mes, 'YYYY-MM'),
                    'ventas', COALESCE(total_ventas, 0)
                )
            )
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
            'data', json_agg(
                json_build_object(
                    'mes', TO_CHAR(mes, 'YYYY-MM'),
                    'ventas', COALESCE(total_ventas, 0)
                )
            )
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

COMMENT ON FUNCTION get_sales_chart_data IS 'E003-HU-001: Obtiene datos de gráfico de ventas mensuales según rol';
```

---

### 3.3 Función: `get_top_productos()`

```sql
-- Función para obtener top 5 productos más vendidos
CREATE OR REPLACE FUNCTION get_top_productos(p_user_id UUID, p_limit INTEGER DEFAULT 5)
RETURNS JSON AS $$
DECLARE
    v_user_rol user_role;
    v_tienda_id UUID;
    v_result JSON;
BEGIN
    SELECT rol INTO v_user_rol FROM users WHERE id = p_user_id;

    -- Para GERENTE, filtrar por tienda
    IF v_user_rol = 'GERENTE' THEN
        SELECT ut.tienda_id INTO v_tienda_id
        FROM user_tiendas ut
        WHERE ut.user_id = p_user_id AND ut.activo = true
        LIMIT 1;
    END IF;

    SELECT json_build_object(
        'success', true,
        'data', json_agg(
            json_build_object(
                'producto_id', producto_id,
                'nombre', producto_nombre,
                'cantidad_vendida', cantidad_total
            )
        )
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

COMMENT ON FUNCTION get_top_productos IS 'E003-HU-001: Obtiene top N productos más vendidos del mes';
```

---

### 3.4 Función: `refresh_dashboard_metrics()`

```sql
-- Función para refrescar vistas materializadas (ejecutar periódicamente)
CREATE OR REPLACE FUNCTION refresh_dashboard_metrics()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY dashboard_vendedor_metrics;
    REFRESH MATERIALIZED VIEW CONCURRENTLY dashboard_gerente_metrics;
    REFRESH MATERIALIZED VIEW CONCURRENTLY dashboard_admin_metrics;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION refresh_dashboard_metrics IS 'E003-HU-001: Refresca todas las vistas materializadas del dashboard';
```

---

## 4. ÍNDICES DE PERFORMANCE

Todos los índices críticos ya están creados en las secciones anteriores:

- `idx_ventas_tienda_fecha` - Para métricas por tienda
- `idx_ventas_vendedor_fecha` - Para métricas por vendedor
- `idx_ventas_estado` - Para filtrar por estado
- `idx_productos_stock` - Para alertas de stock bajo

---

## 5. RLS POLICIES

### 5.1 Policies para `ventas`

```sql
-- VENDEDOR: Ver solo sus propias ventas
CREATE POLICY "vendedor_view_own_sales"
    ON ventas
    FOR SELECT
    USING (
        auth.jwt() ->> 'rol' = 'VENDEDOR'
        AND vendedor_id = auth.uid()
    );

-- GERENTE: Ver ventas de su tienda
CREATE POLICY "gerente_view_tienda_sales"
    ON ventas
    FOR SELECT
    USING (
        auth.jwt() ->> 'rol' = 'GERENTE'
        AND tienda_id IN (
            SELECT tienda_id
            FROM user_tiendas
            WHERE user_id = auth.uid() AND activo = true
        )
    );

-- ADMIN: Ver todas las ventas
CREATE POLICY "admin_view_all_sales"
    ON ventas
    FOR SELECT
    USING (auth.jwt() ->> 'rol' = 'ADMIN');
```

### 5.2 Policies para `productos`

```sql
-- Todos pueden ver productos activos
CREATE POLICY "authenticated_view_productos"
    ON productos
    FOR SELECT
    USING (activo = true);
```

---

## 📝 NOTAS DE IMPLEMENTACIÓN

### Triggers a Crear

1. **Auto-actualizar `updated_at`** en todas las tablas (similar a `users`)
2. **Auto-calcular comisiones** al insertar venta con estado COMPLETADA
3. **Auto-actualizar stock** de productos cuando se registra venta

### Jobs Programados

- **Refresh de vistas materializadas**: Cada 5 minutos durante horas pico
- **Limpieza de ventas antiguas**: Archivar ventas > 1 año

### Validaciones en Aplicación

- Verificar que vendedor pertenece a la tienda antes de crear venta
- Validar stock disponible antes de confirmar venta
- Calcular tendencias en frontend (comparar con período anterior)

---

## ✅ SQL FINAL IMPLEMENTADO

**Status**: 🎨 Pendiente de Implementación

_Esta sección será completada por @supabase-expert después de crear la migration._

---

**Próximos Pasos**:
1. @supabase-expert: Crear migration con este schema
2. @supabase-expert: Poblar datos de prueba (seed)
3. @flutter-expert: Implementar modelos Dart correspondientes
