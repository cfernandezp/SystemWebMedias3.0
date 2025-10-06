import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/menu/domain/entities/menu_option.dart';

/// Estados del MenuBloc
abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MenuInitial extends MenuState {}

/// Estado: Cargando menú
class MenuLoading extends MenuState {}

/// Estado: Menú cargado exitosamente
class MenuLoaded extends MenuState {
  final List<MenuOption> menuOptions;
  final bool sidebarCollapsed;

  const MenuLoaded({
    required this.menuOptions,
    required this.sidebarCollapsed,
  });

  @override
  List<Object?> get props => [menuOptions, sidebarCollapsed];

  /// CopyWith para actualizar sidebar sin recargar menú
  MenuLoaded copyWith({
    List<MenuOption>? menuOptions,
    bool? sidebarCollapsed,
  }) {
    return MenuLoaded(
      menuOptions: menuOptions ?? this.menuOptions,
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
    );
  }
}

/// Estado: Error al cargar menú
class MenuError extends MenuState {
  final String message;

  const MenuError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado: Actualizando preferencia de sidebar
class SidebarUpdating extends MenuState {
  final List<MenuOption> menuOptions;
  final bool currentCollapsed;

  const SidebarUpdating({
    required this.menuOptions,
    required this.currentCollapsed,
  });

  @override
  List<Object?> get props => [menuOptions, currentCollapsed];
}
