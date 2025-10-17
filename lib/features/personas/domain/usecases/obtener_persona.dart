import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';
import 'package:system_web_medias/features/personas/domain/repositories/persona_repository.dart';

class ObtenerPersona {
  final PersonaRepository repository;

  ObtenerPersona(this.repository);

  Future<Either<Failure, Persona>> call(ObtenerPersonaParams params) async {
    return await repository.obtenerPersona(params.personaId);
  }
}

class ObtenerPersonaParams extends Equatable {
  final String personaId;

  const ObtenerPersonaParams({required this.personaId});

  @override
  List<Object?> get props => [personaId];
}
