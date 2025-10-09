-- ============================================
-- Migration: 00000000000007_menu_permissions.sql
-- Descripción: Sistema de menús y permisos por rol
-- Fecha: 2025-10-07 (Consolidado)
-- ============================================

BEGIN;

-- ============================================
-- PASO 1: Tabla menu_options (HU-002)
-- ============================================

CREATE TABLE menu_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES menu_options(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    icon TEXT,
    route TEXT,
    orden INTEGER NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_menu_options_parent_id ON menu_options(parent_id);
CREATE INDEX idx_menu_options_activo ON menu_options(activo);
CREATE INDEX idx_menu_options_code ON menu_options(code);

CREATE TRIGGER update_menu_options_updated_at
    BEFORE UPDATE ON menu_options
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE menu_options IS 'HU-002: Catálogo maestro de opciones de menú del sistema';
COMMENT ON COLUMN menu_options.parent_id IS 'ID del menú padre (NULL si es menú raíz)';
COMMENT ON COLUMN menu_options.code IS 'Código único para identificar la opción programáticamente';
COMMENT ON COLUMN menu_options.route IS 'Ruta de navegación (NULL si tiene sub-menús)';

-- ============================================
-- PASO 2: Tabla menu_permissions (HU-002)
-- ============================================

CREATE TABLE menu_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_option_id UUID NOT NULL REFERENCES menu_options(id) ON DELETE CASCADE,
    role user_role NOT NULL,
    puede_ver BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_menu_permissions_unique ON menu_permissions(menu_option_id, role);
CREATE INDEX idx_menu_permissions_role ON menu_permissions(role);

COMMENT ON TABLE menu_permissions IS 'HU-002: Permisos de visualización de menús según rol';
COMMENT ON COLUMN menu_permissions.puede_ver IS 'Define si el rol puede ver esta opción de menú';

-- ============================================
-- PASO 3: Habilitar RLS
-- ============================================

ALTER TABLE menu_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_permissions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PASO 4: RLS Policies
-- ============================================

CREATE POLICY menu_options_select_policy ON menu_options
FOR SELECT
TO authenticated
USING (activo = true);

CREATE POLICY menu_permissions_select_policy ON menu_permissions
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY menu_options_admin_policy ON menu_options
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users
        WHERE auth.users.id = auth.uid()
        AND auth.users.raw_user_meta_data->>'rol' = 'ADMIN'
    )
);

CREATE POLICY menu_permissions_admin_policy ON menu_permissions
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users
        WHERE auth.users.id = auth.uid()
        AND auth.users.raw_user_meta_data->>'rol' = 'ADMIN'
    )
);

-- ============================================
-- PASO 5: Función get_menu_options (HU-002)
-- ============================================

CREATE OR REPLACE FUNCTION get_menu_options(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_role user_role;
    v_menu JSON;
BEGIN
    SELECT (raw_user_meta_data->>'rol')::user_role INTO v_user_role
    FROM auth.users
    WHERE id = p_user_id;

    IF v_user_role IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', 'user_not_found',
                'message', 'Usuario no encontrado o no autorizado',
                'hint', 'user_not_authorized'
            )
        );
    END IF;

    WITH RECURSIVE menu_tree AS (
        SELECT
            mo.id,
            mo.parent_id,
            mo.code,
            mo.label,
            mo.icon,
            mo.route,
            mo.orden,
            0 AS nivel
        FROM menu_options mo
        INNER JOIN menu_permissions mp ON mo.id = mp.menu_option_id
        WHERE mo.parent_id IS NULL
          AND mo.activo = true
          AND mp.role = v_user_role
          AND mp.puede_ver = true

        UNION ALL

        SELECT
            mo.id,
            mo.parent_id,
            mo.code,
            mo.label,
            mo.icon,
            mo.route,
            mo.orden,
            mt.nivel + 1
        FROM menu_options mo
        INNER JOIN menu_permissions mp ON mo.id = mp.menu_option_id
        INNER JOIN menu_tree mt ON mo.parent_id = mt.id
        WHERE mo.activo = true
          AND mp.role = v_user_role
          AND mp.puede_ver = true
    )
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'role', v_user_role,
            'menu', (
                SELECT json_agg(
                    json_build_object(
                        'id', code,
                        'label', label,
                        'icon', icon,
                        'route', route,
                        'children', (
                            SELECT json_agg(
                                json_build_object(
                                    'id', c.code,
                                    'label', c.label,
                                    'icon', c.icon,
                                    'route', c.route
                                )
                                ORDER BY c.orden
                            )
                            FROM menu_tree c
                            WHERE c.parent_id = mt.id
                        )
                    )
                    ORDER BY mt.orden
                )
                FROM menu_tree mt
                WHERE mt.parent_id IS NULL
            )
        )
    ) INTO v_menu;

    RETURN v_menu;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', 'unknown'
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_menu_options IS 'HU-002: Obtiene menú jerárquico según rol del usuario';

