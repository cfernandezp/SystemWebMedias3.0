# Componentes UI - E003-HU-001: Dashboard con Métricas

**Historia de Usuario**: E003-HU-001
**Responsable Diseño**: @web-architect-expert
**Fecha Diseño**: 2025-10-06
**Estado**: 🎨 Especificación de Diseño

---

## 📋 ÍNDICE

1. [Atoms (Componentes Base)](#atoms-componentes-base)
2. [Molecules (Componentes Compuestos)](#molecules-componentes-compuestos)
3. [Organisms (Componentes Complejos)](#organisms-componentes-complejos)
4. [Pages (Pantallas)](#pages-pantallas)
5. [Responsive Breakpoints](#responsive-breakpoints)

---

## 1. ATOMS (Componentes Base)

### 1.1 `MetricCard` (Atom)

**Descripción**: Card individual para mostrar una métrica con icono, título, valor y tendencia.

**Ubicación**: `lib/shared/design_system/atoms/metric_card.dart`

**Propiedades**:
```dart
class MetricCard extends StatelessWidget {
  final IconData icon;               // Icono de la métrica
  final String titulo;               // "Ventas de Hoy"
  final String valor;                // "$1,250.50"
  final String? subtitulo;           // "vs ayer" (opcional)
  final TrendIndicator? tendencia;   // Indicador de tendencia (opcional)
  final VoidCallback? onTap;         // Callback al hacer clic (RN-006)
  final Color? backgroundColor;      // Color de fondo (theme-aware)
  final Color? iconColor;            // Color del icono (theme-aware)

  const MetricCard({
    required this.icon,
    required this.titulo,
    required this.valor,
    this.subtitulo,
    this.tendencia,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
  });
}
```

**Diseño Visual**:
```
┌─────────────────────────────────────┐
│  📊  Ventas de Hoy                  │
│                                     │
│      $1,250.50                      │
│                                     │
│      ▲ +12.5% vs ayer    [verde]   │
└─────────────────────────────────────┘
```

**Especificaciones**:
- **Tamaño**: Ancho flexible, altura ~120px
- **Border Radius**: `12px` (DesignRadius.cards)
- **Padding**: `16px` (DesignDimensions.cardPadding)
- **Elevation**: `2` normal, `8` en hover (DesignElevation)
- **Animación Hover**: Scale `1.02`, duración `200ms`
- **Fuente Valor**: `headlineLarge` (28px bold)
- **Fuente Título**: `bodyLarge` (16px regular)

**Estados**:
- **Normal**: Background blanco, elevation 2
- **Hover**: Scale 1.02, elevation 8, cursor pointer
- **Pressed**: Scale 0.98
- **Loading**: Shimmer skeleton

**Theme-Aware**:
```dart
// ✅ CORRECTO
Container(
  decoration: BoxDecoration(
    color: backgroundColor ?? Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(DesignRadius.cards),
  ),
)
```

---

### 1.2 `TrendIndicator` (Atom)

**Descripción**: Indicador visual de tendencia (crecimiento/decrecimiento).

**Ubicación**: `lib/shared/design_system/atoms/trend_indicator.dart`

**Propiedades**:
```dart
class TrendIndicator extends StatelessWidget {
  final double porcentaje;        // 12.5 o -3.2
  final TrendType tipo;           // up, down, neutral
  final bool mostrarIcono;        // Mostrar flecha arriba/abajo

  const TrendIndicator({
    required this.porcentaje,
    required this.tipo,
    this.mostrarIcono = true,
  });
}

enum TrendType {
  up,      // Verde, flecha arriba
  down,    // Rojo, flecha abajo
  neutral, // Gris, sin flecha
}
```

**Diseño Visual**:
```
▲ +12.5%  [Verde]
▼ -3.2%   [Rojo]
● 0%      [Gris]
```

**Especificaciones**:
- **Colores**:
  - Verde: `DesignColors.success` (#4CAF50)
  - Rojo: `DesignColors.error` (#F44336)
  - Gris: `DesignColors.textSecondary` (#6B7280)
- **Iconos**:
  - Up: `Icons.arrow_upward`
  - Down: `Icons.arrow_downward`
  - Neutral: `Icons.circle` (pequeño)
- **Fuente**: `bodyMedium` (14px)

**Lógica de Negocio** (RN-002):
```dart
TrendType _calcularTipo(double porcentaje) {
  if (porcentaje >= 5) return TrendType.up;
  if (porcentaje <= -5) return TrendType.down;
  return TrendType.neutral;
}
```

---

### 1.3 `MetaProgressBar` (Atom)

**Descripción**: Barra de progreso para meta mensual (solo Gerente).

**Ubicación**: `lib/shared/design_system/atoms/meta_progress_bar.dart`

**Propiedades**:
```dart
class MetaProgressBar extends StatelessWidget {
  final double progreso;          // 0-100+ (puede ser > 100)
  final double metaMensual;       // Ej: 50000.00
  final double ventasActuales;    // Ej: 35000.00
  final MetaIndicator indicador;  // verde, amarillo, rojo

  const MetaProgressBar({
    required this.progreso,
    required this.metaMensual,
    required this.ventasActuales,
    required this.indicador,
  });
}
```

**Diseño Visual**:
```
Meta Mensual: $35,000 / $50,000 (70%)
[████████████░░░░░░░░] 70%

Colores:
- Verde: >= 100%
- Amarillo: 50-99%
- Rojo: < 50% y día > 20 del mes
```

**Especificaciones**:
- **Altura**: `8px`
- **Border Radius**: `4px`
- **Background**: Gris claro (#E5E7EB)
- **Foreground**: Color según indicador
- **Animación**: Linear progress con duración `300ms`

---

## 2. MOLECULES (Componentes Compuestos)

### 2.1 `MetricsGrid` (Molecule)

**Descripción**: Grid responsive de MetricCards.

**Ubicación**: `lib/features/dashboard/presentation/widgets/metrics_grid.dart`

**Propiedades**:
```dart
class MetricsGrid extends StatelessWidget {
  final List<MetricCardData> metricas;  // Lista de datos para cards

  const MetricsGrid({required this.metricas});
}
```

**Layout Responsive**:
```dart
// Desktop (>= 1200px): 3 columnas
GridView.count(crossAxisCount: 3, ...)

// Tablet (768-1199px): 2 columnas
GridView.count(crossAxisCount: 2, ...)

// Mobile (< 768px): 1 columna
GridView.count(crossAxisCount: 1, ...)
```

**Spacing**:
- **Gap entre cards**: `16px` (DesignSpacing.md)
- **Padding externo**: `16px`

---

### 2.2 `SalesLineChart` (Molecule)

**Descripción**: Gráfico de línea para ventas mensuales (últimos 6 meses).

**Ubicación**: `lib/features/dashboard/presentation/widgets/sales_line_chart.dart`

**Propiedades**:
```dart
class SalesLineChart extends StatelessWidget {
  final List<SalesChartData> datos;  // Datos de ventas por mes
  final String titulo;               // "Mis Ventas por Mes"

  const SalesLineChart({
    required this.datos,
    required this.titulo,
  });
}
```

**Diseño Visual**:
```
Mis Ventas por Mes
┌────────────────────────────────────┐
│ 50k│                           ●   │
│    │                      ●─────   │
│ 40k│               ●─────          │
│    │          ●─────               │
│ 30k│     ●─────                    │
│    └──────────────────────────────│
│     Oct  Nov  Dic  Ene  Feb  Mar  │
└────────────────────────────────────┘
```

**Especificaciones**:
- **Librería**: `fl_chart` package
- **Color línea**: `primaryTurquoise` (#4ECDC4)
- **Color puntos**: `primaryDark` (#26A69A)
- **Gradient bajo línea**: Turquesa con alpha 0.2
- **Animación**: Fade in + slide up (300ms)
- **Altura**: `250px` en desktop, `200px` en mobile
- **Interactividad**: Tooltip al hacer hover en puntos

---

### 2.3 `TopProductosList` (Molecule)

**Descripción**: Lista de top 5 productos más vendidos.

**Ubicación**: `lib/features/dashboard/presentation/widgets/top_productos_list.dart`

**Propiedades**:
```dart
class TopProductosList extends StatelessWidget {
  final List<TopProducto> productos;  // Top 5 productos

  const TopProductosList({required this.productos});
}
```

**Diseño Visual**:
```
Productos Más Vendidos

1. Medias Deportivas Negras      120 uds
2. Medias Ejecutivas Grises       95 uds
3. Medias Casuales Blancas        80 uds
4. Medias Térmicas Azules         72 uds
5. Medias Running Rojas           65 uds
```

**Especificaciones**:
- **Item altura**: `48px`
- **Icono ranking**: Badge circular con número (1-5)
- **Fuente nombre**: `bodyLarge` (16px)
- **Fuente cantidad**: `bodyMedium` bold (14px)
- **Dividers**: Entre items (color gris claro)

---

### 2.4 `TransaccionesRecientesList` (Molecule)

**Descripción**: Lista de últimas 5 transacciones (solo Gerente/Admin).

**Ubicación**: `lib/features/dashboard/presentation/widgets/transacciones_recientes_list.dart`

**Propiedades**:
```dart
class TransaccionesRecientesList extends StatelessWidget {
  final List<TransaccionReciente> transacciones;

  const TransaccionesRecientesList({required this.transacciones});
}
```

**Diseño Visual**:
```
Transacciones Recientes

Carlos Ramírez               $1,250.50
Vendedor: Juan Pérez         Hace 2 horas
──────────────────────────────────────

Ana López                    $850.00
Vendedor: María González     Hace 3 horas
──────────────────────────────────────
```

**Especificaciones**:
- **Item altura**: `72px`
- **Avatar**: Iniciales del cliente (circular)
- **Estado visual**: Badge de color según estado
  - `COMPLETADA`: Verde
  - `PENDIENTE`: Amarillo
  - `CANCELADA`: Rojo

---

## 3. ORGANISMS (Componentes Complejos)

### 3.1 `VendedorDashboard` (Organism)

**Descripción**: Dashboard completo para rol VENDEDOR.

**Ubicación**: `lib/features/dashboard/presentation/widgets/vendedor_dashboard.dart`

**Estructura**:
```dart
Column(
  children: [
    // Fila 1: Cards de métricas (grid 2x2)
    MetricsGrid(metricas: [
      MetricCard(titulo: 'Ventas de Hoy', ...),
      MetricCard(titulo: 'Mis Comisiones', ...),
      MetricCard(titulo: 'Productos en Stock', ...),
      MetricCard(titulo: 'Órdenes Pendientes', ...),
    ]),

    // Fila 2: Gráfico de ventas
    SalesLineChart(datos: ventasPorMes, ...),

    // Fila 3: Top productos
    TopProductosList(productos: topProductos),
  ],
)
```

**Layout Responsive**:
- **Desktop**: Grid 2x2 + Gráfico + Lista
- **Mobile**: Columna única (scroll vertical)

---

### 3.2 `GerenteDashboard` (Organism)

**Descripción**: Dashboard completo para rol GERENTE.

**Ubicación**: `lib/features/dashboard/presentation/widgets/gerente_dashboard.dart`

**Estructura**:
```dart
Column(
  children: [
    // Fila 1: Cards de métricas (grid 2x2)
    MetricsGrid(metricas: [
      MetricCard(titulo: 'Ventas Totales', ...),
      MetricCard(titulo: 'Clientes Activos', ...),
      MetricCard(titulo: 'Productos en Stock', ...),
      MetricCard(titulo: 'Órdenes Pendientes', ...),
    ]),

    // Fila 2: Meta Mensual
    MetaProgressBar(progreso: 70, ...),

    // Fila 3: Gráfico + Top Vendedores
    Row(
      children: [
        SalesLineChart(datos: ventasPorMes, ...),
        TopVendedoresList(vendedores: topVendedores),
      ],
    ),

    // Fila 4: Transacciones Recientes
    TransaccionesRecientesList(transacciones: recientes),
  ],
)
```

---

### 3.3 `AdminDashboard` (Organism)

**Descripción**: Dashboard completo para rol ADMIN.

**Ubicación**: `lib/features/dashboard/presentation/widgets/admin_dashboard.dart`

**Estructura**:
```dart
Column(
  children: [
    // Fila 1: Cards de métricas (grid 2x3 en desktop)
    MetricsGrid(metricas: [
      MetricCard(titulo: 'Ventas Totales Global', ...),
      MetricCard(titulo: 'Clientes Activos Global', ...),
      MetricCard(titulo: 'Órdenes Pendientes', ...),
      MetricCard(titulo: 'Tiendas Activas', ...),
      MetricCard(titulo: 'Productos Stock Crítico', ...),
    ]),

    // Fila 2: Gráfico comparativo entre tiendas
    SalesComparisonChart(datos: ventasPorTienda, ...),

    // Fila 3: Alertas del Sistema
    AlertasSystemaList(alertas: alertas),

    // Fila 4: Acciones Rápidas
    AccionesRapidasGrid(acciones: [
      'Nueva Venta', 'Productos', 'Inventario', 'Reportes'
    ]),
  ],
)
```

---

## 4. PAGES (Pantallas)

### 4.1 `DashboardPage` (Page)

**Descripción**: Página principal del dashboard que muestra el organism correcto según rol.

**Ubicación**: `lib/features/dashboard/presentation/pages/dashboard_page.dart`

**Estructura**:
```dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => context.read<DashboardBloc>().add(RefreshDashboard()),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return DashboardLoadingSkeleton();
          }

          if (state is DashboardLoaded) {
            final metrics = state.metrics;

            // Polimorfismo según rol
            if (metrics is VendedorMetrics) {
              return VendedorDashboard(metrics: metrics);
            } else if (metrics is GerenteMetrics) {
              return GerenteDashboard(metrics: metrics);
            } else if (metrics is AdminMetrics) {
              return AdminDashboard(metrics: metrics);
            }
          }

          if (state is DashboardError) {
            return ErrorDisplay(mensaje: state.mensaje);
          }

          return Container();
        },
      ),
    );
  }
}
```

**Routing** (según 00-CONVENTIONS.md):
```dart
'/dashboard': (context) => DashboardPage(),  // ✅ Ruta flat
```

---

## 5. RESPONSIVE BREAKPOINTS

### 5.1 Comportamiento por Device

**Desktop (>= 1200px)**:
- **Layout**: Sidebar fijo + Dashboard en grid 3 columnas
- **MetricsGrid**: 3 columnas
- **Gráficos**: Ancho completo o 50% en row
- **Touch targets**: Mínimo 44px

**Tablet (768-1199px)**:
- **Layout**: NavigationRail colapsible + Dashboard en grid 2 columnas
- **MetricsGrid**: 2 columnas
- **Gráficos**: Ancho completo
- **Touch targets**: Mínimo 44px

**Mobile (< 768px)**:
- **Layout**: Drawer oculto + BottomNavigation
- **MetricsGrid**: 1 columna (stack vertical)
- **Gráficos**: Ancho completo, altura reducida (200px)
- **Touch targets**: Mínimo 48px

---

## 6. LOADING SKELETONS

### 6.1 `DashboardLoadingSkeleton`

**Descripción**: Skeleton animado mientras cargan las métricas.

```dart
class DashboardLoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: MetricsGrid(
        metricas: List.generate(4, (_) => FakeMetricCard()),
      ),
    );
  }
}
```

---

## 7. INTERACTIVIDAD

### 7.1 Navegación desde Cards (RN-006)

**Implementación**:
```dart
MetricCard(
  titulo: 'Ventas de Hoy',
  valor: '\$1,250.50',
  onTap: () {
    Navigator.pushNamed(
      context,
      '/ventas',  // ✅ Ruta flat
      arguments: {
        'fecha': DateTime.now(),
      },
    );
  },
)
```

**Rutas de Navegación**:
- `'Ventas de Hoy'` → `/ventas?fecha=hoy`
- `'Productos en Stock'` → `/inventario?filtro=stock_bajo`
- `'Órdenes Pendientes'` → `/ordenes?estado=pendiente`
- `'Clientes Activos'` → `/clientes?estado=activo`

---

## 8. ANIMACIONES

### 8.1 Animaciones Estándar

**Cards Hover**:
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeInOut,
  transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
  ...
)
```

**Gráfico Fade In**:
```dart
FadeTransition(
  opacity: _animation,
  child: SlideTransition(
    position: _slideAnimation,
    child: SalesLineChart(...),
  ),
)
```

---

## ✅ CÓDIGO FINAL IMPLEMENTADO

**Status**: ✅ Implementado (2025-10-06)

### Atoms Implementados

**1. MetricCard** (`lib/shared/design_system/atoms/metric_card.dart`)
- ✅ Diseño con icono, título, valor y tendencia
- ✅ Animación hover: scale 1.02, elevation 2 → 8 (200ms)
- ✅ Loading skeleton con shimmer
- ✅ Navegación mediante onTap (RN-006)
- ✅ Theme-aware (usa Theme.of(context))
- ✅ Test coverage: 7 tests pasados

**2. TrendIndicator** (`lib/shared/design_system/atoms/trend_indicator.dart`)
- ✅ Factory constructor automático según RN-002
- ✅ Colores: Verde (≥+5%), Rojo (≤-5%), Gris (neutral)
- ✅ Iconos: flecha arriba, flecha abajo, círculo
- ✅ Formato porcentaje con signo

**3. MetaProgressBar** (`lib/shared/design_system/atoms/meta_progress_bar.dart`)
- ✅ Factory constructor según RN-007
- ✅ Colores: Verde (≥100%), Amarillo (50-99%), Rojo (<50% día >20)
- ✅ Animación linear progress 300ms
- ✅ Alerta crítica cuando meta en peligro

### Molecules Implementadas

**1. MetricsGrid** (`lib/features/dashboard/presentation/widgets/metrics_grid.dart`)
- ✅ Responsive: 3/2/1 columnas según breakpoints
- ✅ Layout adaptable con LayoutBuilder
- ✅ Gap 16px entre cards
- ✅ Loading state con skeletons

**2. SalesLineChart** (`lib/features/dashboard/presentation/widgets/sales_line_chart.dart`)
- ✅ Gráfico de línea con fl_chart
- ✅ Gradiente turquesa (#4ECDC4 → #26A69A)
- ✅ Animación fade in + slide up (300ms)
- ✅ Tooltips interactivos al hover
- ✅ Responsive: 250px desktop, 200px mobile
- ✅ Empty state con mensaje

**3. TopProductosList** (`lib/features/dashboard/presentation/widgets/top_productos_list.dart`)
- ✅ Lista top 5 productos
- ✅ Badge ranking (oro/plata/bronce)
- ✅ Dividers entre items
- ✅ Item altura 48px
- ✅ Empty state

**4. TopVendedoresList** (`lib/features/dashboard/presentation/widgets/top_vendedores_list.dart`)
- ✅ Lista top 5 vendedores
- ✅ Avatar con iniciales
- ✅ Badge ranking en avatar
- ✅ Monto y cantidad transacciones
- ✅ Empty state

**5. TransaccionesRecientesList** (`lib/features/dashboard/presentation/widgets/transacciones_recientes_list.dart`)
- ✅ Últimas 5 transacciones
- ✅ Avatar cliente con iniciales
- ✅ Badge estado (verde/amarillo/rojo)
- ✅ Timestamp relativo (Hace X horas)
- ✅ Item altura 72px
- ✅ Empty state

### Organisms Implementados

**1. VendedorDashboard** (`lib/features/dashboard/presentation/widgets/vendedor_dashboard.dart`)
- ✅ 4 cards métricas (ventas, comisiones, stock, órdenes)
- ✅ Gráfico ventas por mes
- ✅ Top productos más vendidos
- ✅ Navegación RN-006 desde cards
- ✅ Responsive: grid 2x2 desktop, columna mobile

**2. GerenteDashboard** (`lib/features/dashboard/presentation/widgets/gerente_dashboard.dart`)
- ✅ 4 cards métricas (ventas totales, clientes, stock, órdenes)
- ✅ Meta mensual con progress bar
- ✅ Gráfico + Top vendedores (row desktop, stack mobile)
- ✅ Transacciones recientes
- ✅ Navegación RN-006

**3. AdminDashboard** (`lib/features/dashboard/presentation/widgets/admin_dashboard.dart`)
- ✅ 6 cards métricas globales (grid 3x2)
- ✅ Gráfico ventas consolidadas
- ✅ Top productos global
- ✅ Acciones rápidas (grid 4/2 columnas)
- ✅ Navegación RN-006

### Pages Implementadas

**1. DashboardPage** (`lib/features/dashboard/presentation/pages/dashboard_page.dart`)
- ✅ Routing flat: '/dashboard'
- ✅ AppBar con botón refresh
- ✅ Polimorfismo según rol (VENDEDOR/GERENTE/ADMIN)
- ✅ Loading skeleton
- ✅ Manejo de errores con retry
- ✅ Switch temporal de roles para demo
- ✅ AuthGuard protección

### Routing

**Ruta agregada en main.dart**:
```dart
'/dashboard': (context) => const AuthGuard(child: DashboardPage()),
```

### Tests Implementados

**Widget Tests**:
- ✅ `test/shared/design_system/atoms/metric_card_test.dart` (7 tests pasados)
- ⏳ Pending: molecules y organisms tests

### Cambios vs Diseño Inicial

**1. Imports corregidos**:
- Cambiado de `sistema_venta_medias` a `system_web_medias` (nombre correcto del paquete)

**2. Mock Data**:
- DashboardPage incluye datos mock temporales para demo
- Switch de roles manual mientras se implementa BLoC

**3. Deprecation warnings**:
- Uso de `.withOpacity()` en fl_chart (deprecado en Material 3)
- Futuro: migrar a `.withValues()` cuando fl_chart actualice

### Análisis de Código

```bash
flutter analyze lib/features/dashboard
```
**Resultado**: ✅ Sin errores, solo warnings deprecation de fl_chart

---

**Próximos Pasos**:
1. ✅ COMPLETADO - Atoms implementados
2. ✅ COMPLETADO - Molecules implementadas
3. ✅ COMPLETADO - Organisms implementados
4. ✅ COMPLETADO - DashboardPage con routing
5. ⏳ PENDIENTE - Tests completos de molecules y organisms
6. ⏳ PENDIENTE - Integración con DashboardBloc (depende de @flutter-expert)
