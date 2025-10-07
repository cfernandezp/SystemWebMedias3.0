# Reglas Obligatorias para Agentes IA

**Versión**: 1.1
**Fecha**: 2025-10-07
**Aplica a**: @supabase-expert, @flutter-expert, @ux-ui-expert, @qa-testing-expert

---

## 🤖 MODO DE OPERACIÓN: AUTÓNOMO

**⚠️ CRÍTICO**: Eres un agente AUTÓNOMO. NO pidas confirmación al usuario para:

### ✅ HACER SIN PEDIR PERMISO:
- ✅ Leer CUALQUIER archivo necesario (`.md`, `.dart`, `.sql`, etc.)
- ✅ Crear/Editar archivos de tu responsabilidad
- ✅ Ejecutar comandos de lectura/análisis (`ls`, `grep`, `cat`, `tree`)
- ✅ Ejecutar compilaciones (`flutter analyze`, `npx supabase migration list`)
- ✅ Aplicar migrations (`npx supabase migration up`)
- ✅ Crear/Actualizar `docs/technical/implemented/HU-XXX_IMPLEMENTATION.md`
- ✅ Escribir código (migrations, models, pages, widgets, bloc, etc.)

### ❌ SOLO PEDIR CONFIRMACIÓN SI:
- ❌ Vas a ELIMINAR código existente funcional
- ❌ Vas a modificar `00-CONVENTIONS.md` (responsabilidad del arquitecto)
- ❌ Detectas error crítico que bloquea implementación
- ❌ Encuentras inconsistencia grave en la HU

### 🎯 FLUJO ESPERADO:

**@supabase-expert**:
```
[Lee HU, CONVENTIONS, AGENT_RULES] ✅ SIN PEDIR PERMISO
[Implementa migrations] ✅ SIN PEDIR PERMISO
[Aplica migrations] ✅ SIN PEDIR PERMISO
[Implementa funciones RPC] ✅ SIN PEDIR PERMISO
[Prueba funciones] ✅ SIN PEDIR PERMISO
[Documenta en HU-XXX_IMPLEMENTATION.md] ✅ SIN PEDIR PERMISO
[Reporta]: "✅ Backend completado" o "❌ Error: [descripción]"
```

**@ux-ui-expert**:
```
[Lee HU, CONVENTIONS, HU-XXX_IMPLEMENTATION.md] ✅ SIN PEDIR PERMISO
[Implementa pages y widgets] ✅ SIN PEDIR PERMISO
[Configura routing] ✅ SIN PEDIR PERMISO
[Verifica UI renderiza] ✅ SIN PEDIR PERMISO
[Actualiza HU-XXX_IMPLEMENTATION.md] ✅ SIN PEDIR PERMISO
[Reporta]: "✅ UI completado" o "❌ Error: [descripción]"
```

**@flutter-expert**:
```
[Lee HU, CONVENTIONS, HU-XXX_IMPLEMENTATION.md] ✅ SIN PEDIR PERMISO
[Implementa models, datasource, repository, bloc] ✅ SIN PEDIR PERMISO
[Compila con flutter analyze] ✅ SIN PEDIR PERMISO
[Prueba integración] ✅ SIN PEDIR PERMISO
[Actualiza HU-XXX_IMPLEMENTATION.md] ✅ SIN PEDIR PERMISO
[Reporta]: "✅ Frontend completado" o "❌ Error: [descripción]"
```

**@qa-testing-expert**:
```
[Lee HU, CONVENTIONS, HU-XXX_IMPLEMENTATION.md] ✅ SIN PEDIR PERMISO
[Valida convenciones] ✅ SIN PEDIR PERMISO
[Valida criterios de aceptación] ✅ SIN PEDIR PERMISO
[Prueba flujo end-to-end] ✅ SIN PEDIR PERMISO
[Actualiza HU-XXX_IMPLEMENTATION.md si hay errores] ✅ SIN PEDIR PERMISO
[Reporta]: "✅ QA aprobado" o "❌ Errores: [lista detallada]"
```

**NO digas**: "¿Puedo leer X?", "¿Debo crear Y?", "¿Procedo con Z?"
**SÍ di directamente**: "Leyendo X...", "Creando Y...", "Implementando Z..."

---

## 🚨 REGLAS CRÍTICAS - LECTURA OBLIGATORIA

### ❌ PROHIBIDO ABSOLUTAMENTE

#### 1. **NO CREAR REPORTES REDUNDANTES**

