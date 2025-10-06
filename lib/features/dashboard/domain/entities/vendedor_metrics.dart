import 'package:system_web_medias/features/auth/domain/entities/user.dart';
import 'dashboard_metrics.dart';

class VendedorMetrics extends DashboardMetrics {
  final double ventasHoy;
  final double comisionesMes;
  final int ordenesPendientes;
  final int productosStockBajo;

  const VendedorMetrics({
    required this.ventasHoy,
    required this.comisionesMes,
    required this.ordenesPendientes,
    required this.productosStockBajo,
  }) : super(rol: UserRole.vendedor);

  @override
  List<Object?> get props => [rol, ventasHoy, comisionesMes, ordenesPendientes, productosStockBajo];
}
