-- Supabase Seed File - E003-HU-001
-- Data de prueba para Dashboard con Métricas

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

-- ============================================
-- 4. ASIGNAR TIENDAS A USUARIOS (esperar que existan usuarios)
-- ============================================

-- NOTA: Estos INSERTs dependen de que existan usuarios con roles específicos
-- Se ejecutarán cuando haya usuarios registrados con rol VENDEDOR o GERENTE

-- Ejemplo de asignación (descomentar cuando existan usuarios):
-- INSERT INTO user_tiendas (user_id, tienda_id, activo) VALUES
-- ('user-vendedor-1-uuid', '11111111-1111-1111-1111-111111111111', true),
-- ('user-gerente-1-uuid', '11111111-1111-1111-1111-111111111111', true);

-- ============================================
-- 5. CREAR VENTAS (200 ventas en últimos 6 meses)
-- ============================================

-- NOTA: Las ventas también dependen de que existan usuarios vendedores
-- Por ahora, comentamos esta sección

-- Ejemplo de ventas (descomentar cuando existan vendedores):
/*
DO $$
DECLARE
    v_tienda_ids UUID[] := ARRAY[
        '11111111-1111-1111-1111-111111111111',
        '22222222-2222-2222-2222-222222222222',
        '33333333-3333-3333-3333-333333333333'
    ];
    v_cliente_ids UUID[];
    v_producto_ids UUID[];
    v_vendedor_id UUID := 'user-vendedor-uuid'; -- Reemplazar con UUID real
    v_fecha DATE;
    v_monto DECIMAL;
    v_estado venta_estado;
    i INTEGER;
BEGIN
    -- Obtener arrays de clientes y productos
    SELECT ARRAY_AGG(id) INTO v_cliente_ids FROM clientes LIMIT 50;
    SELECT ARRAY_AGG(id) INTO v_producto_ids FROM productos WHERE activo = true;

    -- Crear 200 ventas distribuidas en 6 meses
    FOR i IN 1..200 LOOP
        -- Fecha aleatoria en los últimos 6 meses
        v_fecha := NOW() - (RANDOM() * 180)::INTEGER * INTERVAL '1 day';

        -- Monto aleatorio entre 50 y 500
        v_monto := 50 + RANDOM() * 450;

        -- Estado aleatorio (80% completadas, 15% en proceso, 5% pendientes)
        v_estado := CASE
            WHEN RANDOM() < 0.80 THEN 'COMPLETADA'::venta_estado
            WHEN RANDOM() < 0.95 THEN 'EN_PROCESO'::venta_estado
            ELSE 'PENDIENTE'::venta_estado
        END;

        INSERT INTO ventas (
            tienda_id,
            vendedor_id,
            cliente_id,
            monto_total,
            estado,
            fecha_venta
        ) VALUES (
            v_tienda_ids[1 + FLOOR(RANDOM() * 3)::INTEGER],
            v_vendedor_id,
            v_cliente_ids[1 + FLOOR(RANDOM() * ARRAY_LENGTH(v_cliente_ids, 1))::INTEGER],
            v_monto,
            v_estado,
            v_fecha
        );
    END LOOP;
END $$;
*/

-- ============================================
-- 6. REFRESCAR VISTAS MATERIALIZADAS
-- ============================================

-- Las vistas se refrescarán automáticamente cuando haya datos

COMMIT;

-- ============================================
-- INSTRUCCIONES POST-SEED
-- ============================================

-- Para completar el seed con datos realistas:
--
-- 1. Registra usuarios con roles VENDEDOR, GERENTE, ADMIN usando la app
-- 2. Obtén sus UUIDs de auth.users
-- 3. Asigna tiendas a vendedores y gerentes en user_tiendas
-- 4. Crea ventas asociadas a esos vendedores
-- 5. Ejecuta: SELECT refresh_dashboard_metrics();
--
-- Ejemplo de query para obtener UUIDs:
-- SELECT id, email, raw_user_meta_data->>'rol' as rol FROM auth.users;
