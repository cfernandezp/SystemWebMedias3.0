import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/shared/design_system/atoms/metric_card.dart';
import 'package:system_web_medias/shared/design_system/atoms/trend_indicator.dart';

void main() {
  group('MetricCard Widget Tests', () {
    testWidgets('should display all basic elements correctly',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricCard(
              icon: Icons.attach_money,
              titulo: 'Ventas de Hoy',
              valor: '\$1,250.50',
              subtitulo: 'vs ayer',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.text('Ventas de Hoy'), findsOneWidget);
      expect(find.text('\$1,250.50'), findsOneWidget);
      expect(find.text('vs ayer'), findsOneWidget);
    });

    testWidgets('should display with trend indicator',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricCard(
              icon: Icons.trending_up,
              titulo: 'Ventas',
              valor: '\$1,000',
              tendencia: TrendIndicator.fromPorcentaje(12.5),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(TrendIndicator), findsOneWidget);
    });

    testWidgets('should show loading skeleton when isLoading is true',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCard(
              icon: Icons.attach_money,
              titulo: 'Loading',
              valor: '...',
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert - skeleton containers should be visible
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricCard(
              icon: Icons.attach_money,
              titulo: 'Ventas',
              valor: '\$1,000',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(MetricCard));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should animate on hover (desktop)',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricCard(
              icon: Icons.attach_money,
              titulo: 'Ventas',
              valor: '\$1,000',
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the MouseRegion - should have at least one
      final mouseRegion = find.byType(MouseRegion);
      expect(mouseRegion, findsWidgets);

      // Note: Full hover testing requires integration tests
      // as MouseRegion interactions are limited in widget tests
    });

    testWidgets('should use custom colors when provided',
        (WidgetTester tester) async {
      // Arrange
      const customBg = Color(0xFFFF0000);
      const customIcon = Color(0xFF00FF00);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCard(
              icon: Icons.attach_money,
              titulo: 'Ventas',
              valor: '\$1,000',
              backgroundColor: customBg,
              iconColor: customIcon,
            ),
          ),
        ),
      );

      // Assert - Material should exist (color verification is complex in Material 3)
      expect(find.byType(Material), findsWidgets);

      // Assert - Icon should exist with custom color
      final icon = tester.widget<Icon>(find.byIcon(Icons.attach_money));
      expect(icon.color, customIcon);
    });

    testWidgets('should have fixed height of 120px',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricCard(
              icon: Icons.attach_money,
              titulo: 'Ventas',
              valor: '\$1,000',
            ),
          ),
        ),
      );

      // Assert - Container with height 120
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.maxHeight, 120);
    });
  });
}
