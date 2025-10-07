import 'package:flutter/material.dart';
import 'status_badge.dart';

/// Card visual para mostrar tipo en lista (CA-001)
///
/// Especificaciones:
/// - Nombre, código, descripción (truncada), estado
/// - Imagen de referencia (si existe)
/// - Botones: Ver Detalle, Editar, Activar/Desactivar
/// - Contador de productos asociados
class TipoCard extends StatelessWidget {
  final String nombre;
  final String? descripcion;
  final String codigo;
  final bool activo;
  final String? imagenUrl;
  final int productosCount;
  final VoidCallback onViewDetail;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  const TipoCard({
    Key? key,
    required this.nombre,
    this.descripcion,
    required this.codigo,
    required this.activo,
    this.imagenUrl,
    required this.productosCount,
    required this.onViewDetail,
    required this.onEdit,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onViewDetail,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Imagen + Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen o icono por defecto
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      image: imagenUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imagenUrl!),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                // Si falla la carga, muestra el icono por defecto
                              },
                            )
                          : null,
                    ),
                    child: imagenUrl == null
                        ? Icon(
                            Icons.checkroom,
                            color: theme.colorScheme.primary,
                            size: 24,
                          )
                        : null,
                  ),

                  const SizedBox(width: 12),

                  // Nombre + Código + Estado
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                codigo,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(activo: activo),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Descripción
              if (descripcion != null && descripcion!.isNotEmpty) ...[
                Text(
                  descripcion!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Footer: Productos + Acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Contador de productos
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$productosCount producto${productosCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Botones de acción
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Editar',
                        color: const Color(0xFF6B7280),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                      IconButton(
                        icon: Icon(
                          activo ? Icons.toggle_on : Icons.toggle_off,
                          size: 24,
                        ),
                        onPressed: onToggleStatus,
                        tooltip: activo ? 'Desactivar' : 'Activar',
                        color: activo
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF9CA3AF),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
