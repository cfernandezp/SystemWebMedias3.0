# 🔧 Mejoras de Prompts de Agentes - Post-Análisis Error HU-002

**Fecha**: 2025-10-16
**Causa**: Error `TipoDocumentoListSuccess` no existe (debió ser `TipoDocumentoListLoaded`)
**Responsable**: @ux-ui-expert NO leyó código de @flutter-expert antes de implementar

---

## 🔴 PROBLEMA IDENTIFICADO

### Error Específico
```
lib/features/personas/presentation/pages/personas_list_page.dart:178:30: Error: 'TipoDocumentoListSuccess' isn't a type.
                if (state is TipoDocumentoListSuccess) {
                             ^^^^^^^^^^^^^^^^^^^^^^^^
```

### Causa Raíz

**@ux-ui-expert asumió nombres** que no existían:
- Asumió: `TipoDocumentoListSuccess` + `state.tiposDocumento`
- Real: `TipoDocumentoListLoaded` + `state.tipos`

**@ux-ui-expert NO leyó** archivos de @flutter-expert (HU-001):
- ❌ NO leyó `lib/features/tipos_documento/presentation/bloc/tipo_documento_state.dart`
- ❌ NO verificó nombres exactos de estados
- ❌ NO verificó nombres exactos de propiedades

---

## ✅ MEJORAS PROPUESTAS POR AGENTE

### 1. @web-architect-expert (Coordinador)

#### Problema Actual
- Prompt NO especifica archivos exactos a leer de HUs anteriores
- Asume que agentes leerán código previo (no lo hacen)

#### Mejora Propuesta

**AGREGAR después de línea 205** (Paso 6 - Lanzar UI):

```markdown
### 6. Lanzar UI (Tercero) - MEJORA CRÍTICA

**REPORTA AL USUARIO**:
```
📊 Paso 6/8 - 75% completado
🔄 Lanzando @ux-ui-expert para implementar UI HU-XXX
⏳ Creando: Pages, Widgets, Responsive
```

**ANTES DE LANZAR @ux-ui-expert**:
```bash
# PASO PREVIO OBLIGATORIO: Identificar dependencias de features anteriores

# 1. Leer HU para identificar dependencias
Read(docs/historias-usuario/E00X-HU-XXX.md)

