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
  bajo, // < 20%
}
