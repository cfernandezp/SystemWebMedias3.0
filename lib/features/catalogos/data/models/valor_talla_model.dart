import 'package:equatable/equatable.dart';

/// Modelo de Valor de Talla del sistema.
///
/// Implementa E002-HU-004 (Gestionar Sistemas de Tallas).
/// Cumple RN-004-03: Formato de valor según tipo.
/// Cumple RN-004-04: No duplicidad de valores.
/// Cumple RN-004-10: Ordenamiento de valores.
///
/// Mapping BD ↔ Dart:
/// - `sistema_talla_id` → `sistemaTallaId`
/// - `valor` → `valor`
/// - `orden` → `orden`
/// - `activo` → `activo`
/// - `productos_count` → `productosCount`
/// - `created_at` → `createdAt`
/// - `updated_at` → `updatedAt`
class ValorTallaModel extends Equatable {
  final String id;
  final String sistemaTallaId;
  final String valor;
  final int orden;
  final bool activo;
  final int productosCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ValorTallaModel({
    required this.id,
    required this.sistemaTallaId,
    required this.valor,
    required this.orden,
    required this.activo,
    required this.productosCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea ValorTallaModel desde JSON (snake_case → camelCase)
  factory ValorTallaModel.fromJson(Map<String, dynamic> json) {
    return ValorTallaModel(
      id: json['id'] as String,
      sistemaTallaId: json['sistema_talla_id'] as String? ?? '',   // ⭐ snake_case → camelCase
      valor: json['valor'] as String,
      orden: json['orden'] as int,
      activo: json['activo'] as bool? ?? true,
      productosCount: json['productos_count'] as int? ?? 0,        // ⭐ snake_case → camelCase
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),                                         // ⭐ snake_case → camelCase
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),                                         // ⭐ snake_case → camelCase
    );
  }

  /// Convierte ValorTallaModel a JSON (camelCase → snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sistema_talla_id': sistemaTallaId,                       // ⭐ camelCase → snake_case
      'valor': valor,
      'orden': orden,
      'activo': activo,
      'productos_count': productosCount,                        // ⭐ camelCase → snake_case
      'created_at': createdAt.toIso8601String(),                // ⭐ camelCase → snake_case
      'updated_at': updatedAt.toIso8601String(),                // ⭐ camelCase → snake_case
    };
  }

  /// Crea copia con campos actualizados
  ValorTallaModel copyWith({
    String? id,
    String? sistemaTallaId,
    String? valor,
    int? orden,
    bool? activo,
    int? productosCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ValorTallaModel(
      id: id ?? this.id,
      sistemaTallaId: sistemaTallaId ?? this.sistemaTallaId,
      valor: valor ?? this.valor,
      orden: orden ?? this.orden,
      activo: activo ?? this.activo,
      productosCount: productosCount ?? this.productosCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sistemaTallaId,
        valor,
        orden,
        activo,
        productosCount,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'ValorTallaModel(id: $id, valor: $valor, orden: $orden, activo: $activo)';
}
