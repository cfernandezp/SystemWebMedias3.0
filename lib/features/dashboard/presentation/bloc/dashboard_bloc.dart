import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/dashboard/domain/usecases/get_dashboard_metrics.dart'
    as get_dashboard_metrics;
import 'package:system_web_medias/features/dashboard/domain/usecases/get_sales_chart.dart'
    as get_sales_chart;
import 'package:system_web_medias/features/dashboard/domain/usecases/get_top_productos.dart'
    as get_top_productos;
import 'package:system_web_medias/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:system_web_medias/features/dashboard/presentation/bloc/dashboard_state.dart';

/// Bloc para gestionar el estado del dashboard
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final get_dashboard_metrics.GetDashboardMetrics getDashboardMetrics;
  final get_sales_chart.GetSalesChart getSalesChart;
  final get_top_productos.GetTopProductos getTopProductos;

  DashboardBloc({
    required this.getDashboardMetrics,
    required this.getSalesChart,
    required this.getTopProductos,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    // Obtener métricas
    final metricsResult = await getDashboardMetrics(
        get_dashboard_metrics.Params(userId: event.userId));

    // Si falló, emitir error
    if (metricsResult.isLeft()) {
      final failure = metricsResult.fold((l) => l, (r) => null);
      emit(DashboardError(message: failure?.message ?? 'Error desconocido'));
      return;
    }

    // Obtener sales chart
    final chartResult =
        await getSalesChart(get_sales_chart.Params(userId: event.userId));

    if (chartResult.isLeft()) {
      final failure = chartResult.fold((l) => l, (r) => null);
      emit(DashboardError(message: failure?.message ?? 'Error desconocido'));
      return;
    }

    // Obtener top productos
    final productosResult = await getTopProductos(
        get_top_productos.Params(userId: event.userId));

    if (productosResult.isLeft()) {
      final failure = productosResult.fold((l) => l, (r) => null);
      emit(DashboardError(message: failure?.message ?? 'Error desconocido'));
      return;
    }

    // Todos exitosos, extraer valores
    final metrics = metricsResult.fold((l) => null, (r) => r)!;
    final salesChart = chartResult.fold((l) => null, (r) => r)!;
    final topProductos = productosResult.fold((l) => null, (r) => r)!;

    emit(DashboardLoaded(
      metrics: metrics,
      salesChart: salesChart,
      topProductos: topProductos,
    ));
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // Obtener métricas
    final metricsResult = await getDashboardMetrics(
        get_dashboard_metrics.Params(userId: event.userId));

    // Si falló, mantener estado actual
    if (metricsResult.isLeft()) {
      return;
    }

    // Obtener sales chart
    final chartResult =
        await getSalesChart(get_sales_chart.Params(userId: event.userId));

    if (chartResult.isLeft()) {
      return;
    }

    // Obtener top productos
    final productosResult = await getTopProductos(
        get_top_productos.Params(userId: event.userId));

    if (productosResult.isLeft()) {
      return;
    }

    // Todos exitosos, extraer valores
    final metrics = metricsResult.fold((l) => null, (r) => r)!;
    final salesChart = chartResult.fold((l) => null, (r) => r)!;
    final topProductos = productosResult.fold((l) => null, (r) => r)!;

    emit(DashboardLoaded(
      metrics: metrics,
      salesChart: salesChart,
      topProductos: topProductos,
    ));
  }
}
