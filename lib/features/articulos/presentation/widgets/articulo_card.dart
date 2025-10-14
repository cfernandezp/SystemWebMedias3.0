import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/articulos/data/models/articulo_model.dart';
import 'package:system_web_medias/features/articulos/presentation/bloc/articulos_event.dart';
import 'package:system_web_medias/features/articulos/presentation/bloc/articulos_bloc.dart';
import 'package:system_web_medias/features/articulos/presentation/widgets/colores_preview_widget.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/status_badge.dart';
import 'package:intl/intl.dart';

class ArticuloCard extends StatefulWidget {
  final ArticuloModel articulo;

  const ArticuloCard({super.key, required this.articulo});

  @override
  State<ArticuloCard> createState() => _ArticuloCardState();
}

class _ArticuloCardState extends State<ArticuloCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: _elevationAnimation.value,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isDesktop
                    ? _buildDesktopLayout(context, theme)
                    : _buildMobileLayout(context, theme),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.articulo.sku,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.articulo.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            if (widget.articulo.colores != null && widget.articulo.colores!.isNotEmpty) ...[
              ColoresPreviewWidget(
                colores: widget.articulo.colores!,
                tipoColoracion: widget.articulo.tipoColoracion,
                size: 32,
              ),
              const SizedBox(width: 12),
            ],

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatoMoneda.format(widget.articulo.precio),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.articulo.colores?.map((c) => c.nombre).join(', ') ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            StatusBadge(activo: widget.articulo.activo),

            const SizedBox(width: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTipoColoracionColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getTipoColoracionText(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getTipoColoracionColor(),
                ),
              ),
            ),

            const Spacer(),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  color: theme.colorScheme.primary,
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: _handleEdit,
                ),

                IconButton(
                  icon: Icon(
                    widget.articulo.activo ? Icons.toggle_on : Icons.toggle_off,
                  ),
                  tooltip: widget.articulo.activo ? 'Desactivar' : 'Reactivar',
                  color: widget.articulo.activo
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF9CA3AF),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: widget.articulo.activo ? _handleDeactivate : _handleReactivate,
                ),

                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar',
                  color: const Color(0xFFF44336),
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: _handleDelete,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.articulo.sku,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.articulo.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            StatusBadge(activo: widget.articulo.activo),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            if (widget.articulo.colores != null && widget.articulo.colores!.isNotEmpty) ...[
              ColoresPreviewWidget(
                colores: widget.articulo.colores!,
                tipoColoracion: widget.articulo.tipoColoracion,
                size: 32,
              ),
              const SizedBox(width: 12),
            ],

            Expanded(
              child: Text(
                formatoMoneda.format(widget.articulo.precio),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: theme.colorScheme.primary,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: _handleEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: const Color(0xFFF44336),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: _handleDelete,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _getTipoColoracionText() {
    switch (widget.articulo.tipoColoracion) {
      case 'unicolor':
        return 'UNICOLOR';
      case 'bicolor':
        return 'BICOLOR';
      case 'tricolor':
        return 'TRICOLOR';
      default:
        return widget.articulo.tipoColoracion.toUpperCase();
    }
  }

  Color _getTipoColoracionColor() {
    switch (widget.articulo.tipoColoracion) {
      case 'unicolor':
        return const Color(0xFF4CAF50);
      case 'bicolor':
        return const Color(0xFF2196F3);
      case 'tricolor':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _handleEdit() {
    // TODO: Implementar edición de artículos (solo precio si tiene stock)
  }

  void _handleDeactivate() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Desactivar artículo?'),
        content: Text('¿Deseas desactivar el artículo "${widget.articulo.sku}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ArticulosBloc>().add(DesactivarArticuloEvent(articuloId: widget.articulo.id));
            },
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  void _handleReactivate() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Reactivar artículo?'),
        content: Text('¿Deseas reactivar el artículo "${widget.articulo.sku}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ArticulosBloc>().add(EditarArticuloEvent(
                articuloId: widget.articulo.id,
                activo: true,
              ));
            },
            child: const Text('Reactivar'),
          ),
        ],
      ),
    );
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar artículo?'),
        content: Text('¿Estás seguro de eliminar permanentemente el artículo "${widget.articulo.sku}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ArticulosBloc>().add(EliminarArticuloEvent(articuloId: widget.articulo.id));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}