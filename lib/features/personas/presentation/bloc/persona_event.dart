import 'package:equatable/equatable.dart';

abstract class PersonaEvent extends Equatable {
  const PersonaEvent();

  @override
  List<Object?> get props => [];
}

class BuscarPersonaPorDocumentoEvent extends PersonaEvent {
  final String tipoDocumentoId;
  final String numeroDocumento;

  const BuscarPersonaPorDocumentoEvent({
    required this.tipoDocumentoId,
    required this.numeroDocumento,
  });

  @override
  List<Object?> get props => [tipoDocumentoId, numeroDocumento];
}

class CrearPersonaEvent extends PersonaEvent {
  final String tipoDocumentoId;
  final String numeroDocumento;
  final String tipoPersona;
  final String? nombreCompleto;
  final String? razonSocial;
  final String? email;
  final String? celular;
  final String? telefono;
  final String? direccion;

  const CrearPersonaEvent({
    required this.tipoDocumentoId,
    required this.numeroDocumento,
    required this.tipoPersona,
    this.nombreCompleto,
    this.razonSocial,
    this.email,
    this.celular,
    this.telefono,
    this.direccion,
  });

  @override
  List<Object?> get props => [
        tipoDocumentoId,
        numeroDocumento,
        tipoPersona,
        nombreCompleto,
        razonSocial,
        email,
        celular,
        telefono,
        direccion,
      ];
}

class ListarPersonasEvent extends PersonaEvent {
  final String? tipoDocumentoId;
  final String? tipoPersona;
  final bool? activo;
  final String? busqueda;
  final int limit;
  final int offset;

  const ListarPersonasEvent({
    this.tipoDocumentoId,
    this.tipoPersona,
    this.activo,
    this.busqueda,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [
        tipoDocumentoId,
        tipoPersona,
        activo,
        busqueda,
        limit,
        offset,
      ];
}

class ObtenerPersonaEvent extends PersonaEvent {
  final String personaId;

  const ObtenerPersonaEvent({required this.personaId});

  @override
  List<Object?> get props => [personaId];
}

class EditarPersonaEvent extends PersonaEvent {
  final String personaId;
  final String? email;
  final String? celular;
  final String? telefono;
  final String? direccion;

  const EditarPersonaEvent({
    required this.personaId,
    this.email,
    this.celular,
    this.telefono,
    this.direccion,
  });

  @override
  List<Object?> get props => [
        personaId,
        email,
        celular,
        telefono,
        direccion,
      ];
}

class DesactivarPersonaEvent extends PersonaEvent {
  final String personaId;
  final bool desactivarRoles;

  const DesactivarPersonaEvent({
    required this.personaId,
    this.desactivarRoles = false,
  });

  @override
  List<Object?> get props => [personaId, desactivarRoles];
}

class EliminarPersonaEvent extends PersonaEvent {
  final String personaId;

  const EliminarPersonaEvent({required this.personaId});

  @override
  List<Object?> get props => [personaId];
}

class ReactivarPersonaEvent extends PersonaEvent {
  final String personaId;
  final String? email;
  final String? celular;
  final String? telefono;
  final String? direccion;

  const ReactivarPersonaEvent({
    required this.personaId,
    this.email,
    this.celular,
    this.telefono,
    this.direccion,
  });

  @override
  List<Object?> get props => [
        personaId,
        email,
        celular,
        telefono,
        direccion,
      ];
}
