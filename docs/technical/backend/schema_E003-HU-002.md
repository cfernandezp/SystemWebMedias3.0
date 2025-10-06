# Schema Backend - E003-HU-002: Sistema de Navegación con Menús Desplegables

**Historia de Usuario**: E003-HU-002
**Fecha creación**: 2025-10-06
**Autor**: @web-architect-expert
**Estado**: ✅ Implementado (2025-10-06)
**Migration**: `20251006112745_hu002_navigation_menus.sql`

---

## 🎯 OBJETIVO

Diseñar el schema de base de datos para soportar un sistema de navegación dinámico con menús adaptados por rol de usuario.

---

## 📊 TABLAS REQUERIDAS

### 1. `menu_options` - Opciones de Menú Maestras

```sql
CREATE TABLE menu_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES menu_options(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,                    -- Código único: 'dashboard', 'productos', 'productos-catalogo'
    label TEXT NOT NULL,                          -- Label visible: 'Dashboard', 'Productos', 'Gestionar catálogo'
    icon TEXT,                                    -- Nombre del ícono: 'dashboard', 'inventory', 'people'
    route TEXT,                                   -- Ruta Flutter: '/dashboard', '/products', null si tiene children
    orden INTEGER NOT NULL DEFAULT 0,             -- Orden de visualización
    activo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_menu_options_parent_id ON menu_options(parent_id);
CREATE INDEX idx_menu_options_activo ON menu_options(activo);
CREATE INDEX idx_menu_options_code ON menu_options(code);

-- Comentarios
COMMENT ON TABLE menu_options IS 'HU-002: Catálogo maestro de opciones de menú del sistema';
COMMENT ON COLUMN menu_options.parent_id IS 'ID del menú padre (NULL si es menú raíz)';
COMMENT ON COLUMN menu_options.code IS 'Código único para identificar la opción programáticamente';
COMMENT ON COLUMN menu_options.route IS 'Ruta de navegación (NULL si tiene sub-menús)';
COMMENT ON COLUMN menu_options.orden IS 'Orden de visualización en el menú';
```

---

### 2. `menu_permissions` - Permisos de Menú por Rol

```sql
CREATE TABLE menu_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_option_id UUID NOT NULL REFERENCES menu_options(id) ON DELETE CASCADE,
    role user_role NOT NULL,                      -- ENUM: 'ADMIN', 'GERENTE', 'VENDEDOR'
    puede_ver BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE UNIQUE INDEX idx_menu_permissions_unique ON menu_permissions(menu_option_id, role);
CREATE INDEX idx_menu_permissions_role ON menu_permissions(role);

-- Comentarios
COMMENT ON TABLE menu_permissions IS 'HU-002: Permisos de visualización de menús según rol';
COMMENT ON COLUMN menu_permissions.puede_ver IS 'Define si el rol puede ver esta opción de menú';
```

---

### 3. Extensión de `users` - Preferencias de Navegación

```sql
-- Agregar columnas a tabla existente `users`
ALTER TABLE users
ADD COLUMN sidebar_collapsed BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN users.sidebar_collapsed IS 'HU-002: Preferencia de usuario para sidebar colapsado';
```

---

## 🔄 FUNCIONES POSTGRESQL

### 1. `get_menu_options(p_user_id UUID)` - Obtener Menú por Usuario

```sql
CREATE OR REPLACE FUNCTION get_menu_options(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_role user_role;
    v_menu JSON;
BEGIN
    -- Obtener rol del usuario
    SELECT rol INTO v_user_role
    FROM users
    WHERE id = p_user_id AND estado = 'APROBADO';

    -- Si usuario no existe o no está aprobado
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

    -- Construir menú jerárquico según permisos del rol
    WITH RECURSIVE menu_tree AS (
        -- Nivel 1: Opciones raíz
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

        -- Niveles siguientes: Sub-opciones
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
```

---

### 2. `update_sidebar_preference(p_user_id UUID, p_collapsed BOOLEAN)`

