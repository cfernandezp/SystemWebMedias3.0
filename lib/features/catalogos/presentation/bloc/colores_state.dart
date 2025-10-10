import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';
import 'package:system_web_medias/features/catalogos/data/models/estadisticas_colores_model.dart';

abstract class ColoresState extends Equatable {
  const ColoresState();

  @override
  List<Object?> get props => [];
}

class ColoresInitial extends ColoresState {
  const ColoresInitial();
}

class ColoresLoading extends ColoresState {
  const ColoresLoading();
}

class ColoresLoaded extends ColoresState {
  final List<ColorModel> colores;
  final List<ColorModel> filteredColores;
  final String searchQuery;
  final int coloresActivos;
  final int coloresInactivos;

  const ColoresLoaded({
    required this.colores,
    required this.filteredColores,
    this.searchQuery = '',
    required this.coloresActivos,
    required this.coloresInactivos,
  });

  @override
  List<Object?> get props => [
        colores,
        filteredColores,
        searchQuery,
        coloresActivos,
        coloresInactivos,
      ];

  ColoresLoaded copyWith({
    List<ColorModel>? colores,
    List<ColorModel>? filteredColores,
    String? searchQuery,
    int? coloresActivos,
    int? coloresInactivos,
  }) {
    return ColoresLoaded(
      colores: colores ?? this.colores,
      filteredColores: filteredColores ?? this.filteredColores,
      searchQuery: searchQuery ?? this.searchQuery,
      coloresActivos: coloresActivos ?? this.coloresActivos,
      coloresInactivos: coloresInactivos ?? this.coloresInactivos,
    );
  }
}

class ColorOperationSuccess extends ColoresState {
  final String message;
  final List<ColorModel> colores;
  final Map<String, dynamic>? deleteResult;

  const ColorOperationSuccess({
    required this.message,
    required this.colores,
    this.deleteResult,
  });

  @override
  List<Object?> get props => [message, colores, deleteResult];
}

class EstadisticasLoaded extends ColoresState {
  final EstadisticasColoresModel estadisticas;

  const EstadisticasLoaded({required this.estadisticas});

  @override
  List<Object?> get props => [estadisticas];
}

class ProductosByColorLoaded extends ColoresState {
  final List<Map<String, dynamic>> productos;
  final String colorNombre;
  final bool exacto;

  const ProductosByColorLoaded({
    required this.productos,
    required this.colorNombre,
    required this.exacto,
  });

  @override
  List<Object?> get props => [productos, colorNombre, exacto];
}

class ProductosByCombinacionLoaded extends ColoresState {
  final List<Map<String, dynamic>> productos;
  final List<String> colores;

  const ProductosByCombinacionLoaded({
    required this.productos,
    required this.colores,
  });

  @override
  List<Object?> get props => [productos, colores];
}

class ColoresError extends ColoresState {
  final String message;

  const ColoresError({required this.message});

  @override
  List<Object?> get props => [message];
}
