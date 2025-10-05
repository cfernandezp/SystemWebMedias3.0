# Índice de Documentación Técnica - Sistema Venta Medias

**Última actualización**: [Fecha] por @web-architect-expert

## 📚 Estructura de Documentación

### Backend (Supabase Local)
- [Schema de Base de Datos](backend/schema.md) - Diseño de tablas PostgreSQL
- [APIs y Endpoints](backend/apis.md) - REST API + Edge Functions
- [Configuración Supabase](backend/supabase-config.md) - Setup local

### Frontend (Flutter Web)
- [Modelos de Datos](frontend/models.md) - Clases Dart + mapping
- [Arquitectura](frontend/architecture.md) - Clean Architecture + Bloc
- [Configuración Flutter](frontend/flutter-config.md) - Setup web

### Design System
- [Design Tokens](design/tokens.md) - Colores, spacing, typography
- [Componentes UI](design/components.md) - Atoms, Molecules, Organisms

### Integración
- [Mapping Backend ↔ Frontend](integration/mapping.md) - Tabla de correspondencia
- [Contratos de API](integration/contracts.md) - Request/Response schemas

---

## 🔍 Por Historia de Usuario

### HU-001: [Título]
**Estado**: [🎨 Diseño / 🔨 Implementación / ✅ Completado]

- Backend: [Schema](backend/schema.md#hu-001) | [API](backend/apis.md#hu-001)
- Frontend: [Model](frontend/models.md#hu-001) | [Screen](frontend/architecture.md#hu-001)
- Design: [Components](design/components.md#hu-001)
- Mapping: [Tabla](integration/mapping.md#hu-001)

**Agentes:**
- 🎨 @web-architect-expert → Diseñó especificaciones
- 🔨 @supabase-expert → Implementó backend
- 🔨 @flutter-expert → Implementó frontend
- 🔨 @ux-ui-expert → Implementó UI

---

## 🔄 Flujo de Actualización

1. **@web-architect-expert**: Crea estructura inicial con diseño
2. **@supabase-expert**: Implementa y actualiza `backend/`
3. **@flutter-expert**: Implementa y actualiza `frontend/`
4. **@ux-ui-expert**: Implementa y actualiza `design/`
5. **Todos**: Validan `integration/mapping.md`

---

## 📝 Convenciones

- **Backend**: snake_case (product_id, created_at)
- **Frontend**: camelCase (productId, createdAt)
- **Componentes**: PascalCase (ProductCard, PrimaryButton)
- **Archivos**: snake_case (product_card.dart, user_model.dart)
