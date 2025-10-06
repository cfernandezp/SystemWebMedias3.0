# Especificaciones para Agentes - E001-HU-003: Logout Seguro

**Historia de Usuario**: E001-HU-003 - Logout Seguro
**Arquitecto**: @web-architect-expert
**Fecha**: 2025-10-06

---

## 🎯 RESUMEN EJECUTIVO

Implementar cierre de sesión seguro con:
- Confirmación de logout manual
- Invalidación de tokens JWT (blacklist)
- Detección de inactividad (2 horas)
- Sincronización multi-pestaña
- Auditoría de eventos de seguridad

---

## 📋 INSTRUCCIONES PARA @supabase-expert

### Scope de Implementación

**Leer**:
- ✅ `docs/technical/00-CONVENTIONS.md` (Sección 7: Security Patterns)
- ✅ `docs/technical/backend/schema_E001-HU-003.md`
- ✅ `docs/technical/backend/apis_E001-HU-003.md`
- ✅ `docs/technical/integration/mapping_E001-HU-003.md`

**Implementar**:

1. **Migration**: `supabase/migrations/YYYYMMDDHHMMSS_hu003_logout_seguro.sql`
   - Tabla `token_blacklist` (id, token, user_id, blacklisted_at, expires_at, reason)
   - Tabla `audit_logs` (id, user_id, event_type, event_subtype, ip_address, user_agent, metadata, created_at)
   - Columna `users.last_activity_at`
   - Índices: `idx_token_blacklist_token`, `idx_audit_logs_user_id`, etc.

2. **Funciones DB**:
   - `logout_user(p_token, p_user_id, p_logout_type, ...)`
   - `check_token_blacklist(p_token)`
   - `check_user_inactivity(p_user_id, p_timeout_minutes)`
   - `update_user_activity(p_user_id)`
   - `cleanup_expired_blacklist()`
   - `get_user_audit_logs(p_user_id, p_event_type, p_limit)`

3. **Error Handling**: Usar patrón estándar con `v_error_hint` local (NO `PG_EXCEPTION_HINT`)

4. **Testing**: Verificar funciones en Supabase Studio

**Actualizar después de implementar**:
- ✅ `docs/technical/backend/schema_E001-HU-003.md` → Sección "SQL Final Implementado"
- ✅ `docs/technical/backend/apis_E001-HU-003.md` → Sección "Código Final Implementado"

---

## 📋 INSTRUCCIONES PARA @flutter-expert

### Scope de Implementación

**Leer**:
- ✅ `docs/technical/00-CONVENTIONS.md` (Sección 1: Naming, Sección 3: Error Handling)
- ✅ `docs/technical/frontend/models_E001-HU-003.md`
- ✅ `docs/technical/integration/mapping_E001-HU-003.md`

**Implementar**:

1. **Models** (`lib/features/auth/data/models/`):
   - `logout_request_model.dart`
   - `logout_response_model.dart`
   - `token_blacklist_check_model.dart`
   - `inactivity_status_model.dart`
   - `audit_log_model.dart`

2. **Services** (`lib/features/auth/domain/services/`):
   - `inactivity_timer_service.dart` (Timer para inactividad)
   - `multi_tab_sync_service.dart` (Sync entre pestañas - Flutter Web)

3. **Bloc Events/States** (`lib/features/auth/presentation/bloc/`):
   - Eventos: `LogoutRequested`, `LogoutCancelled`, `InactivityDetected`, `ExtendSessionRequested`
   - Estados: `LogoutInProgress`, `LogoutConfirmationRequired`, `LogoutSuccess`, `InactivityWarning`, `TokenBlacklisted`

4. **Repository** (`lib/features/auth/domain/repositories/auth_repository.dart`):
   - Métodos: `logout()`, `checkTokenBlacklist()`, `checkInactivity()`, `updateUserActivity()`, `getUserAuditLogs()`

5. **Datasource** (`lib/features/auth/data/datasources/auth_remote_datasource.dart`):
   - Llamadas RPC a Supabase
   - Mapeo de hints a excepciones (según 00-CONVENTIONS.md)

