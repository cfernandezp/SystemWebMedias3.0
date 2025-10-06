import 'package:dartz/dartz.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/menu/domain/entities/menu_option.dart';

/// Contract abstracto del repository de menú
/// Define las operaciones disponibles sin especificar implementación
abstract class MenuRepository {
  /// Obtener opciones de menú según usuario autenticado
  /// Returns: Either<Failure, List<MenuOption>>
  Future<Either<Failure, List<MenuOption>>> getMenuOptions(String userId);

  /// Actualizar preferencia de sidebar (expandido/colapsado)
  /// Returns: Either<Failure, void>
  Future<Either<Failure, void>> updateSidebarPreference(String userId, bool collapsed);
}
