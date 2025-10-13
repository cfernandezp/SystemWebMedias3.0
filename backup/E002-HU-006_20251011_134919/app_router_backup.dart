import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:system_web_medias/core/injection/injection_container.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_event.dart';
import 'package:system_web_medias/features/auth/presentation/bloc/auth_state.dart';
import 'package:system_web_medias/features/auth/presentation/pages/confirm_email_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/login_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/register_page.dart';
import 'package:system_web_medias/features/auth/presentation/pages/reset_password_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/marcas_list_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/marca_form_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/materiales_list_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/material_form_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/tipos_list_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/tipo_form_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/sistemas_talla_list_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/sistema_talla_form_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/colores_list_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/color_form_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/colores_estadisticas_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/filtrar_por_combinacion_page.dart';
import 'package:system_web_medias/features/catalogos/presentation/pages/productos_por_color_page.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/pages/productos_maestros_list_page.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/pages/producto_maestro_form_page.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/pages/producto_maestro_detail_page.dart';
import 'package:system_web_medias/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:system_web_medias/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:system_web_medias/features/menu/presentation/bloc/menu_event.dart';
import 'package:system_web_medias/features/menu/presentation/bloc/menu_state.dart';
import 'package:system_web_medias/features/navigation/domain/entities/breadcrumb.dart';
import 'package:system_web_medias/features/user/domain/entities/user_profile.dart';
import 'package:system_web_medias/shared/design_system/templates/main_layout.dart';

