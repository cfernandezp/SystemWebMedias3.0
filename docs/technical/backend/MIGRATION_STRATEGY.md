# Estrategia de Migraciones Supabase

**Propósito**: Definir mejores prácticas para manejo de migraciones SQL durante desarrollo incremental.

**Fecha**: 2025-10-05
**Mantenido por**: @web-architect-expert

---

## 🎯 FILOSOFÍA

Durante **desarrollo incremental** (HU por HU):
- ✅ **Permitir múltiples migraciones por HU** mientras experimentamos
- ✅ **Consolidar periódicamente** al completar épicas
- ❌ **NO squash después de cada HU** (interrumpe flujo de desarrollo)
- ❌ **NO dejar 50+ migraciones sin consolidar** (caos en producción)

---

## 📋 ESTRATEGIA: "Squash por Épica"

### Fase 1: DESARROLLO ACTIVO (ahora)

**Regla**: Durante desarrollo de una Épica, permite múltiples migraciones.

```
E001: Autenticación y Autorización (EN DESARROLLO)
├── supabase/migrations/
│   ├── 20251004145739_hu001_users_registration.sql
│   ├── 20251004170000_hu001_database_functions.sql
│   ├── 20251004180000_fix_database_functions_exception_handling.sql
│   ├── 20251004230000_migrate_to_supabase_auth.sql
│   ├── 20251005040208_hu002_login_functions.sql
│   ├── 20251005042727_fix_hu002_use_supabase_auth.sql
│   └── ... (más conforme avanzamos HU-003, HU-004)
```

**Ventajas**:
- ⚡ Desarrollo rápido sin interrupciones
- 🔧 Fácil debugging (cada cambio es rastreable)
- 🔄 Rollback granular si algo falla

**Desventajas**:
- 📚 Muchos archivos (manejable con buena convención)
- 🤔 Historia difusa (aceptable en dev)

---

### Fase 2: CONSOLIDACIÓN DE ÉPICA

**Regla**: Al completar TODAS las HUs de una Épica → SQUASH.

**Ejemplo**: Al terminar E001 (HU-001, HU-002, HU-003, HU-004):

```bash
# 1. Crear snapshot de migraciones actuales
mkdir -p supabase/migrations/archive/E001-pre-squash
mv supabase/migrations/202510*.sql supabase/migrations/archive/E001-pre-squash/

# 2. Exportar schema actual desde BD local
supabase db dump -f supabase/migrations/20251015000000_E001_complete_authentication_system.sql

# 3. Limpiar dump (remover schemas sistema, solo conservar custom)
# (editar archivo manualmente)

# 4. Resetear BD local
supabase db reset

# 5. Verificar que todo funciona
flutter test
```

**Resultado**:
```
E001: Autenticación ✅ COMPLETADA
├── supabase/migrations/
│   └── 20251015000000_E001_complete_authentication_system.sql  ← 1 archivo limpio
└── supabase/migrations/archive/E001-pre-squash/
    └── ... (14 archivos originales, para referencia histórica)
```

**Ventajas**:
- 📖 Historia limpia y comprensible
- 🚀 Fácil replicar en nuevos ambientes
- ✅ Producción-ready

---

### Fase 3: PRE-PRODUCCIÓN

**Regla**: Antes de deploy a producción, hacer squash final de TODAS las épicas.

```
Producción:
├── supabase/migrations/
│   ├── 20251020000000_complete_schema_v1.0.sql  ← Todo consolidado
│   └── seed.sql  ← Datos de prueba
```

---

## 🛠️ CONVENCIONES DURANTE DESARROLLO

### Naming Convention (mientras NO se hace squash)

```
YYYYMMDDHHMMSS_[tipo]_[hu]_[descripcion].sql

Tipos:
- hu00X         → Migración inicial de HU
- fix           → Corrección de bug en migración previa
- refactor      → Refactorización sin cambio funcional
- helper        → Funciones auxiliares (dev/testing)
- rollback      → Revertir cambio previo
```

