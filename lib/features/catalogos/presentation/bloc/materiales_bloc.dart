import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/materiales_repository.dart';
import 'materiales_event.dart';
import 'materiales_state.dart';

/// BLoC para gestión de materiales
///
/// Implementa E002-HU-002 (Gestionar Catálogo de Materiales).
/// Maneja estados de carga, éxito y error.
class MaterialesBloc extends Bloc<MaterialesEvent, MaterialesState> {
  final MaterialesRepository repository;

  MaterialesBloc({required this.repository}) : super(const MaterialesInitial()) {
    on<LoadMaterialesEvent>(_onLoadMateriales);
    on<SearchMaterialesEvent>(_onSearchMateriales);
    on<CreateMaterialEvent>(_onCreateMaterial);
    on<UpdateMaterialEvent>(_onUpdateMaterial);
    on<ToggleMaterialActivoEvent>(_onToggleMaterialActivo);
    on<LoadMaterialDetailEvent>(_onLoadMaterialDetail);
  }

  /// Handler: Cargar lista de materiales
  Future<void> _onLoadMateriales(
    LoadMaterialesEvent event,
    Emitter<MaterialesState> emit,
  ) async {
    emit(const MaterialesLoading());

    final result = await repository.getMateriales();

    result.fold(
      (failure) => emit(MaterialesError(message: failure.message)),
      (materiales) => emit(MaterialesLoaded(materiales: materiales)),
    );
  }

  /// Handler: Buscar materiales por query
  Future<void> _onSearchMateriales(
    SearchMaterialesEvent event,
    Emitter<MaterialesState> emit,
  ) async {
    emit(const MaterialesLoading());

    final result = await repository.searchMateriales(event.query);

    result.fold(
      (failure) => emit(MaterialesError(message: failure.message)),
      (materiales) => emit(MaterialesLoaded(
        materiales: materiales,
        searchQuery: event.query,
      )),
    );
  }

  /// Handler: Crear nuevo material
  Future<void> _onCreateMaterial(
    CreateMaterialEvent event,
    Emitter<MaterialesState> emit,
  ) async {
    emit(const MaterialesLoading());

    final result = await repository.createMaterial(
      nombre: event.nombre,
      descripcion: event.descripcion,
      codigo: event.codigo,
    );

    result.fold(
      (failure) => emit(MaterialesError(message: failure.message)),
      (material) => emit(MaterialOperationSuccess(
        message: 'Material creado exitosamente',
        material: material,
      )),
    );
  }

  /// Handler: Actualizar material existente
  Future<void> _onUpdateMaterial(
    UpdateMaterialEvent event,
    Emitter<MaterialesState> emit,
  ) async {
    emit(const MaterialesLoading());

    final result = await repository.updateMaterial(
      id: event.id,
      nombre: event.nombre,
      descripcion: event.descripcion,
      activo: event.activo,
    );

    result.fold(
      (failure) => emit(MaterialesError(message: failure.message)),
      (material) => emit(MaterialOperationSuccess(
        message: 'Material actualizado exitosamente',
        material: material,
      )),
    );
  }

  /// Handler: Activar/Desactivar material
  Future<void> _onToggleMaterialActivo(
    ToggleMaterialActivoEvent event,
    Emitter<MaterialesState> emit,
  ) async {
    emit(const MaterialesLoading());

    final result = await repository.toggleMaterialActivo(event.id);

    result.fold(
      (failure) => emit(MaterialesError(message: failure.message)),
      (material) {
        final action = material.activo ? 'reactivado' : 'desactivado';
        emit(MaterialOperationSuccess(
          message: 'Material $action exitosamente',
          material: material,
        ));
      },
    );
  }

  /// Handler: Cargar detalle de material
  Future<void> _onLoadMaterialDetail(
    LoadMaterialDetailEvent event,
    Emitter<MaterialesState> emit,
  ) async {
    emit(const MaterialesLoading());

    final result = await repository.getMaterialDetail(event.id);

    result.fold(
      (failure) => emit(MaterialesError(message: failure.message)),
      (detail) => emit(MaterialDetailLoaded(detail: detail)),
    );
  }
}
