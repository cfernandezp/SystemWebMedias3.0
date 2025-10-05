# APIs Backend

**Base URL Local**: `http://localhost:54321`
**Stack**: Supabase Edge Functions
**Última actualización**: [Fecha] por [Agente]

---

## 🔐 Módulo: [Nombre del Módulo]

### [METHOD] /ruta/endpoint
**HU**: [HU-XXX]
**Implementa**: [RN-XXX, RN-YYY]
**Edge Function**: `supabase/functions/[modulo]/[nombre].ts`
**Estado**: [🎨 Diseño / ✅ Implementado]

**DISEÑADO POR**: @web-architect-expert ([Fecha])
**IMPLEMENTADO POR**: @supabase-expert ([Fecha])

#### Request:
```json
{
  "campo_snake_case": "valor",
  "otro_campo": 123
}
```

#### Validaciones Backend:
- ✅ [RN-XXX]: [Descripción de la validación]
- ✅ [RN-YYY]: [Descripción de la validación]

#### Response 200/201 (Success):
```json
{
  "id": "uuid",
  "campo_snake_case": "valor",
  "created_at": "2024-01-15T10:30:00Z"
}
```

#### Response 400 (Bad Request):
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Descripción del error",
  "field": "campo_que_falla"
}
```

#### Response 409 (Conflict):
```json
{
  "error": "DUPLICATE_ENTRY",
  "message": "El recurso ya existe"
}
```

#### Lógica Implementada:
```typescript
// [Código TypeScript real por @supabase-expert]
```

---

## 📝 Plantilla para Nuevo Endpoint

```markdown
### POST /ruta/nueva
**HU**: HU-XXX
**Implementa**: RN-XXX
**Estado**: 🎨 Diseño

**Request:**
```json
{
  "campo": "valor"
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "campo": "valor"
}
```
```
