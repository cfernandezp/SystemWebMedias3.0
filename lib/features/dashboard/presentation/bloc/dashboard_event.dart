import 'package:equatable/equatable.dart';

/// Eventos del DashboardBloc
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar dashboard inicial
class LoadDashboard extends DashboardEvent {
  final String userId;

  const LoadDashboard({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento para refrescar dashboard
class RefreshDashboard extends DashboardEvent {
  final String userId;

  const RefreshDashboard({required this.userId});

  @override
  List<Object?> get props => [userId];
}
