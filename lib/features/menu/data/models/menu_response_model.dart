import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/menu/data/models/menu_option_model.dart';

/// Modelo de respuesta completa de get_menu_options()
/// Incluye el rol del usuario y el árbol de menú jerárquico
class MenuResponseModel extends Equatable {
  final String role;
  final List<MenuOptionModel> menu;

  const MenuResponseModel({
    required this.role,
    required this.menu,
  });

  /// Factory: Desde JSON del backend
  factory MenuResponseModel.fromJson(Map<String, dynamic> json) {
    return MenuResponseModel(
      role: json['role'] as String,
      menu: (json['menu'] as List)
          .map((item) => MenuOptionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'menu': menu.map((item) => item.toJson()).toList(),
    };
  }

  /// CopyWith para inmutabilidad
  MenuResponseModel copyWith({
    String? role,
    List<MenuOptionModel>? menu,
  }) {
    return MenuResponseModel(
      role: role ?? this.role,
      menu: menu ?? this.menu,
    );
  }

  @override
  List<Object?> get props => [role, menu];
}