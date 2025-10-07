import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Modal de detalles del material (CA-012)
///
/// Especificaciones:
/// - Información completa: nombre, descripción, código, estado
/// - Estadísticas de uso: cantidad de productos (RN-002-010)
/// - Fechas de creación y última modificación
/// - Lista de productos asociados (si existen)
class MaterialDetailModal extends StatelessWidget {
  final Map<String, dynamic> materialDetail; // Recibe detail completo del RPC

  const MaterialDetailModal({
    Key? key,
    required this.materialDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    // Extraer datos del detalle
    final nombre = materialDetail['nombre'] as String? ?? 'Material';
    final codigo = materialDetail['codigo'] as String? ?? 'N/A';
    final descripcion = materialDetail['descripcion'] as String?;
    final activo = materialDetail['activo'] as bool? ?? false;
    final createdAt = materialDetail['created_at'] != null
        ? DateTime.parse(materialDetail['created_at'] as String)
        : null;
    final updatedAt = materialDetail['updated_at'] != null
        ? DateTime.parse(materialDetail['updated_at'] as String)
        : null;
    final estadisticas = materialDetail['estadisticas'] as Map<String, dynamic>?;
    final productosCount = estadisticas?['productos_count'] as int? ?? 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.texture,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Código: $codigo',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Estado
                    _buildInfoRow(
                      'Estado:',
                      activo ? 'Activo' : 'Inactivo',
                      icon: Icons.toggle_on,
                      valueColor: activo
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF9CA3AF),
                    ),

                    const SizedBox(height: 16),

                    // Descripción (CA-012)
                    if (descripcion != null && descripcion.isNotEmpty) ...[
                      _buildSectionTitle('Descripción'),
                      const SizedBox(height: 8),
                      Text(
                        descripcion,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Estadísticas de uso (RN-002-010, CA-012)
                    _buildSectionTitle('Estadísticas de Uso'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            color: theme.colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$productosCount',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'Producto${productosCount == 1 ? '' : 's'} asociado${productosCount == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Fechas (CA-012)
                    _buildSectionTitle('Información de Registro'),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Creado:',
                      _formatDate(createdAt),
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Última modificación:',
                      _formatDate(updatedAt),
                      icon: Icons.update,
                    ),

                    const SizedBox(height: 20),

                    // Lista de productos (CA-012)
                    if (productosCount > 0) ...[
                      _buildSectionTitle('Productos que usan este material'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info,
                              size: 48,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Implementación pendiente',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Requiere implementación de relación con productos',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF9CA3AF),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.info,
                              color: Color(0xFFFFC107),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Sin productos asociados',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
