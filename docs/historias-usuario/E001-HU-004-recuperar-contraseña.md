# E001-HU-004: Recuperar Contraseña

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E001-HU-004
- **Épica**: E001 - Autenticación y Autorización
- **Título**: Recuperar Contraseña
- **Story Points**: 5 pts
- **Estado**: ⚪ Pendiente

## 🎯 HISTORIA DE USUARIO
**Como** usuario registrado y aprobado que olvidó su contraseña
**Quiero** recuperar el acceso a mi cuenta mediante email
**Para** poder volver a utilizar el sistema sin perder mi cuenta

## ✅ CRITERIOS DE ACEPTACIÓN

### CA-001: Enlace "Olvidé mi Contraseña"
- [ ] **DADO** que estoy en la página de login
- [ ] **CUANDO** veo el formulario de inicio de sesión
- [ ] **ENTONCES** debo ver:
  - [ ] Enlace "¿Olvidaste tu contraseña?" debajo del formulario
  - [ ] Enlace bien visible y accesible
  - [ ] Al hacer clic, redirigir a página de recuperación

### CA-002: Formulario de Recuperación
- [ ] **DADO** que hago clic en "Olvidé mi contraseña"
- [ ] **CUANDO** accedo a la página de recuperación
- [ ] **ENTONCES** debo ver:
  - [ ] Título "Recuperar Contraseña"
  - [ ] Campo Email (obligatorio)
  - [ ] Botón "Enviar enlace de recuperación"
  - [ ] Enlace "Volver al login"
  - [ ] Texto explicativo del proceso

### CA-003: Solicitud de Recuperación Exitosa
- [ ] **DADO** que soy usuario registrado, aprobado y con email verificado
- [ ] **CUANDO** ingreso mi email y presiono "Enviar enlace"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Validar que el email existe y está aprobado
  - [ ] Generar token de recuperación único
  - [ ] Enviar email con enlace de recuperación
  - [ ] Mostrar "Si el email existe, se enviará un enlace de recuperación"
  - [ ] Redirigir a página de confirmación

### CA-004: Email No Registrado
- [ ] **DADO** que ingreso email que no existe en el sistema
- [ ] **CUANDO** presiono "Enviar enlace de recuperación"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Mostrar mismo mensaje: "Si el email existe, se enviará un enlace"
  - [ ] No revelar que el email no está registrado (seguridad)
  - [ ] No enviar email real
  - [ ] Registrar intento en logs

### CA-005: Usuario No Aprobado
- [ ] **DADO** que soy usuario registrado pero no aprobado por admin
- [ ] **CUANDO** solicito recuperación de contraseña
- [ ] **ENTONCES** el sistema debe:
  - [ ] Mostrar mensaje genérico de envío
  - [ ] Enviar email explicando que cuenta no está aprobada
  - [ ] No generar token de recuperación
  - [ ] Sugerir contactar administrador

### CA-006: Email de Recuperación
- [ ] **DADO** que solicité recuperación exitosamente
- [ ] **CUANDO** reviso mi email
- [ ] **ENTONCES** debo recibir:
  - [ ] Email con asunto "Recuperación de Contraseña - Sistema Medias"
  - [ ] Enlace seguro para cambiar contraseña
  - [ ] Instrucciones claras del proceso
  - [ ] Aviso de expiración (24 horas)
  - [ ] Nota de seguridad si no solicité el cambio

### CA-007: Enlace de Recuperación Válido
- [ ] **DADO** que recibí email de recuperación
- [ ] **CUANDO** hago clic en el enlace dentro de 24 horas
- [ ] **ENTONCES** debo:
  - [ ] Ser redirigido a página de "Nueva Contraseña"
  - [ ] Ver formulario con campos "Nueva Contraseña" y "Confirmar Contraseña"
  - [ ] Ver token válido confirmado en la URL

### CA-008: Formulario Nueva Contraseña
- [ ] **DADO** que accedí via enlace de recuperación válido
- [ ] **CUANDO** estoy en página de nueva contraseña
- [ ] **ENTONCES** debo ver:
  - [ ] Campo "Nueva Contraseña" (obligatorio, mínimo 8 caracteres)
  - [ ] Campo "Confirmar Contraseña" (obligatorio)
  - [ ] Validaciones en tiempo real
  - [ ] Botón "Cambiar Contraseña"
  - [ ] Indicador de fortaleza de contraseña

### CA-009: Cambio de Contraseña Exitoso
- [ ] **DADO** que completé formulario con contraseñas válidas que coinciden
- [ ] **CUANDO** presiono "Cambiar Contraseña"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Validar token de recuperación nuevamente
  - [ ] Actualizar password_hash en BD
  - [ ] Invalidar token de recuperación usado
  - [ ] Mostrar "Contraseña cambiada exitosamente"
  - [ ] Redirigir al login automáticamente

### CA-010: Enlace de Recuperación Expirado
- [ ] **DADO** que tengo enlace de recuperación de más de 24 horas
- [ ] **CUANDO** hago clic en el enlace
- [ ] **ENTONCES** debo ver:
  - [ ] Mensaje "Enlace de recuperación expirado"
  - [ ] Botón "Solicitar nuevo enlace"
  - [ ] Redirección a formulario de recuperación

