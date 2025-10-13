import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_filter_model.dart';

abstract class ProductoMaestroState extends Equatable {
  const ProductoMaestroState();

  @override
  List<Object?> get props => [];
}

class ProductoMaestroInitial extends ProductoMaestroState {}

class ProductoMaestroLoading extends ProductoMaestroState {}

class ProductoMaestroListLoaded extends ProductoMaestroState {
  final List<ProductoMaestroModel> productos;
  final ProductoMaestroFilterModel? filtros;

  const ProductoMaestroListLoaded({
    required this.productos,
    this.filtros,
  });

  @override
  List<Object?> get props => [productos, filtros];
}

class ProductoMaestroCreated extends ProductoMaestroState {
  final ProductoMaestroModel producto;
  final List<String>? warnings;

  const ProductoMaestroCreated({
    required this.producto,
    this.warnings,
  });

  @override
  List<Object?> get props => [producto, warnings];
}

class ProductoMaestroEdited extends ProductoMaestroState {
  final ProductoMaestroModel producto;

  const ProductoMaestroEdited(this.producto);

  @override
  List<Object?> get props => [producto];
}

class ProductoMaestroDeleted extends ProductoMaestroState {
  final String productoId;

  const ProductoMaestroDeleted(this.productoId);

  @override
  List<Object?> get props => [productoId];
}

class ProductoMaestroDeactivated extends ProductoMaestroState {
  final String productoId;
  final int affectedArticles;

  const ProductoMaestroDeactivated({
    required this.productoId,
    required this.affectedArticles,
  });

  @override
  List<Object?> get props => [productoId, affectedArticles];
}

class ProductoMaestroReactivated extends ProductoMaestroState {
  final ProductoMaestroModel producto;

  const ProductoMaestroReactivated(this.producto);

  @override
  List<Object?> get props => [producto];
}

class CombinacionValidated extends ProductoMaestroState {
  final List<String> warnings;

  const CombinacionValidated(this.warnings);

  @override
  List<Object?> get props => [warnings];
}

class ProductoMaestroError extends ProductoMaestroState {
  final String message;
  final String? hint;
  final String? navigateTo;

  const ProductoMaestroError({
    required this.message,
    this.hint,
    this.navigateTo,
  });

  @override
  List<Object?> get props => [message, hint, navigateTo];
}
