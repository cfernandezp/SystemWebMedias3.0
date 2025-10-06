# E003-HU-001: Dashboard Principal con Métricas

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E003-HU-001
- **Épica**: E003 - Dashboard y Sistema de Navegación
- **Título**: Dashboard Principal con Métricas
- **Story Points**: 8 pts
- **Estado**: 🔵 En Desarrollo (Backend ✅ | Frontend ⏳ | UI ⏳)
- **Fecha Creación**: 2025-10-05

## 🎯 HISTORIA DE USUARIO
**Como** usuario del sistema (vendedor/gerente/admin)
**Quiero** ver un dashboard con métricas relevantes a mi rol
**Para** tener visibilidad inmediata del estado del negocio y tomar decisiones informadas

### Criterios de Aceptación

#### CA-001: Dashboard para Vendedor
- [ ] **DADO** que soy un vendedor autenticado
- [ ] **CUANDO** accedo al dashboard
- [ ] **ENTONCES** debo ver:
  - [ ] Card de "Ventas de Hoy" con monto total y porcentaje vs ayer
  - [ ] Card de "Mis Comisiones" del mes actual
  - [ ] Card de "Productos en Stock" de mi tienda con indicador de stock bajo
  - [ ] Card de "Órdenes Pendientes" que requieren mi atención
  - [ ] Gráfico de "Mis Ventas por Mes" (últimos 6 meses)
  - [ ] Lista de "Productos Más Vendidos" del mes (top 5)

#### CA-002: Dashboard para Gerente
- [ ] **DADO** que soy un gerente autenticado
- [ ] **CUANDO** accedo al dashboard
- [ ] **ENTONCES** debo ver:
  - [ ] Card de "Ventas Totales" de mi tienda con tendencia (+12.5% o -3.2%)
  - [ ] Card de "Clientes Activos" registrados este mes
  - [ ] Card de "Productos en Stock" con productos en stock bajo (alerta)
  - [ ] Card de "Órdenes Pendientes" de la tienda
  - [ ] Gráfico de "Ventas por Mes" de la tienda (evolución mensual)
  - [ ] Lista de "Top Vendedores" del mes con sus ventas
  - [ ] Sección "Transacciones Recientes" (últimas 5 operaciones)
  - [ ] Indicador de progreso de "Meta Mensual" vs ventas actuales

#### CA-003: Dashboard para Admin
- [ ] **DADO** que soy un admin autenticado
- [ ] **CUANDO** accedo al dashboard
- [ ] **ENTONCES** debo ver:
  - [ ] Card de "Ventas Totales" consolidadas de todas las tiendas
  - [ ] Card de "Clientes Activos" a nivel global
  - [ ] Card de "Productos en Stock" consolidado con alertas críticas
  - [ ] Card de "Órdenes Pendientes" globales
  - [ ] Gráfico de "Ventas por Mes" comparativo entre tiendas
  - [ ] Gráfico de "Productos Más Vendidos" a nivel global
  - [ ] Lista de "Alertas del Sistema" (stock crítico, ventas anormales)
  - [ ] Sección de "Acciones Rápidas" (Nueva Venta, Productos, Inventario, etc.)

#### CA-004: Actualización en Tiempo Real
- [ ] **DADO** que estoy visualizando el dashboard
- [ ] **CUANDO** ocurre una nueva venta o cambio en el sistema
- [ ] **ENTONCES** debo ver un botón "Actualizar" con indicador verde
- [ ] **Y** al hacer clic en "Actualizar" las métricas se refrescan
- [ ] **Y** debo ver animación de actualización (0m hace actualizado)

#### CA-005: Interactividad de Métricas
- [ ] **DADO** que veo una card de métrica en el dashboard
- [ ] **CUANDO** hago clic en la card
- [ ] **ENTONCES** debo navegar al detalle correspondiente:
  - [ ] "Ventas de Hoy" → Historial de ventas del día
  - [ ] "Productos en Stock" → Listado de inventario
  - [ ] "Órdenes Pendientes" → Gestión de órdenes
  - [ ] "Clientes Activos" → Base de datos de clientes

