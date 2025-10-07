# Documentación Técnica - Sistema Web Medias 3.0

**Versión**: 2.0
**Última actualización**: 2025-10-07

---

## 📂 Estructura de Documentación

```
docs/technical/
├── README.md                        # ⭐ Este archivo - índice principal
├── 00-CONVENTIONS.md                # ⭐ CONVENCIONES - Fuente única de verdad
│
├── workflows/                       # 🤖 Flujos de trabajo de agentes
│   ├── ARCHITECT_WORKFLOW.md        # Flujo del arquitecto web
│   └── AGENT_RULES.md               # Reglas para agentes especializados
│
├── guides/                          # 📖 Guías para usuarios
│   ├── QUICK_START_V2.md            # Inicio rápido v2.0
│   └── MIGRATION_GUIDE_V2.md        # Guía de migración v1.0 → v2.0
│
└── implemented/                     # ✅ Documentación de HUs implementadas
    ├── TEMPLATE_HU-XXX.md           # Template para nuevas HUs
    └── HU-XXX_IMPLEMENTATION.md     # 1 archivo por HU implementada
```

---

## 🚀 Inicio Rápido

### Para Implementar una HU

```
Tú: "Implementa HU-005"
```

**Eso es todo.** El arquitecto hace el resto automáticamente.

**Lee**: [guides/QUICK_START_V2.md](guides/QUICK_START_V2.md) para más detalles.

---

## 📖 Documentos Principales

### 1. **Convenciones (OBLIGATORIO leer primero)**

📄 **[00-CONVENTIONS.md](00-CONVENTIONS.md)** ⭐

**Qué contiene**:
- Naming conventions (snake_case, camelCase, PascalCase)
- Routing strategy (flat routes)
- Error handling patterns
- API Response format (JSON estándar)
- Design System (Theme, colores, spacing)
- Mapping BD ↔ Dart

**Quién lo usa**: Todos (arquitecto y agentes especializados)

**Cuándo leerlo**: Antes de implementar CUALQUIER HU

---

### 2. **Workflows (Para Agentes IA)**

#### 📄 [workflows/ARCHITECT_WORKFLOW.md](workflows/ARCHITECT_WORKFLOW.md)

**Para**: @web-architect-expert

**Qué contiene**:
- Flujo completo de 5 pasos para implementar HU
- Modo autónomo (sin pedir permisos)
- Coordinación secuencial: Backend → UI → Frontend → QA
- Cuándo actualizar convenciones

**Cuándo leerlo**: El arquitecto lo lee al recibir "Implementa HU-XXX"

---

#### 📄 [workflows/AGENT_RULES.md](workflows/AGENT_RULES.md)

**Para**: @supabase-expert, @flutter-expert, @ux-ui-expert, @qa-testing-expert

**Qué contiene**:
- Modo autónomo (sin pedir permisos)
- Prohibiciones absolutas (no crear reportes redundantes)
- Documentación única progresiva
- Checklist por agente
- Ejemplos antes/después

**Cuándo leerlo**: Cada agente lo lee antes de implementar su parte

---

### 3. **Guías (Para Usuarios)**

#### 📄 [guides/QUICK_START_V2.md](guides/QUICK_START_V2.md)

**Para**: Usuarios del sistema que implementan HUs

**Qué contiene**:
- Cómo usar el flujo v2.0 en 1 minuto
- Qué hace el arquitecto automáticamente
- Tiempos esperados
- Ahorro de tokens
- Ejemplo completo

**Cuándo leerlo**: Primera vez que usas el sistema v2.0

---

#### 📄 [guides/MIGRATION_GUIDE_V2.md](guides/MIGRATION_GUIDE_V2.md)

**Para**: Usuarios migrando desde v1.0

**Qué contiene**:
- Comparativa v1.0 vs v2.0
- Qué archivos se eliminaron
- Nuevas reglas para agentes
- Métricas de mejora
- FAQ

**Cuándo leerlo**: Si venías usando el flujo anterior (v1.0)

---

### 4. **Templates e Implementaciones**

#### 📄 [implemented/TEMPLATE_HU-XXX.md](implemented/TEMPLATE_HU-XXX.md)

**Para**: Agentes que documentan implementaciones

**Qué contiene**:
- Template con 3 secciones: Backend, UI, Frontend
- Checklist de verificación
- Estructura estándar para documentar

**Cuándo usarlo**: Cada agente copia este template para nueva HU

---

#### 📁 [implemented/](implemented/)

**Para**: Referencia de HUs implementadas

**Qué contiene**:
- 1 archivo por HU implementada (ej: `HU-005_IMPLEMENTATION.md`)
- Secciones: Backend, UI, Frontend, QA
- Documentación progresiva (cada agente actualiza su sección)

**Cuándo consultarlo**: Para entender qué se implementó en una HU

---

## 🔄 Flujo de Trabajo Completo

