import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/dashboard/data/models/producto_stock_bajo_model.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/producto_stock_bajo.dart';

void main() {
  const tProductoStockBajoModel = ProductoStockBajoModel(
    productoId: 'uuid-producto',
    nombre: 'Medias Deportivas Blancas',
    stockActual: 3,
    stockMaximo: 100,
    porcentajeStock: 3,
    nivelAlerta: NivelAlerta.critico,
  );

  test('should be a subclass of ProductoStockBajo entity', () {
    expect(tProductoStockBajoModel, isA<ProductoStockBajo>());
  });

  group('fromJson', () {
    test('should return a valid model when JSON is valid with CRITICO', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'producto_id': 'uuid-producto',
        'nombre': 'Medias Deportivas Blancas',
        'stock_actual': 3,
        'stock_maximo': 100,
        'porcentaje_stock': 3,
        'nivel_alerta': 'CRITICO',
      };

      // Act
      final result = ProductoStockBajoModel.fromJson(jsonMap);

      // Assert
      expect(result, tProductoStockBajoModel);
    });

    test('should parse BAJO nivel alerta correctly', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'producto_id': 'uuid-producto',
        'nombre': 'Medias Deportivas Blancas',
        'stock_actual': 15,
        'stock_maximo': 100,
        'porcentaje_stock': 15,
        'nivel_alerta': 'BAJO',
      };

      // Act
      final result = ProductoStockBajoModel.fromJson(jsonMap);

      // Assert
      expect(result.nivelAlerta, NivelAlerta.bajo);
    });

    test('should throw ArgumentError when nivel_alerta is invalid', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'producto_id': 'uuid-producto',
        'nombre': 'Medias Deportivas Blancas',
        'stock_actual': 3,
        'stock_maximo': 100,
        'porcentaje_stock': 3,
        'nivel_alerta': 'INVALIDO',
      };

      // Act & Assert
      expect(
        () => ProductoStockBajoModel.fromJson(jsonMap),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tProductoStockBajoModel.toJson();

      // Assert
      final expectedMap = {
        'producto_id': 'uuid-producto',
        'nombre': 'Medias Deportivas Blancas',
        'stock_actual': 3,
        'stock_maximo': 100,
        'porcentaje_stock': 3,
        'nivel_alerta': 'CRITICO',
      };
      expect(result, expectedMap);
    });
  });
}
