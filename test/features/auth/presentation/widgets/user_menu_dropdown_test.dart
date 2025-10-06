import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/user_menu_dropdown.dart';

void main() {
  group('UserMenuDropdown', () {
    testWidgets('should display user name and role in desktop mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                UserMenuDropdown(
                  userName: 'Juan Pérez',
                  userRole: 'Administrador',
                  onLogoutPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verificar que se muestra nombre y rol
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Administrador'), findsOneWidget);
    });

    testWidgets('should display user avatar with initials when no avatarUrl',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                UserMenuDropdown(
                  userName: 'Juan Pérez',
                  userRole: 'Vendedor',
                  onLogoutPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verificar avatar con inicial
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('should show popup menu when tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                UserMenuDropdown(
                  userName: 'Juan Pérez',
                  userRole: 'Gerente',
                  onLogoutPressed: () {},
                  onProfilePressed: () {},
                  onSettingsPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Tap en el dropdown
      await tester.tap(find.byType(UserMenuDropdown));
      await tester.pumpAndSettle();

      // Verificar que aparecen las opciones
      expect(find.text('Mi Perfil'), findsOneWidget);
      expect(find.text('Configuración'), findsOneWidget);
      expect(find.text('Cerrar Sesión'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('should call onLogoutPressed when logout item selected',
        (tester) async {
      bool logoutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                UserMenuDropdown(
                  userName: 'Juan Pérez',
                  userRole: 'Administrador',
                  onLogoutPressed: () => logoutCalled = true,
                ),
              ],
            ),
          ),
        ),
      );

      // Abrir menu
      await tester.tap(find.byType(UserMenuDropdown));
      await tester.pumpAndSettle();

      // Tap en "Cerrar Sesión"
      await tester.tap(find.text('Cerrar Sesión'));
      await tester.pumpAndSettle();

      // Verificar callback
      expect(logoutCalled, true);
    });

    testWidgets('should call onProfilePressed when profile item selected',
        (tester) async {
      bool profileCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                UserMenuDropdown(
                  userName: 'Juan Pérez',
                  userRole: 'Vendedor',
                  onLogoutPressed: () {},
                  onProfilePressed: () => profileCalled = true,
                ),
              ],
            ),
          ),
        ),
      );

      // Abrir menu
      await tester.tap(find.byType(UserMenuDropdown));
      await tester.pumpAndSettle();

      // Tap en "Mi Perfil"
      await tester.tap(find.text('Mi Perfil'));
      await tester.pumpAndSettle();

      // Verificar callback
      expect(profileCalled, true);
    });

    testWidgets('should display only avatar in mobile mode', (tester) async {
      // Configurar tamaño mobile ANTES de construir el widget
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                UserMenuDropdown(
                  userName: 'Juan Pérez',
                  userRole: 'Administrador',
                  onLogoutPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // En mobile solo debe mostrar avatar, no nombre ni rol
      expect(find.text('Juan Pérez'), findsNothing);
      expect(find.text('Administrador'), findsNothing);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should show divider before logout option', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                UserMenuDropdown(
                  userName: 'Juan Pérez',
                  userRole: 'Gerente',
                  onLogoutPressed: () {},
                  onProfilePressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Abrir menu
      await tester.tap(find.byType(UserMenuDropdown));
      await tester.pumpAndSettle();

      // Verificar que hay un divider
      expect(find.byType(PopupMenuDivider), findsOneWidget);
    });

    testWidgets('should not show profile/settings if callbacks not provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                UserMenuDropdown(
                  userName: 'Juan Pérez',
                  userRole: 'Vendedor',
                  onLogoutPressed: () {},
                  // No onProfilePressed ni onSettingsPressed
                ),
              ],
            ),
          ),
        ),
      );

      // Abrir menu
      await tester.tap(find.byType(UserMenuDropdown));
      await tester.pumpAndSettle();

      // Solo debe aparecer logout
      expect(find.text('Mi Perfil'), findsNothing);
      expect(find.text('Configuración'), findsNothing);
      expect(find.text('Cerrar Sesión'), findsOneWidget);
    });
  });
}