/// Router principal de la aplicación usando GoRouter
/// Maneja navegación, guards de autenticación y breadcrumbs
class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthInitial = authState is AuthInitial;
      final location = state.matchedLocation;

      // Rutas públicas que no requieren autenticación
      final publicRoutes = ['/login', '/register', '/forgot-password'];
      final isPublicRoute = publicRoutes.contains(location) ||
                           location.startsWith('/confirm-email') ||
                           location.startsWith('/reset-password');

      // Si aún está cargando el auth, no redirigir
      if (isAuthInitial) {
        return null;
      }

      // Si está autenticado y va a rutas públicas, redirigir a dashboard
      if (isAuthenticated && isPublicRoute) {
        return '/dashboard';
      }

      // Si NO está autenticado y NO va a rutas públicas, redirigir a login
      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      return null; // No redirigir
    },
    routes: [
      // ========== RUTAS PÚBLICAS (Sin Layout) ==========
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/confirm-email/:token',
        name: 'confirm-email',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return ConfirmEmailPage(token: token);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password/:token',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return ResetPasswordPage(token: token);
        },
      ),
      // RUTA TEMPORAL: Force logout
      GoRoute(
        path: '/force-logout',
        name: 'force-logout',
        builder: (context, state) {
          // Limpiar sesión de Supabase
          sl<SupabaseClient>().auth.signOut();
          // Redirigir a login
          Future.delayed(Duration.zero, () {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cerrando sesión...'),
                ],
              ),
            ),
          );
        },
      ),

      // ========== RUTAS PROTEGIDAS (Con MainLayout) ==========
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (context) => sl<MenuBloc>(),
            child: _MainLayoutWrapper(child: child),
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/pos',
            name: 'pos',
            builder: (context, state) => const _PlaceholderPage(title: 'Punto de Venta'),
          ),
          GoRoute(
            path: '/products',
            name: 'products',
            builder: (context, state) => const _PlaceholderPage(title: 'Gestionar Catálogo'),
          ),
          GoRoute(
            path: '/inventory',
            name: 'inventory',
            builder: (context, state) => const _PlaceholderPage(title: 'Inventario'),
          ),
          GoRoute(
            path: '/sales',
            name: 'sales',
            builder: (context, state) => const _PlaceholderPage(title: 'Ventas'),
          ),
          GoRoute(
            path: '/clientes',
            name: 'clientes',
            builder: (context, state) => const _PlaceholderPage(title: 'Clientes'),
          ),
          GoRoute(
            path: '/reportes',
            name: 'reportes',
            builder: (context, state) => const _PlaceholderPage(title: 'Reportes'),
          ),
          GoRoute(
            path: '/admin',
            name: 'admin',
            builder: (context, state) => const _PlaceholderPage(title: 'Administración'),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const _PlaceholderPage(title: 'Configuración'),
          ),
          // HU-001: Gestionar Catálogo de Marcas
          GoRoute(
            path: '/marcas',
            name: 'marcas',
            builder: (context, state) => const MarcasListPage(),
          ),
          GoRoute(
            path: '/marca-form',
            name: 'marca-form',
            builder: (context, state) {
              final arguments = state.extra as Map<String, dynamic>?;
              return MarcaFormPage(arguments: arguments);
            },
          ),
          // HU-002: Gestionar Catálogo de Materiales
          GoRoute(
            path: '/materiales',
            name: 'materiales',
            builder: (context, state) => const MaterialesListPage(),
          ),
          GoRoute(
            path: '/materiales-form',
            name: 'materiales-form',
            builder: (context, state) {
              final arguments = state.extra as Map<String, dynamic>?;
              return MaterialFormPage(arguments: arguments);
            },
          ),
          // HU-003: Gestionar Catálogo de Tipos
          GoRoute(
            path: '/tipos',
            name: 'tipos',
            builder: (context, state) => const TiposListPage(),
          ),
          GoRoute(
            path: '/tipos-form',
            name: 'tipos-form',
            builder: (context, state) {
              final arguments = state.extra as Map<String, dynamic>?;
              return TipoFormPage(arguments: arguments);
            },
          ),
          // HU-004: Gestionar Sistemas de Tallas
          GoRoute(
            path: '/sistemas-talla',
            name: 'sistemas-talla',
            builder: (context, state) => const SistemasTallaListPage(),
          ),
          GoRoute(
            path: '/sistemas-talla-form',
            name: 'sistemas-talla-form',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return SistemaTallaFormPage(sistema: extra?['sistema']);
            },
          ),
          // HU-005: Gestionar Catálogo de Colores
          GoRoute(
            path: '/colores',
            name: 'colores',
            builder: (context, state) => const ColoresListPage(),
          ),
          GoRoute(
            path: '/color-form',
            name: 'color-form',
            builder: (context, state) {
              final arguments = state.extra as Map<String, dynamic>?;
              return BlocProvider(
                create: (_) => sl<ColoresBloc>()..add(const LoadColores()),
                child: ColorFormPage(arguments: arguments),
              );
            },
          ),
          GoRoute(
            path: '/colores-estadisticas',
            name: 'colores-estadisticas',
            builder: (context, state) => const ColoresEstadisticasPage(),
          ),
          GoRoute(
            path: '/filtrar-combinacion',
            name: 'filtrar-combinacion',
            builder: (context, state) => const FiltrarPorCombinacionPage(),
          ),
          GoRoute(
            path: '/productos-por-color',
            name: 'productos-por-color',
            builder: (context, state) => const ProductosPorColorPage(),
          ),
          // HU-006: Gestionar Productos Maestros
          GoRoute(
            path: '/productos-maestros',
            name: 'productos-maestros',
            builder: (context, state) => const ProductosMaestrosListPage(),
          ),
          GoRoute(
            path: '/producto-maestro-form',
            name: 'producto-maestro-form',
            builder: (context, state) {
              final arguments = state.extra as Map<String, dynamic>?;
              return ProductoMaestroFormPage(arguments: arguments);
            },
          ),
          GoRoute(
            path: '/producto-maestro-detail',
            name: 'producto-maestro-detail',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ProductoMaestroDetailPage(extra: extra);
            },
          ),
        ],
      ),
    ],
  );
}

/// Wrapper del MainLayout que integra con MenuBloc y AuthBloc
class _MainLayoutWrapper extends StatelessWidget {
  final Widget child;

