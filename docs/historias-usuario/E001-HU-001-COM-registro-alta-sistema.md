# E001-HU-001: Registro de Alta al Sistema Web

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E001-HU-001
- **Épica**: E001 - Autenticación y Autorización
- **Título**: Registro de Alta al Sistema Web
- **Story Points**: 8 pts
- **Estado**: ✅ Implementada
- **Fecha Creación**: 2025-01-04
- **Fecha Refinamiento**: 2025-01-04
- **Fecha Inicio Desarrollo**: 2025-10-04
- **Fecha Implementación**: 2025-10-04

## 🎯 HISTORIA DE USUARIO
**Como** usuario nuevo del sistema de medias
**Quiero** registrarme con email, contraseña y nombre completo
**Para** solicitar acceso al sistema y esperar aprobación del administrador

## ✅ CRITERIOS DE ACEPTACIÓN

### CA-001: Formulario de Registro Exitoso
- [ ] **DADO** que soy un nuevo usuario sin cuenta
- [ ] **CUANDO** accedo a la página de registro
- [ ] **ENTONCES** debo ver un formulario con:
  - [ ] Campo Email (obligatorio)
  - [ ] Campo Contraseña (obligatorio)
  - [ ] Campo Confirmar Contraseña (obligatorio)
  - [ ] Campo Nombre Completo (obligatorio)
  - [ ] Botón "Registrarse"
  - [ ] Enlace "¿Ya tienes cuenta? Inicia sesión"

### CA-002: Validaciones de Campos
- [ ] **DADO** que estoy en el formulario de registro
- [ ] **CUANDO** dejo el email vacío
- [ ] **ENTONCES** debo ver "Email es requerido"
- [ ] **CUANDO** ingreso email con formato inválido
- [ ] **ENTONCES** debo ver "Formato de email inválido"
- [ ] **CUANDO** dejo la contraseña vacía
- [ ] **ENTONCES** debo ver "Contraseña es requerida"
- [ ] **CUANDO** la contraseña tiene menos de 8 caracteres
- [ ] **ENTONCES** debo ver "Contraseña debe tener al menos 8 caracteres"
- [ ] **CUANDO** las contraseñas no coinciden
- [ ] **ENTONCES** debo ver "Las contraseñas no coinciden"
- [ ] **CUANDO** dejo el nombre completo vacío
- [ ] **ENTONCES** debo ver "Nombre completo es requerido"

### CA-003: Registro Exitoso
- [ ] **DADO** que completo todos los campos correctamente
- [ ] **CUANDO** presiono "Registrarse"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Crear usuario en BD con estado "REGISTRADO"
  - [ ] Marcar email_verificado como false
  - [ ] Enviar email de confirmación
  - [ ] Mostrar mensaje "Registro exitoso. Revisa tu email para confirmar tu cuenta"
  - [ ] Redirigir a página de "Confirma tu email"

### CA-004: Email Duplicado
- [ ] **DADO** que ingreso un email ya registrado
- [ ] **CUANDO** presiono "Registrarse"
- [ ] **ENTONCES** debo ver "Este email ya está registrado"
- [ ] **Y** debo permanecer en el formulario de registro

### CA-005: Confirmación de Email
- [ ] **DADO** que me registré exitosamente
- [ ] **CUANDO** hago clic en el enlace del email de confirmación
- [ ] **ENTONCES** el sistema debe:
  - [ ] Marcar email_verificado como true
  - [ ] Mostrar mensaje "Email confirmado exitosamente"
  - [ ] Mostrar "Tu cuenta está esperando aprobación del administrador"
  - [ ] Ofrecer botón para ir al login

### CA-006: Enlace de Confirmación Inválido
- [ ] **DADO** que tengo un enlace de confirmación
- [ ] **CUANDO** el enlace es inválido o expirado
- [ ] **ENTONCES** debo ver "Enlace de confirmación inválido o expirado"
- [ ] **Y** debo ver opción "Reenviar email de confirmación"

### CA-007: Reenvío de Email de Confirmación
- [ ] **DADO** que mi enlace de confirmación expiró
- [ ] **CUANDO** presiono "Reenviar email de confirmación"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Generar nuevo enlace de confirmación
  - [ ] Enviar nuevo email
  - [ ] Mostrar "Email de confirmación reenviado"

### CA-008: Intentar Login sin Aprobación
- [ ] **DADO** que confirmé mi email pero admin no me aprobó
- [ ] **CUANDO** intento hacer login
- [ ] **ENTONCES** debo ver "Tu cuenta está esperando aprobación del administrador"
- [ ] **Y** no debo poder acceder al sistema

## 📋 ESTADOS DE IMPLEMENTACIÓN

