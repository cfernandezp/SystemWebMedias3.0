import 'package:flutter/material.dart';
import 'package:system_web_medias/features/navigation/domain/entities/breadcrumb.dart';

/// Widget de breadcrumbs (migas de pan) para navegación
///
/// Especificaciones:
/// - Separador: Icons.chevron_right 16px
/// - Espaciado entre items: 8px
/// - Color clickeable: Primary color (turquesa)
/// - Color actual: Text primary
/// - Hover effect en items clickeables
///
/// Características:
/// - Items clickeables navegan a su ruta
/// - El último item (actual) no es clickeable
/// - Theme-aware
class BreadcrumbsWidget extends StatelessWidget {
  final List<Breadcrumb> breadcrumbs;
  final ValueChanged<String> onNavigate;

  const BreadcrumbsWidget({
    Key? key,
    required this.breadcrumbs,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (breadcrumbs.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
                  _buildBreadcrumbItem(context, entry.value),
                ])
            .toList(),
      ),
    );
  }

  Widget _buildBreadcrumbItem(BuildContext context, Breadcrumb breadcrumb) {
    final theme = Theme.of(context);

    if (breadcrumb.isClickable) {
      return InkWell(
        onTap: () => onNavigate(breadcrumb.route!),
        borderRadius: BorderRadius.circular(4),
        hoverColor: theme.colorScheme.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          child: Text(
            breadcrumb.label,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Text(
          breadcrumb.label,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }
}
