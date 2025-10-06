# Mapping Backend ↔ Frontend - E003-HU-001: Dashboard con Métricas

**Historia de Usuario**: E003-HU-001
**Responsable Diseño**: @web-architect-expert
**Fecha Diseño**: 2025-10-06
**Estado**: 🎨 Especificación de Diseño

---

## 📋 ÍNDICE

1. [Tabla Completa de Mapping](#tabla-completa-de-mapping)
2. [Mapping por Endpoint](#mapping-por-endpoint)
3. [Manejo de Errores](#manejo-de-errores)
4. [Ejemplo Completo de Datasource](#ejemplo-completo-de-datasource)

---

## 1. TABLA COMPLETA DE MAPPING

### 1.1 Métricas de Vendedor

| Campo Backend (snake_case) | Campo Dart (camelCase) | Tipo SQL | Tipo Dart | Ejemplo BD | Ejemplo Dart |
|----------------------------|------------------------|----------|-----------|------------|--------------|
| `rol` | `rol` | `TEXT` | `UserRole` (enum) | `"VENDEDOR"` | `UserRole.vendedor` |
| `ventas_hoy` | `ventasHoy` | `DECIMAL(12,2)` | `double` | `1250.50` | `1250.50` |
| `comisiones_mes` | `comisionesMes` | `DECIMAL(10,2)` | `double` | `350.75` | `350.75` |
| `ordenes_pendientes` | `ordenesPendientes` | `INTEGER` | `int` | `3` | `3` |
| `productos_stock_bajo` | `productosStockBajo` | `INTEGER` | `int` | `5` | `5` |

---

### 1.2 Métricas de Gerente

| Campo Backend (snake_case) | Campo Dart (camelCase) | Tipo SQL | Tipo Dart | Ejemplo BD | Ejemplo Dart |
|----------------------------|------------------------|----------|-----------|------------|--------------|
| `rol` | `rol` | `TEXT` | `UserRole` (enum) | `"GERENTE"` | `UserRole.gerente` |
| `tienda_id` | `tiendaId` | `UUID` | `String` | `"uuid-123"` | `"uuid-123"` |
| `ventas_totales` | `ventasTotales` | `DECIMAL(12,2)` | `double` | `15000.00` | `15000.0` |
| `clientes_activos` | `clientesActivos` | `INTEGER` | `int` | `45` | `45` |
| `ordenes_pendientes` | `ordenesPendientes` | `INTEGER` | `int` | `12` | `12` |
| `productos_stock_bajo` | `productosStockBajo` | `INTEGER` | `int` | `8` | `8` |
| `meta_mensual` | `metaMensual` | `DECIMAL(12,2)` | `double` | `50000.00` | `50000.0` |
| `ventas_mes_actual` | `ventasMesActual` | `DECIMAL(12,2)` | `double` | `35000.00` | `35000.0` |

---

### 1.3 Métricas de Admin

| Campo Backend (snake_case) | Campo Dart (camelCase) | Tipo SQL | Tipo Dart | Ejemplo BD | Ejemplo Dart |
|----------------------------|------------------------|----------|-----------|------------|--------------|
| `rol` | `rol` | `TEXT` | `UserRole` (enum) | `"ADMIN"` | `UserRole.admin` |
| `ventas_totales_global` | `ventasTotalesGlobal` | `DECIMAL(12,2)` | `double` | `125000.00` | `125000.0` |
| `clientes_activos_global` | `clientesActivosGlobal` | `INTEGER` | `int` | `320` | `320` |
| `ordenes_pendientes_global` | `ordenesPendientesGlobal` | `INTEGER` | `int` | `48` | `48` |
| `tiendas_activas` | `tiendasActivas` | `INTEGER` | `int` | `5` | `5` |
| `productos_stock_critico` | `productosStockCritico` | `INTEGER` | `int` | `12` | `12` |

---

### 1.4 Datos de Gráfico de Ventas

| Campo Backend (snake_case) | Campo Dart (camelCase) | Tipo SQL | Tipo Dart | Ejemplo BD | Ejemplo Dart |
|----------------------------|------------------------|----------|-----------|------------|--------------|
| `mes` | `mes` | `TEXT` | `String` | `"2025-10"` | `"2025-10"` |
| `ventas` | `ventas` | `DECIMAL(12,2)` | `double` | `35000.00` | `35000.0` |

---

### 1.5 Top Productos

| Campo Backend (snake_case) | Campo Dart (camelCase) | Tipo SQL | Tipo Dart | Ejemplo BD | Ejemplo Dart |
|----------------------------|------------------------|----------|-----------|------------|--------------|
| `producto_id` | `productoId` | `UUID` | `String` | `"uuid-prod-1"` | `"uuid-prod-1"` |
| `nombre` | `nombre` | `TEXT` | `String` | `"Medias Deportivas"` | `"Medias Deportivas"` |
| `cantidad_vendida` | `cantidadVendida` | `INTEGER` | `int` | `120` | `120` |

---

### 1.6 Top Vendedores

| Campo Backend (snake_case) | Campo Dart (camelCase) | Tipo SQL | Tipo Dart | Ejemplo BD | Ejemplo Dart |
|----------------------------|------------------------|----------|-----------|------------|--------------|
| `vendedor_id` | `vendedorId` | `UUID` | `String` | `"uuid-vend-1"` | `"uuid-vend-1"` |
| `nombre_completo` | `nombreCompleto` | `TEXT` | `String` | `"Juan Pérez"` | `"Juan Pérez"` |
| `ventas_totales` | `ventasTotales` | `DECIMAL(12,2)` | `double` | `15000.00` | `15000.0` |
| `num_transacciones` | `numTransacciones` | `INTEGER` | `int` | `45` | `45` |

---

### 1.7 Transacciones Recientes

| Campo Backend (snake_case) | Campo Dart (camelCase) | Tipo SQL | Tipo Dart | Ejemplo BD | Ejemplo Dart |
|----------------------------|------------------------|----------|-----------|------------|--------------|
| `venta_id` | `ventaId` | `UUID` | `String` | `"uuid-venta"` | `"uuid-venta"` |
| `fecha_venta` | `fechaVenta` | `TIMESTAMP WITH TIME ZONE` | `DateTime` | `"2025-10-06T14:30:00Z"` | `DateTime(2025,10,6,14,30)` |
| `monto_total` | `montoTotal` | `DECIMAL(12,2)` | `double` | `1250.50` | `1250.50` |
| `estado` | `estado` | `TEXT (ENUM)` | `String` | `"COMPLETADA"` | `"COMPLETADA"` |
| `cliente_nombre` | `clienteNombre` | `TEXT` | `String?` | `"Carlos Ramírez"` | `"Carlos Ramírez"` |
| `vendedor_nombre` | `vendedorNombre` | `TEXT` | `String` | `"Juan Pérez"` | `"Juan Pérez"` |

---

### 1.8 Productos Stock Bajo

| Campo Backend (snake_case) | Campo Dart (camelCase) | Tipo SQL | Tipo Dart | Ejemplo BD | Ejemplo Dart |
|----------------------------|------------------------|----------|-----------|------------|--------------|
| `producto_id` | `productoId` | `UUID` | `String` | `"uuid-prod"` | `"uuid-prod"` |
| `nombre` | `nombre` | `TEXT` | `String` | `"Medias Blancas"` | `"Medias Blancas"` |
| `stock_actual` | `stockActual` | `INTEGER` | `int` | `3` | `3` |
| `stock_maximo` | `stockMaximo` | `INTEGER` | `int` | `100` | `100` |
| `porcentaje_stock` | `porcentajeStock` | `INTEGER` | `int` | `3` | `3` |
| `nivel_alerta` | `nivelAlerta` | `TEXT` | `NivelAlerta` (enum) | `"CRITICO"` | `NivelAlerta.critico` |

---

## 2. MAPPING POR ENDPOINT

### 2.1 `get_dashboard_metrics()`

**Request (Dart → PostgreSQL)**:
```dart
// Datasource
final response = await supabase.rpc('get_dashboard_metrics', params: {
  'p_user_id': userId,  // String (UUID)
});
```

**Response (PostgreSQL → Dart)**:

**Caso VENDEDOR**:
```json
// JSON Response
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

```dart
// Dart Model
VendedorMetricsModel.fromJson(data) // data = result['data']

// Resultado:
VendedorMetrics(
  ventasHoy: 1250.50,
  comisionesMes: 350.75,
  ordenesPendientes: 3,
  productosStockBajo: 5,
)
```

---

**Caso GERENTE**:
```json
// JSON Response
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

```dart
// Dart Model
GerenteMetricsModel.fromJson(data)

// Resultado:
GerenteMetrics(
  tiendaId: "uuid-tienda",
  ventasTotales: 15000.0,
  clientesActivos: 45,
  ordenesPendientes: 12,
  productosStockBajo: 8,
  metaMensual: 50000.0,
  ventasMesActual: 35000.0,
)
```

---

### 2.2 `get_sales_chart_data()`

**Request (Dart → PostgreSQL)**:
```dart
final response = await supabase.rpc('get_sales_chart_data', params: {
  'p_user_id': userId,
  'p_months': 6,  // opcional, default 6
});
```

**Response (PostgreSQL → Dart)**:
```json
// JSON Response
{
  "success": true,
  "data": [
    {"mes": "2025-10", "ventas": 35000.00},
    {"mes": "2025-09", "ventas": 42000.00},
    {"mes": "2025-08", "ventas": 38500.00}
  ]
}
```

```dart
// Dart Model
final chartData = (result['data'] as List)
    .map((item) => SalesChartDataModel.fromJson(item))
    .toList();

// Resultado:
List<SalesChartData> [
  SalesChartData(mes: "2025-10", ventas: 35000.0),
  SalesChartData(mes: "2025-09", ventas: 42000.0),
  SalesChartData(mes: "2025-08", ventas: 38500.0),
]
```

---

### 2.3 `get_top_productos()`

**Request**:
```dart
final response = await supabase.rpc('get_top_productos', params: {
  'p_user_id': userId,
  'p_limit': 5,  // opcional, default 5
});
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "producto_id": "uuid-1",
      "nombre": "Medias Deportivas Negras",
      "cantidad_vendida": 120
    }
  ]
}
```

```dart
final productos = (result['data'] as List)
    .map((item) => TopProductoModel.fromJson(item))
    .toList();
```

---

## 3. MANEJO DE ERRORES

### 3.1 Mapping de Hints a Excepciones

| Hint Backend | Excepción Dart | HTTP Status | Mensaje UI |
|--------------|----------------|-------------|------------|
| `user_not_authorized` | `UnauthorizedException` | `403` | "No tienes permisos para acceder al dashboard" |
| `user_not_found` | `NotFoundException` | `404` | "Usuario no encontrado" |
| `no_tienda_assigned` | `ValidationException` | `400` | "No tienes una tienda asignada. Contacta al administrador" |
| `invalid_role` | `ValidationException` | `400` | "Rol de usuario no válido" |
| `forbidden` | `ForbiddenException` | `403` | "Operación no permitida para tu rol" |
| `missing_param` | `ValidationException` | `400` | "Parámetro requerido faltante" |
| `invalid_param` | `ValidationException` | `400` | "Parámetro con valor inválido" |

---

### 3.2 Implementación en Datasource

```dart
// lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart

Future<DashboardMetrics> getMetrics(String userId) async {
  try {
    final response = await supabase.rpc('get_dashboard_metrics', params: {
      'p_user_id': userId,
    });

    final result = response as Map<String, dynamic>;

    // ✅ Success
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
    }

    // ❌ Error
    final error = result['error'] as Map<String, dynamic>;
    throw _mapError(error);

  } on PostgrestException catch (e) {
    throw NetworkException('Error de conexión: ${e.message}');
  } catch (e) {
    if (e is AppException) rethrow;
    throw NetworkException('Error inesperado: $e');
  }
}

/// Mapea error de PostgreSQL a excepción Dart
AppException _mapError(Map<String, dynamic> error) {
  final hint = error['hint'] as String?;
  final message = error['message'] as String;
  final code = error['code'] as String;

  switch (hint) {
    case 'user_not_authorized':
      return UnauthorizedException(message, 403);

    case 'user_not_found':
      return NotFoundException(message, 404);

    case 'no_tienda_assigned':
    case 'invalid_role':
    case 'missing_param':
    case 'invalid_param':
      return ValidationException(message, 400);

    case 'forbidden':
      return ForbiddenException(message, 403);

    default:
      return ServerException(message, 500);
  }
}
```

---

### 3.3 Excepciones Personalizadas

```dart
// lib/core/error/exceptions.dart

abstract class AppException implements Exception {
  final String message;
  final int statusCode;

  AppException(this.message, this.statusCode);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message, int statusCode)
      : super(message, statusCode);
}

class NotFoundException extends AppException {
  NotFoundException(String message, int statusCode)
      : super(message, statusCode);
}

class ValidationException extends AppException {
  final String? field;

  ValidationException(String message, int statusCode, {this.field})
      : super(message, statusCode);
}

class ForbiddenException extends AppException {
  ForbiddenException(String message, int statusCode)
      : super(message, statusCode);
}

class ServerException extends AppException {
  ServerException(String message, int statusCode)
      : super(message, statusCode);
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, 0);
}
```

---

## 4. EJEMPLO COMPLETO DE DATASOURCE

### 4.1 Interface (Data Layer)

```dart
// lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart

abstract class DashboardRemoteDataSource {
  Future<DashboardMetrics> getMetrics(String userId);
  Future<List<SalesChartData>> getSalesChart(String userId, {int months = 6});
  Future<List<TopProducto>> getTopProductos(String userId, {int limit = 5});
  Future<List<TopVendedor>> getTopVendedores(String userId, {int limit = 5});
  Future<List<TransaccionReciente>> getTransaccionesRecientes(String userId, {int limit = 5});
  Future<List<ProductoStockBajo>> getProductosStockBajo(String userId);
  Future<void> refreshMetrics();
}
```

---

### 4.2 Implementación

```dart
// lib/features/dashboard/data/datasources/dashboard_remote_datasource_impl.dart

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final SupabaseClient supabase;

  DashboardRemoteDataSourceImpl({required this.supabase});

  @override
  Future<DashboardMetrics> getMetrics(String userId) async {
    try {
      final response = await supabase.rpc('get_dashboard_metrics', params: {
        'p_user_id': userId,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final rol = data['rol'] as String;

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
    } on PostgrestException catch (e) {
      throw NetworkException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error inesperado: $e');
    }
  }

  @override
  Future<List<SalesChartData>> getSalesChart(String userId, {int months = 6}) async {
    try {
      final response = await supabase.rpc('get_sales_chart_data', params: {
        'p_user_id': userId,
        'p_months': months,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List;
        return data.map((item) => SalesChartDataModel.fromJson(item)).toList();
      }

      throw _mapError(result['error']);
    } on PostgrestException catch (e) {
      throw NetworkException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error inesperado: $e');
    }
  }

  @override
  Future<List<TopProducto>> getTopProductos(String userId, {int limit = 5}) async {
    try {
      final response = await supabase.rpc('get_top_productos', params: {
        'p_user_id': userId,
        'p_limit': limit,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List;
        return data.map((item) => TopProductoModel.fromJson(item)).toList();
      }

      throw _mapError(result['error']);
    } on PostgrestException catch (e) {
      throw NetworkException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error inesperado: $e');
    }
  }

  @override
  Future<void> refreshMetrics() async {
    try {
      await supabase.rpc('refresh_dashboard_metrics');
    } on PostgrestException catch (e) {
      throw NetworkException('Error al refrescar métricas: ${e.message}');
    }
  }

  // Mapeo de errores
  AppException _mapError(Map<String, dynamic> error) {
    final hint = error['hint'] as String?;
    final message = error['message'] as String;

    switch (hint) {
      case 'user_not_authorized':
        return UnauthorizedException(message, 403);
      case 'user_not_found':
        return NotFoundException(message, 404);
      case 'no_tienda_assigned':
      case 'invalid_role':
      case 'missing_param':
      case 'invalid_param':
        return ValidationException(message, 400);
      case 'forbidden':
        return ForbiddenException(message, 403);
      default:
        return ServerException(message, 500);
    }
  }
}
```

---

## 5. VALIDACIONES CRÍTICAS

### 5.1 Validaciones en Datasource

```dart
// ✅ SIEMPRE validar que response no sea null
if (response == null) {
  throw ServerException('Response vacío', 500);
}

// ✅ SIEMPRE validar que 'success' exista
if (!result.containsKey('success')) {
  throw ServerException('Formato de respuesta inválido', 500);
}

// ✅ SIEMPRE validar tipo de datos antes de cast
if (result['data'] is! Map<String, dynamic>) {
  throw ServerException('Tipo de data inválido', 500);
}
```

---

## ✅ CÓDIGO FINAL IMPLEMENTADO

**Status**: 🎨 Pendiente de Implementación

_Esta sección será completada por @flutter-expert después de implementar el datasource._

---

**Próximos Pasos**:
1. @flutter-expert: Implementar DashboardRemoteDataSource
2. @flutter-expert: Crear tests unitarios de mapping
3. @flutter-expert: Validar todos los escenarios de error
