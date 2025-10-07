import 'package:flutter/material.dart';

/// Diálogo de confirmación para activar/desactivar material (CA-008)
///
/// Especificaciones:
/// - Mensaje: "¿Estás seguro de desactivar este material?"
/// - Advertencia: "Los productos existentes no se verán afectados" (RN-002-007)
/// - Muestra cantidad de productos asociados (RN-002-007)
/// - Botones: "Confirmar" y "Cancelar"
class MaterialToggleConfirmDialog extends StatelessWidget {
  final bool isActive;
  final int productosCount;
  final VoidCallback onConfirm;

  const MaterialToggleConfirmDialog({
    Key? key,
    required this.isActive,
    required this.productosCount,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Icon(
            isActive ? Icons.warning : Icons.check_circle,
            color: isActive ? const Color(0xFFFFC107) : const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isActive ? '¿Desactivar material?' : '¿Reactivar material?',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mensaje principal
          Text(
            isActive
                ? 'Los productos existentes no se verán afectados'
                : 'El material volverá a estar disponible para nuevos productos',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),

          // Información de productos asociados (RN-002-007, CA-008)
          if (productosCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$productosCount producto${productosCount > 1 ? 's' : ''} asociado${productosCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Nota adicional para desactivación
          if (isActive && productosCount > 0) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(
                  Icons.info,
                  size: 16,
                  color: Color(0xFF2196F3),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Los productos existentes mantendrán su referencia al material',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: isActive
                ? const Color(0xFFF44336)
                : theme.colorScheme.primary,
          ),
          child: Text(isActive ? 'Desactivar' : 'Reactivar'),
        ),
      ],
    );
  }
}