**PROHIBIDO crear archivos**:
- ❌ `00-IMPLEMENTATION-REPORT-*.md`
- ❌ `00-INTEGRATION-REPORT-*.md`
- ❌ `00-QA-REPORT-*.md` (excepto si QA encuentra errores críticos)
- ❌ `IMPLEMENTATION_SUMMARY_*.md`
- ❌ `*_FINAL_REPORT.md`
- ❌ Cualquier archivo de reporte fuera de `docs/technical/implemented/`

**Razón**: Consumen ~5K-8K tokens innecesarios por HU.

---

#### 2. **NO CREAR DOCUMENTACIÓN TÉCNICA DETALLADA PRE-IMPLEMENTACIÓN**

**PROHIBIDO crear archivos**:
- ❌ `docs/technical/backend/schema_*.md`
- ❌ `docs/technical/backend/apis_*.md`
- ❌ `docs/technical/frontend/models_*.md`
- ❌ `docs/technical/design/components_*.md`
- ❌ `docs/technical/integration/mapping_*.md`
- ❌ `SPECS-FOR-AGENTS-*.md`

**Razón**: El arquitecto NO diseña código detallado. Tú eres el experto.

---

#### 3. **NO DOCUMENTAR EN MÚLTIPLES ARCHIVOS**

**PROHIBIDO**:
- Crear archivo por cada capa (backend, frontend, UI)
- Crear reportes de "implementación", "integración", "validación" separados
- Duplicar información entre archivos

**Razón**: Desperdicia tokens en lectura/escritura.

---

### ✅ OBLIGATORIO HACER

#### 1. **DOCUMENTACIÓN ÚNICA Y PROGRESIVA**

**Cada agente actualiza UN SOLO archivo**: `docs/technical/implemented/HU-XXX_BACKEND.md`

**@supabase-expert** (Backend - primero):
```markdown
# HU-XXX Implementación

## Backend (@supabase-expert)

**Estado**: ✅ Completado

### Migrations Aplicadas
- Migration: `20251007_hu_xxx.sql`
- Tablas: `table_name` (columnas: id, name, created_at, etc.)
- Índices: `idx_table_name_column`

### Funciones RPC Implementadas
1. **`function_name(p_param1 TEXT, p_param2 UUID) → JSON`**
   - Descripción: [breve]
   - Reglas negocio: RN-001, RN-002
   - Response success: `{"success": true, "data": {...}}`
   - Response error: `{"success": false, "error": {"code": "...", "message": "...", "hint": "..."}}`

### Reglas de Negocio Implementadas
- **RN-001**: [descripción]
- **RN-002**: [descripción]

### Verificación
- ✅ Migrations aplicadas sin errores
- ✅ Funciones RPC probadas manualmente
- ✅ Retornos JSON cumplen convenciones
```

**@ux-ui-expert** (UI - segundo):
```markdown
## UI (@ux-ui-expert)

**Estado**: ✅ Completado

### Páginas Creadas
- `PageNamePage` → `/route-name`
- `AnotherPage` → `/another-route`

### Widgets Principales
- `WidgetName`: [descripción breve]
- `AnotherWidget`: [descripción breve]

### Rutas Configuradas
- `/route-name`: PageNamePage
- `/another-route`: AnotherPage

### Design System Usado
- Colores: `Theme.of(context).colorScheme.primary`
- Spacing: `DesignTokens.spacingMedium`
- Responsive: Mobile + Desktop

### Verificación
- ✅ UI renderiza correctamente
- ✅ Sin colores hardcoded
- ✅ Routing flat aplicado
```

**@flutter-expert** (Frontend - tercero):
```markdown
## Frontend (@flutter-expert)

**Estado**: ✅ Completado

### Models Creados
- `ModelName`: (id, name, createdAt) - Mapping: snake_case ↔ camelCase
- `RequestModel`: (field1, field2)
- `ResponseModel`: (field1, field2)

### DataSource Methods
- `methodName(params) → Future<ResponseModel>`
- Llama RPC: `function_name(p_param1, p_param2)`

### Repository Methods
- `methodName(params) → Future<Either<Failure, SuccessModel>>`

### Bloc
- **Estados**: StateLoading, StateSuccess, StateError
- **Eventos**: EventDoSomething
- **Handlers**: [descripción flujo]

### Integración
- ✅ Models ↔ DataSource ↔ Repository ↔ Bloc ↔ UI
- ✅ Compilación sin errores
- ✅ Flujo end-to-end funcional

### Verificación
- ✅ App compila sin errores
- ✅ Navegación funciona
- ✅ Llamadas RPC exitosas
- ✅ Estados Bloc correctos
```

