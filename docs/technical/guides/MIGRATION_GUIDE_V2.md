# Guía de Migración: Flujo v1.0 → v2.0 (Minimalista)

**Fecha**: 2025-10-07
**Razón**: Optimización de uso de tokens y eficiencia en implementación de HUs

---

## 📊 Resumen de Cambios

### Problemas Identificados
- **Alto consumo de tokens**: ~25K-35K tokens por HU
- **Documentación redundante**: 5-7 archivos por HU con información duplicada
- **Arquitecto hacía trabajo de implementación**: Diseñaba código completo
- **Ejecución en paralelo causaba errores**: Frontend no conocía estructura backend
- **Agentes pedían permisos constantemente**: "¿Puedo leer X?", "¿Debo crear Y?"

### Soluciones Implementadas
- **Reducción de tokens**: ~12K-15K tokens por HU (40-50% ahorro)
- **Documentación única**: 1 archivo por HU con 3 secciones (Backend, UI, Frontend)
- **Arquitecto minimalista**: Solo coordina, no diseña código
- **Ejecución secuencial**: Backend → UX/UI → Frontend (dependencias claras)
- **Agentes autónomos**: NO piden permisos para operaciones estándar

---

## 🔄 Cambios en el Flujo de Trabajo

### v1.0 (Anterior) - 9 PASOS
```
1. Recibir comando
2. Leer documentación base
3. Verificar convenciones
4. ❌ Diseñar arquitectura COMPLETA (código SQL, Dart, Flutter)
5. ❌ Crear 5-7 archivos de specs por HU
6. ❌ Crear SPECS-FOR-AGENTS detallado
7. ❌ Coordinar agentes EN PARALELO
8. Validar con QA
9. Gestionar resultado QA
```

### v2.0 (Nuevo) - 5 PASOS
```
1. Recibir comando
2. Leer documentación base
3. Verificar convenciones (solo si es necesario)
4. ✅ Coordinar agentes SECUENCIALMENTE:
   - Backend primero (@supabase-expert)
   - UI segundo (@ux-ui-expert)
   - Frontend último (@flutter-expert)
5. Validar con QA
```

---

## 📁 Cambios en Estructura Documental

### ❌ Archivos Eliminados (Ya NO se crean)

```
docs/technical/
├── backend/
│   ├── schema_huXXX.md              ❌ ELIMINADO
│   └── apis_huXXX.md                ❌ ELIMINADO
├── frontend/
│   └── models_huXXX.md              ❌ ELIMINADO
├── design/
│   └── components_huXXX.md          ❌ ELIMINADO
├── integration/
│   └── mapping_huXXX.md             ❌ ELIMINADO
├── SPECS-FOR-AGENTS-HU-XXX.md       ❌ ELIMINADO
├── 00-IMPLEMENTATION-REPORT-*.md    ❌ ELIMINADO
└── 00-INTEGRATION-REPORT-*.md       ❌ ELIMINADO
```

### ✅ Nueva Estructura (Minimalista)

```
docs/
├── historias-usuario/
│   └── E001-HU-XXX.md               ✅ Criterios de aceptación y estado
├── technical/
│   ├── 00-CONVENTIONS.md            ✅ Fuente única de verdad
│   ├── AGENT_RULES.md               ✅ NUEVO - Reglas para agentes
│   ├── ARCHITECT_WORKFLOW.md        ✅ ACTUALIZADO v2.0
│   └── implemented/
│       ├── TEMPLATE_HU-XXX.md       ✅ NUEVO - Template
│       └── HU-XXX_IMPLEMENTATION.md ✅ ÚNICO doc por HU (3 secciones)
└── Varios/
    └── comandos                      ✅ URLs de desarrollo
```

---

## 🎯 Nuevas Reglas para Agentes

### @web-architect-expert (Arquitecto)

**❌ YA NO HACE**:
- Diseñar código SQL completo
- Diseñar Models Dart completos
- Diseñar UI completa
- Crear múltiples archivos de specs
- Coordinar agentes en paralelo

**✅ AHORA HACE**:
- Verificar que `00-CONVENTIONS.md` cubre la HU
- Actualizar convenciones solo si falta algo crítico
- Lanzar agentes SECUENCIALMENTE (Backend → UI → Frontend)
- Validar con QA al final
- Gestionar correcciones

