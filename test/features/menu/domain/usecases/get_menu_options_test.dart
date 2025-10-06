import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/menu/domain/entities/menu_option.dart';
import 'package:system_web_medias/features/menu/domain/repositories/menu_repository.dart';
import 'package:system_web_medias/features/menu/domain/usecases/get_menu_options.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late GetMenuOptions useCase;
  late MockMenuRepository mockRepository;

  setUp(() {
    mockRepository = MockMenuRepository();
    useCase = GetMenuOptions(mockRepository);
  });

  const testUserId = 'test-user-id';
  final testMenuOptions = [
    const MenuOption(
      id: 'dashboard',
      label: 'Dashboard',
      icon: 'dashboard',
      route: '/dashboard',
    ),
    const MenuOption(
      id: 'productos',
      label: 'Productos',
      icon: 'inventory',
      children: [
        MenuOption(
          id: 'productos-catalogo',
          label: 'Gestionar catálogo',
          route: '/products',
        ),
      ],
    ),
  ];

  group('GetMenuOptions', () {
    test('should get menu options from repository', () async {
      // Arrange
      when(() => mockRepository.getMenuOptions(any()))
          .thenAnswer((_) async => Right(testMenuOptions));

      // Act
      final result = await useCase(const GetMenuOptionsParams(userId: testUserId));

      // Assert
      expect(result, Right(testMenuOptions));
      verify(() => mockRepository.getMenuOptions(testUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      const testFailure = ServerFailure('Error del servidor');
      when(() => mockRepository.getMenuOptions(any()))
          .thenAnswer((_) async => const Left(testFailure));

      // Act
      final result = await useCase(const GetMenuOptionsParams(userId: testUserId));

      // Assert
      expect(result, const Left(testFailure));
      verify(() => mockRepository.getMenuOptions(testUserId)).called(1);
    });

    test('should return NotFoundFailure when user not found', () async {
      // Arrange
      const testFailure = NotFoundFailure('Usuario no encontrado');
      when(() => mockRepository.getMenuOptions(any()))
          .thenAnswer((_) async => const Left(testFailure));

      // Act
      final result = await useCase(const GetMenuOptionsParams(userId: testUserId));

      // Assert
      expect(result, const Left(testFailure));
    });

    test('should return ForbiddenFailure when user not authorized', () async {
      // Arrange
      const testFailure = ForbiddenFailure('No autorizado');
      when(() => mockRepository.getMenuOptions(any()))
          .thenAnswer((_) async => const Left(testFailure));

      // Act
      final result = await useCase(const GetMenuOptionsParams(userId: testUserId));

      // Assert
      expect(result, const Left(testFailure));
    });
  });

  group('GetMenuOptionsParams', () {
    test('should have correct props', () {
      const params1 = GetMenuOptionsParams(userId: 'id-1');
      const params2 = GetMenuOptionsParams(userId: 'id-1');
      const params3 = GetMenuOptionsParams(userId: 'id-2');

      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });
  });
}
