import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/user/domain/entities/user_profile.dart';
import 'package:system_web_medias/features/navigation/domain/entities/breadcrumb.dart';
import 'package:system_web_medias/shared/design_system/organisms/app_header.dart';

void main() {
  group('AppHeader Widget Tests', () {
    late UserProfile mockUser;
    late List<Breadcrumb> mockBreadcrumbs;

    setUp(() {
      mockUser = const UserProfile(
        id: 'test-id',
        nombreCompleto: 'Juan Pérez',
        email: 'juan@example.com',
        rol: 'VENDEDOR',
        avatarUrl: null,
        sidebarCollapsed: false,
      );

      mockBreadcrumbs = [
        const Breadcrumb(label: 'Dashboard', route: '/dashboard'),
        const Breadcrumb(label: 'Productos', route: '/products'),
        const Breadcrumb(label: 'Gestionar catálogo', route: null),
      ];
    });

    Widget buildTestWidget({
      required UserProfile user,
      required List<Breadcrumb> breadcrumbs,
      VoidCallback? onLogout,
      VoidCallback? onProfile,
      VoidCallback? onSettings,
      ValueChanged<String>? onNavigate,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AppHeader(
            user: user,
            breadcrumbs: breadcrumbs,
            onLogout: onLogout ?? () {},
            onProfile: onProfile ?? () {},
            onSettings: onSettings ?? () {},
            onNavigate: onNavigate ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('should render header with correct height', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          user: mockUser,
          breadcrumbs: mockBreadcrumbs,
        ),
      );

      // Verificar que el header existe
      expect(find.byType(AppHeader), findsOneWidget);

      // Verificar altura del header (64px)
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxHeight, 64);
    });

    testWidgets('should display user profile information', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          user: mockUser,
          breadcrumbs: mockBreadcrumbs,
        ),
      );

      // Verificar nombre del usuario
      expect(find.text('Juan Pérez'), findsOneWidget);

      // Verificar badge del rol
      expect(find.text('Vendedor'), findsOneWidget);

      // Verificar avatar con iniciales
      expect(find.text('JP'), findsOneWidget);
    });

    testWidgets('should display breadcrumbs', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          user: mockUser,
          breadcrumbs: mockBreadcrumbs,
        ),
      );

      // Verificar que todos los breadcrumbs están presentes
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Productos'), findsOneWidget);
      expect(find.text('Gestionar catálogo'), findsOneWidget);
    });

    testWidgets('should show dropdown menu when profile is clicked', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          user: mockUser,
          breadcrumbs: mockBreadcrumbs,
        ),
      );

      // Hacer click en el perfil de usuario
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Verificar que aparecen las opciones del menú
      expect(find.text('Ver perfil'), findsOneWidget);
      expect(find.text('Configuración'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('should call onProfile when profile option is selected', (tester) async {
      bool profileCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          user: mockUser,
          breadcrumbs: mockBreadcrumbs,
          onProfile: () {
            profileCalled = true;
          },
        ),
      );

      // Abrir dropdown
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Seleccionar "Ver perfil"
      await tester.tap(find.text('Ver perfil'));
      await tester.pumpAndSettle();

      // Verificar que se llamó el callback
      expect(profileCalled, true);
    });

    testWidgets('should call onSettings when settings option is selected', (tester) async {
      bool settingsCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          user: mockUser,
          breadcrumbs: mockBreadcrumbs,
          onSettings: () {
            settingsCalled = true;
          },
        ),
      );

      // Abrir dropdown
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Seleccionar "Configuración"
      await tester.tap(find.text('Configuración'));
      await tester.pumpAndSettle();

      // Verificar que se llamó el callback
      expect(settingsCalled, true);
    });

    testWidgets('should show logout dialog when logout option is selected', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          user: mockUser,
          breadcrumbs: mockBreadcrumbs,
        ),
      );

      // Abrir dropdown
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Seleccionar "Cerrar sesión"
      await tester.tap(find.text('Cerrar sesión').last);
      await tester.pumpAndSettle();

      // Verificar que aparece el diálogo de confirmación
      expect(find.text('¿Estás seguro que deseas cerrar sesión?'), findsOneWidget);
    });

    testWidgets('should display correct role badge color for ADMIN', (tester) async {
      final adminUser = mockUser.copyWith(rol: 'ADMIN');

      await tester.pumpWidget(
        buildTestWidget(
          user: adminUser,
          breadcrumbs: mockBreadcrumbs,
        ),
      );

      // Verificar badge del rol
      expect(find.text('Administrador'), findsOneWidget);

      // El badge debe tener color rojo para ADMIN
      final badge = tester.widget<Container>(
        find.ancestor(
          of: find.text('Administrador'),
          matching: find.byType(Container),
        ).first,
      );

      expect(badge.decoration, isA<BoxDecoration>());
      final decoration = badge.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFF44336).withValues(alpha: 0.1));
    });

    testWidgets('should display correct role badge color for GERENTE', (tester) async {
      final gerenteUser = mockUser.copyWith(rol: 'GERENTE');

      await tester.pumpWidget(
        buildTestWidget(
          user: gerenteUser,
          breadcrumbs: mockBreadcrumbs,
        ),
      );

      // Verificar badge del rol
      expect(find.text('Gerente'), findsOneWidget);
    });

    testWidgets('should display user initials when no avatar', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          user: mockUser,
          breadcrumbs: mockBreadcrumbs,
        ),
      );

      // Verificar que se muestran las iniciales
      expect(find.text('JP'), findsOneWidget);

      // Verificar que el CircleAvatar existe
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should display empty breadcrumbs when list is empty', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          user: mockUser,
          breadcrumbs: [],
        ),
      );

      // El header debe renderizarse sin breadcrumbs
      expect(find.byType(AppHeader), findsOneWidget);
    });

    testWidgets('should call onNavigate when breadcrumb is clicked', (tester) async {
      String? navigatedRoute;

      await tester.pumpWidget(
        buildTestWidget(
          user: mockUser,
          breadcrumbs: mockBreadcrumbs,
          onNavigate: (route) {
            navigatedRoute = route;
          },
        ),
      );

      // Hacer click en "Dashboard" breadcrumb
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();

      // Verificar que se llamó onNavigate
      expect(navigatedRoute, '/dashboard');
    });
  });
}

extension on UserProfile {
  UserProfile copyWith({
    String? id,
    String? nombreCompleto,
    String? email,
    String? rol,
    String? avatarUrl,
    bool? sidebarCollapsed,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
    );
  }
}
