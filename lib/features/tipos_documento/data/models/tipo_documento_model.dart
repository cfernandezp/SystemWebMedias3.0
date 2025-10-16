import 'package:system_web_medias/features/tipos_documento/domain/entities/tipo_documento_entity.dart';

class TipoDocumentoModel extends TipoDocumentoEntity {
  const TipoDocumentoModel({
    required super.id,
    required super.codigo,
    required super.nombre,
    required super.formato,
    required super.longitudMinima,
    required super.longitudMaxima,
    required super.activo,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TipoDocumentoModel.fromJson(Map<String, dynamic> json) {
    return TipoDocumentoModel(
      id: json['id'] as String? ?? '',
      codigo: json['codigo'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      formato: TipoDocumentoFormato.fromString(json['formato'] as String? ?? 'NUMERICO'),
      longitudMinima: json['longitud_minima'] as int? ?? 0,
      longitudMaxima: json['longitud_maxima'] as int? ?? 0,
      activo: json['activo'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'formato': formato.toBackendString(),
      'longitud_minima': longitudMinima,
      'longitud_maxima': longitudMaxima,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TipoDocumentoEntity toEntity() {
    return TipoDocumentoEntity(
      id: id,
      codigo: codigo,
      nombre: nombre,
      formato: formato,
      longitudMinima: longitudMinima,
      longitudMaxima: longitudMaxima,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  TipoDocumentoModel copyWith({
    String? id,
    String? codigo,
    String? nombre,
    TipoDocumentoFormato? formato,
    int? longitudMinima,
    int? longitudMaxima,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TipoDocumentoModel(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      formato: formato ?? this.formato,
      longitudMinima: longitudMinima ?? this.longitudMinima,
      longitudMaxima: longitudMaxima ?? this.longitudMaxima,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