# 2. Si HU menciona usar Blocs de HUs anteriores (ej: TipoDocumentoBloc, ColorBloc):
Glob(lib/features/[feature_anterior]/presentation/bloc/*_state.dart)
Glob(lib/features/[feature_anterior]/presentation/bloc/*_event.dart)

# 3. Extraer nombres EXACTOS:
#    - Estados: TipoDocumentoListLoaded (NO TipoDocumentoListSuccess)
#    - Propiedades: state.tipos (NO state.tiposDocumento)

# 4. Documentar en prompt de @ux-ui-expert
```

**PROMPT MEJORADO AL LANZAR @ux-ui-expert**:
```bash
Task(@ux-ui-expert):
"Implementa UI HU-XXX (visualización de Bloc)

📖 LEER OBLIGATORIO (ANTES DE CODIFICAR):
1. docs/historias-usuario/E00X-HU-XXX.md (CA + Backend + Frontend)
2. docs/technical/00-CONVENTIONS.md (sección 2, 5)
3. ⭐ CRÍTICO - DEPENDENCIAS DE HUs ANTERIORES:

   Esta HU usa Blocs de features anteriores. DEBES leer PRIMERO:

   ```bash
   # HU-001 - Tipos de Documento
   Read(lib/features/tipos_documento/presentation/bloc/tipo_documento_state.dart)
   Read(lib/features/tipos_documento/presentation/bloc/tipo_documento_event.dart)

   # Extraer nombres EXACTOS (NO asumir):
   # - Estados de lista: TipoDocumentoListLoaded (línea 15)
   # - Propiedad datos: state.tipos (línea 16)
   # - Evento listar: ListarTiposDocumentoEvent (archivo event.dart)
   ```

   **ANOTAR ANTES DE IMPLEMENTAR**:
   - Estado lista tipos doc: `TipoDocumentoListLoaded`
   - Propiedad: `state.tipos`
   - Evento: `ListarTiposDocumentoEvent()`

   **USAR NOMBRES EXACTOS** (NO inventar, NO asumir)

🎯 IMPLEMENTAR:
[... resto del prompt ...]
```
```

#### Ubicación en Archivo
- **Archivo**: `.claude/agents/web-architect-expert.md`
- **Línea**: Después de línea 205 (reemplazar sección "6. Lanzar UI")
- **Acción**: Edit

---

### 2. @flutter-expert

#### Problema Actual
- Documenta funcionalidad PERO no documenta contrato para otros agentes
- No especifica nombres exactos de estados/propiedades

#### Mejora Propuesta

**AGREGAR después de línea 287** (Sección 7 - Documentar en HU):

```markdown
### 7. Documentar en HU - CONTRATO PARA AGENTES FUTUROS

**ADEMÁS de tu sección técnica, AGREGA subsección de contrato**:

```markdown
#### 📋 Contrato API para Agentes Futuros (ux-ui-expert, otros features)

**NOMBRES EXACTOS DE CLASES** (NO asumir, copiar de código):

**Estados del Bloc**:
- Inicial: `[Modulo]Initial`
- Cargando: `[Modulo]Loading`
- Lista cargada: `[Modulo]ListLoaded` ← ⚠️ Nombre exacto (NOT ListSuccess)
  - Propiedad: `state.[items]` ← ⚠️ Nombre exacto (NOT state.[Items])
- Operación exitosa: `[Modulo]OperationSuccess`
- Error: `[Modulo]Error`
  - Propiedad: `state.message`

**Eventos del Bloc**:
- Listar: `Listar[Modulos]Event()`
- Crear: `Crear[Modulo]Event(params...)`
- Actualizar: `Actualizar[Modulo]Event(params...)`

**Ejemplo de uso en otros features**:
```dart
// ✅ CORRECTO - Nombres exactos
BlocBuilder<[Modulo]Bloc, [Modulo]State>(
  builder: (context, state) {
    if (state is [Modulo]ListLoaded) {  // ← Nombre exacto línea XX
      final items = state.[items];       // ← Propiedad exacta línea YY
      return ListView.builder(...);
    }
  }
)

// ❌ INCORRECTO - Nombres asumidos
if (state is [Modulo]ListSuccess) { ... }     // Estado no existe
final items = state.[Items];                   // Propiedad no existe
```

**Enums y Métodos Especiales** (si aplica):
- Enum `[NombreEnum]`: valores `[valor1, valor2]`
  - Métodos: `.toBackendString()` → devuelve `'VALOR_BACKEND'`
  - Métodos: `.fromString(String)` → parsea desde backend

**Ejemplo**:
```dart
// Uso del enum en UI
final formato = TipoDocumentoFormato.numerico;
final backendValue = formato.toBackendString(); // 'NUMERICO'
```
```
```

#### Ubicación en Archivo
- **Archivo**: `.claude/agents/flutter-expert.md`
- **Línea**: Después de línea 287 (dentro de sección 7 - Documentar)
- **Acción**: Edit

---

### 3. @ux-ui-expert

#### Problema Actual
- Sección "1. Leer HU" NO especifica leer código de features dependientes
- Línea 496 menciona "leer Backend/Frontend" pero NO es suficiente específico

#### Mejora Propuesta

**REEMPLAZAR líneas 496-520** (Sección "Lectura Obligatoria"):

```markdown
### 1. Lectura Obligatoria de Dependencias - PROTOCOLO MEJORADO

**ORDEN OBLIGATORIO DE LECTURA** (ANTES de escribir código):

```bash
# PASO 1: Leer HU completa
Read(docs/historias-usuario/E00X-HU-XXX.md)

# PASO 2: Identificar dependencias de features anteriores
# Buscar en HU menciones a:
# - "Usa TipoDocumentoBloc de HU-001"
# - "Integra con ColorBloc"
# - "Selecciona de catálogo existente"

# PASO 3: POR CADA DEPENDENCIA IDENTIFICADA, leer PRIMERO:

# Ejemplo: Si HU menciona usar TipoDocumentoBloc:
Read(lib/features/tipos_documento/presentation/bloc/tipo_documento_state.dart)
Read(lib/features/tipos_documento/presentation/bloc/tipo_documento_event.dart)
Read(lib/features/tipos_documento/domain/entities/tipo_documento_entity.dart)

# PASO 4: ANOTAR nombres EXACTOS (crear checklist):
# ✅ Estado lista: TipoDocumentoListLoaded (línea 15 del archivo)
# ✅ Propiedad: state.tipos (línea 16 del archivo)
# ✅ Evento: ListarTiposDocumentoEvent() (línea XX del event.dart)

# PASO 5: Leer sección "Contrato API para Agentes Futuros" si existe
# (Esta sección la crea @flutter-expert en su documentación)

# PASO 6: RECIÉN AHORA implementar páginas
```

**⚠️ REGLA CRÍTICA - NO ASUMIR NUNCA**:

```dart
// ❌ MAL - Asumir nombres sin leer código
if (state is TipoDocumentoListSuccess) { ... }  // ¿De dónde sacaste "ListSuccess"?
final tipos = state.tiposDocumento;             // ¿De dónde sacaste "tiposDocumento"?

// ✅ BIEN - Copiar nombres EXACTOS del código leído
if (state is TipoDocumentoListLoaded) { ... }   // ✅ Leído de tipo_documento_state.dart:15
final tipos = state.tipos;                       // ✅ Leído de tipo_documento_state.dart:16
```

**CHECKLIST PRE-IMPLEMENTACIÓN** (completar ANTES de codificar):

```markdown
## Dependencias Verificadas

- [ ] Leí archivos de states de features dependientes
- [ ] Anoté nombres EXACTOS de estados (con número de línea)
- [ ] Anoté nombres EXACTOS de propiedades (con número de línea)
- [ ] Anoté nombres EXACTOS de eventos
- [ ] Verifiqué enums y métodos especiales (ej: .toBackendString())
- [ ] Confirmo que NO estoy asumiendo nombres

**Nombres verificados**:
- Estado lista [Feature1]: `[NombreExacto]` (línea XX)
- Propiedad: `state.[propiedad]` (línea YY)
- Evento: `[EventoExacto]()` (línea ZZ)
```

**PROTOCOLO DE VERIFICACIÓN**:

Si tu página usa Bloc de OTRA feature:
1. ❌ NO escribas código aún
2. ✅ Lee PRIMERO los archivos _state.dart y _event.dart
3. ✅ Anota nombres con número de línea
4. ✅ Copia EXACTO en tu código
5. ✅ Compila (`flutter analyze`) ANTES de reportar completado
```

#### Ubicación en Archivo
- **Archivo**: `.claude/agents/ux-ui-expert.md`
- **Líneas**: Reemplazar 496-520 (toda la sección "1. Lectura Obligatoria")
- **Acción**: Edit

---

## 📊 RESUMEN DE CAMBIOS

| Agente | Archivo | Líneas | Cambio | Impacto |
|--------|---------|--------|--------|---------|
| **@web-architect-expert** | `.claude/agents/web-architect-expert.md` | ~205 | Agregar identificación de dependencias + prompt mejorado | ⭐⭐⭐ CRÍTICO |
| **@flutter-expert** | `.claude/agents/flutter-expert.md` | ~287 | Agregar subsección "Contrato para Agentes Futuros" | ⭐⭐ IMPORTANTE |
| **@ux-ui-expert** | `.claude/agents/ux-ui-expert.md` | 496-520 | Reemplazar protocolo de lectura con checklist | ⭐⭐⭐ CRÍTICO |

---

## ✅ VALIDACIÓN DE MEJORAS

### Escenario de Prueba

**Simular HU-003 que use TipoDocumentoBloc**:

1. @web-architect-expert lanza @ux-ui-expert con prompt mejorado
2. Prompt especifica archivos EXACTOS a leer
3. @ux-ui-expert lee `tipo_documento_state.dart` ANTES de codificar
4. @ux-ui-expert anota: `TipoDocumentoListLoaded`, `state.tipos`
5. @ux-ui-expert usa nombres EXACTOS en código
6. `flutter analyze` → 0 errores ✅

### Resultado Esperado

- ✅ 0 errores de compilación
- ✅ Nombres correctos desde primer intento
- ✅ No se pierde tiempo corrigiendo errores evitables

---

## 🎯 PRÓXIMOS PASOS

1. **Aplicar cambios a prompts** (usar Edit tool)
2. **Probar en HU-003** (siguiente implementación)
3. **Monitorear**: Si vuelve a ocurrir error similar → reforzar más

---

**Versión**: 1.0
**Última actualización**: 2025-10-16
**Aplicar cambios**: AHORA (antes de próxima HU)
