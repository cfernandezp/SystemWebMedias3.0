import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';

abstract class PersonaRepository {
  Future<Either<Failure, Persona>> buscarPersonaPorDocumento({
    required String tipoDocumentoId,
    required String numeroDocumento,
  });

  Future<Either<Failure, Persona>> crearPersona({
    required String tipoDocumentoId,
    required String numeroDocumento,
    required String tipoPersona,
    String? nombreCompleto,
    String? razonSocial,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
  });

  Future<Either<Failure, Map<String, dynamic>>> listarPersonas({
    String? tipoDocumentoId,
    String? tipoPersona,
    bool? activo,
    String? busqueda,
    int limit = 50,
    int offset = 0,
  });

  Future<Either<Failure, Persona>> obtenerPersona(String personaId);

  Future<Either<Failure, Persona>> editarPersona({
    required String personaId,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
  });

  Future<Either<Failure, Persona>> desactivarPersona({
    required String personaId,
    bool desactivarRoles = false,
  });

  Future<Either<Failure, Map<String, dynamic>>> eliminarPersona(String personaId);

  Future<Either<Failure, Persona>> reactivarPersona({
    required String personaId,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
  });
}
