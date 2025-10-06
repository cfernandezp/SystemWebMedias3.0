import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/dashboard/domain/entities/vendedor_metrics.dart';
import 'package:system_web_medias/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:system_web_medias/features/dashboard/domain/usecases/get_dashboard_metrics.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late GetDashboardMetrics usecase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    usecase = GetDashboardMetrics(mockRepository);
  });

  const tUserId = 'test-user-id';
  const tVendedorMetrics = VendedorMetrics(
    ventasHoy: 1250.50,
    comisionesMes: 350.75,
    ordenesPendientes: 3,
    productosStockBajo: 5,
  );

  test('should get metrics from the repository', () async {
    // Arrange
    when(() => mockRepository.getMetrics(any()))
        .thenAnswer((_) async => const Right(tVendedorMetrics));

    // Act
    final result = await usecase(const Params(userId: tUserId));

    // Assert
    expect(result, const Right(tVendedorMetrics));
    verify(() => mockRepository.getMetrics(tUserId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    const tFailure = ServerFailure('Error del servidor');
    when(() => mockRepository.getMetrics(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(const Params(userId: tUserId));

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.getMetrics(tUserId)).called(1);
  });
}