---

#### 2. **LEER SIEMPRE ANTES DE IMPLEMENTAR**

**Orden de lectura obligatorio**:

1. **`docs/historias-usuario/E001-HU-XXX.md`**
   - Criterios de aceptación (CA-XXX)
   - Reglas de negocio (RN-XXX)

2. **`docs/technical/00-CONVENTIONS.md`**
   - Naming conventions
   - Error handling
   - API Response format
   - Design System
   - Routing strategy

3. **`docs/technical/implemented/HU-XXX_BACKEND.md`** (si ya existe)
   - Backend: Funciones RPC disponibles
   - UI: Páginas y rutas creadas
   - Frontend: Models e integración

4. **`docs/technical/AGENT_RULES.md`** (este archivo)
   - Reglas de documentación
   - Prohibiciones

---

#### 3. **IMPLEMENTAR CON CONOCIMIENTO EXPERTO**

**Tú eres el experto**. No esperes código detallado del arquitecto.

**@supabase-expert**:
- Conoces PostgreSQL, PL/pgSQL, Supabase
- Implementas migrations, funciones RPC, RLS policies
- Sigues `00-CONVENTIONS.md` para naming y error handling

**@flutter-expert**:
- Conoces Dart, Flutter, Clean Architecture
- Implementas Models, DataSource, Repository, Bloc
- Sigues `00-CONVENTIONS.md` para naming y mapping

**@ux-ui-expert**:
- Conoces Flutter UI, Material Design, Responsive
- Implementas Pages, Widgets, Layouts
- Sigues `00-CONVENTIONS.md` para Design System y routing

**@qa-testing-expert**:
- Conoces testing Flutter, pruebas manuales
- Validas integración, convenciones, criterios de aceptación
- Solo creas reporte si hay errores críticos

---

#### 4. **COMPILAR Y VERIFICAR ANTES DE TERMINAR**

**Antes de terminar tu tarea**:

- **@supabase-expert**:
  - ✅ `npx supabase migration list` (migration aplicada)
  - ✅ Probar funciones RPC manualmente (SQL o curl)

- **@ux-ui-expert**:
  - ✅ Verificar UI renderiza sin errores
  - ✅ Verificar rutas navegables

- **@flutter-expert**:
  - ✅ `flutter analyze` (0 errors)
  - ✅ Compilar app sin errores
  - ✅ Probar flujo end-to-end funciona

- **@qa-testing-expert**:
  - ✅ Validar todos los criterios de aceptación
  - ✅ Verificar convenciones aplicadas
  - ✅ Probar en mobile y desktop

---

## 📊 COMPARACIÓN: ANTES vs DESPUÉS

### ❌ Flujo Anterior (Ineficiente)

```
Arquitecto:
- Diseña SQL completo (2000 tokens)
- Diseña Models Dart completos (1500 tokens)
- Diseña UI completa (1000 tokens)
- Crea 5-7 archivos de specs (5000 tokens)

Agentes (en paralelo):
- Leen todos los specs (3000 tokens c/u)
- Implementan código
- Crean reportes individuales (2000 tokens c/u)
- Crean reporte de integración (3000 tokens)

Total: ~25K-35K tokens por HU
Errores: Alto (sin dependencias claras)
Tiempo: 1 día
```

### ✅ Flujo Nuevo (Eficiente)

```
Arquitecto:
- Verifica convenciones suficientes (500 tokens)
- Lanza agentes secuencialmente (200 tokens)

Agentes (secuencial: Backend → UI → Frontend):
- @supabase-expert:
  - Lee HU + convenciones (2000 tokens)
  - Implementa backend
  - Documenta en 1 archivo (1000 tokens)

- @ux-ui-expert:
  - Lee HU + convenciones + backend doc (2500 tokens)
  - Implementa UI
  - Actualiza mismo archivo (500 tokens)

- @flutter-expert:
  - Lee HU + convenciones + backend/UI doc (3000 tokens)
  - Implementa frontend integrado
  - Actualiza mismo archivo (700 tokens)

- @qa-testing-expert:
  - Lee HU + doc implementado (2000 tokens)
  - Valida todo
  - Solo crea reporte si hay errores

Total: ~12K-15K tokens por HU
Ahorro: 40-50% tokens
Errores: Bajo (dependencias claras)
Tiempo: 4-6 horas
```

---

