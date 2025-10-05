# Documentación Técnica - Sistema Venta Medias

Esta es la **fuente única de verdad** para la documentación técnica del proyecto.

## 📂 Estructura

```
docs/technical/
├── 00-INDEX.md              # Índice maestro - EMPIEZA AQUÍ
├── backend/                 # Documentación Backend (Supabase)
│   ├── schema.md           # Schema de Base de Datos
│   └── apis.md             # APIs y Endpoints
├── frontend/               # Documentación Frontend (Flutter)
│   ├── models.md           # Modelos Dart
│   └── architecture.md     # Clean Architecture
├── design/                 # Documentación Design System
│   ├── tokens.md           # Design Tokens (colores, spacing, etc)
│   └── components.md       # Componentes UI (Atomic Design)
└── integration/            # Integración Backend ↔ Frontend
    └── mapping.md          # Tabla de mapping snake_case ↔ camelCase
```

## 🔄 ¿Cómo funciona?

### 1. **Arquitecto diseña** (@web-architect-expert)
Cuando recibe "implementa HU-XXX":
- Lee la HU desde `docs/historias-usuario/`
- Diseña arquitectura completa
- **Crea/actualiza archivos** en `docs/technical/` con especificaciones
- Coordina agentes técnicos

### 2. **Agentes implementan y actualizan**
- **@supabase-expert**: Lee `backend/`, implementa, actualiza con SQL/TS final
- **@flutter-expert**: Lee `frontend/` + `integration/mapping.md`, implementa, actualiza con Dart final
- **@ux-ui-expert**: Lee `design/`, implementa, actualiza con componentes finales

### 3. **Todos validan mapping**
- `integration/mapping.md` es la **tabla de referencia** para nombres exactos
- Backend usa: `snake_case` (product_id, created_at)
- Frontend usa: `camelCase` (productId, createdAt)
- **Garantiza sincronización** backend ↔ frontend

## 📋 Flujo Completo - Ejemplo HU-001

```
1. @web-architect-expert:
   Write(backend/schema.md):      "CREATE TABLE users (user_id UUID...)"
   Write(backend/apis.md):         "POST /auth/register {...}"
   Write(frontend/models.md):      "class UserModel { String userId... }"
   Write(design/components.md):    "class RegisterForm {...}"
   Write(integration/mapping.md):  "user_id ↔ userId"
   Edit(00-INDEX.md):              "HU-001 agregada"

2. Task(@supabase-expert):
   Read(backend/schema.md)
   Implementa SQL
   Edit(backend/schema.md):        "SQL FINAL: CREATE TABLE users..."

3. Task(@flutter-expert):
   Read(frontend/models.md + integration/mapping.md)
   Implementa UserModel
   Edit(frontend/models.md):       "CÓDIGO DART FINAL: class UserModel..."

4. Task(@ux-ui-expert):
   Read(design/components.md)
   Implementa RegisterForm
   Edit(design/components.md):     "CÓDIGO DART FINAL: class RegisterForm..."
```

## ⚠️ IMPORTANTE

### **¿Dónde NO está la doc técnica?**
- ❌ Ya NO usamos un solo `SISTEMA_DOCUMENTACION.md`
- ✅ Ahora usamos estructura modular en `docs/technical/`

### **¿Qué hay en cada archivo?**
- **Diseño inicial**: Especificaciones del arquitecto
- **Código final**: Actualizado por agentes después de implementar
- **Estado**: 🎨 Diseño / ✅ Implementado

### **¿Cómo sé qué leer?**
- Backend developer → `backend/`
- Frontend developer → `frontend/` + `integration/mapping.md`
- UI developer → `design/`
- Ver todo → `00-INDEX.md`

## 🎯 Ventajas de esta estructura

1. ✅ **Separación clara** por capa técnica
2. ✅ **Archivos pequeños** y enfocados
3. ✅ **Fácil de mantener** (cada agente actualiza su área)
4. ✅ **Trabajo en paralelo** sin conflictos
5. ✅ **Trazabilidad** (quién diseñó, quién implementó, cuándo)
6. ✅ **Onboarding rápido** (solo lees lo que necesitas)
7. ✅ **Sincronización garantizada** vía `integration/mapping.md`

---

**Índice completo**: Ver [00-INDEX.md](00-INDEX.md)
