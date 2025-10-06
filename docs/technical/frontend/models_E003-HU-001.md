# Modelos Dart - E003-HU-001: Dashboard con Métricas

**Historia de Usuario**: E003-HU-001
**Responsable Diseño**: @web-architect-expert
**Fecha Diseño**: 2025-10-06
**Estado**: 🎨 Especificación de Diseño

---

## 📋 ÍNDICE

1. [Entities (Domain Layer)](#entities-domain-layer)
2. [Models (Data Layer)](#models-data-layer)
3. [Mapping BD ↔ Dart](#mapping-bd--dart)
4. [Ejemplo de Uso](#ejemplo-de-uso)

---

## 1. ENTITIES (Domain Layer)

### 1.1 `DashboardMetrics` (Entity Base)

```dart
// lib/features/dashboard/domain/entities/dashboard_metrics.dart

import 'package:equatable/equatable.dart';

/// Entity base para métricas de dashboard
/// Polimórfica según rol del usuario (Vendedor/Gerente/Admin)
abstract class DashboardMetrics extends Equatable {
  final UserRole rol;

  const DashboardMetrics({required this.rol});

  @override
  List<Object?> get props => [rol];
}
```

---

### 1.2 `VendedorMetrics` (Entity)

```dart
// lib/features/dashboard/domain/entities/vendedor_metrics.dart

import 'package:equatable/equatable.dart';
import 'dashboard_metrics.dart';

/// Métricas específicas para rol VENDEDOR
/// Implementa RN-001 (segmentación por rol)
class VendedorMetrics extends DashboardMetrics {
  final double ventasHoy;            // ← ventas_hoy
  final double comisionesMes;        // ← comisiones_mes
  final int ordenesPendientes;       // ← ordenes_pendientes
  final int productosStockBajo;      // ← productos_stock_bajo

  const VendedorMetrics({
    required this.ventasHoy,
    required this.comisionesMes,
    required this.ordenesPendientes,
    required this.productosStockBajo,
  }) : super(rol: UserRole.vendedor);

  @override
  List<Object?> get props => [
        rol,
        ventasHoy,
        comisionesMes,
        ordenesPendientes,
        productosStockBajo,
      ];
}
```

---

### 1.3 `GerenteMetrics` (Entity)

```dart
// lib/features/dashboard/domain/entities/gerente_metrics.dart

import 'package:equatable/equatable.dart';
import 'dashboard_metrics.dart';

/// Métricas específicas para rol GERENTE
/// Implementa RN-001, RN-007 (meta mensual)
class GerenteMetrics extends DashboardMetrics {
  final String tiendaId;             // ← tienda_id
  final double ventasTotales;        // ← ventas_totales
  final int clientesActivos;         // ← clientes_activos
  final int ordenesPendientes;       // ← ordenes_pendientes
  final int productosStockBajo;      // ← productos_stock_bajo
  final double metaMensual;          // ← meta_mensual
  final double ventasMesActual;      // ← ventas_mes_actual

  const GerenteMetrics({
    required this.tiendaId,
    required this.ventasTotales,
    required this.clientesActivos,
    required this.ordenesPendientes,
    required this.productosStockBajo,
    required this.metaMensual,
    required this.ventasMesActual,
  }) : super(rol: UserRole.gerente);

  /// Calcula progreso de meta mensual (0-100+)
  /// Implementa RN-007
  double get progresoMeta {
    if (metaMensual == 0) return 0;
    return (ventasMesActual / metaMensual) * 100;
  }

  /// Indica color del indicador de meta
  /// RN-007: < 50% y día > 20 = rojo, >= 50% < 100% = amarillo, >= 100% = verde
  MetaIndicator get metaIndicator {
    final progreso = progresoMeta;
    final diaDelMes = DateTime.now().day;

    if (progreso >= 100) return MetaIndicator.verde;
    if (progreso >= 50) return MetaIndicator.amarillo;
    if (progreso < 50 && diaDelMes > 20) return MetaIndicator.rojo;
    return MetaIndicator.amarillo;
  }

  @override
  List<Object?> get props => [
        rol,
        tiendaId,
        ventasTotales,
        clientesActivos,
        ordenesPendientes,
        productosStockBajo,
        metaMensual,
        ventasMesActual,
      ];
}

enum MetaIndicator { verde, amarillo, rojo }
```

---

### 1.4 `AdminMetrics` (Entity)

```dart
// lib/features/dashboard/domain/entities/admin_metrics.dart

import 'package:equatable/equatable.dart';
import 'dashboard_metrics.dart';

/// Métricas consolidadas para rol ADMIN
/// Implementa RN-001
class AdminMetrics extends DashboardMetrics {
  final double ventasTotalesGlobal;     // ← ventas_totales_global
  final int clientesActivosGlobal;      // ← clientes_activos_global
  final int ordenesPendientesGlobal;    // ← ordenes_pendientes_global
  final int tiendasActivas;             // ← tiendas_activas
  final int productosStockCritico;      // ← productos_stock_critico

  const AdminMetrics({
    required this.ventasTotalesGlobal,
    required this.clientesActivosGlobal,
    required this.ordenesPendientesGlobal,
    required this.tiendasActivas,
    required this.productosStockCritico,
  }) : super(rol: UserRole.admin);

  @override
  List<Object?> get props => [
        rol,
        ventasTotalesGlobal,
        clientesActivosGlobal,
        ordenesPendientesGlobal,
        tiendasActivas,
        productosStockCritico,
      ];
}
```

---

### 1.5 `SalesChartData` (Entity)

```dart
// lib/features/dashboard/domain/entities/sales_chart_data.dart

import 'package:equatable/equatable.dart';

/// Datos de gráfico de ventas mensuales
class SalesChartData extends Equatable {
  final String mes;          // ← "2025-10" (formato YYYY-MM)
  final double ventas;       // ← monto total de ventas del mes

  const SalesChartData({
    required this.mes,
    required this.ventas,
  });

  /// Convierte mes string a DateTime para ordenamiento
  DateTime get mesDateTime => DateTime.parse('$mes-01');

  /// Formatea mes para mostrar en UI ("Oct 2025")
  String get mesFormateado {
    final fecha = mesDateTime;
    final meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                   'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  List<Object?> get props => [mes, ventas];
}
```

---

### 1.6 `TopProducto` (Entity)

```dart
// lib/features/dashboard/domain/entities/top_producto.dart

import 'package:equatable/equatable.dart';

/// Producto en ranking de más vendidos
/// Implementa RN-005
class TopProducto extends Equatable {
  final String productoId;       // ← producto_id
  final String nombre;           // ← nombre
  final int cantidadVendida;     // ← cantidad_vendida

  const TopProducto({
    required this.productoId,
    required this.nombre,
    required this.cantidadVendida,
  });

  @override
  List<Object?> get props => [productoId, nombre, cantidadVendida];
}
```

---

### 1.7 `TopVendedor` (Entity)

```dart
// lib/features/dashboard/domain/entities/top_vendedor.dart

import 'package:equatable/equatable.dart';

/// Vendedor en ranking de top ventas
/// Implementa RN-005
class TopVendedor extends Equatable {
  final String vendedorId;          // ← vendedor_id
  final String nombreCompleto;      // ← nombre_completo
  final double ventasTotales;       // ← ventas_totales
  final int numTransacciones;       // ← num_transacciones

  const TopVendedor({
    required this.vendedorId,
    required this.nombreCompleto,
    required this.ventasTotales,
    required this.numTransacciones,
  });

  @override
  List<Object?> get props => [
        vendedorId,
        nombreCompleto,
        ventasTotales,
        numTransacciones,
      ];
}
```

---

### 1.8 `TransaccionReciente` (Entity)

```dart
// lib/features/dashboard/domain/entities/transaccion_reciente.dart

import 'package:equatable/equatable.dart';

/// Transacción reciente para dashboard
class TransaccionReciente extends Equatable {
  final String ventaId;              // ← venta_id
  final DateTime fechaVenta;         // ← fecha_venta
  final double montoTotal;           // ← monto_total
  final String estado;               // ← estado (ENUM como string)
  final String? clienteNombre;       // ← cliente_nombre (nullable)
  final String vendedorNombre;       // ← vendedor_nombre

  const TransaccionReciente({
    required this.ventaId,
    required this.fechaVenta,
    required this.montoTotal,
    required this.estado,
    this.clienteNombre,
    required this.vendedorNombre,
  });

  /// Formatea fecha para mostrar ("Hace 2 horas")
  String get fechaRelativa {
    final diferencia = DateTime.now().difference(fechaVenta);
    if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} horas';
    } else {
      return 'Hace ${diferencia.inDays} días';
    }
  }

  @override
  List<Object?> get props => [
        ventaId,
        fechaVenta,
        montoTotal,
        estado,
        clienteNombre,
        vendedorNombre,
      ];
}
```

---

### 1.9 `ProductoStockBajo` (Entity)

```dart
// lib/features/dashboard/domain/entities/producto_stock_bajo.dart

import 'package:equatable/equatable.dart';

/// Producto con stock bajo o crítico
/// Implementa RN-003
class ProductoStockBajo extends Equatable {
  final String productoId;       // ← producto_id
  final String nombre;           // ← nombre
  final int stockActual;         // ← stock_actual
  final int stockMaximo;         // ← stock_maximo
  final int porcentajeStock;     // ← porcentaje_stock
  final NivelAlerta nivelAlerta; // ← nivel_alerta

  const ProductoStockBajo({
    required this.productoId,
    required this.nombre,
    required this.stockActual,
    required this.stockMaximo,
    required this.porcentajeStock,
    required this.nivelAlerta,
  });

  @override
  List<Object?> get props => [
        productoId,
        nombre,
        stockActual,
        stockMaximo,
        porcentajeStock,
        nivelAlerta,
      ];
}

enum NivelAlerta {
  critico, // < 5 unidades o < 10%
  bajo,    // < 20%
}
```

---

## 2. MODELS (Data Layer)

### 2.1 `VendedorMetricsModel`

```dart
// lib/features/dashboard/data/models/vendedor_metrics_model.dart

import 'package:system_web_medias/features/dashboard/domain/entities/vendedor_metrics.dart';

/// Model que extiende Entity y agrega serialización JSON
class VendedorMetricsModel extends VendedorMetrics {
  const VendedorMetricsModel({
    required super.ventasHoy,
    required super.comisionesMes,
    required super.ordenesPendientes,
    required super.productosStockBajo,
  });

  /// Mapping desde JSON (Backend snake_case → Dart camelCase)
  factory VendedorMetricsModel.fromJson(Map<String, dynamic> json) {
    return VendedorMetricsModel(
      ventasHoy: (json['ventas_hoy'] as num).toDouble(),
      comisionesMes: (json['comisiones_mes'] as num).toDouble(),
      ordenesPendientes: json['ordenes_pendientes'] as int,
      productosStockBajo: json['productos_stock_bajo'] as int,
    );
  }

  /// Mapping a JSON (Dart camelCase → Backend snake_case)
  Map<String, dynamic> toJson() {
    return {
      'ventas_hoy': ventasHoy,
      'comisiones_mes': comisionesMes,
      'ordenes_pendientes': ordenesPendientes,
      'productos_stock_bajo': productosStockBajo,
    };
  }
}
```

---

### 2.2 `GerenteMetricsModel`

```dart
// lib/features/dashboard/data/models/gerente_metrics_model.dart

import 'package:system_web_medias/features/dashboard/domain/entities/gerente_metrics.dart';

class GerenteMetricsModel extends GerenteMetrics {
  const GerenteMetricsModel({
    required super.tiendaId,
    required super.ventasTotales,
    required super.clientesActivos,
    required super.ordenesPendientes,
    required super.productosStockBajo,
    required super.metaMensual,
    required super.ventasMesActual,
  });

  factory GerenteMetricsModel.fromJson(Map<String, dynamic> json) {
    return GerenteMetricsModel(
      tiendaId: json['tienda_id'] as String,
      ventasTotales: (json['ventas_totales'] as num).toDouble(),
      clientesActivos: json['clientes_activos'] as int,
      ordenesPendientes: json['ordenes_pendientes'] as int,
      productosStockBajo: json['productos_stock_bajo'] as int,
      metaMensual: (json['meta_mensual'] as num).toDouble(),
      ventasMesActual: (json['ventas_mes_actual'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tienda_id': tiendaId,
      'ventas_totales': ventasTotales,
      'clientes_activos': clientesActivos,
      'ordenes_pendientes': ordenesPendientes,
      'productos_stock_bajo': productosStockBajo,
      'meta_mensual': metaMensual,
      'ventas_mes_actual': ventasMesActual,
    };
  }
}
```

---

### 2.3 `AdminMetricsModel`

```dart
// lib/features/dashboard/data/models/admin_metrics_model.dart

import 'package:system_web_medias/features/dashboard/domain/entities/admin_metrics.dart';

class AdminMetricsModel extends AdminMetrics {
  const AdminMetricsModel({
    required super.ventasTotalesGlobal,
    required super.clientesActivosGlobal,
    required super.ordenesPendientesGlobal,
    required super.tiendasActivas,
    required super.productosStockCritico,
  });

  factory AdminMetricsModel.fromJson(Map<String, dynamic> json) {
    return AdminMetricsModel(
      ventasTotalesGlobal: (json['ventas_totales_global'] as num).toDouble(),
      clientesActivosGlobal: json['clientes_activos_global'] as int,
      ordenesPendientesGlobal: json['ordenes_pendientes_global'] as int,
      tiendasActivas: json['tiendas_activas'] as int,
      productosStockCritico: json['productos_stock_critico'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ventas_totales_global': ventasTotalesGlobal,
      'clientes_activos_global': clientesActivosGlobal,
      'ordenes_pendientes_global': ordenesPendientesGlobal,
      'tiendas_activas': tiendasActivas,
      'productos_stock_critico': productosStockCritico,
    };
  }
}
```

---

### 2.4 `SalesChartDataModel`

```dart
// lib/features/dashboard/data/models/sales_chart_data_model.dart

import 'package:system_web_medias/features/dashboard/domain/entities/sales_chart_data.dart';

class SalesChartDataModel extends SalesChartData {
  const SalesChartDataModel({
    required super.mes,
    required super.ventas,
  });

  factory SalesChartDataModel.fromJson(Map<String, dynamic> json) {
    return SalesChartDataModel(
      mes: json['mes'] as String,
      ventas: (json['ventas'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mes': mes,
      'ventas': ventas,
    };
  }
}
```

---

### 2.5 `TopProductoModel`

```dart
// lib/features/dashboard/data/models/top_producto_model.dart

import 'package:system_web_medias/features/dashboard/domain/entities/top_producto.dart';

class TopProductoModel extends TopProducto {
  const TopProductoModel({
    required super.productoId,
    required super.nombre,
    required super.cantidadVendida,
  });

  factory TopProductoModel.fromJson(Map<String, dynamic> json) {
    return TopProductoModel(
      productoId: json['producto_id'] as String,
      nombre: json['nombre'] as String,
      cantidadVendida: json['cantidad_vendida'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'nombre': nombre,
      'cantidad_vendida': cantidadVendida,
    };
  }
}
```

---

## 3. MAPPING BD ↔ DART

### 3.1 Tabla Completa de Mapping

| Campo BD (snake_case) | Modelo Dart (camelCase) | Tipo SQL | Tipo Dart |
|-----------------------|-------------------------|----------|-----------|
| `ventas_hoy` | `ventasHoy` | `DECIMAL(12,2)` | `double` |
| `comisiones_mes` | `comisionesMes` | `DECIMAL(10,2)` | `double` |
| `ordenes_pendientes` | `ordenesPendientes` | `INTEGER` | `int` |
| `productos_stock_bajo` | `productosStockBajo` | `INTEGER` | `int` |
| `tienda_id` | `tiendaId` | `UUID` | `String` |
| `ventas_totales` | `ventasTotales` | `DECIMAL(12,2)` | `double` |
| `clientes_activos` | `clientesActivos` | `INTEGER` | `int` |
| `meta_mensual` | `metaMensual` | `DECIMAL(12,2)` | `double` |
| `ventas_mes_actual` | `ventasMesActual` | `DECIMAL(12,2)` | `double` |
| `ventas_totales_global` | `ventasTotalesGlobal` | `DECIMAL(12,2)` | `double` |
| `clientes_activos_global` | `clientesActivosGlobal` | `INTEGER` | `int` |
| `producto_id` | `productoId` | `UUID` | `String` |
| `cantidad_vendida` | `cantidadVendida` | `INTEGER` | `int` |
| `vendedor_id` | `vendedorId` | `UUID` | `String` |
| `nombre_completo` | `nombreCompleto` | `TEXT` | `String` |
| `num_transacciones` | `numTransacciones` | `INTEGER` | `int` |
| `venta_id` | `ventaId` | `UUID` | `String` |
| `fecha_venta` | `fechaVenta` | `TIMESTAMP WITH TIME ZONE` | `DateTime` |
| `monto_total` | `montoTotal` | `DECIMAL(12,2)` | `double` |
| `cliente_nombre` | `clienteNombre` | `TEXT` | `String?` |
| `vendedor_nombre` | `vendedorNombre` | `TEXT` | `String` |
| `stock_actual` | `stockActual` | `INTEGER` | `int` |
| `stock_maximo` | `stockMaximo` | `INTEGER` | `int` |
| `porcentaje_stock` | `porcentajeStock` | `INTEGER` | `int` |
| `nivel_alerta` | `nivelAlerta` | `TEXT` | `NivelAlerta` (enum) |

---

## 4. EJEMPLO DE USO

### 4.1 Datasource

```dart
// lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart

Future<DashboardMetrics> getMetrics(String userId) async {
  final response = await supabase.rpc('get_dashboard_metrics', params: {
    'p_user_id': userId,
  });

  final result = response as Map<String, dynamic>;

  if (result['success'] == true) {
    final data = result['data'] as Map<String, dynamic>;
    final rol = data['rol'] as String;

    // Polimorfismo según rol
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
  } else {
    // Manejo de errores (ver mapping_E003-HU-001.md)
    throw _handleError(result['error']);
  }
}
```

---

## ✅ CÓDIGO FINAL IMPLEMENTADO

**Status**: 🎨 Pendiente de Implementación

_Esta sección será completada por @flutter-expert después de implementar los modelos._

---

**Próximos Pasos**:
1. @flutter-expert: Crear entities en `domain/`
2. @flutter-expert: Crear models en `data/models/`
3. @flutter-expert: Implementar tests unitarios para cada modelo
