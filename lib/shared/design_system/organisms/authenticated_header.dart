import 'package:flutter/material.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/user_menu_dropdown.dart';
import 'package:system_web_medias/features/auth/presentation/widgets/logout_confirmation_dialog.dart';

/// Header para usuarios autenticados con UserMenuDropdown
///
/// Especificaciones:
/// - Altura: 64px
/// - Background: Surface del tema (blanco)
/// - Elevation: 0
/// - Integra UserMenuDropdown en actions
///
/// Características:
/// - Theme-aware
/// - Muestra modal de confirmación antes de logout
/// - Soporta título y actions personalizadas
/// - Integración con AuthBloc para logout
class AuthenticatedHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userRole;
  final String? avatarUrl;
  final Widget? title;
  final List<Widget>? actions;
  final VoidCallback onLogoutConfirmed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSettingsPressed;

  const AuthenticatedHeader({
    Key? key,
    required this.userName,
    required this.userRole,
    this.avatarUrl,
    this.title,
    this.actions,
    required this.onLogoutConfirmed,
    this.onProfilePressed,
    this.onSettingsPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      title: title,
      actions: [
        ...?actions,
        UserMenuDropdown(
          userName: userName,
          userRole: userRole,
          avatarUrl: avatarUrl,
          onLogoutPressed: () => _showLogoutConfirmation(context),
          onProfilePressed: onProfilePressed,
          onSettingsPressed: onSettingsPressed,
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LogoutConfirmationDialog(
        onConfirm: onLogoutConfirmed,
      ),
    );
  }
}
