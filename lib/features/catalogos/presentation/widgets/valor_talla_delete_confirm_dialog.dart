import 'package:flutter/material.dart';

/// Dialog de confirmación para eliminar valor de talla (CA-008)
///
/// Futuro: Implementación completa con lógica de productos
/// Actual: Placeholder básico
class ValorTallaDeleteConfirmDialog extends StatelessWidget {
  final String valor;
  final int productosCount;
  final VoidCallback onConfirm;
  final VoidCallback? onMigrate;

  const ValorTallaDeleteConfirmDialog({
    Key? key,
    required this.valor,
    required this.productosCount,
    required this.onConfirm,
    this.onMigrate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF44336),
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Eliminar valor de talla',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valor: $valor',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          if (productosCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF44336).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Color(0xFFF44336),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Este valor está siendo usado',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$productosCount producto${productosCount != 1 ? 's' : ''} usa${productosCount != 1 ? 'n' : ''} este valor',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nota: Funcionalidad de migración disponible próximamente',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFF6B7280),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF059669),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este valor no está siendo usado',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: productosCount > 0 ? null : onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF44336),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFE5E7EB),
          ),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}
