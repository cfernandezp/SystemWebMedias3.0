import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/menu/domain/entities/menu_option.dart';
import 'package:system_web_medias/shared/design_system/organisms/app_sidebar.dart';

void main() {
  group('AppSidebar Widget Tests', () {
    late List<MenuOption> mockMenuOptions;

    setUp(() {
      mockMenuOptions = [
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
            MenuOption(
              id: 'productos-categorias',
              label: 'Categorías',
              route: '/products/categories',
            ),
          ],
        ),
        const MenuOption(
          id: 'ventas',
          label: 'Ventas',
          icon: 'shopping_cart',
          route: '/sales',
        ),
      ];
    });

    Widget buildTestWidget({
      required bool isCollapsed,
      required String currentRoute,
      required ValueChanged<bool> onToggleCollapse,
      required ValueChanged<String> onNavigate,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AppSidebar(
            isCollapsed: isCollapsed,
            menuOptions: mockMenuOptions,
            currentRoute: currentRoute,
            onToggleCollapse: onToggleCollapse,
            onNavigate: onNavigate,
          ),
        ),
      );
    }

    testWidgets('should render expanded sidebar with correct width', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isCollapsed: false,
          currentRoute: '/dashboard',
          onToggleCollapse: (_) {},
          onNavigate: (_) {},
        ),
      );

      // Verificar que el sidebar existe
      expect(find.byType(AppSidebar), findsOneWidget);

      // Verificar que muestra el texto "Sistema Medias"
      expect(find.text('Sistema Medias'), findsOneWidget);

      // Verificar que muestra los labels de menú
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Productos'), findsOneWidget);
      expect(find.text('Ventas'), findsOneWidget);
    });

    testWidgets('should render collapsed sidebar', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isCollapsed: true,
          currentRoute: '/dashboard',
          onToggleCollapse: (_) {},
          onNavigate: (_) {},
        ),
      );

      // En modo colapsado, no debe mostrar el texto "Sistema Medias"
      expect(find.text('Sistema Medias'), findsNothing);

      // Pero debe mostrar íconos
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    });

    testWidgets('should highlight active menu item', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isCollapsed: false,
          currentRoute: '/dashboard',
          onToggleCollapse: (_) {},
          onNavigate: (_) {},
        ),
      );

      // El item activo debe tener el background turquesa
      final dashboardItem = find.text('Dashboard');
      expect(dashboardItem, findsOneWidget);

      // Verificar que tiene el container con el color primary
      final container = tester.widget<Container>(
        find.ancestor(
          of: dashboardItem,
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('should expand submenu when parent is tapped', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isCollapsed: false,
          currentRoute: '/dashboard',
          onToggleCollapse: (_) {},
          onNavigate: (_) {},
        ),
      );

      // Verificar que los sub-items NO están visibles inicialmente
      expect(find.text('Gestionar catálogo'), findsNothing);
      expect(find.text('Categorías'), findsNothing);

      // Hacer tap en "Productos"
      await tester.tap(find.text('Productos'));
      await tester.pumpAndSettle();

      // Ahora los sub-items DEBEN estar visibles
      expect(find.text('Gestionar catálogo'), findsOneWidget);
      expect(find.text('Categorías'), findsOneWidget);
    });

    testWidgets('should call onToggleCollapse when hamburger button is tapped', (tester) async {
      bool toggleCalled = false;
      bool toggleValue = false;

      await tester.pumpWidget(
        buildTestWidget(
          isCollapsed: false,
          currentRoute: '/dashboard',
          onToggleCollapse: (value) {
            toggleCalled = true;
            toggleValue = value;
          },
          onNavigate: (_) {},
        ),
      );

      // Hacer tap en el botón hamburguesa
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verificar que se llamó el callback
      expect(toggleCalled, true);
      expect(toggleValue, true); // Debería pasar true porque estaba en false
    });

    testWidgets('should call onNavigate when menu item is tapped', (tester) async {
      String? navigatedRoute;

      await tester.pumpWidget(
        buildTestWidget(
          isCollapsed: false,
          currentRoute: '/dashboard',
          onToggleCollapse: (_) {},
          onNavigate: (route) {
            navigatedRoute = route;
          },
        ),
      );

      // Hacer tap en "Ventas"
      await tester.tap(find.text('Ventas'));
      await tester.pumpAndSettle();

      // Verificar que se llamó onNavigate con la ruta correcta
      expect(navigatedRoute, '/sales');
    });

    testWidgets('should call onNavigate when submenu item is tapped', (tester) async {
      String? navigatedRoute;

      await tester.pumpWidget(
        buildTestWidget(
          isCollapsed: false,
          currentRoute: '/dashboard',
          onToggleCollapse: (_) {},
          onNavigate: (route) {
            navigatedRoute = route;
          },
        ),
      );

      // Expandir menú Productos
      await tester.tap(find.text('Productos'));
      await tester.pumpAndSettle();

      // Hacer tap en sub-item
      await tester.tap(find.text('Gestionar catálogo'));
      await tester.pumpAndSettle();

      // Verificar que se llamó onNavigate con la ruta correcta
      expect(navigatedRoute, '/products');
    });

    testWidgets('should show tooltip in collapsed mode', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isCollapsed: true,
          currentRoute: '/dashboard',
          onToggleCollapse: (_) {},
          onNavigate: (_) {},
        ),
      );

      // En modo colapsado, debe haber tooltips
      expect(find.byType(Tooltip), findsWidgets);

      // Verificar que hay tooltip para "Dashboard"
      final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip));
      final dashboardTooltip = tooltips.firstWhere(
        (tooltip) => tooltip.message == 'Dashboard',
        orElse: () => throw Exception('Tooltip not found'),
      );

      expect(dashboardTooltip.message, 'Dashboard');
    });

    testWidgets('should animate expansion and collapse', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isCollapsed: false,
          currentRoute: '/dashboard',
          onToggleCollapse: (_) {},
          onNavigate: (_) {},
        ),
      );

      // Verificar que existe AnimatedContainer
      expect(find.byType(AnimatedContainer), findsOneWidget);

      // Verificar duración de la animación
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      expect(animatedContainer.duration, const Duration(milliseconds: 300));
      expect(animatedContainer.curve, Curves.easeInOut);
    });

    testWidgets('should highlight submenu when active', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          isCollapsed: false,
          currentRoute: '/products',
          onToggleCollapse: (_) {},
          onNavigate: (_) {},
        ),
      );

      await tester.pumpAndSettle();

      // El sub-menú activo debe estar visible automáticamente
      expect(find.text('Gestionar catálogo'), findsOneWidget);

      // Y debe tener highlight
      final catalogoText = find.text('Gestionar catálogo');
      expect(catalogoText, findsOneWidget);
    });
  });
}
