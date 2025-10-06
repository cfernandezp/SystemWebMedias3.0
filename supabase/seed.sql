-- ============================================
-- Supabase Seed File - SystemWebMedias 3.0
-- Data de prueba persistente para desarrollo local
-- Se ejecuta automáticamente después de cada 'npx supabase db reset'
-- ============================================

-- ============================================
-- CREDENCIALES DE ACCESO
-- ============================================
-- ADMIN:     admin@test.com    / asdasd211
-- GERENTE:   gerente@test.com  / asdasd211
-- VENDEDOR:  vendedor@test.com / asdasd211
-- ============================================

BEGIN;

-- ============================================
-- 1. CREAR TIENDAS
-- ============================================

INSERT INTO tiendas (id, nombre, direccion, meta_mensual, activa) VALUES
('11111111-1111-1111-1111-111111111111', 'Tienda Centro', 'Av. Principal 123', 50000.00, true),
('22222222-2222-2222-2222-222222222222', 'Tienda Norte', 'Calle Comercio 456', 40000.00, true),
('33333333-3333-3333-3333-333333333333', 'Tienda Sur', 'Blvd. Sur 789', 35000.00, true);

-- ============================================
-- 2. CREAR PRODUCTOS (30 productos con stock variado)
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
('Medias Yoga Multicolor', 'Medias para yoga y pilates', 16.50, 42, 100, true);

-- ============================================
-- 3. CREAR CLIENTES (50 clientes)
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
('Iván Rubio', 'ivan.rubio@example.com', '555-0150', true);

COMMIT;

-- ============================================
-- 4. CREAR USUARIOS DE AUTENTICACIÓN
-- ============================================
-- NOTA: Esta sección crea usuarios directamente en auth.users y auth.identities
-- Solo funciona en desarrollo local con Supabase local

DO $$
DECLARE
    -- UUIDs fijos para usuarios de prueba (facilita referencias)
    v_admin_id UUID := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
    v_gerente_id UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
    v_vendedor_id UUID := 'cccccccc-cccc-cccc-cccc-cccccccccccc';

    v_encrypted_pass TEXT;
BEGIN
    -- Generar contraseña encriptada para 'asdasd211' usando bcrypt
    v_encrypted_pass := crypt('asdasd211', gen_salt('bf'));

    -- ========================================
    -- 1. USUARIO ADMIN
    -- ========================================
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = v_admin_id) THEN
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_user_meta_data,
            raw_app_meta_data,
            created_at,
            updated_at,
            aud,
            role
        ) VALUES (
            v_admin_id,
            '00000000-0000-0000-0000-000000000000',
            'admin@test.com',
            v_encrypted_pass,
            NOW(),
            jsonb_build_object(
                'rol', 'ADMIN',
                'nombre_completo', 'Administrador Principal',
                'email', 'admin@test.com'
            ),
            jsonb_build_object(
                'provider', 'email',
                'providers', ARRAY['email']
            ),
            NOW(),
            NOW(),
            'authenticated',
            'authenticated'
        );

        RAISE NOTICE 'Usuario ADMIN creado: admin@test.com';
    END IF;

    -- ========================================
    -- 2. USUARIO GERENTE
    -- ========================================
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = v_gerente_id) THEN
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_user_meta_data,
            raw_app_meta_data,
            created_at,
            updated_at,
            aud,
            role
        ) VALUES (
            v_gerente_id,
            '00000000-0000-0000-0000-000000000000',
            'gerente@test.com',
            v_encrypted_pass,
            NOW(),
            jsonb_build_object(
                'rol', 'GERENTE',
                'nombre_completo', 'Gerente Tienda Centro',
                'email', 'gerente@test.com',
                'tienda_id', '11111111-1111-1111-1111-111111111111'
            ),
            jsonb_build_object(
                'provider', 'email',
                'providers', ARRAY['email']
            ),
            NOW(),
            NOW(),
            'authenticated',
            'authenticated'
        );

        RAISE NOTICE 'Usuario GERENTE creado: gerente@test.com';
    END IF;

    -- ========================================
    -- 3. USUARIO VENDEDOR
    -- ========================================
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = v_vendedor_id) THEN
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_user_meta_data,
            raw_app_meta_data,
            created_at,
            updated_at,
            aud,
            role
        ) VALUES (
            v_vendedor_id,
            '00000000-0000-0000-0000-000000000000',
            'vendedor@test.com',
            v_encrypted_pass,
            NOW(),
            jsonb_build_object(
                'rol', 'VENDEDOR',
                'nombre_completo', 'Vendedor Tienda Centro',
                'email', 'vendedor@test.com',
                'tienda_id', '11111111-1111-1111-1111-111111111111'
            ),
            jsonb_build_object(
                'provider', 'email',
                'providers', ARRAY['email']
            ),
            NOW(),
            NOW(),
            'authenticated',
            'authenticated'
        );

        RAISE NOTICE 'Usuario VENDEDOR creado: vendedor@test.com';
    END IF;

    -- ========================================
    -- CREAR IDENTIDADES PARA LOGIN
    -- ========================================

    -- Identity para ADMIN
    IF NOT EXISTS (SELECT 1 FROM auth.identities WHERE provider_id = v_admin_id::text AND provider = 'email') THEN
        INSERT INTO auth.identities (
            provider_id,
            user_id,
            identity_data,
            provider,
            last_sign_in_at,
            created_at,
            updated_at
        ) VALUES (
            v_admin_id::text,
            v_admin_id,
            jsonb_build_object(
                'sub', v_admin_id::text,
                'email', 'admin@test.com',
                'email_verified', true,
                'phone_verified', false
            ),
            'email',
            NOW(),
            NOW(),
            NOW()
        );
    END IF;

    -- Identity para GERENTE
    IF NOT EXISTS (SELECT 1 FROM auth.identities WHERE provider_id = v_gerente_id::text AND provider = 'email') THEN
        INSERT INTO auth.identities (
            provider_id,
            user_id,
            identity_data,
            provider,
            last_sign_in_at,
            created_at,
            updated_at
        ) VALUES (
            v_gerente_id::text,
            v_gerente_id,
            jsonb_build_object(
                'sub', v_gerente_id::text,
                'email', 'gerente@test.com',
                'email_verified', true,
                'phone_verified', false
            ),
            'email',
            NOW(),
            NOW(),
            NOW()
        );
    END IF;

    -- Identity para VENDEDOR
    IF NOT EXISTS (SELECT 1 FROM auth.identities WHERE provider_id = v_vendedor_id::text AND provider = 'email') THEN
        INSERT INTO auth.identities (
            provider_id,
            user_id,
            identity_data,
            provider,
            last_sign_in_at,
            created_at,
            updated_at
        ) VALUES (
            v_vendedor_id::text,
            v_vendedor_id,
            jsonb_build_object(
                'sub', v_vendedor_id::text,
                'email', 'vendedor@test.com',
                'email_verified', true,
                'phone_verified', false
            ),
            'email',
            NOW(),
            NOW(),
            NOW()
        );
    END IF;

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Usuarios de autenticación creados exitosamente';
    RAISE NOTICE '========================================';

