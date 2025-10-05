# Schema de Base de Datos

**Stack**: Supabase Local (PostgreSQL)
**Última actualización**: 2025-10-05 por @web-architect-expert

---

## 🔐 Módulo: Autenticación y Autorización

### Función: confirm_email()
**HU relacionada**: HU-001
**Reglas de negocio**: RN-003, RN-004, RN-005
**Migración**: `supabase/migrations/20251004170000_hu001_database_functions.sql`
**Estado**: ✅ Implementado
**Cambio CP-001**: ✅ Aplicado (2025-10-05)

**DISEÑADO POR**: @web-architect-expert (2025-10-04)
**IMPLEMENTADO POR**: @supabase-expert (2025-10-04)
**MODIFICADO POR**: @web-architect-expert (2025-10-05) - CP-001

#### Descripción:
Función que confirma el email de un usuario registrado mediante un token de verificación enviado por correo.

#### Cambio CP-001 (Auto-aprobación):
**Fecha**: 2025-10-05
**Motivo**: Simplificar el flujo inicial del sistema, eliminando la aprobación manual del administrador.

**Cambio realizado**:
```sql
-- Antes:
UPDATE users
SET
    email_verificado = true,
    token_confirmacion = NULL,
    token_expiracion = NULL
WHERE id = v_user.id;

-- Después (CP-001):
UPDATE users
SET
    email_verificado = true,
    estado = 'APROBADO',  -- Auto-aprobar usuario tras verificar email
    token_confirmacion = NULL,
    token_expiracion = NULL
WHERE id = v_user.id;
```

**Impacto**:
- Los usuarios pasan automáticamente de `REGISTRADO` a `APROBADO` al confirmar su email
- Pueden hacer login inmediatamente después de verificar su email
- Los estados `RECHAZADO` y `SUSPENDIDO` se mantienen en la estructura para uso futuro
- El mensaje de respuesta cambió de "Tu cuenta está esperando aprobación del administrador" a "Tu cuenta ha sido aprobada. Ya puedes iniciar sesión en el sistema."

#### Comportamiento:
1. Valida que el token no esté vacío
2. Busca el usuario por token de confirmación
3. Verifica que el email no esté ya verificado
4. Verifica que el token no haya expirado (24 horas)
5. **Actualiza `email_verificado = true` y `estado = 'APROBADO'`** (CP-001)
6. Limpia el token usado
7. Retorna mensaje de éxito con instrucción para hacer login

---

## 📋 Convenciones

- **Nomenclatura**: snake_case (user_id, created_at)
- **Primary Keys**: UUID con default uuid_generate_v4()
- **Timestamps**: TIMESTAMP WITH TIME ZONE con default NOW()
- **Auditoría**: created_at, updated_at en todas las tablas

---

## 🔐 Módulo: [Nombre del Módulo]

### Tabla: [nombre_tabla]
**HU relacionada**: [HU-XXX]
**Reglas de negocio**: [RN-XXX, RN-YYY]
**Migración**: `supabase/migrations/[timestamp]_[nombre].sql`
**Estado**: [🎨 Diseño / ✅ Implementado]

**DISEÑADO POR**: @web-architect-expert ([Fecha])
**IMPLEMENTADO POR**: @supabase-expert ([Fecha])

#### Diseño Propuesto:
```sql
CREATE TABLE [nombre_tabla] (
    [campo_id] UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    [campo_nombre] TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_[tabla]_[campo] ON [tabla]([campo]);

-- Constraints
ALTER TABLE [tabla] ADD CONSTRAINT [nombre_constraint] CHECK ([condicion]);

-- RLS Policies
ALTER TABLE [tabla] ENABLE ROW LEVEL SECURITY;
```

#### SQL Final Implementado:
```sql
-- [Código SQL real aplicado por @supabase-expert]
```

#### Cambios vs Diseño Inicial:
- ✅ [Cambio 1]: [Descripción]
- ✅ [Cambio 2]: [Descripción]

#### Campos:
| Campo | Tipo | Descripción | Mapea a Dart |
|-------|------|-------------|--------------|
| `campo_id` | UUID | Primary Key | `campoId` |
| `campo_nombre` | TEXT | Descripción | `campoNombre` |

---

## 📝 Plantilla para Nueva Tabla

Copia esta plantilla cuando agregues una nueva tabla:

```markdown
### Tabla: nueva_tabla
**HU relacionada**: HU-XXX
**Reglas de negocio**: RN-XXX
**Migración**: `supabase/migrations/YYYYMMDD_create_nueva_tabla.sql`
**Estado**: 🎨 Diseño

**DISEÑADO POR**: @web-architect-expert (YYYY-MM-DD)

```sql
CREATE TABLE nueva_tabla (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    -- campos aquí
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```
```
