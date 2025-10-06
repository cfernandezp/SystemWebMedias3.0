# SPECS para Agentes - E003-HU-001: Dashboard con Métricas

**Historia de Usuario**: E003-HU-001
**Fecha**: 2025-10-06
**Arquitecto**: @web-architect-expert

---

## 🎯 RESUMEN EJECUTIVO

Implementar dashboard con métricas personalizadas por rol (VENDEDOR/GERENTE/ADMIN) que muestra:
- Cards de métricas clave (ventas, comisiones, stock, órdenes)
- Gráficos de ventas mensuales (últimos 6 meses)
- Rankings (top productos, top vendedores)
- Transacciones recientes
- Alertas de stock bajo

---

## 📋 ASIGNACIÓN DE TAREAS

### @supabase-expert: Backend (Prioridad 1)

**Archivos a crear**:
```
supabase/migrations/YYYYMMDDHHMMSS_e003_hu001_dashboard_metrics.sql
```

**Leer antes de implementar**:
- [schema_E003-HU-001.md](backend/schema_E003-HU-001.md) ← Schema completo
- [apis_E003-HU-001.md](backend/apis_E003-HU-001.md) ← Funciones SQL
- [00-CONVENTIONS.md](00-CONVENTIONS.md) ← Convenciones obligatorias

**Checklist**:
- [ ] Crear tablas: `tiendas`, `productos`, `clientes`, `ventas`, `ventas_detalles`, `comisiones`, `user_tiendas`
- [ ] Crear ENUM `venta_estado`
- [ ] Crear vistas materializadas: `dashboard_vendedor_metrics`, `dashboard_gerente_metrics`, `dashboard_admin_metrics`
- [ ] Crear función `get_dashboard_metrics(p_user_id UUID)` con polimorfismo por rol
- [ ] Crear función `get_sales_chart_data(p_user_id UUID, p_months INTEGER)`
- [ ] Crear función `get_top_productos(p_user_id UUID, p_limit INTEGER)`
- [ ] Crear función `get_top_vendedores(p_user_id UUID, p_limit INTEGER)`
- [ ] Crear función `get_transacciones_recientes(p_user_id UUID, p_limit INTEGER)`
- [ ] Crear función `get_productos_stock_bajo(p_user_id UUID)`
- [ ] Crear función `refresh_dashboard_metrics()`
- [ ] Crear índices de performance (ver schema)
- [ ] Crear RLS policies (VENDEDOR/GERENTE/ADMIN)
- [ ] Poblar datos de prueba (seed): 3 tiendas, 30 productos, 50 clientes, 200 ventas
- [ ] Tests manuales en Supabase Studio
- [ ] Actualizar sección "SQL Final Implementado" en schema_E003-HU-001.md

**Validaciones críticas**:
```sql
-- ✅ Formato JSON estándar
{ "success": true, "data": {...} }
{ "success": false, "error": {"code": "...", "message": "...", "hint": "..."} }

-- ✅ Variables de error con v_error_hint (NO usar PG_EXCEPTION_HINT)
DECLARE
    v_error_hint TEXT;
BEGIN
    ...
    v_error_hint := 'user_not_authorized';
    RAISE EXCEPTION '...';
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', COALESCE(v_error_hint, 'unknown')
            )
        );
END;
```

---

### @flutter-expert: Frontend Logic (Prioridad 2)

