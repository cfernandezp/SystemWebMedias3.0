# Convención de Nomenclatura del Proyecto

**Propósito**: Definir estándares de nombres para épicas, historias de usuario y archivos técnicos.

**Fecha**: 2025-10-05
**Aplicada por**: Product Owner (épicas/HUs) y @web-architect-expert (docs técnicos)

---

## 🎯 REGLA FUNDAMENTAL

### Épicas y HUs usan numeración **relativa por épica**, NO global

```
✅ CORRECTO:
E001-HU-001, E001-HU-002, E001-HU-003
E002-HU-001, E002-HU-002  ← Reinicia en 001
E003-HU-001, E003-HU-002  ← Reinicia en 001

❌ INCORRECTO:
HU-001, HU-002, HU-003
HU-004, HU-005  ← Numeración global continua
```

---

## 👥 RESPONSABILIDADES

### 📝 Product Owner (TÚ) crea:
- ✅ Épicas (`docs/epicas/E00X-nombre.md`)
- ✅ Historias de Usuario (`docs/historias-usuario/E00X-HU-00Y-nombre.md`)
- ✅ Decide numeración y nombres de negocio

### 🏗️ @web-architect-expert (Agente) crea:
- ✅ Documentación técnica (`docs/technical/`)
- ✅ Specs para agentes (`SPECS-FOR-AGENTS-E00X-HU-00Y.md`)
- ✅ Índices técnicos (`00-INDEX-E00X-HU-00Y.md`)
- ✅ Mappings, schemas, APIs docs

### 🔧 @supabase-expert (Agente) crea:
- ✅ Migraciones SQL siguiendo convención

### 💻 @flutter-expert (Agente) crea:
- ✅ Documentación de modelos y código

### 🎨 @ux-ui-expert (Agente) crea:
- ✅ Documentación de componentes

---

## 📋 FORMATO DE ÉPICAS

**Responsable**: Product Owner

### Convención:
```
E[XXX]-[nombre-kebab-case]

XXX = Número de 3 dígitos (001, 002, 003...)
```

### Ejemplos:
```
✅ E001-autenticacion-autorizacion.md
✅ E002-gestion-productos.md
✅ E003-dashboard-navegacion.md
```

### Archivo de épica:
```
Ubicación: docs/epicas/
Nombre: E[XXX]-[nombre-kebab-case].md
Creado por: Product Owner

Ejemplo:
docs/epicas/E001-autenticacion-autorizacion.md
```

---

## 📋 FORMATO DE HISTORIAS DE USUARIO

**Responsable**: Product Owner

### Convención:
```
E[XXX]-HU-[YYY]-[nombre-kebab-case]

XXX = Número de épica (001, 002, 003...)
YYY = Número de HU dentro de la épica (001, 002, 003...)
      ⚠️ REINICIA en 001 para cada nueva épica
```

### Ejemplos:

#### E001: Autenticación (Creada por PO)
```
✅ E001-HU-001-registro-alta-sistema.md
✅ E001-HU-002-login.md
✅ E001-HU-003-logout-seguro.md
✅ E001-HU-004-recuperar-contraseña.md
```

#### E002: Gestión de Productos (Creada por PO)
```
✅ E002-HU-001-gestionar-marcas.md      ← Reinicia en 001
✅ E002-HU-002-gestionar-materiales.md
✅ E002-HU-003-gestionar-tipos.md
✅ E002-HU-004-gestionar-sistemas-tallas.md
```

#### E003: Dashboard (Creada por PO)
```
✅ E003-HU-001-crear-dashboard.md       ← Reinicia en 001
✅ E003-HU-002-widgets-personalizables.md
```

### Archivo de HU:
```
Ubicación: docs/historias-usuario/
Nombre: E[XXX]-HU-[YYY]-[nombre-kebab-case].md
Creado por: Product Owner

Ejemplo:
docs/historias-usuario/E001-HU-001-registro-alta-sistema.md
```

---

## 📂 DOCUMENTACIÓN TÉCNICA POR HU

**Responsable**: @web-architect-expert (y otros agentes especializados)

### Índice de HU

```
Ubicación: docs/technical/
Nombre: 00-INDEX-E[XXX]-HU-[YYY].md
Creado por: @web-architect-expert

Ejemplo:
docs/technical/00-INDEX-E001-HU-001.md
docs/technical/00-INDEX-E001-HU-002.md
```

### Especificaciones para Agentes

```
Ubicación: docs/technical/
Nombre: SPECS-FOR-AGENTS-E[XXX]-HU-[YYY].md
Creado por: @web-architect-expert

Ejemplo:
docs/technical/SPECS-FOR-AGENTS-E001-HU-001.md
docs/technical/SPECS-FOR-AGENTS-E001-HU-002.md
```

### Documentación Backend

