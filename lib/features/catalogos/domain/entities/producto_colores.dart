import 'package:equatable/equatable.dart';

class ProductoColores extends Equatable {
  final String productoId;
  final List<String> colores;
  final int cantidadColores;
  final String tipoColor;
  final String? descripcionVisual;

  const ProductoColores({
    required this.productoId,
    required this.colores,
    required this.cantidadColores,
    required this.tipoColor,
    this.descripcionVisual,
  });

  String clasificarTipoColor() {
    switch (cantidadColores) {
      case 1:
        return 'Unicolor';
      case 2:
        return 'Bicolor';
      case 3:
        return 'Tricolor';
      default:
        return 'Multicolor';
    }
  }

  @override
  List<Object?> get props => [
        productoId,
        colores,
        cantidadColores,
        tipoColor,
        descripcionVisual,
      ];
}
