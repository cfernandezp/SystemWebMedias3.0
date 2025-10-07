import 'package:flutter/material.dart';
import 'package:system_web_medias/features/menu/domain/entities/menu_option.dart';

/// Sidebar de navegación principal con soporte para expansión/colapso
///
/// Especificaciones:
/// - Ancho expandido: 280px
/// - Ancho colapsado: 80px
/// - Animación de transición: 300ms con Curves.easeInOut
/// - Altura de header: 64px
/// - Altura de menú item: 48px
/// - Altura de sub-menú item: 40px
/// - Indentación sub-menú: 52px desde la izquierda
///
/// Características:
/// - Menús desplegables con animación
/// - Indicador visual de página activa
/// - Hover effects
/// - Tooltips en modo colapsado
/// - Theme-aware (usa Theme.of(context))
class AppSidebar extends StatefulWidget {
  final bool isCollapsed;
  final List<MenuOption> menuOptions;
  final String currentRoute;
  final ValueChanged<bool> onToggleCollapse;
  final ValueChanged<String> onNavigate;

  const AppSidebar({
    Key? key,
    required this.isCollapsed,
    required this.menuOptions,
    required this.currentRoute,
    required this.onToggleCollapse,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> with SingleTickerProviderStateMixin {
  final Map<String, bool> _expandedMenus = {};

  @override
  void initState() {
    super.initState();
    _initializeExpandedMenus();
  }

  @override
  void didUpdateWidget(AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _initializeExpandedMenus();
    }
  }

  /// Inicializa menús expandidos basado en la ruta actual
  void _initializeExpandedMenus() {
    for (final menu in widget.menuOptions) {
      if (menu.hasChildren) {
        final isActive = _isMenuActive(menu);
        _expandedMenus[menu.id] = isActive;
      }
    }
  }

  /// Verifica si un menú está activo (alguno de sus hijos está activo)
  bool _isMenuActive(MenuOption menu) {
    if (menu.route == widget.currentRoute) return true;
    if (menu.hasChildren) {
      return menu.children!.any((child) => child.route == widget.currentRoute);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: widget.isCollapsed ? 80 : 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: widget.menuOptions.length,
              itemBuilder: (context, index) {
                return _buildMenuItem(widget.menuOptions[index], theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Header del sidebar con logo y botón de toggle
  Widget _buildHeader(ThemeData theme) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => widget.onToggleCollapse(!widget.isCollapsed),
            tooltip: widget.isCollapsed ? 'Expandir menú' : 'Colapsar menú',
            color: theme.colorScheme.primary,
          ),
          if (!widget.isCollapsed) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sistema Medias',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construye un item de menú (puede ser padre con children o hijo simple)
  Widget _buildMenuItem(MenuOption menu, ThemeData theme) {
    final isActive = widget.currentRoute == menu.route;
    final isExpanded = _expandedMenus[menu.id] ?? false;
    final hasActiveChild = menu.hasChildren &&
        menu.children!.any((child) => child.route == widget.currentRoute);

    return Column(
      children: [
        _buildMenuItemButton(
          menu: menu,
          isActive: isActive,
          isExpanded: isExpanded,
          hasActiveChild: hasActiveChild,
          theme: theme,
        ),
        if (menu.hasChildren && isExpanded && !widget.isCollapsed)
          ...menu.children!.map((child) => _buildSubMenuItem(child, theme)),
      ],
    );
  }

  /// Botón de menú individual
  Widget _buildMenuItemButton({
    required MenuOption menu,
    required bool isActive,
    required bool isExpanded,
    required bool hasActiveChild,
    required ThemeData theme,
  }) {
    final backgroundColor = isActive
        ? theme.colorScheme.primary
        : (hasActiveChild
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : Colors.transparent);

    final textColor = isActive ? Colors.white : const Color(0xFF1A1A1A);
    final iconColor = isActive ? Colors.white : const Color(0xFF6B7280);

    final button = InkWell(
      onTap: () => _handleMenuTap(menu),
      onHover: (hovering) {
        // Hover effect manejado por InkWell
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: isActive
              ? Border(
                  left: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    width: 4,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              _getIcon(menu.icon),
              color: iconColor,
              size: widget.isCollapsed ? 20 : 24,
            ),
            if (!widget.isCollapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  menu.label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (menu.hasChildren)
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: iconColor,
                    size: 20,
                  ),
                ),
            ],
          ],
        ),
      ),
    );

    // Agregar Tooltip solo cuando está colapsado
    if (widget.isCollapsed) {
      return Tooltip(
        message: menu.label,
        preferBelow: false,
        child: button,
      );
    }

    return button;
  }

  /// Construye un sub-item de menú
  Widget _buildSubMenuItem(MenuOption subMenu, ThemeData theme) {
    final isActive = widget.currentRoute == subMenu.route;

    return InkWell(
      onTap: () {
        if (subMenu.route != null) {
          widget.onNavigate(subMenu.route!);
        }
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 52, right: 16),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                subMenu.label,
                style: TextStyle(
                  color: isActive
                      ? theme.colorScheme.primary
                      : const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Maneja el tap en un menú item
  void _handleMenuTap(MenuOption menu) {
    if (menu.hasChildren) {
      // Toggle el menú desplegable
      setState(() {
        _expandedMenus[menu.id] = !(_expandedMenus[menu.id] ?? false);
      });
    } else if (menu.route != null) {
      // Navegar a la ruta
      widget.onNavigate(menu.route!);
    }
  }

  /// Mapea el nombre del ícono a IconData
  IconData _getIcon(String? iconName) {
    if (iconName == null) return Icons.circle;

    switch (iconName) {
      case 'dashboard':
        return Icons.dashboard;
      case 'point_of_sale':
        return Icons.point_of_sale;
      case 'inventory':
        return Icons.inventory;
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
      case 'assessment':
        return Icons.assessment;
      default:
        return Icons.circle;
    }
  }
}
