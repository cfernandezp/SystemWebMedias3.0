import 'package:flutter/material.dart';

/// TrendIndicator (Atom)
///
/// Indicador visual de tendencia (crecimiento/decrecimiento).
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Cumple RN-002: Cálculo de Tendencias y Comparativas
///
/// Colores según tendencia:
/// - Verde: >= +5% (TrendType.up)
/// - Rojo: <= -5% (TrendType.down)
/// - Gris: Entre -5% y +5% (TrendType.neutral)
enum TrendType {
  up,      // Verde, flecha arriba
  down,    // Rojo, flecha abajo
  neutral, // Gris, sin flecha
}

class TrendIndicator extends StatelessWidget {
  final double porcentaje;
  final TrendType tipo;
  final bool mostrarIcono;

  const TrendIndicator({
    Key? key,
    required this.porcentaje,
    required this.tipo,
    this.mostrarIcono = true,
  }) : super(key: key);

  /// Factory constructor que calcula automáticamente el tipo según RN-002
  ///
  /// Lógica de negocio:
  /// - >= +5% → TrendType.up (verde)
  /// - <= -5% → TrendType.down (rojo)
  /// - Entre -5% y +5% → TrendType.neutral (gris)
  factory TrendIndicator.fromPorcentaje(
    double porcentaje, {
    bool mostrarIcono = true,
  }) {
    final tipo = _calcularTipo(porcentaje);
    return TrendIndicator(
      porcentaje: porcentaje,
      tipo: tipo,
      mostrarIcono: mostrarIcono,
    );
  }

  static TrendType _calcularTipo(double porcentaje) {
    if (porcentaje >= 5.0) return TrendType.up;
    if (porcentaje <= -5.0) return TrendType.down;
    return TrendType.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(theme);
    final icon = _getIcon();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mostrarIcono && icon != null)
          Icon(
            icon,
            size: 16,
            color: color,
          ),
        if (mostrarIcono && icon != null) const SizedBox(width: 4),
        Text(
          _formatPorcentaje(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Color _getColor(ThemeData theme) {
    switch (tipo) {
      case TrendType.up:
        return const Color(0xFF4CAF50); // DesignColors.success
      case TrendType.down:
        return const Color(0xFFF44336); // DesignColors.error
      case TrendType.neutral:
        return const Color(0xFF6B7280); // DesignColors.textSecondary
    }
  }

  IconData? _getIcon() {
    switch (tipo) {
      case TrendType.up:
        return Icons.arrow_upward;
      case TrendType.down:
        return Icons.arrow_downward;
      case TrendType.neutral:
        return Icons.circle;
    }
  }

  String _formatPorcentaje() {
    final sign = porcentaje >= 0 ? '+' : '';
    return '$sign${porcentaje.toStringAsFixed(1)}%';
  }
}
