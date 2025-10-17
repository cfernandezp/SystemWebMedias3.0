import 'package:equatable/equatable.dart';

enum TipoPersona {
  natural,
  juridica;

  static TipoPersona fromString(String value) {
    switch (value.toLowerCase()) {
      case 'natural':
        return TipoPersona.natural;
      case 'juridica':
        return TipoPersona.juridica;
      default:
        throw ArgumentError('Tipo de persona inválido: $value');
    }
  }

  String toBackendString() {
    switch (this) {
      case TipoPersona.natural:
        return 'Natural';
      case TipoPersona.juridica:
        return 'Juridica';
    }
  }
}

class Persona extends Equatable {
  final String id;
  final String tipoDocumentoId;
  final String numeroDocumento;
  final TipoPersona tipoPersona;
  final String? nombreCompleto;
  final String? razonSocial;
  final String? email;
  final String? celular;
  final String? telefono;
  final String? direccion;
  final bool activo;
  final List<dynamic> roles;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Persona({
    required this.id,
    required this.tipoDocumentoId,
    required this.numeroDocumento,
    required this.tipoPersona,
    this.nombreCompleto,
    this.razonSocial,
    this.email,
    this.celular,
    this.telefono,
    this.direccion,
    required this.activo,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        tipoDocumentoId,
        numeroDocumento,
        tipoPersona,
        nombreCompleto,
        razonSocial,
        email,
        celular,
        telefono,
        direccion,
        activo,
        roles,
        createdAt,
        updatedAt,
      ];
}
