import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/menu/domain/repositories/menu_repository.dart';
import 'package:system_web_medias/features/menu/domain/usecases/update_sidebar_preference.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late UpdateSidebarPreference useCase;
  late MockMenuRepository mockRepository;

  setUp(() {
    mockRepository = MockMenuRepository();
    useCase = UpdateSidebarPreference(mockRepository);
  });

  const testUserId = 'test-user-id';

  group('UpdateSidebarPreference', () {
    test('should update sidebar preference to collapsed', () async {
      // Arrange
      when(() => mockRepository.updateSidebarPreference(any(), any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(const UpdateSidebarPreferenceParams(
        userId: testUserId,
        collapsed: true,
      ));

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.updateSidebarPreference(testUserId, true)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should update sidebar preference to expanded', () async {
      // Arrange
      when(() => mockRepository.updateSidebarPreference(any(), any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(const UpdateSidebarPreferenceParams(
        userId: testUserId,
        collapsed: false,
      ));

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.updateSidebarPreference(testUserId, false)).called(1);
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      const testFailure = ServerFailure('Error del servidor');
      when(() => mockRepository.updateSidebarPreference(any(), any()))
          .thenAnswer((_) async => const Left(testFailure));

      // Act
      final result = await useCase(const UpdateSidebarPreferenceParams(
        userId: testUserId,
        collapsed: true,
      ));

      // Assert
      expect(result, const Left(testFailure));
      verify(() => mockRepository.updateSidebarPreference(testUserId, true)).called(1);
    });

    test('should return NotFoundFailure when user not found', () async {
      // Arrange
      const testFailure = NotFoundFailure('Usuario no encontrado');
      when(() => mockRepository.updateSidebarPreference(any(), any()))
          .thenAnswer((_) async => const Left(testFailure));

      // Act
      final result = await useCase(const UpdateSidebarPreferenceParams(
        userId: testUserId,
        collapsed: true,
      ));

      // Assert
      expect(result, const Left(testFailure));
    });
  });

  group('UpdateSidebarPreferenceParams', () {
    test('should have correct props', () {
      const params1 = UpdateSidebarPreferenceParams(userId: 'id-1', collapsed: true);
      const params2 = UpdateSidebarPreferenceParams(userId: 'id-1', collapsed: true);
      const params3 = UpdateSidebarPreferenceParams(userId: 'id-1', collapsed: false);

      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });
  });
}
