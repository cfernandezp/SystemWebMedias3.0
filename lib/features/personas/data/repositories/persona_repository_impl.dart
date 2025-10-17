import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/personas/data/datasources/persona_remote_datasource.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';
import 'package:system_web_medias/features/personas/domain/repositories/persona_repository.dart';

class PersonaRepositoryImpl implements PersonaRepository {
  final PersonaRemoteDataSource remoteDataSource;

  PersonaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Persona>> buscarPersonaPorDocumento({
    required String tipoDocumentoId,
    required String numeroDocumento,
  }) async {
    try {
      final persona = await remoteDataSource.buscarPersonaPorDocumento(
        tipoDocumentoId: tipoDocumentoId,
        numeroDocumento: numeroDocumento,
      );
      return Right(persona);
    } on PersonaNotFoundException catch (e) {
      return Left(PersonaNotFoundFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
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
  }) async {
    try {
      final persona = await remoteDataSource.crearPersona(
        tipoDocumentoId: tipoDocumentoId,
        numeroDocumento: numeroDocumento,
        tipoPersona: tipoPersona,
        nombreCompleto: nombreCompleto,
        razonSocial: razonSocial,
        email: email,
        celular: celular,
        telefono: telefono,
        direccion: direccion,
      );
      return Right(persona);
    } on DuplicatePersonaException catch (e) {
      return Left(DuplicatePersonaFailure(e.message));
    } on InvalidDocumentFormatException catch (e) {
      return Left(InvalidDocumentFormatFailure(e.message));
    } on InvalidDocumentForPersonTypeException catch (e) {
      return Left(InvalidDocumentForPersonTypeFailure(e.message));
    } on MissingNombreException catch (e) {
      return Left(MissingNombreFailure(e.message));
    } on MissingRazonSocialException catch (e) {
      return Left(MissingRazonSocialFailure(e.message));
    } on InvalidEmailException catch (e) {
      return Left(InvalidEmailFailure(e.message));
    } on InvalidPhoneException catch (e) {
      return Left(InvalidPhoneFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> listarPersonas({
    String? tipoDocumentoId,
    String? tipoPersona,
    bool? activo,
    String? busqueda,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final result = await remoteDataSource.listarPersonas(
        tipoDocumentoId: tipoDocumentoId,
        tipoPersona: tipoPersona,
        activo: activo,
        busqueda: busqueda,
        limit: limit,
        offset: offset,
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Persona>> obtenerPersona(String personaId) async {
    try {
      final persona = await remoteDataSource.obtenerPersona(personaId);
      return Right(persona);
    } on PersonaNotFoundException catch (e) {
      return Left(PersonaNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Persona>> editarPersona({
    required String personaId,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
  }) async {
    try {
      final persona = await remoteDataSource.editarPersona(
        personaId: personaId,
        email: email,
        celular: celular,
        telefono: telefono,
        direccion: direccion,
      );
      return Right(persona);
    } on PersonaNotFoundException catch (e) {
      return Left(PersonaNotFoundFailure(e.message));
    } on InvalidEmailException catch (e) {
      return Left(InvalidEmailFailure(e.message));
    } on InvalidPhoneException catch (e) {
      return Left(InvalidPhoneFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Persona>> desactivarPersona({
    required String personaId,
    bool desactivarRoles = false,
  }) async {
    try {
      final persona = await remoteDataSource.desactivarPersona(
        personaId: personaId,
        desactivarRoles: desactivarRoles,
      );
      return Right(persona);
    } on PersonaNotFoundException catch (e) {
      return Left(PersonaNotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> eliminarPersona(String personaId) async {
    try {
      final result = await remoteDataSource.eliminarPersona(personaId);
      return Right(result);
    } on PersonaNotFoundException catch (e) {
      return Left(PersonaNotFoundFailure(e.message));
    } on HasTransactionsException catch (e) {
      return Left(HasTransactionsFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Persona>> reactivarPersona({
    required String personaId,
    String? email,
    String? celular,
    String? telefono,
    String? direccion,
  }) async {
    try {
      final persona = await remoteDataSource.reactivarPersona(
        personaId: personaId,
        email: email,
        celular: celular,
        telefono: telefono,
        direccion: direccion,
      );
      return Right(persona);
    } on PersonaNotFoundException catch (e) {
      return Left(PersonaNotFoundFailure(e.message));
    } on AlreadyActiveException catch (e) {
      return Left(AlreadyActiveFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: $e'));
    }
  }
}
