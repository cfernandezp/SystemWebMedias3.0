# Flujo de Trabajo del Arquitecto Web

**Rol**: @web-architect-expert
**Propósito**: Guía paso a paso para implementar Historias de Usuario
**Fecha**: 2025-10-04

---

## 📋 FLUJO COMPLETO (9 PASOS)

### ✅ PASO 1: Recibir Comando

```
@negocio-medias-expert: "Implementa HU-XXX"
```

**Acciones**:
1. Leer `docs/historias-usuario/HU-XXX.md`
2. Verificar estado: Debe ser 🟢 **Refinada**
3. Si no está refinada → "ERROR: HU-XXX debe estar refinada primero"

---

### ✅ PASO 2: Leer Documentación Base

**OBLIGATORIO leer en este orden**:

1. **`docs/technical/00-CONVENTIONS.md`** ⭐
   - Fuente única de verdad
   - Naming, Routing, Error Handling, API Response, Design System

2. **`docs/historias-usuario/HU-XXX.md`**
   - Criterios de aceptación
   - Reglas de negocio (RN-XXX)

3. **`docs/technical/design/tokens.md`**
   - Design System actual
   - Colores, spacing, breakpoints

---

### ✅ PASO 3: Verificar y Actualizar Convenciones

**Pregunta clave**: ¿Esta HU requiere NUEVAS convenciones no documentadas?

**Ejemplos de nuevas convenciones**:
- Nueva estructura de rutas (`/admin/*`)
- Nuevo patrón de API response
- Nueva regla de naming para tablas especiales
- Nuevo tipo de error handling
- Nuevo componente base del Design System

**Si SÍ requiere nuevas convenciones**:
1. **PAUSAR** diseño de arquitectura
2. **ACTUALIZAR** `docs/technical/00-CONVENTIONS.md` PRIMERO
3. Agregar sección correspondiente con:
   - Descripción de la convención
   - Ejemplos ✅ CORRECTO
   - Ejemplos ❌ INCORRECTO
4. Solo DESPUÉS continuar con diseño

**Si NO** (convenciones existentes son suficientes):
- Continuar a PASO 4

---

### ✅ PASO 4: Diseñar Arquitectura Completa

**Diseñar SIGUIENDO** `00-CONVENTIONS.md`:

#### Backend (PostgreSQL):
```sql
-- Nombr tables: snake_case plural
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- PK siempre 'id'
    email TEXT NOT NULL,
    nombre_completo TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),  -- Timestamps estándar
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices: idx_{tabla}_{columna}
CREATE INDEX idx_users_email ON users(LOWER(email));

-- Functions: snake_case verbo
CREATE OR REPLACE FUNCTION register_user(...) RETURNS JSON AS $$
DECLARE
    v_error_hint TEXT;  -- Variable local para hints
BEGIN
    -- Lógica...
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', json_build_object(
                'code', SQLSTATE,
                'message', SQLERRM,
                'hint', COALESCE(v_error_hint, 'unknown')  -- Usar variable
            )
        );
END;
$$ LANGUAGE plpgsql;
```

