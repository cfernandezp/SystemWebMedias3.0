import 'package:flutter/material.dart';

class CatalogosInactivosBadge extends StatelessWidget {
  const CatalogosInactivosBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.warning, size: 14, color: Color(0xFFFF9800)),
          SizedBox(width: 4),
          Text(
            'Catálogos inactivos',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }
}
