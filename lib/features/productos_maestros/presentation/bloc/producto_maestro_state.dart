import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';

abstract class ProductoMaestroState extends Equatable {
  const ProductoMaestroState();

  @override
  List<Object?> get props => [];
}

class ProductoMaestroInitial extends ProductoMaestroState {
  const ProductoMaestroInitial();
}

class ProductoMaestroLoading extends ProductoMaestroState {
  const ProductoMaestroLoading();
}

class ProductoMaestroLoaded extends ProductoMaestroState {
  final List<ProductoMaestroModel> productos;

  const ProductoMaestroLoaded({required this.productos});

  @override
  List<Object?> get props => [productos];
}

class ProductoMaestroError extends ProductoMaestroState {
  final String message;

  const ProductoMaestroError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProductoMaestroOperationSuccess extends ProductoMaestroState {
  final String message;
  final List<ProductoMaestroModel> productos;

  const ProductoMaestroOperationSuccess({
    required this.message,
    required this.productos,
  });

  @override
  List<Object?> get props => [message, productos];
}

class ValidacionCombinacionSuccess extends ProductoMaestroState {
  final Map<String, dynamic> validacion;

  const ValidacionCombinacionSuccess({required this.validacion});

  @override
  List<Object?> get props => [validacion];
}

class DesactivacionInfo extends ProductoMaestroState {
  final Map<String, dynamic> info;
  final List<ProductoMaestroModel> productos;

  const DesactivacionInfo({
    required this.info,
    required this.productos,
  });

  @override
  List<Object?> get props => [info, productos];
}