END $$;

-- ============================================
-- 5. ASIGNAR TIENDAS A USUARIOS
-- ============================================

BEGIN;

INSERT INTO user_tiendas (user_id, tienda_id, activo) VALUES
-- Gerente → Tienda Centro
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', true),
-- Vendedor → Tienda Centro
('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', true)
ON CONFLICT (user_id, tienda_id) DO NOTHING;

COMMIT;

-- ============================================
-- 6. CREAR VENTAS (200 ventas últimos 6 meses)
-- ============================================

DO $$
DECLARE
    v_tienda_ids UUID[] := ARRAY[
        '11111111-1111-1111-1111-111111111111',
        '22222222-2222-2222-2222-222222222222',
        '33333333-3333-3333-3333-333333333333'
    ];
    v_vendedor_id UUID := 'cccccccc-cccc-cccc-cccc-cccccccccccc'; -- El vendedor creado
    v_cliente_ids UUID[];
    v_producto_ids UUID[];
    v_venta_id UUID;
    v_fecha TIMESTAMP WITH TIME ZONE;
    v_monto DECIMAL(12, 2);
    v_estado venta_estado;
    v_tienda_id UUID;
    v_cliente_id UUID;
    v_num_items INTEGER;
    v_producto_id UUID;
    v_cantidad INTEGER;
    v_precio DECIMAL(10, 2);
    v_subtotal DECIMAL(12, 2);
    i INTEGER;
    j INTEGER;
