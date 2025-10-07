import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/catalogos/data/models/marca_model.dart';

/// Estados del Bloc de Marcas
abstract class MarcasState extends Equatable {
  const MarcasState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MarcasInitial extends MarcasState {
  const MarcasInitial();
}

/// Estado de carga
class MarcasLoading extends MarcasState {
  const MarcasLoading();
}

/// Estado de éxito con datos
class MarcasLoaded extends MarcasState {
  final List<MarcaModel> marcas;
  final List<MarcaModel> filteredMarcas;
  final String searchQuery;

  const MarcasLoaded({
    required this.marcas,
    List<MarcaModel>? filteredMarcas,
    this.searchQuery = '',
  }) : filteredMarcas = filteredMarcas ?? marcas;

  /// Calcular estadísticas
  int get totalMarcas => marcas.length;
  int get marcasActivas => marcas.where((m) => m.activo).length;
  int get marcasInactivas => marcas.where((m) => !m.activo).length;

  @override
  List<Object?> get props => [marcas, filteredMarcas, searchQuery];

  /// Crear copia con filtros actualizados
  MarcasLoaded copyWith({
    List<MarcaModel>? marcas,
    List<MarcaModel>? filteredMarcas,
    String? searchQuery,
  }) {
    return MarcasLoaded(
      marcas: marcas ?? this.marcas,
      filteredMarcas: filteredMarcas ?? this.filteredMarcas,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Estado de error
class MarcasError extends MarcasState {
  final String message;

  const MarcasError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de operación exitosa (create/update/toggle)
class MarcaOperationSuccess extends MarcasState {
  final String message;
  final List<MarcaModel> marcas;

  const MarcaOperationSuccess({
    required this.message,
    required this.marcas,
  });

  @override
  List<Object?> get props => [message, marcas];
}
