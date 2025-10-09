import 'package:flutter/material.dart';

class ColorPreviewCircle extends StatelessWidget {
  final String codigoHex;
  final double size;
  final bool showBorder;

  const ColorPreviewCircle({
    Key? key,
    required this.codigoHex,
    this.size = 40,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(codigoHex);
    final needsBorder = showBorder && _isLightColor(color);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: needsBorder
            ? Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return const Color(0xFF4ECDC4);
    }
  }

  bool _isLightColor(Color color) {
    final r = (color.r * 255.0).round() & 0xff;
    final g = (color.g * 255.0).round() & 0xff;
    final b = (color.b * 255.0).round() & 0xff;
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance > 0.85;
  }
}
