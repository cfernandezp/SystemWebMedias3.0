import 'package:flutter/material.dart';
import 'package:system_web_medias/core/theme/design_tokens.dart';

class ConfirmEliminarDialog extends StatelessWidget {
  final String nombrePersona;
  final bool hasTransacciones;
  final VoidCallback onConfirm;

  const ConfirmEliminarDialog({
    super.key,
    required this.nombrePersona,
    required this.hasTransacciones,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      title: Row(
        children: [
          Icon(
            hasTransacciones ? Icons.block : Icons.delete,
            color: hasTransacciones ? DesignColors.warning : DesignColors.error,
          ),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Text(
              hasTransacciones ? 'No se puede eliminar' : 'Confirmar Eliminación',
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasTransacciones) ...[
                Container(
                  padding: EdgeInsets.all(DesignSpacing.md),
                  decoration: BoxDecoration(
                    color: DesignColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                    border: Border.all(color: DesignColors.warning),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info, color: DesignColors.warning),
                      SizedBox(width: DesignSpacing.sm),
                      Expanded(
                        child: Text(
                          'Esta persona tiene transacciones registradas en el sistema (ventas, compras o entregas). Solo puede desactivarse, no eliminarse permanentemente.',
                          style: TextStyle(
                            fontSize: DesignTypography.fontSm,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  '¿Estás seguro de eliminar permanentemente a "$nombrePersona"?',
                  style: TextStyle(fontSize: DesignTypography.fontMd),
                ),
                SizedBox(height: DesignSpacing.md),
                Container(
                  padding: EdgeInsets.all(DesignSpacing.md),
                  decoration: BoxDecoration(
                    color: DesignColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                    border: Border.all(color: DesignColors.error),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning, color: DesignColors.error),
                      SizedBox(width: DesignSpacing.sm),
                      Expanded(
                        child: Text(
                          'Esta acción es irreversible. Todos los datos de la persona se eliminarán permanentemente.',
                          style: TextStyle(
                            fontSize: DesignTypography.fontSm,
                            color: DesignColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (hasTransacciones) ...[
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: FilledButton.styleFrom(
              backgroundColor: DesignColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ],
    );
  }
}
