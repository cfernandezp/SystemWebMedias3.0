import 'package:flutter/material.dart';
import 'trend_indicator.dart';

/// MetricCard (Atom)
///
/// Card individual para mostrar una métrica con icono, título, valor y tendencia.
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Cumple especificaciones en docs/technical/design/components_E003-HU-001.md
///
/// Características:
/// - Theme-aware (usa Theme.of(context))
/// - Animación hover: scale 1.02, elevation 2 → 8
/// - Loading skeleton con shimmer
/// - Navegación mediante onTap (RN-006)
class MetricCard extends StatefulWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  final String? subtitulo;
  final TrendIndicator? tendencia;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isLoading;

  const MetricCard({
    Key? key,
    required this.icon,
    required this.titulo,
    required this.valor,
    this.subtitulo,
    this.tendencia,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isLoading) {
      return _buildLoadingSkeleton(theme);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.diagonal3Values(
          _isHovered ? 1.02 : 1.0,
          _isHovered ? 1.02 : 1.0,
          1.0,
        ),
        child: Material(
          elevation: _isHovered ? 8 : 2,
          borderRadius: BorderRadius.circular(12),
          color: widget.backgroundColor ?? theme.colorScheme.surface,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.icon,
                        size: 24,
                        color: widget.iconColor ?? theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.titulo,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.valor,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (widget.tendencia != null || widget.subtitulo != null)
                    Row(
                      children: [
                        if (widget.tendencia != null) widget.tendencia!,
                        if (widget.tendencia != null && widget.subtitulo != null)
                          const SizedBox(width: 4),
                        if (widget.subtitulo != null)
                          Expanded(
                            child: Text(
                              widget.subtitulo!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 100,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
