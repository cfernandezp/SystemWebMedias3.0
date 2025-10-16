import 'package:flutter/material.dart';
import 'package:system_web_medias/core/theme/design_tokens.dart';

class FormatoBadge extends StatelessWidget {
  final String formato;

  const FormatoBadge({
    super.key,
    required this.formato,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.full),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          SizedBox(width: DesignSpacing.xs),
          Text(
            _getLabel(),
            style: TextStyle(
              color: color,
              fontSize: DesignTypography.fontXs,
              fontWeight: DesignTypography.medium,
            ),
          ),
        ],
      ),
    );
  }

  String _getLabel() {
    switch (formato.toUpperCase()) {
      case 'NUMERICO':
        return 'Numérico';
      case 'ALFANUMERICO':
        return 'Alfanumérico';
      default:
        return formato;
    }
  }

  Color _getColor() {
    switch (formato.toUpperCase()) {
      case 'NUMERICO':
        return DesignColors.info;
      case 'ALFANUMERICO':
        return DesignColors.accent;
      default:
        return DesignColors.textSecondary;
    }
  }

  IconData _getIcon() {
    switch (formato.toUpperCase()) {
      case 'NUMERICO':
        return Icons.pin_outlined;
      case 'ALFANUMERICO':
        return Icons.text_fields;
      default:
        return Icons.help_outline;
    }
  }
}
