/// Servicio para sincronizar estado de autenticación entre pestañas.
///
/// Implementa HU-003 (Logout Seguro - RN-003-LOGOUT-005).
///
/// Este archivo usa conditional imports para soportar:
/// - Web: Usa localStorage events (multi_tab_sync_service_web.dart)
/// - VM/Tests: Usa stub sin operaciones (multi_tab_sync_service_stub.dart)
///
/// Esto resuelve el error:
/// "Dart library 'dart:js_interop' is not available on this platform"
/// que bloqueaba la ejecución de tests.
export 'multi_tab_sync_service_stub.dart'
    if (dart.library.html) 'multi_tab_sync_service_web.dart';
