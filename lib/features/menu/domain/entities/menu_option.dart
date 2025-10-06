import 'package:equatable/equatable.dart';

/// Entity pura de opción de menú con lógica de negocio
/// NO contiene lógica de serialización (eso es responsabilidad del Model)
class MenuOption extends Equatable {
  final String id;
  final String label;
  final String? icon;
  final String? route;
  final List<MenuOption>? children;

  const MenuOption({
    required this.id,
    required this.label,
    this.icon,
    this.route,
    this.children,
  });

  /// Lógica de negocio: Verificar si tiene sub-menús
  bool get hasChildren => children != null && children!.isNotEmpty;

  /// Lógica de negocio: Verificar si es navegable
  bool get isNavigable => route != null && route!.isNotEmpty;

  /// Lógica de negocio: Verificar si es un grupo (tiene children pero no route)
  bool get isGroup => hasChildren && !isNavigable;

  /// Lógica de negocio: Contar total de opciones (incluyendo children)
  int get totalOptions {
    if (!hasChildren) return 1;
    return 1 + children!.fold(0, (sum, child) => sum + child.totalOptions);
  }

  @override
  List<Object?> get props => [id, label, icon, route, children];
}
