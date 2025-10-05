# Mapping Backend ↔ Frontend

**Propósito**: Garantizar consistencia entre snake_case (BD) y camelCase (Dart)
**Última actualización**: [Fecha] por @web-architect-expert

---

## 📋 Convenciones de Mapping

- **Backend (PostgreSQL)**: snake_case → `user_id`, `created_at`, `is_active`
- **Frontend (Dart)**: camelCase → `userId`, `createdAt`, `isActive`
- **Tipos SQL → Dart**:
  - UUID → String
  - TEXT → String
  - INTEGER → int
  - DECIMAL → double
  - BOOLEAN → bool
  - TIMESTAMP → DateTime

---

## 🔐 Módulo: [Nombre del Módulo]

### Tabla: [tabla_bd] ↔ [ModelName]

**HU**: [HU-XXX]
**Backend**: `[tabla_bd]` (snake_case)
**Frontend**: `[ModelName]` (camelCase)

| Backend (snake_case) | SQL Type | Frontend (camelCase) | Dart Type | Notas |
|---------------------|----------|---------------------|-----------|-------|
| `campo_id` | UUID | `campoId` | String | Primary Key |
| `campo_nombre` | TEXT | `campoNombre` | String | - |
| `campo_activo` | BOOLEAN | `campoActivo` | bool | Default true |
| `created_at` | TIMESTAMP | `createdAt` | DateTime | Auto-generado |

#### Ejemplo de Transformación:

**Backend Response (snake_case):**
```json
{
  "campo_id": "abc-123",
  "campo_nombre": "Ejemplo",
  "campo_activo": true,
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Frontend Model (camelCase):**
```dart
ModelName(
  campoId: "abc-123",
  campoNombre: "Ejemplo",
  campoActivo: true,
  createdAt: DateTime(2024, 1, 15, 10, 30),
)
```

#### Mapping en fromJson:
```dart
factory ModelName.fromJson(Map<String, dynamic> json) => ModelName(
  campoId: json['campo_id'] as String,        // ← snake_case input
  campoNombre: json['campo_nombre'] as String,
  campoActivo: json['campo_activo'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);
```

#### Mapping en toJson:
```dart
Map<String, dynamic> toJson() => {
  'campo_id': campoId,              // ← snake_case output
  'campo_nombre': campoNombre,
  'campo_activo': campoActivo,
  'created_at': createdAt.toIso8601String(),
};
```

---

## ⚠️ IMPORTANTE

**TODOS los agentes deben validar este archivo:**
- @supabase-expert: Verifica nombres de campos BD (snake_case)
- @flutter-expert: Verifica nombres de propiedades Dart (camelCase)
- @web-architect-expert: Mantiene tabla actualizada

**Cualquier cambio en BD DEBE reflejarse aquí PRIMERO.**

---

## 📝 Plantilla para Nuevo Mapping

```markdown
### Tabla: nueva_tabla ↔ NuevoModel

| Backend (snake_case) | SQL Type | Frontend (camelCase) | Dart Type | Notas |
|---------------------|----------|---------------------|-----------|-------|
| `id` | UUID | `id` | String | PK |
| `nombre` | TEXT | `nombre` | String | - |
```
