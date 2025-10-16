import 'package:flutter/material.dart';
import 'package:system_web_medias/core/theme/design_tokens.dart';

class TipoDocumentoCard extends StatelessWidget {
  final String codigo;
  final String nombre;
  final String formato;
  final int longitudMinima;
  final int longitudMaxima;
  final bool activo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TipoDocumentoCard({
    super.key,
    required this.codigo,
    required this.nombre,
    required this.formato,
    required this.longitudMinima,
    required this.longitudMaxima,
    required this.activo,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.sm),
        side: BorderSide(color: DesignColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        codigo,
                        style: TextStyle(
                          fontSize: DesignTypography.fontLg,
                          fontWeight: DesignTypography.bold,
                          color: DesignColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: DesignSpacing.xs),
                      Text(
                        nombre,
                        style: TextStyle(
                          fontSize: DesignTypography.fontMd,
                          color: DesignColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildEstadoBadge(),
              ],
            ),
            SizedBox(height: DesignSpacing.md),
            Divider(color: DesignColors.border, height: 1),
            SizedBox(height: DesignSpacing.md),
            _buildInfoRow('Formato', formato),
            SizedBox(height: DesignSpacing.sm),
            _buildInfoRow('Longitud', '$longitudMinima - $longitudMaxima'),
            SizedBox(height: DesignSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignColors.primaryTurquoise,
                    side: BorderSide(color: DesignColors.primaryTurquoise),
                  ),
                ),
                SizedBox(width: DesignSpacing.sm),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignColors.error,
                    side: BorderSide(color: DesignColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            color: DesignColors.textSecondary,
            fontWeight: DesignTypography.medium,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            color: DesignColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: activo ? DesignColors.success : DesignColors.disabled,
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: Text(
        activo ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: DesignColors.surface,
          fontSize: DesignTypography.fontXs,
          fontWeight: DesignTypography.medium,
        ),
      ),
    );
  }
}