```sql
CREATE OR REPLACE FUNCTION update_sidebar_preference(
    p_user_id UUID,
    p_collapsed BOOLEAN
)
RETURNS JSON AS $$
BEGIN
    -- Actualizar preferencia
    UPDATE users
    SET sidebar_collapsed = p_collapsed,
        updated_at = NOW()
    WHERE id = p_user_id;

    -- Verificar si se actualizó
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
```

---

## 🌱 SEED DATA - Menús Iniciales

```sql
-- seed_menu_options.sql

-- Limpiar datos existentes
TRUNCATE menu_options CASCADE;

-- ====================================
-- NIVEL 1: MENÚS RAÍZ
-- ====================================

-- Dashboard
INSERT INTO menu_options (id, code, label, icon, route, orden)
VALUES
('11111111-1111-1111-1111-111111111111', 'dashboard', 'Dashboard', 'dashboard', '/dashboard', 1);

-- Punto de Venta
INSERT INTO menu_options (id, code, label, icon, route, orden)
VALUES
('22222222-2222-2222-2222-222222222222', 'pos', 'Punto de Venta', 'point_of_sale', '/pos', 2);

-- Productos
INSERT INTO menu_options (id, code, label, icon, route, orden)
VALUES
('33333333-3333-3333-3333-333333333333', 'productos', 'Productos', 'inventory', NULL, 3);

-- Inventario
INSERT INTO menu_options (id, code, label, icon, route, orden)
VALUES
('44444444-4444-4444-4444-444444444444', 'inventario', 'Inventario', 'warehouse', NULL, 4);

-- Ventas
INSERT INTO menu_options (id, code, label, icon, route, orden)
VALUES
('55555555-5555-5555-5555-555555555555', 'ventas', 'Ventas', 'shopping_cart', NULL, 5);

-- Personas
INSERT INTO menu_options (id, code, label, icon, route, orden)
VALUES
('66666666-6666-6666-6666-666666666666', 'personas', 'Personas', 'people', NULL, 6);

-- Clientes (para Vendedor)
INSERT INTO menu_options (id, code, label, icon, route, orden)
VALUES
('77777777-7777-7777-7777-777777777777', 'clientes', 'Clientes', 'people', NULL, 6);

-- Reportes
INSERT INTO menu_options (id, code, label, icon, route, orden)
VALUES
('88888888-8888-8888-8888-888888888888', 'reportes', 'Reportes', 'bar_chart', NULL, 7);

-- Admin
INSERT INTO menu_options (id, code, label, icon, route, orden)
VALUES
('99999999-9999-9999-9999-999999999999', 'admin', 'Admin', 'admin_panel_settings', NULL, 8);

-- Configuración
INSERT INTO menu_options (id, code, label, icon, route, orden)
VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'configuracion', 'Configuración', 'settings', NULL, 9);

-- ====================================
-- NIVEL 2: SUB-MENÚS - PRODUCTOS
-- ====================================

INSERT INTO menu_options (id, parent_id, code, label, route, orden)
VALUES
('33333333-0001-0001-0001-000000000001', '33333333-3333-3333-3333-333333333333', 'productos-catalogo', 'Gestionar catálogo', '/products', 1),
('33333333-0002-0002-0002-000000000002', '33333333-3333-3333-3333-333333333333', 'productos-marcas', 'Marcas', '/brands', 2),
('33333333-0003-0003-0003-000000000003', '33333333-3333-3333-3333-333333333333', 'productos-materiales', 'Materiales', '/materials', 3),
('33333333-0004-0004-0004-000000000004', '33333333-3333-3333-3333-333333333333', 'productos-tipos', 'Tipos', '/product-types', 4),
('33333333-0005-0005-0005-000000000005', '33333333-3333-3333-3333-333333333333', 'productos-tallas', 'Sistemas de tallas', '/size-systems', 5);

-- ====================================
-- NIVEL 2: SUB-MENÚS - INVENTARIO
-- ====================================

INSERT INTO menu_options (id, parent_id, code, label, route, orden)
VALUES
('44444444-0001-0001-0001-000000000001', '44444444-4444-4444-4444-444444444444', 'inventario-stock', 'Control de stock', '/inventory', 1),
('44444444-0002-0002-0002-000000000002', '44444444-4444-4444-4444-444444444444', 'inventario-transferencias', 'Transferencias', '/inventory/transfers', 2);

-- ====================================
-- NIVEL 2: SUB-MENÚS - VENTAS
-- ====================================

INSERT INTO menu_options (id, parent_id, code, label, route, orden)
VALUES
('55555555-0001-0001-0001-000000000001', '55555555-5555-5555-5555-555555555555', 'ventas-historial', 'Historial de ventas', '/sales', 1),
('55555555-0002-0002-0002-000000000002', '55555555-5555-5555-5555-555555555555', 'ventas-comisiones', 'Comisiones', '/commissions', 2),
('55555555-0003-0003-0003-000000000003', '55555555-5555-5555-5555-555555555555', 'ventas-mis-comisiones', 'Mis comisiones', '/my-commissions', 3);

-- ====================================
-- NIVEL 2: SUB-MENÚS - PERSONAS
-- ====================================

INSERT INTO menu_options (id, parent_id, code, label, route, orden)
VALUES
('66666666-0001-0001-0001-000000000001', '66666666-6666-6666-6666-666666666666', 'personas-registrar', 'Registrar persona/documento', '/personas/register', 1),
('66666666-0002-0002-0002-000000000002', '66666666-6666-6666-6666-666666666666', 'personas-todas', 'Base de datos completa', '/personas', 2),
('66666666-0003-0003-0003-000000000003', '66666666-6666-6666-6666-666666666666', 'personas-clientes', 'Ver clientes', '/personas?rol=cliente', 3),
('66666666-0004-0004-0004-000000000004', '66666666-6666-6666-6666-666666666666', 'personas-proveedores', 'Ver proveedores', '/personas?rol=proveedor', 4),
('66666666-0005-0005-0005-000000000005', '66666666-6666-6666-6666-666666666666', 'personas-transportistas', 'Ver transportistas', '/personas?rol=transportista', 5);

-- ====================================
-- NIVEL 2: SUB-MENÚS - CLIENTES (Vendedor)
-- ====================================

INSERT INTO menu_options (id, parent_id, code, label, route, orden)
VALUES
('77777777-0001-0001-0001-000000000001', '77777777-7777-7777-7777-777777777777', 'clientes-registrar', 'Registrar cliente', '/clientes/register', 1),
('77777777-0002-0002-0002-000000000002', '77777777-7777-7777-7777-777777777777', 'clientes-base', 'Base de datos de clientes', '/clientes', 2);

-- ====================================
-- NIVEL 2: SUB-MENÚS - REPORTES
-- ====================================

INSERT INTO menu_options (id, parent_id, code, label, route, orden)
VALUES
('88888888-0001-0001-0001-000000000001', '88888888-8888-8888-8888-888888888888', 'reportes-analisis', 'Análisis y métricas', '/reports/analytics', 1),
('88888888-0002-0002-0002-000000000002', '88888888-8888-8888-8888-888888888888', 'reportes-dashboard', 'Dashboard de tienda', '/reports/store-dashboard', 2),
('88888888-0003-0003-0003-000000000003', '88888888-8888-8888-8888-888888888888', 'reportes-comparativas', 'Comparativas entre tiendas', '/reports/store-comparison', 3);

-- ====================================
-- NIVEL 2: SUB-MENÚS - ADMIN
-- ====================================

INSERT INTO menu_options (id, parent_id, code, label, route, orden)
VALUES
('99999999-0001-0001-0001-000000000001', '99999999-9999-9999-9999-999999999999', 'admin-usuarios', 'Gestión de usuarios', '/admin/users', 1),
('99999999-0002-0002-0002-000000000002', '99999999-9999-9999-9999-999999999999', 'admin-tiendas', 'Gestión de tiendas', '/admin/stores', 2);

-- ====================================
-- NIVEL 2: SUB-MENÚS - CONFIGURACIÓN
-- ====================================

INSERT INTO menu_options (id, parent_id, code, label, route, orden)
VALUES
('aaaaaaaa-0001-0001-0001-000000000001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'config-ajustes', 'Ajustes del sistema', '/settings', 1);

-- ====================================
-- PERMISOS POR ROL
-- ====================================

-- VENDEDOR: Dashboard, POS, Productos (solo catálogo), Inventario (solo lectura), Ventas (historial + mis comisiones), Clientes, Reportes (análisis)
INSERT INTO menu_permissions (menu_option_id, role) VALUES
('11111111-1111-1111-1111-111111111111', 'VENDEDOR'), -- Dashboard
('22222222-2222-2222-2222-222222222222', 'VENDEDOR'), -- POS
('33333333-3333-3333-3333-333333333333', 'VENDEDOR'), -- Productos
('33333333-0001-0001-0001-000000000001', 'VENDEDOR'), -- Productos > Catálogo
('44444444-4444-4444-4444-444444444444', 'VENDEDOR'), -- Inventario
('44444444-0001-0001-0001-000000000001', 'VENDEDOR'), -- Inventario > Stock (solo lectura)
('55555555-5555-5555-5555-555555555555', 'VENDEDOR'), -- Ventas
('55555555-0001-0001-0001-000000000001', 'VENDEDOR'), -- Ventas > Historial
('55555555-0003-0003-0003-000000000003', 'VENDEDOR'), -- Ventas > Mis comisiones
('77777777-7777-7777-7777-777777777777', 'VENDEDOR'), -- Clientes
('77777777-0001-0001-0001-000000000001', 'VENDEDOR'), -- Clientes > Registrar
('77777777-0002-0002-0002-000000000002', 'VENDEDOR'), -- Clientes > Base de datos
('88888888-8888-8888-8888-888888888888', 'VENDEDOR'), -- Reportes
('88888888-0001-0001-0001-000000000001', 'VENDEDOR'); -- Reportes > Análisis

-- GERENTE: Todo lo de Vendedor + Personas (clientes + proveedores) + Transferencias + Comisiones del equipo + Dashboard de tienda + Configuración
INSERT INTO menu_permissions (menu_option_id, role) VALUES
('11111111-1111-1111-1111-111111111111', 'GERENTE'), -- Dashboard
('22222222-2222-2222-2222-222222222222', 'GERENTE'), -- POS
('33333333-3333-3333-3333-333333333333', 'GERENTE'), -- Productos
('33333333-0001-0001-0001-000000000001', 'GERENTE'), -- Productos > Catálogo
('44444444-4444-4444-4444-444444444444', 'GERENTE'), -- Inventario
('44444444-0001-0001-0001-000000000001', 'GERENTE'), -- Inventario > Stock
('44444444-0002-0002-0002-000000000002', 'GERENTE'), -- Inventario > Transferencias
('55555555-5555-5555-5555-555555555555', 'GERENTE'), -- Ventas
('55555555-0001-0001-0001-000000000001', 'GERENTE'), -- Ventas > Historial
('55555555-0002-0002-0002-000000000002', 'GERENTE'), -- Ventas > Comisiones del equipo
('66666666-6666-6666-6666-666666666666', 'GERENTE'), -- Personas
('66666666-0001-0001-0001-000000000001', 'GERENTE'), -- Personas > Registrar
('66666666-0003-0003-0003-000000000003', 'GERENTE'), -- Personas > Clientes
('66666666-0004-0004-0004-000000000004', 'GERENTE'), -- Personas > Proveedores
('88888888-8888-8888-8888-888888888888', 'GERENTE'), -- Reportes
('88888888-0001-0001-0001-000000000001', 'GERENTE'), -- Reportes > Análisis
('88888888-0002-0002-0002-000000000002', 'GERENTE'), -- Reportes > Dashboard de tienda
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'GERENTE'), -- Configuración
('aaaaaaaa-0001-0001-0001-000000000001', 'GERENTE'); -- Configuración > Ajustes

-- ADMIN: Acceso total
INSERT INTO menu_permissions (menu_option_id, role) VALUES
('11111111-1111-1111-1111-111111111111', 'ADMIN'), -- Dashboard
('22222222-2222-2222-2222-222222222222', 'ADMIN'), -- POS
('33333333-3333-3333-3333-333333333333', 'ADMIN'), -- Productos
('33333333-0001-0001-0001-000000000001', 'ADMIN'), -- Productos > Catálogo
('33333333-0002-0002-0002-000000000002', 'ADMIN'), -- Productos > Marcas
('33333333-0003-0003-0003-000000000003', 'ADMIN'), -- Productos > Materiales
('33333333-0004-0004-0004-000000000004', 'ADMIN'), -- Productos > Tipos
('33333333-0005-0005-0005-000000000005', 'ADMIN'), -- Productos > Tallas
('44444444-4444-4444-4444-444444444444', 'ADMIN'), -- Inventario
('44444444-0001-0001-0001-000000000001', 'ADMIN'), -- Inventario > Stock (todas las tiendas)
('44444444-0002-0002-0002-000000000002', 'ADMIN'), -- Inventario > Transferencias
('55555555-5555-5555-5555-555555555555', 'ADMIN'), -- Ventas
('55555555-0001-0001-0001-000000000001', 'ADMIN'), -- Ventas > Historial consolidado
('55555555-0002-0002-0002-000000000002', 'ADMIN'), -- Ventas > Comisiones globales
('66666666-6666-6666-6666-666666666666', 'ADMIN'), -- Personas
('66666666-0001-0001-0001-000000000001', 'ADMIN'), -- Personas > Registrar
('66666666-0002-0002-0002-000000000002', 'ADMIN'), -- Personas > Base completa
('66666666-0003-0003-0003-000000000003', 'ADMIN'), -- Personas > Clientes
('66666666-0004-0004-0004-000000000004', 'ADMIN'), -- Personas > Proveedores
('66666666-0005-0005-0005-000000000005', 'ADMIN'), -- Personas > Transportistas
('88888888-8888-8888-8888-888888888888', 'ADMIN'), -- Reportes
('88888888-0001-0001-0001-000000000001', 'ADMIN'), -- Reportes > Análisis global
('88888888-0003-0003-0003-000000000003', 'ADMIN'), -- Reportes > Comparativas
('99999999-9999-9999-9999-999999999999', 'ADMIN'), -- Admin
('99999999-0001-0001-0001-000000000001', 'ADMIN'), -- Admin > Usuarios
('99999999-0002-0002-0002-000000000002', 'ADMIN'), -- Admin > Tiendas
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ADMIN'), -- Configuración
('aaaaaaaa-0001-0001-0001-000000000001', 'ADMIN'); -- Configuración > Ajustes
```

