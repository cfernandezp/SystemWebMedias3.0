import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/dashboard/domain/repositories/dashboard_repository.dart';

/// UseCase para refrescar métricas del dashboard
class RefreshDashboard {
  final DashboardRepository repository;

  RefreshDashboard(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.refreshMetrics();
  }
}
