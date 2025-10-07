import 'package:flutter/material.dart';

/// Badge visual para estado activo/inactivo
///
/// Especificaciones:
/// - Verde para activo, gris para inactivo
/// - Border radius: 12px
/// - Padding: 6px horizontal, 4px vertical
class StatusBadge extends StatelessWidget {
  final bool activo;

  const StatusBadge({
    Key? key,
    required this.activo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = activo
        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
        : const Color(0xFF9CA3AF).withValues(alpha: 0.1);

    final textColor = activo
        ? const Color(0xFF4CAF50)
        : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: activo ? const Color(0xFF4CAF50) : const Color(0xFF9CA3AF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            activo ? 'Activo' : 'Inactivo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
