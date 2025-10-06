import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/sales_chart_data.dart';
import 'package:system_web_medias/features/dashboard/domain/repositories/dashboard_repository.dart';

/// UseCase para obtener datos de gráfico de ventas
class GetSalesChart {
  final DashboardRepository repository;

  GetSalesChart(this.repository);

  Future<Either<Failure, List<SalesChartData>>> call(Params params) async {
    return await repository.getSalesChart(
      params.userId,
      months: params.months,
    );
  }
}

class Params extends Equatable {
  final String userId;
  final int months;

  const Params({
    required this.userId,
    this.months = 6,
  });

  @override
  List<Object?> get props => [userId, months];
}
