import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_completo_response_model.dart';

abstract class ProductoCompletoState extends Equatable {
  const ProductoCompletoState();

  @override
  List<Object?> get props => [];
}

class ProductoCompletoInitial extends ProductoCompletoState {
  const ProductoCompletoInitial();

  @override
  List<Object?> get props => [];
}

class ProductoCompletoCreating extends ProductoCompletoState {
  const ProductoCompletoCreating();

  @override
  List<Object?> get props => [];
}

class ProductoCompletoCreated extends ProductoCompletoState {
  final ProductoCompletoResponseModel response;
  final String? navigateTo;

  const ProductoCompletoCreated(this.response, {this.navigateTo});

  @override
  List<Object?> get props => [response, navigateTo];
}

class ProductoCompletoError extends ProductoCompletoState {
  final String message;
  final FailureType type;

  const ProductoCompletoError(this.message, this.type);

  @override
  List<Object?> get props => [message, type];
}

enum FailureType { duplicate, validation, unauthorized, server, network }
