import 'package:flutter/material.dart';

class ColorPreviewCircle extends StatelessWidget {
  final List<String> codigosHex;
  final double size;
  final bool showBorder;

  const ColorPreviewCircle({
    Key? key,
    required this.codigosHex,
    this.size = 40,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (codigosHex.length == 1) {
      return _buildSingleColor();
    }

    return _buildMultipleColors();
  }

  Widget _buildSingleColor() {
    final color = _parseColor(codigosHex[0]);
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

  Widget _buildMultipleColors() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.5),
        child: Row(
          children: codigosHex.asMap().entries.map((entry) {
            final hex = entry.value;

            return Expanded(
              child: Container(
                color: _parseColor(hex),
              ),
            );
          }).toList(),
        ),
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
