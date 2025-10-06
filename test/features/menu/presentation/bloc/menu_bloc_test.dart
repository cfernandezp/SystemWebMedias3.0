import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/menu/domain/entities/menu_option.dart';
import 'package:system_web_medias/features/menu/domain/usecases/get_menu_options.dart';
import 'package:system_web_medias/features/menu/domain/usecases/update_sidebar_preference.dart';
import 'package:system_web_medias/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:system_web_medias/features/menu/presentation/bloc/menu_event.dart';
import 'package:system_web_medias/features/menu/presentation/bloc/menu_state.dart';

class MockGetMenuOptions extends Mock implements GetMenuOptions {}

class MockUpdateSidebarPreference extends Mock implements UpdateSidebarPreference {}

void main() {
  late MenuBloc bloc;
  late MockGetMenuOptions mockGetMenuOptions;
  late MockUpdateSidebarPreference mockUpdateSidebarPreference;

  setUp(() {
    mockGetMenuOptions = MockGetMenuOptions();
    mockUpdateSidebarPreference = MockUpdateSidebarPreference();
    bloc = MenuBloc(
      getMenuOptions: mockGetMenuOptions,
      updateSidebarPreference: mockUpdateSidebarPreference,
    );
  });

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(const GetMenuOptionsParams(userId: ''));
    registerFallbackValue(const UpdateSidebarPreferenceParams(userId: '', collapsed: false));
  });

  tearDown(() {
    bloc.close();
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

  group('MenuBloc', () {
    test('initial state should be MenuInitial', () {
      expect(bloc.state, equals(MenuInitial()));
    });

    group('LoadMenuEvent', () {
      blocTest<MenuBloc, MenuState>(
        'should emit [MenuLoading, MenuLoaded] when menu loads successfully',
        build: () {
          when(() => mockGetMenuOptions(any()))
              .thenAnswer((_) async => Right(testMenuOptions));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadMenuEvent(userId: testUserId)),
        expect: () => [
          MenuLoading(),
          MenuLoaded(
            menuOptions: testMenuOptions,
            sidebarCollapsed: false,
          ),
        ],
        verify: (_) {
          verify(() => mockGetMenuOptions(const GetMenuOptionsParams(userId: testUserId)))
              .called(1);
        },
      );

      blocTest<MenuBloc, MenuState>(
        'should emit [MenuLoading, MenuError] when loading fails with ServerFailure',
        build: () {
          when(() => mockGetMenuOptions(any()))
              .thenAnswer((_) async => const Left(ServerFailure('Error del servidor')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadMenuEvent(userId: testUserId)),
        expect: () => [
          MenuLoading(),
          const MenuError(message: 'Error del servidor'),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'should emit [MenuLoading, MenuError] when user not found',
        build: () {
          when(() => mockGetMenuOptions(any()))
              .thenAnswer((_) async => const Left(NotFoundFailure('Usuario no encontrado')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadMenuEvent(userId: testUserId)),
        expect: () => [
          MenuLoading(),
          const MenuError(message: 'Usuario no encontrado'),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'should emit [MenuLoading, MenuError] when user not authorized',
        build: () {
          when(() => mockGetMenuOptions(any()))
              .thenAnswer((_) async => const Left(ForbiddenFailure('No autorizado')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadMenuEvent(userId: testUserId)),
        expect: () => [
          MenuLoading(),
          const MenuError(message: 'No autorizado'),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'should emit [MenuLoading, MenuError] with connection failure',
        build: () {
          when(() => mockGetMenuOptions(any()))
              .thenAnswer((_) async => const Left(ConnectionFailure('Sin conexión')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadMenuEvent(userId: testUserId)),
        expect: () => [
          MenuLoading(),
          const MenuError(message: 'Sin conexión'),
        ],
      );
    });

    group('ToggleSidebarEvent', () {
      blocTest<MenuBloc, MenuState>(
        'should emit [SidebarUpdating, MenuLoaded] when sidebar is collapsed successfully',
        build: () {
          when(() => mockUpdateSidebarPreference(any()))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => MenuLoaded(
          menuOptions: testMenuOptions,
          sidebarCollapsed: false,
        ),
        act: (bloc) => bloc.add(const ToggleSidebarEvent(
          userId: testUserId,
          collapsed: true,
        )),
        expect: () => [
          SidebarUpdating(
            menuOptions: testMenuOptions,
            currentCollapsed: false,
          ),
          MenuLoaded(
            menuOptions: testMenuOptions,
            sidebarCollapsed: true,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateSidebarPreference(
                const UpdateSidebarPreferenceParams(
                  userId: testUserId,
                  collapsed: true,
                ),
              )).called(1);
        },
      );

      blocTest<MenuBloc, MenuState>(
        'should emit [SidebarUpdating, MenuLoaded] when sidebar is expanded successfully',
        build: () {
          when(() => mockUpdateSidebarPreference(any()))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => MenuLoaded(
          menuOptions: testMenuOptions,
          sidebarCollapsed: true,
        ),
        act: (bloc) => bloc.add(const ToggleSidebarEvent(
          userId: testUserId,
          collapsed: false,
        )),
        expect: () => [
          SidebarUpdating(
            menuOptions: testMenuOptions,
            currentCollapsed: true,
          ),
          MenuLoaded(
            menuOptions: testMenuOptions,
            sidebarCollapsed: false,
          ),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'should revert to previous state when update fails',
        build: () {
          when(() => mockUpdateSidebarPreference(any()))
              .thenAnswer((_) async => const Left(ServerFailure('Error')));
          return bloc;
        },
        seed: () => MenuLoaded(
          menuOptions: testMenuOptions,
          sidebarCollapsed: false,
        ),
        act: (bloc) => bloc.add(const ToggleSidebarEvent(
          userId: testUserId,
          collapsed: true,
        )),
        expect: () => [
          SidebarUpdating(
            menuOptions: testMenuOptions,
            currentCollapsed: false,
          ),
          MenuLoaded(
            menuOptions: testMenuOptions,
            sidebarCollapsed: false, // Reverted
          ),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'should do nothing when state is not MenuLoaded',
        build: () => bloc,
        seed: () => MenuInitial(),
        act: (bloc) => bloc.add(const ToggleSidebarEvent(
          userId: testUserId,
          collapsed: true,
        )),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockUpdateSidebarPreference(any()));
        },
      );
    });
  });
}
