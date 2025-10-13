import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/validar_combinacion_comercial.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/crear_producto_maestro.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/listar_productos_maestros.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/editar_producto_maestro.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/eliminar_producto_maestro.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/desactivar_producto_maestro.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/reactivar_producto_maestro.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_state.dart';

class ProductoMaestroBloc extends Bloc<ProductoMaestroEvent, ProductoMaestroState> {
  final ValidarCombinacionComercial validarCombinacionComercial;
  final CrearProductoMaestro crearProductoMaestro;
  final ListarProductosMaestros listarProductosMaestros;
  final EditarProductoMaestro editarProductoMaestro;
  final EliminarProductoMaestro eliminarProductoMaestro;
  final DesactivarProductoMaestro desactivarProductoMaestro;
  final ReactivarProductoMaestro reactivarProductoMaestro;

  ProductoMaestroBloc({
    required this.validarCombinacionComercial,
    required this.crearProductoMaestro,
    required this.listarProductosMaestros,
    required this.editarProductoMaestro,
    required this.eliminarProductoMaestro,
    required this.desactivarProductoMaestro,
    required this.reactivarProductoMaestro,
  }) : super(const ProductoMaestroInitial()) {
    on<ValidarCombinacionEvent>(_onValidarCombinacion);
    on<CrearProductoMaestroEvent>(_onCrearProductoMaestro);
    on<ListarProductosMaestrosEvent>(_onListarProductosMaestros);
    on<EditarProductoMaestroEvent>(_onEditarProductoMaestro);
    on<EliminarProductoMaestroEvent>(_onEliminarProductoMaestro);
    on<DesactivarProductoMaestroEvent>(_onDesactivarProductoMaestro);
    on<ReactivarProductoMaestroEvent>(_onReactivarProductoMaestro);
  }

  Future<void> _onValidarCombinacion(
    ValidarCombinacionEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(const ProductoMaestroLoading());

    final result = await validarCombinacionComercial(
      tipoId: event.tipoId,
      sistemaTallaId: event.sistemaTallaId,
    );

    result.fold(
      (failure) => emit(ProductoMaestroError(message: failure.message)),
      (validacion) => emit(ValidacionCombinacionSuccess(validacion: validacion)),
    );
  }

  Future<void> _onCrearProductoMaestro(
    CrearProductoMaestroEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(const ProductoMaestroLoading());

    final result = await crearProductoMaestro(
      marcaId: event.marcaId,
      materialId: event.materialId,
      tipoId: event.tipoId,
      sistemaTallaId: event.sistemaTallaId,
      descripcion: event.descripcion,
    );

    await result.fold(
      (failure) async => emit(ProductoMaestroError(message: failure.message)),
      (producto) async {
        final productosResult = await listarProductosMaestros();
        productosResult.fold(
          (failure) => emit(ProductoMaestroError(message: failure.message)),
          (productos) => emit(ProductoMaestroOperationSuccess(
            message: 'Producto maestro creado exitosamente',
            productos: productos,
          )),
        );
      },
    );
  }

  Future<void> _onListarProductosMaestros(
    ListarProductosMaestrosEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(const ProductoMaestroLoading());

    final result = await listarProductosMaestros(filtros: event.filtros);

    result.fold(
      (failure) => emit(ProductoMaestroError(message: failure.message)),
      (productos) => emit(ProductoMaestroLoaded(productos: productos)),
    );
  }

  Future<void> _onEditarProductoMaestro(
    EditarProductoMaestroEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(const ProductoMaestroLoading());

    final result = await editarProductoMaestro(
      productoId: event.productoId,
      descripcion: event.descripcion,
    );

    await result.fold(
      (failure) async => emit(ProductoMaestroError(message: failure.message)),
      (producto) async {
        final productosResult = await listarProductosMaestros();
        productosResult.fold(
          (failure) => emit(ProductoMaestroError(message: failure.message)),
          (productos) => emit(ProductoMaestroOperationSuccess(
            message: 'Producto maestro actualizado exitosamente',
            productos: productos,
          )),
        );
      },
    );
  }

  Future<void> _onEliminarProductoMaestro(
    EliminarProductoMaestroEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(const ProductoMaestroLoading());

    final result = await eliminarProductoMaestro(productoId: event.productoId);

    await result.fold(
      (failure) async => emit(ProductoMaestroError(message: failure.message)),
      (_) async {
        final productosResult = await listarProductosMaestros();
        productosResult.fold(
          (failure) => emit(ProductoMaestroError(message: failure.message)),
          (productos) => emit(ProductoMaestroOperationSuccess(
            message: 'Producto maestro eliminado exitosamente',
            productos: productos,
          )),
        );
      },
    );
  }

  Future<void> _onDesactivarProductoMaestro(
    DesactivarProductoMaestroEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(const ProductoMaestroLoading());

    final result = await desactivarProductoMaestro(
      productoId: event.productoId,
      desactivarArticulos: event.desactivarArticulos,
    );

    await result.fold(
      (failure) async => emit(ProductoMaestroError(message: failure.message)),
      (info) async {
        final productosResult = await listarProductosMaestros();
        productosResult.fold(
          (failure) => emit(ProductoMaestroError(message: failure.message)),
          (productos) => emit(DesactivacionInfo(
            info: info,
            productos: productos,
          )),
        );
      },
    );
  }

  Future<void> _onReactivarProductoMaestro(
    ReactivarProductoMaestroEvent event,
    Emitter<ProductoMaestroState> emit,
  ) async {
    emit(const ProductoMaestroLoading());

    final result = await reactivarProductoMaestro(productoId: event.productoId);

    await result.fold(
      (failure) async => emit(ProductoMaestroError(message: failure.message)),
      (_) async {
        final productosResult = await listarProductosMaestros();
        productosResult.fold(
          (failure) => emit(ProductoMaestroError(message: failure.message)),
          (productos) => emit(ProductoMaestroOperationSuccess(
            message: 'Producto maestro reactivado exitosamente',
            productos: productos,
          )),
        );
      },
    );
  }
}
