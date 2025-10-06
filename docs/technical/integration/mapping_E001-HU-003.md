# Mapping Backend ↔ Frontend - E001-HU-003: Logout Seguro

**HU**: E001-HU-003 - Logout Seguro
**Fecha**: 2025-10-06

---

## 📊 TABLA DE MAPPING

### 1. Logout User (logout_user)

| PostgreSQL (snake_case) | Dart (camelCase) | Tipo | Dirección | Notas |
|------------------------|------------------|------|-----------|-------|
| **REQUEST** | | | | |
| `p_token` | `token` | String | → | Token JWT a invalidar |
| `p_user_id` | `userId` | String (UUID) | → | ID del usuario |
| `p_logout_type` | `logoutType` | String | → | 'manual', 'inactivity', 'token_expired' |
| `p_ip_address` | `ipAddress` | String? (INET) | → | IP del cliente (opcional) |
| `p_user_agent` | `userAgent` | String? | → | User agent del navegador (opcional) |
| `p_session_duration` | `sessionDuration` | int? (seconds) | → | Duración de la sesión en segundos |
| **RESPONSE** | | | | |
| `message` | `message` | String | ← | Mensaje de confirmación |
| `logout_type` | `logoutType` | String | ← | Tipo de logout ejecutado |
| `blacklisted_at` | `blacklistedAt` | DateTime | ← | Timestamp de invalidación |

**Ejemplo Request**:
```dart
// Dart
final request = LogoutRequestModel(
  token: 'eyJhbGc...',
  userId: 'a1b2c3d4-...',
  logoutType: 'manual',
  ipAddress: '192.168.1.1',
  userAgent: 'Mozilla/5.0...',
  sessionDuration: Duration(minutes: 45),
);

// JSON enviado a Supabase
{
  "p_token": "eyJhbGc...",
  "p_user_id": "a1b2c3d4-...",
  "p_logout_type": "manual",
  "p_ip_address": "192.168.1.1",
  "p_user_agent": "Mozilla/5.0...",
  "p_session_duration": 2700  // seconds
}
```

**Ejemplo Response**:
```json
// JSON de Supabase
{
  "success": true,
  "data": {
    "message": "Sesión cerrada exitosamente",
    "logout_type": "manual",
    "blacklisted_at": "2025-10-06T10:30:00Z"
  }
}

// Dart
final response = LogoutResponseModel(
  message: 'Sesión cerrada exitosamente',
  logoutType: 'manual',
  blacklistedAt: DateTime.parse('2025-10-06T10:30:00Z'),
);
```

---

### 2. Check Token Blacklist (check_token_blacklist)

| PostgreSQL (snake_case) | Dart (camelCase) | Tipo | Dirección | Notas |
|------------------------|------------------|------|-----------|-------|
| **REQUEST** | | | | |
| `p_token` | `token` | String | → | Token a verificar |
| **RESPONSE** | | | | |
| `is_blacklisted` | `isBlacklisted` | bool | ← | true si token invalidado |
| `reason` | `reason` | String? | ← | Motivo de invalidación |
| `message` | `message` | String | ← | Mensaje descriptivo |

**Ejemplo**:
```dart
// Dart Request
final token = 'eyJhbGc...';

// JSON Response
{
  "success": true,
  "data": {
    "is_blacklisted": true,
    "reason": "manual_logout",
    "message": "Token inválido. Debes iniciar sesión nuevamente"
  }
}

// Dart Model
final check = TokenBlacklistCheckModel(
  isBlacklisted: true,
  reason: 'manual_logout',
  message: 'Token inválido. Debes iniciar sesión nuevamente',
);
```

---

### 3. Check User Inactivity (check_user_inactivity)

| PostgreSQL (snake_case) | Dart (camelCase) | Tipo | Dirección | Notas |
|------------------------|------------------|------|-----------|-------|
| **REQUEST** | | | | |
| `p_user_id` | `userId` | String (UUID) | → | ID del usuario |
| `p_timeout_minutes` | `timeoutMinutes` | int | → | Default: 120 minutos |
| **RESPONSE** | | | | |
| `is_inactive` | `isInactive` | bool | ← | true si inactivo > timeout |
| `last_activity_at` | `lastActivityAt` | DateTime | ← | Última actividad registrada |
| `inactive_minutes` | `inactiveMinutes` | int | ← | Minutos de inactividad |
| `minutes_until_logout` | `minutesUntilLogout` | int | ← | Minutos restantes |
| `should_warn` | `shouldWarn` | bool | ← | true si debe mostrar warning |
| `message` | `message` | String | ← | Mensaje descriptivo |

