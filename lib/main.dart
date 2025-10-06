import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/core/routing/app_router.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_event.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Dependency Injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl<AuthBloc>()..add(CheckAuthStatus());
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: _AuthStateListener(
        child: MaterialApp.router(
          title: 'Sistema de Gestión de Medias',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4ECDC4), // Turquesa corporativo
            ),
            useMaterial3: true,
            fontFamily: 'Inter',
          ),
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}

/// Wrapper con BlocListener para manejar estados de AuthBloc
/// y GestureDetector para resetear timer de inactividad
class _AuthStateListener extends StatelessWidget {
  final Widget child;

  const _AuthStateListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // HU-003: Manejar LogoutSuccess
        if (state is LogoutSuccess) {
          _showSessionExpiredSnackbar(
            context: context,
            message: state.message,
            logoutType: state.logoutType,
          );
          // La navegación se maneja automáticamente por GoRouter
        }

        // HU-003: Manejar TokenBlacklisted
        if (state is TokenBlacklisted) {
          _showSessionExpiredSnackbar(
            context: context,
            message: 'Sesión cerrada en otra pestaña',
            logoutType: 'multi_tab',
          );
          // La navegación se maneja automáticamente por GoRouter
        }

        // HU-003: Manejar InactivityWarning
        if (state is InactivityWarning) {
          _showInactivityWarning(context, state);
        }
      },
      child: GestureDetector(
        // HU-003: Resetear timer de inactividad en cada tap
        onTap: () {
          context.read<AuthBloc>().resetInactivityTimer();
        },
        behavior: HitTestBehavior.translucent,
        child: child,
      ),
    );
  }

  /// Mostrar snackbar de sesión cerrada
  void _showSessionExpiredSnackbar({
    required BuildContext context,
    required String message,
    required String logoutType,
  }) {
    // Importar SessionExpiredSnackbar dinámicamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      final theme = Theme.of(context);
      IconData icon;
      Color backgroundColor;

      switch (logoutType) {
        case 'inactivity':
          icon = Icons.timer_off;
          backgroundColor = const Color(0xFFFF9800);
          break;
        case 'token_expired':
        case 'multi_tab':
          icon = Icons.lock_clock;
          backgroundColor = theme.colorScheme.error;
          break;
        default:
          icon = Icons.check_circle;
          backgroundColor = theme.colorScheme.primary;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 4),
          action: logoutType != 'manual'
              ? SnackBarAction(
                  label: 'Entendido',
                  textColor: Colors.white,
                  onPressed: () {},
                )
              : null,
        ),
      );
    });
  }

  /// Mostrar dialog de advertencia de inactividad
  void _showInactivityWarning(BuildContext context, InactivityWarning state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _InactivityWarningDialogWrapper(
          minutesRemaining: state.minutesRemaining,
          onExtendSession: () {
            Navigator.of(dialogContext).pop();
            context.read<AuthBloc>().add(ExtendSessionRequested());
          },
          onLogout: () {
            Navigator.of(dialogContext).pop();
            context.read<AuthBloc>().add(const LogoutRequested(logoutType: 'inactivity'));
          },
        ),
      );
    });
  }
}

/// Dialog wrapper para warning de inactividad (simple version)
class _InactivityWarningDialogWrapper extends StatelessWidget {
  final int minutesRemaining;
  final VoidCallback onExtendSession;
  final VoidCallback onLogout;

  const _InactivityWarningDialogWrapper({
    required this.minutesRemaining,
    required this.onExtendSession,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warningColor = const Color(0xFFFF9800);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      icon: Icon(
        Icons.timer_outlined,
        size: 48,
        color: warningColor,
      ),
      title: const Text('Sesión por Expirar'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tu sesión expirará en $minutesRemaining minuto${minutesRemaining != 1 ? 's' : ''} por inactividad.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            '¿Deseas extender tu sesión?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onLogout,
          child: const Text('Cerrar Sesión'),
        ),
        FilledButton(
          onPressed: onExtendSession,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
          ),
          child: const Text('Extender Sesión'),
        ),
      ],
    );
  }
}
