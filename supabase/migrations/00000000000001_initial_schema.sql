-- ============================================
-- Migration: 00000000000001_initial_schema.sql
-- Descripción: Tablas base del sistema + triggers globales
-- Fecha: 2025-10-07 (Consolidado)
-- ============================================

BEGIN;

-- ============================================
-- PASO 1: Extensiones necesarias
-- ============================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- ============================================
-- PASO 2: ENUMs globales
-- ============================================

-- ENUM para roles de usuario
CREATE TYPE user_role AS ENUM ('ADMIN', 'GERENTE', 'VENDEDOR');

COMMENT ON TYPE user_role IS 'Roles de usuario del sistema';

-- ENUM para estados de venta
CREATE TYPE venta_estado AS ENUM ('PENDIENTE', 'EN_PROCESO', 'PREPARANDO', 'COMPLETADA', 'CANCELADA', 'DEVUELTA');

COMMENT ON TYPE venta_estado IS 'Estados posibles de una venta - E003-HU-001: RN-004';

-- ENUM para tipo de sistema de tallas (E002-HU-004)
CREATE TYPE tipo_sistema_enum AS ENUM ('UNICA', 'NUMERO', 'NUMERO_INDIVIDUAL', 'LETRA', 'RANGO');

COMMENT ON TYPE tipo_sistema_enum IS 'E002-HU-004: Tipos de sistema de tallas - RN-004-01. NUMERO=rangos (35-36), NUMERO_INDIVIDUAL=valores individuales (35,36,37)';

-- ============================================
-- PASO 3: Función global para updated_at
-- ============================================

-- Función reutilizable para auto-actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column IS 'Trigger global: Actualiza campo updated_at en cada UPDATE';

COMMIT;

-- ============================================
-- RESUMEN
-- ============================================
-- Extensiones: pgcrypto, pg_net
-- ENUMs: user_role, venta_estado
-- Funciones: update_updated_at_column
-- ============================================