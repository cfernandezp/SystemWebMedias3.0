# ÉPICA E002: Gestión de Productos de Medias

## 📋 INFORMACIÓN DE LA ÉPICA
- **Código**: E002
- **Nombre**: Gestión de Productos de Medias
- **Descripción**: Sistema completo de catálogos maestros, productos y artículos especializados para retail de medias multi-tienda
- **Story Points Totales**: 63 pts
- **Estado**: 🔵 En Progreso

## 📚 HISTORIAS DE USUARIO

### 🏷️ GESTIÓN DE CATÁLOGOS MAESTROS (Solo Admin)

### E002-HU-001: Gestionar Catálogo de Marcas
- **Archivo**: `docs/historias-usuario/E002-HU-001-COM-gestionar-marcas.md`
- **Estado**: ✅ Completada
- **Story Points**: 4 pts
- **Prioridad**: Alta
- **Descripción**: CRUD de marcas con códigos únicos para SKU

### E002-HU-002: Gestionar Catálogo de Materiales
- **Archivo**: `docs/historias-usuario/E002-HU-002-COM-gestionar-materiales.md`
- **Estado**: ✅ Completada
- **Story Points**: 4 pts
- **Prioridad**: Alta
- **Descripción**: CRUD de materiales con códigos para generación de SKU

### E002-HU-003: Gestionar Catálogo de Tipos
- **Archivo**: `docs/historias-usuario/E002-HU-003-COM-gestionar-tipos.md`
- **Estado**: ✅ Completada
- **Story Points**: 4 pts
- **Prioridad**: Alta
- **Descripción**: CRUD de tipos de medias con códigos para SKU

### E002-HU-004: Gestionar Sistemas de Tallas
- **Archivo**: `docs/historias-usuario/E002-HU-004-COM-gestionar-sistemas-tallas.md`
- **Estado**: ✅ Completada
- **Story Points**: 5 pts
- **Prioridad**: Alta
- **Descripción**: CRUD de sistemas de tallas con configuración de valores

### E002-HU-005: Gestionar Catálogo de Colores
- **Archivo**: `docs/historias-usuario/E002-HU-005-COM-gestionar-catalogo-colores.md`
- **Estado**: ✅ Completada
- **Story Points**: 8 pts
- **Prioridad**: Alta
- **Descripción**: CRUD de colores con códigos y valores HEX, combinaciones multicolor

### 📦 GESTIÓN DE PRODUCTOS Y ARTÍCULOS

### E002-HU-006: Crear Producto Maestro
- **Archivo**: `docs/historias-usuario/E002-HU-006-REF-crear-producto-maestro.md`
- **Estado**: 🟢 Refinada
- **Story Points**: 5 pts
- **Prioridad**: Crítica
- **Descripción**: Crear productos maestros combinando catálogos base (marca, material, tipo, sistema tallas) sin colores ni stock

### E002-HU-007: Especializar Artículos con Colores
- **Archivo**: `docs/historias-usuario/E002-HU-007-especializar-articulos-colores.md`
- **Estado**: ⚪ Pendiente
- **Story Points**: 6 pts
- **Prioridad**: Crítica
- **Descripción**: Crear artículos especializando productos maestros con combinaciones de colores y generación automática de SKU único

### E002-HU-008: Asignar Stock por Tienda
- **Archivo**: `docs/historias-usuario/E002-HU-008-asignar-stock-tienda.md`
- **Estado**: ⚪ Pendiente
- **Story Points**: 5 pts
- **Prioridad**: Crítica
- **Descripción**: Gestionar inventario por artículo específico en cada tienda con niveles mínimo/máximo

### E002-HU-009: Transferencias Entre Tiendas
- **Archivo**: `docs/historias-usuario/E002-HU-009-transferencias-tiendas.md`
- **Estado**: ⚪ Pendiente
- **Story Points**: 8 pts
- **Prioridad**: Alta
- **Descripción**: Solicitar y aprobar movimientos de artículos entre tiendas con tracking y aprobación

