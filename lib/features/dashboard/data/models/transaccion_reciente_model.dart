import 'package:system_web_medias/features/dashboard/domain/entities/transaccion_reciente.dart';

class TransaccionRecienteModel extends TransaccionReciente {
  const TransaccionRecienteModel({
    required super.ventaId,
    required super.fechaVenta,
    required super.montoTotal,
    required super.estado,
    super.clienteNombre,
    required super.vendedorNombre,
  });

  factory TransaccionRecienteModel.fromJson(Map<String, dynamic> json) {
    return TransaccionRecienteModel(
      ventaId: json['venta_id'] as String,
      fechaVenta: DateTime.parse(json['fecha_venta'] as String),
      montoTotal: (json['monto_total'] as num).toDouble(),
      estado: json['estado'] as String,
      clienteNombre: json['cliente_nombre'] as String?,
      vendedorNombre: json['vendedor_nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'venta_id': ventaId,
      'fecha_venta': fechaVenta.toIso8601String(),
      'monto_total': montoTotal,
      'estado': estado,
      'cliente_nombre': clienteNombre,
      'vendedor_nombre': vendedorNombre,
    };
  }
}
