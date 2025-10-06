import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/dashboard_metrics.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/sales_chart_data.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/top_producto.dart';

/// Estados del DashboardBloc
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DashboardInitial extends DashboardState {}

/// Estado de carga
class DashboardLoading extends DashboardState {}

/// Estado de dashboard cargado exitosamente
class DashboardLoaded extends DashboardState {
  final DashboardMetrics metrics;
  final List<SalesChartData> salesChart;
  final List<TopProducto> topProductos;

  const DashboardLoaded({
    required this.metrics,
    required this.salesChart,
    required this.topProductos,
  });

  @override
  List<Object?> get props => [metrics, salesChart, topProductos];
}

/// Estado de error
class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