-- ============================================
-- PASO 6: Función update_sidebar_preference (HU-002)
-- ============================================

CREATE OR REPLACE FUNCTION update_sidebar_preference(
    p_user_id UUID,
    p_collapsed BOOLEAN
)
RETURNS JSON AS $$
BEGIN
    UPDATE auth.users
    SET raw_user_meta_data = jsonb_set(
        COALESCE(raw_user_meta_data, '{}'::jsonb),
        '{sidebar_collapsed}',
        to_jsonb(p_collapsed)
    ),
    updated_at = NOW()
    WHERE id = p_user_id;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', 'user_not_found',
                'message', 'Usuario no encontrado',
                'hint', 'user_not_found'
            )
        );
    END IF;

    RETURN json_build_object(
        'success', true,
        'data', json_build_object(
            'sidebar_collapsed', p_collapsed,
            'message', 'Preferencia actualizada'
        )
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', 'unknown'
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION update_sidebar_preference IS 'HU-002: Actualiza preferencia de sidebar colapsado del usuario';

-- ============================================
-- PASO 7: Función get_user_profile (HU-002)
-- ============================================

CREATE OR REPLACE FUNCTION get_user_profile(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user JSON;
BEGIN
    SELECT json_build_object(
        'success', true,
        'data', json_build_object(
            'id', id,
            'nombre_completo', raw_user_meta_data->>'nombre_completo',
            'email', email,
            'rol', raw_user_meta_data->>'rol',
            'avatar_url', raw_user_meta_data->>'avatar_url',
            'sidebar_collapsed', COALESCE((raw_user_meta_data->>'sidebar_collapsed')::boolean, false)
        )
    ) INTO v_user
    FROM auth.users
    WHERE id = p_user_id
      AND email_confirmed_at IS NOT NULL;

    IF v_user IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', 'user_not_found',
                'message', 'Usuario no encontrado',
                'hint', 'user_not_found'
            )
        );
    END IF;

    RETURN v_user;

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', 'unknown'
            )
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_user_profile IS 'HU-002: Obtiene perfil de usuario para header';

-- ============================================
-- PASO 8: Seed de Menús Completos (HU-002 Navegación)
-- Estructura completa según HU-002 CA-001, CA-002, CA-003
-- ============================================

DO $$
DECLARE
    -- Menús raíz
    v_dashboard_id UUID;
    v_punto_venta_id UUID;
    v_productos_id UUID;
    v_inventario_id UUID;
    v_ventas_id UUID;
    v_clientes_id UUID;
    v_reportes_id UUID;
    v_admin_id UUID;
    v_config_id UUID;

    -- Submenús Productos
    v_productos_catalogo_id UUID;
    v_productos_marcas_id UUID;
    v_productos_materiales_id UUID;
    v_productos_tipos_id UUID;
    v_productos_tallas_id UUID;
    v_productos_colores_id UUID;

    -- Submenús Inventario
    v_inventario_stock_id UUID;
    v_inventario_transferencias_id UUID;

    -- Submenús Ventas
    v_ventas_historial_id UUID;
    v_ventas_comisiones_id UUID;

    -- Submenús Clientes
    v_clientes_registrar_id UUID;
    v_clientes_base_id UUID;

    -- Submenús Reportes
    v_reportes_analisis_id UUID;
    v_reportes_dashboard_id UUID;

    -- Submenús Admin
    v_admin_usuarios_id UUID;
    v_admin_tiendas_id UUID;

    -- Submenús Configuración
    v_config_sistema_id UUID;
