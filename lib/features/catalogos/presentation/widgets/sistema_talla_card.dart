import 'package:flutter/material.dart';
import 'status_badge.dart';

/// Card visual para mostrar sistema de tallas en lista
///
/// Especificaciones:
/// - Nombre, tipo, descripción, estado
/// - Badge de color según tipo de sistema
/// - Botones: Ver Detalle, Editar, Activar/Desactivar
/// - Contador de valores configurados
class SistemaTallaCard extends StatelessWidget {
  final String nombre;
  final String tipoSistema;
  final String? descripcion;
  final bool activo;
  final int valoresCount;
  final int productosCount;
  final VoidCallback onViewDetail;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  const SistemaTallaCard({
    Key? key,
    required this.nombre,
    required this.tipoSistema,
    this.descripcion,
    required this.activo,
    required this.valoresCount,
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
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _getIconForTipo(tipoSistema),
                    color: _getColorForTipo(tipoSistema),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
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
                            _buildTipoBadge(),
                            const SizedBox(width: 8),
                            StatusBadge(activo: activo),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (descripcion != null && descripcion!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    descripcion!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.straighten,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$valoresCount valor${valoresCount != 1 ? 'es' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

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
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: onViewDetail,
                        tooltip: 'Ver Detalle',
                        color: theme.colorScheme.primary,
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

  Widget _buildTipoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getColorForTipo(tipoSistema).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tipoSistema,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getColorForTipo(tipoSistema),
        ),
      ),
    );
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'UNICA':
        return Icons.person;
      case 'NUMERO':
        return Icons.numbers;
      case 'LETRA':
        return Icons.text_fields;
      case 'RANGO':
        return Icons.straighten;
      default:
        return Icons.category;
    }
  }

  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'UNICA':
        return const Color.fromRGBO(156, 39, 176, 1);
      case 'NUMERO':
        return const Color.fromRGBO(33, 150, 243, 1);
      case 'LETRA':
        return const Color.fromRGBO(255, 152, 0, 1);
      case 'RANGO':
        return const Color.fromRGBO(76, 175, 80, 1);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
