import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/logout_confirmation_dialog.dart';

void main() {
  group('LogoutConfirmationDialog Widget Tests', () {
    Widget buildTestWidget({
      required VoidCallback onConfirm,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => LogoutConfirmationDialog(
                      onConfirm: onConfirm,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        ),
      );
    }

    testWidgets('should render dialog with correct content', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          onConfirm: () {},
        ),
      );

      // Mostrar el diálogo
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verificar título
      expect(find.text('Cerrar sesión'), findsNWidgets(2)); // Título + botón

      // Verificar contenido
      expect(find.text('¿Estás seguro que deseas cerrar sesión?'), findsOneWidget);

      // Verificar botones
      expect(find.text('Cancelar'), findsOneWidget);

      // Verificar ícono
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('should close dialog when cancel button is pressed', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          onConfirm: () {},
        ),
      );

      // Mostrar el diálogo
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verificar que el diálogo está visible
      expect(find.byType(AlertDialog), findsOneWidget);

      // Presionar cancelar
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Verificar que el diálogo se cerró
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should call onConfirm and close dialog when confirm button is pressed', (tester) async {
      bool confirmCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          onConfirm: () {
            confirmCalled = true;
          },
        ),
      );

      // Mostrar el diálogo
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verificar que el diálogo está visible
      expect(find.byType(AlertDialog), findsOneWidget);

      // Presionar confirmar (buscar el botón elevado con texto "Cerrar sesión")
      final confirmButton = find.ancestor(
        of: find.text('Cerrar sesión'),
        matching: find.byType(ElevatedButton),
      );

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verificar que se llamó onConfirm
      expect(confirmCalled, true);

      // Verificar que el diálogo se cerró
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should have correct styling', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          onConfirm: () {},
        ),
      );

      // Mostrar el diálogo
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verificar que el AlertDialog tiene border radius
      final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(alertDialog.shape, isA<RoundedRectangleBorder>());

      final shape = alertDialog.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(12));

      // Verificar que el ícono usa color del tema
      final logoutIcon = tester.widget<Icon>(find.byIcon(Icons.logout));
      expect(logoutIcon.color, isNotNull);
      expect(logoutIcon.size, 24);

      // Verificar estilo del botón confirmar
      final confirmButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Cerrar sesión'),
          matching: find.byType(ElevatedButton),
        ),
      );

      expect(confirmButton.style?.backgroundColor?.resolve({}), isNotNull);
    });

    testWidgets('should display icon and title in a row', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          onConfirm: () {},
        ),
      );

      // Mostrar el diálogo
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verificar que el título tiene un Row con ícono y texto
      final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(alertDialog.title, isA<Row>());

      final titleRow = alertDialog.title as Row;
      expect(titleRow.children.length, 3); // Icon + SizedBox + Text
    });
  });
}
