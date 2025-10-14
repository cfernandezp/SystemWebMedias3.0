import 'package:flutter/material.dart';

class CatalogosInactivosBadge extends StatelessWidget {
  const CatalogosInactivosBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800), size: 12),
          SizedBox(width: 3),
          Text(
            'Inactivos',
            style: TextStyle(color: Color(0xFFE65100), fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
