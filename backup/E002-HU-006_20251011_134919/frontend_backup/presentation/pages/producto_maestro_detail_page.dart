import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductoMaestroDetailPage extends StatelessWidget {
  final Map<String, dynamic>? extra;

  const ProductoMaestroDetailPage({Key? key, this.extra}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productoId = extra?['productoId'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Producto Maestro'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            const Text(
              'Página en construcción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Producto ID: ${productoId ?? "N/A"}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
