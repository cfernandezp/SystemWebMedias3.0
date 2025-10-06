import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/dashboard/data/models/vendedor_metrics_model.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/vendedor_metrics.dart';

void main() {
  const tVendedorMetricsModel = VendedorMetricsModel(
    ventasHoy: 1250.50,
    comisionesMes: 350.75,
    ordenesPendientes: 3,
    productosStockBajo: 5,
  );

  test('should be a subclass of VendedorMetrics entity', () {
    expect(tVendedorMetricsModel, isA<VendedorMetrics>());
  });

  group('fromJson', () {
    test('should return a valid model when JSON is valid', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'ventas_hoy': 1250.50,
        'comisiones_mes': 350.75,
        'ordenes_pendientes': 3,
        'productos_stock_bajo': 5,
      };

      // Act
      final result = VendedorMetricsModel.fromJson(jsonMap);

      // Assert
      expect(result, tVendedorMetricsModel);
    });

    test('should handle integer values for double fields', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'ventas_hoy': 1250,
        'comisiones_mes': 350,
        'ordenes_pendientes': 3,
        'productos_stock_bajo': 5,
      };

      // Act
      final result = VendedorMetricsModel.fromJson(jsonMap);

      // Assert
      expect(result.ventasHoy, 1250.0);
      expect(result.comisionesMes, 350.0);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tVendedorMetricsModel.toJson();

      // Assert
      final expectedMap = {
        'ventas_hoy': 1250.50,
        'comisiones_mes': 350.75,
        'ordenes_pendientes': 3,
        'productos_stock_bajo': 5,
      };
      expect(result, expectedMap);
    });
  });
}
