import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/exceptions.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:system_web_medias/features/menu/data/models/menu_option_model.dart';
import 'package:system_web_medias/features/menu/domain/entities/menu_option.dart';
import 'package:system_web_medias/features/menu/domain/repositories/menu_repository.dart';

/// Implementation del MenuRepository
/// Coordina el data source y maneja errores
class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;

  const MenuRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MenuOption>>> getMenuOptions(String userId) async {
    try {
      final response = await remoteDataSource.getMenuOptions(userId);

      // Convertir MenuOptionModel a MenuOption (entity)
      final menuOptions = MenuOptionModel.toEntityList(response.menu);

      return Right(menuOptions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(ConnectionFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSidebarPreference(String userId, bool collapsed) async {
    try {
      await remoteDataSource.updateSidebarPreference(userId, collapsed);
      return const Right(null);
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
