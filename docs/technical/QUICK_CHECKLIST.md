# Quick Checklist - Para TODOS los Agentes

**Antes de implementar CUALQUIER Historia de Usuario**

---

## ✅ CHECKLIST OBLIGATORIO

### 📖 1. LEER ANTES DE CODIFICAR

```
[ ] Leí docs/technical/00-CONVENTIONS.md completo
[ ] Leí docs/technical/SPECS-FOR-AGENTS-HU-XXX.md (mi sección)
[ ] Leí el archivo de diseño específico:
    @supabase-expert   → backend/schema_huXXX.md + apis_huXXX.md
    @flutter-expert    → frontend/models_huXXX.md
    @ux-ui-expert      → design/components_huXXX.md + tokens.md
```

---

### 🔤 2. NAMING CONVENTIONS

```
Backend (PostgreSQL):
[ ] Tablas en snake_case plural (users, sales_details)
[ ] Columnas en snake_case (email, created_at)
[ ] PKs siempre 'id' (UUID)
[ ] FKs formato {tabla}_id (user_id, product_id)
[ ] Timestamps: created_at, updated_at
[ ] ENUM types: snake_case singular
[ ] ENUM values: UPPER_SNAKE_CASE

Frontend (Dart):
[ ] Clases en PascalCase (User, ProductCard)
[ ] Variables en camelCase (userId, createdAt)
[ ] Archivos en snake_case (user_model.dart)
[ ] Mapping explícito snake_case ↔ camelCase en fromJson/toJson
```

---

### 🔀 3. ROUTING (Flutter)

```
[ ] Rutas FLAT sin prefijos (/login, /products)
[ ] NO uso rutas con módulos (/auth/login ❌)
[ ] Navigator.pushNamed() con rutas correctas
[ ] Rutas registradas en main.dart
```

---

### 🔧 4. ERROR HANDLING

```
PostgreSQL:
[ ] Variable local v_error_hint en DECLARE
[ ] Asigno hint ANTES de RAISE EXCEPTION
[ ] Uso COALESCE(v_error_hint, 'unknown') en EXCEPTION

Dart:
[ ] Excepciones heredan de AppException
[ ] Mapeo hints de PostgreSQL a excepciones específicas
[ ] Try-catch en datasources con rethrow de AppException
```

---

### 📦 5. API RESPONSE FORMAT

```
PostgreSQL Functions:
[ ] Retorno JSON con formato estándar:
    Success: {success: true, data: {...}}
    Error: {success: false, error: {code, message, hint}}
[ ] Uso hints estándar (duplicate_email, invalid_token, etc.)

Flutter:
[ ] Verifico result['success'] == true
[ ] Parseo result['data'] a modelo
[ ] Mapeo result['error']['hint'] a excepciones
```

---

### 🎨 6. DESIGN SYSTEM (UX/UI)

```
[ ] USO Theme.of(context).colorScheme.primary
[ ] NO hardcodeo colores (Color(0xFF...) ❌)
[ ] Uso DesignSpacing.* para spacing
[ ] Uso DesignColors.* si no uso Theme
[ ] Componentes son theme-aware
[ ] Responsive: mobile <768px, desktop ≥1200px
```

---

### 📝 7. DOCUMENTACIÓN

```
[ ] Actualicé sección "Código Final Implementado" en .md
[ ] Documenté cambios vs diseño inicial
[ ] Agregué comentarios con contexto (HU-XXX, RN-XXX)
[ ] Actualicé SPECS si encontré algo no documentado
```

---

### 🧪 8. TESTING

```
@supabase-expert:
[ ] Probé función SQL manualmente en Supabase Studio
[ ] Verifiqué response JSON (success + error cases)

@flutter-expert:
[ ] Escribí unit tests para modelos
[ ] Coverage ≥90% en models

@ux-ui-expert:
[ ] Probé UI en mobile y desktop
[ ] Verifiqué responsive breakpoints
```

---

## 🚨 SI ENCUENTRO ALGO NO DOCUMENTADO

```
1. ⏸️  PAUSAR implementación
2. 📝 Reportar a @web-architect-expert
3. ⏳ ESPERAR actualización de 00-CONVENTIONS.md
4. ✅ Continuar con convención definida
```

---

## 🔍 VALIDACIÓN FINAL

Antes de marcar tarea como completada:

```
[ ] Código compila sin errores
[ ] Sigue TODAS las convenciones de 00-CONVENTIONS.md
[ ] Documentación actualizada
[ ] Tests pasando (si aplica)
[ ] Revisé checklist de SPECS-FOR-AGENTS-HU-XXX.md
```

---

**Versión**: 1.0
**Última actualización**: 2025-10-04
**Referencia completa**: [00-CONVENTIONS.md](00-CONVENTIONS.md)
