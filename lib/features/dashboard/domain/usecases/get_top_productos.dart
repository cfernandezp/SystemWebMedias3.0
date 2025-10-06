import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/top_producto.dart';
import 'package:system_web_medias/features/dashboard/domain/repositories/dashboard_repository.dart';

/// UseCase para obtener top productos más vendidos
class GetTopProductos {
  final DashboardRepository repository;

  GetTopProductos(this.repository);

  Future<Either<Failure, List<TopProducto>>> call(Params params) async {
    return await repository.getTopProductos(
      params.userId,
      limit: params.limit,
    );
  }
}

class Params extends Equatable {
  final String userId;
  final int limit;

  const Params({
    required this.userId,
    this.limit = 5,
  });

  @override
  List<Object?> get props => [userId, limit];
}
