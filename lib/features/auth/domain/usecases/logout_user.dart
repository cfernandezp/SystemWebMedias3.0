import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/auth/domain/repositories/auth_repository.dart';

/// Use Case para cerrar sesión
///
/// Implementa HU-002 (Login al Sistema)
/// Limpia el estado de autenticación local (SecureStorage)
class LogoutUser {
  final AuthRepository repository;

  LogoutUser(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
