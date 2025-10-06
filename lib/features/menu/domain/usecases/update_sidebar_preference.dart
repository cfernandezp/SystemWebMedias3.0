import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:system_web_medias/core/error/failures.dart';
import 'package:system_web_medias/features/menu/domain/repositories/menu_repository.dart';

/// Use Case: Actualizar preferencia de sidebar (expandido/colapsado)
/// Sigue el patrón de Clean Architecture con params
class UpdateSidebarPreference {
  final MenuRepository repository;

  const UpdateSidebarPreference(this.repository);

  /// Ejecutar use case
  Future<Either<Failure, void>> call(UpdateSidebarPreferenceParams params) async {
    return await repository.updateSidebarPreference(params.userId, params.collapsed);
  }
}

/// Params del use case
class UpdateSidebarPreferenceParams extends Equatable {
  final String userId;
  final bool collapsed;

  const UpdateSidebarPreferenceParams({
    required this.userId,
    required this.collapsed,
  });

  @override
  List<Object?> get props => [userId, collapsed];
}
