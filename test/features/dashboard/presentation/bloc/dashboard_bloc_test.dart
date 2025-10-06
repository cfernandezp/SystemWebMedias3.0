import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/vendedor_metrics.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/sales_chart_data.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/top_producto.dart';
import 'package:system_web_medias/features/dashboard/domain/usecases/get_dashboard_metrics.dart'
    as get_dashboard_metrics;
import 'package:system_web_medias/features/dashboard/domain/usecases/get_sales_chart.dart'
    as get_sales_chart;
import 'package:system_web_medias/features/dashboard/domain/usecases/get_top_productos.dart'
    as get_top_productos;
import 'package:system_web_medias/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:system_web_medias/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:system_web_medias/features/dashboard/presentation/bloc/dashboard_state.dart';

class MockGetDashboardMetrics extends Mock
    implements get_dashboard_metrics.GetDashboardMetrics {}

class MockGetSalesChart extends Mock implements get_sales_chart.GetSalesChart {}

class MockGetTopProductos extends Mock
    implements get_top_productos.GetTopProductos {}

void main() {
  late DashboardBloc bloc;
  late MockGetDashboardMetrics mockGetDashboardMetrics;
  late MockGetSalesChart mockGetSalesChart;
  late MockGetTopProductos mockGetTopProductos;

  setUp(() {
    mockGetDashboardMetrics = MockGetDashboardMetrics();
    mockGetSalesChart = MockGetSalesChart();
    mockGetTopProductos = MockGetTopProductos();

    bloc = DashboardBloc(
      getDashboardMetrics: mockGetDashboardMetrics,
      getSalesChart: mockGetSalesChart,
      getTopProductos: mockGetTopProductos,
    );

    // Register fallback values
    registerFallbackValue(
        const get_dashboard_metrics.Params(userId: 'test-user-id'));
    registerFallbackValue(const get_sales_chart.Params(userId: 'test-user-id'));
    registerFallbackValue(
        const get_top_productos.Params(userId: 'test-user-id'));
  });

  tearDown(() {
    bloc.close();
  });

  const tUserId = 'test-user-id';
  const tVendedorMetrics = VendedorMetrics(
    ventasHoy: 1250.50,
    comisionesMes: 350.75,
    ordenesPendientes: 3,
    productosStockBajo: 5,
  );
  const tSalesChartData = [
    SalesChartData(mes: '2025-10', ventas: 35000.00),
    SalesChartData(mes: '2025-09', ventas: 42000.00),
  ];
  const tTopProductos = [
    TopProducto(
      productoId: 'uuid-1',
      nombre: 'Medias Deportivas',
      cantidadVendida: 120,
    ),
  ];

  test('initial state should be DashboardInitial', () {
    expect(bloc.state, DashboardInitial());
  });

  group('LoadDashboard', () {
    blocTest<DashboardBloc, DashboardState>(
      'should emit [DashboardLoading, DashboardLoaded] when all data loads successfully',
      build: () {
        when(() => mockGetDashboardMetrics(any()))
            .thenAnswer((_) async => const Right(tVendedorMetrics));
        when(() => mockGetSalesChart(any()))
            .thenAnswer((_) async => const Right(tSalesChartData));
        when(() => mockGetTopProductos(any()))
            .thenAnswer((_) async => const Right(tTopProductos));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadDashboard(userId: tUserId)),
      expect: () => [
        DashboardLoading(),
        const DashboardLoaded(
          metrics: tVendedorMetrics,
          salesChart: tSalesChartData,
          topProductos: tTopProductos,
        ),
      ],
      verify: (_) {
        verify(() => mockGetDashboardMetrics(any())).called(1);
        verify(() => mockGetSalesChart(any())).called(1);
        verify(() => mockGetTopProductos(any())).called(1);
      },
    );

    blocTest<DashboardBloc, DashboardState>(
      'should emit [DashboardLoading, DashboardError] when getMetrics fails',
      build: () {
        when(() => mockGetDashboardMetrics(any())).thenAnswer(
            (_) async => const Left(ServerFailure('Error del servidor')));
        when(() => mockGetSalesChart(any()))
            .thenAnswer((_) async => const Right(tSalesChartData));
        when(() => mockGetTopProductos(any()))
            .thenAnswer((_) async => const Right(tTopProductos));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadDashboard(userId: tUserId)),
      expect: () => [
        DashboardLoading(),
        const DashboardError(message: 'Error del servidor'),
      ],
    );
  });

  group('RefreshDashboard', () {
    blocTest<DashboardBloc, DashboardState>(
      'should emit updated DashboardLoaded when refresh is successful',
      build: () {
        // Usamos métricas diferentes para que Equatable emita el nuevo estado
        const updatedMetrics = VendedorMetrics(
          ventasHoy: 1350.00, // Valor diferente
          comisionesMes: 350.75,
          ordenesPendientes: 3,
          productosStockBajo: 5,
        );
        when(() => mockGetDashboardMetrics(any()))
            .thenAnswer((_) async => const Right(updatedMetrics));
        when(() => mockGetSalesChart(any()))
            .thenAnswer((_) async => const Right(tSalesChartData));
        when(() => mockGetTopProductos(any()))
            .thenAnswer((_) async => const Right(tTopProductos));
        return bloc;
      },
      seed: () => const DashboardLoaded(
        metrics: tVendedorMetrics,
        salesChart: tSalesChartData,
        topProductos: tTopProductos,
      ),
      act: (bloc) => bloc.add(const RefreshDashboard(userId: tUserId)),
      expect: () => [
        const DashboardLoaded(
          metrics: VendedorMetrics(
            ventasHoy: 1350.00,
            comisionesMes: 350.75,
            ordenesPendientes: 3,
            productosStockBajo: 5,
          ),
          salesChart: tSalesChartData,
          topProductos: tTopProductos,
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'should maintain current state when refresh fails',
      build: () {
        when(() => mockGetDashboardMetrics(any())).thenAnswer(
            (_) async => const Left(ConnectionFailure('Sin conexión')));
        when(() => mockGetSalesChart(any()))
            .thenAnswer((_) async => const Right(tSalesChartData));
        when(() => mockGetTopProductos(any()))
            .thenAnswer((_) async => const Right(tTopProductos));
        return bloc;
      },
      seed: () => const DashboardLoaded(
        metrics: tVendedorMetrics,
        salesChart: tSalesChartData,
        topProductos: tTopProductos,
      ),
      act: (bloc) => bloc.add(const RefreshDashboard(userId: tUserId)),
      expect: () => [],
    );
  });
}
