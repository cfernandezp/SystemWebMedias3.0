import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/auth/domain/entities/user.dart';

/// Entity base para métricas de dashboard
/// Polimórfica según rol del usuario (Vendedor/Gerente/Admin)
///
/// Implementa E003-HU-001 - RN-001: Segmentación de dashboard por rol
abstract class DashboardMetrics extends Equatable {
  final UserRole rol;

  const DashboardMetrics({required this.rol});

  @override
  List<Object?> get props => [rol];
}
