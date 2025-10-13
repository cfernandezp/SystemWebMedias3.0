import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_model.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/widgets/articulos_derivados_badge.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/widgets/catalogos_inactivos_badge.dart';

class ProductoMaestroCard extends StatefulWidget {
  final ProductoMaestroModel producto;

  const ProductoMaestroCard({super.key, required this.producto});

  @override
  State<ProductoMaestroCard> createState() => _ProductoMaestroCardState();
}

class _ProductoMaestroCardState extends State<ProductoMaestroCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => context.push('/producto-maestro-detail', extra: widget.producto.id),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? Theme.of(context).colorScheme.primary : const Color(0xFFE5E7EB),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.producto.nombreCompleto,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _handleEdit();
                          break;
                        case 'deactivate':
                          _handleDeactivate();
                          break;
                        case 'reactivate':
                          _handleReactivate();
                          break;
                        case 'delete':
                          _handleDelete();
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 12), Text('Editar')]),
                      ),
                      PopupMenuItem(
                        value: widget.producto.activo ? 'deactivate' : 'reactivate',
                        child: Row(
                          children: [
                            Icon(widget.producto.activo ? Icons.block : Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 12),
                            Text(widget.producto.activo ? 'Desactivar' : 'Reactivar'),
                          ],
                        ),
                      ),
                      if (widget.producto.articulosTotales == 0)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                'Sistema: ${widget.producto.sistemaTallaNombre}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ArticulosDerivadosBadge(
                    articulosActivos: widget.producto.articulosActivos,
                    articulosTotales: widget.producto.articulosTotales,
                  ),
                  if (widget.producto.tieneCatalogosInactivos) const CatalogosInactivosBadge(),
                ],
              ),
              if (widget.producto.descripcion != null && widget.producto.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  widget.producto.descripcion!,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
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
