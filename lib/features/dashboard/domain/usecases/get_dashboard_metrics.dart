import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:system_web_medias/features/dashboard/domain/repositories/dashboard_repository.dart';

/// UseCase para obtener métricas del dashboard según rol
class GetDashboardMetrics {
  final DashboardRepository repository;

  GetDashboardMetrics(this.repository);

  Future<Either<Failure, DashboardMetrics>> call(Params params) async {
    return await repository.getMetrics(params.userId);
  }
}

class Params extends Equatable {
  final String userId;

  const Params({required this.userId});

  @override
  List<Object?> get props => [userId];
}
