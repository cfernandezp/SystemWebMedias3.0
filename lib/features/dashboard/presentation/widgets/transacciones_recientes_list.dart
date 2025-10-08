import 'package:flutter/material.dart';

/// TransaccionReciente
///
/// Modelo de datos para una transacción reciente
class TransaccionReciente {
  final String id;
  final String clienteNombre;
  final String vendedorNombre;
  final double monto;
  final DateTime fecha;
  final TransaccionEstado estado;

  const TransaccionReciente({
    required this.id,
    required this.clienteNombre,
    required this.vendedorNombre,
    required this.monto,
    required this.fecha,
    required this.estado,
  });
}

/// TransaccionEstado
///
/// Estados posibles de una transacción
enum TransaccionEstado {
  completada,
  pendiente,
  cancelada,
}

/// TransaccionesRecientesList (Molecule)
///
/// Lista de últimas 5 transacciones (solo Gerente/Admin).
///
/// Implementa HU E003-HU-001: Dashboard con Métricas
/// Cumple RN-004: Agregación de Métricas en Tiempo Real
///
/// Características:
/// - Muestra últimas 5 transacciones
/// - Avatar con iniciales del cliente
/// - Badge de estado (verde/amarillo/rojo)
/// - Timestamp relativo (Hace 2 horas)
class TransaccionesRecientesList extends StatelessWidget {
  final List<TransaccionReciente> transacciones;
  final String titulo;

  const TransaccionesRecientesList({
    Key? key,
    required this.transacciones,
    this.titulo = 'Transacciones Recientes',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (transacciones.isEmpty)
            _buildEmptyState(theme)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transacciones.length,
              separatorBuilder: (context, index) => Divider(
                height: 24,
                color: theme.colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final transaccion = transacciones[index];
                return _buildTransaccionItem(transaccion, theme);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTransaccionItem(
    TransaccionReciente transaccion,
    ThemeData theme,
  ) {
    return Container(
      height: 72,
      child: Row(
        children: [
          _buildAvatar(transaccion.clienteNombre, theme),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaccion.clienteNombre,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildEstadoBadge(transaccion.estado, theme),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Vendedor: ${transaccion.vendedorNombre}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _getTimeAgo(transaccion.fecha),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$${transaccion.monto.toStringAsFixed(2)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String clienteNombre, ThemeData theme) {
    final iniciales = _getIniciales(clienteNombre);

    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        iniciales,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildEstadoBadge(TransaccionEstado estado, ThemeData theme) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (estado) {
      case TransaccionEstado.completada:
        backgroundColor = const Color.fromRGBO(76, 175, 80, 0.1);
        textColor = const Color(0xFF4CAF50);
        label = 'Completada';
        break;
      case TransaccionEstado.pendiente:
        backgroundColor = const Color.fromRGBO(255, 152, 0, 0.1);
        textColor = const Color(0xFFFF9800);
        label = 'Pendiente';
        break;
      case TransaccionEstado.cancelada:
        backgroundColor = const Color.fromRGBO(244, 67, 54, 0.1);
        textColor = const Color(0xFFF44336);
        label = 'Cancelada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  String _getIniciales(String nombreCompleto) {
    final partes = nombreCompleto.trim().split(' ');
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  String _getTimeAgo(DateTime fecha) {
    final now = DateTime.now();
    final difference = now.difference(fecha);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No hay transacciones recientes',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
