import 'package:flutter/material.dart';
import 'package:system_web_medias/features/menu/domain/entities/menu_option.dart';
import 'package:system_web_medias/features/user/domain/entities/user_profile.dart';
import 'package:system_web_medias/features/navigation/domain/entities/breadcrumb.dart';
import 'package:system_web_medias/shared/design_system/organisms/app_sidebar.dart';
import 'package:system_web_medias/shared/design_system/organisms/app_header.dart';

/// Layout principal de la aplicación con Sidebar + Header + Content
///
/// Especificaciones:
/// - Sidebar: 280px expandido / 80px colapsado
/// - Header: 64px altura
/// - Content: Fondo #F9FAFB con padding 24px
/// - Responsive: Desktop / Tablet / Mobile
///
/// Características:
/// - Integración de AppSidebar y AppHeader
/// - Manejo de estado de sidebar (expandido/colapsado)
/// - Navegación completa
/// - Theme-aware
/// - Responsive design con breakpoints
class MainLayout extends StatelessWidget {
  final Widget child;
  final bool sidebarCollapsed;
  final List<MenuOption> menuOptions;
  final UserProfile user;
  final List<Breadcrumb> breadcrumbs;
  final String currentRoute;
  final ValueChanged<bool> onToggleSidebar;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;

  const MainLayout({
    Key? key,
    required this.child,
    required this.sidebarCollapsed,
    required this.menuOptions,
    required this.user,
    required this.breadcrumbs,
    required this.currentRoute,
    required this.onToggleSidebar,
    required this.onNavigate,
    required this.onLogout,
    this.onProfile,
    this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;

        if (isMobile) {
          return _buildMobileLayout(context);
        } else if (isTablet) {
          return _buildTabletLayout(context);
        } else {
          // Desktop (≥1200px)
          return _buildDesktopLayout(context);
        }
      },
    );
  }

  /// Layout para desktop (≥1200px): Sidebar fijo expandido/colapsado
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            isCollapsed: sidebarCollapsed,
            menuOptions: menuOptions,
            currentRoute: currentRoute,
            onToggleCollapse: onToggleSidebar,
            onNavigate: onNavigate,
          ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  user: user,
                  breadcrumbs: breadcrumbs,
                  onLogout: onLogout,
                  onProfile: onProfile ?? () => onNavigate('/profile'),
                  onSettings: onSettings ?? () => onNavigate('/settings'),
                  onNavigate: onNavigate,
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF9FAFB),
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Layout para tablet (768-1199px): Sidebar colapsado por defecto
  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            isCollapsed: true, // Siempre colapsado en tablet
            menuOptions: menuOptions,
            currentRoute: currentRoute,
            onToggleCollapse: onToggleSidebar,
            onNavigate: onNavigate,
          ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  user: user,
                  breadcrumbs: breadcrumbs,
                  onLogout: onLogout,
                  onProfile: onProfile ?? () => onNavigate('/profile'),
                  onSettings: onSettings ?? () => onNavigate('/settings'),
                  onNavigate: onNavigate,
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF9FAFB),
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Layout para mobile (<768px): Drawer (hamburguesa)
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          breadcrumbs.isNotEmpty ? breadcrumbs.last.label : 'Sistema Medias',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          _buildMobileUserMenu(context),
        ],
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 1,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: menuOptions.length,
                itemBuilder: (context, index) {
                  return _buildDrawerMenuItem(context, menuOptions[index]);
                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFF9FAFB),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            backgroundImage: user.hasAvatar ? NetworkImage(user.avatarUrl!) : null,
            child: !user.hasAvatar
                ? Text(
                    user.initials,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            user.nombreCompleto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            user.roleBadge,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerMenuItem(BuildContext context, MenuOption menu) {
    final isActive = currentRoute == menu.route;

    if (menu.hasChildren) {
      return ExpansionTile(
        leading: Icon(_getIcon(menu.icon)),
        title: Text(menu.label),
        children: menu.children!.map((child) {
          final isChildActive = currentRoute == child.route;
          return ListTile(
            title: Text(
              child.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isChildActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            selected: isChildActive,
            onTap: () {
              if (child.route != null) {
                Navigator.pop(context); // Cerrar drawer
                onNavigate(child.route!);
              }
            },
          );
        }).toList(),
      );
    }

    return ListTile(
      leading: Icon(_getIcon(menu.icon)),
      title: Text(menu.label),
      selected: isActive,
      onTap: () {
        if (menu.route != null) {
          Navigator.pop(context); // Cerrar drawer
          onNavigate(menu.route!);
        }
      },
    );
  }

  Widget _buildMobileUserMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: user.hasAvatar ? NetworkImage(user.avatarUrl!) : null,
        child: !user.hasAvatar
            ? Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              )
            : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: const [
              Icon(Icons.person, size: 18),
              SizedBox(width: 12),
              Text('Ver perfil'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: const [
              Icon(Icons.settings, size: 18),
              SizedBox(width: 12),
              Text('Configuración'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, size: 18, color: Color(0xFFF44336)),
              SizedBox(width: 12),
              Text(
                'Cerrar sesión',
                style: TextStyle(color: Color(0xFFF44336)),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          onLogout();
        } else if (value == 'profile') {
          if (onProfile != null) {
            onProfile!();
          } else {
            onNavigate('/profile');
          }
        } else if (value == 'settings') {
          if (onSettings != null) {
            onSettings!();
          } else {
            onNavigate('/settings');
          }
        }
      },
    );
  }

  IconData _getIcon(String? iconName) {
    if (iconName == null) return Icons.circle;

    switch (iconName) {
      case 'dashboard':
        return Icons.dashboard;
      case 'point_of_sale':
        return Icons.point_of_sale;
      case 'inventory':
        return Icons.inventory_2;
      case 'inventory_2':
        return Icons.inventory_2;
      case 'warehouse':
        return Icons.warehouse;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'people':
        return Icons.people;
      case 'person':
        return Icons.person;
      case 'bar_chart':
        return Icons.bar_chart;
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;
      case 'settings':
        return Icons.settings;
      case 'store':
        return Icons.store;
      case 'category':
        return Icons.category;
      case 'attach_money':
        return Icons.attach_money;
      case 'receipt_long':
        return Icons.receipt_long;
      default:
        return Icons.circle;
    }
  }
}
