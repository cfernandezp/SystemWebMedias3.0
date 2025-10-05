# HU-001: Registro de Alta al Sistema - Documentación Técnica Completa

**Estado**: 🔵 En Desarrollo
**Épica**: E001 - Autenticación y Autorización
**Diseñado por**: @web-architect-expert (2025-10-04)

---

## 📚 Documentación Completa

### Backend (Supabase)

#### Schema de Base de Datos
**Archivo**: [backend/schema_hu001.md](backend/schema_hu001.md)

**Contenido:**
- Tabla `users` con 11 campos
- ENUMs: `user_role` (ADMIN, GERENTE, VENDEDOR) y `user_estado` (REGISTRADO, APROBADO, RECHAZADO, SUSPENDIDO)
- Índices optimizados: email (case-insensitive), estado, token_confirmacion
- Trigger para auto-update de `updated_at`
- RLS Policies para seguridad
- Implementa: RN-001 a RN-007

#### APIs y Edge Functions
**Archivo**: [backend/apis_hu001.md](backend/apis_hu001.md)

**Endpoints:**
1. **POST /auth/register**
   - Request: email, password, confirm_password, nombre_completo
   - Validaciones: RN-001, RN-002, RN-003, RN-006
   - Response 201: Usuario creado con token de confirmación
   - Response 400: Errores de validación
   - Response 409: Email duplicado

2. **GET /auth/confirm-email?token={token}**
   - Valida token y expiración (RN-003)
   - Actualiza email_verificado a true
   - Response 200: Email confirmado
   - Response 400: Token inválido o expirado

3. **POST /auth/resend-confirmation**
   - Request: email
   - Límite: 3 reenvíos por hora (RN-003)
   - Response 200: Email reenviado
   - Response 429: Límite excedido

**Template Email:**
- Diseño corporativo turquesa
- Enlace con token de confirmación
- Validez 24 horas

---

### Frontend (Flutter Web)

#### Modelos Dart
**Archivo**: [frontend/models_hu001.md](frontend/models_hu001.md)

**Modelos:**
1. **UserModel**
   - Mapea con tabla `users`
   - ENUMs: UserRole, UserEstado
   - Helpers: isApproved, canLogin, isAdmin
   - fromJson / toJson con mapping snake_case ↔ camelCase

2. **RegisterRequestModel**
   - Campos: email, password, confirmPassword, nombreCompleto
   - Validaciones frontend completas
   - Método validateAll() retorna Map de errores

3. **AuthResponseModel**
   - Response de POST /auth/register
   - Campos opcionales para flexibilidad

4. **EmailConfirmationResponseModel**
   - Response de GET /auth/confirm-email
   - Incluye mensaje y next step

5. **ErrorResponseModel**
   - Manejo consistente de errores de API
   - Helpers para tipos de error comunes

**Dependencias:**
- equatable: ^2.0.5
- json_annotation: ^4.8.1 (opcional)

---

### Design System (UX/UI)

#### Componentes UI
**Archivo**: [design/components_hu001.md](design/components_hu001.md)

**Páginas (Templates):**
1. **RegisterPage**
   - Responsive: Desktop (split-screen), Mobile (full-width)
   - Ruta: `/register`
   - Incluye: RegisterForm + Branding

**Organisms:**
1. **RegisterForm**
   - 4 campos con validaciones en tiempo real
   - Estados: initial, loading, error, success
   - Integración con AuthBloc
   - Usa CorporateButton y CorporateFormField

2. **EmailConfirmationWaiting**
   - Página después del registro
   - Icono decorativo + mensaje
   - Botón reenviar email

3. **EmailConfirmationSuccess**
   - Confirmación exitosa
   - Icono success verde
   - Botón ir al login

4. **EmailConfirmationError**
   - Enlace inválido/expirado
   - Opción reenviar o volver a registrarse

**Molecules:**
1. **AuthHeader**
   - Logo + título + subtítulo
   - Consistente entre páginas auth

**Atoms (ya definidos en tokens.md):**
- CorporateButton (turquesa, 52px, elevation 3)
- CorporateFormField (pill-shaped 28px radius)

**SnackBars:**
- Success: Verde con check icon
- Error: Rojo con error icon
- Floating con border radius 8px

**Navegación:**
- `/register` → RegisterPage
- `/confirm-email` → EmailConfirmationWaiting
- `/confirm-email/success` → EmailConfirmationSuccess
- `/confirm-email/error` → EmailConfirmationError

