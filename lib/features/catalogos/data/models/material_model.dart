import 'package:equatable/equatable.dart';

/// Modelo de Material del sistema.
///
/// Implementa E002-HU-002 (Gestionar Catálogo de Materiales).
/// Cumple RN-002-001: Código único de 3 letras A-Z mayúsculas.
/// Cumple RN-002-002: Nombre único max 50 caracteres.
/// Cumple RN-002-003: Descripción opcional max 200 caracteres.
///
/// Mapping BD ↔ Dart:
/// - `descripcion` → `descripcion`
/// - `codigo` → `codigo`
/// - `activo` → `activo`
/// - `created_at` → `createdAt`
/// - `updated_at` → `updatedAt`
/// - `productos_count` → `productosCount`
class MaterialModel extends Equatable {
  final String id;
  final String nombre;
  final String? descripcion;
  final String codigo;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? productosCount;

  const MaterialModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.codigo,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.productosCount,
  });

  /// Crea MaterialModel desde JSON (snake_case → camelCase)
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      codigo: json['codigo'] as String,
      activo: json['activo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String), // ⭐ snake_case → camelCase
      updatedAt: DateTime.parse(json['updated_at'] as String), // ⭐ snake_case → camelCase
      productosCount: json['productos_count'] as int?,         // ⭐ snake_case → camelCase (opcional)
    );
  }

  /// Convierte MaterialModel a JSON (camelCase → snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'codigo': codigo,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),     // ⭐ camelCase → snake_case
      'updated_at': updatedAt.toIso8601String(),     // ⭐ camelCase → snake_case
      if (productosCount != null)
        'productos_count': productosCount,           // ⭐ camelCase → snake_case
    };
  }

  /// Crea copia con campos actualizados
  MaterialModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? codigo,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? productosCount,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      codigo: codigo ?? this.codigo,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productosCount: productosCount ?? this.productosCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        codigo,
        activo,
        createdAt,
        updatedAt,
        productosCount,
      ];

  @override
  String toString() => 'MaterialModel(id: $id, nombre: $nombre, codigo: $codigo, activo: $activo)';
}
