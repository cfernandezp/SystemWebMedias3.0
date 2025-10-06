import 'package:system_web_medias/features/menu/domain/entities/menu_option.dart';

/// Model que extiende Entity y agrega serialización JSON
/// Mapea la respuesta de get_menu_options() desde PostgreSQL
class MenuOptionModel extends MenuOption {
  const MenuOptionModel({
    required super.id,
    required super.label,
    super.icon,
    super.route,
    super.children,
  });

  /// Factory: Desde JSON del backend (mapping recursivo)
  factory MenuOptionModel.fromJson(Map<String, dynamic> json) {
    return MenuOptionModel(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String?,
      route: json['route'] as String?,
      children: json['children'] != null
          ? (json['children'] as List)
              .map((child) => MenuOptionModel.fromJson(child as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Convertir a JSON (para almacenamiento local si es necesario)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': icon,
      'route': route,
      'children': children?.map((child) => (child as MenuOptionModel).toJson()).toList(),
    };
  }

  /// Helper: Convertir lista de MenuOptionModel a lista de MenuOption (entities)
  static List<MenuOption> toEntityList(List<MenuOptionModel> models) {
    return models.map((model) => model as MenuOption).toList();
  }

  /// CopyWith para inmutabilidad
  MenuOptionModel copyWith({
    String? id,
    String? label,
    String? icon,
    String? route,
    List<MenuOption>? children,
  }) {
    return MenuOptionModel(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      children: children ?? this.children,
    );
  }
}