**Ejemplo**:
```dart
// Dart Request
final userId = 'a1b2c3d4-...';

// JSON Response (Usuario inactivo)
{
  "success": true,
  "data": {
    "is_inactive": true,
    "last_activity_at": "2025-10-06T08:00:00Z",
    "inactive_minutes": 125,
    "minutes_until_logout": 0,
    "should_warn": false,
    "message": "Usuario inactivo. Sesión debe cerrarse"
  }
}

// JSON Response (Warning - 5 min restantes)
{
  "success": true,
  "data": {
    "is_inactive": false,
    "last_activity_at": "2025-10-06T10:10:00Z",
    "inactive_minutes": 115,
    "minutes_until_logout": 5,
    "should_warn": true,
    "message": "Tu sesión expirará en 5 minutos"
  }
}

// Dart Model
final status = InactivityStatusModel(
  isInactive: false,
  lastActivityAt: DateTime.parse('2025-10-06T10:10:00Z'),
  inactiveMinutes: 115,
  minutesUntilLogout: 5,
  shouldWarn: true,
  message: 'Tu sesión expirará en 5 minutos',
);
```

---

### 4. Update User Activity (update_user_activity)

| PostgreSQL (snake_case) | Dart (camelCase) | Tipo | Dirección | Notas |
|------------------------|------------------|------|-----------|-------|
| **REQUEST** | | | | |
| `p_user_id` | `userId` | String (UUID) | → | ID del usuario |
| **RESPONSE** | | | | |
| `last_activity_at` | `lastActivityAt` | DateTime | ← | Nueva timestamp de actividad |
| `message` | `message` | String | ← | "Actividad actualizada" |

**Ejemplo**:
```dart
// Dart - Llamar en cada interacción del usuario
await authRepository.updateUserActivity(userId);

// JSON Response
{
  "success": true,
  "data": {
    "last_activity_at": "2025-10-06T10:35:00Z",
    "message": "Actividad actualizada"
  }
}
```

---

### 5. Get User Audit Logs (get_user_audit_logs)

| PostgreSQL (snake_case) | Dart (camelCase) | Tipo | Dirección | Notas |
|------------------------|------------------|------|-----------|-------|
| **REQUEST** | | | | |
| `p_user_id` | `userId` | String (UUID) | → | ID del usuario |
| `p_event_type` | `eventType` | String? | → | Filtrar por tipo (opcional) |
| `p_limit` | `limit` | int | → | Default: 20 |
| **RESPONSE** | | | | |
| `logs` | `logs` | List<AuditLog> | ← | Array de logs |
| `count` | `count` | int | ← | Total de logs del usuario |

**Ejemplo**:
```json
// JSON Response
{
  "success": true,
  "data": {
    "logs": [
      {
        "id": "log-uuid-1",
        "event_type": "logout",
        "event_subtype": "manual",
        "ip_address": "192.168.1.1",
        "user_agent": "Mozilla/5.0...",
        "metadata": {
          "session_duration": 2700,
          "logout_type": "manual"
        },
        "created_at": "2025-10-06T10:30:00Z"
      }
    ],
    "count": 15
  }
}
```

```dart
// Dart Model
final logs = [
  AuditLogModel(
    id: 'log-uuid-1',
    eventType: 'logout',
    eventSubtype: 'manual',
    ipAddress: '192.168.1.1',
    userAgent: 'Mozilla/5.0...',
    metadata: {
      'session_duration': 2700,
      'logout_type': 'manual',
    },
    createdAt: DateTime.parse('2025-10-06T10:30:00Z'),
  ),
];
```

---

## 🔄 FLUJO COMPLETO DE DATOS

### Logout Manual

```
[UI] UserMenuDropdown
  ↓ onLogoutPressed()
[Widget] LogoutConfirmationDialog.show()
  ↓ confirmed = true
[Bloc] AuthBloc.add(LogoutRequested())
  ↓
[UseCase] LogoutUseCase.call()
  ↓
[Repository] AuthRepository.logout()
  ↓
[Datasource] AuthRemoteDatasource.logout()
  ↓ HTTP Request
[Supabase] logout_user(p_token, p_user_id, 'manual')
  ↓ SQL
[DB] INSERT INTO token_blacklist + audit_logs
  ↓ JSON Response
[Datasource] LogoutResponseModel.fromJson()
  ↓
[Repository] Either<Failure, LogoutResponseModel>
  ↓
[Bloc] emit(LogoutSuccess())
  ↓
[UI] BlocListener → SessionExpiredSnackbar + Navigator.pushNamed('/login')
```

---

### Logout por Inactividad