```
Ubicación: docs/technical/backend/
Creado por: @supabase-expert (con guía de @web-architect-expert)

Formato:
- apis_E[XXX]-HU-[YYY].md       ← Funciones y endpoints
- schema_E[XXX]-HU-[YYY].md     ← Schema de BD (solo si aplica)

Ejemplo:
docs/technical/backend/apis_E001-HU-001.md
docs/technical/backend/schema_E001-HU-001.md
```

### Documentación Frontend

```
Ubicación: docs/technical/frontend/
Creado por: @flutter-expert

Formato: models_E[XXX]-HU-[YYY].md

Ejemplo:
docs/technical/frontend/models_E001-HU-001.md
docs/technical/frontend/models_E001-HU-002.md
```

### Documentación Design/UX

```
Ubicación: docs/technical/design/
Creado por: @ux-ui-expert

Formato: components_E[XXX]-HU-[YYY].md

Ejemplo:
docs/technical/design/components_E001-HU-001.md
docs/technical/design/components_E001-HU-002.md
```

### Documentación Integration (Mapping)

```
Ubicación: docs/technical/integration/
Creado por: @web-architect-expert

Formato: mapping_E[XXX]-HU-[YYY].md

Ejemplo:
docs/technical/integration/mapping_E001-HU-001.md
docs/technical/integration/mapping_E001-HU-002.md
```

---

## 📊 REPORTES DE IMPLEMENTACIÓN

**Responsable**: Agentes especializados al completar su parte

### Convención:
```
Ubicación: docs/technical/implementation-reports/
Formato: E[XXX]-HU-[YYY]_[AGENTE]_IMPLEMENTATION.md

AGENTE puede ser:
- UI                    (@ux-ui-expert)
- BACKEND               (@supabase-expert)
- MODELS_BLOC           (@flutter-expert)
- QA                    (@qa-testing-expert)
- FINAL_REPORT          (@web-architect-expert)
```

### Ejemplos:
```
✅ E001-HU-001_UI_IMPLEMENTATION.md                  (@ux-ui-expert)
✅ E001-HU-002_MODELS_BLOC_IMPLEMENTATION.md         (@flutter-expert)
✅ E001-HU-002_FINAL_REPORT.md                       (@web-architect-expert)
✅ E002-HU-001_BACKEND_IMPLEMENTATION.md             (@supabase-expert)
```

---

## 🗂️ MIGRACIONES DE BASE DE DATOS

**Responsable**: @supabase-expert

### Convención durante desarrollo:
```
Ubicación: supabase/migrations/
Formato: YYYYMMDDHHMMSS_[tipo]_e[XXX]_hu[YYY]_[descripcion].sql

Tipos:
- (ninguno) → Migración inicial de HU
- fix       → Corrección
- helper    → Helper de desarrollo
- refactor  → Refactorización
```

### Ejemplos:
```
✅ 20251004145739_e001_hu001_users_registration.sql
✅ 20251005040208_e001_hu002_login_functions.sql
✅ 20251005042727_fix_e001_hu002_use_supabase_auth.sql
✅ 20251006120000_e001_hu003_logout_functions.sql
✅ 20251010080000_e002_hu001_brands_table.sql  ← E002 empieza en hu001
```

### Migración consolidada:
```
Ubicación: supabase/migrations-consolidated/
Formato: E[XXX]_[nombre-epica].sql
Creado/Mantenido por: @supabase-expert

Ejemplo:
✅ E001_authentication_system.sql
✅ E002_product_management.sql
✅ E003_dashboard_navigation.sql
```

---

## 🤖 INSTRUCCIONES PARA PRODUCT OWNER

### Al crear una nueva Épica:

```markdown
1. Identificar el último número de épica existente
   - Revisar: docs/epicas/
   - Ejemplo: Si existe E002, la nueva será E003

2. Crear archivo de épica:
   - Nombre: E003-[nombre-kebab-case].md
   - Ubicación: docs/epicas/
   - Usar template de épica

3. Notificar a @web-architect-expert
   - El arquitecto creará la estructura técnica
```

### Al crear una nueva HU:

```markdown
1. Identificar la épica (E00X)

2. Contar HUs existentes de esa épica
   - Revisar: docs/historias-usuario/E00X-*
   - Ejemplo: Si E002 tiene HU-001 y HU-002, la siguiente es HU-003

3. Crear archivo HU:
   - Nombre: E00X-HU-00Y-[nombre-kebab-case].md
   - Ubicación: docs/historias-usuario/
   - Usar template de HU

4. Notificar a @web-architect-expert
   - El arquitecto creará índice y specs técnicas
   - Los agentes especializados crearán su documentación
```

---

## 🤖 INSTRUCCIONES PARA @web-architect-expert

### Cuando PO crea nueva Épica E00X:

```markdown
1. Crear estructura técnica base:
   - (Por ahora no hay docs de épica general, solo por HU)

2. Esperar a que PO cree primera HU (E00X-HU-001)
```