BEGIN
    -- Obtener arrays de clientes y productos
    SELECT ARRAY_AGG(id) INTO v_cliente_ids FROM clientes WHERE activo = true;
    SELECT ARRAY_AGG(id) INTO v_producto_ids FROM productos WHERE activo = true;

    -- Crear 200 ventas distribuidas en 6 meses
    FOR i IN 1..200 LOOP
        -- Generar UUID para la venta
        v_venta_id := gen_random_uuid();

        -- Fecha aleatoria en los últimos 6 meses
        v_fecha := NOW() - (RANDOM() * 180)::INTEGER * INTERVAL '1 day';

        -- Estado aleatorio (80% completadas, 15% en proceso, 5% pendientes)
        CASE
            WHEN RANDOM() < 0.80 THEN v_estado := 'COMPLETADA';
            WHEN RANDOM() < 0.95 THEN v_estado := 'EN_PROCESO';
            ELSE v_estado := 'PENDIENTE';
        END CASE;

        -- Seleccionar tienda aleatoria
        v_tienda_id := v_tienda_ids[1 + FLOOR(RANDOM() * 3)::INTEGER];

        -- Seleccionar cliente aleatorio
        v_cliente_id := v_cliente_ids[1 + FLOOR(RANDOM() * ARRAY_LENGTH(v_cliente_ids, 1))::INTEGER];

        -- Número de items en la venta (entre 1 y 5)
        v_num_items := 1 + FLOOR(RANDOM() * 5)::INTEGER;

        -- Calcular monto total basado en items
        v_monto := 0;

        -- Insertar venta (sin monto aún, se calculará con los detalles)
        INSERT INTO ventas (
            id,
            tienda_id,
            vendedor_id,
            cliente_id,
            monto_total,
            estado,
            fecha_venta,
            created_at,
            updated_at
        ) VALUES (
            v_venta_id,
            v_tienda_id,
            v_vendedor_id,
            v_cliente_id,
            0, -- Se actualizará después
            v_estado,
            v_fecha,
            v_fecha,
            v_fecha
        );

        -- Crear detalles de venta
        FOR j IN 1..v_num_items LOOP
            -- Seleccionar producto aleatorio
            v_producto_id := v_producto_ids[1 + FLOOR(RANDOM() * ARRAY_LENGTH(v_producto_ids, 1))::INTEGER];

            -- Cantidad aleatoria (1-10 unidades)
            v_cantidad := 1 + FLOOR(RANDOM() * 10)::INTEGER;

            -- Obtener precio del producto
            SELECT precio INTO v_precio FROM productos WHERE id = v_producto_id;

            -- Calcular subtotal
            v_subtotal := v_precio * v_cantidad;
            v_monto := v_monto + v_subtotal;

            -- Insertar detalle de venta
            INSERT INTO ventas_detalles (
                venta_id,
                producto_id,
                cantidad,
                precio_unitario,
                subtotal,
                created_at
            ) VALUES (
                v_venta_id,
                v_producto_id,
                v_cantidad,
                v_precio,
                v_subtotal,
                v_fecha
            );
        END LOOP;

        -- Actualizar monto total de la venta
        UPDATE ventas SET monto_total = v_monto WHERE id = v_venta_id;

        -- Si la venta está completada, crear comisión (5% del monto)
        IF v_estado = 'COMPLETADA' THEN
            INSERT INTO comisiones (
                vendedor_id,
                venta_id,
                monto_comision,
                porcentaje,
                fecha_comision,
                created_at
            ) VALUES (
                v_vendedor_id,
                v_venta_id,
                v_monto * 0.05,
                5.00,
                v_fecha,
                v_fecha
            );
        END IF;
    END LOOP;

    RAISE NOTICE 'Se crearon 200 ventas con sus detalles y comisiones';
END $$;

-- ============================================
-- 7. SEED MENU OPTIONS Y PERMISSIONS (HU-002)
-- ============================================

BEGIN;

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

COMMIT;

DO $$
BEGIN
    RAISE NOTICE 'Seed de menús completado: % opciones de menú, % permisos',
        (SELECT COUNT(*) FROM menu_options),
        (SELECT COUNT(*) FROM menu_permissions);
END $$;

-- ============================================
-- 8. REFRESCAR VISTAS MATERIALIZADAS
-- ============================================

SELECT refresh_dashboard_metrics();

-- ============================================
-- RESUMEN DE SEED
-- ============================================

DO $$
DECLARE
    v_tiendas INTEGER;
    v_productos INTEGER;
    v_clientes INTEGER;
    v_usuarios INTEGER;
    v_ventas INTEGER;
    v_detalles INTEGER;
    v_comisiones INTEGER;
    v_asignaciones INTEGER;
    v_menu_options INTEGER;
    v_menu_permissions INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_tiendas FROM tiendas;
    SELECT COUNT(*) INTO v_productos FROM productos;
    SELECT COUNT(*) INTO v_clientes FROM clientes;
    SELECT COUNT(*) INTO v_usuarios FROM auth.users WHERE email LIKE '%@test.com';
    SELECT COUNT(*) INTO v_ventas FROM ventas;
    SELECT COUNT(*) INTO v_detalles FROM ventas_detalles;
    SELECT COUNT(*) INTO v_comisiones FROM comisiones;
    SELECT COUNT(*) INTO v_asignaciones FROM user_tiendas;
    SELECT COUNT(*) INTO v_menu_options FROM menu_options;
    SELECT COUNT(*) INTO v_menu_permissions FROM menu_permissions;

    RAISE NOTICE '========================================';
    RAISE NOTICE 'SEED COMPLETADO EXITOSAMENTE';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Tiendas: %', v_tiendas;
    RAISE NOTICE 'Productos: %', v_productos;
    RAISE NOTICE 'Clientes: %', v_clientes;
    RAISE NOTICE 'Usuarios de prueba: %', v_usuarios;
    RAISE NOTICE 'Ventas generadas: %', v_ventas;
    RAISE NOTICE 'Detalles de venta: %', v_detalles;
    RAISE NOTICE 'Comisiones: %', v_comisiones;
    RAISE NOTICE 'Asignaciones user-tienda: %', v_asignaciones;
    RAISE NOTICE 'Opciones de menú (HU-002): %', v_menu_options;
    RAISE NOTICE 'Permisos de menú (HU-002): %', v_menu_permissions;
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CREDENCIALES DE ACCESO:';
    RAISE NOTICE 'Admin:    admin@test.com    / asdasd211';
    RAISE NOTICE 'Gerente:  gerente@test.com  / asdasd211';
    RAISE NOTICE 'Vendedor: vendedor@test.com / asdasd211';
    RAISE NOTICE '========================================';
END $$;