import 'package:flutter/material.dart';

/// Header consistente para páginas de autenticación
///
/// Incluye:
/// - Logo del sistema (48px altura)
/// - Título (headlineLarge - 28px, primaryDark)
/// - Subtítulo opcional (bodyMedium, textSecondary)
class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showLogo;

  const AuthHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.showLogo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        if (showLogo) ...[
          Center(
            child: _buildLogo(),
          ),
          const SizedBox(height: 24),
        ],

        // Título
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF26A69A), // primaryDark
          ),
        ),

        // Subtítulo (opcional)
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280), // textSecondary
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogo() {
    // Intentar cargar logo desde assets
    // Si no existe, mostrar placeholder con nombre del sistema
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.store_outlined,
            size: 40,
            color: const Color(0xFF4ECDC4), // primaryTurquoise
          ),
          const SizedBox(width: 8),
          const Text(
            'Sistema Medias',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26A69A), // primaryDark
            ),
          ),
        ],
      ),
    );

    // TODO: Descomentar cuando exista assets/logo.png
    // return Image.asset(
    //   'assets/logo.png',
    //   height: 48,
    //   errorBuilder: (context, error, stackTrace) {
    //     return _buildPlaceholderLogo();
    //   },
    // );
  }
}
