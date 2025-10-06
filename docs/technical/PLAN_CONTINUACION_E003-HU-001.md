# Plan de Continuación - E003-HU-001: Dashboard con Métricas

**Fecha**: 2025-10-06
**Arquitecto**: @web-architect-expert
**Estado Backend**: ✅ Completado (100%)
**Estado Frontend**: ⏳ Pendiente
**Estado UI**: ⏳ Pendiente

---

## ✅ COMPLETADO

### Backend (100%)
- ✅ Migration creada: `20251006053549_e003_hu001_dashboard_metrics.sql`
- ✅ 7 tablas creadas (tiendas, productos, clientes, ventas, ventas_detalles, comisiones, user_tiendas)
- ✅ 3 vistas materializadas (vendedor, gerente, admin)
- ✅ 4 funciones implementadas:
  - `get_dashboard_metrics(p_user_id)`
  - `get_sales_chart_data(p_user_id, p_months)`
  - `get_top_productos(p_user_id, p_limit)`
  - `refresh_dashboard_metrics()`
- ✅ RLS policies por rol
- ✅ Seed data: 3 tiendas, 30 productos, 50 clientes
- ✅ Base de datos funcionando en Supabase Local

---

## 🔄 SIGUIENTE FASE: Frontend + UI

### Opción 1: Esperar Reset de Agentes (4am)

Después de las 4am, ejecutar agentes en paralelo:

```bash
# En un solo mensaje, coordinar:
@flutter-expert implementa docs/technical/SPECS-FOR-AGENTS-E003-HU-001.md (Frontend)
@ux-ui-expert implementa docs/technical/SPECS-FOR-AGENTS-E003-HU-001.md (UI)
```

### Opción 2: Implementación Manual (Ahora)

Si quieres continuar ahora, sigue este orden:

#### PASO 1: Crear Entities (Domain Layer)

```bash
# Ubicación: lib/features/dashboard/domain/entities/

1. dashboard_metrics.dart (abstract base)
2. vendedor_metrics.dart
3. gerente_metrics.dart
4. admin_metrics.dart
5. sales_chart_data.dart
6. top_producto.dart
7. top_vendedor.dart
8. transaccion_reciente.dart
9. producto_stock_bajo.dart
```

**Referencia**: [models_E003-HU-001.md](frontend/models_E003-HU-001.md) - Sección 1

#### PASO 2: Crear Models (Data Layer)

```bash
# Ubicación: lib/features/dashboard/data/models/

1. vendedor_metrics_model.dart (con fromJson/toJson)
2. gerente_metrics_model.dart (con fromJson/toJson)
3. admin_metrics_model.dart (con fromJson/toJson)
4. sales_chart_data_model.dart
5. top_producto_model.dart
6. top_vendedor_model.dart
7. transaccion_reciente_model.dart
8. producto_stock_bajo_model.dart
```

**Referencia**: [models_E003-HU-001.md](frontend/models_E003-HU-001.md) - Sección 2

**⚠️ CRÍTICO**: Mapping exacto snake_case ↔ camelCase según [mapping_E003-HU-001.md](integration/mapping_E003-HU-001.md)

#### PASO 3: Implementar Datasource

```bash
# Ubicación: lib/features/dashboard/data/datasources/

1. dashboard_remote_datasource.dart (interface)
2. dashboard_remote_datasource_impl.dart (implementación)
```

**Funciones clave**:
- `getMetrics(userId)` - Con polimorfismo VENDEDOR/GERENTE/ADMIN
- `getSalesChart(userId, months)`
- `getTopProductos(userId, limit)`

**Referencia**: [mapping_E003-HU-001.md](integration/mapping_E003-HU-001.md) - Sección 4

#### PASO 4: Implementar Repository

```bash
# Domain: lib/features/dashboard/domain/repositories/
dashboard_repository.dart (interface)

# Data: lib/features/dashboard/data/repositories/
dashboard_repository_impl.dart (implementación)
```

#### PASO 5: Implementar UseCases