```
[Service] InactivityTimerService (115 minutos)
  ↓ onWarning(5)
[Bloc] emit(InactivityWarning(minutesRemaining: 5))
  ↓
[UI] InactivityWarningDialog.show()
  ↓ Usuario NO interactúa (5 minutos)
[Service] InactivityTimerService (120 minutos)
  ↓ onInactive()
[Bloc] AuthBloc.add(InactivityDetected())
  ↓
[Repository] AuthRepository.logout(logoutType: 'inactivity')
  ↓
[Supabase] logout_user(p_token, p_user_id, 'inactivity')
  ↓
[UI] Navigator.pushNamed('/login') + Snackbar("Sesión cerrada por inactividad")
```

---

### Multi-Tab Logout

```
[Pestaña A] Usuario hace logout
  ↓
[Datasource] SecureStorage.remove('auth_token')
  ↓
[Service] MultiTabSyncService → localStorage.removeItem('auth_token')
  ↓ storage event
[Pestaña B] MultiTabSyncService detecta evento
  ↓ _storageEventController.add('logout_detected')
[Bloc B] AuthBloc escucha stream
  ↓
[Bloc B] emit(TokenBlacklisted())
  ↓
[UI B] Navigator.pushNamed('/login') + Snackbar("Sesión cerrada en otra pestaña")
```

---

## 🔐 CONSIDERACIONES DE SEGURIDAD

### Token Handling

```dart
// ✅ CORRECTO: NO enviar token completo en logs
final sanitizedToken = token.substring(0, 10) + '...';
print('Logout token: $sanitizedToken');

// ❌ INCORRECTO: Exponer token completo
print('Logout token: $token');  // ❌
```

### IP Address Capture

```dart
// Backend debe capturar IP, NO Flutter
// Flutter solo pasa user agent

final userAgent = html.window.navigator.userAgent;

final request = LogoutRequestModel(
  token: token,
  userId: userId,
  userAgent: userAgent,
  // ipAddress se captura en backend desde headers HTTP
);
```

---

## ✅ VALIDACIONES

### En Datasource (Flutter)

```dart
// Validar respuesta de Supabase
if (result['success'] == true) {
  return LogoutResponseModel.fromJson(result['data']);
} else {
  final error = result['error'] as Map<String, dynamic>;
  final hint = error['hint'] as String?;

  if (hint == 'token_blacklisted') {
    throw TokenBlacklistedException(error['message']);
  } else if (hint == 'already_blacklisted') {
    throw AlreadyLoggedOutException(error['message']);
  }
  throw ServerException(error['message']);
}
```

### En Backend (PostgreSQL)

```sql
-- Validar que token no esté ya en blacklist
IF EXISTS (SELECT 1 FROM token_blacklist WHERE token = p_token) THEN
    v_error_hint := 'already_blacklisted';
    RAISE EXCEPTION 'Token ya invalidado';
END IF;
```

---

## 📝 NOTAS DE IMPLEMENTACIÓN

1. **Duration Conversion**: `sessionDuration` en Dart (Duration) → `p_session_duration` en SQL (seconds)
2. **DateTime Parsing**: Siempre usar ISO 8601 (`toIso8601String()` / `DateTime.parse()`)
3. **Null Safety**: Campos opcionales (`ipAddress?`, `userAgent?`) deben manejarse correctamente
4. **Error Hints**: Mapear hints de PostgreSQL a excepciones específicas en Dart
5. **Multi-Tab**: `localStorage` events solo funcionan en Flutter Web

---

## 🧪 TESTING INTEGRATION

```dart
// test/features/auth/data/datasources/auth_remote_datasource_test.dart

void main() {
  group('logout', () {
    test('should call logout_user with correct parameters', () async {
      // Arrange
      final request = LogoutRequestModel(
        token: 'test-token',
        userId: 'user-123',
        logoutType: 'manual',
        sessionDuration: Duration(minutes: 30),
      );

      when(() => mockSupabase.rpc('logout_user', params: any(named: 'params')))
          .thenAnswer((_) async => {
                'success': true,
                'data': {
                  'message': 'Sesión cerrada exitosamente',
                  'logout_type': 'manual',
                  'blacklisted_at': '2025-10-06T10:30:00Z',
                }
              });

      // Act
      final result = await datasource.logout(request);

      // Assert
      verify(() => mockSupabase.rpc('logout_user', params: {
            'p_token': 'test-token',
            'p_user_id': 'user-123',
            'p_logout_type': 'manual',
            'p_session_duration': 1800,  // 30 minutes in seconds
          })).called(1);

      expect(result.message, 'Sesión cerrada exitosamente');
      expect(result.logoutType, 'manual');
    });
  });
}
```

---

**Estado**: ⏳ Pendiente de implementación
**Próximo paso**: Coordinar agentes en paralelo para implementación