BEGIN
    -- ========================================
    -- 1. DASHBOARD (enlace directo)
    -- ========================================
    INSERT INTO menu_options (code, label, icon, route, orden, activo)
    VALUES ('dashboard', 'Dashboard', 'dashboard', '/dashboard', 10, true)
    ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, route = EXCLUDED.route, orden = EXCLUDED.orden, activo = EXCLUDED.activo
    RETURNING id INTO v_dashboard_id;

    -- ========================================
    -- 2. PUNTO DE VENTA (enlace directo)
    -- ========================================
    INSERT INTO menu_options (code, label, icon, route, orden, activo)
    VALUES ('punto-venta', 'Punto de Venta', 'point_of_sale', '/punto-venta', 20, true)
    ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, route = EXCLUDED.route, orden = EXCLUDED.orden, activo = EXCLUDED.activo
    RETURNING id INTO v_punto_venta_id;

    -- ========================================
    -- 3. PRODUCTOS (menú desplegable)
    -- ========================================
    INSERT INTO menu_options (code, label, icon, route, orden, activo)
    VALUES ('productos', 'Productos', 'inventory_2', null, 30, true)
    ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, route = EXCLUDED.route, orden = EXCLUDED.orden, activo = EXCLUDED.activo
    RETURNING id INTO v_productos_id;

    -- Submenú: Gestionar catálogo
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_productos_id, 'productos-catalogo', 'Gestionar catálogo', 'apps', '/productos', 5, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_productos_id
    RETURNING id INTO v_productos_catalogo_id;

    -- Submenú: Marcas
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_productos_id, 'productos-marcas', 'Marcas', 'local_offer', '/marcas', 10, true)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_productos_id
    RETURNING id INTO v_productos_marcas_id;

    -- Submenú: Materiales
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_productos_id, 'productos-materiales', 'Materiales', 'texture', '/materiales', 20, true)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_productos_id
    RETURNING id INTO v_productos_materiales_id;

    -- Submenú: Tipos (HU-003)
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_productos_id, 'productos-tipos', 'Tipos', 'category', '/tipos', 30, true)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_productos_id, activo = EXCLUDED.activo
    RETURNING id INTO v_productos_tipos_id;

    -- Submenú: Sistemas de tallas (HU-004)
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_productos_id, 'productos-tallas', 'Sistemas de tallas', 'straighten', '/sistemas-talla', 40, true)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_productos_id, activo = EXCLUDED.activo, route = EXCLUDED.route
    RETURNING id INTO v_productos_tallas_id;

    -- Submenú: Colores (HU-005)
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_productos_id, 'productos-colores', 'Colores', 'palette', '/colores', 50, true)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_productos_id, activo = EXCLUDED.activo, route = EXCLUDED.route
    RETURNING id INTO v_productos_colores_id;

    -- ========================================
    -- 4. INVENTARIO (menú desplegable)
    -- ========================================
    INSERT INTO menu_options (code, label, icon, route, orden, activo)
    VALUES ('inventario', 'Inventario', 'inventory', null, 40, true)
    ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, route = EXCLUDED.route, orden = EXCLUDED.orden, activo = EXCLUDED.activo
    RETURNING id INTO v_inventario_id;

    -- Submenú: Control de stock
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_inventario_id, 'inventario-stock', 'Control de stock', 'inventory', '/inventario/stock', 10, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_inventario_id
    RETURNING id INTO v_inventario_stock_id;

    -- Submenú: Transferencias
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_inventario_id, 'inventario-transferencias', 'Transferencias', 'swap_horiz', '/inventario/transferencias', 20, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_inventario_id
    RETURNING id INTO v_inventario_transferencias_id;

    -- ========================================
    -- 5. VENTAS (menú desplegable)
    -- ========================================
    INSERT INTO menu_options (code, label, icon, route, orden, activo)
    VALUES ('ventas', 'Ventas', 'attach_money', null, 50, true)
    ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, route = EXCLUDED.route, orden = EXCLUDED.orden, activo = EXCLUDED.activo
    RETURNING id INTO v_ventas_id;

    -- Submenú: Historial
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_ventas_id, 'ventas-historial', 'Historial de ventas', 'history', '/ventas/historial', 10, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_ventas_id
    RETURNING id INTO v_ventas_historial_id;

    -- Submenú: Comisiones
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_ventas_id, 'ventas-comisiones', 'Comisiones', 'payments', '/ventas/comisiones', 20, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_ventas_id
    RETURNING id INTO v_ventas_comisiones_id;

    -- ========================================
    -- 6. CLIENTES (menú desplegable)
    -- ========================================
    INSERT INTO menu_options (code, label, icon, route, orden, activo)
    VALUES ('clientes', 'Clientes', 'people', null, 60, true)
    ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, route = EXCLUDED.route, orden = EXCLUDED.orden, activo = EXCLUDED.activo
    RETURNING id INTO v_clientes_id;

    -- Submenú: Registrar cliente
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_clientes_id, 'clientes-registrar', 'Registrar cliente', 'person_add', '/clientes/registrar', 10, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_clientes_id
    RETURNING id INTO v_clientes_registrar_id;

    -- Submenú: Base de datos
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_clientes_id, 'clientes-base', 'Base de datos de clientes', 'people', '/clientes', 20, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_clientes_id
    RETURNING id INTO v_clientes_base_id;

    -- ========================================
    -- 7. REPORTES (menú desplegable)
    -- ========================================
    INSERT INTO menu_options (code, label, icon, route, orden, activo)
    VALUES ('reportes', 'Reportes', 'assessment', null, 70, true)
    ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, route = EXCLUDED.route, orden = EXCLUDED.orden, activo = EXCLUDED.activo
    RETURNING id INTO v_reportes_id;

    -- Submenú: Análisis y métricas
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_reportes_id, 'reportes-analisis', 'Análisis y métricas', 'analytics', '/reportes/analisis', 10, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_reportes_id
    RETURNING id INTO v_reportes_analisis_id;

    -- Submenú: Dashboard de tienda
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_reportes_id, 'reportes-dashboard', 'Dashboard de tienda', 'store', '/reportes/dashboard', 20, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_reportes_id
    RETURNING id INTO v_reportes_dashboard_id;

    -- ========================================
    -- 8. ADMIN (menú desplegable - solo ADMIN)
    -- ========================================
    INSERT INTO menu_options (code, label, icon, route, orden, activo)
    VALUES ('admin', 'Admin', 'admin_panel_settings', null, 80, true)
    ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, route = EXCLUDED.route, orden = EXCLUDED.orden, activo = EXCLUDED.activo
    RETURNING id INTO v_admin_id;

    -- Submenú: Gestión de usuarios
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_admin_id, 'admin-usuarios', 'Gestión de usuarios', 'manage_accounts', '/admin/usuarios', 10, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_admin_id
    RETURNING id INTO v_admin_usuarios_id;

    -- Submenú: Gestión de tiendas
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_admin_id, 'admin-tiendas', 'Gestión de tiendas', 'store', '/admin/tiendas', 20, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_admin_id
    RETURNING id INTO v_admin_tiendas_id;

    -- ========================================
    -- 9. CONFIGURACIÓN (menú desplegable)
    -- ========================================
    INSERT INTO menu_options (code, label, icon, route, orden, activo)
    VALUES ('configuracion', 'Configuración', 'settings', null, 90, true)
    ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, icon = EXCLUDED.icon, route = EXCLUDED.route, orden = EXCLUDED.orden, activo = EXCLUDED.activo
    RETURNING id INTO v_config_id;

    -- Submenú: Ajustes del sistema
    INSERT INTO menu_options (parent_id, code, label, icon, route, orden, activo)
    VALUES (v_config_id, 'configuracion-sistema', 'Ajustes del sistema', 'tune', '/configuracion/sistema', 10, false)
    ON CONFLICT (code) DO UPDATE SET parent_id = v_config_id
    RETURNING id INTO v_config_sistema_id;

    -- ========================================
    -- PERMISOS POR ROL
    -- ========================================

    -- ADMIN: todos los menús
    INSERT INTO menu_permissions (menu_option_id, role, puede_ver) VALUES
        (v_dashboard_id, 'ADMIN', true),
        (v_punto_venta_id, 'ADMIN', true),
        (v_productos_id, 'ADMIN', true),
        (v_productos_catalogo_id, 'ADMIN', true),
        (v_productos_marcas_id, 'ADMIN', true),
        (v_productos_materiales_id, 'ADMIN', true),
        (v_productos_tipos_id, 'ADMIN', true),
        (v_productos_tallas_id, 'ADMIN', true),
        (v_productos_colores_id, 'ADMIN', true),
        (v_inventario_id, 'ADMIN', true),
        (v_inventario_stock_id, 'ADMIN', true),
        (v_inventario_transferencias_id, 'ADMIN', true),
        (v_ventas_id, 'ADMIN', true),
        (v_ventas_historial_id, 'ADMIN', true),
        (v_ventas_comisiones_id, 'ADMIN', true),
        (v_clientes_id, 'ADMIN', true),
        (v_clientes_registrar_id, 'ADMIN', true),
        (v_clientes_base_id, 'ADMIN', true),
        (v_reportes_id, 'ADMIN', true),
        (v_reportes_analisis_id, 'ADMIN', true),
        (v_reportes_dashboard_id, 'ADMIN', true),
        (v_admin_id, 'ADMIN', true),
        (v_admin_usuarios_id, 'ADMIN', true),
        (v_admin_tiendas_id, 'ADMIN', true),
        (v_config_id, 'ADMIN', true),
        (v_config_sistema_id, 'ADMIN', true)
    ON CONFLICT (menu_option_id, role) DO NOTHING;

    -- GERENTE: dashboard, punto venta, productos (solo catálogo), inventario, ventas, clientes, reportes, configuración
    INSERT INTO menu_permissions (menu_option_id, role, puede_ver) VALUES
        (v_dashboard_id, 'GERENTE', true),
        (v_punto_venta_id, 'GERENTE', true),
        (v_productos_id, 'GERENTE', true),
        (v_productos_catalogo_id, 'GERENTE', true),
        (v_productos_marcas_id, 'GERENTE', false),
        (v_productos_materiales_id, 'GERENTE', false),
        (v_productos_tipos_id, 'GERENTE', false),
        (v_productos_tallas_id, 'GERENTE', false),
        (v_productos_colores_id, 'GERENTE', false),
        (v_inventario_id, 'GERENTE', true),
        (v_inventario_stock_id, 'GERENTE', true),
        (v_inventario_transferencias_id, 'GERENTE', true),
        (v_ventas_id, 'GERENTE', true),
        (v_ventas_historial_id, 'GERENTE', true),
        (v_ventas_comisiones_id, 'GERENTE', true),
        (v_clientes_id, 'GERENTE', true),
        (v_clientes_registrar_id, 'GERENTE', true),
        (v_clientes_base_id, 'GERENTE', true),
        (v_reportes_id, 'GERENTE', true),
        (v_reportes_analisis_id, 'GERENTE', true),
        (v_reportes_dashboard_id, 'GERENTE', true),
        (v_admin_id, 'GERENTE', false),
        (v_config_id, 'GERENTE', true),
        (v_config_sistema_id, 'GERENTE', true)
    ON CONFLICT (menu_option_id, role) DO NOTHING;

    -- VENDEDOR: dashboard, punto venta, productos (solo catálogo), inventario (solo lectura), ventas (mis comisiones), clientes, reportes
    INSERT INTO menu_permissions (menu_option_id, role, puede_ver) VALUES
        (v_dashboard_id, 'VENDEDOR', true),
        (v_punto_venta_id, 'VENDEDOR', true),
        (v_productos_id, 'VENDEDOR', true),
        (v_productos_catalogo_id, 'VENDEDOR', true),
        (v_productos_marcas_id, 'VENDEDOR', false),
        (v_productos_materiales_id, 'VENDEDOR', false),
        (v_productos_tipos_id, 'VENDEDOR', false),
        (v_productos_tallas_id, 'VENDEDOR', false),
        (v_productos_colores_id, 'VENDEDOR', false),
        (v_inventario_id, 'VENDEDOR', true),
        (v_inventario_stock_id, 'VENDEDOR', true),
        (v_ventas_id, 'VENDEDOR', true),
        (v_ventas_historial_id, 'VENDEDOR', true),
        (v_ventas_comisiones_id, 'VENDEDOR', true),
        (v_clientes_id, 'VENDEDOR', true),
        (v_clientes_registrar_id, 'VENDEDOR', true),
        (v_clientes_base_id, 'VENDEDOR', true),
        (v_reportes_id, 'VENDEDOR', true),
        (v_reportes_analisis_id, 'VENDEDOR', true),
        (v_admin_id, 'VENDEDOR', false),
        (v_config_id, 'VENDEDOR', false)
    ON CONFLICT (menu_option_id, role) DO NOTHING;

    RAISE NOTICE 'Menús completos creados exitosamente (9 menús raíz + 16 submenús)';
END $$;

COMMIT;