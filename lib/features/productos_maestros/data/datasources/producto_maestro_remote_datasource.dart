import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_filter_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_completo_request_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_completo_response_model.dart';

abstract class ProductoMaestroRemoteDataSource {
  Future<Map<String, dynamic>> validarCombinacionComercial({
    required String tipoId,
    required String sistemaTallaId,
  });

  Future<ProductoMaestroModel> crearProductoMaestro({
    required String marcaId,
    required String materialId,
    required String tipoId,
    required String sistemaTallaId,
    String? descripcion,
  });

  Future<List<ProductoMaestroModel>> listarProductosMaestros({
    ProductoMaestroFilterModel? filtros,
  });

  Future<ProductoMaestroModel> editarProductoMaestro({
    required String productoId,
    String? descripcion,
  });

  Future<void> eliminarProductoMaestro({required String productoId});

  Future<Map<String, dynamic>> desactivarProductoMaestro({
    required String productoId,
    required bool desactivarArticulos,
  });

  Future<void> reactivarProductoMaestro({required String productoId});

  Future<ProductoCompletoResponseModel> crearProductoCompleto(ProductoCompletoRequestModel request);
}

class ProductoMaestroRemoteDataSourceImpl implements ProductoMaestroRemoteDataSource {
  final SupabaseClient supabase;

  ProductoMaestroRemoteDataSourceImpl({required this.supabase});

  @override
  Future<Map<String, dynamic>> validarCombinacionComercial({
    required String tipoId,
    required String sistemaTallaId,
  }) async {
    try {
      final response = await supabase.rpc(
        'validar_combinacion_comercial',
        params: {
          'p_tipo_id': tipoId,
          'p_sistema_talla_id': sistemaTallaId,
        },
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'tipo_not_found') {
          throw TipoNotFoundException(error['message'], 404);
        } else if (hint == 'sistema_not_found') {
          throw SistemaNotFoundException(error['message'], 404);
        } else {
          throw ServerException(error['message'], 500);
        }
      }

      return json['data'] as Map<String, dynamic>;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ProductoMaestroModel> crearProductoMaestro({
    required String marcaId,
    required String materialId,
    required String tipoId,
    required String sistemaTallaId,
    String? descripcion,
  }) async {
    try {
      final response = await supabase.rpc(
        'crear_producto_maestro',
        params: {
          'p_marca_id': marcaId,
          'p_material_id': materialId,
          'p_tipo_id': tipoId,
          'p_sistema_talla_id': sistemaTallaId,
          'p_descripcion': descripcion,
        },
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'duplicate_combination') {
          throw DuplicateCombinationException(error['message'], 409);
        } else if (hint == 'duplicate_combination_inactive') {
          throw DuplicateCombinationInactiveException(
            error['message'],
            409,
            productoId: error['producto_id'] as String?,
          );
        } else if (hint == 'inactive_catalog') {
          throw InactiveCatalogException(error['message'], 400);
        } else if (hint == 'invalid_description_length') {
          throw ValidationException(error['message'], 400);
        } else {
          throw ServerException(error['message'], 500);
        }
      }

      final data = json['data'] as Map<String, dynamic>;
      return ProductoMaestroModel.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<List<ProductoMaestroModel>> listarProductosMaestros({
    ProductoMaestroFilterModel? filtros,
  }) async {
    try {
      final response = await supabase.rpc(
        'listar_productos_maestros',
        params: {
          'p_marca_id': filtros?.marcaId,
          'p_material_id': filtros?.materialId,
          'p_tipo_id': filtros?.tipoId,
          'p_sistema_talla_id': filtros?.sistemaTallaId,
          'p_activo': filtros?.activo,
          'p_search_text': filtros?.searchText,
        },
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        throw ServerException(error['message'], 500);
      }

      final dataList = json['data'] as List;
      return dataList.map((item) => ProductoMaestroModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ProductoMaestroModel> editarProductoMaestro({
    required String productoId,
    String? descripcion,
  }) async {
    try {
      final response = await supabase.rpc(
        'editar_producto_maestro',
        params: {
          'p_producto_id': productoId,
          'p_descripcion': descripcion,
        },
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'has_derived_articles') {
          throw HasDerivedArticlesException(
            error['message'],
            400,
            totalArticles: error['total_articles'] as int?,
          );
        } else if (hint == 'producto_not_found') {
          throw ProductoMaestroNotFoundException(error['message'], 404);
        } else {
          throw ServerException(error['message'], 500);
        }
      }

      final data = json['data'] as Map<String, dynamic>;
      return ProductoMaestroModel.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<void> eliminarProductoMaestro({required String productoId}) async {
    try {
      final response = await supabase.rpc(
        'eliminar_producto_maestro',
        params: {'p_producto_id': productoId},
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'has_derived_articles') {
          throw HasDerivedArticlesException(
            error['message'],
            400,
            totalArticles: error['total_articles'] as int?,
          );
        } else if (hint == 'producto_not_found') {
          throw ProductoMaestroNotFoundException(error['message'], 404);
        } else {
          throw ServerException(error['message'], 500);
        }
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> desactivarProductoMaestro({
    required String productoId,
    required bool desactivarArticulos,
  }) async {
    try {
      final response = await supabase.rpc(
        'desactivar_producto_maestro',
        params: {
          'p_producto_id': productoId,
          'p_desactivar_articulos': desactivarArticulos,
        },
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'producto_not_found') {
          throw ProductoMaestroNotFoundException(error['message'], 404);
        } else {
          throw ServerException(error['message'], 500);
        }
      }

      return json['data'] as Map<String, dynamic>;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<void> reactivarProductoMaestro({required String productoId}) async {
    try {
      final response = await supabase.rpc(
        'reactivar_producto_maestro',
        params: {'p_producto_id': productoId},
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'inactive_catalog') {
          throw InactiveCatalogException(error['message'], 400);
        } else if (hint == 'producto_not_found') {
          throw ProductoMaestroNotFoundException(error['message'], 404);
        } else {
          throw ServerException(error['message'], 500);
        }
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ProductoCompletoResponseModel> crearProductoCompleto(
    ProductoCompletoRequestModel request,
  ) async {
    try {
      final response = await supabase.rpc(
        'crear_producto_completo',
        params: request.toJson(),
      );

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return ProductoCompletoResponseModel.fromJson(result);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'duplicate_producto') {
          throw DuplicateCombinationException(error['message'], 409);
        } else if (hint == 'unauthorized') {
          throw UnauthorizedException(error['message'], 401);
        } else if (hint == 'invalid_catalog') {
          throw InactiveCatalogException(error['message'], 400);
        } else if (hint == 'invalid_color') {
          throw ColorInactiveException(error['message'], 400);
        } else if (hint == 'duplicate_sku') {
          throw DuplicateSkuException(error['message'], 409);
        }
        throw ServerException(error['message'], 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }
}
