import 'package:flutter/material.dart';

/// TopVendedor
///
/// Modelo de datos para un vendedor en el top de ventas
class TopVendedor {
  final String id;
  final String nombreCompleto;
  final double montoVentas;
  final int cantidadTransacciones;
  final int ranking; // 1-5

  const TopVendedor({
    required this.id,
    required this.nombreCompleto,
    required this.montoVentas,
    required this.cantidadTransacciones,
    required this.ranking,
  });
}

/// TopVendedoresList (Molecule)
///
/// Lista de top 5 vendedores del mes.
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Cumple RN-005: Top Vendedores y Productos Más Vendidos
///
/// Características:
/// - Muestra top 5 vendedores
/// - Avatar con iniciales
/// - Badge circular con número de ranking
/// - Monto y número de transacciones
class TopVendedoresList extends StatelessWidget {
  final List<TopVendedor> vendedores;
  final String titulo;

  const TopVendedoresList({
    Key? key,
    required this.vendedores,
    this.titulo = 'Top Vendedores del Mes',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        children: [
          Text(
            titulo,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (vendedores.isEmpty)
            _buildEmptyState(theme)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vendedores.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vendedor = vendedores[index];
                return _buildVendedorItem(vendedor, theme);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVendedorItem(TopVendedor vendedor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Stack(
            children: [
              _buildAvatar(vendedor.nombreCompleto, theme),
              Positioned(
                right: -2,
                bottom: -2,
                child: _buildRankingBadge(vendedor.ranking, theme),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendedor.nombreCompleto,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${vendedor.cantidadTransacciones} transacciones',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${_formatMonto(vendedor.montoVentas)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String nombreCompleto, ThemeData theme) {
    final iniciales = _getIniciales(nombreCompleto);

    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        iniciales,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildRankingBadge(int ranking, ThemeData theme) {
    Color badgeColor;
    switch (ranking) {
      case 1:
        badgeColor = const Color(0xFFFFD700); // Oro
        break;
      case 2:
        badgeColor = const Color(0xFFC0C0C0); // Plata
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32); // Bronce
        break;
      default:
        badgeColor = theme.colorScheme.primaryContainer;
    }

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          ranking.toString(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getIniciales(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(' ');
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
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

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No hay datos disponibles',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
