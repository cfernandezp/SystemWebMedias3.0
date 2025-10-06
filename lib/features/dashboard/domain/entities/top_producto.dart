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
