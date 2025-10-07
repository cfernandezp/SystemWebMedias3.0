# Quick Start - Flujo v2.0 Minimalista

**Para**: Usuarios del sistema que implementan HUs
**Versión**: 2.0
**Fecha**: 2025-10-07

---

## 🚀 Cómo Implementar una HU (Historia de Usuario)

### Tú solo dices:

```
"Implementa HU-005"
```

**Eso es todo.** El arquitecto hace el resto automáticamente.

---

## 🤖 Qué Hace el Arquitecto Automáticamente

```
Arquitecto (@web-architect-expert):
├─ [Lee HU-005]
├─ [Verifica convenciones]
├─ [Lanza Backend] → ESPERA
├─ [Lanza UI] → ESPERA
├─ [Lanza Frontend] → ESPERA
├─ [Lanza QA] → ESPERA
└─ [Te reporta resultado]
```

**NO te pregunta** nada intermedio. **NO pide permisos** para leer/crear archivos.

---

## ✅ Resultado Esperado

### Si todo OK:
```
Arquitecto: "✅ HU-005 implementada y validada por QA"
```

### Si hay errores:
```
Arquitecto: "❌ HU-005 con errores:
1. [Error en backend]: [descripción]
2. [Error en UI]: [descripción]

Corrigiendo... [lanza agentes para corregir]"
```

---

## 📁 Documentación Generada

Solo **1 archivo** por HU:
```
docs/technical/implemented/HU-005_IMPLEMENTATION.md
├─ Sección Backend (@supabase-expert)
├─ Sección UI (@ux-ui-expert)
└─ Sección Frontend (@flutter-expert)
```

**NO se crean**:
- ❌ `00-IMPLEMENTATION-REPORT-*.md`
- ❌ `00-INTEGRATION-REPORT-*.md`
- ❌ `SPECS-FOR-AGENTS-*.md`
- ❌ Múltiples archivos dispersos

---

## 🔧 Qué Hace Cada Agente

### 1. Backend (@supabase-expert) - PRIMERO
- Lee HU y convenciones
- Implementa migrations + funciones RPC
- Aplica migrations a BD
- Documenta funciones implementadas
- ✅ Reporta: "Backend completado"

### 2. UI (@ux-ui-expert) - SEGUNDO
- Lee HU, convenciones y backend
- Implementa páginas y widgets
- Configura rutas
- Verifica UI renderiza
- ✅ Reporta: "UI completado"

### 3. Frontend (@flutter-expert) - TERCERO
- Lee HU, convenciones, backend y UI
- Implementa models, datasource, repository, bloc
- Integra todo el flujo
- Compila sin errores
- ✅ Reporta: "Frontend completado"

### 4. QA (@qa-testing-expert) - FINAL
- Valida convenciones aplicadas
- Valida criterios de aceptación
- Prueba flujo end-to-end
- ✅ Reporta: "QA aprobado" o lista errores

---

## ⏱️ Tiempos Esperados

| HU Complejidad | Tiempo v1.0 | Tiempo v2.0 | Ahorro |
|----------------|-------------|-------------|--------|
| Simple (3 pts) | ~6-8 horas | ~2-3 horas | 60% |
| Media (5 pts) | ~1 día | ~4-6 horas | 50% |
| Compleja (8 pts)| ~2 días | ~1 día | 50% |

---

## 📊 Ahorro de Tokens

| Métrica | v1.0 | v2.0 | Ahorro |
|---------|------|------|--------|
| Tokens arquitecto | 10K-15K | 2K-3K | **80%** |
| Tokens agentes | 15K-20K | 10K-12K | **40%** |
| **Total por HU** | **25K-35K** | **12K-15K** | **50%** |

---

## 🚨 Cuándo el Arquitecto Te Pregunta

**SOLO te pregunta si**:
- ❌ Detecta que vas a eliminar código funcional importante
- ❌ Encuentra conflicto crítico en convenciones que requiere decisión
- ❌ QA reporta error que requiere decisión de negocio (no técnica)

**Para TODO lo demás**: Opera autónomamente.

---

## 📖 Documentos de Referencia

Si quieres entender detalles:

1. **[ARCHITECT_WORKFLOW.md](ARCHITECT_WORKFLOW.md)** - Flujo completo del arquitecto
2. **[AGENT_RULES.md](AGENT_RULES.md)** - Reglas para agentes especializados
3. **[00-CONVENTIONS.md](00-CONVENTIONS.md)** - Convenciones técnicas
4. **[MIGRATION_GUIDE_V2.md](MIGRATION_GUIDE_V2.md)** - Migración v1.0 → v2.0

---

## 🎯 Ejemplo Completo

```
Usuario: "Implementa HU-006"

Arquitecto:
[Lee HU-006] ✅
[Verifica convenciones] ✅
[Lanza @supabase-expert]
  └─ Backend implementa login_user() function
  └─ Backend documenta en HU-006_IMPLEMENTATION.md
  └─ Backend: "✅ Completado"
[Lanza @ux-ui-expert]
  └─ UI implementa LoginPage
  └─ UI actualiza HU-006_IMPLEMENTATION.md
  └─ UI: "✅ Completado"
[Lanza @flutter-expert]
  └─ Frontend implementa LoginBloc, LoginRepository
  └─ Frontend actualiza HU-006_IMPLEMENTATION.md
  └─ Frontend: "✅ Completado"
[Lanza @qa-testing-expert]
  └─ QA valida flujo login completo
  └─ QA: "✅ Aprobado"

Arquitecto: "✅ HU-006 implementada y validada"
```

**Tiempo total**: ~3-4 horas
**Tokens usados**: ~12K
**Archivos creados**: 1 (HU-006_IMPLEMENTATION.md)

---

## 💡 Tips

1. **Confía en el arquitecto**: Es autónomo, no necesita micro-management
2. **Revisa al final**: Valida el resultado cuando te reporte completado
3. **Si hay dudas**: Lee `HU-XXX_IMPLEMENTATION.md` para ver qué se implementó
4. **Feedback**: Si algo no funciona, dilo directo y el arquitecto coordina corrección

---

**Última actualización**: 2025-10-07
**Próxima revisión**: Después de 5 HUs implementadas