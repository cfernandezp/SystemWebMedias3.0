import 'package:equatable/equatable.dart';

/// Modelo de Tipo del sistema.
///
/// Implementa E002-HU-003 (Gestionar Catálogo de Tipos).
/// Cumple RN-003-001: Código único de 3 letras A-Z mayúsculas.
/// Cumple RN-003-002: Nombre único max 50 caracteres.
/// Cumple RN-003-003: Descripción e imagen opcionales max 200 caracteres.
/// Cumple RN-003-004: Código inmutable (no se puede modificar).
///
/// Mapping BD ↔ Dart:
/// - `descripcion` → `descripcion`
/// - `codigo` → `codigo`
/// - `imagen_url` → `imagenUrl`
/// - `activo` → `activo`
/// - `created_at` → `createdAt`
/// - `updated_at` → `updatedAt`
/// - `productos_count` → `productosCount`
class TipoModel extends Equatable {
  final String id;
  final String nombre;
  final String? descripcion;
  final String codigo;
  final String? imagenUrl;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? productosCount;

  const TipoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.codigo,
    this.imagenUrl,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.productosCount,
  });

  /// Crea TipoModel desde JSON (snake_case → camelCase)
  factory TipoModel.fromJson(Map<String, dynamic> json) {
    return TipoModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      codigo: json['codigo'] as String,
      imagenUrl: json['imagen_url'] as String?,                // ⭐ snake_case → camelCase
      activo: json['activo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String), // ⭐ snake_case → camelCase
      updatedAt: DateTime.parse(json['updated_at'] as String), // ⭐ snake_case → camelCase
      productosCount: json['productos_count'] as int?,         // ⭐ snake_case → camelCase (opcional)
    );
  }

  /// Convierte TipoModel a JSON (camelCase → snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'codigo': codigo,
      'imagen_url': imagenUrl,                             // ⭐ camelCase → snake_case
      'activo': activo,
      'created_at': createdAt.toIso8601String(),           // ⭐ camelCase → snake_case
      'updated_at': updatedAt.toIso8601String(),           // ⭐ camelCase → snake_case
      if (productosCount != null)
        'productos_count': productosCount,                 // ⭐ camelCase → snake_case
    };
  }

  /// Crea copia con campos actualizados
  TipoModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? codigo,
    String? imagenUrl,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? productosCount,
  }) {
    return TipoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      codigo: codigo ?? this.codigo,
      imagenUrl: imagenUrl ?? this.imagenUrl,
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
        imagenUrl,
        activo,
        createdAt,
        updatedAt,
        productosCount,
      ];

  @override
  String toString() => 'TipoModel(id: $id, nombre: $nombre, codigo: $codigo, activo: $activo)';
}
