import 'package:system_web_medias/features/personas/domain/entities/persona.dart';

class PersonaModel extends Persona {
  const PersonaModel({
    required super.id,
    required super.tipoDocumentoId,
    required super.numeroDocumento,
    required super.tipoPersona,
    super.nombreCompleto,
    super.razonSocial,
    super.email,
    super.celular,
    super.telefono,
    super.direccion,
    required super.activo,
    required super.roles,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PersonaModel.fromJson(Map<String, dynamic> json) {
    return PersonaModel(
      id: json['id'] as String? ?? '',
      tipoDocumentoId: json['tipo_documento_id'] as String? ?? '',
      numeroDocumento: json['numero_documento'] as String? ?? '',
      tipoPersona: TipoPersona.fromString(json['tipo_persona'] as String? ?? 'Natural'),
      nombreCompleto: json['nombre_completo'] as String?,
      razonSocial: json['razon_social'] as String?,
      email: json['email'] as String?,
      celular: json['celular'] as String?,
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
      activo: json['activo'] as bool? ?? true,
      roles: json['roles'] as List<dynamic>? ?? [],
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
      'tipo_documento_id': tipoDocumentoId,
      'numero_documento': numeroDocumento,
      'tipo_persona': tipoPersona.toBackendString(),
      'nombre_completo': nombreCompleto,
      'razon_social': razonSocial,
      'email': email,
      'celular': celular,
      'telefono': telefono,
      'direccion': direccion,
      'activo': activo,
      'roles': roles,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Persona toEntity() {
    return Persona(
      id: id,
      tipoDocumentoId: tipoDocumentoId,
      numeroDocumento: numeroDocumento,
      tipoPersona: tipoPersona,
      nombreCompleto: nombreCompleto,
      razonSocial: razonSocial,
      email: email,
      celular: celular,
      telefono: telefono,
      direccion: direccion,
      activo: activo,
      roles: roles,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  PersonaModel copyWith({
    String? id,
    String? tipoDocumentoId,
    String? numeroDocumento,
    TipoPersona? tipoPersona,
    String? nombreCompleto,
    String? razonSocial,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
    bool? activo,
    List<dynamic>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonaModel(
      id: id ?? this.id,
      tipoDocumentoId: tipoDocumentoId ?? this.tipoDocumentoId,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      tipoPersona: tipoPersona ?? this.tipoPersona,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      razonSocial: razonSocial ?? this.razonSocial,
      email: email ?? this.email,
      celular: celular ?? this.celular,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      activo: activo ?? this.activo,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