### Backend (Supabase)
- [x] **COMPLETADO** - Tabla `users` con campos:
  - [x] id (UUID, PRIMARY KEY)
  - [x] email (TEXT, UNIQUE, NOT NULL)
  - [x] password_hash (TEXT, NOT NULL)
  - [x] nombre_completo (TEXT, NOT NULL)
  - [x] rol (ENUM: 'ADMIN', 'GERENTE', 'VENDEDOR', NULL)
  - [x] estado (ENUM: 'REGISTRADO', 'APROBADO', 'RECHAZADO', 'SUSPENDIDO')
  - [x] email_verificado (BOOLEAN, DEFAULT false)
  - [x] token_confirmacion (TEXT, NULLABLE)
  - [x] token_expiracion (TIMESTAMP, NULLABLE)
  - [x] created_at (TIMESTAMP)
  - [x] updated_at (TIMESTAMP)

- [x] **COMPLETADO** - Edge Function `auth/register`:
  - [x] Validar formato de email
  - [x] Verificar email no duplicado
  - [x] Hash de contraseña seguro
  - [x] Generar token de confirmación
  - [x] Enviar email de confirmación
  - [x] Crear registro en BD

- [x] **COMPLETADO** - Edge Function `auth/confirm-email`:
  - [x] Validar token de confirmación
  - [x] Verificar expiración
  - [x] Actualizar email_verificado
  - [x] Limpiar token usado

- [x] **COMPLETADO** - Edge Function `auth/resend-confirmation`:
  - [x] Verificar usuario existe
  - [x] Generar nuevo token
  - [x] Enviar nuevo email

### Frontend (Flutter)
- [x] **COMPLETADO** - RegisterPage:
  - [x] Formulario con validaciones en tiempo real
  - [x] Manejo de estados (loading, success, error)
  - [x] Integración con AuthBloc

- [x] **COMPLETADO** - ConfirmEmailPage:
  - [x] Página de espera de confirmación
  - [x] Manejo de enlaces de confirmación
  - [x] Opción de reenvío

- [x] **COMPLETADO** - AuthBloc:
  - [x] Estados para registro
  - [x] Eventos para cada acción
  - [x] Integración con API de Supabase

### UX/UI
- [x] **COMPLETADO** - RegisterForm component:
  - [x] Diseño responsive
  - [x] Validaciones visuales
  - [x] Estados de loading/error
  - [x] Mensajes de feedback claros

- [x] **COMPLETADO** - EmailConfirmation components:
  - [x] Página de confirmación exitosa
  - [x] Página de enlace inválido
  - [x] Opción de reenvío

### QA
- [x] **COMPLETADO** - Tests todos los criterios de aceptación:
  - [x] Casos felices de registro
  - [x] Validaciones de campos
  - [x] Flujo de confirmación de email
  - [x] Casos de error y edge cases

## ✅ DEFINICIÓN DE TERMINADO (DoD)
- [x] Todos los criterios de aceptación cumplidos
- [x] Backend implementado con Supabase según especificación
- [x] Frontend consume APIs correctamente
- [x] UX/UI sigue Design System
- [x] QA valida todos los flujos
- [x] Script de admin inicial creado
- [x] Documentación actualizada

## 📝 CAMBIOS PENDIENTES POST-IMPLEMENTACIÓN

### CP-001: Auto-aprobación de usuarios tras confirmación de email
**Fecha**: 2025-10-04
**Relacionado con**: HU-002 (Login simple sin gestión de roles)

**Cambio requerido**:
- Al confirmar el email, establecer automáticamente `estado = 'APROBADO'`
- Esto permite que el usuario pueda hacer login inmediatamente después de verificar su email
- Los estados RECHAZADO/SUSPENDIDO se mantienen en la estructura para uso futuro

**Archivos afectados**:
- `supabase/migrations/20251004170000_hu001_database_functions.sql` - Función `confirm_email_verification()`
- Línea específica: Agregar `estado = 'APROBADO'` en el UPDATE de confirmación

**Justificación**:
- Simplifica el flujo inicial del sistema
- Elimina la necesidad de aprobación manual por administrador para empezar
- Preparado para reactivar la aprobación manual en futuras HU de administración

**Estado**: ✅ Completado (2025-10-05)

## 🔗 DEPENDENCIAS
- **Ninguna** - Esta es la primera HU del sistema

## 📧 CONFIGURACIÓN DE EMAIL
- **Proveedor**: Supabase Auth (configurar SMTP)
- **Template**: Email de confirmación con enlace seguro
- **Expiración**: Enlaces válidos por 24 horas
- **Reenvío**: Máximo 3 reenvíos por hora por usuario

