import 'package:system_web_medias/features/navigation/domain/entities/breadcrumb.dart';

/// Model que extiende Entity y agrega serialización
/// Representa un ítem individual en el breadcrumb trail
class BreadcrumbModel extends Breadcrumb {
  const BreadcrumbModel({
    required super.label,
    super.route,
  });

  /// Factory: Desde Map
  factory BreadcrumbModel.fromMap(Map<String, String?> map) {
    return BreadcrumbModel(
      label: map['label']!,
      route: map['route'],
    );
  }

  /// Convertir a Map
  Map<String, String?> toMap() {
    return {
      'label': label,
      'route': route,
    };
  }

  /// CopyWith para inmutabilidad
  BreadcrumbModel copyWith({
    String? label,
    String? route,
  }) {
    return BreadcrumbModel(
      label: label ?? this.label,
      route: route ?? this.route,
    );
  }
}