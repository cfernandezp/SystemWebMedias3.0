import 'package:equatable/equatable.dart';

/// Datos de gráfico de ventas mensuales
class SalesChartData extends Equatable {
  final String mes;          // ← "2025-10" (formato YYYY-MM)
  final double ventas;       // ← monto total de ventas del mes

  const SalesChartData({
    required this.mes,
    required this.ventas,
  });

  /// Convierte mes string a DateTime para ordenamiento
  DateTime get mesDateTime => DateTime.parse('$mes-01');

  /// Formatea mes para mostrar en UI ("Oct 2025")
  String get mesFormateado {
    final fecha = mesDateTime;
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  List<Object?> get props => [mes, ventas];
}