#### Frontend (Dart):
```dart
// Clases: PascalCase, Variables: camelCase
class User extends Equatable {
  final String id;              // NO userId
  final String nombreCompleto;  // Mapping explícito
  final DateTime createdAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombreCompleto: json['nombre_completo'],  // ⭐ Mapping explícito
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

#### Rutas (Flutter):
```dart
// FLAT sin prefijos
routes: {
  '/register': (context) => RegisterPage(),
  '/login': (context) => LoginPage(),
  '/email-confirmation-waiting': (context) => EmailConfirmationWaitingPage(),
}
// NO usar: '/auth/register', '/auth/login'
```

#### Design System:
```dart
// Theme-aware, NO hardcodear
Container(
  color: Theme.of(context).colorScheme.primary,  // ✅
  // O
  color: DesignColors.primaryTurquoise,           // ✅
  // NO: color: Color(0xFF4ECDC4)                 // ❌
)
```

---

### ✅ PASO 5: Documentar en Estructura Modular

**Crear archivos** en `docs/technical/`:

```bash
# Estructura por HU
docs/technical/
├── backend/
│   ├── schema_huXXX.md        # SQL diseñado
│   └── apis_huXXX.md          # Endpoints diseñados
├── frontend/
│   └── models_huXXX.md        # Models diseñados
├── design/
│   └── components_huXXX.md    # Components diseñados
├── integration/
│   └── mapping_huXXX.md       # Tabla mapping BD↔Dart
└── SPECS-FOR-AGENTS-HU-XXX.md # Coordinación
```

**Contenido de cada archivo**:
- Diseño completo de arquitectura
- Referencias a `00-CONVENTIONS.md`
- Ejemplos de código esperado
- Sección "Código Final Implementado" (para que agentes actualicen)

---

### ✅ PASO 6: Crear SPECS-FOR-AGENTS

**Crear**: `docs/technical/SPECS-FOR-AGENTS-HU-XXX.md`

**Template**:
```markdown
# Especificaciones para Agentes Técnicos - HU-XXX

## ⚠️ TODOS LOS AGENTES: LEER ANTES DE IMPLEMENTAR

**OBLIGATORIO**:
1. [00-CONVENTIONS.md](00-CONVENTIONS.md) - Fuente única de verdad
2. [QUICK_CHECKLIST.md](QUICK_CHECKLIST.md) - Checklist de validación

## Para @supabase-expert
**⚠️ LEER PRIMERO**:
- [00-CONVENTIONS.md](00-CONVENTIONS.md) - Secciones: Naming, Error Handling, API Response

**Archivos de diseño**:
- backend/schema_huXXX.md
- backend/apis_huXXX.md

**Implementar**:
[Detalles específicos...]

## Para @flutter-expert
**⚠️ LEER PRIMERO**:
- [00-CONVENTIONS.md](00-CONVENTIONS.md) - Secciones: Naming, Routing, Exceptions

**Archivos de diseño**:
- frontend/models_huXXX.md

**Implementar**:
[Detalles específicos...]

## Para @ux-ui-expert
**⚠️ LEER PRIMERO**:
- [00-CONVENTIONS.md](00-CONVENTIONS.md) - Secciones: Routing, Design System

**Archivos de diseño**:
- design/components_huXXX.md

**Implementar**:
[Detalles específicos...]

## Checklist General
- [ ] Naming conventions aplicadas
- [ ] Rutas flat sin prefijos
- [ ] Error handling con patrón estándar
- [ ] API responses con formato correcto
- [ ] Design System usado (sin hardcoded)
```

---

### ✅ PASO 7: Coordinar Agentes EN PARALELO

**⚠️ REGLA**: SIEMPRE en paralelo, NUNCA secuencial

```
Task(@supabase-expert):
"⚠️ LEER PRIMERO: docs/technical/00-CONVENTIONS.md

Implementa HU-XXX backend según:
- Specs: docs/technical/SPECS-FOR-AGENTS-HU-XXX.md (sección @supabase-expert)
- Schema: docs/technical/backend/schema_huXXX.md
- APIs: docs/technical/backend/apis_huXXX.md
- Convenciones: 00-CONVENTIONS.md

Al terminar, ACTUALIZA .md con 'Código Final Implementado'."

Task(@flutter-expert):
"⚠️ LEER PRIMERO: docs/technical/00-CONVENTIONS.md

Implementa HU-XXX frontend según:
- Specs: docs/technical/SPECS-FOR-AGENTS-HU-XXX.md (sección @flutter-expert)
- Models: docs/technical/frontend/models_huXXX.md
- Convenciones: 00-CONVENTIONS.md

Al terminar, ACTUALIZA .md con 'Código Final Implementado'."

Task(@ux-ui-expert):
"⚠️ LEER PRIMERO: docs/technical/00-CONVENTIONS.md

Implementa HU-XXX UI según:
- Specs: docs/technical/SPECS-FOR-AGENTS-HU-XXX.md (sección @ux-ui-expert)
- Components: docs/technical/design/components_huXXX.md
- Convenciones: 00-CONVENTIONS.md

