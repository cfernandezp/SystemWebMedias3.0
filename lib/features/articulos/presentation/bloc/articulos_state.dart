import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/articulos/data/models/articulo_model.dart';

abstract class ArticulosState extends Equatable {
  const ArticulosState();

  @override
  List<Object?> get props => [];
}

class ArticulosInitial extends ArticulosState {}

class ArticulosLoading extends ArticulosState {}

class ArticulosLoaded extends ArticulosState {
  final List<ArticuloModel> articulos;

  const ArticulosLoaded({required this.articulos});

  @override
  List<Object?> get props => [articulos];
}

class ArticuloDetailLoaded extends ArticulosState {
  final ArticuloModel articulo;

  const ArticuloDetailLoaded({required this.articulo});

  @override
  List<Object?> get props => [articulo];
}

class SkuGenerated extends ArticulosState {
  final String sku;

  const SkuGenerated({required this.sku});

  @override
  List<Object?> get props => [sku];
}

class ArticuloOperationSuccess extends ArticulosState {
  final String message;
  final List<ArticuloModel> articulos;

  const ArticuloOperationSuccess({
    required this.message,
    required this.articulos,
  });

  @override
  List<Object?> get props => [message, articulos];
}

class ArticulosError extends ArticulosState {
  final String message;

  const ArticulosError({required this.message});

  @override
  List<Object?> get props => [message];
}