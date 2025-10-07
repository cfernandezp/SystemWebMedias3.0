import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/tipos_repository.dart';
import 'tipos_event.dart';
import 'tipos_state.dart';

/// Bloc para gestión de tipos
///
/// Maneja:
/// - CA-001: Lista de tipos
/// - CA-002 a CA-004: Crear tipo
/// - CA-005 a CA-007: Editar tipo
/// - CA-008 a CA-010: Activar/desactivar tipo
/// - CA-011: Búsqueda
/// - CA-012: Vista detallada
class TiposBloc extends Bloc<TiposEvent, TiposState> {
  final TiposRepository repository;

  TiposBloc({required this.repository}) : super(const TiposInitial()) {
    on<LoadTiposEvent>(_onLoadTipos);
    on<SearchTiposEvent>(_onSearchTipos);
    on<CreateTipoEvent>(_onCreateTipo);
    on<UpdateTipoEvent>(_onUpdateTipo);
    on<ToggleTipoActivoEvent>(_onToggleTipoActivo);
    on<LoadTipoDetailEvent>(_onLoadTipoDetail);
  }

  /// Cargar lista de tipos (CA-001)
  Future<void> _onLoadTipos(
    LoadTiposEvent event,
    Emitter<TiposState> emit,
  ) async {
    emit(const TiposLoading());

    final result = await repository.getTipos();

    result.fold(
      (failure) => emit(TiposError(message: failure.message)),
      (tipos) => emit(TiposLoaded(tipos: tipos)),
    );
  }

  /// Buscar tipos (CA-011)
  Future<void> _onSearchTipos(
    SearchTiposEvent event,
    Emitter<TiposState> emit,
  ) async {
    emit(const TiposLoading());

    final result = await repository.getTipos(search: event.query);

    result.fold(
      (failure) => emit(TiposError(message: failure.message)),
      (tipos) => emit(TiposLoaded(tipos: tipos, searchQuery: event.query)),
    );
  }

  /// Crear nuevo tipo (CA-002, CA-003, CA-004)
  Future<void> _onCreateTipo(
    CreateTipoEvent event,
    Emitter<TiposState> emit,
  ) async {
    emit(const TiposLoading());

    final result = await repository.createTipo(
      nombre: event.nombre,
      descripcion: event.descripcion,
      codigo: event.codigo,
      imagenUrl: event.imagenUrl,
    );

    result.fold(
      (failure) => emit(TiposError(message: failure.message)),
      (tipo) => emit(const TipoOperationSuccess(
        message: 'Tipo creado exitosamente',
      )),
    );
  }

  /// Actualizar tipo (CA-005, CA-006, CA-007)
  Future<void> _onUpdateTipo(
    UpdateTipoEvent event,
    Emitter<TiposState> emit,
  ) async {
    emit(const TiposLoading());

    final result = await repository.updateTipo(
      id: event.id,
      nombre: event.nombre,
      descripcion: event.descripcion,
      activo: event.activo,
    );

    result.fold(
      (failure) => emit(TiposError(message: failure.message)),
      (tipo) => emit(const TipoOperationSuccess(
        message: 'Tipo actualizado exitosamente',
      )),
    );
  }

  /// Activar/desactivar tipo (CA-008, CA-009, CA-010)
  Future<void> _onToggleTipoActivo(
    ToggleTipoActivoEvent event,
    Emitter<TiposState> emit,
  ) async {
    emit(const TiposLoading());

    final result = await repository.toggleTipoActivo(event.id);

    result.fold(
      (failure) => emit(TiposError(message: failure.message)),
      (tipo) {
        final message = tipo.activo
            ? 'Tipo reactivado exitosamente'
            : 'Tipo desactivado exitosamente';
        emit(TipoOperationSuccess(message: message));
      },
    );
  }

  /// Cargar detalle de tipo (CA-012)
  Future<void> _onLoadTipoDetail(
    LoadTipoDetailEvent event,
    Emitter<TiposState> emit,
  ) async {
    emit(const TiposLoading());

    final result = await repository.getTipoDetalle(event.id);

    result.fold(
      (failure) => emit(TiposError(message: failure.message)),
      (detail) => emit(TipoDetailLoaded(detail: detail)),
    );
  }
}