---

### @supabase-expert (Backend) - PRIMERO

**📖 Lee**:
1. `docs/historias-usuario/E001-HU-XXX.md`
2. `docs/technical/00-CONVENTIONS.md`
3. `docs/technical/AGENT_RULES.md`

**🎯 Implementa**:
- Migrations con naming según convenciones
- Funciones RPC con lógica de negocio
- Sin specs previos (usa tu conocimiento experto)

**📝 Documenta**:
- Crea `docs/technical/implemented/HU-XXX_IMPLEMENTATION.md`
- Sección: **Backend** (tablas, funciones RPC, JSON responses)
- ❌ NO crea: implementation-report, schema_*.md, apis_*.md

---

### @ux-ui-expert (UI) - SEGUNDO

**📖 Lee**:
1. `docs/historias-usuario/E001-HU-XXX.md`
2. `docs/technical/00-CONVENTIONS.md`
3. `docs/technical/implemented/HU-XXX_IMPLEMENTATION.md` (Backend)
4. `docs/technical/AGENT_RULES.md`

**🎯 Implementa**:
- Páginas con routing flat
- Widgets con Design System
- Layouts responsive

**📝 Documenta**:
- Actualiza `docs/technical/implemented/HU-XXX_IMPLEMENTATION.md`
- Agrega sección: **UI** (páginas, widgets, rutas)
- ❌ NO crea: archivos nuevos

---

### @flutter-expert (Frontend) - TERCERO

**📖 Lee**:
1. `docs/historias-usuario/E001-HU-XXX.md`
2. `docs/technical/00-CONVENTIONS.md`
3. `docs/technical/implemented/HU-XXX_IMPLEMENTATION.md` (Backend + UI)
4. `docs/technical/AGENT_RULES.md`

**🎯 Implementa**:
- Models con mapping explícito
- DataSource con llamadas RPC exactas
- Repository con Either<Failure, Success>
- Bloc con integración UI completa

**📝 Documenta**:
- Actualiza `docs/technical/implemented/HU-XXX_IMPLEMENTATION.md`
- Agrega sección: **Frontend** (models, datasource, repository, bloc)
- ❌ NO crea: archivos nuevos

---

### @qa-testing-expert (QA) - FINAL

**📖 Lee**:
1. `docs/historias-usuario/E001-HU-XXX.md`
2. `docs/technical/00-CONVENTIONS.md`
3. `docs/technical/implemented/HU-XXX_IMPLEMENTATION.md`
4. `docs/technical/AGENT_RULES.md`

**🎯 Valida**:
- Convenciones aplicadas
- Criterios de aceptación cumplidos
- Integración funcional
- Compilación sin errores

**📝 Documenta**:
- Actualiza `docs/technical/implemented/HU-XXX_IMPLEMENTATION.md`
- Agrega sección: **QA** (solo si hay errores)
- ✅ Si OK: Reporta aprobación directamente
- ❌ NO crea: reporte si todo está correcto

---

## 📈 Métricas Comparativas

| Métrica | v1.0 (Anterior) | v2.0 (Nuevo) | Mejora |
|---------|-----------------|--------------|--------|
| **Tokens por HU** | 25K-35K | 12K-15K | ✅ 40-50% ahorro |
| **Tiempo implementación** | ~1 día | ~4-6 horas | ✅ 50% más rápido |
| **Archivos por HU** | 5-7 archivos | 1 archivo | ✅ 85% menos archivos |
| **Errores de integración** | Alto (paralelo) | Bajo (secuencial) | ✅ Menos re-trabajo |
| **Iteraciones QA** | ≤ 2 | ≤ 1 | ✅ Menos correcciones |

---

## 🚀 Cómo Usar el Nuevo Flujo

### Para el Arquitecto

