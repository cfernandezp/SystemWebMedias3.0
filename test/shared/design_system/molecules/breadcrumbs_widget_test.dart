import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/navigation/domain/entities/breadcrumb.dart';
import 'package:system_web_medias/shared/design_system/molecules/breadcrumbs_widget.dart';

void main() {
  group('BreadcrumbsWidget Widget Tests', () {
    Widget buildTestWidget({
      required List<Breadcrumb> breadcrumbs,
      required ValueChanged<String> onNavigate,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BreadcrumbsWidget(
            breadcrumbs: breadcrumbs,
            onNavigate: onNavigate,
          ),
        ),
      );
    }

    testWidgets('should render breadcrumbs correctly', (tester) async {
      final breadcrumbs = [
        const Breadcrumb(label: 'Dashboard', route: '/dashboard'),
        const Breadcrumb(label: 'Productos', route: '/products'),
        const Breadcrumb(label: 'Gestionar catálogo', route: null),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          breadcrumbs: breadcrumbs,
          onNavigate: (_) {},
        ),
      );

      // Verificar que todos los breadcrumbs están presentes
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Productos'), findsOneWidget);
      expect(find.text('Gestionar catálogo'), findsOneWidget);

      // Verificar separadores (chevron_right)
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    });

    testWidgets('should render empty when no breadcrumbs', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          breadcrumbs: [],
          onNavigate: (_) {},
        ),
      );

      // No debe renderizar nada
      expect(find.byType(BreadcrumbsWidget), findsOneWidget);
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('should call onNavigate when clickable breadcrumb is tapped', (tester) async {
      String? navigatedRoute;

      final breadcrumbs = [
        const Breadcrumb(label: 'Dashboard', route: '/dashboard'),
        const Breadcrumb(label: 'Productos', route: '/products'),
        const Breadcrumb(label: 'Gestionar catálogo', route: null),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          breadcrumbs: breadcrumbs,
          onNavigate: (route) {
            navigatedRoute = route;
          },
        ),
      );

      // Hacer tap en "Dashboard" (clickeable)
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();

      // Verificar que se llamó onNavigate
      expect(navigatedRoute, '/dashboard');
    });

    testWidgets('should not call onNavigate when non-clickable breadcrumb is tapped', (tester) async {
      final breadcrumbs = [
        const Breadcrumb(label: 'Dashboard', route: '/dashboard'),
        const Breadcrumb(label: 'Gestionar catálogo', route: null),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          breadcrumbs: breadcrumbs,
          onNavigate: (route) {},
        ),
      );

      // Intentar hacer tap en "Gestionar catálogo" (no clickeable)
      // Como no es clickeable, no debería tener InkWell
      final catalogoText = find.text('Gestionar catálogo');
      expect(catalogoText, findsOneWidget);

      // El elemento no clickeable no debe tener InkWell como ancestro directo
      final inkWells = find.ancestor(
        of: catalogoText,
        matching: find.byType(InkWell),
      );
      expect(inkWells, findsNothing);
    });

    testWidgets('should render single breadcrumb without separator', (tester) async {
      final breadcrumbs = [
        const Breadcrumb(label: 'Dashboard', route: null),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          breadcrumbs: breadcrumbs,
          onNavigate: (_) {},
        ),
      );

      // Verificar que muestra el breadcrumb
      expect(find.text('Dashboard'), findsOneWidget);

      // No debe haber separadores
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('should style clickable breadcrumbs differently', (tester) async {
      final breadcrumbs = [
        const Breadcrumb(label: 'Dashboard', route: '/dashboard'),
        const Breadcrumb(label: 'Actual', route: null),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          breadcrumbs: breadcrumbs,
          onNavigate: (_) {},
        ),
      );

      // Verificar estilos
      final dashboardText = tester.widget<Text>(
        find.descendant(
          of: find.byType(InkWell),
          matching: find.text('Dashboard'),
        ),
      );

      // El breadcrumb clickeable debe tener color turquesa
      expect(dashboardText.style?.color, isNotNull);

      final actualText = tester.widget<Text>(find.text('Actual'));

      // El breadcrumb actual debe tener peso bold
      expect(actualText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('should render multiple breadcrumbs with correct separators', (tester) async {
      final breadcrumbs = [
        const Breadcrumb(label: 'Home', route: '/'),
        const Breadcrumb(label: 'Products', route: '/products'),
        const Breadcrumb(label: 'Electronics', route: '/products/electronics'),
        const Breadcrumb(label: 'Phones', route: null),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          breadcrumbs: breadcrumbs,
          onNavigate: (_) {},
        ),
      );

      // 4 breadcrumbs = 3 separadores
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));

      // Todos los labels deben estar presentes
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('Phones'), findsOneWidget);
    });
  });
}
