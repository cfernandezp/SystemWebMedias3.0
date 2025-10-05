# E001-HU-003: Logout Seguro

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E001-HU-003
- **Épica**: E001 - Autenticación y Autorización
- **Título**: Logout Seguro
- **Story Points**: 3 pts
- **Estado**: ⚪ Pendiente

## 🎯 HISTORIA DE USUARIO
**Como** usuario autenticado en el sistema
**Quiero** cerrar sesión de forma segura
**Para** proteger mi cuenta y datos cuando deje de usar la aplicación

## ✅ CRITERIOS DE ACEPTACIÓN

### CA-001: Botón de Logout Visible
- [ ] **DADO** que soy un usuario autenticado
- [ ] **CUANDO** estoy en cualquier página del sistema
- [ ] **ENTONCES** debo ver:
  - [ ] Botón "Cerrar Sesión" en header/navbar
  - [ ] Mi nombre y rol visible en header
  - [ ] Icono de usuario con dropdown menu
  - [ ] Opción "Cerrar Sesión" en dropdown

### CA-002: Logout Exitoso
- [ ] **DADO** que estoy autenticado y quiero cerrar sesión
- [ ] **CUANDO** hago clic en "Cerrar Sesión"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Mostrar modal de confirmación "¿Estás seguro que quieres cerrar sesión?"
  - [ ] Al confirmar, invalidar JWT token
  - [ ] Limpiar almacenamiento local (SecureStorage)
  - [ ] Limpiar estado de autenticación en memoria
  - [ ] Redirigir a página de login
  - [ ] Mostrar mensaje "Sesión cerrada exitosamente"

### CA-003: Cancelar Logout
- [ ] **DADO** que presioné "Cerrar Sesión"
- [ ] **CUANDO** aparece el modal de confirmación
- [ ] **ENTONCES** puedo:
  - [ ] Presionar "Cancelar" para permanecer logueado
  - [ ] Cerrar modal con X o clic fuera
  - [ ] Permanecer en la página actual sin cambios

### CA-004: Logout Automático por Inactividad
- [ ] **DADO** que estoy autenticado pero inactivo
- [ ] **CUANDO** paso más de 2 horas sin actividad
- [ ] **ENTONCES** el sistema debe:
  - [ ] Mostrar warning "Tu sesión expirará en 5 minutos"
  - [ ] Ofrecer botón "Extender sesión"
  - [ ] Si no hay acción, hacer logout automático
  - [ ] Redirigir a login con mensaje "Sesión cerrada por inactividad"

### CA-005: Acceso Post-Logout
- [ ] **DADO** que cerré sesión exitosamente
- [ ] **CUANDO** intento acceder a páginas protegidas
- [ ] **ENTONCES** debo ser:
  - [ ] Redirigido automáticamente al login
  - [ ] Ver mensaje "Debes iniciar sesión para acceder"
  - [ ] No poder ver contenido protegido

### CA-006: Logout desde Múltiples Pestañas
- [ ] **DADO** que tengo la app abierta en múltiples pestañas
- [ ] **CUANDO** hago logout en una pestaña
- [ ] **ENTONCES** todas las pestañas deben:
  - [ ] Detectar que la sesión terminó
  - [ ] Redirigir automáticamente al login
  - [ ] Mostrar mensaje "Sesión cerrada en otra pestaña"

### CA-007: Logout en Modo "Recordarme"
- [ ] **DADO** que inicié sesión con "Recordarme" activado
- [ ] **CUANDO** hago logout manual
- [ ] **ENTONCES** el sistema debe:
  - [ ] Limpiar también el token de larga duración
  - [ ] Requerir login completo en próximo acceso
  - [ ] No mantener sesión persistente

### CA-008: Logout por Token Expirado
- [ ] **DADO** que mi token JWT expiró
- [ ] **CUANDO** intento hacer cualquier acción
- [ ] **ENTONCES** el sistema debe:
  - [ ] Detectar token expirado automáticamente
  - [ ] Hacer logout automático
  - [ ] Redirigir al login
  - [ ] Mostrar "Tu sesión ha expirado. Inicia sesión nuevamente"