### Cuando PO crea nueva HU E00X-HU-00Y:

```markdown
1. Crear índice técnico:
   - docs/technical/00-INDEX-E00X-HU-00Y.md

2. Crear especificaciones para agentes:
   - docs/technical/SPECS-FOR-AGENTS-E00X-HU-00Y.md

3. Crear mapping:
   - docs/technical/integration/mapping_E00X-HU-00Y.md

4. Notificar a agentes especializados:
   - @supabase-expert → crear apis_E00X-HU-00Y.md
   - @flutter-expert → crear models_E00X-HU-00Y.md
   - @ux-ui-expert → crear components_E00X-HU-00Y.md
```

---

## 🤖 INSTRUCCIONES PARA AGENTES ESPECIALIZADOS

### @supabase-expert

Cuando @web-architect-expert te notifica nueva HU:

```markdown
1. Crear documentación backend:
   - docs/technical/backend/apis_E00X-HU-00Y.md
   - docs/technical/backend/schema_E00X-HU-00Y.md (si aplica)

2. Crear migraciones siguiendo convención:
   - Formato: YYYYMMDDHHMMSS_e00X_hu00Y_descripcion.sql

3. Mantener migración consolidada:
   - Actualizar: supabase/migrations-consolidated/E00X_nombre.sql
```

### @flutter-expert

```markdown
1. Crear documentación frontend:
   - docs/technical/frontend/models_E00X-HU-00Y.md

2. Al finalizar implementación:
   - Crear reporte: E00X-HU-00Y_MODELS_BLOC_IMPLEMENTATION.md
```

### @ux-ui-expert

```markdown
1. Crear documentación design:
   - docs/technical/design/components_E00X-HU-00Y.md

2. Al finalizar implementación:
   - Crear reporte: E00X-HU-00Y_UI_IMPLEMENTATION.md
```

---

## ⚠️ ERRORES COMUNES A EVITAR

### ❌ ERROR 1: PO usa numeración global
```
❌ E001-HU-001, E001-HU-002
❌ E002-HU-003, E002-HU-004  ← NO continuar numeración

✅ E001-HU-001, E001-HU-002
✅ E002-HU-001, E002-HU-002  ← Reiniciar en 001
```

### ❌ ERROR 2: Agente crea épica/HU (no es su responsabilidad)
```
❌ @web-architect-expert crea E003-nueva-epica.md

✅ Product Owner crea E003-nueva-epica.md
✅ @web-architect-expert crea docs técnicos después
```

### ❌ ERROR 3: Formato inconsistente
```
❌ apis_HU001.md
❌ apis-E001-HU-001.md

✅ apis_E001-HU-001.md
```

---

## 📚 TABLA DE RESPONSABILIDADES

| Documento | Responsable | Cuándo |
|-----------|-------------|--------|
| **Épica** | Product Owner | Al planificar nueva épica |
| **HU** | Product Owner | Al definir funcionalidad |
| **00-INDEX** | @web-architect-expert | Después que PO crea HU |
| **SPECS-FOR-AGENTS** | @web-architect-expert | Después que PO crea HU |
| **apis_*** | @supabase-expert | Según SPECS |
| **models_*** | @flutter-expert | Según SPECS |
| **components_*** | @ux-ui-expert | Según SPECS |
| **mapping_*** | @web-architect-expert | Después que PO crea HU |
| **Migraciones** | @supabase-expert | Durante implementación |
| **Reportes** | Agentes especializados | Al finalizar implementación |

---

## 🔄 FLUJO COMPLETO DE TRABAJO

```
1. Product Owner crea épica
   └─> docs/epicas/E003-dashboard.md

2. Product Owner crea primera HU
   └─> docs/historias-usuario/E003-HU-001-crear-dashboard.md

3. @web-architect-expert diseña arquitectura
   ├─> docs/technical/00-INDEX-E003-HU-001.md
   ├─> docs/technical/SPECS-FOR-AGENTS-E003-HU-001.md
   └─> docs/technical/integration/mapping_E003-HU-001.md

4. @supabase-expert documenta backend
   ├─> docs/technical/backend/apis_E003-HU-001.md
   └─> supabase/migrations/20251010_e003_hu001_dashboard.sql

5. @flutter-expert documenta frontend
   └─> docs/technical/frontend/models_E003-HU-001.md

6. @ux-ui-expert documenta UI
   └─> docs/technical/design/components_E003-HU-001.md

7. Agentes implementan y reportan
   ├─> E003-HU-001_BACKEND_IMPLEMENTATION.md
   ├─> E003-HU-001_UI_IMPLEMENTATION.md
   └─> E003-HU-001_FINAL_REPORT.md
```

---

**Última actualización**: 2025-10-05
**Próxima revisión**: Cuando PO cree E003