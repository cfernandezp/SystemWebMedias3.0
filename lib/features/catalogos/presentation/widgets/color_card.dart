import 'package:flutter/material.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/color_preview_circle.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/status_badge.dart';

class ColorCard extends StatelessWidget {
  final String nombre;
  final List<String> codigosHex;
  final bool activo;
  final int productosCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ColorCard({
    Key? key,
    required this.nombre,
    required this.codigosHex,
    required this.activo,
    required this.productosCount,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isDesktop
              ? _buildDesktopLayout(context, theme)
              : _buildMobileLayout(context, theme),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        ColorPreviewCircle(
          codigosHex: codigosHex,
          size: 48,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                codigosHex.join(', '),
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        StatusBadge(activo: activo),
        const SizedBox(width: 12),
        _buildProductsCount(theme),
        const SizedBox(width: 12),
        _buildActions(context),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            ColorPreviewCircle(
              codigosHex: codigosHex,
              size: 48,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    codigosHex.join(', '),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(activo: activo),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildProductsCount(theme),
            _buildActions(context),
          ],
        ),
      ],
    );
  }

  Widget _buildProductsCount(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '$productosCount',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          iconSize: 20,
          color: Theme.of(context).colorScheme.primary,
          tooltip: 'Editar',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onDelete,
          icon: Icon(
            productosCount > 0 ? Icons.visibility_off : Icons.delete_outline,
          ),
          iconSize: 20,
          color: productosCount > 0 ? Colors.orange : const Color(0xFFF44336),
          tooltip: productosCount > 0 ? 'Desactivar' : 'Eliminar',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
        ),
      ],
    );
  }
}
