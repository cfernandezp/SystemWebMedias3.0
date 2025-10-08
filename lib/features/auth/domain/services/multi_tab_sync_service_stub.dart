import 'dart:async';

/// Stub de MultiTabSyncService para entornos NO-Web (VM, tests).
///
/// En tests y VM, las APIs de browser no están disponibles,
/// por lo que este stub proporciona una implementación vacía
/// que no hace nada pero mantiene la misma interfaz.
class MultiTabSyncService {
  final StreamController<String> _storageEventController =
      StreamController.broadcast();

  Stream<String> get storageEvents => _storageEventController.stream;

  MultiTabSyncService();

  void notifyLogout() {
    // No-op en VM
  }

  void notifySessionExtended() {
    // No-op en VM
  }

  void dispose() {
    _storageEventController.close();
  }
}
