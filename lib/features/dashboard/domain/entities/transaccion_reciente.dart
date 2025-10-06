import 'package:equatable/equatable.dart';

/// Transacción reciente para dashboard
class TransaccionReciente extends Equatable {
  final String ventaId;              // ← venta_id
  final DateTime fechaVenta;         // ← fecha_venta
  final double montoTotal;           // ← monto_total
  final String estado;               // ← estado (ENUM como string)
  final String? clienteNombre;       // ← cliente_nombre (nullable)
  final String vendedorNombre;       // ← vendedor_nombre

  const TransaccionReciente({
    required this.ventaId,
    required this.fechaVenta,
    required this.montoTotal,
    required this.estado,
    this.clienteNombre,
    required this.vendedorNombre,
  });

  /// Formatea fecha para mostrar ("Hace 2 horas")
  String get fechaRelativa {
    final diferencia = DateTime.now().difference(fechaVenta);
    if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} horas';
    } else {
      return 'Hace ${diferencia.inDays} días';
    }
  }

  @override
  List<Object?> get props => [
        ventaId,
        fechaVenta,
        montoTotal,
        estado,
        clienteNombre,
        vendedorNombre,
      ];
}
