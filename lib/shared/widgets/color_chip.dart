import 'package:flutter/material.dart';
import 'package:system_web_medias/core/theme/design_tokens.dart';

class ColorChip extends StatelessWidget {
  final String colorId;
  final String colorName;
  final List<String> hexCodes;

  const ColorChip({
    super.key,
    required this.colorId,
    required this.colorName,
    required this.hexCodes,
  });

  Color _parseHexColor(String hexCode) {
    final hex = hexCode.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DesignColors.backgroundLight,
        border: Border.all(color: DesignColors.border),
        borderRadius: BorderRadius.circular(DesignRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...hexCodes.map((hexCode) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _parseHexColor(hexCode),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DesignColors.border,
                    width: 1,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 4),
          Text(
            colorName,
            style: TextStyle(
              fontSize: DesignTypography.fontSm,
              color: DesignColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
