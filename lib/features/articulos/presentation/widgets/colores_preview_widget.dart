import 'package:flutter/material.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';

class ColoresPreviewWidget extends StatelessWidget {
  final List<ColorModel> colores;
  final String tipoColoracion;
  final double size;

  const ColoresPreviewWidget({
    Key? key,
    required this.colores,
    required this.tipoColoracion,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (colores.isEmpty) return const SizedBox.shrink();

    if (tipoColoracion == 'unicolor' && colores.length == 1) {
      return _buildCirculo(colores[0].codigosHex);
    }

    return _buildRectanguloMultiple();
  }

  Widget _buildCirculo(List<String> codigosHex) {
    final color = _parseColor(codigosHex.isNotEmpty ? codigosHex[0] : '#CCCCCC');
    final needsBorder = _isLightColor(color);

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

  Widget _buildRectanguloMultiple() {
    return Container(
      width: size * 1.5,
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
          children: colores.map((color) {
            final hex = color.codigosHex.isNotEmpty ? color.codigosHex[0] : '#CCCCCC';
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