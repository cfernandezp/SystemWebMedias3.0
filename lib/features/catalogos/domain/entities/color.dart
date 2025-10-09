import 'package:equatable/equatable.dart';

class Color extends Equatable {
  final String id;
  final String nombre;
  final String codigoHex;
  final bool activo;
  final int productosCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Color({
    required this.id,
    required this.nombre,
    required this.codigoHex,
    required this.activo,
    required this.productosCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        codigoHex,
        activo,
        productosCount,
        createdAt,
        updatedAt,
      ];
}
