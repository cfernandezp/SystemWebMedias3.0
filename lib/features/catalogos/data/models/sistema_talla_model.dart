import 'package:equatable/equatable.dart';

/// Modelo de Sistema de Tallas del sistema.
///
/// Implementa E002-HU-004 (Gestionar Sistemas de Tallas).
/// Cumple RN-004-01: Tipos válidos (UNICA, NUMERO, LETRA, RANGO).
/// Cumple RN-004-02: Nombre único max 50 caracteres.
/// Cumple RN-004-07: Tipo de sistema inmutable.
/// Cumple RN-004-09: Soft delete (activo).
///
/// Mapping BD ↔ Dart:
/// - `tipo_sistema` → `tipoSistema`
/// - `descripcion` → `descripcion`
/// - `activo` → `activo`
/// - `valores_count` → `valoresCount`
/// - `created_at` → `createdAt`
/// - `updated_at` → `updatedAt`
class SistemaTallaModel extends Equatable {
  final String id;
  final String nombre;
  final String tipoSistema;
  final String? descripcion;
  final bool activo;
  final int valoresCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SistemaTallaModel({
    required this.id,
    required this.nombre,
    required this.tipoSistema,
    this.descripcion,
    required this.activo,
    required this.valoresCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea SistemaTallaModel desde JSON (snake_case → camelCase)
  factory SistemaTallaModel.fromJson(Map<String, dynamic> json) {
    return SistemaTallaModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      tipoSistema: json['tipo_sistema'] as String,              // ⭐ snake_case → camelCase
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
      valoresCount: json['valores_count'] as int? ?? 0,         // ⭐ snake_case → camelCase
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),                                      // ⭐ snake_case → camelCase
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),                                      // ⭐ snake_case → camelCase
    );
  }

  /// Convierte SistemaTallaModel a JSON (camelCase → snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo_sistema': tipoSistema,                          // ⭐ camelCase → snake_case
      'descripcion': descripcion,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),            // ⭐ camelCase → snake_case
      'updated_at': updatedAt.toIso8601String(),            // ⭐ camelCase → snake_case
    };
  }

  /// Crea copia con campos actualizados
  SistemaTallaModel copyWith({
    String? id,
    String? nombre,
    String? tipoSistema,
    String? descripcion,
    bool? activo,
    int? valoresCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SistemaTallaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipoSistema: tipoSistema ?? this.tipoSistema,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      valoresCount: valoresCount ?? this.valoresCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        tipoSistema,
        descripcion,
        activo,
        valoresCount,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'SistemaTallaModel(id: $id, nombre: $nombre, tipo: $tipoSistema, activo: $activo)';
}
