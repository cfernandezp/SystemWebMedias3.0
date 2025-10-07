import 'package:equatable/equatable.dart';
import '../../data/models/material_model.dart';

/// Estados para MaterialesBloc
///
/// Implementa E002-HU-002 (Gestionar Catálogo de Materiales)
abstract class MaterialesState extends Equatable {
  const MaterialesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MaterialesInitial extends MaterialesState {
  const MaterialesInitial();
}

/// Estado de carga
class MaterialesLoading extends MaterialesState {
  const MaterialesLoading();
}

/// Lista de materiales cargada
class MaterialesLoaded extends MaterialesState {
  final List<MaterialModel> materiales;
  final String? searchQuery;

  const MaterialesLoaded({
    required this.materiales,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [materiales, searchQuery];
}

/// Detalle de material cargado
class MaterialDetailLoaded extends MaterialesState {
  final Map<String, dynamic> detail;

  const MaterialDetailLoaded({required this.detail});

  @override
  List<Object?> get props => [detail];
}

/// Operación exitosa (crear, actualizar, toggle)
class MaterialOperationSuccess extends MaterialesState {
  final String message;
  final MaterialModel? material;

  const MaterialOperationSuccess({
    required this.message,
    this.material,
  });

  @override
  List<Object?> get props => [message, material];
}

/// Error en operación
class MaterialesError extends MaterialesState {
  final String message;

  const MaterialesError({required this.message});

  @override
  List<Object?> get props => [message];
}
