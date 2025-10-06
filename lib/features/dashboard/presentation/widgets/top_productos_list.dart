import 'package:flutter/material.dart';

/// TopProducto
///
/// Modelo de datos para un producto en el top de vendidos
class TopProducto {
  final String id;
  final String nombre;
  final int cantidadVendida;
  final int ranking; // 1-5

  const TopProducto({
    required this.id,
    required this.nombre,
    required this.cantidadVendida,
    required this.ranking,
  });
}

/// TopProductosList (Molecule)
///
/// Lista de top 5 productos más vendidos.
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Cumple RN-005: Top Vendedores y Productos Más Vendidos
///
/// Características:
/// - Muestra top 5 productos
/// - Badge circular con número de ranking
/// - Dividers entre items
/// - Item altura: 48px
class TopProductosList extends StatelessWidget {
  final List<TopProducto> productos;
  final String titulo;

  const TopProductosList({
    Key? key,
    required this.productos,
    this.titulo = 'Productos Más Vendidos',
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
          if (productos.isEmpty)
            _buildEmptyState(theme)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productos.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final producto = productos[index];
                return _buildProductoItem(producto, theme);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProductoItem(TopProducto producto, ThemeData theme) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildRankingBadge(producto.ranking, theme),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              producto.nombre,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${producto.cantidadVendida} uds',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
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
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          ranking.toString(),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: ranking <= 3 ? Colors.white : theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
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
