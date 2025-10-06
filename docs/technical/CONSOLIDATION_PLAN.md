# Plan de Consolidación de Documentación Técnica

**Objetivo**: Reducir consumo de tokens consolidando archivos por módulo funcional en lugar de por HU.

## Estrategia de Consolidación

### 1. Backend - Por Módulo Funcional

**ANTES** (archivos separados por HU):
```
backend/
├── schema_E001-HU-001.md (Auth - Login)
├── schema_E001-HU-003.md (Auth - Logout)
├── schema_E003-HU-001.md (Dashboard)
├── schema_E003-HU-002.md (Navigation)
├── apis_E001-HU-001.md
├── apis_E001-HU-002.md
├── apis_E001-HU-003.md
├── apis_E003-HU-001.md
└── apis_E003-HU-002.md
```

**DESPUÉS** (consolidado por módulo):
```
backend/
├── schema_auth.md          # Todas las HU de autenticación (HU-001, HU-002, HU-003)
├── schema_dashboard.md     # Todas las HU de dashboard (HU-001)
├── schema_navigation.md    # Todas las HU de navegación (HU-002)
├── apis_auth.md            # Todas las APIs de auth
├── apis_dashboard.md       # Todas las APIs de dashboard
└── apis_navigation.md      # Todas las APIs de navegación
```

### 2. Frontend - Por Módulo Funcional

**ANTES**:
```
frontend/
├── models_E001-HU-001.md
├── models_E001-HU-002.md
├── models_E001-HU-003.md
├── models_E003-HU-001.md
└── models_E003-HU-002.md
```

**DESPUÉS**:
```
frontend/
├── models_auth.md         # Todos los modelos de auth
├── models_dashboard.md    # Todos los modelos de dashboard
└── models_navigation.md   # Todos los modelos de navegación
```

### 3. Design - Por Módulo Funcional

**ANTES**:
```
design/
├── components_E001-HU-001.md
├── components_E001-HU-002.md
├── components_E001-HU-003.md
├── components_E003-HU-001.md
└── components_E003-HU-002.md
```

**DESPUÉS**:
```
design/
├── components_auth.md        # Todos los componentes de auth
├── components_dashboard.md   # Todos los componentes de dashboard
└── components_navigation.md  # Todos los componentes de navegación
```

### 4. Integration - Por Módulo Funcional

**ANTES**:
```
integration/
├── mapping_E001-HU-001.md
├── mapping_E001-HU-002.md
├── mapping_E001-HU-003.md
├── mapping_E003-HU-001.md
└── mapping_E003-HU-002.md
```

**DESPUÉS**:
```
integration/
├── mapping_auth.md        # Todos los mappings de auth
├── mapping_dashboard.md   # Todos los mappings de dashboard
└── mapping_navigation.md  # Todos los mappings de navegación
```

## Formato de Archivo Consolidado

Cada archivo consolidado usa secciones con anclas para búsqueda rápida:

```markdown
# Schema Auth Module

## HU-001: Login {#hu-001}

### Tabla: users
CREATE TABLE users (...);

### Función: login_user()
...

## HU-002: Registro {#hu-002}

### Función: register_user()
...

## HU-003: Logout Seguro {#hu-003}

### Tabla: token_blacklist
CREATE TABLE token_blacklist (...);
```

## Búsqueda Optimizada

Los agentes usan Grep para encontrar secciones específicas:

```bash
# Buscar HU específica:
Grep(pattern="## HU-003", path="docs/technical/backend/schema_auth.md")

# Buscar tabla específica:
Grep(pattern="### Tabla: token_blacklist", path="docs/technical/backend/schema_auth.md")
```

## Módulos Funcionales Identificados

1. **auth** - Autenticación y autorización (HU-001, HU-002, HU-003)
2. **dashboard** - Dashboard y métricas (HU-001)
3. **navigation** - Navegación y menús (HU-002)
4. **layout** - Layout responsivo (HU-003)
5. **products** - Productos (futuras HU)
6. **sales** - Ventas (futuras HU)
7. **inventory** - Inventario (futuras HU)

## Beneficios

1. **Reducción de tokens**: ~60-70% menos lecturas de archivos
2. **Menos archivos**: De ~50 archivos a ~20 archivos
3. **Búsqueda más rápida**: Grep en archivos consolidados
4. **Mantenimiento más fácil**: Un solo archivo por módulo
5. **Mismo flujo de trabajo**: Los agentes siguen funcionando igual

## Migración

**NO ES NECESARIO** consolidar todo ahora. Nuevas HU usan estructura consolidada, archivos viejos permanecen hasta refactor futuro.

**Para nuevas HU**: Arquitecto crea/actualiza archivos consolidados directamente.
