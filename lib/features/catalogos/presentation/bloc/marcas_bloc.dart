import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/catalogos/domain/repositories/marcas_repository.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_state.dart';

/// Bloc para gestión de Marcas
class MarcasBloc extends Bloc<MarcasEvent, MarcasState> {
  final MarcasRepository repository;

  MarcasBloc({required this.repository}) : super(const MarcasInitial()) {
    on<LoadMarcas>(_onLoadMarcas);
    on<CreateMarca>(_onCreateMarca);
    on<UpdateMarca>(_onUpdateMarca);
    on<ToggleMarca>(_onToggleMarca);
    on<SearchMarcas>(_onSearchMarcas);
  }

  /// Handler: Cargar todas las marcas
  Future<void> _onLoadMarcas(
    LoadMarcas event,
    Emitter<MarcasState> emit,
  ) async {
    emit(const MarcasLoading());

    final result = await repository.getMarcas();

    result.fold(
      (failure) => emit(MarcasError(message: failure.message)),
      (marcas) => emit(MarcasLoaded(marcas: marcas)),
    );
  }

  /// Handler: Crear nueva marca
  Future<void> _onCreateMarca(
    CreateMarca event,
    Emitter<MarcasState> emit,
  ) async {
    emit(const MarcasLoading());

    final result = await repository.createMarca(
      nombre: event.nombre,
      codigo: event.codigo,
      activo: event.activo,
    );

    await result.fold(
      (failure) async => emit(MarcasError(message: failure.message)),
      (marca) async {
        // Recargar lista completa después de crear
        final marcasResult = await repository.getMarcas();
        marcasResult.fold(
          (failure) => emit(MarcasError(message: failure.message)),
          (marcas) => emit(MarcaOperationSuccess(
            message: 'Marca creada exitosamente',
            marcas: marcas,
          )),
        );
      },
    );
  }

  /// Handler: Actualizar marca existente
  Future<void> _onUpdateMarca(
    UpdateMarca event,
    Emitter<MarcasState> emit,
  ) async {
    emit(const MarcasLoading());

    final result = await repository.updateMarca(
      id: event.id,
      nombre: event.nombre,
      activo: event.activo,
    );

    await result.fold(
      (failure) async => emit(MarcasError(message: failure.message)),
      (marca) async {
        // Recargar lista completa después de actualizar
        final marcasResult = await repository.getMarcas();
        marcasResult.fold(
          (failure) => emit(MarcasError(message: failure.message)),
          (marcas) => emit(MarcaOperationSuccess(
            message: 'Marca actualizada exitosamente',
            marcas: marcas,
          )),
        );
      },
    );
  }

  /// Handler: Activar/desactivar marca
  Future<void> _onToggleMarca(
    ToggleMarca event,
    Emitter<MarcasState> emit,
  ) async {
    // Guardar estado actual para rollback si hay error
    final currentState = state;

    if (currentState is MarcasLoaded) {
      // Mostrar loading pero mantener datos visibles
      emit(const MarcasLoading());
    }

    final result = await repository.toggleMarca(event.id);

    await result.fold(
      (failure) async {
        // Restaurar estado anterior en caso de error
        if (currentState is MarcasLoaded) {
          emit(currentState);
        }
        emit(MarcasError(message: failure.message));
      },
      (marca) async {
        // Recargar lista completa después de toggle
        final marcasResult = await repository.getMarcas();
        marcasResult.fold(
          (failure) => emit(MarcasError(message: failure.message)),
          (marcas) => emit(MarcaOperationSuccess(
            message: marca.activo
                ? 'Marca reactivada exitosamente'
                : 'Marca desactivada exitosamente',
            marcas: marcas,
          )),
        );
      },
    );
  }

  /// Handler: Buscar marcas por nombre o código
  void _onSearchMarcas(
    SearchMarcas event,
    Emitter<MarcasState> emit,
  ) {
    if (state is MarcasLoaded) {
      final currentState = state as MarcasLoaded;
      final query = event.query.toLowerCase().trim();

      if (query.isEmpty) {
        // Sin búsqueda: mostrar todas las marcas
        emit(currentState.copyWith(
          filteredMarcas: currentState.marcas,
          searchQuery: '',
        ));
      } else {
        // Filtrar por nombre o código
        final filtered = currentState.marcas.where((marca) {
          final nombreMatch = marca.nombre.toLowerCase().contains(query);
          final codigoMatch = marca.codigo.toLowerCase().contains(query);
          return nombreMatch || codigoMatch;
        }).toList();

        emit(currentState.copyWith(
          filteredMarcas: filtered,
          searchQuery: query,
        ));
      }
    }
  }
}
