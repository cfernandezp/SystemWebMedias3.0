import 'package:flutter/material.dart';
import 'package:system_web_medias/core/theme/design_tokens.dart';

class RolesBadgesWidget extends StatelessWidget {
  final List<dynamic> roles;

  const RolesBadgesWidget({
    super.key,
    required this.roles,
  });

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: DesignColors.disabled.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: DesignColors.disabled,
            ),
            SizedBox(width: DesignSpacing.xs),
            Text(
              'Sin roles asignados',
              style: TextStyle(
                fontSize: DesignTypography.fontSm,
                color: DesignColors.disabled,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: DesignSpacing.sm,
      children: roles.map((rol) {
        final tipo = rol['tipo'] ?? 'Sin tipo';
        final activo = rol['activo'] ?? false;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: DesignSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: activo
                ? DesignColors.success.withValues(alpha: 0.1)
                : DesignColors.disabled.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
            border: Border.all(
              color: activo ? DesignColors.success : DesignColors.disabled,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconForRole(tipo),
                size: 16,
                color: activo ? DesignColors.success : DesignColors.disabled,
              ),
              SizedBox(width: DesignSpacing.xs),
              Text(
                tipo,
                style: TextStyle(
                  fontSize: DesignTypography.fontSm,
                  color: activo ? DesignColors.success : DesignColors.disabled,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (activo)
                Container(
                  margin: EdgeInsets.only(left: DesignSpacing.xs),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: DesignColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForRole(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'cliente':
        return Icons.shopping_bag;
      case 'proveedor':
        return Icons.local_shipping;
      case 'transportista':
        return Icons.local_shipping_outlined;
      default:
        return Icons.person;
    }
  }
}
