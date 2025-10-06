import 'package:equatable/equatable.dart';

/// Eventos del MenuBloc
abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Cargar menú del usuario autenticado
class LoadMenuEvent extends MenuEvent {
  final String userId;

  const LoadMenuEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Evento: Toggle estado del sidebar (expandir/colapsar)
class ToggleSidebarEvent extends MenuEvent {
  final String userId;
  final bool collapsed;

  const ToggleSidebarEvent({
    required this.userId,
    required this.collapsed,
  });

  @override
  List<Object?> get props => [userId, collapsed];
}