**Archivos a crear**:
```
lib/features/dashboard/
├── domain/
│   ├── entities/
│   │   ├── dashboard_metrics.dart
│   │   ├── vendedor_metrics.dart
│   │   ├── gerente_metrics.dart
│   │   ├── admin_metrics.dart
│   │   ├── sales_chart_data.dart
│   │   ├── top_producto.dart
│   │   ├── top_vendedor.dart
│   │   ├── transaccion_reciente.dart
│   │   └── producto_stock_bajo.dart
│   ├── repositories/
│   │   └── dashboard_repository.dart
│   └── usecases/
│       ├── get_dashboard_metrics.dart
│       ├── get_sales_chart.dart
│       └── get_top_productos.dart
├── data/
│   ├── models/
│   │   ├── vendedor_metrics_model.dart
│   │   ├── gerente_metrics_model.dart
│   │   ├── admin_metrics_model.dart
│   │   ├── sales_chart_data_model.dart
│   │   ├── top_producto_model.dart
│   │   ├── top_vendedor_model.dart
│   │   └── transaccion_reciente_model.dart
│   ├── datasources/
│   │   └── dashboard_remote_datasource.dart
│   └── repositories/
│       └── dashboard_repository_impl.dart
└── presentation/
    └── bloc/
        ├── dashboard_bloc.dart
        ├── dashboard_event.dart
        └── dashboard_state.dart

test/features/dashboard/
├── data/models/ (tests)
├── data/datasources/ (tests)
├── domain/usecases/ (tests)
└── presentation/bloc/ (tests)
```

**Leer antes de implementar**:
- [models_E003-HU-001.md](frontend/models_E003-HU-001.md) ← Modelos completos
- [mapping_E003-HU-001.md](integration/mapping_E003-HU-001.md) ← Mapping snake_case ↔ camelCase
- [00-CONVENTIONS.md](00-CONVENTIONS.md) ← Convenciones obligatorias

**Checklist**:
- [ ] Crear entities (abstract `DashboardMetrics` + 3 concretas)
- [ ] Crear models con `fromJson()` y `toJson()` (mapping exacto)
- [ ] Implementar `DashboardRemoteDataSource` con polimorfismo por rol
- [ ] Implementar manejo de errores (hints → excepciones)
- [ ] Implementar `DashboardRepository` (abstract + impl)
- [ ] Implementar UseCases
- [ ] Implementar `DashboardBloc` (eventos: Load/Refresh, estados: Loading/Loaded/Error)
- [ ] Tests unitarios de models (coverage 90%+)
- [ ] Tests de datasource (mocks)
- [ ] Tests de repository
- [ ] Tests de usecases
- [ ] Tests de bloc
- [ ] Actualizar sección "Código Final Implementado" en models_E003-HU-001.md

**Ejemplo crítico de polimorfismo**:
```dart
// Datasource
Future<DashboardMetrics> getMetrics(String userId) async {
  final response = await supabase.rpc('get_dashboard_metrics', params: {
    'p_user_id': userId,
  });

  final result = response as Map<String, dynamic>;

  if (result['success'] == true) {
    final data = result['data'] as Map<String, dynamic>;
    final rol = data['rol'] as String;

    // ✅ Polimorfismo según rol
    switch (rol) {
      case 'VENDEDOR':
        return VendedorMetricsModel.fromJson(data);
      case 'GERENTE':
        return GerenteMetricsModel.fromJson(data);
      case 'ADMIN':
        return AdminMetricsModel.fromJson(data);
      default:
        throw ServerException('Rol no reconocido', 500);
    }
  }

  throw _mapError(result['error']);
}
```

---

### @ux-ui-expert: UI/UX (Prioridad 3)

**Archivos a crear**:
```
lib/shared/design_system/atoms/
├── metric_card.dart
├── trend_indicator.dart
└── meta_progress_bar.dart

lib/features/dashboard/presentation/
├── pages/
│   └── dashboard_page.dart
└── widgets/
    ├── vendedor_dashboard.dart
    ├── gerente_dashboard.dart
    ├── admin_dashboard.dart
    ├── metrics_grid.dart
    ├── sales_line_chart.dart
    ├── top_productos_list.dart
    ├── top_vendedores_list.dart
    └── transacciones_recientes_list.dart

test/shared/design_system/atoms/ (tests)
test/features/dashboard/presentation/widgets/ (tests)
```

