import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';
import 'package:system_web_medias/features/personas/domain/repositories/persona_repository.dart';

class ReactivarPersona {
  final PersonaRepository repository;

  ReactivarPersona(this.repository);

  Future<Either<Failure, Persona>> call(ReactivarPersonaParams params) async {
    return await repository.reactivarPersona(
      personaId: params.personaId,
      email: params.email,
      celular: params.celular,
      telefono: params.telefono,
      direccion: params.direccion,
    );
  }
}

class ReactivarPersonaParams extends Equatable {
  final String personaId;
  final String? email;
  final String? celular;
  final String? telefono;
  final String? direccion;

  const ReactivarPersonaParams({
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
