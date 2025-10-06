import 'package:equatable/equatable.dart';

/// Entity pura de breadcrumb con lógica de negocio
/// Representa un ítem individual en el breadcrumb trail
class Breadcrumb extends Equatable {
  final String label;
  final String? route;

  const Breadcrumb({
    required this.label,
    this.route,
  });

  /// Lógica de negocio: Verificar si es clickeable
  /// El último breadcrumb (página actual) no es clickeable
  bool get isClickable => route != null && route!.isNotEmpty;

  @override
  List<Object?> get props => [label, route];
}
