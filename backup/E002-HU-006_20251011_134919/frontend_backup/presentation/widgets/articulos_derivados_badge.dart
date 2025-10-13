import 'package:flutter/material.dart';

class ArticulosDerivadosBadge extends StatelessWidget {
  final int articulosActivos;
  final int articulosTotales;

  const ArticulosDerivadosBadge({
    Key? key,
    required this.articulosActivos,
    required this.articulosTotales,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (articulosTotales == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.new_releases, size: 14, color: Color(0xFF4CAF50)),
            SizedBox(width: 4),
            Text(
              'Nuevo',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      );
    }

    if (articulosActivos > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2, size: 14, color: Color(0xFF2196F3)),
            const SizedBox(width: 4),
            Text(
              '$articulosActivos artículo${articulosActivos != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF9CA3AF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 4),
          Text(
            '0 activos ($articulosTotales inactivos)',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
