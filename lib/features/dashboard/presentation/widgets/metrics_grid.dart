import 'package:flutter/material.dart';
import 'package:system_web_medias/shared/design_system/atoms/metric_card.dart';
import 'package:system_web_medias/shared/design_system/atoms/trend_indicator.dart';

/// MetricCardData
///
/// Modelo de datos para MetricCard
class MetricCardData {
  final IconData icon;
  final String titulo;
  final String valor;
  final String? subtitulo;
  final double? tendenciaPorcentaje;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const MetricCardData({
    required this.icon,
    required this.titulo,
    required this.valor,
    this.subtitulo,
    this.tendenciaPorcentaje,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
  });
}

/// MetricsGrid (Molecule)
///
/// Grid responsive de MetricCards.
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Layout responsive:
/// - Desktop (>= 1200px): 3 columnas
/// - Tablet (768-1199px): 2 columnas
/// - Mobile (< 768px): 1 columna
class MetricsGrid extends StatelessWidget {
  final List<MetricCardData> metricas;
  final bool isLoading;

  const MetricsGrid({
    Key? key,
    required this.metricas,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: isLoading ? 4 : metricas.length,
          itemBuilder: (context, index) {
            if (isLoading) {
              return const MetricCard(
                icon: Icons.insights,
                titulo: 'Loading...',
                valor: '...',
                isLoading: true,
              );
            }

            final metrica = metricas[index];
            return MetricCard(
              icon: metrica.icon,
              titulo: metrica.titulo,
              valor: metrica.valor,
              subtitulo: metrica.subtitulo,
              tendencia: metrica.tendenciaPorcentaje != null
                  ? TrendIndicator.fromPorcentaje(metrica.tendenciaPorcentaje!)
                  : null,
              onTap: metrica.onTap,
              backgroundColor: metrica.backgroundColor,
              iconColor: metrica.iconColor,
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) {
      return 3; // Desktop
    } else if (width >= 768) {
      return 2; // Tablet
    } else {
      return 1; // Mobile
    }
  }
}
