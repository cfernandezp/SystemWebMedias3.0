import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/domain/usecases/crear_producto_completo_usecase.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_completo_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_completo_state.dart';

class ProductoCompletoBloc extends Bloc<ProductoCompletoEvent, ProductoCompletoState> {
  final CrearProductoCompletoUseCase crearProductoCompletoUseCase;

  ProductoCompletoBloc({
    required this.crearProductoCompletoUseCase,
  }) : super(const ProductoCompletoInitial()) {
    on<CreateProductoCompletoEvent>(_onCreateProductoCompleto);
    on<ResetProductoCompletoEvent>(_onReset);
  }

  Future<void> _onCreateProductoCompleto(
    CreateProductoCompletoEvent event,
    Emitter<ProductoCompletoState> emit,
  ) async {
    emit(const ProductoCompletoCreating());

    final result = await crearProductoCompletoUseCase(event.request);

    result.fold(
      (failure) {
        final type = _mapFailureToType(failure);
        emit(ProductoCompletoError(failure.message, type));
      },
      (response) {
        emit(ProductoCompletoCreated(
          response,
          navigateTo: '/productos-maestros/${response.productoMaestroId}',
        ));
      },
    );
  }

  void _onReset(
    ResetProductoCompletoEvent event,
    Emitter<ProductoCompletoState> emit,
  ) {
    emit(const ProductoCompletoInitial());
  }

  FailureType _mapFailureToType(Failure failure) {
    if (failure is DuplicateCombinationFailure) return FailureType.duplicate;
    if (failure is ValidationFailure) return FailureType.validation;
    if (failure is UnauthorizedFailure) return FailureType.unauthorized;
    if (failure is ServerFailure) return FailureType.server;
    if (failure is ConnectionFailure) return FailureType.network;
    return FailureType.server;
  }
}
