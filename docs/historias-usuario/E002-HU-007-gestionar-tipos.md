# E002-HU-007: Gestionar Catálogo de Tipos

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E002-HU-007
- **Épica**: E002 - Gestión de Productos de Medias
- **Título**: Gestionar Catálogo de Tipos
- **Story Points**: 4 pts
- **Estado**: ⚪ Pendiente

## 🎯 HISTORIA DE USUARIO
**Como** administrador del sistema de medias
**Quiero** gestionar el catálogo de tipos de medias con códigos únicos y descripciones
**Para** clasificar productos por su diseño y altura, y generar SKUs consistentes

## ✅ CRITERIOS DE ACEPTACIÓN

### CA-001: Visualizar Lista de Tipos
- [ ] **DADO** que soy admin autenticado
- [ ] **CUANDO** accedo a la sección "Catálogos > Tipos"
- [ ] **ENTONCES** debo ver:
  - [ ] Lista de tipos con: nombre, descripción, código, estado (activo/inactivo)
  - [ ] Botón "Agregar Nuevo Tipo"
  - [ ] Botones de acciones: Editar, Activar/Desactivar
  - [ ] Contador total de tipos activos/inactivos
  - [ ] Buscador por nombre, descripción o código

### CA-002: Agregar Nuevo Tipo
- [ ] **DADO** que quiero agregar un tipo de media
- [ ] **CUANDO** presiono "Agregar Nuevo Tipo"
- [ ] **ENTONCES** debo ver formulario con:
  - [ ] Campo "Nombre" (obligatorio, máx 50 caracteres)
  - [ ] Campo "Descripción" (opcional, máx 200 caracteres)
  - [ ] Campo "Código" (obligatorio, 3 caracteres, solo letras mayúsculas)
  - [ ] Checkbox "Activo" (marcado por defecto)
  - [ ] Botones "Guardar" y "Cancelar"

### CA-003: Validaciones de Nuevo Tipo
- [ ] **DADO** que estoy creando un tipo
- [ ] **CUANDO** dejo el nombre vacío
- [ ] **ENTONCES** debo ver "Nombre es requerido"
- [ ] **CUANDO** dejo el código vacío
- [ ] **ENTONCES** debo ver "Código es requerido"
- [ ] **CUANDO** ingreso código con menos de 3 caracteres
- [ ] **ENTONCES** debo ver "Código debe tener exactamente 3 letras"
- [ ] **CUANDO** ingreso código con números o símbolos
- [ ] **ENTONCES** debo ver "Código solo puede contener letras mayúsculas"
- [ ] **CUANDO** ingreso código ya existente
- [ ] **ENTONCES** debo ver "Este código ya existe, ingresa otro"
- [ ] **CUANDO** ingreso descripción de más de 200 caracteres
- [ ] **ENTONCES** debo ver "Descripción máximo 200 caracteres"

### CA-004: Crear Tipo Exitosamente
- [ ] **DADO** que completo el formulario correctamente
- [ ] **CUANDO** presiono "Guardar"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Crear el tipo en la base de datos
  - [ ] Mostrar mensaje "Tipo creado exitosamente"
  - [ ] Volver a la lista de tipos
  - [ ] Mostrar el nuevo tipo en la lista

### CA-005: Editar Tipo Existente
- [ ] **DADO** que quiero modificar un tipo
- [ ] **CUANDO** presiono "Editar" en un tipo
- [ ] **ENTONCES** debo ver:
  - [ ] Formulario prellenado con datos actuales
  - [ ] Campo código deshabilitado (no se puede cambiar)
  - [ ] Posibilidad de cambiar nombre, descripción y estado
  - [ ] Botones "Actualizar" y "Cancelar"

### CA-006: Validación de Edición
- [ ] **DADO** que estoy editando un tipo
- [ ] **CUANDO** dejo el nombre vacío
- [ ] **ENTONCES** debo ver "Nombre es requerido"
- [ ] **CUANDO** ingreso nombre que ya existe en otro tipo
- [ ] **ENTONCES** debo ver "Ya existe un tipo con este nombre"
- [ ] **CUANDO** ingreso descripción de más de 200 caracteres
- [ ] **ENTONCES** debo ver "Descripción máximo 200 caracteres"

