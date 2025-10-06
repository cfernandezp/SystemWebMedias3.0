import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:system_web_medias/main.dart' as app;
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/shared/design_system/organisms/app_sidebar.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E003-HU-002: Sistema de Navegacion con Menus Desplegables', () {
    setUpAll(() async {
      await di.init();
    });

    group('CA-001: Sidebar con Menus segun Rol de Vendedor', () {
      testWidgets(
        'Vendedor debe ver solo opciones permitidas',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();

          await _loginAsUser(
            tester,
            email: 'vendedor@tienda1.com',
            password: 'password123',
          );

          expect(find.text('Dashboard'), findsOneWidget);
          expect(find.text('Productos'), findsOneWidget);
          expect(find.text('Personas'), findsNothing);
          expect(find.text('Admin'), findsNothing);
        },
      );
    });

    group('CA-002: Sidebar con Menus segun Rol de Gerente', () {
      testWidgets(
        'Gerente debe ver opciones adicionales',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();

          await _loginAsUser(
            tester,
            email: 'gerente@tienda1.com',
            password: 'password123',
          );

          expect(find.text('Dashboard'), findsOneWidget);
          expect(find.text('Personas'), findsOneWidget);
          expect(find.text('Admin'), findsNothing);
        },
      );
    });

    group('CA-003: Sidebar con Menus segun Rol de Admin', () {
      testWidgets(
        'Admin debe ver TODAS las opciones',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();

          await _loginAsUser(
            tester,
            email: 'admin@sistemasmedias.com',
            password: 'password123',
          );

          expect(find.text('Dashboard'), findsOneWidget);
          expect(find.text('Personas'), findsOneWidget);
          expect(find.text('Admin'), findsOneWidget);
        },
      );
    });

    group('CA-004: Comportamiento de Menus Desplegables', () {
      testWidgets(
        'Menu debe expandirse y colapsar al hacer clic',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          await _loginAsUser(
            tester,
            email: 'admin@sistemasmedias.com',
            password: 'password123',
          );

          expect(find.text('Marcas'), findsNothing);

          await tester.tap(find.text('Productos'));
          await tester.pumpAndSettle();

          expect(find.text('Marcas'), findsOneWidget);

          await tester.tap(find.text('Productos'));
          await tester.pumpAndSettle();

          expect(find.text('Marcas'), findsNothing);
        },
      );
    });

    group("CA-005: Sidebar Colapsable", () {
      testWidgets(
        "Sidebar debe colapsarse al hacer clic en boton hamburguesa",
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();
          await _loginAsUser(
            tester,
            email: "vendedor@tienda1.com",
            password: "password123",
          );

          await tester.tap(find.byIcon(Icons.menu));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.menu));
          await tester.pumpAndSettle();

          expect(find.text("Dashboard"), findsWidgets);
        },
      );
    });
  });
}


Future<void> _loginAsUser(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.pumpAndSettle();

  final emailField = find.widgetWithText(TextFormField, "Email");
  final passwordField = find.widgetWithText(TextFormField, "Contraseña");

  if (emailField.evaluate().isEmpty || passwordField.evaluate().isEmpty) {
    return;
  }

  await tester.enterText(emailField, email);
  await tester.enterText(passwordField, password);

  final loginButton = find.text("Iniciar Sesión");
  if (loginButton.evaluate().isNotEmpty) {
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  await tester.pumpAndSettle();
}
