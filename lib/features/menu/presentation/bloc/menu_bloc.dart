import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/menu/domain/usecases/get_menu_options.dart';
import 'package:system_web_medias/features/menu/domain/usecases/update_sidebar_preference.dart';
import 'package:system_web_medias/features/menu/presentation/bloc/menu_event.dart';
import 'package:system_web_medias/features/menu/presentation/bloc/menu_state.dart';

/// Bloc para manejo de estado del menú de navegación
/// Maneja carga de menú y preferencias de sidebar
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetMenuOptions getMenuOptions;
  final UpdateSidebarPreference updateSidebarPreference;

  MenuBloc({
    required this.getMenuOptions,
    required this.updateSidebarPreference,
  }) : super(MenuInitial()) {
    on<LoadMenuEvent>(_onLoadMenu);
    on<ToggleSidebarEvent>(_onToggleSidebar);
  }

  /// Handler: Cargar menú del usuario
  Future<void> _onLoadMenu(LoadMenuEvent event, Emitter<MenuState> emit) async {
    emit(MenuLoading());

    final result = await getMenuOptions(GetMenuOptionsParams(userId: event.userId));

    result.fold(
      (failure) => emit(MenuError(message: failure.message)),
      (menuOptions) => emit(MenuLoaded(
        menuOptions: menuOptions,
        sidebarCollapsed: false, // Default: expandido
      )),
    );
  }

  /// Handler: Toggle sidebar (expandir/colapsar)
  Future<void> _onToggleSidebar(ToggleSidebarEvent event, Emitter<MenuState> emit) async {
    // Guardar estado actual
    final currentState = state;
    if (currentState is! MenuLoaded) return;

    // Emitir estado de actualización
    emit(SidebarUpdating(
      menuOptions: currentState.menuOptions,
      currentCollapsed: currentState.sidebarCollapsed,
    ));

    // Actualizar preferencia en backend
    final result = await updateSidebarPreference(UpdateSidebarPreferenceParams(
      userId: event.userId,
      collapsed: event.collapsed,
    ));

    result.fold(
      (failure) {
        // En caso de error, revertir al estado anterior
        emit(currentState);
        // Opcional: Emitir snackbar con mensaje de error
      },
      (_) {
        // Éxito: Actualizar estado con nuevo valor
        emit(currentState.copyWith(sidebarCollapsed: event.collapsed));
      },
    );
  }
}
