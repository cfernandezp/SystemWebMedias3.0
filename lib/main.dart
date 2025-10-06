import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/auth/presentation/pages/register_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/login_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/confirm_email_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/email_confirmation_waiting_page.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/auth_guard.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_event.dart';
import 'package:system_web_medias/features/home/presentation/pages/home_page.dart';
import 'package:system_web_medias/features/dashboard/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Dependency Injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
      child: MaterialApp(
        title: 'Sistema de Gestión de Medias',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4ECDC4), // Turquesa corporativo
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        // Rutas de la aplicación (Flat - sin prefijos /auth/, /products/, etc.)
        // Ver: docs/technical/frontend/ROUTING_CONVENTIONS.md
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const AuthGuard(child: HomePage()),
          '/dashboard': (context) => const AuthGuard(child: DashboardPage()),
          '/confirm-email': (context) => const ConfirmEmailPage(),
          '/email-confirmation-waiting': (context) => const EmailConfirmationWaitingPage(),
        },
      ),
    );
  }
}
