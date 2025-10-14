import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SkuPreviewWidget extends StatelessWidget {
  final String sku;
  final bool esDuplicado;

  const SkuPreviewWidget({
    Key? key,
    required this.sku,
    this.esDuplicado = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esDuplicado
            ? const Color(0xFFFEE2E2)
            : theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: esDuplicado
              ? const Color(0xFFF44336)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                esDuplicado ? Icons.error_outline : Icons.inventory_2_outlined,
                color: esDuplicado ? const Color(0xFFF44336) : theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  esDuplicado ? 'SKU Duplicado' : 'SKU Generado Automáticamente',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: esDuplicado ? const Color(0xFFF44336) : theme.colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copiar SKU',
                color: theme.colorScheme.primary,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: sku));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text('SKU copiado: $sku', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    sku,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (esDuplicado) ...[
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.warning_amber, size: 16, color: Color(0xFFF44336)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Este SKU ya existe. Modifica el orden de colores o selección',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),

          Text(
            'Formato: MARCA-TIPO-MATERIAL-TALLA-COLOR1-COLOR2-COLOR3',
            style: TextStyle(
              fontSize: 11,
              color: esDuplicado ? const Color(0xFFC62828) : const Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}