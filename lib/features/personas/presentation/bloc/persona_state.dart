import 'package:equatable/equatable.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';

abstract class PersonaState extends Equatable {
  const PersonaState();

  @override
  List<Object?> get props => [];
}

class PersonaInitial extends PersonaState {}

class PersonaLoading extends PersonaState {}

class PersonaSuccess extends PersonaState {
  final Persona persona;

  const PersonaSuccess({required this.persona});

  @override
  List<Object?> get props => [persona];
}

class PersonaListSuccess extends PersonaState {
  final List<Persona> personas;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  const PersonaListSuccess({
    required this.personas,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [personas, total, limit, offset, hasMore];
}

class PersonaDeleteSuccess extends PersonaState {
  final String message;

  const PersonaDeleteSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class PersonaError extends PersonaState {
  final String message;

  const PersonaError({required this.message});

  @override
  List<Object?> get props => [message];
}
