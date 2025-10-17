import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';
import 'package:system_web_medias/features/personas/domain/repositories/persona_repository.dart';

class DesactivarPersona {
  final PersonaRepository repository;

  DesactivarPersona(this.repository);

  Future<Either<Failure, Persona>> call(DesactivarPersonaParams params) async {
    return await repository.desactivarPersona(
      personaId: params.personaId,
      desactivarRoles: params.desactivarRoles,
    );
  }
}

class DesactivarPersonaParams extends Equatable {
  final String personaId;
  final bool desactivarRoles;

  const DesactivarPersonaParams({
    required this.personaId,
    this.desactivarRoles = false,
  });

  @override
  List<Object?> get props => [personaId, desactivarRoles];
}