```
Usuario: "Implementa HU-005"
    ↓
@web-architect-expert (lee workflows/ARCHITECT_WORKFLOW.md)
    ↓
├─ Lee: docs/historias-usuario/E001-HU-005.md
├─ Lee: 00-CONVENTIONS.md
├─ Verifica convenciones suficientes
    ↓
├─ Lanza @supabase-expert (lee workflows/AGENT_RULES.md)
│   └─ Implementa backend
│   └─ Documenta en implemented/HU-005_IMPLEMENTATION.md (sección Backend)
│   └─ Reporta: "✅ Backend completado"
    ↓
├─ Lanza @ux-ui-expert (lee workflows/AGENT_RULES.md)
│   └─ Lee implemented/HU-005_IMPLEMENTATION.md (backend)
│   └─ Implementa UI
│   └─ Actualiza implemented/HU-005_IMPLEMENTATION.md (sección UI)
│   └─ Reporta: "✅ UI completado"
    ↓
├─ Lanza @flutter-expert (lee workflows/AGENT_RULES.md)
│   └─ Lee implemented/HU-005_IMPLEMENTATION.md (backend + UI)
│   └─ Implementa frontend integrado
│   └─ Actualiza implemented/HU-005_IMPLEMENTATION.md (sección Frontend)
│   └─ Reporta: "✅ Frontend completado"
    ↓
├─ Lanza @qa-testing-expert (lee workflows/AGENT_RULES.md)
│   └─ Lee implemented/HU-005_IMPLEMENTATION.md (todo)
│   └─ Valida convenciones y criterios
│   └─ Reporta: "✅ QA aprobado" o lista errores
    ↓
└─ Reporta a usuario: "✅ HU-005 implementada y validada"
```

---

## 📊 Métricas v2.0

| Métrica | Valor | Comparado con v1.0 |
|---------|-------|-------------------|
| **Tokens por HU** | 12K-15K | -50% (antes 25K-35K) |
| **Tiempo por HU** | 4-6 horas | -50% (antes 1 día) |
| **Archivos por HU** | 1 | -85% (antes 5-7) |
| **Autonomía** | Alta | ✅ Agentes autónomos |
| **Errores integración** | Bajo | ✅ Flujo secuencial |

---

## 🔍 Cómo Encontrar Información

### "¿Cómo nombro una tabla en PostgreSQL?"
→ Lee: [00-CONVENTIONS.md](00-CONVENTIONS.md) - Sección 1.1 (Naming - Backend)

### "¿Cómo defino rutas en Flutter?"
→ Lee: [00-CONVENTIONS.md](00-CONVENTIONS.md) - Sección 2 (Routing Strategy)

### "¿Cómo implemento una HU nueva?"
→ Lee: [guides/QUICK_START_V2.md](guides/QUICK_START_V2.md)

### "¿Qué hace el arquitecto automáticamente?"
→ Lee: [workflows/ARCHITECT_WORKFLOW.md](workflows/ARCHITECT_WORKFLOW.md)

### "¿Qué reglas deben seguir los agentes?"
→ Lee: [workflows/AGENT_RULES.md](workflows/AGENT_RULES.md)

### "¿Qué se implementó en HU-005?"
→ Lee: [implemented/HU-005_IMPLEMENTATION.md](implemented/HU-005_IMPLEMENTATION.md)

### "¿Cómo migro desde v1.0?"
→ Lee: [guides/MIGRATION_GUIDE_V2.md](guides/MIGRATION_GUIDE_V2.md)

---

## 🚨 Reglas de Oro

1. **`00-CONVENTIONS.md` es la fuente única de verdad**
   - Si hay conflicto, 00-CONVENTIONS.md gana SIEMPRE

2. **1 archivo por HU** (en `implemented/`)
   - NO crear: SPECS-FOR-AGENTS, IMPLEMENTATION-REPORT, etc.

3. **Agentes son autónomos**
   - NO piden permisos para leer/crear archivos estándar

4. **Flujo secuencial**: Backend → UI → Frontend → QA
   - NO paralelo (causa errores de integración)

5. **Arquitecto coordina, NO implementa**
   - Los agentes especializados son los expertos

---

## 📞 Soporte

**Si tienes dudas**:
1. Revisa este README primero
2. Lee el documento correspondiente según tabla arriba
3. Si no está documentado, actualiza `00-CONVENTIONS.md`

**Si encuentras error en documentación**:
1. Repórtalo al arquitecto
2. Actualiza el documento correspondiente
3. Notifica a agentes afectados

---

## 📝 Historial de Versiones

- **v2.0** (2025-10-07): Flujo minimalista + autónomo
  - Reducción 50% tokens
  - Agentes autónomos
  - Documentación organizada en carpetas
  - 1 archivo por HU

- **v1.0** (2025-10-04): Flujo inicial
  - 9 pasos arquitecto
  - Múltiples archivos por HU
  - Agentes pedían permisos

---

**Mantenido por**: @web-architect-expert
**Próxima revisión**: Después de 5 HUs implementadas con v2.0