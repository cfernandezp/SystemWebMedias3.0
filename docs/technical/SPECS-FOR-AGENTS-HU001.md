# Especificaciones para Agentes Técnicos - HU-001

**HU**: E001-HU-001: Registro de Alta al Sistema
**Arquitecto**: @web-architect-expert
**Fecha**: 2025-10-04

---

## ⚠️ TODOS LOS AGENTES: LEER ANTES DE IMPLEMENTAR

**OBLIGATORIO**:
1. 📖 **[00-CONVENTIONS.md](00-CONVENTIONS.md)** - Fuente única de verdad (Naming, Routing, Error Handling, etc.)
2. 📋 **[QUICK_CHECKLIST.md](QUICK_CHECKLIST.md)** - Checklist rápido de validación

**Si hay conflicto entre documentos**: `00-CONVENTIONS.md` tiene PRIORIDAD MÁXIMA.

---

## Para @supabase-expert

### Tarea: Implementar Backend de HU-001

**⚠️ LEER PRIMERO**:
- [00-CONVENTIONS.md](00-CONVENTIONS.md) - Secciones: Naming (1), Error Handling (3), API Response (4)
- [QUICK_CHECKLIST.md](QUICK_CHECKLIST.md) - Sección: Backend

**Archivos de diseño:**
- C:/SystemWebMedias3.0/docs/technical/backend/schema_hu001.md
- C:/SystemWebMedias3.0/docs/technical/backend/apis_hu001.md
- C:/SystemWebMedias3.0/docs/technical/integration/mapping_hu001.md

**Implementar:**

1. **Migration**: `supabase/migrations/YYYYMMDDHHMMSS_create_users_table.sql`
   - Crear ENUM `user_role` con valores: ADMIN, GERENTE, VENDEDOR
   - Crear ENUM `user_estado` con valores: REGISTRADO, APROBADO, RECHAZADO, SUSPENDIDO
   - Crear tabla `users` con 11 campos (ver schema_hu001.md)
   - Crear 3 índices optimizados (email case-insensitive, estado, token)
   - Crear función `update_updated_at_column()` para auto-update
   - Crear trigger `update_users_updated_at`
   - Habilitar RLS y crear 3 policies (ADMIN view all, users view own, ADMIN update)

2. **Edge Functions**:
   - `supabase/functions/auth/register.ts`:
     - POST endpoint que recibe: email, password, confirm_password, nombre_completo
     - Validar todos los campos según RN-006
     - Validar email único (RN-001) con LOWER(email)
     - Validar contraseña >= 8 caracteres (RN-002)
     - Verificar password === confirm_password
     - Hashear contraseña con bcrypt (rounds: 10)
     - Generar token_confirmacion (crypto.randomUUID())
     - Establecer token_expiracion = NOW() + 24 horas
     - Insertar usuario con estado REGISTRADO
     - Enviar email de confirmación
     - Response 201 con datos usuario (sin password_hash ni tokens)
     - Response 400 para errores de validación
     - Response 409 para email duplicado

   - `supabase/functions/auth/confirm-email.ts`:
     - GET endpoint con query param: token
     - Buscar usuario por token_confirmacion
     - Verificar token no expirado (token_expiracion > NOW())
     - Verificar email_verificado === false (no reutilizar token)
     - UPDATE: email_verificado = true, token_confirmacion = NULL, token_expiracion = NULL
     - Response 200 con mensaje de éxito
     - Response 400 para token inválido/expirado

   - `supabase/functions/auth/resend-confirmation.ts`:
     - POST endpoint que recibe: email
     - Buscar usuario por LOWER(email)
     - Verificar email_verificado === false
     - Implementar límite 3 reenvíos/hora (RN-003) - usar tabla auxiliar o columna contador
     - Generar nuevo token_confirmacion
     - Actualizar token_expiracion = NOW() + 24 horas
     - Enviar nuevo email
     - Response 200 con mensaje de éxito
     - Response 400 si email ya verificado
     - Response 429 si excede límite de reenvíos

3. **Configuración Email**:
   - Configurar SMTP en Supabase
   - Crear template HTML con tema turquesa corporativo (ver apis_hu001.md)
   - Enlace: https://[app-domain]/confirm?token={token_confirmacion}

**Validaciones críticas:**
- RN-001: Email único case-insensitive
- RN-002: Contraseña >= 8 caracteres, hashed, confirmación
- RN-003: Token 24h, límite 3 reenvíos/hora
- RN-006: Campos obligatorios con formatos correctos

**Al terminar:**
- Actualizar secciones "SQL Final Implementado" en schema_hu001.md
- Actualizar secciones "Lógica Implementada" en apis_hu001.md
- Documentar cualquier cambio vs diseño inicial
- Probar manualmente los 3 endpoints