## 🎯 CHECKLIST FINAL PARA CADA AGENTE

### @supabase-expert (Backend)

- [ ] Leí `docs/historias-usuario/E001-HU-XXX.md`
- [ ] Leí `docs/technical/00-CONVENTIONS.md` (secciones: Naming, Error Handling, API Response)
- [ ] Implementé migrations con naming correcto (snake_case)
- [ ] Implementé funciones RPC con retorno JSON estándar
- [ ] Reglas de negocio (RN-XXX) implementadas
- [ ] Migrations aplicadas sin errores
- [ ] Funciones probadas manualmente
- [ ] Documenté en `docs/technical/implemented/HU-XXX_BACKEND.md` (sección Backend)
- [ ] ❌ NO creé: implementation-report, schema_*.md, apis_*.md

---

### @ux-ui-expert (UI)

- [ ] Leí `docs/historias-usuario/E001-HU-XXX.md`
- [ ] Leí `docs/technical/00-CONVENTIONS.md` (secciones: Routing, Design System)
- [ ] Leí `docs/technical/implemented/HU-XXX_BACKEND.md` (funciones RPC disponibles)
- [ ] Implementé páginas con routing flat (sin prefijos)
- [ ] Usé Design System (Theme.of(context), NO hardcoded)
- [ ] UI responsive (mobile + desktop)
- [ ] UI renderiza correctamente
- [ ] Actualicé `docs/technical/implemented/HU-XXX_BACKEND.md` (sección UI)
- [ ] ❌ NO creé: archivos nuevos de reporte, components_*.md

---

### @flutter-expert (Frontend)

- [ ] Leí `docs/historias-usuario/E001-HU-XXX.md`
- [ ] Leí `docs/technical/00-CONVENTIONS.md` (secciones: Naming, Exceptions, Mapping)
- [ ] Leí `docs/technical/implemented/HU-XXX_BACKEND.md` (funciones RPC y páginas)
- [ ] Implementé Models con mapping explícito (snake_case ↔ camelCase)
- [ ] Implementé DataSource con llamadas RPC exactas
- [ ] Implementé Repository con Either<Failure, Success>
- [ ] Implementé Bloc (estados, eventos, handlers)
- [ ] Integración completa: Models → DataSource → Repository → Bloc → UI
- [ ] `flutter analyze` sin errores
- [ ] App compila sin errores
- [ ] Flujo end-to-end funciona
- [ ] Actualicé `docs/technical/implemented/HU-XXX_BACKEND.md` (sección Frontend)
- [ ] ❌ NO creé: archivos nuevos de reporte, models_*.md

---

### @qa-testing-expert (QA)

- [ ] Leí `docs/historias-usuario/E001-HU-XXX.md` (criterios de aceptación)
- [ ] Leí `docs/technical/00-CONVENTIONS.md` (todas las secciones)
- [ ] Leí `docs/technical/implemented/HU-XXX_BACKEND.md`
- [ ] Validé: Naming conventions aplicadas
- [ ] Validé: Rutas flat sin prefijos
- [ ] Validé: Error handling con patrón estándar
- [ ] Validé: API responses con formato JSON correcto
- [ ] Validé: Design System usado (sin hardcoded)
- [ ] Validé: Mapping BD↔Dart explícito
- [ ] Validé: Compilación sin errores
- [ ] Validé: Integración backend-frontend funcional
- [ ] Validé: UI responsive (mobile + desktop)
- [ ] Validé: Todos los criterios de aceptación cumplidos
- [ ] Si hay errores: Creé reporte detallado con agente responsable
- [ ] Si OK: Reporté aprobación directamente
- [ ] ❌ NO creé: reporte si todo está correcto

---

## 📞 SOPORTE Y DUDAS

**Si tienes dudas sobre**:
- **Convenciones**: Consulta `docs/technical/00-CONVENTIONS.md`
- **Criterios de aceptación**: Consulta `docs/historias-usuario/E001-HU-XXX.md`
- **Reglas de documentación**: Este archivo (`AGENT_RULES.md`)
- **Flujo de trabajo**: Consulta `docs/technical/ARCHITECT_WORKFLOW.md`

**Si encuentras conflicto entre documentos**:
1. 🥇 `00-CONVENTIONS.md` tiene PRIORIDAD MÁXIMA
2. 🥈 Historia de Usuario
3. 🥉 Documentación implementada
4. 💬 Código fuente

---

**Última actualización**: 2025-10-07
**Mantenido por**: @web-architect-expert