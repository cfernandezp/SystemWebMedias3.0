import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_filter_model.dart';

abstract class ProductoMaestroRemoteDatasource {
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
    String? marcaId,
    String? materialId,
    String? tipoId,
    String? sistemaTallaId,
    String? descripcion,
  });

  Future<void> eliminarProductoMaestro(String productoId);

  Future<int> desactivarProductoMaestro({
    required String productoId,
    required bool desactivarArticulos,
  });

  Future<ProductoMaestroModel> reactivarProductoMaestro(String productoId);

  Future<List<String>> validarCombinacionComercial({
    required String tipoId,
    required String sistemaTallaId,
  });
}

class ProductoMaestroRemoteDatasourceImpl
    implements ProductoMaestroRemoteDatasource {
  final SupabaseClient supabase;

  ProductoMaestroRemoteDatasourceImpl({required this.supabase});

  @override
  Future<ProductoMaestroModel> crearProductoMaestro({
    required String marcaId,
    required String materialId,
    required String tipoId,
    required String sistemaTallaId,
    String? descripcion,
  }) async {
    try {
      final response = await supabase.rpc('crear_producto_maestro', params: {
        'p_marca_id': marcaId,
        'p_material_id': materialId,
        'p_tipo_id': tipoId,
        'p_sistema_talla_id': sistemaTallaId,
        'p_descripcion': descripcion,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return ProductoMaestroModel.fromJson(
            result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'duplicate_combination') {
          throw DuplicateCombinationException(message, 409);
        } else if (hint == 'duplicate_combination_inactive') {
          throw DuplicateCombinationInactiveException(
            message,
            409,
            productoId: error['producto_id'] as String?,
          );
        } else if (hint == 'inactive_catalog') {
          throw InactiveCatalogException(message, 400);
        } else if (hint == 'invalid_description_length') {
          throw ValidationException(message, 400);
        }

        throw ServerException(message, 500);
      }
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
      final params = filtros?.toJson() ?? {};

      final response =
          await supabase.rpc('listar_productos_maestros', params: params);

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;
        return data
            .map((json) =>
                ProductoMaestroModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final error = result['error'] as Map<String, dynamic>;
        throw ServerException(error['message'] as String, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ProductoMaestroModel> editarProductoMaestro({
    required String productoId,
    String? marcaId,
    String? materialId,
    String? tipoId,
    String? sistemaTallaId,
    String? descripcion,
  }) async {
    try {
      final params = <String, dynamic>{'p_producto_id': productoId};

      if (marcaId != null) params['p_marca_id'] = marcaId;
      if (materialId != null) params['p_material_id'] = materialId;
      if (tipoId != null) params['p_tipo_id'] = tipoId;
      if (sistemaTallaId != null) {
        params['p_sistema_talla_id'] = sistemaTallaId;
      }
      if (descripcion != null) params['p_descripcion'] = descripcion;

      final response =
          await supabase.rpc('editar_producto_maestro', params: params);

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return ProductoMaestroModel.fromJson(
            result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'has_derived_articles') {
          throw HasDerivedArticlesException(
            message,
            400,
            totalArticles: error['total_articles'] as int?,
          );
        } else if (hint == 'producto_not_found') {
          throw ProductoMaestroNotFoundException(message, 404);
        } else if (hint == 'inactive_catalog') {
          throw InactiveCatalogException(message, 400);
        } else if (hint == 'duplicate_combination') {
          throw DuplicateCombinationException(message, 409);
        }

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<void> eliminarProductoMaestro(String productoId) async {
    try {
      final response = await supabase.rpc('eliminar_producto_maestro',
          params: {'p_producto_id': productoId});

      final result = response as Map<String, dynamic>;

      if (result['success'] != true) {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'has_derived_articles') {
          throw HasDerivedArticlesException(
            message,
            400,
            totalArticles: error['total_articles'] as int?,
          );
        } else if (hint == 'producto_not_found') {
          throw ProductoMaestroNotFoundException(message, 404);
        }

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<int> desactivarProductoMaestro({
    required String productoId,
    required bool desactivarArticulos,
  }) async {
    try {
      final response =
          await supabase.rpc('desactivar_producto_maestro', params: {
        'p_producto_id': productoId,
        'p_desactivar_articulos': desactivarArticulos,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        return data['articulos_activos_afectados'] as int? ?? 0;
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'producto_not_found') {
          throw ProductoMaestroNotFoundException(message, 404);
        }

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ProductoMaestroModel> reactivarProductoMaestro(
      String productoId) async {
    try {
      final response = await supabase.rpc('reactivar_producto_maestro',
          params: {'p_producto_id': productoId});

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        return ProductoMaestroModel.fromJson(
            result['data'] as Map<String, dynamic>);
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'inactive_catalog') {
          throw InactiveCatalogException(message, 400);
        } else if (hint == 'producto_not_found') {
          throw ProductoMaestroNotFoundException(message, 404);
        }

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<List<String>> validarCombinacionComercial({
    required String tipoId,
    required String sistemaTallaId,
  }) async {
    try {
      final response =
          await supabase.rpc('validar_combinacion_comercial', params: {
        'p_tipo_id': tipoId,
        'p_sistema_talla_id': sistemaTallaId,
      });

      final result = response as Map<String, dynamic>;

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final warnings = data['warnings'] as List<dynamic>?;
        return warnings?.map((e) => e.toString()).toList() ?? [];
      } else {
        final error = result['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;
        final message = error['message'] as String;

        if (hint == 'tipo_not_found') {
          throw TipoNotFoundException(message, 404);
        } else if (hint == 'sistema_not_found') {
          throw SistemaNotFoundException(message, 404);
        }

        throw ServerException(message, 500);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }
}