#### CA-006: Visualización de Tendencias
- [ ] **DADO** que veo métricas con tendencias
- [ ] **CUANDO** la tendencia es positiva (crecimiento)
- [ ] **ENTONCES** debo ver indicador verde con flecha arriba (ej: +12.5%)
- [ ] **CUANDO** la tendencia es negativa (decrecimiento)
- [ ] **ENTONCES** debo ver indicador rojo con flecha abajo (ej: -3.2%)
- [ ] **CUANDO** no hay cambio significativo
- [ ] **ENTONCES** debo ver indicador neutro

### Estado de Implementación
- [x] **Backend** - ✅ Completado (2025-10-06)
  - [x] Función `get_dashboard_metrics()` con polimorfismo por rol
  - [x] Vista `dashboard_vendedor_metrics` con métricas del vendedor
  - [x] Vista `dashboard_gerente_metrics` con métricas del gerente
  - [x] Vista `dashboard_admin_metrics` con métricas consolidadas
  - [x] RLS policies para acceso según rol
  - [x] Función `get_sales_chart_data()` para gráficos históricos
  - [x] Función `get_top_productos()` para rankings
  - [x] Seed data: 3 tiendas, 30 productos, 50 clientes
- [ ] **Frontend** - Pendiente
  - [ ] DashboardPage con layout de cards
  - [ ] DashboardBloc para gestión de estado
  - [ ] MetricCard widget reutilizable
  - [ ] SalesChart widget (line/bar chart)
  - [ ] TransactionsList widget
  - [ ] Lógica de navegación desde cards
- [ ] **UX/UI** - Pendiente
  - [ ] Dashboard layout responsivo (grid adaptable)
  - [ ] Cards con iconos y colores según tipo de métrica
  - [ ] Gráficos interactivos con animaciones
  - [ ] Sistema de colores: verde (positivo), rojo (alerta), azul (info)
  - [ ] Loading skeletons para carga de métricas
- [ ] **QA** - Pendiente
  - [ ] Tests de todos los criterios de aceptación
  - [ ] Validación de métricas según rol
  - [ ] Tests de navegación desde cards
  - [ ] Tests de actualización de datos

### Definición de Terminado (DoD)
- [ ] Todos los criterios de aceptación cumplidos
- [ ] Backend implementado según SISTEMA_DOCUMENTACION.md
- [ ] Frontend consume APIs correctamente
- [ ] UX/UI sigue Design System
- [ ] QA valida todos los flujos
- [ ] Documentación actualizada

---

## 📊 REGLAS DE NEGOCIO PURAS

### RN-001: Segmentación de Dashboard por Rol
**Regla**: El dashboard debe mostrar métricas específicas según el rol del usuario autenticado.

**Contexto de Negocio**: Cada rol tiene diferentes responsabilidades y necesidades de información. Un vendedor necesita ver sus propias comisiones y metas, mientras que un gerente necesita supervisar toda su tienda y un admin requiere visión consolidada.

**Lógica**:
- **Vendedor**: Métricas individuales (sus ventas, sus comisiones, productos de su tienda asignada)
- **Gerente**: Métricas de su tienda (ventas totales de la tienda, todos los vendedores, inventario completo)
- **Admin**: Métricas globales (consolidado de todas las tiendas, comparativas entre tiendas)

**Validaciones**:
- ✅ Usuario autenticado con rol válido
- ✅ Usuario activo (no bloqueado o suspendido)
- ✅ Métricas filtradas por el ámbito del rol (no mostrar datos fuera de su alcance)

**Casos de Negocio**:
- Si un vendedor intenta acceder a métricas de otra tienda → Rechazar
- Si un gerente intenta ver métricas de tiendas que no gestiona → Rechazar
- Si un usuario tiene múltiples roles → Mostrar dashboard del rol principal o permitir switch

---

### RN-002: Cálculo de Tendencias y Comparativas
**Regla**: Las métricas deben mostrar tendencias comparando el período actual con el período anterior equivalente.

**Contexto de Negocio**: Los usuarios necesitan contexto para evaluar si las métricas son buenas o malas. Una venta de $1000 es buena si ayer fue $800, pero mala si ayer fue $1500.

**Lógica**:
- **"Ventas de Hoy"**: Comparar total de hoy vs total de ayer (mismo día de la semana anterior)
- **"Ventas del Mes"**: Comparar mes actual vs mes anterior
- **"Comisiones"**: Comparar comisiones acumuladas del mes vs mes anterior
- **Fórmula**: `tendencia = ((valor_actual - valor_anterior) / valor_anterior) * 100`

