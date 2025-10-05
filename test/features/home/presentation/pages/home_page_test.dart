import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_event.dart';
import 'package:system_web_medias/features/auth/domain/entities/user.dart';
import 'package:system_web_medias/features/home/presentation/pages/home_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (_) => mockAuthBloc,
        child: const HomePage(),
      ),
    );
  }

  final testUser = User(
    id: 'test-id',
    email: 'test@example.com',
    nombreCompleto: 'Usuario Test',
    rol: UserRole.vendedor,
    estado: UserEstado.aprobado,
    emailVerificado: true,
    createdAt: DateTime(2025, 10, 5),
    updatedAt: DateTime(2025, 10, 5),
  );

  group('HomePage Widget Tests', () {
    testWidgets('should display user info when authenticated', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(user: testUser, message: 'Bienvenido'),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('¡Bienvenido!'), findsOneWidget);
      expect(find.text('Usuario Test'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('VENDEDOR'), findsOneWidget);
      expect(find.text('APROBADO'), findsOneWidget);
    });

    testWidgets('should show logout button in AppBar', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(user: testUser),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byTooltip('Cerrar Sesión'), findsOneWidget);
    });

    testWidgets('should dispatch LogoutRequested when logout button tapped', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(user: testUser),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();

      // Assert
      verify(() => mockAuthBloc.add(LogoutRequested())).called(1);
    });

    testWidgets('should show loading indicator when not authenticated', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display all user info fields', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(user: testUser),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Email:'), findsOneWidget);
      expect(find.text('Rol:'), findsOneWidget);
      expect(find.text('Estado:'), findsOneWidget);
      expect(find.text('Email verificado:'), findsOneWidget);
      expect(find.text('Sí'), findsOneWidget); // Email verificado
    });

    testWidgets('should show "Sin asignar" when user has no role', (tester) async {
      // Arrange
      final userWithoutRole = User(
        id: 'test-id',
        email: 'test@example.com',
        nombreCompleto: 'Usuario Sin Rol',
        rol: null,
        estado: UserEstado.aprobado,
        emailVerificado: true,
        createdAt: DateTime(2025, 10, 5),
        updatedAt: DateTime(2025, 10, 5),
      );

      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(user: userWithoutRole),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Sin asignar'), findsOneWidget);
    });

    testWidgets('should have placeholder text for future features', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(
        AuthAuthenticated(user: testUser),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Funcionalidades próximamente...'), findsOneWidget);
    });
  });
}
