import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_completo_request_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_completo_response_model.dart';
import 'package:system_web_medias/features/productos_maestros/domain/repositories/producto_maestro_repository.dart';

class CrearProductoCompletoUseCase {
  final ProductoMaestroRepository repository;

  CrearProductoCompletoUseCase(this.repository);

  Future<Either<Failure, ProductoCompletoResponseModel>> call(
    ProductoCompletoRequestModel request,
  ) async {
    return await repository.crearProductoCompleto(request);
  }
}