**Validaciones**:
- ✅ Si no hay datos del período anterior → Mostrar "Sin datos previos" (no mostrar tendencia)
- ✅ Si el valor anterior es 0 → Mostrar "N/A" o "Nuevo" (evitar división por cero)
- ✅ Tendencia >= +5% → Indicador verde con flecha arriba
- ✅ Tendencia <= -5% → Indicador rojo con flecha abajo
- ✅ Tendencia entre -5% y +5% → Indicador neutro (amarillo/gris)

**Casos de Negocio**:
- Primera venta del día → Tendencia +100% o "Nueva venta"
- Ventas cayeron de $1000 a $0 → Tendencia -100% con alerta crítica
- Comparar lunes con lunes (no lunes con domingo, porque los patrones son diferentes)

---

### RN-003: Definición de "Stock Bajo" y Alertas
**Regla**: El sistema debe identificar productos con stock bajo según umbrales configurables y mostrar alertas.

**Contexto de Negocio**: Evitar quedarse sin inventario de productos populares. Cada producto puede tener un umbral diferente según su rotación.

**Lógica**:
- **Stock Crítico**: `stock_actual < 5 unidades` o `stock_actual < 10% del stock_maximo`
- **Stock Bajo**: `stock_actual < 20% del stock_maximo`
- **Stock Normal**: `stock_actual >= 20% del stock_maximo`

**Validaciones**:
- ✅ Contar solo productos activos (no productos descontinuados)
- ✅ Si `stock_maximo` no está configurado → Usar umbral fijo de 10 unidades
- ✅ Productos en stock crítico aparecen primero en alertas

**Casos de Negocio**:
- Producto con 3 unidades y stock_maximo = 100 → Alerta crítica (3%)
- Producto con 50 unidades y stock_maximo = 200 → Alerta (25%, pero puede configurarse)
- Producto descontinuado con 0 stock → No mostrar alerta

---

### RN-004: Agregación de Métricas en Tiempo Real
**Regla**: Las métricas deben reflejar el estado actual del negocio, incluyendo transacciones recientes no procesadas.

**Contexto de Negocio**: Un vendedor que acaba de registrar una venta necesita ver inmediatamente el impacto en sus métricas del día.

**Lógica**:
- **Ventas de Hoy**: Sumar todas las ventas confirmadas del día actual (desde las 00:00 hasta now)
- **Comisiones del Mes**: Calcular sobre ventas del mes actual con estado `completada` o `pagada`
- **Órdenes Pendientes**: Contar órdenes con estado `pendiente`, `en_proceso`, `preparando`
- **Actualización**: Al refrescar, recalcular todas las métricas sin caché (datos frescos)

**Validaciones**:
- ✅ Excluir ventas canceladas o devueltas en métricas positivas
- ✅ Incluir devoluciones en métricas separadas (si aplica)
- ✅ Zona horaria del negocio (no UTC) para determinar "Hoy"
- ✅ Comisiones solo sobre ventas confirmadas (no sobre preventas canceladas)

**Casos de Negocio**:
- Venta registrada a las 23:59 → Cuenta para "Ventas de Hoy" de ese día
- Venta cancelada después de 2 días → Restar de métricas históricas
- Preventa no confirmada → No cuenta para comisiones hasta que se confirme

---

### RN-005: Top Vendedores y Productos Más Vendidos
**Regla**: El dashboard debe mostrar rankings de top 5 vendedores y productos según volumen de ventas del período.

**Contexto de Negocio**: Gamificación y motivación del equipo. Identificar productos estrella para estrategias de inventario y marketing.

**Lógica**:
- **Top Vendedores**: Ordenar vendedores por `SUM(monto_ventas)` del mes actual, mostrar top 5
- **Productos Más Vendidos**: Ordenar productos por `COUNT(ventas)` o `SUM(cantidad_vendida)` del mes, mostrar top 5
- **Empates**: Si dos vendedores tienen igual monto, ordenar por número de transacciones (más transacciones = mejor)

**Validaciones**:
- ✅ Solo ventas confirmadas (no canceladas)
- ✅ Si hay menos de 5 vendedores/productos → Mostrar los disponibles
- ✅ Vendedores inactivos no aparecen en ranking
- ✅ Productos descontinuados no aparecen en ranking