---

## 🔒 ROW LEVEL SECURITY (RLS)

```sql
-- Habilitar RLS
ALTER TABLE menu_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_permissions ENABLE ROW LEVEL SECURITY;

-- Policy: Solo lectura para usuarios autenticados
CREATE POLICY menu_options_select_policy ON menu_options
FOR SELECT
TO authenticated
USING (activo = true);

CREATE POLICY menu_permissions_select_policy ON menu_permissions
FOR SELECT
TO authenticated
USING (true);

-- Policy: Solo ADMIN puede modificar menús
CREATE POLICY menu_options_admin_policy ON menu_options
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid()
        AND users.rol = 'ADMIN'
    )
);

CREATE POLICY menu_permissions_admin_policy ON menu_permissions
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid()
        AND users.rol = 'ADMIN'
    )
);
```

---

## 📋 CHECKLIST DE IMPLEMENTACIÓN

- [ ] Crear tablas `menu_options` y `menu_permissions`
- [ ] Agregar columna `sidebar_collapsed` a `users`
- [ ] Implementar función `get_menu_options()`
- [ ] Implementar función `update_sidebar_preference()`
- [ ] Aplicar seed data de menús
- [ ] Configurar RLS policies
- [ ] Probar función con cada rol (VENDEDOR, GERENTE, ADMIN)
- [ ] Validar que menú jerárquico se construye correctamente

---

**Próximos pasos**: Documentar APIs en `apis_E003-HU-002.md`