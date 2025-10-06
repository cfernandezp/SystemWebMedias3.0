# Implementation Reports

**Propósito**: Reportes de implementación creados por los agentes técnicos durante el desarrollo de cada Historia de Usuario.

---

## 📋 Estructura de Archivos

### Formato de nombres:
```
HU[XXX]_[AGENTE]_IMPLEMENTATION.md
HU[XXX]_FINAL_REPORT.md
```

**Ejemplos**:
- `HU001_UI_IMPLEMENTATION.md` - Reporte de @ux-ui-expert para HU-001
- `HU002_MODELS_BLOC_IMPLEMENTATION.md` - Reporte de @flutter-expert para HU-002
- `HU002_FINAL_REPORT.md` - Reporte final consolidado por @web-architect-expert

---

## ✅ Cuándo crear un reporte aquí

Los agentes PUEDEN crear reportes de implementación en esta carpeta cuando:
- Completan una tarea compleja que requiere documentación detallada
- Necesitan documentar decisiones técnicas tomadas durante la implementación
- Quieren reportar lecciones aprendidas o issues encontrados
- Realizan un reporte final de HU con métricas y validación QA

---

## ⚠️ Política de documentación

**IMPORTANTE**: Los agentes NO deben crear documentos en la raíz del proyecto (`/`).

### ❌ NO HACER:
```
/ (raíz del proyecto)
├── IMPLEMENTATION_SUMMARY_*.md      ← ❌ NUNCA
├── HU*_REPORT.md                    ← ❌ NUNCA
└── cualquier_archivo.md             ← ❌ NUNCA
```

### ✅ SÍ HACER:
```
docs/technical/implementation-reports/
├── HU001_UI_IMPLEMENTATION.md       ← ✅ CORRECTO
├── HU002_MODELS_BLOC_IMPLEMENTATION.md ← ✅ CORRECTO
└── HU002_FINAL_REPORT.md            ← ✅ CORRECTO
```

---

## 📝 Alternativa preferida: Actualizar docs existentes

En lugar de crear nuevos reportes, los agentes DEBEN PREFERIR actualizar la documentación técnica existente:

| Agente | Actualizar en |
|--------|---------------|
| @supabase-expert | `docs/technical/backend/apis_hu00X.md` |
| @flutter-expert | `docs/technical/frontend/models_hu00X.md` |
| @ux-ui-expert | `docs/technical/design/components_hu00X.md` |
| @qa-testing-expert | `docs/technical/00-INDEX-HU00X.md` (sección QA) |

**Solo crear reportes aquí si**:
- La información es demasiado extensa para incluir en los docs técnicos
- Es un reporte final que consolida múltiples agentes
- Documenta lecciones aprendidas post-implementación

---

## 📂 Reportes actuales

### HU-001: Registro de Alta al Sistema
- [HU001_UI_IMPLEMENTATION.md](HU001_UI_IMPLEMENTATION.md) - Implementación UI/UX por @ux-ui-expert

### HU-002: Login al Sistema
- [HU002_UI_IMPLEMENTATION.md](HU002_UI_IMPLEMENTATION.md) - Implementación UI/UX por @ux-ui-expert
- [HU002_MODELS_BLOC_IMPLEMENTATION.md](HU002_MODELS_BLOC_IMPLEMENTATION.md) - Models y Bloc por @flutter-expert
- [HU002_FINAL_REPORT.md](HU002_FINAL_REPORT.md) - Reporte final consolidado por @web-architect-expert

---

**Última actualización**: 2025-10-05
**Mantenido por**: @web-architect-expert
