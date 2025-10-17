import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';
import 'package:system_web_medias/features/personas/domain/repositories/persona_repository.dart';

class EditarPersona {
  final PersonaRepository repository;

  EditarPersona(this.repository);

  Future<Either<Failure, Persona>> call(EditarPersonaParams params) async {
    return await repository.editarPersona(
      personaId: params.personaId,
      email: params.email,
      celular: params.celular,
      telefono: params.telefono,
      direccion: params.direccion,
    );
  }
}

class EditarPersonaParams extends Equatable {
  final String personaId;
  final String? email;
  final String? celular;
  final String? telefono;
  final String? direccion;

  const EditarPersonaParams({
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
