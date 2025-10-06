# Componentes UI - E003-HU-002: Sistema de Navegación con Menús Desplegables

**Historia de Usuario**: E003-HU-002
**Fecha creación**: 2025-10-06
**Autor**: @web-architect-expert
**Estado**: 📋 Especificación Técnica

---

## 🎯 OBJETIVO

Documentar la especificación UI/UX de todos los componentes visuales del sistema de navegación con sidebar, header, breadcrumbs y menús desplegables.

---

## 🎨 DESIGN TOKENS APLICABLES

### Colores
```dart
// De design/tokens.md
primaryTurquoise: #4ECDC4
primaryDark: #26A69A
textPrimary: #1A1A1A
textSecondary: #6B7280
backgroundLight: #F9FAFB
cardWhite: #FFFFFF
```

### Espaciado
```dart
xs: 4px
sm: 8px
md: 16px
lg: 24px
xl: 32px
```

### Border Radius
```dart
cards: 12px
buttons: 8px
```

---

## 🧩 COMPONENTES PRINCIPALES

### 1. `AppSidebar` - Sidebar Navegación

**Ubicación**: `lib/shared/design_system/organisms/app_sidebar.dart`

**Especificaciones**:

#### Estados:
- **Expandido**: Ancho 280px, muestra íconos + labels
- **Colapsado**: Ancho 80px, solo íconos + tooltips

#### Diseño Visual:

```
┌─────────────────────────────────┐
│  [☰]  Sistema Medias           │ ← Header (altura 64px)
├─────────────────────────────────┤
│  📊  Dashboard                  │ ← Menú raíz (altura 48px)
│  🏪  Punto de Venta            │
│  📦  Productos              ▼  │ ← Menú con children (expandible)
│       └─ Gestionar catálogo    │ ← Sub-menú (indentación 24px)
│  📋  Inventario                │
│  💰  Ventas                 ▼  │
│  👥  Clientes               ▼  │
│  📈  Reportes               ▼  │
└─────────────────────────────────┘
```

**Colores**:
- Background: `#FFFFFF`
- Hover: `#F9FAFB`
- Activo: `primaryTurquoise (#4ECDC4)` con border-left 4px
- Texto: `textPrimary (#1A1A1A)`
- Texto activo: `#FFFFFF`
- Ícono: `textSecondary (#6B7280)`
- Ícono activo: `#FFFFFF`

**Animaciones**:
- Expansión/colapso: `Duration(milliseconds: 300)` con `Curves.easeInOut`
- Hover: `Duration(milliseconds: 200)` con cambio de background
- Indicador activo: Transición suave de color

**Estructura del Componente**:
```dart
class AppSidebar extends StatefulWidget {
  final bool isCollapsed;
  final List<MenuOption> menuOptions;
  final String currentRoute;
  final ValueChanged<bool> onToggleCollapse;
  final ValueChanged<String> onNavigate;

  const AppSidebar({
    required this.isCollapsed,
    required this.menuOptions,
    required this.currentRoute,
    required this.onToggleCollapse,
    required this.onNavigate,
    Key? key,
  }) : super(key: key);

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final Map<String, bool> _expandedMenus = {};

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: widget.isCollapsed ? 80 : 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: widget.menuOptions.length,
              itemBuilder: (context, index) {
                return _buildMenuItem(widget.menuOptions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          ),
          if (!widget.isCollapsed) ...[
            const SizedBox(width: 8),
            Text(
              'Sistema Medias',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF26A69A),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuOption menu) {
    final isActive = widget.currentRoute == menu.route;
    final isExpanded = _expandedMenus[menu.id] ?? false;

    return Column(
      children: [
        InkWell(
          onTap: () {
            if (menu.hasChildren) {
              setState(() {
                _expandedMenus[menu.id] = !isExpanded;
              });
            } else if (menu.route != null) {
              widget.onNavigate(menu.route!);
            }
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF4ECDC4) : Colors.transparent,
              borderLeft: isActive
                  ? const Border(
                      left: BorderSide(
                        color: Color(0xFF26A69A),
                        width: 4,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  _getIcon(menu.icon),
                  color: isActive
                      ? Colors.white
                      : const Color(0xFF6B7280),
                  size: 24,
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      menu.label,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (menu.hasChildren)
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: isActive
                          ? Colors.white
                          : const Color(0xFF6B7280),
                      size: 20,
                    ),
                ],
              ],
            ),
          ),
        ),
        if (menu.hasChildren && isExpanded && !widget.isCollapsed)
          ...menu.children!.map((child) => _buildSubMenuItem(child)),
      ],
    );
  }

  Widget _buildSubMenuItem(MenuOption subMenu) {
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
        color: isActive
            ? const Color(0xFF4ECDC4).withOpacity(0.1)
            : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Text(
                subMenu.label,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFF4ECDC4)
                      : const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'dashboard':
        return Icons.dashboard;
      case 'point_of_sale':
        return Icons.point_of_sale;
      case 'inventory':
        return Icons.inventory_2;
      case 'warehouse':
        return Icons.warehouse;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'people':
        return Icons.people;
      case 'bar_chart':
        return Icons.bar_chart;
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.circle;
    }
  }
}
```

---

### 2. `AppHeader` - Header con Perfil de Usuario

**Ubicación**: `lib/shared/design_system/organisms/app_header.dart`

**Especificaciones**:

#### Diseño Visual:
```
┌────────────────────────────────────────────────────────────┐
│  Breadcrumbs: Dashboard > Productos          👤 Juan Pérez │
│                                                  [Vendedor] │
└────────────────────────────────────────────────────────────┘
```

