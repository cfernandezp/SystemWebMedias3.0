import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/personas/domain/repositories/persona_repository.dart';

class EliminarPersona {
  final PersonaRepository repository;

  EliminarPersona(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(EliminarPersonaParams params) async {
    return await repository.eliminarPersona(params.personaId);
  }
}

class EliminarPersonaParams extends Equatable {
  final String personaId;

  const EliminarPersonaParams({required this.personaId});

  @override
  List<Object?> get props => [personaId];
}
