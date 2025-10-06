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