## 📋 ESTADOS DE IMPLEMENTACIÓN

### Backend (Supabase)
- [ ] **PENDIENTE** - Edge Function `auth/logout`:
  - [ ] Invalidar JWT token en servidor
  - [ ] Registrar logout en logs de auditoría
  - [ ] Limpiar sesiones activas del usuario

- [ ] **PENDIENTE** - Sistema de Token Blacklist:
  - [ ] Tabla `token_blacklist` para tokens invalidados
  - [ ] Verificación de blacklist en cada request
  - [ ] Limpieza automática de tokens expirados

- [ ] **PENDIENTE** - Detección de Inactividad:
  - [ ] Tracking de última actividad del usuario
  - [ ] Edge Function para verificar inactividad
  - [ ] Configuración de timeouts por rol

### Frontend (Flutter)
- [ ] **PENDIENTE** - LogoutButton component:
  - [ ] Botón visible en header/navbar
  - [ ] Modal de confirmación
  - [ ] Integración con AuthBloc

- [ ] **PENDIENTE** - AuthBloc - Logout Logic:
  - [ ] Evento LogoutRequested
  - [ ] Estado LogoutInProgress
  - [ ] Limpieza de SecureStorage
  - [ ] Navegación a LoginPage

- [ ] **PENDIENTE** - Inactivity Timer:
  - [ ] Detección de inactividad del usuario
  - [ ] Warning modal antes de logout automático
  - [ ] Reset timer en cada interacción

- [ ] **PENDIENTE** - Multi-Tab Sync:
  - [ ] Listener para cambios en storage
  - [ ] Sincronización de estado auth entre pestañas
  - [ ] Logout automático en todas las pestañas

### UX/UI
- [ ] **PENDIENTE** - Logout Components:
  - [ ] UserMenu dropdown con nombre y logout
  - [ ] Modal de confirmación con estilo consistente
  - [ ] Warning modal para inactividad
  - [ ] Feedback visual para logout en progreso

- [ ] **PENDIENTE** - Session States:
  - [ ] Loading spinner durante logout
  - [ ] Mensajes de confirmación claros
  - [ ] Estados de error si logout falla

### QA
- [ ] **PENDIENTE** - Tests todos los criterios:
  - [ ] Logout manual exitoso
  - [ ] Cancelación de logout
  - [ ] Logout automático por inactividad
  - [ ] Acceso post-logout bloqueado
  - [ ] Sincronización multi-pestaña
  - [ ] Logout con y sin "Recordarme"

## ✅ DEFINICIÓN DE TERMINADO (DoD)
- [ ] Todos los criterios de aceptación cumplidos
- [ ] Logout limpia completamente la sesión
- [ ] Inactividad detectada y manejada correctamente
- [ ] Multi-tab sync funcionando
- [ ] Seguridad implementada (token blacklist)
- [ ] UX fluida y mensajes claros
- [ ] QA valida todos los flujos
- [ ] Documentación actualizada

## 🔗 DEPENDENCIAS
- **HU-002**: Login por Roles con Aprobación (debe existir usuario autenticado)

## 🔐 ESPECIFICACIONES DE SEGURIDAD
- **Token Invalidation**: Tokens agregados a blacklist inmediatamente
- **Inactivity Timeout**: 2 horas de inactividad → logout automático
- **Warning Time**: 5 minutos de aviso antes de logout automático
- **Audit Logging**: Registro de todos los logouts (manual/automático)
- **Storage Cleaning**: Limpieza completa de datos locales

## ⏱️ CONFIGURACIÓN DE TIMEOUTS
- **Inactividad General**: 120 minutos
- **Warning Previo**: 5 minutos antes del logout
- **Token Cleanup**: Tokens blacklist limpiados cada 24 horas
- **Multi-tab Sync**: Verificación cada 30 segundos