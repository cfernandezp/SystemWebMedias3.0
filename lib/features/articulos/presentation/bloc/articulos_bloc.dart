import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/articulos/domain/usecases/crear_articulo_usecase.dart';
import 'package:system_web_medias/features/articulos/domain/usecases/editar_articulo_usecase.dart';
import 'package:system_web_medias/features/articulos/domain/usecases/eliminar_articulo_usecase.dart';
import 'package:system_web_medias/features/articulos/domain/usecases/generar_sku_usecase.dart';
import 'package:system_web_medias/features/articulos/domain/usecases/listar_articulos_usecase.dart';
import 'package:system_web_medias/features/articulos/domain/usecases/obtener_articulo_usecase.dart';
import 'package:system_web_medias/features/articulos/presentation/bloc/articulos_event.dart';
import 'package:system_web_medias/features/articulos/presentation/bloc/articulos_state.dart';

class ArticulosBloc extends Bloc<ArticulosEvent, ArticulosState> {
  final GenerarSkuUseCase generarSkuUseCase;
  final CrearArticuloUseCase crearArticuloUseCase;
  final ListarArticulosUseCase listarArticulosUseCase;
  final ObtenerArticuloUseCase obtenerArticuloUseCase;
  final EditarArticuloUseCase editarArticuloUseCase;
  final EliminarArticuloUseCase eliminarArticuloUseCase;

  ArticulosBloc({
    required this.generarSkuUseCase,
    required this.crearArticuloUseCase,
    required this.listarArticulosUseCase,
    required this.obtenerArticuloUseCase,
    required this.editarArticuloUseCase,
    required this.eliminarArticuloUseCase,
  }) : super(ArticulosInitial()) {
    on<GenerarSkuEvent>(_onGenerarSku);
    on<CrearArticuloEvent>(_onCrearArticulo);
    on<ListarArticulosEvent>(_onListarArticulos);
    on<ObtenerArticuloEvent>(_onObtenerArticulo);
    on<EditarArticuloEvent>(_onEditarArticulo);
    on<EliminarArticuloEvent>(_onEliminarArticulo);
    on<DesactivarArticuloEvent>(_onDesactivarArticulo);
  }

  Future<void> _onGenerarSku(
    GenerarSkuEvent event,
    Emitter<ArticulosState> emit,
  ) async {
    emit(ArticulosLoading());

    final result = await generarSkuUseCase(
      productoMaestroId: event.productoMaestroId,
      coloresIds: event.coloresIds,
    );

    result.fold(
      (failure) => emit(ArticulosError(message: failure.message)),
      (data) => emit(SkuGenerated(sku: data['sku'] as String)),
    );
  }

  Future<void> _onCrearArticulo(
    CrearArticuloEvent event,
    Emitter<ArticulosState> emit,
  ) async {
    emit(ArticulosLoading());

    final result = await crearArticuloUseCase(
      productoMaestroId: event.productoMaestroId,
      coloresIds: event.coloresIds,
      precio: event.precio,
    );

    result.fold(
      (failure) => emit(ArticulosError(message: failure.message)),
      (articulo) async {
        final listResult = await listarArticulosUseCase();
        listResult.fold(
          (failure) => emit(ArticulosError(message: failure.message)),
          (articulos) => emit(ArticuloOperationSuccess(
            message: 'Artículo creado exitosamente',
            articulos: articulos,
          )),
        );
      },
    );
  }

  Future<void> _onListarArticulos(
    ListarArticulosEvent event,
    Emitter<ArticulosState> emit,
  ) async {
    emit(ArticulosLoading());

    final result = await listarArticulosUseCase(
      filtros: event.filtros,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(ArticulosError(message: failure.message)),
      (articulos) => emit(ArticulosLoaded(articulos: articulos)),
    );
  }

  Future<void> _onObtenerArticulo(
    ObtenerArticuloEvent event,
    Emitter<ArticulosState> emit,
  ) async {
    emit(ArticulosLoading());

    final result = await obtenerArticuloUseCase(articuloId: event.articuloId);

    result.fold(
      (failure) => emit(ArticulosError(message: failure.message)),
      (articulo) => emit(ArticuloDetailLoaded(articulo: articulo)),
    );
  }

  Future<void> _onEditarArticulo(
    EditarArticuloEvent event,
    Emitter<ArticulosState> emit,
  ) async {
    emit(ArticulosLoading());

    final result = await editarArticuloUseCase(
      articuloId: event.articuloId,
      precio: event.precio,
      activo: event.activo,
    );

    result.fold(
      (failure) => emit(ArticulosError(message: failure.message)),
      (articulo) async {
        final listResult = await listarArticulosUseCase();
        listResult.fold(
          (failure) => emit(ArticulosError(message: failure.message)),
          (articulos) => emit(ArticuloOperationSuccess(
            message: 'Artículo actualizado exitosamente',
            articulos: articulos,
          )),
        );
      },
    );
  }

  Future<void> _onEliminarArticulo(
    EliminarArticuloEvent event,
    Emitter<ArticulosState> emit,
  ) async {
    emit(ArticulosLoading());

    final result = await eliminarArticuloUseCase(articuloId: event.articuloId);

    result.fold(
      (failure) => emit(ArticulosError(message: failure.message)),
      (_) async {
        final listResult = await listarArticulosUseCase();
        listResult.fold(
          (failure) => emit(ArticulosError(message: failure.message)),
          (articulos) => emit(ArticuloOperationSuccess(
            message: 'Artículo eliminado exitosamente',
            articulos: articulos,
          )),
        );
      },
    );
  }

  Future<void> _onDesactivarArticulo(
    DesactivarArticuloEvent event,
    Emitter<ArticulosState> emit,
  ) async {
    emit(ArticulosLoading());

    final result = await editarArticuloUseCase(
      articuloId: event.articuloId,
      activo: false,
    );

    result.fold(
      (failure) => emit(ArticulosError(message: failure.message)),
      (articulo) async {
        final listResult = await listarArticulosUseCase();
        listResult.fold(
          (failure) => emit(ArticulosError(message: failure.message)),
          (articulos) => emit(ArticuloOperationSuccess(
            message: 'Artículo desactivado exitosamente',
            articulos: articulos,
          )),
        );
      },
    );
  }
}