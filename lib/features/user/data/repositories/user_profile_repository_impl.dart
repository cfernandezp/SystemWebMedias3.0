import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/user/data/datasources/user_profile_remote_datasource.dart';
import 'package:system_web_medias/features/user/domain/entities/user_profile.dart';
import 'package:system_web_medias/features/user/domain/repositories/user_profile_repository.dart';

/// Implementation del UserProfileRepository
/// Coordina el data source y maneja errores
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;

  const UserProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      final userProfileModel = await remoteDataSource.getUserProfile(userId);

      // El model extiende entity, así que podemos retornar directamente
      return Right(userProfileModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }
}