**Design Tokens Usados:**
- Colores: primaryTurquoise (#4ECDC4), success, error
- Spacing: sectionSpacing (16px)
- Typography: headlineLarge (28px), bodyLarge, bodyMedium
- Animaciones: 200ms focus, shimmer loading

---

### Integración Backend ↔ Frontend

#### Mapping snake_case ↔ camelCase
**Archivo**: [integration/mapping_hu001.md](integration/mapping_hu001.md)

**Tabla users ↔ UserModel:**
| Backend | Frontend | Notas |
|---------|----------|-------|
| `id` | `id` | UUID |
| `email` | `email` | LOWER(email) normalizado |
| `password_hash` | - | NO exponer (seguridad) |
| `nombre_completo` | `nombreCompleto` | Trim espacios |
| `rol` | `rol` (UserRole?) | Enum nullable |
| `estado` | `estado` (UserEstado) | Enum required |
| `email_verificado` | `emailVerificado` | Boolean |
| `token_confirmacion` | - | NO exponer (seguridad) |
| `token_expiracion` | - | NO exponer (seguridad) |
| `created_at` | `createdAt` | ISO 8601 |
| `updated_at` | `updatedAt` | ISO 8601 |

**ENUMs Mapping:**
- `'ADMIN'` ↔ `UserRole.admin`
- `'GERENTE'` ↔ `UserRole.gerente`
- `'VENDEDOR'` ↔ `UserRole.vendedor`
- `'REGISTRADO'` ↔ `UserEstado.registrado`
- `'APROBADO'` ↔ `UserEstado.aprobado`
- `'RECHAZADO'` ↔ `UserEstado.rechazado`
- `'SUSPENDIDO'` ↔ `UserEstado.suspendido`

**Campos de Seguridad (NO Expuestos):**
- password_hash
- token_confirmacion
- token_expiracion

**Normalización:**
- Email: lowercase en backend y frontend
- Nombre Completo: trim() espacios

---

## 🔐 Reglas de Negocio Implementadas

| RN | Título | Implementación |
|----|--------|----------------|
| RN-001 | Unicidad de Email | Índice UNIQUE LOWER(email) en BD |
| RN-002 | Requisitos de Contraseña | Min 8 caracteres, hash bcrypt, confirmación |
| RN-003 | Confirmación Email Obligatoria | Token 24h, máx 3 reenvíos/hora |
| RN-004 | Estados del Usuario | ENUM con 4 estados, transiciones controladas |
| RN-005 | Control de Acceso | Solo APROBADO + email_verificado pueden login |
| RN-006 | Campos Obligatorios | Validaciones frontend + backend |
| RN-007 | Asignación de Rol | Nullable en registro, asignado al aprobar |

---

## 📋 Especificaciones para Agentes Técnicos

### Para @supabase-expert

**Implementar:**
1. **Migration**: `supabase/migrations/YYYYMMDDHHMMSS_create_users_table.sql`
   - Crear ENUMs: user_role, user_estado
   - Crear tabla users según [backend/schema_hu001.md](backend/schema_hu001.md)
   - Crear índices optimizados
   - Crear función y trigger para updated_at
   - Configurar RLS policies

2. **Edge Functions**:
   - `supabase/functions/auth/register.ts` - POST /auth/register
   - `supabase/functions/auth/confirm-email.ts` - GET /auth/confirm-email
   - `supabase/functions/auth/resend-confirmation.ts` - POST /auth/resend-confirmation
   - Ver especificaciones completas en [backend/apis_hu001.md](backend/apis_hu001.md)

3. **Email Template**:
   - Configurar SMTP en Supabase
   - Template HTML corporativo turquesa
   - Enlace con token de confirmación

**Actualizar al terminar:**
- Completar secciones "SQL Final Implementado" en archivos .md
- Documentar cualquier cambio vs diseño inicial

---

### Para @flutter-expert

**Implementar:**
1. **Modelos** en `lib/features/auth/data/models/`:
   - user_model.dart - UserModel con ENUMs
   - register_request_model.dart - RegisterRequestModel
   - auth_response_model.dart - AuthResponseModel
   - email_confirmation_response_model.dart - EmailConfirmationResponseModel
   - Ver diseño completo en [frontend/models_hu001.md](frontend/models_hu001.md)

2. **Error Model** en `lib/core/error/`:
   - error_response_model.dart - ErrorResponseModel

3. **Bloc** en `lib/features/auth/presentation/bloc/`:
   - auth_bloc.dart - Estados y eventos para registro
   - Estados: AuthInitial, AuthRegisterLoading, AuthRegisterSuccess, AuthRegisterError
   - Eventos: AuthRegisterRequested, AuthResendConfirmationRequested

4. **Repository** en `lib/features/auth/data/repositories/`:
   - auth_repository_impl.dart - Integración con Supabase Client

5. **Datasource** en `lib/features/auth/data/datasources/`:
   - auth_remote_datasource.dart - Llamadas HTTP a Edge Functions

**Validar mapping:**
- Verificar snake_case ↔ camelCase según [integration/mapping_hu001.md](integration/mapping_hu001.md)
- Asegurar que campos sensibles NO se exponen

**Actualizar al terminar:**
- Completar secciones "Código Final Implementado" en archivos .md
- Documentar cambios si los hay

---

### Para @ux-ui-expert

**Implementar:**
1. **Páginas** en `lib/features/auth/presentation/pages/`:
   - register_page.dart - RegisterPage responsive
   - confirm_email_page.dart - Páginas de confirmación
   - Ver diseños en [design/components_hu001.md](design/components_hu001.md)

2. **Widgets** en `lib/features/auth/presentation/widgets/`:
   - register_form.dart - RegisterForm organism
   - email_confirmation_waiting.dart - EmailConfirmationWaiting
   - email_confirmation_success.dart - EmailConfirmationSuccess
   - email_confirmation_error.dart - EmailConfirmationError

3. **Molecules** en `lib/shared/design_system/molecules/`:
   - auth_header.dart - AuthHeader

4. **Atoms** (si no existen) en `lib/shared/design_system/atoms/`:
   - corporate_button.dart - CorporateButton según tokens.md
   - corporate_form_field.dart - CorporateFormField según tokens.md

**Usar Design Tokens:**
- SIEMPRE `Theme.of(context)` o `DesignTokens.*`
- NUNCA hardcodear colores
- Ver [design/tokens.md](design/tokens.md) para especificaciones completas

**Responsive:**
- Desktop ≥1200px: Split-screen
- Mobile <768px: Full-width

**Actualizar al terminar:**
- Completar secciones "Código Final Implementado" en archivos .md
- Documentar cambios vs diseño

---

## ✅ Checklist de Validación Completa

### Backend (@supabase-expert)
- [ ] Migration aplicada exitosamente
- [ ] Tabla users creada con todos los campos
- [ ] ENUMs user_role y user_estado funcionan
- [ ] Índices creados correctamente
- [ ] Trigger updated_at funciona
- [ ] RLS Policies aplicadas
- [ ] Edge Function /auth/register funciona
- [ ] Edge Function /auth/confirm-email funciona
- [ ] Edge Function /auth/resend-confirmation funciona
- [ ] Template de email configurado
- [ ] Email de confirmación se envía correctamente
- [ ] Validaciones RN-001 a RN-007 funcionan

### Frontend (@flutter-expert)
- [ ] UserModel mapea correctamente con BD
- [ ] RegisterRequestModel valida campos (RN-006, RN-002)
- [ ] AuthBloc maneja estados correctamente
- [ ] Datasource llama a Edge Functions
- [ ] Repository implementado
- [ ] Mapping snake_case ↔ camelCase correcto
- [ ] ENUMs funcionan correctamente
- [ ] Errores de API se manejan bien

### UX/UI (@ux-ui-expert)
- [ ] RegisterPage responsive (desktop + mobile)
- [ ] RegisterForm con validaciones en tiempo real
- [ ] Botones usan CorporateButton (turquesa, 52px)
- [ ] Form fields usan CorporateFormField (pill 28px)
- [ ] Estados loading (shimmer) funcionan
- [ ] SnackBars success/error se muestran
- [ ] EmailConfirmationWaiting se ve bien
- [ ] EmailConfirmationSuccess se ve bien
- [ ] EmailConfirmationError se ve bien
- [ ] Navegación entre páginas funciona
- [ ] Design System Turquesa Moderno aplicado
- [ ] NUNCA colores hardcodeados

### Integración (Todos)
- [ ] Frontend consume APIs correctamente
- [ ] Registro exitoso crea usuario en BD
- [ ] Email de confirmación llega
- [ ] Enlace de confirmación funciona
- [ ] Token expirado se maneja correctamente
- [ ] Reenvío de email funciona
- [ ] Límite de 3 reenvíos/hora funciona
- [ ] Email duplicado se rechaza
- [ ] Validaciones frontend coinciden con backend
- [ ] Mensajes de error son consistentes

---

## 📊 Archivos Creados por @web-architect-expert

1. `docs/technical/backend/schema_hu001.md` - Schema BD completo
2. `docs/technical/backend/apis_hu001.md` - 3 Edge Functions especificadas
3. `docs/technical/frontend/models_hu001.md` - 5 modelos Dart diseñados
4. `docs/technical/design/components_hu001.md` - 7 componentes UI diseñados
5. `docs/technical/integration/mapping_hu001.md` - Tabla de mapping completa
6. `docs/technical/00-INDEX-HU001.md` - Este índice

**Total**: 6 archivos de especificación técnica completa

---

## 🚀 Siguiente Paso

**IMPORTANTE**: NO ejecutar Task() para coordinar agentes. El usuario coordinará manualmente.

**Reportar a usuario**:
- Estado HU-001: 🔵 En Desarrollo
- Arquitectura completa diseñada
- Especificaciones listas para implementación
- Archivos de documentación creados y listados arriba

**Agentes técnicos pueden comenzar implementación consultando:**
- @supabase-expert: backend/schema_hu001.md + backend/apis_hu001.md
- @flutter-expert: frontend/models_hu001.md + integration/mapping_hu001.md
- @ux-ui-expert: design/components_hu001.md + design/tokens.md