---

## Para @flutter-expert

### Tarea: Implementar Models, Bloc y Repository de HU-001

**⚠️ LEER PRIMERO**:
- [00-CONVENTIONS.md](00-CONVENTIONS.md) - Secciones: Naming (1.2), Routing (2), Error Handling (3.2)
- [QUICK_CHECKLIST.md](QUICK_CHECKLIST.md) - Sección: Frontend

**Archivos de diseño:**
- C:/SystemWebMedias3.0/docs/technical/frontend/models_hu001.md
- C:/SystemWebMedias3.0/docs/technical/integration/mapping_hu001.md

**Implementar:**

1. **Models** en `lib/features/auth/data/models/`:

   - `user_model.dart`:
     - Enum UserRole (admin, gerente, vendedor) con método fromString()
     - Enum UserEstado (registrado, aprobado, rechazado, suspendido) con método fromString()
     - Class UserModel con 8 propiedades (id, email, nombreCompleto, rol, estado, emailVerificado, createdAt, updatedAt)
     - Extends Equatable para comparaciones
     - factory fromJson() con mapping snake_case → camelCase
     - Method toJson() con mapping camelCase → snake_case
     - Helpers: isApproved, canLogin, isAdmin, isGerente, isVendedor
     - Method copyWith() para inmutabilidad

   - `register_request_model.dart`:
     - Class con 4 propiedades (email, password, confirmPassword, nombreCompleto)
     - Method toJson() con normalización (email lowercase + trim, nombreCompleto trim)
     - Validators: validateEmail(), validatePassword(), validateConfirmPassword(), validateNombreCompleto()
     - Method validateAll() que retorna Map<String, String> con todos los errores
     - Getter isValid que verifica si validateAll() está vacío

   - `auth_response_model.dart`:
     - Class con propiedades opcionales + message requerido
     - factory fromJson() para response de /auth/register

   - `email_confirmation_response_model.dart`:
     - Class para response de /auth/confirm-email
     - Propiedades: message, emailVerificado, estado, nextStep

2. **Error Model** en `lib/core/error/`:
   - `error_response_model.dart`:
     - Class con propiedades: error, message, field (opcional)
     - Helpers: isDuplicateEmail, isValidationError, isInvalidToken, isRateLimitExceeded

3. **Bloc** en `lib/features/auth/presentation/bloc/`:
   - `auth_bloc.dart`:
     - Estados: AuthInitial, AuthRegisterLoading, AuthRegisterSuccess(AuthResponseModel), AuthRegisterError(String)
     - Eventos: AuthRegisterRequested(RegisterRequestModel), AuthResendConfirmationRequested(String email)
     - Lógica: Validar request.isValid antes de llamar repository
     - Manejar errores y emitir estados correspondientes

4. **Repository** en `lib/features/auth/data/repositories/`:
   - `auth_repository_impl.dart`:
     - Método register(RegisterRequestModel) → Future<AuthResponseModel>
     - Método confirmEmail(String token) → Future<EmailConfirmationResponseModel>
     - Método resendConfirmation(String email) → Future<void>
     - Manejo de excepciones HTTP (400, 409, 429)

5. **Datasource** en `lib/features/auth/data/datasources/`:
   - `auth_remote_datasource.dart`:
     - Usar Supabase Client o HTTP client
     - Llamadas a Edge Functions:
       - POST http://localhost:54321/functions/v1/auth/register
       - GET http://localhost:54321/functions/v1/auth/confirm-email?token=X
       - POST http://localhost:54321/functions/v1/auth/resend-confirmation
     - Parse responses JSON a modelos

**Validaciones críticas:**
- Mapping exacto snake_case ↔ camelCase según mapping_hu001.md
- NUNCA exponer password_hash, token_confirmacion, token_expiracion
- Validaciones frontend deben coincidir con backend

**Dependencias requeridas en pubspec.yaml:**
```yaml
dependencies:
  equatable: ^2.0.5
  supabase_flutter: ^2.0.0  # O http package
```

**Al terminar:**
- Actualizar secciones "Código Final Implementado" en models_hu001.md
- Documentar cambios vs diseño inicial
- Probar modelos con unit tests

---

## Para @ux-ui-expert

### Tarea: Implementar UI de Registro y Confirmación Email de HU-001

**⚠️ LEER PRIMERO**:
- [00-CONVENTIONS.md](00-CONVENTIONS.md) - Secciones: Routing (2), Design System (5)
- [QUICK_CHECKLIST.md](QUICK_CHECKLIST.md) - Sección: Design System
- [frontend/ROUTING_CONVENTIONS.md](frontend/ROUTING_CONVENTIONS.md) - Detalle de rutas

