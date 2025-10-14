import 'package:equatable/equatable.dart';

class ProductoCompletoResponseModel extends Equatable {
  final String productoMaestroId;
  final int articulosCreados;
  final List<String> skusGenerados;
  final String message;

  const ProductoCompletoResponseModel({
    required this.productoMaestroId,
    required this.articulosCreados,
    required this.skusGenerados,
    required this.message,
  });

  factory ProductoCompletoResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ProductoCompletoResponseModel(
      productoMaestroId: data['producto_maestro_id'] as String,
      articulosCreados: data['articulos_creados'] as int,
      skusGenerados: List<String>.from(data['skus_generados'] as List),
      message: json['message'] as String,
    );
  }

  @override
  List<Object?> get props => [productoMaestroId, articulosCreados, skusGenerados, message];
}