---

## 🔐 REGLAS DE NEGOCIO (RN)

### RN-001: Unicidad de Email
**Contexto**: Al registrar un nuevo usuario

**Regla**:
- No pueden existir dos usuarios con el mismo email en el sistema
- El sistema debe rechazar cualquier intento de registro con email duplicado

**Casos especiales**:
- Si el email ya existe pero no fue confirmado → Ofrecer opción de reenviar email de confirmación
- El email debe tratarse sin distinción de mayúsculas/minúsculas (user@example.com = USER@example.com)

---

### RN-002: Requisitos de Contraseña
**Contexto**: Al crear o cambiar contraseña

**Regla**:
- La contraseña debe tener mínimo 8 caracteres
- La contraseña debe confirmarse (escribirse dos veces) para evitar errores de tipeo
- No se almacenan contraseñas en texto plano, solo versiones cifradas

**Casos especiales**:
- Se permiten caracteres especiales y espacios en las contraseñas
- No hay límite máximo de caracteres

---

### RN-003: Confirmación de Email Obligatoria
**Contexto**: Después del registro

**Regla**:
- Todo usuario debe confirmar su email antes de poder ser aprobado por un administrador
- El enlace de confirmación es válido por 24 horas
- Se permite un máximo de 3 reenvíos de email de confirmación por hora (anti-spam)
- Una vez usado exitosamente, el enlace de confirmación queda inválido

**Casos especiales**:
- Si el enlace expira, el usuario puede solicitar un nuevo envío
- Si un administrador intenta aprobar un usuario sin email confirmado, el sistema debe impedirlo

---

### RN-004: Estados del Usuario
**Contexto**: Ciclo de vida del usuario en el sistema

**Estados posibles**:
1. **REGISTRADO**: Usuario creó su cuenta pero aún no fue aprobado
2. **APROBADO**: Usuario tiene acceso completo al sistema
3. **RECHAZADO**: Usuario fue rechazado por un administrador
4. **SUSPENDIDO**: Usuario fue suspendido temporalmente

**Reglas de transición**:
- Un usuario inicia siempre en estado REGISTRADO
- Solo un ADMIN puede cambiar el estado de un usuario
- Un usuario REGISTRADO puede pasar a APROBADO o RECHAZADO
- Un usuario APROBADO puede pasar a SUSPENDIDO
- Un usuario SUSPENDIDO puede volver a APROBADO
- Un usuario RECHAZADO no puede cambiar de estado (permanente)

**Casos especiales**:
- Para aprobar un usuario, su email debe estar confirmado primero
- Un usuario rechazado puede volver a registrarse con un email diferente

---

### RN-005: Control de Acceso al Sistema
**Contexto**: Al intentar iniciar sesión

**Regla**:
- Solo usuarios en estado APROBADO con email confirmado pueden acceder al sistema

**Mensajes según estado**:
- REGISTRADO + email NO confirmado → "Debes confirmar tu email para continuar"
- REGISTRADO + email confirmado → "Tu cuenta está esperando aprobación del administrador"
- APROBADO + email confirmado → Permitir acceso
- RECHAZADO → "Tu solicitud de acceso fue rechazada. Contacta al administrador"
- SUSPENDIDO → "Tu cuenta ha sido suspendida. Contacta al administrador"

**Casos especiales**:
- Si un usuario con sesión activa es suspendido, debe ser desconectado automáticamente
- Los usuarios rechazados o suspendidos no deben poder realizar ninguna acción en el sistema

---

### RN-006: Campos Obligatorios en Registro
**Contexto**: Al completar el formulario de registro

**Regla**:
- Email: Obligatorio, debe tener formato válido (contener @ y dominio)
- Contraseña: Obligatoria, mínimo 8 caracteres
- Confirmar Contraseña: Obligatoria, debe coincidir exactamente con la contraseña
- Nombre Completo: Obligatorio, no puede estar vacío

**Casos especiales**:
- Los espacios al inicio y final del nombre completo deben ignorarse
- El nombre completo puede contener caracteres especiales (tildes, ñ, etc.)

---

### RN-007: Asignación de Rol
**Contexto**: Al aprobar un usuario

**Regla**:
- Un usuario REGISTRADO no tiene rol asignado
- Un administrador debe asignar un rol al aprobar al usuario
- Los roles disponibles son: ADMIN, GERENTE, VENDEDOR
- Un usuario solo puede tener un rol a la vez

**Casos especiales**:
- El primer usuario del sistema (creado por script) debe ser ADMIN
- Un ADMIN puede cambiar el rol de otros usuarios en cualquier momento
- No se puede eliminar el último usuario con rol ADMIN del sistema