```bash
# Ubicación: lib/features/dashboard/domain/usecases/

1. get_dashboard_metrics.dart
2. get_sales_chart.dart
3. get_top_productos.dart
```

#### PASO 6: Implementar Bloc

```bash
# Ubicación: lib/features/dashboard/presentation/bloc/

1. dashboard_bloc.dart
2. dashboard_event.dart (LoadDashboard, RefreshDashboard)
3. dashboard_state.dart (Loading, Loaded, Error)
```

#### PASO 7: Crear Atoms (Design System)

```bash
# Ubicación: lib/shared/design_system/atoms/

1. metric_card.dart
   - Props: icon, titulo, valor, tendencia, onTap
   - Hover: scale 1.02, elevation 8
   - Loading: shimmer skeleton

2. trend_indicator.dart
   - Props: porcentaje, tipo (up/down/neutral)
   - Verde: +5%, Rojo: -5%, Gris: neutro

3. meta_progress_bar.dart
   - Props: progreso, metaMensual, ventasActuales
   - Colores: verde ≥100%, amarillo 50-99%, rojo <50%
```

**Referencia**: [components_E003-HU-001.md](design/components_E003-HU-001.md) - Sección 1

#### PASO 8: Crear Molecules

```bash
# Ubicación: lib/features/dashboard/presentation/widgets/

1. metrics_grid.dart
   - Responsive: 3 columnas (desktop), 2 (tablet), 1 (mobile)

2. sales_line_chart.dart
   - Package: fl_chart
   - Color: primaryTurquoise
   - Animación: fade in + slide up

3. top_productos_list.dart
4. top_vendedores_list.dart
5. transacciones_recientes_list.dart
```

**Referencia**: [components_E003-HU-001.md](design/components_E003-HU-001.md) - Sección 2

#### PASO 9: Crear Organisms

```bash
# Ubicación: lib/features/dashboard/presentation/widgets/

1. vendedor_dashboard.dart
   - MetricsGrid + SalesLineChart + TopProductosList

2. gerente_dashboard.dart
   - MetricsGrid + MetaProgressBar + SalesLineChart + TopVendedoresList

3. admin_dashboard.dart
   - MetricsGrid + SalesComparisonChart + AlertasSystemaList
```

**Referencia**: [components_E003-HU-001.md](design/components_E003-HU-001.md) - Sección 3

#### PASO 10: Crear DashboardPage

```bash
# Ubicación: lib/features/dashboard/presentation/pages/

dashboard_page.dart
- BlocBuilder con polimorfismo según rol
- Routing: '/dashboard' (flat)
- AppBar con botón refresh
- Loading skeleton
```

**Referencia**: [components_E003-HU-001.md](design/components_E003-HU-001.md) - Sección 4

#### PASO 11: Agregar Routing

```dart
// En lib/main.dart
routes: {
  '/dashboard': (context) => DashboardPage(),  // ✅ FLAT
}
```

#### PASO 12: Tests

```bash
# Tests unitarios
test/features/dashboard/data/models/ - Tests de fromJson/toJson
test/features/dashboard/data/datasources/ - Tests de datasource (mocks)
test/features/dashboard/domain/usecases/ - Tests de usecases
test/features/dashboard/presentation/bloc/ - Tests de bloc

# Tests de widgets
test/shared/design_system/atoms/ - Tests de atoms
test/features/dashboard/presentation/widgets/ - Tests de molecules/organisms
```

---

## 📋 CHECKLIST DE VALIDACIÓN

### Frontend Logic
- [ ] Entities creadas con Equatable
- [ ] Models con fromJson/toJson (mapping exacto)
- [ ] Datasource con polimorfismo por rol
- [ ] Repository implementado
- [ ] UseCases implementados
- [ ] Bloc con eventos y estados
- [ ] Tests unitarios (coverage 85%+)

### UI/UX
- [ ] Atoms implementados (MetricCard, TrendIndicator, MetaProgressBar)
- [ ] Molecules implementados (MetricsGrid, SalesLineChart, Listas)
- [ ] Organisms implementados (Dashboards por rol)
- [ ] DashboardPage con BlocBuilder
- [ ] Routing flat: '/dashboard'
- [ ] Responsive breakpoints (Mobile/Tablet/Desktop)
- [ ] Navegación desde cards (RN-006)
- [ ] Animaciones: hover, fade in
- [ ] Theme-aware (NO hardcodear colores)
- [ ] Tests de widgets (coverage 70%+)