  const _MainLayoutWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocBuilder<MenuBloc, MenuState>(
          builder: (context, menuState) {
            if (menuState is MenuInitial) {
              // Cargar menú al iniciar
              context.read<MenuBloc>().add(LoadMenuEvent(userId: authState.user.id));
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (menuState is MenuLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (menuState is MenuError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error al cargar menú: ${menuState.message}'),
                    ],
                  ),
                ),
              );
            }

            if (menuState is MenuLoaded || menuState is SidebarUpdating) {
              final menuOptions = menuState is MenuLoaded
                  ? menuState.menuOptions
                  : (menuState as SidebarUpdating).menuOptions;
              final sidebarCollapsed = menuState is MenuLoaded
                  ? menuState.sidebarCollapsed
                  : (menuState as SidebarUpdating).currentCollapsed;

              final currentRoute = GoRouterState.of(context).matchedLocation;
              final breadcrumbs = _generateBreadcrumbs(currentRoute);

              // Crear UserProfile desde datos del AuthState
              final userProfile = _createUserProfileFromAuth(authState.user);

              return MainLayout(
                sidebarCollapsed: sidebarCollapsed,
                menuOptions: menuOptions,
                user: userProfile,
                breadcrumbs: breadcrumbs,
                currentRoute: currentRoute,
                onToggleSidebar: (collapsed) {
                  context.read<MenuBloc>().add(ToggleSidebarEvent(
                        userId: authState.user.id,
                        collapsed: collapsed,
                      ));
                },
                onNavigate: (route) {
                  context.go(route);
                },
                onLogout: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                  context.go('/login');
                },
                child: child,
              );
            }

            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
    );
  }

  /// Generar breadcrumbs desde ruta actual
  List<Breadcrumb> _generateBreadcrumbs(String route) {
    final breadcrumbs = <Breadcrumb>[];

    final routeMap = {
      '/dashboard': ('Dashboard', '/dashboard'),
      '/pos': ('Punto de Venta', '/pos'),
      '/products': ('Productos', '/products'),
      '/inventory': ('Inventario', '/inventory'),
      '/sales': ('Ventas', '/sales'),
      '/clientes': ('Clientes', '/clientes'),
      '/reportes': ('Reportes', '/reportes'),
      '/admin': ('Administración', '/admin'),
      '/settings': ('Configuración', '/settings'),
      '/marcas': ('Catálogo de Marcas', '/marcas'),
      '/marca-form': ('Formulario de Marca', null),
      '/materiales': ('Catálogo de Materiales', '/materiales'),
      '/materiales-form': ('Formulario de Material', null),
      '/tipos': ('Catálogo de Tipos', '/tipos'),
      '/tipos-form': ('Formulario de Tipo', null),
      '/sistemas-talla': ('Sistemas de Tallas', '/sistemas-talla'),
      '/sistemas-talla-form': ('Formulario de Sistema de Tallas', null),
      '/colores': ('Catálogo de Colores', '/colores'),
      '/color-form': ('Formulario de Color', null),
      '/colores-estadisticas': ('Estadísticas de Colores', null),
      '/productos-maestros': ('Productos Maestros', '/productos-maestros'),
      '/producto-maestro-form': ('Formulario de Producto Maestro', null),
      '/producto-maestro-detail': ('Detalle de Producto Maestro', null),
    };

    final current = routeMap[route];
    if (current != null) {
      breadcrumbs.add(Breadcrumb(
        label: current.$1,
        route: null, // Ruta actual no es clickeable
      ));
    }

    return breadcrumbs;
  }

  /// Crear UserProfile desde User de AuthState
  UserProfile _createUserProfileFromAuth(dynamic user) {
    return UserProfile(
      id: user.id,
      nombreCompleto: user.nombreCompleto ?? 'Usuario',
      email: user.email,
      rol: user.rol.toString().split('.').last.toUpperCase(),
      avatarUrl: null,
      sidebarCollapsed: false,
    );
  }
}

/// Placeholder page para rutas no implementadas
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta página está en construcción',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper para escuchar cambios en el AuthBloc
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
