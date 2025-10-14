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
    final theme = Theme.of(context);
    Color bgColor;
    Color iconColor;
    String text;

    if (articulosTotales == 0) {
      bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.1);
      iconColor = const Color(0xFF4CAF50);
      text = 'Nuevo';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(color: iconColor, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );
    } else if (articulosActivos > 0) {
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.1);
      iconColor = theme.colorScheme.primary;
      text = '$articulosActivos/$articulosTotales';
    } else {
      bgColor = const Color(0xFF9CA3AF).withValues(alpha: 0.1);
      iconColor = const Color(0xFF9CA3AF);
      text = '0/$articulosTotales';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: iconColor),
          ),
        ],
      ),
    );
  }
}
