import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/dashboard/data/models/vendedor_metrics_model.dart';
import 'package:system_web_medias/features/dashboard/data/models/gerente_metrics_model.dart';
import 'package:system_web_medias/features/dashboard/data/models/sales_chart_data_model.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/vendedor_metrics.dart';

void main() {
  group('DashboardRemoteDataSource - Model parsing tests', () {
    test('should parse VendedorMetricsModel from JSON correctly', () {
      // Arrange
      final jsonMap = {
        'rol': 'VENDEDOR',
        'ventas_hoy': 1250.50,
        'comisiones_mes': 350.75,
        'ordenes_pendientes': 3,
        'productos_stock_bajo': 5,
      };

      // Act
      final result = VendedorMetricsModel.fromJson(jsonMap);

      // Assert
      expect(result, isA<VendedorMetrics>());
      expect(result.ventasHoy, 1250.50);
      expect(result.comisionesMes, 350.75);
    });

    test('should parse GerenteMetricsModel from JSON correctly', () {
      // Arrange
      final jsonMap = {
        'rol': 'GERENTE',
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
      expect(result.tiendaId, 'uuid-tienda');
      expect(result.ventasTotales, 15000.00);
    });

    test('should parse SalesChartDataModel list from JSON correctly', () {
      // Arrange
      final jsonList = [
        {'mes': '2025-10', 'ventas': 35000.00},
        {'mes': '2025-09', 'ventas': 42000.00},
      ];

      // Act
      final result = jsonList
          .map((item) => SalesChartDataModel.fromJson(item))
          .toList();

      // Assert
      expect(result, isA<List<SalesChartDataModel>>());
      expect(result.length, 2);
      expect(result[0].mes, '2025-10');
      expect(result[0].ventas, 35000.00);
    });
  });
}
