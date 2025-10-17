import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';
import 'package:system_web_medias/features/personas/domain/repositories/persona_repository.dart';

class CrearPersona {
  final PersonaRepository repository;

  CrearPersona(this.repository);

  Future<Either<Failure, Persona>> call(CrearPersonaParams params) async {
    return await repository.crearPersona(
      tipoDocumentoId: params.tipoDocumentoId,
      numeroDocumento: params.numeroDocumento,
      tipoPersona: params.tipoPersona,
      nombreCompleto: params.nombreCompleto,
      razonSocial: params.razonSocial,
      email: params.email,
      celular: params.celular,
      telefono: params.telefono,
      direccion: params.direccion,
    );
  }
}

class CrearPersonaParams extends Equatable {
  final String tipoDocumentoId;
  final String numeroDocumento;
  final String tipoPersona;
  final String? nombreCompleto;
  final String? razonSocial;
  final String? email;
  final String? celular;
  final String? telefono;
  final String? direccion;

  const CrearPersonaParams({
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
