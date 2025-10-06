import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/inactivity_warning_dialog.dart';

void main() {
  group('InactivityWarningDialog', () {
    testWidgets('should show inactivity warning dialog', (tester) async {
      bool extendSessionCalled = false;
      bool logoutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => InactivityWarningDialog.show(
                  context: context,
                  minutesRemaining: 5,
                  onExtendSession: () => extendSessionCalled = true,
                  onLogout: () => logoutCalled = true,
                ),
                child: const Text('Show Warning'),
              ),
            ),
          ),
        ),
      );

      // Presionar botón
      await tester.tap(find.text('Show Warning'));
      await tester.pumpAndSettle();

      // Verificar que dialog aparece
      expect(find.text('Sesión por Expirar'), findsOneWidget);
      expect(
        find.text(
            'Tu sesión expirará en 5 minutos por inactividad.'),
        findsOneWidget,
      );
      expect(find.text('¿Deseas extender tu sesión?'), findsOneWidget);
      expect(find.text('Cerrar Sesión'), findsOneWidget);
      expect(find.text('Extender Sesión'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('should call onExtendSession when "Extender Sesión" pressed',
        (tester) async {
      bool extendSessionCalled = false;
      bool logoutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => InactivityWarningDialog.show(
                  context: context,
                  minutesRemaining: 5,
                  onExtendSession: () => extendSessionCalled = true,
                  onLogout: () => logoutCalled = true,
                ),
                child: const Text('Show Warning'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Warning'));
      await tester.pumpAndSettle();

      // Presionar "Extender Sesión"
      await tester.tap(find.text('Extender Sesión'));
      await tester.pumpAndSettle();

      // Verificar callbacks
      expect(extendSessionCalled, true);
      expect(logoutCalled, false);
      expect(find.byType(InactivityWarningDialog), findsNothing);
    });

    testWidgets('should call onLogout when "Cerrar Sesión" pressed',
        (tester) async {
      bool extendSessionCalled = false;
      bool logoutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => InactivityWarningDialog.show(
                  context: context,
                  minutesRemaining: 5,
                  onExtendSession: () => extendSessionCalled = true,
                  onLogout: () => logoutCalled = true,
                ),
                child: const Text('Show Warning'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Warning'));
      await tester.pumpAndSettle();

      // Presionar "Cerrar Sesión"
      await tester.tap(find.text('Cerrar Sesión'));
      await tester.pumpAndSettle();

      // Verificar callbacks
      expect(extendSessionCalled, false);
      expect(logoutCalled, true);
      expect(find.byType(InactivityWarningDialog), findsNothing);
    });

    testWidgets('should show singular "minuto" when remainingMinutes is 1',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => InactivityWarningDialog.show(
                  context: context,
                  minutesRemaining: 1,
                  onExtendSession: () {},
                  onLogout: () {},
                ),
                child: const Text('Show Warning'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Warning'));
      await tester.pumpAndSettle();

      // Verificar singular
      expect(
        find.text('Tu sesión expirará en 1 minuto por inactividad.'),
        findsOneWidget,
      );
    });

    testWidgets('should not be dismissible by tapping outside',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => InactivityWarningDialog.show(
                  context: context,
                  minutesRemaining: 5,
                  onExtendSession: () {},
                  onLogout: () {},
                ),
                child: const Text('Show Warning'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Warning'));
      await tester.pumpAndSettle();

      // Intentar cerrar tappeando fuera (en el barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Dialog debe seguir visible
      expect(find.byType(InactivityWarningDialog), findsOneWidget);
    });
  });
}