6. **Integración**:
   - Conectar InactivityTimerService con AuthBloc
   - Conectar MultiTabSyncService con AuthBloc
   - Actualizar actividad en cada interacción del usuario

**Actualizar después de implementar**:
- ✅ `docs/technical/frontend/models_E001-HU-003.md` → Sección "Código Final Implementado"

---

## 📋 INSTRUCCIONES PARA @ux-ui-expert

### Scope de Implementación

**Leer**:
- ✅ `docs/technical/00-CONVENTIONS.md` (Sección 5: Design System)
- ✅ `docs/technical/design/components_E001-HU-003.md`

**Implementar**:

1. **Atoms** (`lib/shared/design_system/atoms/`):
   - `logout_button.dart`

2. **Molecules** (`lib/features/auth/presentation/widgets/`):
   - `user_menu_dropdown.dart` (Dropdown con nombre, rol, logout)
   - `logout_confirmation_dialog.dart` (Modal de confirmación)
   - `inactivity_warning_dialog.dart` (Warning con countdown)
   - `session_expired_snackbar.dart` (Snackbar de mensajes)

3. **Organisms** (`lib/shared/design_system/organisms/`):
   - `authenticated_header.dart` (Header con UserMenuDropdown integrado)

4. **Bloc Integration**:
   - `BlocListener<AuthBloc, AuthState>` para mostrar dialogs según estado
   - Navegación a `/login` en `LogoutSuccess` o `TokenBlacklisted`

**Reglas de Diseño**:
- ✅ NUNCA hardcodear colores → usar `Theme.of(context).colorScheme.*`
- ✅ Usar `DesignSpacing.*` para espaciado
- ✅ Logout button en `colorScheme.error`
- ✅ Inactivity warning en `colorScheme.warning`
- ✅ Responsive: Ajustar UserMenuDropdown según breakpoints

**Actualizar después de implementar**:
- ✅ `docs/technical/design/components_E001-HU-003.md` → Sección "Código Final Implementado"

---

## 🔄 INTEGRACIÓN FINAL (@flutter-expert)

**Después de implementación paralela, integrar**:

1. **AuthBloc - Lógica Completa**:
   ```dart
   on<LogoutRequested>((event, emit) async {
     emit(LogoutInProgress());

     final result = await logoutUseCase(LogoutParams(...));

     result.fold(
       (failure) => emit(LogoutError(failure.message)),
       (response) {
         // Limpiar storage
         await secureStorage.delete(key: 'auth_token');

         // Notificar otras pestañas
         multiTabSyncService.notifyLogout();

         emit(LogoutSuccess(
           message: response.message,
           logoutType: response.logoutType,
         ));
       },
     );
   });

   on<InactivityDetected>((event, emit) async {
     // Logout automático por inactividad
     add(LogoutRequested(logoutType: 'inactivity'));
   });

   on<ExtendSessionRequested>((event, emit) async {
     // Resetear timer de inactividad
     inactivityTimerService.resetTimer();

     // Actualizar actividad en backend
     await authRepository.updateUserActivity(userId);

     // Notificar otras pestañas
     multiTabSyncService.notifySessionExtended();

     emit(SessionExtended());
   });
   ```

2. **Main App - Listeners Globales**:
   ```dart
   // Escuchar eventos de otras pestañas
   multiTabSyncService.storageEvents.listen((event) {
     if (event == 'logout_detected') {
       context.read<AuthBloc>().add(LogoutRequested(logoutType: 'multi_tab'));
     } else if (event == 'session_extended') {
       inactivityTimerService.resetTimer();
     }
   });

   // Actualizar actividad en cada interacción
   GestureDetector(
     onTap: () => authRepository.updateUserActivity(userId),
     child: MaterialApp(...),
   );
   ```

3. **Verificar Token Blacklist en cada Request**:
   ```dart
   // Interceptor HTTP
   class AuthInterceptor extends Interceptor {
     @override
     void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
       final token = await secureStorage.read(key: 'auth_token');

       // Verificar blacklist antes de cada request
       final check = await authRepository.checkTokenBlacklist(token);

       if (check.isBlacklisted) {
         throw TokenBlacklistedException(check.message);
       }

       options.headers['Authorization'] = 'Bearer $token';
       handler.next(options);
     }
   }
   ```