**Leer antes de implementar**:
- [components_E003-HU-001.md](design/components_E003-HU-001.md) ← Componentes completos
- [tokens.md](design/tokens.md) ← Design System
- [00-CONVENTIONS.md](00-CONVENTIONS.md) ← Convenciones obligatorias

**Checklist**:
- [ ] Implementar `MetricCard` (atom) con hover, onTap, loading skeleton
- [ ] Implementar `TrendIndicator` (atom) verde/rojo/gris
- [ ] Implementar `MetaProgressBar` (atom) solo para Gerente
- [ ] Implementar `MetricsGrid` (molecule) responsive 3/2/1 columnas
- [ ] Implementar `SalesLineChart` (molecule) con fl_chart
- [ ] Implementar `TopProductosList` (molecule)
- [ ] Implementar `VendedorDashboard` (organism)
- [ ] Implementar `GerenteDashboard` (organism)
- [ ] Implementar `AdminDashboard` (organism)
- [ ] Implementar `DashboardPage` con BlocBuilder + polimorfismo
- [ ] Routing: `/dashboard` (flat, no prefijos)
- [ ] Responsive breakpoints (Desktop/Tablet/Mobile)
- [ ] Navegación desde cards (RN-006): onTap → Navigator.pushNamed()
- [ ] Animaciones: hover (scale 1.02), fade in
- [ ] Tests de widgets (coverage 70%+)
- [ ] Actualizar sección "Código Final Implementado" en components_E003-HU-001.md

**Ejemplo crítico de theme-aware**:
```dart
// ✅ CORRECTO: Siempre usar Theme.of(context)
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(DesignRadius.cards),
  ),
  child: ...
)

// ❌ INCORRECTO: NO hardcodear colores
Container(
  color: Color(0xFFFFFFFF),  // ❌
  ...
)
```

**Routing correcto**:
```dart
// ✅ En main.dart
routes: {
  '/dashboard': (context) => DashboardPage(),  // ✅ Flat
}

// ✅ En MetricCard onTap
Navigator.pushNamed(
  context,
  '/ventas',  // ✅ Flat (no '/dashboard/ventas')
  arguments: {'fecha': DateTime.now()},
);
```

---

### @qa-testing-expert: QA (Prioridad 4)

**Leer antes de validar**:
- [Historia de Usuario Original](../historias-usuario/E003-HU-001-dashboard-metricas.md)
- [00-INDEX-E003-HU-001.md](00-INDEX-E003-HU-001.md) ← Índice técnico

**Checklist de Criterios de Aceptación**:
- [ ] **CA-001**: Dashboard para Vendedor
  - [ ] Card "Ventas de Hoy" con monto y tendencia
  - [ ] Card "Mis Comisiones" del mes
  - [ ] Card "Productos en Stock" con alerta
  - [ ] Card "Órdenes Pendientes"
  - [ ] Gráfico "Mis Ventas por Mes" (6 meses)
  - [ ] Lista "Productos Más Vendidos" (top 5)

- [ ] **CA-002**: Dashboard para Gerente
  - [ ] Card "Ventas Totales" con tendencia
  - [ ] Card "Clientes Activos"
  - [ ] Card "Productos en Stock"
  - [ ] Card "Órdenes Pendientes"
  - [ ] Gráfico "Ventas por Mes" de la tienda
  - [ ] Lista "Top Vendedores"
  - [ ] Sección "Transacciones Recientes" (5)
  - [ ] Indicador "Meta Mensual" con progreso

- [ ] **CA-003**: Dashboard para Admin
  - [ ] Card "Ventas Totales" consolidadas
  - [ ] Card "Clientes Activos" global
  - [ ] Card "Productos en Stock" consolidado
  - [ ] Card "Órdenes Pendientes" globales
  - [ ] Gráfico "Ventas por Mes" comparativo
  - [ ] Gráfico "Productos Más Vendidos" global
  - [ ] Lista "Alertas del Sistema"
  - [ ] Sección "Acciones Rápidas"