**Altura**: 64px
**Background**: `#FFFFFF`
**Border bottom**: 1px solid `#E5E7EB`

**Estructura**:
```dart
class AppHeader extends StatelessWidget {
  final UserProfile user;
  final List<Breadcrumb> breadcrumbs;
  final VoidCallback onLogout;
  final VoidCallback onProfile;
  final VoidCallback onSettings;

  const AppHeader({
    required this.user,
    required this.breadcrumbs,
    required this.onLogout,
    required this.onProfile,
    required this.onSettings,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBreadcrumbs(context),
          ),
          const SizedBox(width: 24),
          _buildUserProfile(context),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    return Row(
      children: breadcrumbs
          .asMap()
          .entries
          .expand((entry) => [
                if (entry.key > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                InkWell(
                  onTap: entry.value.isClickable
                      ? () => _navigateTo(entry.value.route!)
                      : null,
                  child: Text(
                    entry.value.label,
                    style: TextStyle(
                      color: entry.value.isClickable
                          ? const Color(0xFF4ECDC4)
                          : const Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: entry.value.isClickable
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ])
          .toList(),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF4ECDC4),
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    user.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.nombreCompleto,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getRoleBadgeColor(user.rol).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.roleBadge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _getRoleBadgeColor(user.rol),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Color(0xFF6B7280),
          ),
        ],
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
              Text('Cerrar sesión', style: TextStyle(color: Color(0xFFF44336))),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          _showLogoutDialog(context);
        } else if (value == 'profile') {
          onProfile();
        } else if (value == 'settings') {
          onSettings();
        }
      },
    );
  }

  Color _getRoleBadgeColor(String rol) {
    switch (rol) {
      case 'ADMIN':
        return const Color(0xFFF44336); // Rojo
      case 'GERENTE':
        return const Color(0xFF2196F3); // Azul
      case 'VENDEDOR':
        return const Color(0xFF4CAF50); // Verde
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _navigateTo(String route) {
    // Implementar navegación
  }
}
```

---

### 3. `BreadcrumbsWidget` - Migas de Pan

**Ubicación**: `lib/shared/design_system/molecules/breadcrumbs_widget.dart`

**Especificaciones**:

```dart
class BreadcrumbsWidget extends StatelessWidget {
  final List<Breadcrumb> breadcrumbs;
  final ValueChanged<String> onNavigate;

  const BreadcrumbsWidget({
    required this.breadcrumbs,
    required this.onNavigate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: breadcrumbs
          .asMap()
          .entries
          .expand((entry) => [
                if (entry.key > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                _buildBreadcrumbItem(entry.value),
              ])
          .toList(),
    );
  }

  Widget _buildBreadcrumbItem(Breadcrumb breadcrumb) {
    if (breadcrumb.isClickable) {
      return InkWell(
        onTap: () => onNavigate(breadcrumb.route!),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Text(
            breadcrumb.label,
            style: const TextStyle(
              color: Color(0xFF4ECDC4),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    } else {
      return Text(
        breadcrumb.label,
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }
}
```

---

### 4. `LogoutConfirmationDialog` - Modal de Confirmación

**Ubicación**: `lib/features/auth/presentation/widgets/logout_confirmation_dialog.dart`

**Especificaciones**:

```dart
class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutConfirmationDialog({
    required this.onConfirm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: const [
          Icon(
            Icons.logout,
            color: Color(0xFFF44336),
            size: 24,
          ),
          SizedBox(width: 12),
          Text('Cerrar sesión'),
        ],
      ),
      content: const Text(
        '¿Estás seguro que deseas cerrar sesión?',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF6B7280),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF44336),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
```

---

## 📐 LAYOUT PRINCIPAL

### `MainLayout` - Layout con Sidebar + Header + Content

**Ubicación**: `lib/shared/design_system/templates/main_layout.dart`

```dart
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

  const MainLayout({
    required this.child,
    required this.sidebarCollapsed,
    required this.menuOptions,
    required this.user,
    required this.breadcrumbs,
    required this.currentRoute,
    required this.onToggleSidebar,
    required this.onNavigate,
    required this.onLogout,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  onProfile: () => onNavigate('/profile'),
                  onSettings: () => onNavigate('/settings'),
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
}
```

---

## 📱 RESPONSIVE BEHAVIOR

### Breakpoints:

- **Desktop (≥1200px)**: Sidebar fijo expandido/colapsado
- **Tablet (768-1199px)**: Sidebar colapsado por defecto
- **Mobile (<768px)**: Drawer (hamburguesa)

```dart
class ResponsiveMainLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) {
      return MainLayout(...); // Sidebar fijo
    } else if (width >= 768) {
      return MainLayout(sidebarCollapsed: true, ...); // Colapsado
    } else {
      return MobileLayout(...); // Drawer
    }
  }
}
```

---

## 📋 CHECKLIST DE IMPLEMENTACIÓN PARA @ux-ui-expert

- [ ] `AppSidebar` con animaciones de expansión/colapso
- [ ] `AppHeader` con dropdown de usuario
- [ ] `BreadcrumbsWidget` con separadores y navegación
- [ ] `LogoutConfirmationDialog` con diseño consistente
- [ ] `MainLayout` integrando todos los componentes
- [ ] Responsive behavior para mobile/tablet/desktop
- [ ] Tooltips en sidebar colapsado
- [ ] Indicador visual de página activa
- [ ] Animaciones suaves en transiciones
- [ ] Tests de widgets

---

**Próximos pasos**: Documentar Mapping en `mapping_E003-HU-002.md`