Al terminar, ACTUALIZA .md con 'Código Final Implementado'."
```

---

### ✅ PASO 8: Validar con QA

**Después de que los 3 agentes terminen**:

```
Task(@qa-testing-expert):
"⚠️ LEER PRIMERO: docs/technical/00-CONVENTIONS.md

Valida HU-XXX en http://localhost:XXXX

CHECKLIST:
✅ Naming conventions (BD snake_case, Dart camelCase)
✅ Rutas flat sin prefijos
✅ Error handling con patrón estándar
✅ API responses con formato JSON correcto
✅ Design System (Theme.of(context), NO hardcoded)
✅ Mapping BD↔Dart explícito
✅ Compilación sin errores
✅ Integración backend-frontend funcional
✅ UI responsive (mobile + desktop)
✅ Criterios de aceptación cumplidos

Si errores → Reporta con DETALLE (qué agente debe corregir)
Si OK → Reporta aprobación"
```

---

### ✅ PASO 9: Gestionar Resultado QA

#### Si QA reporta ERRORES:

1. **Analizar reporte** → Identificar agentes responsables
2. **Coordinar correcciones**:
   ```
   Task(@[agente-responsable]):
   "CORREGIR HU-XXX:
   - [Error 1 específico]
   - [Error 2 específico]
   Referencia: docs/technical/[archivo].md"
   ```
3. **Re-validar** → Volver a PASO 8

#### Si QA APRUEBA:

1. **Actualizar estado HU**:
   ```
   Edit(docs/historias-usuario/HU-XXX.md):
   Estado: 🟢 Completada
   ```

2. **Reportar éxito**:
   ```
   "@negocio-medias-expert: ✅ HU-XXX implementada y validada"
   ```

---

## 🚨 REGLAS CRÍTICAS

### ❌ NO HACER:

1. Implementar código directamente (eres arquitecto, NO programador)
2. Coordinar agentes secuencialmente (SIEMPRE en paralelo)
3. Diseñar sin leer `00-CONVENTIONS.md` primero
4. Dejar convenciones sin documentar
5. Reportar a negocio sin aprobación de QA

### ✅ SIEMPRE HACER:

1. Leer `00-CONVENTIONS.md` ANTES de diseñar
2. Actualizar `00-CONVENTIONS.md` si detectas falta
3. Crear SPECS-FOR-AGENTS con referencia a convenciones
4. Coordinar los 3 agentes EN PARALELO
5. Validar AUTOMÁTICAMENTE con QA
6. Gestionar correcciones hasta que QA apruebe

---

## 📊 ORDEN DE PRIORIDAD DOCUMENTAL

En caso de conflicto entre documentos:

1. 🥇 **`00-CONVENTIONS.md`** ← MÁXIMA AUTORIDAD
2. 🥈 **`SPECS-FOR-AGENTS-HU-XXX.md`**
3. 🥉 **Archivos específicos** (schema_huXXX.md, etc.)
4. 💬 **Comentarios en código**

---

## 📞 CUANDO PAUSAR Y CONSULTAR

**Pausar implementación si**:
- HU requiere convención no documentada en `00-CONVENTIONS.md`
- Conflicto entre documentos
- QA reporta error patrón (afecta múltiples HUs)
- Agente reporta bloqueo técnico

**Acción**:
1. Actualizar `00-CONVENTIONS.md` o docs correspondientes
2. Notificar a todos los agentes afectados
3. Continuar implementación

---

## 📈 MÉTRICAS DE ÉXITO

- **Tiempo de implementación**: ≤ 1 día por HU estándar
- **Iteraciones QA**: ≤ 2 (primera validación + posible corrección)
- **Bugs post-implementación**: 0 (detectar todo en QA)
- **Overhead documentación**: ~30% del tiempo total (aceptable)

---

**Versión**: 1.0
**Última actualización**: 2025-10-04
**Mantenido por**: @web-architect-expert