### E002-HU-010: Búsqueda Avanzada de Artículos
- **Archivo**: `docs/historias-usuario/E002-HU-010-busqueda-avanzada.md`
- **Estado**: ⚪ Pendiente
- **Story Points**: 5 pts
- **Prioridad**: Media
- **Descripción**: Filtros avanzados por marca, material, tipo, tallas, colores y disponibilidad por tienda

### E002-HU-011: Alertas de Stock Crítico
- **Archivo**: `docs/historias-usuario/E002-HU-011-alertas-stock.md`
- **Estado**: ⚪ Pendiente
- **Story Points**: 5 pts
- **Prioridad**: Media
- **Descripción**: Notificaciones automáticas de stock bajo por artículo-tienda según niveles configurados

## 🎯 CRITERIOS DE ACEPTACIÓN DE LA ÉPICA
- [ ] Catálogos maestros gestionables solo por admin
- [ ] Productos creados combinando catálogos válidos
- [ ] Artículos con colores únicos o múltiples
- [ ] SKU generados automáticamente con formato estándar
- [ ] Stock independiente por artículo-tienda
- [ ] Transferencias con aprobación y tracking
- [ ] Búsquedas por todos los atributos
- [ ] Alertas automáticas de reposición

## 📊 PROGRESO
- Total HU: 11
- ✅ Completadas: 4 (36%)
- 🟢 Refinadas: 1 (9%)
- 🟡 Borradores: 0 (0%)
- 🔵 En Desarrollo: 0 (0%)
- ⚪ Pendientes: 6 (55%)

## 🗃️ DATOS TÉCNICOS

### Estructura de Catálogos Maestros:
```sql
-- Catálogos (CRUD solo admin)
marcas: id, nombre, codigo, activo, created_at
materiales: id, nombre, descripcion, codigo, activo
tipos: id, nombre, descripcion, codigo, activo
sistemas_talla: id, tipo_sistema, valores_disponibles[], activo
colores: id, nombre, codigo_hex, codigo_corto, activo

-- Operaciones
productos: id, marca_id, material_id, tipo_id, sistema_talla_id, descripcion_talla
articulos: id, producto_id, sku, combinacion_colores[], precio, activo
stock_tienda: id, articulo_id, tienda_id, cantidad, minimo, maximo
```

### Formato SKU Estándar:
```
MARCA-TIPO-MATERIAL-TALLA-COLOR1-COLOR2-COLOR3
Ejemplos:
ADS-FUT-ALG-3738-ROJ              (1 color)
NIK-INV-MIC-UNI-BLA-GRI           (2 colores)
PUM-TOB-BAM-M-AZU-VER-ROJ         (3 colores)
```

### Sistemas de Tallas:
- **ÚNICA**: Un solo tamaño
- **NÚMERO**: 35-36, 37-38, 39-40, 41-42, 43-44
- **LETRA**: XS, S, M, L, XL, XXL
- **RANGO**: 34-38, 39-42, 43-46

### Roles y Permisos:
- **ADMIN**: Gestiona todos los catálogos, productos, artículos
- **GERENTE**: Ve productos/artículos, gestiona stock de su tienda
- **VENDEDOR**: Ve productos/artículos disponibles en su tienda

## 🔄 FLUJO GENERAL DE LA ÉPICA
1. **Admin configura catálogos** → Marcas, materiales, tipos, tallas, colores
2. **Admin crea productos** → Combina catálogos en producto maestro
3. **Admin especializa artículos** → Asigna colores, genera SKU
4. **Gerente asigna stock** → Define inventario por artículo-tienda
5. **Sistema monitorea** → Alertas, transferencias, búsquedas

## 🏪 REGLAS DE NEGOCIO CRÍTICAS
- **Catálogos activos/inactivos**: No eliminar registros, marcar como inactivo
- **SKU únicos**: Generación automática, no duplicados
- **Stock por tienda**: Independiente, no compartido
- **Transferencias**: Requieren aprobación de admin
- **Búsquedas**: Solo artículos activos de catálogos activos
- **Validaciones**: Combinaciones lógicas (ej: no futbol + invisible)