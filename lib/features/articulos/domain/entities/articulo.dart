import 'package:equatable/equatable.dart';

class Articulo extends Equatable {
  final String id;
  final String productoMaestroId;
  final String sku;
  final String tipoColoracion;
  final List<String> coloresIds;
  final double precio;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Articulo({
    required this.id,
    required this.productoMaestroId,
    required this.sku,
    required this.tipoColoracion,
    required this.coloresIds,
    required this.precio,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get esUnicolor => tipoColoracion == 'unicolor';
  bool get esBicolor => tipoColoracion == 'bicolor';
  bool get esTricolor => tipoColoracion == 'tricolor';

  @override
  List<Object?> get props => [
        id,
        productoMaestroId,
        sku,
        tipoColoracion,
        coloresIds,
        precio,
        activo,
        createdAt,
        updatedAt,
      ];
}