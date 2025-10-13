import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/create_color.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/delete_color.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/filter_productos_by_combinacion.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/get_colores_estadisticas.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/get_colores_list.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/get_productos_by_color.dart';
import 'package:system_web_medias/features/catalogos/domain/usecases/update_color.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_state.dart';

class ColoresBloc extends Bloc<ColoresEvent, ColoresState> {
  final GetColoresList getColoresList;
  final CreateColor createColor;
  final UpdateColor updateColor;
  final DeleteColor deleteColor;
  final GetProductosByColor getProductosByColor;
  final FilterProductosByCombinacion filterProductosByCombinacion;
  final GetColoresEstadisticas getColoresEstadisticas;

  ColoresBloc({
    required this.getColoresList,
    required this.createColor,
    required this.updateColor,
    required this.deleteColor,
    required this.getProductosByColor,
    required this.filterProductosByCombinacion,
    required this.getColoresEstadisticas,
  }) : super(const ColoresInitial()) {
    on<LoadColores>(_onLoadColores);
    on<CreateColorEvent>(_onCreateColor);
    on<UpdateColorEvent>(_onUpdateColor);
    on<DeleteColorEvent>(_onDeleteColor);
    on<SearchColores>(_onSearchColores);
    on<LoadEstadisticas>(_onLoadEstadisticas);
    on<LoadProductosByColor>(_onLoadProductosByColor);
    on<FilterProductosByCombinacionEvent>(_onFilterProductosByCombinacion);
  }

  Future<void> _onLoadColores(
    LoadColores event,
    Emitter<ColoresState> emit,
  ) async {
    emit(const ColoresLoading());

    final result = await getColoresList();

    result.fold(
      (failure) => emit(ColoresError(message: failure.message)),
      (colores) {
        final activos = colores.where((c) => c.activo).length;
        final inactivos = colores.where((c) => !c.activo).length;

        emit(ColoresLoaded(
          colores: colores,
          filteredColores: colores,
          coloresActivos: activos,
          coloresInactivos: inactivos,
        ));
      },
    );
  }

  Future<void> _onCreateColor(
    CreateColorEvent event,
    Emitter<ColoresState> emit,
  ) async {
    emit(const ColoresLoading());

    final result = await createColor(
      nombre: event.nombre,
      codigosHex: event.codigosHex,
    );

    await result.fold(
      (failure) async => emit(ColoresError(message: failure.message)),
      (newColor) async {
        if (emit.isDone) return;
        final coloresResult = await getColoresList();
        if (emit.isDone) return;
        coloresResult.fold(
          (failure) => emit(ColoresError(message: failure.message)),
          (colores) {
            if (!emit.isDone) {
              emit(ColorOperationSuccess(
                message: 'Color creado exitosamente',
                colores: colores,
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _onUpdateColor(
    UpdateColorEvent event,
    Emitter<ColoresState> emit,
  ) async {
    emit(const ColoresLoading());

    final result = await updateColor(
      id: event.id,
      nombre: event.nombre,
      codigosHex: event.codigosHex,
    );

    await result.fold(
      (failure) async => emit(ColoresError(message: failure.message)),
      (updatedColor) async {
        if (emit.isDone) return;
        final coloresResult = await getColoresList();
        if (emit.isDone) return;
        coloresResult.fold(
          (failure) => emit(ColoresError(message: failure.message)),
          (colores) {
            if (!emit.isDone) {
              final message = updatedColor.productosCount > 0
                  ? 'Color actualizado exitosamente. Este cambio afecta a ${updatedColor.productosCount} producto(s)'
                  : 'Color actualizado exitosamente';

              emit(ColorOperationSuccess(
                message: message,
                colores: colores,
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _onDeleteColor(
    DeleteColorEvent event,
    Emitter<ColoresState> emit,
  ) async {
    emit(const ColoresLoading());

    final result = await deleteColor(event.id);

    await result.fold(
      (failure) async => emit(ColoresError(message: failure.message)),
      (deleteResult) async {
        if (emit.isDone) return;
        final coloresResult = await getColoresList();
        if (emit.isDone) return;
        coloresResult.fold(
          (failure) => emit(ColoresError(message: failure.message)),
          (colores) {
            if (!emit.isDone) {
              final deleted = deleteResult['deleted'] as bool;
              final deactivated = deleteResult['deactivated'] as bool;
              final productosCount = deleteResult['productos_count'] as int;

              String message;
              if (deleted) {
                message = 'Color eliminado permanentemente';
              } else if (deactivated) {
                message =
                    'El color está en uso en $productosCount producto(s). Se ha desactivado en lugar de eliminarse';
              } else {
                message = 'Operación completada';
              }

              emit(ColorOperationSuccess(
                message: message,
                colores: colores,
                deleteResult: deleteResult,
              ));
            }
          },
        );
      },
    );
  }

  void _onSearchColores(
    SearchColores event,
    Emitter<ColoresState> emit,
  ) {
    if (state is ColoresLoaded) {
      final currentState = state as ColoresLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredColores: currentState.colores,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.colores.where((color) {
          final matchesName = color.nombre.toLowerCase().contains(query);
          final matchesHex = color.codigosHex.any((hex) => hex.toLowerCase().contains(query));
          return matchesName || matchesHex;
        }).toList();

        emit(currentState.copyWith(
          filteredColores: filtered,
          searchQuery: query,
        ));
      }
    }
  }

  Future<void> _onLoadEstadisticas(
    LoadEstadisticas event,
    Emitter<ColoresState> emit,
  ) async {
    emit(const ColoresLoading());

    final result = await getColoresEstadisticas();

    result.fold(
      (failure) => emit(ColoresError(message: failure.message)),
      (estadisticas) => emit(EstadisticasLoaded(estadisticas: estadisticas)),
    );
  }

  Future<void> _onLoadProductosByColor(
    LoadProductosByColor event,
    Emitter<ColoresState> emit,
  ) async {
    emit(const ColoresLoading());

    final result = await getProductosByColor(
      colorNombre: event.colorNombre,
      exacto: event.exacto,
    );

    result.fold(
      (failure) => emit(ColoresError(message: failure.message)),
      (productos) => emit(ProductosByColorLoaded(
        productos: productos,
        colorNombre: event.colorNombre,
        exacto: event.exacto,
      )),
    );
  }

  Future<void> _onFilterProductosByCombinacion(
    FilterProductosByCombinacionEvent event,
    Emitter<ColoresState> emit,
  ) async {
    emit(const ColoresLoading());

    final result = await filterProductosByCombinacion(
      colores: event.colores,
    );

    result.fold(
      (failure) => emit(ColoresError(message: failure.message)),
      (productos) => emit(ProductosByCombinacionLoaded(
        productos: productos,
        colores: event.colores,
      )),
    );
  }
}
