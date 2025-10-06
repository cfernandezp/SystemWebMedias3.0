import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/dashboard/data/models/gerente_metrics_model.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/gerente_metrics.dart';

void main() {
  const tGerenteMetricsModel = GerenteMetricsModel(
    tiendaId: 'uuid-tienda',
    ventasTotales: 15000.00,
    clientesActivos: 45,
    ordenesPendientes: 12,
    productosStockBajo: 8,
    metaMensual: 50000.00,
    ventasMesActual: 35000.00,
  );

  test('should be a subclass of GerenteMetrics entity', () {
    expect(tGerenteMetricsModel, isA<GerenteMetrics>());
  });

  group('fromJson', () {
    test('should return a valid model when JSON is valid', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'tienda_id': 'uuid-tienda',
        'ventas_totales': 15000.00,
        'clientes_activos': 45,
        'ordenes_pendientes': 12,
        'productos_stock_bajo': 8,
        'meta_mensual': 50000.00,
        'ventas_mes_actual': 35000.00,
      };

      // Act
      final result = GerenteMetricsModel.fromJson(jsonMap);

      // Assert
      expect(result, tGerenteMetricsModel);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tGerenteMetricsModel.toJson();

      // Assert
      final expectedMap = {
        'tienda_id': 'uuid-tienda',
        'ventas_totales': 15000.00,
        'clientes_activos': 45,
        'ordenes_pendientes': 12,
        'productos_stock_bajo': 8,
        'meta_mensual': 50000.00,
        'ventas_mes_actual': 35000.00,
      };
      expect(result, expectedMap);
    });
  });

  group('business logic', () {
    test('should calculate progresoMeta correctly', () {
      // Act
      final progreso = tGerenteMetricsModel.progresoMeta;

      // Assert
      expect(progreso, 70.0); // 35000 / 50000 * 100
    });

    test('should return 0 when metaMensual is 0', () {
      // Arrange
      const model = GerenteMetricsModel(
        tiendaId: 'uuid-tienda',
        ventasTotales: 15000.00,
        clientesActivos: 45,
        ordenesPendientes: 12,
        productosStockBajo: 8,
        metaMensual: 0,
        ventasMesActual: 35000.00,
      );

      // Act
      final progreso = model.progresoMeta;

      // Assert
      expect(progreso, 0);
    });
  });
}
