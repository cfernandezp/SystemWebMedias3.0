import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/features/articulos/data/models/articulo_model.dart';
import 'package:system_web_medias/features/articulos/data/models/filtros_articulos_model.dart';

abstract class ArticulosRemoteDataSource {
  Future<Map<String, dynamic>> generarSku({
    required String productoMaestroId,
    required List<String> coloresIds,
  });

  Future<Map<String, dynamic>> validarSkuUnico({
    required String sku,
    String? articuloId,
  });

  Future<ArticuloModel> crearArticulo({
    required String productoMaestroId,
    required List<String> coloresIds,
    required double precio,
  });

  Future<List<ArticuloModel>> listarArticulos({
    FiltrosArticulosModel? filtros,
    int? limit,
    int? offset,
  });

  Future<ArticuloModel> obtenerArticulo({required String articuloId});

  Future<ArticuloModel> editarArticulo({
    required String articuloId,
    double? precio,
    bool? activo,
  });

  Future<void> eliminarArticulo({required String articuloId});

  Future<Map<String, dynamic>> desactivarArticulo({required String articuloId});
}

class ArticulosRemoteDataSourceImpl implements ArticulosRemoteDataSource {
  final SupabaseClient supabase;

  ArticulosRemoteDataSourceImpl({required this.supabase});

  @override
  Future<Map<String, dynamic>> generarSku({
    required String productoMaestroId,
    required List<String> coloresIds,
  }) async {
    try {
      final response = await supabase.rpc(
        'generar_sku',
        params: {
          'p_producto_maestro_id': productoMaestroId,
          'p_colores_ids': coloresIds,
        },
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'producto_maestro_not_found') {
          throw ProductoMaestroNotFoundException(error['message'], 404);
        } else if (hint == 'color_not_found') {
          throw ColorNotFoundException(error['message'], 404);
        } else if (hint == 'missing_catalog_codes') {
          throw ValidationException(error['message'], 400);
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
  Future<Map<String, dynamic>> validarSkuUnico({
    required String sku,
    String? articuloId,
  }) async {
    try {
      final response = await supabase.rpc(
        'validar_sku_unico',
        params: {
          'p_sku': sku,
          'p_articulo_id': articuloId,
        },
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        throw ServerException(error['message'], 500);
      }

      return json['data'] as Map<String, dynamic>;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ArticuloModel> crearArticulo({
    required String productoMaestroId,
    required List<String> coloresIds,
    required double precio,
  }) async {
    try {
      final response = await supabase.rpc(
        'crear_articulo',
        params: {
          'p_producto_maestro_id': productoMaestroId,
          'p_colores_ids': coloresIds,
          'p_precio': precio,
        },
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'colores_required') {
          throw ValidationException(error['message'], 400);
        } else if (hint == 'invalid_color_count') {
          throw InvalidColorCountException(error['message'], 400);
        } else if (hint == 'producto_maestro_not_found') {
          throw ProductoMaestroNotFoundException(error['message'], 404);
        } else if (hint == 'producto_maestro_inactive') {
          throw InactiveCatalogException(error['message'], 400);
        } else if (hint == 'catalog_inactive') {
          throw InactiveCatalogException(error['message'], 400);
        } else if (hint == 'color_inactive') {
          throw ColorInactiveException(error['message'], 400);
        } else if (hint == 'invalid_price') {
          throw InvalidPriceException(error['message'], 400);
        } else if (hint == 'duplicate_sku') {
          throw DuplicateSkuException(error['message'], 409);
        } else {
          throw ServerException(error['message'], 500);
        }
      }

      final data = json['data'] as Map<String, dynamic>;
      return ArticuloModel.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<List<ArticuloModel>> listarArticulos({
    FiltrosArticulosModel? filtros,
    int? limit,
    int? offset,
  }) async {
    try {
      final params = <String, dynamic>{
        'p_producto_maestro_id': filtros?.productoMaestroId,
        'p_marca_id': filtros?.marcaId,
        'p_tipo_id': filtros?.tipoId,
        'p_material_id': filtros?.materialId,
        'p_activo': filtros?.activo,
        'p_search': filtros?.searchText,
        'p_limit': limit ?? 50,
        'p_offset': offset ?? 0,
      };

      final response = await supabase.rpc('listar_articulos', params: params);

      if (response == null) {
        throw ServerException('Respuesta nula del servidor', 500);
      }

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>? ?? {};
        final message = error['message'] as String? ?? 'Error desconocido';
        throw ServerException(message, 500);
      }

      final data = json['data'] as Map<String, dynamic>? ?? {};
      final articulosList = data['articulos'] as List? ?? [];

      if (articulosList.isEmpty) {
        return [];
      }

      return articulosList
          .map((item) => ArticuloModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ArticuloModel> obtenerArticulo({required String articuloId}) async {
    try {
      final response = await supabase.rpc(
        'obtener_articulo',
        params: {'p_articulo_id': articuloId},
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'articulo_not_found') {
          throw ArticuloNotFoundException(error['message'], 404);
        } else {
          throw ServerException(error['message'], 500);
        }
      }

      final data = json['data'] as Map<String, dynamic>;
      return ArticuloModel.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<ArticuloModel> editarArticulo({
    required String articuloId,
    double? precio,
    bool? activo,
  }) async {
    try {
      final response = await supabase.rpc(
        'editar_articulo',
        params: {
          'p_articulo_id': articuloId,
          'p_precio': precio,
          'p_activo': activo,
        },
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'articulo_not_found') {
          throw ArticuloNotFoundException(error['message'], 404);
        } else if (hint == 'invalid_price') {
          throw InvalidPriceException(error['message'], 400);
        } else {
          throw ServerException(error['message'], 500);
        }
      }

      final data = json['data'] as Map<String, dynamic>;
      return ArticuloModel.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Error de conexión: $e');
    }
  }

  @override
  Future<void> eliminarArticulo({required String articuloId}) async {
    try {
      final response = await supabase.rpc(
        'eliminar_articulo',
        params: {'p_articulo_id': articuloId},
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'articulo_not_found') {
          throw ArticuloNotFoundException(error['message'], 404);
        } else if (hint == 'has_stock') {
          throw ArticuloHasStockException(error['message'], 400);
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
  Future<Map<String, dynamic>> desactivarArticulo({
    required String articuloId,
  }) async {
    try {
      final response = await supabase.rpc(
        'desactivar_articulo',
        params: {'p_articulo_id': articuloId},
      );

      final json = response as Map<String, dynamic>;

      if (json['success'] == false) {
        final error = json['error'] as Map<String, dynamic>;
        final hint = error['hint'] as String?;

        if (hint == 'articulo_not_found') {
          throw ArticuloNotFoundException(error['message'], 404);
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
}