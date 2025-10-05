import 'package:flutter/material.dart';

/// Variantes del CorporateButton
enum ButtonVariant {
  primary,
  secondary,
}

/// Botón corporativo que sigue el Design System Turquesa Moderno Retail
///
/// Especificaciones:
/// - Altura: 52px
/// - Border radius: 8px
/// - Padding horizontal: 24px
/// - Variantes: primary (turquesa), secondary (outline)
/// - Estados: normal, hover, pressed, loading
class CorporateButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  const CorporateButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    if (variant == ButtonVariant.secondary) {
      return _buildSecondaryButton(context, primaryColor);
    }

    return _buildPrimaryButton(context, primaryColor);
  }

  Widget _buildPrimaryButton(BuildContext context, Color primaryColor) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          disabledBackgroundColor: primaryColor.withValues(alpha: 0.6),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.2);
            }
            return null;
          }),
        ),
        child: isLoading ? _buildLoadingIndicator(context, Colors.white) : _buildButtonContent(),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, Color primaryColor) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          disabledForegroundColor: primaryColor.withValues(alpha: 0.6),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return primaryColor.withValues(alpha: 0.05);
            }
            if (states.contains(WidgetState.pressed)) {
              return primaryColor.withValues(alpha: 0.1);
            }
            return null;
          }),
        ),
        child: isLoading ? _buildLoadingIndicator(context, primaryColor) : _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context, Color indicatorColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Cargando...',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
