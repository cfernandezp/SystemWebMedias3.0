import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_event.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/login_form.dart';

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
        child: const Scaffold(
          body: LoginForm(),
        ),
      ),
    );
  }

  group('LoginForm Widget Tests', () {
    testWidgets('CA-001: should show all form elements', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Recordarme'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    });

    testWidgets('CA-002: should validate empty email', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap submit button without filling fields
      final submitButton = find.text('Iniciar Sesión');
      await tester.tap(submitButton);
      await tester.pump();

      // Assert - should show validation error
      expect(find.text('Email es requerido'), findsOneWidget);
    });

    testWidgets('CA-002: should validate empty password', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Fill email but not password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );

      final submitButton = find.text('Iniciar Sesión');
      await tester.tap(submitButton);
      await tester.pump();

      // Assert
      expect(find.text('Contraseña es requerida'), findsOneWidget);
    });

    testWidgets('CA-002: should validate invalid email format', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid-email',
      );

      final submitButton = find.text('Iniciar Sesión');
      await tester.tap(submitButton);
      await tester.pump();

      // Assert
      expect(find.text('Formato de email inválido'), findsOneWidget);
    });

    testWidgets('should toggle remember me checkbox', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      final checkbox = find.byType(Checkbox);
      expect((tester.widget(checkbox) as Checkbox).value, false);

      await tester.tap(checkbox);
      await tester.pump();

      // Assert
      expect((tester.widget(checkbox) as Checkbox).value, true);
    });

    testWidgets('should show loading indicator when AuthLoading', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando...'), findsOneWidget);
    });

    testWidgets('should disable form fields when loading', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final emailField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Email'),
      );
      final passwordField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Contraseña'),
      );

      expect(emailField.enabled, false);
      expect(passwordField.enabled, false);
    });
  });
}
