import 'package:flutter/material.dart';
import 'package:system_web_medias/features/user/domain/entities/user_profile.dart';
import 'package:system_web_medias/features/navigation/domain/entities/breadcrumb.dart';
import 'package:system_web_medias/shared/design_system/molecules/breadcrumbs_widget.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/logout_confirmation_dialog.dart';

/// Header de la aplicación con breadcrumbs y perfil de usuario
///
/// Especificaciones:
/// - Altura: 64px
/// - Background: Blanco
/// - Border bottom: 1px solid gris
/// - Padding horizontal: 24px
/// - Avatar: 40px diámetro
/// - Badge rol: con colores específicos por rol
///
/// Características:
/// - Breadcrumbs de navegación
/// - Dropdown de perfil de usuario
/// - Opciones: Ver perfil, Configuración, Cerrar sesión
/// - Modal de confirmación para logout
/// - Theme-aware
class AppHeader extends StatelessWidget {
  final UserProfile user;
  final List<Breadcrumb> breadcrumbs;
  final VoidCallback onLogout;
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final ValueChanged<String> onNavigate;

  const AppHeader({
    Key? key,
    required this.user,
    required this.breadcrumbs,
    required this.onLogout,
    required this.onProfile,
    required this.onSettings,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: BreadcrumbsWidget(
              breadcrumbs: breadcrumbs,
              onNavigate: onNavigate,
            ),
          ),
          const SizedBox(width: 24),
          _buildUserProfile(context),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        hoverColor: theme.colorScheme.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary,
                backgroundImage: user.hasAvatar ? NetworkImage(user.avatarUrl!) : null,
                child: !user.hasAvatar
                    ? Text(
                        user.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleBadgeColor(user.rol).withValues(alpha: 0.1),
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
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: const [
              Icon(Icons.person, size: 18, color: Color(0xFF6B7280)),
              SizedBox(width: 12),
              Text('Ver perfil'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: const [
              Icon(Icons.settings, size: 18, color: Color(0xFF6B7280)),
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
    switch (rol.toUpperCase()) {
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
      builder: (context) => LogoutConfirmationDialog(
        onConfirm: () {
          onLogout();
        },
      ),
    );
  }
}
