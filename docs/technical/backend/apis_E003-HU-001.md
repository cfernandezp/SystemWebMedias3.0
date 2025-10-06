# APIs Backend - E003-HU-001: Dashboard con Métricas

**Historia de Usuario**: E003-HU-001
**Responsable Diseño**: @web-architect-expert
**Fecha Diseño**: 2025-10-06
**Estado**: 🎨 Especificación de Diseño

---

## 📋 ÍNDICE

1. [Endpoints PostgreSQL Functions](#endpoints-postgresql-functions)
2. [Formato de Respuestas](#formato-de-respuestas)
3. [Validaciones y Seguridad](#validaciones-y-seguridad)
4. [Manejo de Errores](#manejo-de-errores)

---

## 1. ENDPOINTS POSTGRESQL FUNCTIONS

### 1.1 `get_dashboard_metrics()`

**Descripción**: Obtiene métricas del dashboard según el rol del usuario autenticado.

**Acceso**: Función RPC vía Supabase Client

**Parámetros**:
```typescript
{
  p_user_id: string (UUID) // ID del usuario autenticado
}
```

**Lógica de Negocio**:
- **RN-001**: Segmentación por rol (VENDEDOR/GERENTE/ADMIN)
- **RN-003**: Cálculo de stock bajo (< 5 unidades o < 10% stock_maximo)
- **RN-004**: Agregación en tiempo real
- **RN-007**: Meta mensual para gerentes

**Response Success (VENDEDOR)**:
```json
{
  "success": true,
  "data": {
    "rol": "VENDEDOR",
    "ventas_hoy": 1250.50,
    "comisiones_mes": 350.75,
    "ordenes_pendientes": 3,
    "productos_stock_bajo": 5
  }
}
```

**Response Success (GERENTE)**:
```json
{
  "success": true,
  "data": {
    "rol": "GERENTE",
    "tienda_id": "uuid-tienda",
    "ventas_totales": 15000.00,
    "clientes_activos": 45,
    "ordenes_pendientes": 12,
    "productos_stock_bajo": 8,
    "meta_mensual": 50000.00,
    "ventas_mes_actual": 35000.00
  }
}
```

**Response Success (ADMIN)**:
```json
{
  "success": true,
  "data": {
    "rol": "ADMIN",
    "ventas_totales_global": 125000.00,
    "clientes_activos_global": 320,
    "ordenes_pendientes_global": 48,
    "tiendas_activas": 5,
    "productos_stock_critico": 12
  }
}
```

**Response Error**:
```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Usuario no autorizado para acceder al dashboard",
    "hint": "user_not_authorized"
  }
}
```

**Hints de Error**:
- `user_not_authorized`: Usuario no aprobado o email no verificado
- `no_tienda_assigned`: Gerente sin tienda asignada
- `invalid_role`: Rol no reconocido

**Validaciones**:
- ✅ Usuario debe existir
- ✅ Usuario debe estar APROBADO
- ✅ Email debe estar verificado
- ✅ Usuario debe tener rol asignado
- ✅ Gerente debe tener tienda asignada

---

### 1.2 `get_sales_chart_data()`

**Descripción**: Obtiene datos históricos de ventas por mes para gráficos (últimos 6 meses por defecto).

**Acceso**: Función RPC vía Supabase Client

**Parámetros**:
```typescript
{
  p_user_id: string (UUID),    // ID del usuario autenticado
  p_months?: number (INTEGER)  // Número de meses a consultar (default: 6)
}
```

**Lógica de Negocio**:
- **VENDEDOR**: Solo sus ventas
- **GERENTE**: Ventas de su tienda
- **ADMIN**: Ventas consolidadas globales

**Response Success**:
```json
{
  "success": true,
  "data": [
    {
      "mes": "2025-10",
      "ventas": 35000.00
    },
    {
      "mes": "2025-09",
      "ventas": 42000.00
    },
    {
      "mes": "2025-08",
      "ventas": 38500.00
    }
    // ... hasta 6 meses
  ]
}
```

**Response Error**:
```json
{
  "success": false,
  "error": {
    "code": "P0001",
    "message": "Usuario no encontrado",
    "hint": "user_not_found"
  }
}
```

**Validaciones**:
- ✅ `p_months` debe ser entre 1 y 12
- ✅ Solo ventas con estado `COMPLETADA`, `PREPARANDO`, `EN_PROCESO`
- ✅ Ordenar por mes DESC (más reciente primero)

---

### 1.3 `get_top_productos()`

**Descripción**: Obtiene los N productos más vendidos del mes actual.

**Acceso**: Función RPC vía Supabase Client

**Parámetros**:
```typescript
{
  p_user_id: string (UUID),  // ID del usuario autenticado
  p_limit?: number (INTEGER) // Cantidad de productos (default: 5)
}
```

**Lógica de Negocio**:
- **RN-005**: Top productos según cantidad vendida (no monto)
- **VENDEDOR**: Productos de su tienda asignada
- **GERENTE**: Productos de su tienda
- **ADMIN**: Productos globales

**Response Success**:
```json
{
  "success": true,
  "data": [
    {
      "producto_id": "uuid-producto-1",
      "nombre": "Medias Deportivas Negras",
      "cantidad_vendida": 120
    },
    {
      "producto_id": "uuid-producto-2",
      "nombre": "Medias Ejecutivas Grises",
      "cantidad_vendida": 95
    }
    // ... hasta p_limit productos
  ]
}
```

**Validaciones**:
- ✅ `p_limit` debe ser entre 1 y 20
- ✅ Solo productos activos (no descontinuados)
- ✅ Solo ventas del mes actual

---

### 1.4 `get_top_vendedores()`

**Descripción**: Obtiene los top N vendedores del mes (solo para GERENTE y ADMIN).

**Acceso**: Función RPC vía Supabase Client

**Parámetros**:
```typescript
{
  p_user_id: string (UUID),  // ID del usuario autenticado
  p_limit?: number (INTEGER) // Cantidad de vendedores (default: 5)
}
```

**Lógica de Negocio**:
- **RN-005**: Ordenar por monto de ventas DESC
- **En empate**: Priorizar por mayor número de transacciones
- **GERENTE**: Solo vendedores de su tienda
- **ADMIN**: Vendedores globales

**Response Success**:
```json
{
  "success": true,
  "data": [
    {
      "vendedor_id": "uuid-vendedor-1",
      "nombre_completo": "Juan Pérez",
      "ventas_totales": 15000.00,
      "num_transacciones": 45
    },
    {
      "vendedor_id": "uuid-vendedor-2",
      "nombre_completo": "María González",
      "ventas_totales": 14800.00,
      "num_transacciones": 50
    }
  ]
}
```

**Validaciones**:
- ✅ Solo GERENTE o ADMIN pueden llamar
- ✅ VENDEDOR recibirá error `forbidden`
- ✅ Solo ventas confirmadas del mes actual

---

### 1.5 `get_transacciones_recientes()`

**Descripción**: Obtiene las últimas N transacciones según rol.

**Acceso**: Función RPC vía Supabase Client

**Parámetros**:
```typescript
{
  p_user_id: string (UUID),  // ID del usuario autenticado
  p_limit?: number (INTEGER) // Cantidad de transacciones (default: 5)
}
```

**Response Success**:
```json
{
  "success": true,
  "data": [
    {
      "venta_id": "uuid-venta",
      "fecha_venta": "2025-10-06T14:30:00Z",
      "monto_total": 1250.50,
      "estado": "COMPLETADA",
      "cliente_nombre": "Carlos Ramírez",
      "vendedor_nombre": "Juan Pérez"
    }
    // ... hasta p_limit transacciones
  ]
}
```

**Validaciones**:
- ✅ `p_limit` debe ser entre 1 y 20
- ✅ VENDEDOR: Solo sus ventas
- ✅ GERENTE: Ventas de su tienda
- ✅ ADMIN: Ventas globales

---

### 1.6 `get_productos_stock_bajo()`

**Descripción**: Obtiene productos con stock bajo o crítico.

**Acceso**: Función RPC vía Supabase Client

**Parámetros**:
```typescript
{
  p_user_id: string (UUID)
}
```

**Lógica de Negocio**:
- **RN-003**: Stock crítico < 5 unidades o < 10% stock_maximo
- **Stock bajo**: < 20% stock_maximo

**Response Success**:
```json
{
  "success": true,
  "data": [
    {
      "producto_id": "uuid-producto",
      "nombre": "Medias Deportivas Blancas",
      "stock_actual": 3,
      "stock_maximo": 100,
      "porcentaje_stock": 3,
      "nivel_alerta": "CRITICO" // CRITICO | BAJO
    }
  ]
}
```

**Validaciones**:
- ✅ Solo productos activos
- ✅ Ordenar por nivel de alerta (CRITICO primero)
- ✅ No incluir productos descontinuados

---

### 1.7 `refresh_dashboard_metrics()`

**Descripción**: Refresca vistas materializadas del dashboard.

**Acceso**: Función RPC (ejecutar manual o programado)

**Parámetros**: Ninguno

**Response Success**:
```json
{
  "success": true,
  "message": "Vistas materializadas refrescadas correctamente"
}
```

**Uso**:
- Ejecutar cada 5 minutos durante horas pico (9am - 8pm)
- Ejecutar cada 30 minutos en horas valle

---

## 2. FORMATO DE RESPUESTAS

### 2.1 Respuesta Exitosa Estándar

```json
{
  "success": true,
  "data": {
    // Datos específicos del endpoint
  }
}
```

### 2.2 Respuesta con Error Estándar

```json
{
  "success": false,
  "error": {
    "code": "P0001",           // SQLSTATE
    "message": "Mensaje descriptivo",
    "hint": "codigo_hint"      // Hint para mapear en frontend
  }
}
```

---

## 3. VALIDACIONES Y SEGURIDAD

### 3.1 Autenticación

Todas las funciones requieren:
- Usuario autenticado (JWT válido)
- Usuario con estado `APROBADO`
- Email verificado (`email_verificado = true`)

### 3.2 Autorización (RLS)

- **VENDEDOR**: Solo accede a datos de su ámbito (sus ventas, su tienda)
- **GERENTE**: Solo accede a datos de su tienda asignada
- **ADMIN**: Acceso completo a todos los datos

### 3.3 Rate Limiting (Futuro)

- Implementar límite de 60 requests/min por usuario
- Bloquear si se excede (hint: `rate_limit`)

---

## 4. MANEJO DE ERRORES

### 4.1 Códigos de Hint Estándar

| Hint | Significado | HTTP Status (Flutter) |
|------|-------------|-----------------------|
| `user_not_authorized` | Usuario no autorizado | 403 Forbidden |
| `user_not_found` | Usuario no existe | 404 Not Found |
| `no_tienda_assigned` | Gerente sin tienda | 400 Bad Request |
| `invalid_role` | Rol no válido | 400 Bad Request |
| `forbidden` | Operación no permitida para rol | 403 Forbidden |
| `missing_param` | Parámetro requerido faltante | 400 Bad Request |
| `invalid_param` | Parámetro con valor inválido | 400 Bad Request |

### 4.2 Ejemplo de Manejo en Datasource (Flutter)

```dart
// Ver docs/technical/integration/mapping_E003-HU-001.md
// para código completo de mapeo de errores
```

---

## 📝 NOTAS DE IMPLEMENTACIÓN

### Optimizaciones

1. **Vistas Materializadas**: Pre-calcular métricas pesadas
2. **Índices**: Todos los JOIN y WHERE deben tener índices
3. **Caché**: Implementar caché de 5 min en frontend para métricas no críticas

### Testing

```sql
-- Test de get_dashboard_metrics() con usuario VENDEDOR
SELECT get_dashboard_metrics('uuid-vendedor-test');

-- Test de get_sales_chart_data() últimos 3 meses
SELECT get_sales_chart_data('uuid-gerente-test', 3);

-- Test de top productos
SELECT get_top_productos('uuid-admin-test', 10);
```

---

## ✅ CÓDIGO FINAL IMPLEMENTADO

**Status**: 🎨 Pendiente de Implementación

_Esta sección será completada por @supabase-expert después de implementar las funciones._

---

**Próximos Pasos**:
1. @supabase-expert: Implementar funciones SQL en migration
2. @supabase-expert: Crear tests de cada función
3. @flutter-expert: Consumir APIs desde Datasource