### Integración
- [ ] Backend funcionando (Supabase Local corriendo)
- [ ] Frontend consume APIs correctamente
- [ ] Polimorfismo VENDEDOR/GERENTE/ADMIN funciona
- [ ] Mapping BD ↔ Dart correcto
- [ ] RLS policies validadas
- [ ] Performance < 2s carga de dashboard

---

## 🧪 TESTING MANUAL

### Preparar Usuarios de Prueba

1. **Registrar usuarios con roles**:
```bash
# En la app, registrar:
- admin@test.com (ADMIN)
- gerente@test.com (GERENTE)
- vendedor@test.com (VENDEDOR)
```

2. **Asignar tiendas** (en Supabase Studio):
```sql
-- Asignar gerente a Tienda Centro
INSERT INTO user_tiendas (user_id, tienda_id, activo) VALUES
('uuid-gerente', '11111111-1111-1111-1111-111111111111', true);

-- Asignar vendedor a Tienda Centro
INSERT INTO user_tiendas (user_id, tienda_id, activo) VALUES
('uuid-vendedor', '11111111-1111-1111-1111-111111111111', true);
```

3. **Crear ventas de prueba**:
```sql
-- Obtener UUID del vendedor
SELECT id FROM auth.users WHERE email = 'vendedor@test.com';

-- Crear 10 ventas
INSERT INTO ventas (tienda_id, vendedor_id, cliente_id, monto_total, estado, fecha_venta)
SELECT
    '11111111-1111-1111-1111-111111111111',
    'uuid-vendedor',
    (SELECT id FROM clientes ORDER BY RANDOM() LIMIT 1),
    100 + RANDOM() * 400,
    'COMPLETADA',
    NOW() - (RANDOM() * 30)::INTEGER * INTERVAL '1 day'
FROM generate_series(1, 10);
```

4. **Refrescar vistas**:
```sql
SELECT refresh_dashboard_metrics();
```

### Validar Dashboard

1. **Login como VENDEDOR** → Ver dashboard vendedor:
   - Card "Ventas de Hoy"
   - Card "Mis Comisiones"
   - Card "Órdenes Pendientes"
   - Gráfico de ventas mensuales

2. **Login como GERENTE** → Ver dashboard gerente:
   - Card "Ventas Totales" con tendencia
   - Card "Clientes Activos"
   - Indicador "Meta Mensual"
   - Top Vendedores

3. **Login como ADMIN** → Ver dashboard admin:
   - Cards consolidados
   - Alertas de sistema
   - Comparativa entre tiendas

---

## 🚀 COMANDO RÁPIDO (Después 4am)

```bash
# En un solo mensaje a Claude:
@flutter-expert: Implementa SPECS-FOR-AGENTS-E003-HU-001.md sección "Frontend"
@ux-ui-expert: Implementa SPECS-FOR-AGENTS-E003-HU-001.md sección "UX/UI"

# Documentación de referencia para ambos:
- models_E003-HU-001.md
- components_E003-HU-001.md
- mapping_E003-HU-001.md
- 00-CONVENTIONS.md
```

---

## 📊 PROGRESO ACTUAL

```
Backend:  ████████████████████ 100% ✅
Frontend: ░░░░░░░░░░░░░░░░░░░░   0% ⏳
UI:       ░░░░░░░░░░░░░░░░░░░░   0% ⏳
QA:       ░░░░░░░░░░░░░░░░░░░░   0% ⏳
───────────────────────────────────
Total:    ████████░░░░░░░░░░░░  25%
```

**Estimación**: 4-6 horas de desarrollo (Frontend + UI + QA)

---

**Última actualización**: 2025-10-06 11:30 UTC
**Próximo paso**: Implementar Frontend (Entities → Models → Datasource → Bloc)