### CA-007: Actualizar Tipo Exitosamente
- [ ] **DADO** que modifico un tipo correctamente
- [ ] **CUANDO** presiono "Actualizar"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Actualizar los datos en la base de datos
  - [ ] Mostrar mensaje "Tipo actualizado exitosamente"
  - [ ] Volver a la lista con datos actualizados

### CA-008: Desactivar Tipo
- [ ] **DADO** que quiero desactivar un tipo
- [ ] **CUANDO** presiono "Desactivar" en un tipo activo
- [ ] **ENTONCES** debo ver:
  - [ ] Modal de confirmación "¿Estás seguro de desactivar este tipo?"
  - [ ] Advertencia "Los productos existentes no se verán afectados"
  - [ ] Información de productos asociados si los hay
  - [ ] Botones "Confirmar" y "Cancelar"

### CA-009: Confirmar Desactivación
- [ ] **DADO** que confirmo la desactivación
- [ ] **CUANDO** presiono "Confirmar"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Marcar el tipo como inactivo (no eliminar)
  - [ ] Mostrar mensaje "Tipo desactivado exitosamente"
  - [ ] Actualizar la lista mostrando estado inactivo
  - [ ] El tipo no aparece en selecciones para nuevos productos

### CA-010: Reactivar Tipo
- [ ] **DADO** que quiero reactivar un tipo inactivo
- [ ] **CUANDO** presiono "Activar" en un tipo inactivo
- [ ] **ENTONCES** el sistema debe:
  - [ ] Marcar el tipo como activo
  - [ ] Mostrar mensaje "Tipo reactivado exitosamente"
  - [ ] El tipo vuelve a estar disponible para nuevos productos

### CA-011: Búsqueda de Tipos
- [ ] **DADO** que quiero buscar un tipo específico
- [ ] **CUANDO** escribo en el campo de búsqueda
- [ ] **ENTONCES** debo ver:
  - [ ] Filtrado en tiempo real por nombre, descripción o código
  - [ ] Resultados actualizados al escribir
  - [ ] Mensaje "No se encontraron tipos" si no hay coincidencias
  - [ ] Opción de limpiar búsqueda

### CA-012: Vista Detallada de Tipo
- [ ] **DADO** que quiero ver detalles de un tipo
- [ ] **CUANDO** hago clic en el nombre del tipo
- [ ] **ENTONCES** debo ver:
  - [ ] Modal con información completa del tipo
  - [ ] Lista de productos que usan este tipo
  - [ ] Fecha de creación y última modificación
  - [ ] Estadísticas de uso (cantidad de productos)
  - [ ] Imagen de referencia del tipo (si está disponible)

### CA-013: Validación de Combinaciones Lógicas
- [ ] **DADO** que un tipo tiene restricciones de uso
- [ ] **CUANDO** se intenta crear producto con combinación inválida
- [ ] **ENTONCES** el sistema debe:
  - [ ] Mostrar warning de combinación poco común
  - [ ] Permitir continuar pero con confirmación
  - [ ] Registrar combinaciones para futuras validaciones

## 📋 ESTADOS DE IMPLEMENTACIÓN

### Backend (Supabase)
- [ ] **PENDIENTE** - Tabla `tipos`:
  - [ ] id (UUID, PRIMARY KEY)
  - [ ] nombre (TEXT, NOT NULL, UNIQUE)
  - [ ] descripcion (TEXT, NULLABLE)
  - [ ] codigo (TEXT, NOT NULL, UNIQUE, LENGTH=3)
  - [ ] imagen_url (TEXT, NULLABLE)
  - [ ] activo (BOOLEAN, DEFAULT true)
  - [ ] created_at (TIMESTAMP)
  - [ ] updated_at (TIMESTAMP)

- [ ] **PENDIENTE** - Edge Function `catalogos/tipos`:
  - [ ] GET /tipos - Listar todos los tipos
  - [ ] POST /tipos - Crear nuevo tipo
  - [ ] PUT /tipos/:id - Actualizar tipo
  - [ ] PATCH /tipos/:id/toggle - Activar/desactivar tipo
  - [ ] GET /tipos/:id/productos - Productos que usan el tipo

