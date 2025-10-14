import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_completo_request_model.dart';

abstract class ProductoCompletoEvent extends Equatable {
  const ProductoCompletoEvent();

  @override
  List<Object?> get props => [];
}

class CreateProductoCompletoEvent extends ProductoCompletoEvent {
  final ProductoCompletoRequestModel request;

  const CreateProductoCompletoEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class ResetProductoCompletoEvent extends ProductoCompletoEvent {
  const ResetProductoCompletoEvent();

  @override
  List<Object?> get props => [];
}
