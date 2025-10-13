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
    Color bgColor;
    String text;
    Color textColor = Colors.white;

    if (articulosTotales == 0) {
      bgColor = const Color(0xFF4CAF50);
      text = 'Nuevo';
    } else if (articulosActivos > 0) {
      bgColor = const Color(0xFF2196F3);
      text = '$articulosActivos artículo${articulosActivos == 1 ? '' : 's'}';
    } else {
      bgColor = const Color(0xFF9CA3AF);
      text = '0 activos ($articulosTotales inactivos)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