```bash
# 1. Recibir HU
Usuario: "Implementa HU-005"

# 2. Verificar convenciones
¿Necesita algo nuevo en 00-CONVENTIONS.md? NO → Continuar

# 3. Lanzar Backend
Task(@supabase-expert):
"Implementa backend HU-005
📖 LEER: docs/historias-usuario/E001-HU-005.md
📖 LEER: docs/technical/00-CONVENTIONS.md
📖 LEER: docs/technical/AGENT_RULES.md
📝 Documentar en: docs/technical/implemented/HU-005_IMPLEMENTATION.md"

[ESPERAR COMPLETAR]

# 4. Lanzar UI
Task(@ux-ui-expert):
"Implementa UI HU-005
📖 LEER: docs/historias-usuario/E001-HU-005.md
📖 LEER: docs/technical/00-CONVENTIONS.md
📖 LEER: docs/technical/implemented/HU-005_IMPLEMENTATION.md
📖 LEER: docs/technical/AGENT_RULES.md
📝 Actualizar: docs/technical/implemented/HU-005_IMPLEMENTATION.md"

[ESPERAR COMPLETAR]

# 5. Lanzar Frontend
Task(@flutter-expert):
"Implementa frontend HU-005
📖 LEER: docs/historias-usuario/E001-HU-005.md
📖 LEER: docs/technical/00-CONVENTIONS.md
📖 LEER: docs/technical/implemented/HU-005_IMPLEMENTATION.md
📖 LEER: docs/technical/AGENT_RULES.md
📝 Actualizar: docs/technical/implemented/HU-005_IMPLEMENTATION.md"

[ESPERAR COMPLETAR]

# 6. Validar con QA
Task(@qa-testing-expert):
"Valida HU-005
📖 LEER: docs/historias-usuario/E001-HU-005.md
📖 LEER: docs/technical/00-CONVENTIONS.md
📖 LEER: docs/technical/implemented/HU-005_IMPLEMENTATION.md
📖 LEER: docs/technical/AGENT_RULES.md"
```

---

## 🔍 Checklist de Migración

### Para el Arquitecto
- [x] Leer `ARCHITECT_WORKFLOW.md` v2.0
- [x] Entender flujo secuencial (Backend → UI → Frontend)
- [x] Ya NO crear specs detallados
- [x] Verificar `AGENT_RULES.md` existe

### Para Agentes Especializados
- [ ] Leer `AGENT_RULES.md` completo
- [ ] Entender documentación única progresiva
- [ ] Ya NO crear reportes individuales
- [ ] Usar template `TEMPLATE_HU-XXX.md`

### Para QA
- [ ] Leer `AGENT_RULES.md`
- [ ] Solo crear reporte si hay errores
- [ ] Validar contra `00-CONVENTIONS.md`

---

## 📞 Preguntas Frecuentes

### ¿Qué pasa con los archivos antiguos (SPECS-FOR-AGENTS, etc.)?
**R**: Se pueden mantener para HUs ya implementadas, pero para nuevas HUs NO se crean.

### ¿El arquitecto ya no hace nada?
**R**: Sí hace, pero ahora es coordinador experto, no diseñador de código. Verifica convenciones, coordina secuencia, valida QA.

### ¿Cómo sabemos que los agentes seguirán las reglas?
**R**: Cada prompt incluye referencia obligatoria a `AGENT_RULES.md`. El arquitecto debe verificar que lean este archivo.

### ¿Y si un agente crea un reporte adicional?
**R**: El arquitecto debe rechazar el resultado y pedir corrección según `AGENT_RULES.md`.

### ¿Qué pasa si hay errores en QA?
**R**: El agente responsable corrige y actualiza el MISMO archivo `HU-XXX_IMPLEMENTATION.md`. NO crea nuevos reportes.

---

## ✅ Checklist de Implementación Exitosa

- [x] `ARCHITECT_WORKFLOW.md` actualizado a v2.0
- [x] `AGENT_RULES.md` creado
- [x] Carpeta `docs/technical/implemented/` creada
- [x] Template `TEMPLATE_HU-XXX.md` creado
- [x] Guía de migración documentada
- [ ] Arquitecto probó flujo en HU de prueba
- [ ] Agentes leyeron `AGENT_RULES.md`
- [ ] Primera HU v2.0 completada exitosamente

---

**Versión**: 2.0
**Fecha**: 2025-10-07
**Próxima revisión**: Después de 3 HUs implementadas con nuevo flujo