- [ ] **CA-004**: Actualización en Tiempo Real
  - [ ] Botón "Actualizar" funcional
  - [ ] Métricas se refrescan correctamente
  - [ ] Animación de actualización

- [ ] **CA-005**: Interactividad de Métricas
  - [ ] Click en "Ventas de Hoy" → `/ventas?fecha=hoy`
  - [ ] Click en "Productos en Stock" → `/inventario?filtro=stock_bajo`
  - [ ] Click en "Órdenes Pendientes" → `/ordenes?estado=pendiente`
  - [ ] Click en "Clientes Activos" → `/clientes?estado=activo`

- [ ] **CA-006**: Visualización de Tendencias
  - [ ] Tendencia positiva (≥5%) → Verde con flecha arriba
  - [ ] Tendencia negativa (≤-5%) → Rojo con flecha abajo
  - [ ] Sin cambio significativo → Neutro

**Tests de Seguridad (RLS)**:
- [ ] VENDEDOR no puede ver datos de otros vendedores
- [ ] GERENTE solo ve datos de su tienda asignada
- [ ] ADMIN ve todos los datos consolidados
- [ ] Usuario sin rol/aprobación → Error 403

**Tests de Performance**:
- [ ] Carga de dashboard < 2 segundos
- [ ] Vistas materializadas refrescan correctamente
- [ ] Sin memory leaks en navegación repetida

**Tests Responsive**:
- [ ] Desktop (≥1200px): Grid 3 columnas
- [ ] Tablet (768-1199px): Grid 2 columnas
- [ ] Mobile (<768px): Grid 1 columna

---

## 🚀 ORDEN DE EJECUCIÓN

1. **@supabase-expert** (Día 1-2): Backend + seed + tests
2. **@flutter-expert** (Día 2-3): Models + Datasource + Bloc + tests
3. **@ux-ui-expert** (Día 3-4): UI + Responsive + tests
4. **@qa-testing-expert** (Día 4-5): Validación E2E + CA + Performance

---

## 📊 DEFINICIÓN DE TERMINADO (DoD)

- [x] Arquitectura diseñada (este documento)
- [ ] Backend implementado y testeado
- [ ] Frontend implementado y testeado
- [ ] UI implementada y testeada
- [ ] QA validó todos los CA
- [ ] Coverage: Models 90%+, UseCases 85%+, Widgets 70%+
- [ ] Docs actualizados con "Código Final Implementado"
- [ ] Datos de prueba poblados
- [ ] Performance validado (< 2s)
- [ ] RLS policies validadas
- [ ] Responsive validado (Mobile/Tablet/Desktop)

---

## 🔗 REFERENCIAS RÁPIDAS

| Documento | URL | Para Quién |
|-----------|-----|------------|
| **Schema BD** | [schema_E003-HU-001.md](backend/schema_E003-HU-001.md) | @supabase-expert |
| **APIs** | [apis_E003-HU-001.md](backend/apis_E003-HU-001.md) | @supabase-expert |
| **Modelos Dart** | [models_E003-HU-001.md](frontend/models_E003-HU-001.md) | @flutter-expert |
| **Mapping** | [mapping_E003-HU-001.md](integration/mapping_E003-HU-001.md) | @flutter-expert |
| **Componentes UI** | [components_E003-HU-001.md](design/components_E003-HU-001.md) | @ux-ui-expert |
| **Design System** | [tokens.md](design/tokens.md) | @ux-ui-expert |
| **Convenciones** | [00-CONVENTIONS.md](00-CONVENTIONS.md) | Todos |
| **Índice Técnico** | [00-INDEX-E003-HU-001.md](00-INDEX-E003-HU-001.md) | Todos |

---

**Arquitecto**: @web-architect-expert
**Fecha**: 2025-10-06
**Status**: ✅ Arquitectura Completa - Listo para Implementación en Paralelo
