import 'package:flutter/material.dart';

/// MetaProgressBar (Atom)
///
/// Barra de progreso para meta mensual (solo Gerente).
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Cumple RN-007: Meta Mensual y Progreso
///
/// Colores según indicador:
/// - Verde: >= 100% (meta cumplida)
/// - Amarillo: 50-99% (en progreso)
/// - Rojo: < 50% y día > 20 del mes (riesgo)
enum MetaIndicator {
  cumplida,    // Verde >= 100%
  enProgreso,  // Amarillo 50-99%
  critica,     // Rojo < 50% y día > 20
}

class MetaProgressBar extends StatelessWidget {
  final double progreso; // 0-100+ (puede ser > 100)
  final double metaMensual;
  final double ventasActuales;
  final MetaIndicator indicador;

  const MetaProgressBar({
    Key? key,
    required this.progreso,
    required this.metaMensual,
    required this.ventasActuales,
    required this.indicador,
  }) : super(key: key);

  /// Factory constructor que calcula automáticamente el indicador según RN-007
  ///
  /// Lógica de negocio:
  /// - >= 100% → MetaIndicator.cumplida (verde)
  /// - 50-99% → MetaIndicator.enProgreso (amarillo)
  /// - < 50% y día > 20 → MetaIndicator.critica (rojo)
  factory MetaProgressBar.fromVentas({
    required double metaMensual,
    required double ventasActuales,
  }) {
    final progreso = (ventasActuales / metaMensual) * 100;
    final diaActual = DateTime.now().day;

    final MetaIndicator indicador;
    if (progreso >= 100) {
      indicador = MetaIndicator.cumplida;
    } else if (progreso >= 50) {
      indicador = MetaIndicator.enProgreso;
    } else if (diaActual > 20) {
      indicador = MetaIndicator.critica;
    } else {
      indicador = MetaIndicator.enProgreso;
    }

    return MetaProgressBar(
      progreso: progreso,
      metaMensual: metaMensual,
      ventasActuales: ventasActuales,
      indicador: indicador,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meta Mensual',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${progreso.toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_formatMonto(ventasActuales)} / \$${_formatMonto(metaMensual)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              tween: Tween<double>(
                begin: 0,
                end: (progreso / 100).clamp(0.0, 1.0),
              ),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE5E7EB), // Gris claro
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                );
              },
            ),
          ),
          if (indicador == MetaIndicator.critica) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  'Riesgo: Meta en peligro',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getColor() {
    switch (indicador) {
      case MetaIndicator.cumplida:
        return const Color(0xFF4CAF50); // Verde
      case MetaIndicator.enProgreso:
        return const Color(0xFFFF9800); // Amarillo/Naranja
      case MetaIndicator.critica:
        return const Color(0xFFF44336); // Rojo
    }
  }

  String _formatMonto(double monto) {
    if (monto >= 1000000) {
      return '${(monto / 1000000).toStringAsFixed(1)}M';
    } else if (monto >= 1000) {
      return '${(monto / 1000).toStringAsFixed(0)}K';
    } else {
      return monto.toStringAsFixed(0);
    }
  }
}
