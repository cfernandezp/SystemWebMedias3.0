import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window, StorageEvent;

/// Servicio para sincronizar estado de autenticación entre pestañas.
///
/// Implementa HU-003 (Logout Seguro - RN-003-LOGOUT-005).
///
/// Usa localStorage events de HTML5 para detectar cambios en otras pestañas
/// del navegador. Solo funciona en Flutter Web.
///
/// Eventos detectados:
/// - `logout_detected`: Token eliminado en otra pestaña
/// - `session_extended`: Sesión extendida en otra pestaña
class MultiTabSyncService {
  final StreamController<String> _storageEventController =
      StreamController.broadcast();

  Stream<String> get storageEvents => _storageEventController.stream;

  MultiTabSyncService() {
    _listenToStorageChanges();
  }

  /// Escucha cambios en localStorage de otras pestañas.
  void _listenToStorageChanges() {
    html.window.addEventListener('storage', (event) {
      final storageEvent = event as html.StorageEvent;

      // Detectar cuando token es eliminado en otra pestaña
      if (storageEvent.key == 'auth_token' && storageEvent.newValue == null) {
        _storageEventController.add('logout_detected');
      }

      // Detectar cuando sesión es extendida en otra pestaña
      if (storageEvent.key == 'session_extended') {
        _storageEventController.add('session_extended');
      }
    });
  }

  /// Notifica a otras pestañas que se hizo logout.
  ///
  /// Elimina el token de localStorage para triggear
  /// el evento 'storage' en otras pestañas.
  void notifyLogout() {
    // Eliminar token para notificar a otras pestañas
    html.window.localStorage.remove('auth_token');
  }

  /// Notifica a otras pestañas que la sesión fue extendida.
  ///
  /// Marca en localStorage que la sesión fue extendida
  /// para que otras pestañas reseten su timer de inactividad.
  void notifySessionExtended() {
    // Marcar que sesión fue extendida
    html.window.localStorage['session_extended'] =
        DateTime.now().toIso8601String();
  }

  /// Libera recursos del servicio.
  void dispose() {
    _storageEventController.close();
  }
}
