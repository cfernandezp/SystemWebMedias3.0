import 'package:equatable/equatable.dart';

/// HU-001: Modelo de Marca
///
/// Implementa E002-HU-001 (Gestionar Catálogo de Marcas)
/// Cumple RN-001: Nombre único, máximo 50 caracteres
/// Cumple RN-002: Código inmutable, único, 3 letras mayúsculas
///
/// Mapping BD ↔ Dart (snake_case ↔ camelCase):
/// - `id` ↔ `id`
/// - `nombre` ↔ `nombre`
/// - `codigo` ↔ `codigo`
/// - `activo` ↔ `activo`
/// - `created_at` ↔ `createdAt`
/// - `updated_at` ↔ `updatedAt`
class MarcaModel extends Equatable {
  final String id;
  final String nombre;
  final String codigo;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarcaModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear MarcaModel desde JSON (response de backend)
  ///
  /// Mapping explícito snake_case → camelCase
  factory MarcaModel.fromJson(Map<String, dynamic> json) {
    return MarcaModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      activo: json['activo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String), // snake_case → camelCase
      updatedAt: DateTime.parse(json['updated_at'] as String), // snake_case → camelCase
    );
  }

  /// Convertir MarcaModel a JSON (request a backend)
  ///
  /// Mapping explícito camelCase → snake_case
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'activo': activo,
      'created_at': createdAt.toIso8601String(), // camelCase → snake_case
      'updated_at': updatedAt.toIso8601String(), // camelCase → snake_case
    };
  }

  /// Crear copia con valores modificados
  MarcaModel copyWith({
    String? id,
    String? nombre,
    String? codigo,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarcaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, nombre, codigo, activo, createdAt, updatedAt];
}