### CA-011: Enlace de Recuperación Inválido
- [ ] **DADO** que tengo enlace de recuperación manipulado o inválido
- [ ] **CUANDO** intento acceder
- [ ] **ENTONCES** debo ver:
  - [ ] Mensaje "Enlace de recuperación inválido"
  - [ ] Botón "Solicitar nuevo enlace"
  - [ ] Redirección a formulario de recuperación

### CA-012: Límite de Solicitudes
- [ ] **DADO** que ya solicité recuperación recientemente
- [ ] **CUANDO** intento solicitar otra vez dentro de 15 minutos
- [ ] **ENTONCES** debo ver:
  - [ ] "Ya se envió un enlace recientemente. Espera 15 minutos"
  - [ ] Tiempo restante hasta poder solicitar nuevamente
  - [ ] Opción "No recibí el email" con troubleshooting

## 📋 ESTADOS DE IMPLEMENTACIÓN

### Backend (Supabase)
- [ ] **PENDIENTE** - Tabla `password_recovery`:
  - [ ] user_id (FK a users)
  - [ ] token (TEXT, UNIQUE)
  - [ ] expires_at (TIMESTAMP)
  - [ ] used_at (TIMESTAMP, NULLABLE)
  - [ ] created_at (TIMESTAMP)

- [ ] **PENDIENTE** - Edge Function `auth/forgot-password`:
  - [ ] Validar email existe y está aprobado
  - [ ] Verificar límite de solicitudes (15 min)
  - [ ] Generar token seguro (32 bytes random)
  - [ ] Guardar en tabla password_recovery
  - [ ] Enviar email con enlace

- [ ] **PENDIENTE** - Edge Function `auth/reset-password`:
  - [ ] Validar token existe y no expiró
  - [ ] Verificar token no fue usado
  - [ ] Validar nueva contraseña
  - [ ] Actualizar password_hash
  - [ ] Marcar token como usado

- [ ] **PENDIENTE** - Limpieza automática:
  - [ ] Job para limpiar tokens expirados
  - [ ] Ejecutar diariamente

### Frontend (Flutter)
- [ ] **PENDIENTE** - ForgotPasswordPage:
  - [ ] Formulario con email
  - [ ] Validaciones de formato
  - [ ] Estados de loading/success/error
  - [ ] Navegación de regreso al login

- [ ] **PENDIENTE** - ResetPasswordPage:
  - [ ] Captura token desde URL
  - [ ] Formulario nueva contraseña
  - [ ] Validaciones de contraseña
  - [ ] Indicador de fortaleza
  - [ ] Confirmación de contraseñas

- [ ] **PENDIENTE** - AuthBloc Updates:
  - [ ] Estados para forgot/reset password
  - [ ] Eventos ForgotPasswordRequested, ResetPasswordRequested
  - [ ] Manejo de errores específicos

### UX/UI
- [ ] **PENDIENTE** - ForgotPassword Components:
  - [ ] Formulario responsive
  - [ ] Mensajes de feedback claros
  - [ ] Estados de loading
  - [ ] Enlace de regreso al login

- [ ] **PENDIENTE** - ResetPassword Components:
  - [ ] Formulario con validaciones visuales
  - [ ] Medidor de fortaleza de contraseña
  - [ ] Confirmación visual de éxito
  - [ ] Manejo de errores (token inválido/expirado)

### QA
- [ ] **PENDIENTE** - Tests todos los criterios:
  - [ ] Flujo completo de recuperación exitosa
  - [ ] Validaciones de email (existente/no existente)
  - [ ] Casos de usuario no aprobado
  - [ ] Expiración y invalidez de tokens
  - [ ] Límites de solicitudes
  - [ ] Seguridad (no exposición de datos)

## ✅ DEFINICIÓN DE TERMINADO (DoD)
- [ ] Todos los criterios de aceptación cumplidos
- [ ] Flujo de recuperación funciona end-to-end
- [ ] Emails se envían correctamente
- [ ] Tokens seguros y con expiración
- [ ] Límites de rate-limiting implementados
- [ ] No se expone información sensible
- [ ] QA valida todos los flujos
- [ ] Documentación actualizada

## 🔗 DEPENDENCIAS
- **HU-001**: Registro de Alta al Sistema Web (debe existir usuario registrado)
- **HU-002**: Login por Roles con Aprobación (para verificar estado aprobado)

## 🔐 ESPECIFICACIONES DE SEGURIDAD
- **Token Generation**: 32 bytes random, URL-safe encoding
- **Token Expiration**: 24 horas desde generación
- **Rate Limiting**: 1 solicitud cada 15 minutos por email
- **Single Use**: Tokens invalidados después de uso exitoso
- **Email Privacy**: No revelar si email existe o no
- **Password Policy**: Mínimo 8 caracteres, validación de fortaleza

## 📧 CONFIGURACIÓN DE EMAIL
- **Template**: Email de recuperación con branding del sistema
- **Subject**: "Recuperación de Contraseña - Sistema Medias"
- **From**: "noreply@sistema-medias.com"
- **Tracking**: Logs de emails enviados para auditoría
- **Cleanup**: Tokens expirados limpiados cada 24 horas