**Casos de Negocio**:
- Vendedor A: $10,000 en 50 ventas
- Vendedor B: $10,000 en 30 ventas
- Ranking: Vendedor A primero (más transacciones, mejor servicio)

---

### RN-006: Acceso Rápido desde Cards de Métricas
**Regla**: Al hacer clic en una card de métrica, el usuario debe navegar al módulo correspondiente con filtros pre-aplicados.

**Contexto de Negocio**: Facilitar la investigación de métricas. Si veo "5 órdenes pendientes", quiero ir directo a verlas sin buscar manualmente.

**Lógica**:
- **"Ventas de Hoy"** → `/ventas?fecha=${hoy}`
- **"Productos en Stock Bajo"** → `/inventario?filtro=stock_bajo`
- **"Órdenes Pendientes"** → `/ordenes?estado=pendiente`
- **"Clientes Activos"** → `/clientes?estado=activo&periodo=mes_actual`
- **"Top Vendedores"** → `/reportes/vendedores?periodo=mes_actual`

**Validaciones**:
- ✅ Usuario tiene permisos para acceder al módulo destino
- ✅ Si no tiene permisos → Mostrar mensaje "No autorizado" sin navegar
- ✅ Filtros pre-aplicados deben ser editables por el usuario en el destino

**Casos de Negocio**:
- Vendedor hace clic en "Órdenes Pendientes" → Ve solo sus órdenes asignadas
- Gerente hace clic en "Órdenes Pendientes" → Ve todas las órdenes de su tienda
- Admin hace clic en "Ventas Totales" → Ve dashboard de ventas consolidado

---

### RN-007: Meta Mensual y Progreso
**Regla**: El dashboard de gerente debe mostrar el progreso hacia la meta mensual de ventas configurada.

**Contexto de Negocio**: Las tiendas tienen objetivos de ventas mensuales. El gerente necesita monitorear si va en camino de cumplir la meta.

**Lógica**:
- **Meta Mensual**: Configurada en tabla `tiendas.meta_mensual` (valor en $)
- **Progreso**: `(ventas_mes_actual / meta_mensual) * 100`
- **Indicador**:
  - `< 50%` y faltan menos de 10 días → Rojo (riesgo de no cumplir)
  - `>= 50%` y `< 100%` → Amarillo (en progreso)
  - `>= 100%` → Verde (meta cumplida o superada)

**Validaciones**:
- ✅ Si no hay meta configurada → Mostrar "Meta no definida"
- ✅ Meta debe ser > 0
- ✅ Progreso > 100% es válido (sobre-cumplimiento)

**Casos de Negocio**:
- Meta: $50,000 | Ventas actuales: $35,000 | Día 25 del mes → Amarillo (70%, falta poco tiempo)
- Meta: $50,000 | Ventas actuales: $55,000 | Día 20 del mes → Verde (110%, meta superada)
- Meta: $50,000 | Ventas actuales: $15,000 | Día 28 del mes → Rojo crítico (30%, imposible cumplir)

---

### RN-008: Clientes Activos del Mes
**Regla**: "Clientes Activos" son aquellos que realizaron al menos una compra en el mes actual.

**Contexto de Negocio**: Medir engagement de clientes y retención. Un cliente registrado pero sin compras no es "activo".

**Lógica**:
- **Cliente Activo**: `COUNT(DISTINCT cliente_id)` con al menos 1 venta en el mes actual
- **Comparativa**: Comparar con clientes activos del mes anterior
- **Nuevos Clientes**: Clientes que hicieron su primera compra este mes

**Validaciones**:
- ✅ Solo ventas confirmadas (no canceladas)
- ✅ Cliente debe existir en tabla `clientes` (no ventas anónimas)
- ✅ Distinguir entre "Clientes Activos" y "Nuevos Clientes"

**Casos de Negocio**:
- Cliente compró 5 veces este mes → Cuenta como 1 cliente activo
- Cliente registrado pero sin compras → No cuenta como activo
- Cliente nuevo que compró por primera vez → Cuenta en "Nuevos Clientes" y "Clientes Activos"

---

## 🔗 RELACIONES CON OTRAS HISTORIAS

- **Depende de**: E001-HU-001 (Login), E001-HU-002 (Confirmación Email)
- **Bloquea**: E003-HU-002 (Navegación y Menús)
- **Relacionada con**: Todas las HUs de gestión de ventas, inventario, clientes (proveen datos para métricas)
