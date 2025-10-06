import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/menu/domain/entities/menu_option.dart';
import 'package:system_web_medias/features/menu/domain/repositories/menu_repository.dart';

/// Use Case: Obtener opciones de menú según usuario autenticado
/// Sigue el patrón de Clean Architecture con params
class GetMenuOptions {
  final MenuRepository repository;

  const GetMenuOptions(this.repository);

  /// Ejecutar use case
  Future<Either<Failure, List<MenuOption>>> call(GetMenuOptionsParams params) async {
    return await repository.getMenuOptions(params.userId);
  }
}

/// Params del use case
class GetMenuOptionsParams extends Equatable {
  final String userId;

  const GetMenuOptionsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
