import 'package:flutter/material.dart';

/// Dropdown menu con información de usuario y opción de logout
///
/// Especificaciones:
/// - Avatar circular de 36px (radio 18)
/// - Nombre del usuario en texto bold
/// - Rol del usuario en texto secundario
/// - Opciones: Mi Perfil, Configuración, Cerrar Sesión
/// - Opción logout en color error (rojo)
///
/// Características:
/// - Theme-aware
/// - Responsive: oculta texto en mobile (<768px)
/// - Hover states
/// - Divider antes de logout
class UserMenuDropdown extends StatelessWidget {
  final String userName;
  final String userRole;
  final String? avatarUrl;
  final VoidCallback onLogoutPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSettingsPressed;

  const UserMenuDropdown({
    Key? key,
    required this.userName,
    required this.userRole,
    this.avatarUrl,
    required this.onLogoutPressed,
    this.onProfilePressed,
    this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
            if (!isMobile) ...[
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    userRole,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ],
        ),
      ),
      itemBuilder: (context) => [
        if (onProfilePressed != null)
          PopupMenuItem<String>(
            value: 'profile',
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                const Text('Mi Perfil'),
              ],
            ),
          ),
        if (onSettingsPressed != null)
          PopupMenuItem<String>(
            value: 'settings',
            child: Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                const Text('Configuración'),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          onTap: onLogoutPressed,
          child: Row(
            children: [
              Icon(
                Icons.logout,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                'Cerrar Sesión',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'profile' && onProfilePressed != null) {
          onProfilePressed!();
        } else if (value == 'settings' && onSettingsPressed != null) {
          onSettingsPressed!();
        }
        // logout se maneja con onTap en el MenuItem
      },
    );
  }
}