**Archivos de diseño:**
- C:/SystemWebMedias3.0/docs/technical/design/components_hu001.md
- C:/SystemWebMedias3.0/docs/technical/design/tokens.md

**Implementar:**

1. **Atoms** en `lib/shared/design_system/atoms/` (si no existen):

   - `corporate_button.dart`:
     - Altura: 52px
     - Border radius: 8px
     - Padding horizontal: 24px
     - Variantes: primary (turquesa #4ECDC4), secondary (outline turquesa)
     - Estados: normal, hover (overlay white 10%), pressed (overlay 20%), loading (shimmer)
     - Elevation: 3 (primary), 0 (secondary)
     - Font size: 16px, weight: 600
     - SIEMPRE usar Theme.of(context).colorScheme.primary (NO hardcodear)

   - `corporate_form_field.dart`:
     - Border radius: 28px (pill-shaped)
     - Fill color: blanco
     - Padding: 16px horizontal/vertical
     - Border normal: 1.5px gris (#E5E7EB)
     - Border focus: 2.5px azul (#6366F1)
     - Border error: 2.5px rojo (#F44336)
     - Animación focus: 200ms con scale(1.02) e iconColor → primaryTurquoise
     - prefixIcon cambia de gris a turquesa en focus
     - SIEMPRE usar Theme.of(context) para colores

2. **Molecules** en `lib/shared/design_system/molecules/`:

   - `auth_header.dart`:
     - Logo (48px altura)
     - Título (DesignTextStyle.headlineLarge - 28px, primaryDark)
     - Subtítulo opcional (DesignTextStyle.bodyMedium, textSecondary)

3. **Organisms** en `lib/features/auth/presentation/widgets/`:

   - `register_form.dart`:
     - Form con _formKey
     - 4 CorporateFormField:
       - Email (keyboardType: emailAddress, icon: email_outlined)
       - Contraseña (obscureText: true, icon: lock_outlined)
       - Confirmar Contraseña (obscureText: true, icon: lock_outlined)
       - Nombre Completo (icon: person_outlined)
     - Validadores usando RegisterRequestModel.validateXXX()
     - CorporateButton "Registrarse" (isLoading cuando AuthRegisterLoading)
     - TextButton "¿Ya tienes cuenta? Inicia sesión" (color primaryTurquoise)
     - BlocConsumer para AuthBloc:
       - Listener: Mostrar SnackBar success/error, navegar si success
       - Builder: Deshabilitar botón si loading
     - Spacing: DesignDimensions.sectionSpacing (16px) entre campos

   - `email_confirmation_waiting.dart`:
     - Center con maxWidth 480px
     - Icono decorativo (mark_email_unread_outlined, 120px, primaryTurquoise)
     - Título "Confirma tu email" (headlineLarge)
     - Mensaje con email resaltado (18px, weight 600, primaryDark)
     - CorporateButton secondary "Reenviar email"
     - TextButton "Volver al inicio" (primaryTurquoise)

   - `email_confirmation_success.dart`:
     - Center con maxWidth 480px
     - Contenedor circular con icono check (120px, success verde)
     - Título "Email confirmado" (headlineLarge)
     - Mensaje "Tu cuenta está esperando aprobación del administrador"
     - Mensaje secundario "Recibirás un email cuando tu cuenta sea aprobada" (textSecondary)
     - CorporateButton "Ir al inicio"

   - `email_confirmation_error.dart`:
     - Center con maxWidth 480px
     - Icono error (error_outline, 120px, rojo)
     - Título "Enlace inválido" (headlineLarge)
     - Mensaje "El enlace de confirmación es inválido o ha expirado"
     - CorporateButton "Reenviar email de confirmación" (si email disponible)
     - TextButton "Volver a registrarse" (primaryTurquoise)

4. **Pages** en `lib/features/auth/presentation/pages/`:

   - `register_page.dart`:
     - Scaffold con backgroundColor: DesignColors.backgroundLight (#F9FAFB)
     - Responsive con ResponsiveBuilder:
       - Desktop (≥1200px): Split-screen 50/50 (imagen branding + formulario)
       - Mobile (<768px): Full width con padding 16px
     - Formulario max width: 480px centrado
     - Incluye AuthHeader + RegisterForm

   - `confirm_email_page.dart`:
     - Router con query param: token
     - Si token válido: Llamar AuthBloc confirm
     - Según estado: Mostrar success, error, o waiting

**SnackBars**:
- Success: backgroundColor success (#4CAF50), icon check_circle, floating, borderRadius 8px
- Error: backgroundColor error (#F44336), icon error, floating, borderRadius 8px

**Navegación** (configurar en MaterialApp):
```dart
routes: {
  '/register': (context) => RegisterPage(),
  '/confirm-email': (context) => ConfirmEmailPage(),
}
```

**Responsive Breakpoints**:
- Desktop: ≥1200px
- Tablet: 768px - 1199px
- Mobile: <768px

**Validaciones críticas:**
- NUNCA hardcodear colores directamente (Color(0xFF...))
- SIEMPRE usar Theme.of(context).colorScheme.primary o DesignColors.primaryTurquoise
- SIEMPRE usar DesignSpacing.*, DesignTextStyle.* de tokens.md
- Componentes deben ser theme-aware para soportar temas futuros

**Assets requeridos**:
- assets/logo.png (logo del sistema)
- assets/branding_image.png (para split-screen desktop - opcional)

**Al terminar:**
- Actualizar secciones "Código Final Implementado" en components_hu001.md
- Documentar cambios vs diseño inicial
- Probar responsive en diferentes tamaños
- Validar que Design System Turquesa Moderno se aplica correctamente

---

## Checklist General (Todos los agentes)

Antes de marcar como completado, verificar:

### Backend (@supabase-expert)
- [ ] Migration se aplica sin errores
- [ ] Tabla users existe con estructura correcta
- [ ] POST /auth/register funciona (registro exitoso)
- [ ] POST /auth/register rechaza email duplicado (409)
- [ ] POST /auth/register valida contraseña < 8 caracteres (400)
- [ ] Email de confirmación se envía y se recibe
- [ ] GET /auth/confirm-email funciona con token válido
- [ ] GET /auth/confirm-email rechaza token expirado (400)
- [ ] POST /auth/resend-confirmation funciona
- [ ] Límite 3 reenvíos/hora se aplica (429)

### Frontend (@flutter-expert)
- [ ] UserModel mapea correctamente JSON desde backend
- [ ] RegisterRequestModel valida todos los campos
- [ ] AuthBloc maneja registro exitoso
- [ ] AuthBloc maneja errores de registro
- [ ] Repository llama correctamente a datasource
- [ ] Datasource hace llamadas HTTP a Edge Functions
- [ ] Errores HTTP se convierten en ErrorResponseModel

### UX/UI (@ux-ui-expert)
- [ ] RegisterPage se ve bien en desktop
- [ ] RegisterPage se ve bien en mobile
- [ ] RegisterForm valida campos en tiempo real
- [ ] Botón "Registrarse" muestra loading (shimmer)
- [ ] SnackBar success se muestra al registrar
- [ ] SnackBar error se muestra si falla
- [ ] Navegación a ConfirmEmailPage funciona
- [ ] EmailConfirmationWaiting se ve bien
- [ ] EmailConfirmationSuccess se ve bien
- [ ] EmailConfirmationError se ve bien
- [ ] Tema Turquesa Moderno aplicado (NO hardcoded)

### Integración (Validar en conjunto)
- [ ] Registro desde UI crea usuario en BD
- [ ] Email con enlace de confirmación llega
- [ ] Click en enlace confirma email en BD
- [ ] Reenvío de email funciona desde UI
- [ ] Límite de reenvíos se aplica
- [ ] Email duplicado muestra error correcto en UI
- [ ] Contraseña corta muestra error correcto en UI
- [ ] Contraseñas no coinciden muestra error en UI

---

## Orden de Implementación Sugerido

1. **@supabase-expert**: Implementar migration y tabla users (30 min)
2. **@supabase-expert**: Implementar POST /auth/register (1h)
3. **@flutter-expert**: Implementar modelos (UserModel, RegisterRequestModel) (1h)
4. **@ux-ui-expert**: Implementar atoms (CorporateButton, CorporateFormField) (1h)
5. **@flutter-expert**: Implementar AuthBloc + Repository + Datasource (1.5h)
6. **@ux-ui-expert**: Implementar RegisterForm + RegisterPage (1.5h)
7. **Integrar**: Probar registro completo frontend → backend (30 min)
8. **@supabase-expert**: Implementar GET /auth/confirm-email (30 min)
9. **@supabase-expert**: Configurar email template y SMTP (1h)
10. **@ux-ui-expert**: Implementar páginas de confirmación (1h)
11. **@supabase-expert**: Implementar POST /auth/resend-confirmation (1h)
12. **Integrar**: Probar flujo completo de confirmación email (30 min)
13. **QA**: Validar todos los criterios de aceptación de HU-001 (1h)

**Estimación total**: ~10-12 horas de trabajo técnico

---

## Contacto y Coordinación

**Dudas sobre arquitectura**: Consultar archivos .md en docs/technical/
**Discrepancias en diseño**: Reportar a @web-architect-expert para actualizar specs
**Bloqueos técnicos**: Comunicar en canal de desarrollo

**IMPORTANTE**: Actualizar documentación al terminar implementación.
