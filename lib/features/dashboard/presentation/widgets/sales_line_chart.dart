import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// SalesChartData
///
/// Modelo de datos para un punto en el gráfico de ventas
class SalesChartData {
  final String mes; // "Oct", "Nov", "Dic", etc.
  final double monto; // Monto de ventas

  const SalesChartData({
    required this.mes,
    required this.monto,
  });
}

/// SalesLineChart (Molecule)
///
/// Gráfico de línea para ventas mensuales (últimos 6 meses).
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Usa fl_chart package para rendering
///
/// Características:
/// - Color línea: primaryTurquoise (#4ECDC4)
/// - Gradient bajo línea: Turquesa con alpha 0.2
/// - Animación: Fade in + slide up (300ms)
/// - Responsive: 250px desktop, 200px mobile
/// - Tooltips interactivos al hover
class SalesLineChart extends StatefulWidget {
  final List<SalesChartData> datos;
  final String titulo;

  const SalesLineChart({
    Key? key,
    required this.datos,
    required this.titulo,
  }) : super(key: key);

  @override
  State<SalesLineChart> createState() => _SalesLineChartState();
}

class _SalesLineChartState extends State<SalesLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final chartHeight = isDesktop ? 250.0 : 200.0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
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
            children: [
              Text(
                widget.titulo,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: chartHeight,
                child: widget.datos.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildChart(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(ThemeData theme) {
    final spots = widget.datos.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.monto);
    }).toList();

    final maxY = widget.datos
        .map((d) => d.monto)
        .reduce((a, b) => a > b ? a : b);
    final minY = widget.datos
        .map((d) => d.monto)
        .reduce((a, b) => a < b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFE5E7EB),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.datos.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.datos[index].mes,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: (maxY - minY) / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatMonto(value),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (widget.datos.length - 1).toDouble(),
        minY: minY * 0.9,
        maxY: maxY * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4ECDC4), // primaryTurquoise
                Color(0xFF26A69A), // primaryDark
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF26A69A), // primaryDark
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4ECDC4).withOpacity(0.2),
                  const Color(0xFF4ECDC4).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final mes = widget.datos[spot.x.toInt()].mes;
                return LineTooltipItem(
                  '$mes\n\$${spot.y.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No hay datos para mostrar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonto(double monto) {
    if (monto >= 1000000) {
      return '\$${(monto / 1000000).toStringAsFixed(1)}M';
    } else if (monto >= 1000) {
      return '\$${(monto / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${monto.toStringAsFixed(0)}';
    }
  }
}
