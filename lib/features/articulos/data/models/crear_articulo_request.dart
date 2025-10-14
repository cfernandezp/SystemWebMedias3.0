import 'package:equatable/equatable.dart';

class CrearArticuloRequest extends Equatable {
  final String productoMaestroId;
  final List<String> coloresIds;
  final double precio;

  const CrearArticuloRequest({
    required this.productoMaestroId,
    required this.coloresIds,
    required this.precio,
  });

  Map<String, dynamic> toJson() {
    return {
      'p_producto_maestro_id': productoMaestroId,
      'p_colores_ids': coloresIds,
      'p_precio': precio,
    };
  }

  @override
  List<Object?> get props => [productoMaestroId, coloresIds, precio];
}