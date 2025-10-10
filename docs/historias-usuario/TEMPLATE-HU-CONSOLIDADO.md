# EXXX-HU-XXX: [Título de la Historia]

## 📋 INFORMACIÓN
- **Código**: EXXX-HU-XXX
- **Épica**: EXXX - [Nombre Épica]
- **Título**: [Título]
- **Story Points**: X pts
- **Estado**: 🟡 En Progreso / ✅ Completada
- **Fecha Creación**: YYYY-MM-DD

---

## 🎯 HISTORIA DE USUARIO

**Como** [rol]
**Quiero** [funcionalidad]
**Para** [beneficio]

---

## ✅ CRITERIOS DE ACEPTACIÓN

### CA-001: [Título Criterio]
- [ ] **DADO** que [contexto]
- [ ] **CUANDO** [acción]
- [ ] **ENTONCES** [resultado esperado]

**Implementación**:
- Backend: [función RPC / tabla]
- Frontend: [usecase / datasource]
- UI: [widget / página]

### CA-002: [Título Criterio]
...

---

## 📐 REGLAS DE NEGOCIO

### RN-001: [Título Regla]
**Descripción**: [regla de negocio]

**Implementación**:
- Backend: [constraint / validación]
- Frontend: [validación]

### RN-002: [Título Regla]
...

---

## 🔧 IMPLEMENTACIÓN TÉCNICA

### Backend (@supabase-expert)

**Estado**: 🟡 Pendiente / 🔵 En Progreso / ✅ Completado
**Fecha**: YYYY-MM-DD

<details>
<summary><b>Ver detalles técnicos</b></summary>

#### Archivos Modificados
- `supabase/migrations/00000000000003_catalog_tables.sql`
- `supabase/migrations/00000000000005_functions.sql`

#### Tablas Creadas/Modificadas

**Tabla**: `nombre_tabla`
```sql
CREATE TABLE nombre_tabla (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    columna VARCHAR(50) NOT NULL
);
```

#### Funciones RPC Implementadas

**`nombre_funcion(p_param TYPE) → JSON`**
- Descripción: Qué hace
- Reglas: RN-001, RN-002
- Request: `{"p_param": "value"}`
- Response: `{"success": true, "data": {...}}`

#### Verificación
- [x] Migrations aplicadas (`npx supabase db reset`)
- [x] Funciones probadas
- [x] Convenciones aplicadas

</details>

---

### Frontend (@flutter-expert)

**Estado**: 🟡 Pendiente / 🔵 En Progreso / ✅ Completado
**Fecha**: YYYY-MM-DD

<details>
<summary><b>Ver detalles técnicos</b></summary>

#### Archivos Creados/Modificados
- `lib/features/[modulo]/data/models/model_name.dart`
- `lib/features/[modulo]/data/datasources/datasource_name.dart`
- `lib/features/[modulo]/data/repositories/repository_impl.dart`
- `lib/features/[modulo]/presentation/bloc/bloc_name.dart`

#### Models
**ModelName**: Propiedades, mapping snake_case ↔ camelCase

#### DataSource
**Methods**: Llaman RPC, manejan errores

#### Repository
**Methods**: Either<Failure, Success> pattern

#### Bloc
**Estados**: Initial, Loading, Success, Error
**Eventos**: Eventos de UI

#### Verificación
- [x] flutter analyze: 0 errores
- [x] Mapping explícito
- [x] Integración end-to-end funcional

</details>

---

### UI (@ux-ui-expert)

**Estado**: 🟡 Pendiente / 🔵 En Progreso / ✅ Completado
**Fecha**: YYYY-MM-DD

<details>
<summary><b>Ver detalles técnicos</b></summary>

#### Páginas Creadas
**PageName** (`/ruta`):
- CA implementados: CA-001, CA-002
- Componentes: Widget1, Widget2
- Estados: Loading, Success, Error
- Responsive: Mobile/Desktop

#### Widgets Principales
**WidgetName**:
- Descripción: Qué hace
- Props: prop1, prop2
- Uso: Página X

#### Rutas Configuradas
```dart
'/ruta': (context) => PageName()
```

#### Design System
- Colores: Theme.of(context).colorScheme.primary
- Spacing: DesignTokens.spacingMedium
- Responsive: < 600px Mobile, >= 1200px Desktop

#### Verificación
- [x] TODOS los CA cubiertos en UI
- [x] Sin colores hardcoded
- [x] Routing flat
- [x] Responsive verificado
- [x] Sin overflow warnings

</details>

---

### QA (@qa-testing-expert)

**Estado**: 🟡 Pendiente / 🔵 En Progreso / ✅ Aprobado / ❌ Rechazado
**Fecha**: YYYY-MM-DD

<details>
<summary><b>Ver resultados de validación</b></summary>

#### Validación Técnica
- [ ] flutter analyze: 0 errores
- [ ] flutter test: Todos pasan
- [ ] App ejecuta sin crashes

#### Criterios de Aceptación
- [ ] CA-001: ✅ PASS / ❌ FAIL - [Observaciones]
- [ ] CA-002: ✅ PASS / ❌ FAIL - [Observaciones]

**CA Cumplidos**: X/Y

#### Reglas de Negocio
- [ ] RN-001: ✅ PASS / ❌ FAIL - [Observaciones]

**RN Cumplidas**: X/Y

#### Testing Manual
**Test Case 1**: [Descripción]
- Resultado: ✅ PASS / ❌ FAIL

#### Errores Encontrados
1. [Descripción error] - **Severidad**: Alta/Media/Baja

#### Resumen
**Estado General**: ✅ APROBADO / ❌ RECHAZADO

**Conclusión**: [Descripción]

</details>

---

## 📝 NOTAS Y OBSERVACIONES

- [Cualquier nota importante]

---

**Creado por**: @po-user-stories-template
**Última actualización**: YYYY-MM-DD