**Ejemplos**:
```
✅ 20251005040208_hu002_login_functions.sql
✅ 20251005042727_fix_hu002_use_supabase_auth.sql
✅ 20251005043000_helper_dev_confirm_email.sql
✅ 20251006050000_refactor_token_validation.sql
✅ 20251006051000_rollback_email_verification.sql
```

---

## ⚠️ REGLAS PARA AGENTES (@supabase-expert)

### ✅ PERMITIDO (durante desarrollo de Épica):

1. **Crear múltiples migraciones por HU**
   ```sql
   20251005040208_hu002_login_functions.sql
   20251005042727_fix_hu002_use_supabase_auth.sql
   ```

2. **Usar prefijo `fix_` para correcciones**
   ```sql
   20251005043100_fix_token_validation_decimal.sql
   ```

3. **Crear helpers de desarrollo**
   ```sql
   20251005043000_helper_dev_confirm_email.sql
   ```

### ❌ EVITAR:

1. **Modificar migraciones ya aplicadas**
   - ❌ NO editar `20251004145739_hu001_users_registration.sql` si ya fue aplicada
   - ✅ SÍ crear `20251006120000_fix_hu001_missing_index.sql`

2. **Crear migraciones "parche sobre parche"**
   - Si tienes 3+ migraciones `fix_` para la misma HU → considera squash parcial

3. **Migraciones sin comentarios**
   ```sql
   ❌ MALO:
   CREATE TABLE login_attempts (...);

   ✅ BUENO:
   -- Migration: HU-002 - Login Rate Limiting
   -- Razón: Prevenir brute force attacks (CA-008)
   -- Impacto: Crea tabla login_attempts + función check_login_rate_limit()
   CREATE TABLE login_attempts (...);
   ```

---

## 📊 CUANDO HACER SQUASH

### ✅ Squash recomendado:

- ✅ Al completar una **Épica completa** (E001, E002, etc.)
- ✅ Antes de **merge a rama principal** (develop/main)
- ✅ Antes de **deploy a staging/producción**
- ✅ Cuando acumulas **20+ migraciones** sin consolidar

### ❌ NO hacer squash:

- ❌ Después de cada HU individual
- ❌ Si la Épica aún está en desarrollo
- ❌ Si otros desarrolladores dependen de las migraciones actuales

---

## 🔄 PROCESO DE SQUASH (Paso a Paso)

### 1. Backup de migraciones actuales

```bash
# Crear carpeta archive con timestamp
mkdir -p supabase/migrations/archive/$(date +%Y%m%d)-E001-pre-squash

# Mover todas las migraciones a archivar
mv supabase/migrations/202510*.sql supabase/migrations/archive/$(date +%Y%m%d)-E001-pre-squash/
```

### 2. Generar schema consolidado

```bash
# Opción A: Dump completo desde BD local
supabase db dump -f supabase/migrations/20251015000000_E001_complete_authentication_system.sql --data-only=false

# Opción B: Dump solo estructura (sin datos)
supabase db dump -f supabase/migrations/20251015000000_E001_complete_authentication_system.sql --data-only=false --schema public
```

### 3. Limpiar dump generado

**Editar manualmente** el archivo y:
- ❌ Remover schemas del sistema (`auth`, `storage`, `realtime`, etc.) - **SOLO si usaste dump completo**
- ✅ Conservar solo tablas/funciones custom (`users`, `login_attempts`, funciones `login_user()`, etc.)
- ✅ Agregar comentarios de documentación

**Ejemplo de encabezado**:
```sql
-- Migration: E001 - Sistema Completo de Autenticación
-- Fecha: 2025-10-15
-- Razón: Consolidación de HU-001, HU-002, HU-003, HU-004
-- Impacto: Crea infraestructura completa de auth (users, login, logout, password reset)
--
-- HUs incluidas:
--   - HU-001: Registro de Alta al Sistema
--   - HU-002: Login al Sistema
--   - HU-003: Logout Seguro
--   - HU-004: Recuperar Contraseña
--
-- Archivos consolidados: 14 migraciones originales
-- Ver: supabase/migrations/archive/20251015-E001-pre-squash/

BEGIN;

-- ... (tu schema consolidado aquí)

COMMIT;
```

