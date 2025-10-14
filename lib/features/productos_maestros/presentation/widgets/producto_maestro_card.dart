import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/widgets/articulos_derivados_badge.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/widgets/catalogos_inactivos_badge.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/status_badge.dart';

class ProductoMaestroCard extends StatefulWidget {
  final ProductoMaestroModel producto;

  const ProductoMaestroCard({super.key, required this.producto});

  @override
  State<ProductoMaestroCard> createState() => _ProductoMaestroCardState();
}

class _ProductoMaestroCardState extends State<ProductoMaestroCard>
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
              child: InkWell(
                onTap: () => context.push('/producto-maestro-detail', extra: widget.producto.id),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: isDesktop
                      ? _buildDesktopLayout(context, theme)
                      : _buildMobileLayout(context, theme),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme) {
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
                Icons.inventory_2_outlined,
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
                    widget.producto.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Sistema: ${widget.producto.sistemaTallaNombre}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        if (widget.producto.descripcion != null && widget.producto.descripcion!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.producto.descripcion!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 8),

        Row(
          children: [
            StatusBadge(activo: widget.producto.activo),

            const SizedBox(width: 8),

            ArticulosDerivadosBadge(
              articulosActivos: widget.producto.articulosActivos,
              articulosTotales: widget.producto.articulosTotales,
            ),

            if (widget.producto.tieneCatalogosInactivos) ...[
              const SizedBox(width: 6),
              const CatalogosInactivosBadge(),
            ],

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
                    widget.producto.activo ? Icons.toggle_on : Icons.toggle_off,
                  ),
                  tooltip: widget.producto.activo ? 'Desactivar' : 'Reactivar',
                  color: widget.producto.activo
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF9CA3AF),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: widget.producto.activo ? _handleDeactivate : _handleReactivate,
                ),

                if (widget.producto.articulosTotales == 0)
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
    return Column(
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
                Icons.inventory_2_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.producto.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Sistema: ${widget.producto.sistemaTallaNombre}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            StatusBadge(activo: widget.producto.activo),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ArticulosDerivadosBadge(
                  articulosActivos: widget.producto.articulosActivos,
                  articulosTotales: widget.producto.articulosTotales,
                ),
                if (widget.producto.tieneCatalogosInactivos) ...[
                  const SizedBox(width: 8),
                  const CatalogosInactivosBadge(),
                ],
              ],
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
                  icon: Icon(
                    widget.producto.activo ? Icons.toggle_on : Icons.toggle_off,
                  ),
                  color: widget.producto.activo
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF9CA3AF),
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: widget.producto.activo ? _handleDeactivate : _handleReactivate,
                ),
                if (widget.producto.articulosTotales == 0)
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

  void _handleEdit() {
    context.push('/producto-maestro-form', extra: {
      'mode': 'edit',
      'productoId': widget.producto.id,
      'producto': {
        'marcaId': widget.producto.marcaId,
        'materialId': widget.producto.materialId,
        'tipoId': widget.producto.tipoId,
        'sistemaTallaId': widget.producto.sistemaTallaId,
        'descripcion': widget.producto.descripcion,
      },
      'articulosTotales': widget.producto.articulosTotales,
    });
  }

  void _handleDeactivate() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Desactivar producto?'),
        content: widget.producto.articulosActivos > 0
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¿Deseas desactivar "${widget.producto.nombreCompleto}"?'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Este producto tiene ${widget.producto.articulosActivos} artículo${widget.producto.articulosActivos == 1 ? '' : 's'} activo${widget.producto.articulosActivos == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF856404)),
                    ),
                  ),
                ],
              )
            : Text('¿Deseas desactivar "${widget.producto.nombreCompleto}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProductoMaestroBloc>().add(DesactivarProductoMaestroEvent(
                    productoId: widget.producto.id,
                    desactivarArticulos: false,
                  ));
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
        title: const Text('¿Reactivar producto?'),
        content: Text('¿Deseas reactivar "${widget.producto.nombreCompleto}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProductoMaestroBloc>().add(ReactivarProductoMaestroEvent(productoId: widget.producto.id));
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
        title: const Text('¿Eliminar producto?'),
        content: Text('¿Estás seguro de eliminar permanentemente "${widget.producto.nombreCompleto}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProductoMaestroBloc>().add(EliminarProductoMaestroEvent(productoId: widget.producto.id));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
