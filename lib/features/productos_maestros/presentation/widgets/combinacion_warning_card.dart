import 'package:flutter/material.dart';

class CombinacionWarningCard extends StatelessWidget {
  final List<String> warnings;

  const CombinacionWarningCard({Key? key, required this.warnings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE69C), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: Color(0xFF856404), size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ADVERTENCIA - Combinación poco común',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF856404)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...warnings.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF856404))),
                    Expanded(child: Text(w, style: const TextStyle(fontSize: 13, color: Color(0xFF856404)))),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          const Text(
            'Esta validación NO impide guardar el producto. Puedes confirmar si la combinación es intencional.',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF856404)),
          ),
        ],
      ),
    );
  }
}