### 4. Verificar consolidación

```bash
# Resetear BD local (esto borra TODOS los datos)
supabase db reset

# Verificar que migración consolidada funcionó
supabase migration list

# Ejecutar tests
flutter test
```

### 5. Documentar en archivo CHANGELOG

Actualizar `supabase/migrations/CHANGELOG.md`:
```markdown
## [E001] - 2025-10-15 - Sistema de Autenticación Completo

### Consolidado desde 14 migraciones
- HU-001: Registro (4 migraciones)
- HU-002: Login (6 migraciones)
- HU-003: Logout (2 migraciones)
- HU-004: Password Reset (2 migraciones)

### Archivos originales
Ver: `archive/20251015-E001-pre-squash/`

### Schema final
- Tabla `users` con 11 campos
- Funciones: `register_user()`, `login_user()`, `validate_token()`, `logout_user()`, `reset_password()`
- Tabla auxiliar: `login_attempts` (rate limiting)
```

---

## 📂 ESTRUCTURA FINAL RECOMENDADA

```
supabase/
├── migrations/
│   ├── CHANGELOG.md                                          ← Historial de consolidaciones
│   ├── 20251015000000_E001_complete_authentication_system.sql ← Épica consolidada
│   ├── 20251020000000_E002_complete_product_management.sql   ← Épica consolidada
│   ├── 20251025123456_hu010_add_reports.sql                  ← HU en desarrollo
│   ├── 20251025130000_fix_hu010_report_query.sql             ← Fix temporal
│   └── archive/
│       ├── 20251015-E001-pre-squash/                         ← Backup épica 1
│       │   ├── 20251004145739_hu001_users_registration.sql
│       │   ├── 20251004170000_hu001_database_functions.sql
│       │   └── ... (14 archivos)
│       └── 20251020-E002-pre-squash/                         ← Backup épica 2
│           └── ... (migraciones de E002)
└── seed.sql                                                  ← Datos de prueba
```

---

## 🎯 RECOMENDACIÓN PARA TU SITUACIÓN ACTUAL

### Estado actual:
- E001 en desarrollo (HU-001 ✅, HU-002 ✅, HU-003 ⏳, HU-004 ⏳)
- 14 migraciones acumuladas

### Acción recomendada: **NO HACER SQUASH TODAVÍA**

**Razón**:
- HU-003 (Logout) y HU-004 (Password Reset) aún no están implementadas
- Hacer squash ahora interrumpiría el flujo de desarrollo
- Las 14 migraciones son manejables (< 20)

### Plan sugerido:

```
✅ AHORA: Continuar desarrollo
├── Implementar HU-003: Logout
├── Implementar HU-004: Recuperar contraseña
└── Dejar las 14 migraciones actuales tal como están

⏳ AL COMPLETAR HU-004:
├── SQUASH de toda la épica E001
├── Consolidar ~18-20 migraciones → 1 archivo
└── Mover originales a archive/

🚀 ANTES DE PRODUCCIÓN:
└── Squash final de TODAS las épicas
```

---

## 📝 CHECKLIST PARA @supabase-expert

Antes de crear una nueva migración, verifica:

- [ ] ¿Esta migración modifica una ya aplicada? → ❌ Crear nueva con prefijo `fix_`
- [ ] ¿Es una corrección menor? → Usar prefijo `fix_` en nombre
- [ ] ¿Es un helper de desarrollo? → Usar prefijo `helper_dev_`
- [ ] ¿Incluye comentarios explicativos? → Obligatorio
- [ ] ¿Referencias a CA/RN en comentarios? → Recomendado
- [ ] ¿Es la 3ra+ migración `fix_` para la misma HU? → Considerar squash parcial

---

## 🔗 REFERENCIAS

- [Supabase Migrations Docs](https://supabase.com/docs/guides/cli/local-development#database-migrations)
- [Migration Best Practices](https://supabase.com/docs/guides/database/managing-migrations)
- Proyecto interno: [00-CONVENTIONS.md](../00-CONVENTIONS.md)

---

**Última actualización**: 2025-10-05
**Próxima revisión**: Al completar E001