- [ ] **PENDIENTE** - Validaciones backend:
  - [ ] Código único, 3 letras mayúsculas
  - [ ] Nombre único, máximo 50 caracteres
  - [ ] Descripción máximo 200 caracteres
  - [ ] Solo admin puede gestionar tipos

### Frontend (Flutter)
- [ ] **PENDIENTE** - TiposListPage:
  - [ ] Lista de tipos con estado visual
  - [ ] Buscador con filtrado en tiempo real
  - [ ] Botones de acción por tipo
  - [ ] Vista detallada en modal con imagen

- [ ] **PENDIENTE** - TipoFormPage:
  - [ ] Formulario crear/editar tipo
  - [ ] Validaciones en tiempo real
  - [ ] Campo descripción opcional
  - [ ] Upload de imagen de referencia
  - [ ] Manejo de estados (loading, success, error)

- [ ] **PENDIENTE** - TiposBloc:
  - [ ] Estados para gestión de tipos
  - [ ] Eventos CRUD completos
  - [ ] Cache local de tipos activos

### UX/UI
- [ ] **PENDIENTE** - Tipos Components:
  - [ ] TipoCard con imagen y descripción
  - [ ] TipoForm responsive con upload de imagen
  - [ ] Estados visuales (activo/inactivo)
  - [ ] Modal de detalles con estadísticas
  - [ ] Galería de imágenes de referencia

### QA
- [ ] **PENDIENTE** - Tests todos los criterios:
  - [ ] CRUD completo de tipos
  - [ ] Validaciones de nombre, código y descripción
  - [ ] Upload y visualización de imágenes
  - [ ] Búsqueda y filtrado avanzado
  - [ ] Activar/desactivar tipos
  - [ ] Vista detallada y estadísticas

## ✅ DEFINICIÓN DE TERMINADO (DoD)
- [ ] Todos los criterios de aceptación cumplidos
- [ ] CRUD completo de tipos implementado
- [ ] Validaciones frontend y backend funcionando
- [ ] Solo admin puede gestionar catálogo
- [ ] Códigos únicos de 3 letras generados correctamente
- [ ] Campo descripción e imagen opcionales
- [ ] Búsqueda por múltiples campos
- [ ] Vista detallada con estadísticas de uso
- [ ] Upload de imágenes de referencia
- [ ] QA valida todos los flujos
- [ ] Documentación actualizada

## 🔗 DEPENDENCIAS
- **E002-HU-005**: Gestionar Catálogo de Marcas (patrón establecido)
- **E002-HU-006**: Gestionar Catálogo de Materiales (patrón establecido)

## 👟 EJEMPLOS DE TIPOS DEL SECTOR
```
Nombre: "Invisible"        → Código: "INV" → Descripción: "Media muy baja, no visible con zapatos"
Nombre: "Tobillera"        → Código: "TOB" → Descripción: "Media que llega al tobillo"
Nombre: "Media Caña"       → Código: "MCA" → Descripción: "Media que llega a media pantorrilla"
Nombre: "Larga"            → Código: "LAR" → Descripción: "Media que llega a la rodilla"
Nombre: "Fútbol"           → Código: "FUT" → Descripción: "Media deportiva alta para fútbol"
Nombre: "Running"          → Código: "RUN" → Descripción: "Media deportiva para correr"
Nombre: "Compresión"       → Código: "COM" → Descripción: "Media con compresión gradual"
Nombre: "Ejecutiva"        → Código: "EJE" → Descripción: "Media formal para uso ejecutivo"
Nombre: "Térmica"          → Código: "TER" → Descripción: "Media para climas fríos"
```

## 🎨 ESPECIFICACIONES VISUALES
- **Imágenes de referencia**: JPG/PNG, máximo 500KB
- **Dimensiones**: 300x300px recomendadas
- **Contenido**: Silueta o foto representativa del tipo
- **Storage**: Supabase Storage con URLs públicas

## 🔐 RESTRICCIONES DE SEGURIDAD
- **Solo ADMIN** puede acceder a gestión de tipos
- **Códigos inmutables** una vez creados (para consistencia de SKU)
- **Soft delete** - nunca eliminar, solo desactivar
- **Auditoría** de cambios en catálogos maestros
- **Validación** de imágenes (formato, tamaño, contenido)