---

## ✅ CRITERIOS DE VALIDACIÓN (@qa-testing-expert)

### Validación Funcional

**CA-001: Botón de Logout Visible**
- [ ] UserMenuDropdown visible en header
- [ ] Muestra nombre y rol del usuario
- [ ] Opción "Cerrar Sesión" disponible

**CA-002: Logout Exitoso**
- [ ] Modal de confirmación aparece
- [ ] Al confirmar, token se invalida en BD
- [ ] SecureStorage se limpia
- [ ] Redirige a /login
- [ ] Mensaje "Sesión cerrada exitosamente"

**CA-003: Cancelar Logout**
- [ ] Botón "Cancelar" funciona
- [ ] Usuario permanece autenticado
- [ ] No hay cambios en sesión

**CA-004: Logout Automático por Inactividad**
- [ ] A los 115 minutos: Warning aparece
- [ ] Warning muestra countdown
- [ ] Botón "Extender sesión" funciona
- [ ] A los 120 minutos: Logout automático
- [ ] Mensaje "Sesión cerrada por inactividad"

**CA-005: Acceso Post-Logout**
- [ ] Intentar acceder a /dashboard → Redirige a /login
- [ ] Mensaje "Debes iniciar sesión para acceder"

**CA-006: Logout desde Múltiples Pestañas**
- [ ] Logout en pestaña A
- [ ] Pestaña B detecta cambio automáticamente
- [ ] Pestaña B redirige a /login
- [ ] Mensaje "Sesión cerrada en otra pestaña"

**CA-008: Logout por Token Expirado**
- [ ] Token expirado detectado automáticamente
- [ ] Logout automático
- [ ] Redirige a /login
- [ ] Mensaje "Tu sesión ha expirado"

### Validación Técnica

**Base de Datos**
- [ ] Token se agrega a `token_blacklist`
- [ ] Evento se registra en `audit_logs`
- [ ] `users.last_activity_at` se actualiza

**Seguridad**
- [ ] Token blacklisted NO puede usarse
- [ ] IP y user agent se registran correctamente
- [ ] Logs NO contienen datos sensibles

**Performance**
- [ ] Logout < 1 segundo
- [ ] Cleanup de blacklist funciona (job diario)
- [ ] Índices mejoran queries

---

## 🔧 TROUBLESHOOTING

### Problema: Multi-Tab Sync no funciona
**Solución**: Solo funciona en Flutter Web. Verificar `import 'dart:html'`

### Problema: Timer de inactividad no se resetea
**Solución**: Asegurar que `InactivityTimerService.resetTimer()` se llama en CADA interacción

### Problema: Token no se invalida
**Solución**: Verificar que `logout_user()` se ejecuta correctamente y token se agrega a blacklist

### Problema: Dialog no aparece
**Solución**: Verificar `BlocListener` esté en árbol de widgets y escuche estado correcto

---

## 📚 REFERENCIAS

- [00-CONVENTIONS.md](00-CONVENTIONS.md) - Convenciones del proyecto
- [SISTEMA_DOCUMENTACION.md](../../SISTEMA_DOCUMENTACION.md) - Reglas de negocio (RN-003-LOGOUT)
- [E001-HU-003-logout-seguro.md](../../historias-usuario/E001-HU-003-logout-seguro.md) - Historia de usuario

---

**⚠️ RECORDATORIO IMPORTANTE**:

Antes de implementar, **TODOS los agentes DEBEN**:
1. ✅ Leer `docs/technical/00-CONVENTIONS.md` completo
2. ✅ Leer las specs de su área (backend/frontend/design)
3. ✅ Seguir naming conventions (snake_case BD, camelCase Dart)
4. ✅ Actualizar archivos .md con código final implementado
5. ✅ Reportar errores o dudas al arquitecto (@web-architect-expert)

---

**Estado**: ⏳ Listo para implementación paralela
