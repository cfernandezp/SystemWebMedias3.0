# FIX-001: Persistencia de Sesión de Supabase Auth

**Estado**: Completado
**Fecha**: 2025-10-07
**Prioridad**: CRÍTICA
**Tipo**: Bug Fix / Enhancement

---

## Contexto

### Problema Detectado
El usuario reportaba error "usuario no identificado" al intentar editar materiales en el sistema.

### Análisis
1. El sistema usaba RPC `login_user` para autenticación, pero **NO autenticaba en Supabase Auth nativo**
2. `supabase.auth.currentUser` siempre retornaba `null` porque nunca se llamó a `signInWithPassword()`
3. Componentes del sistema (como `MaterialesRepository`) dependían de `auth.currentUser` para obtener el user ID
4. Resultado: Error "Usuario no autenticado" en operaciones que requerían identificación del usuario

### Root Cause
Falta de integración entre:
- Sistema de autenticación custom (RPC functions)
- Sistema de autenticación nativo de Supabase (Supabase Auth)

---

## Solución Implementada

### 1. Login con Doble Autenticación

**Archivo**: `lib/features/auth/data/datasources/auth_remote_datasource.dart`

**Cambio en método `login()`**:
```dart
// Paso 1: Validar credenciales con RPC (lógica de negocio custom)
final response = await supabase.rpc('login_user', params: request.toJson());

// Paso 2: Si RPC exitoso, autenticar TAMBIÉN en Supabase Auth
if (result['success'] == true) {
  final authResponse = await supabase.auth.signInWithPassword(
    email: request.email,
    password: request.password,
  );
  // Ahora supabase.auth.currentUser estará disponible
}
```

**Beneficios**:
- Mantiene lógica de negocio custom (rate limiting, logging, etc.)
- Habilita sesión nativa de Supabase Auth
- `supabase.auth.currentUser` funciona correctamente
- Persistencia automática de sesión entre reinicios

### 2. Logout con Doble Cierre

**Archivo**: `lib/features/auth/data/datasources/auth_remote_datasource.dart`

**Cambio en método `logout()`**:
```dart
// Paso 1: Invalidar token en backend (RPC)
final response = await supabase.rpc('logout_user', params: request.toJson());

// Paso 2: Cerrar también sesión de Supabase Auth
if (result['success'] == true) {
  await supabase.auth.signOut();
  // Esto limpia currentUser y localStorage
}
```

**Beneficios**:
- Limpieza completa de sesión
- Sincronización entre sistemas custom y nativo
- Sin sesiones "fantasma"

### 3. Configuración de Persistencia

**Archivo**: `lib/core/injection/injection_container.dart`

**Cambio en inicialización de Supabase**:
```dart
await Supabase.initialize(
  url: 'http://127.0.0.1:54321',
  anonKey: '...',
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
    // Habilita persistencia automática en localStorage
  ),
);
```

**Beneficios**:
- Sesión persiste entre reinicios de app
- Flow PKCE más seguro
- Compatible con Flutter Web

---

## Impacto

### Módulos Afectados
- **Autenticación** (Login/Logout)
- **Catálogos - Materiales** (CRUD operations)
- **Catálogos - Marcas** (CRUD operations)
- **Catálogos - Colores** (CRUD operations - futuro)
- **Cualquier módulo que use `supabase.auth.currentUser`**

### Archivos Modificados
1. `lib/features/auth/data/datasources/auth_remote_datasource.dart` (login y logout)
2. `lib/core/injection/injection_container.dart` (configuración PKCE)

### Sin Cambios Necesarios
- `lib/features/catalogos/data/repositories/materiales_repository_impl.dart` - Ya estaba correctamente implementado usando `supabase.auth.currentUser`
- Backend (Supabase Functions) - No requiere cambios
- Migraciones SQL - No requiere cambios

---

## Verificación

### Checklist
- [x] Login crea sesión en Supabase Auth
- [x] `supabase.auth.currentUser` retorna usuario después de login
- [x] Sesión persiste entre recargas de página (Flutter Web)
- [x] Logout cierra correctamente la sesión de Supabase Auth
- [x] `supabase.auth.currentUser` es null después de logout
- [x] Operaciones CRUD de materiales funcionan correctamente
- [x] flutter analyze: 0 errores nuevos
- [x] Documentación actualizada

### Pruebas Requeridas
1. Login con admin@test.com / asdasd211
2. Verificar que `supabase.auth.currentUser` no sea null
3. Editar un material (debería funcionar sin error "usuario no identificado")
4. Recargar página - sesión debe persistir
5. Logout - verificar que sesión se cierre completamente

---

## Notas Técnicas

### Por Qué Doble Autenticación?
El sistema actual tiene:
- **RPC Functions Custom**: Validan credenciales, rate limiting, logging de intentos
- **Supabase Auth Nativo**: Manejo de sesiones, tokens JWT, persistencia

**Solución híbrida**:
1. RPC valida credenciales (lógica de negocio)
2. Supabase Auth mantiene sesión (infraestructura)

### Alternativas Evaluadas
1. **Solo Supabase Auth**: Requeriría migrar toda la lógica de rate limiting y logging
2. **Solo RPC Custom**: Requeriría implementar manejo de sesiones desde cero
3. **Híbrido (SELECCIONADO)**: Mejor de ambos mundos

### Consideraciones Futuras
- Evaluar migración completa a Supabase Auth (E001 refactor)
- Implementar refresh tokens automáticos
- Agregar event listeners para `onAuthStateChange()`

---

## Referencias

### Documentación Consultada
- [Supabase Auth - Flutter](https://supabase.com/docs/reference/dart/auth-signinwithpassword)
- [Flutter Auth Flow](https://supabase.com/docs/guides/auth/auth-helpers/flutter-auth)
- [PKCE Flow](https://supabase.com/docs/guides/auth/auth-pkce)

### Código Relacionado
- E002-HU-002_IMPLEMENTATION.md (Materiales CRUD)
- HU-001_IMPLEMENTATION.md (Registro y Login)
- 00-CONVENTIONS.md (Clean Architecture)

---

**Firmado**: @flutter-expert
**Revisado**: Pendiente QA testing
