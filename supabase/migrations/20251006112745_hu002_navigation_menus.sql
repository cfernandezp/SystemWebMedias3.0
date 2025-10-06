-- Migration: E003-HU-002 - Sistema de Navegación con Menús Desplegables
-- Fecha: 2025-10-06
-- Razón: Implementar sistema de menús dinámicos adaptados por rol de usuario
-- Impacto: Crea tablas menu_options, menu_permissions, funciones PostgreSQL y RLS policies

BEGIN;

-- ============================================
-- PASO 1: Crear tabla menu_options
-- ============================================

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

-- ============================================
-- PASO 2: Crear tabla menu_permissions
-- ============================================

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

-- ============================================
-- PASO 3: Verificar y agregar columna sidebar_collapsed a auth.users
-- ============================================

-- Nota: Agregamos a auth.users en raw_user_meta_data (no en tabla custom users)
-- La preferencia se guarda en el metadata del usuario de Supabase Auth

-- ============================================
-- PASO 4: Función get_menu_options
-- ============================================

CREATE OR REPLACE FUNCTION get_menu_options(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_role user_role;
    v_menu JSON;
BEGIN
    -- Obtener rol del usuario desde auth.users metadata
    SELECT (raw_user_meta_data->>'rol')::user_role INTO v_user_role
    FROM auth.users
    WHERE id = p_user_id;

    -- Si usuario no existe o no tiene rol
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

-- ============================================
-- PASO 5: Función update_sidebar_preference
-- ============================================

CREATE OR REPLACE FUNCTION update_sidebar_preference(
    p_user_id UUID,
    p_collapsed BOOLEAN
)
RETURNS JSON AS $$
BEGIN
    -- Actualizar preferencia en metadata
    UPDATE auth.users
    SET raw_user_meta_data = jsonb_set(
        COALESCE(raw_user_meta_data, '{}'::jsonb),
        '{sidebar_collapsed}',
        to_jsonb(p_collapsed)
    ),
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

-- ============================================
-- PASO 6: Función get_user_profile
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
      AND email_confirmed_at IS NOT NULL;  -- Usuario confirmado

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
-- PASO 7: Habilitar Row Level Security
-- ============================================

ALTER TABLE menu_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_permissions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PASO 8: Crear RLS Policies
-- ============================================

-- Policy: Solo lectura para usuarios autenticados en menu_options
CREATE POLICY menu_options_select_policy ON menu_options
FOR SELECT
TO authenticated
USING (activo = true);

-- Policy: Solo lectura para usuarios autenticados en menu_permissions
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
-- PASO 9: Trigger para updated_at en menu_options
-- ============================================

CREATE TRIGGER update_menu_options_updated_at
    BEFORE UPDATE ON menu_options
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

COMMIT;

-- ============================================
-- RESUMEN DEL MIGRATION
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'HU-002: Sistema de Navegación - COMPLETADO';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Tablas creadas:';
    RAISE NOTICE '  - menu_options';
    RAISE NOTICE '  - menu_permissions';
    RAISE NOTICE '';
    RAISE NOTICE 'Funciones creadas:';
    RAISE NOTICE '  - get_menu_options(p_user_id UUID)';
    RAISE NOTICE '  - update_sidebar_preference(p_user_id UUID, p_collapsed BOOLEAN)';
    RAISE NOTICE '  - get_user_profile(p_user_id UUID)';
    RAISE NOTICE '';
    RAISE NOTICE 'RLS Policies aplicadas: 4';
    RAISE NOTICE '';
    RAISE NOTICE 'Próximo paso: Ejecutar seed data de menús';
    RAISE NOTICE '========================================';
END $$;
