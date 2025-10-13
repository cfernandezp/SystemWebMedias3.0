import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/crear_producto_maestro.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/listar_productos_maestros.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/editar_producto_maestro.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/eliminar_producto_maestro.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/desactivar_producto_maestro.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/reactivar_producto_maestro.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/validar_combinacion_comercial.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_state.dart';

class ProductoMaestroBloc
    extends Bloc<ProductoMaestroEvent, ProductoMaestroState> {
  final CrearProductoMaestro crearProductoMaestro;
  final ListarProductosMaestros listarProductosMaestros;
  final EditarProductoMaestro editarProductoMaestro;
  final EliminarProductoMaestro eliminarProductoMaestro;
  final DesactivarProductoMaestro desactivarProductoMaestro;
  final ReactivarProductoMaestro reactivarProductoMaestro;
  final ValidarCombinacionComercial validarCombinacionComercial;

  ProductoMaestroBloc({
    required this.crearProductoMaestro,
    required this.listarProductosMaestros,
    required this.editarProductoMaestro,
    required this.eliminarProductoMaestro,
    required this.desactivarProductoMaestro,
    required this.reactivarProductoMaestro,
    required this.validarCombinacionComercial,
  }) : super(ProductoMaestroInitial()) {
    on<CrearProductoMaestroEvent>(_onCrear);
    on<ListarProductosMaestrosEvent>(_onListar);
    on<EditarProductoMaestroEvent>(_onEditar);
    on<EliminarProductoMaestroEvent>(_onEliminar);
    on<DesactivarProductoMaestroEvent>(_onDesactivar);
    on<ReactivarProductoMaestroEvent>(_onReactivar);
    on<ValidarCombinacionComercialEvent>(_onValidarCombinacion);
  }

  Future<void> _onCrear(
    CrearProductoMaestroEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(ProductoMaestroLoading());

    final result = await crearProductoMaestro(
      marcaId: event.marcaId,
      materialId: event.materialId,
      tipoId: event.tipoId,
      sistemaTallaId: event.sistemaTallaId,
      descripcion: event.descripcion,
    );

    result.fold(
      (failure) => emit(ProductoMaestroError(message: failure.message)),
      (producto) => emit(ProductoMaestroCreated(
        producto: producto,
        warnings: producto.warnings,
      )),
    );
  }

  Future<void> _onListar(
    ListarProductosMaestrosEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(ProductoMaestroLoading());

    final result = await listarProductosMaestros(filtros: event.filtros);

    result.fold(
      (failure) => emit(ProductoMaestroError(message: failure.message)),
      (productos) => emit(ProductoMaestroListLoaded(
        productos: productos,
        filtros: event.filtros,
      )),
    );
  }

  Future<void> _onEditar(
    EditarProductoMaestroEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(ProductoMaestroLoading());

    final result = await editarProductoMaestro(
      productoId: event.productoId,
      marcaId: event.marcaId,
      materialId: event.materialId,
      tipoId: event.tipoId,
      sistemaTallaId: event.sistemaTallaId,
      descripcion: event.descripcion,
    );

    result.fold(
      (failure) => emit(ProductoMaestroError(message: failure.message)),
      (producto) => emit(ProductoMaestroEdited(producto)),
    );
  }

  Future<void> _onEliminar(
    EliminarProductoMaestroEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(ProductoMaestroLoading());

    final result = await eliminarProductoMaestro(event.productoId);

    result.fold(
      (failure) => emit(ProductoMaestroError(message: failure.message)),
      (_) => emit(ProductoMaestroDeleted(event.productoId)),
    );
  }

  Future<void> _onDesactivar(
    DesactivarProductoMaestroEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(ProductoMaestroLoading());

    final result = await desactivarProductoMaestro(
      productoId: event.productoId,
      desactivarArticulos: event.desactivarArticulos,
    );

    result.fold(
      (failure) => emit(ProductoMaestroError(message: failure.message)),
      (affectedArticles) => emit(ProductoMaestroDeactivated(
        productoId: event.productoId,
        affectedArticles: affectedArticles,
      )),
    );
  }

  Future<void> _onReactivar(
    ReactivarProductoMaestroEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(ProductoMaestroLoading());

    final result = await reactivarProductoMaestro(event.productoId);

    result.fold(
      (failure) => emit(ProductoMaestroError(message: failure.message)),
      (producto) => emit(ProductoMaestroReactivated(producto)),
    );
  }

  Future<void> _onValidarCombinacion(
    ValidarCombinacionComercialEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    final result = await validarCombinacionComercial(
      tipoId: event.tipoId,
      sistemaTallaId: event.sistemaTallaId,
    );

    result.fold(
      (failure) => emit(ProductoMaestroError(message: failure.message)),
      (warnings) => emit(CombinacionValidated(warnings)),
    );
  }
}
