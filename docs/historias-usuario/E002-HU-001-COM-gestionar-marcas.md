# E002-HU-005: Gestionar Catálogo de Marcas

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E002-HU-001
- **Épica**: E002 - Gestión de Productos de Medias
- **Título**: Gestionar Catálogo de Marcas
- **Story Points**: 4 pts
- **Estado**: ✅ COMPLETADA
- **Fecha Completación**: 2025-10-07

## 🎯 HISTORIA DE USUARIO
**Como** administrador del sistema de medias
**Quiero** gestionar el catálogo de marcas con códigos únicos
**Para** crear productos con marcas estandarizadas y generar SKUs consistentes

## ✅ CRITERIOS DE ACEPTACIÓN

### CA-001: Visualizar Lista de Marcas
- [ ] **DADO** que soy admin autenticado
- [ ] **CUANDO** accedo a la sección "Catálogos > Marcas"
- [ ] **ENTONCES** debo ver:
  - [ ] Lista de marcas existentes con: nombre, código, estado (activo/inactivo)
  - [ ] Botón "Agregar Nueva Marca"
  - [ ] Botones de acciones por marca: Editar, Activar/Desactivar
  - [ ] Contador total de marcas activas/inactivas
  - [ ] Buscador por nombre o código

### CA-002: Agregar Nueva Marca
- [ ] **DADO** que quiero agregar una marca
- [ ] **CUANDO** presiono "Agregar Nueva Marca"
- [ ] **ENTONCES** debo ver formulario con:
  - [ ] Campo "Nombre" (obligatorio, máx 50 caracteres)
  - [ ] Campo "Código" (obligatorio, 3 caracteres, solo letras mayúsculas)
  - [ ] Checkbox "Activo" (marcado por defecto)
  - [ ] Botones "Guardar" y "Cancelar"

### CA-003: Validaciones de Nueva Marca
- [ ] **DADO** que estoy creando una marca
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

### CA-004: Crear Marca Exitosamente
- [ ] **DADO** que completo el formulario correctamente
- [ ] **CUANDO** presiono "Guardar"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Crear la marca en la base de datos
  - [ ] Mostrar mensaje "Marca creada exitosamente"
  - [ ] Volver a la lista de marcas
  - [ ] Mostrar la nueva marca en la lista

### CA-005: Editar Marca Existente
- [ ] **DADO** que quiero modificar una marca
- [ ] **CUANDO** presiono "Editar" en una marca
- [ ] **ENTONCES** debo ver:
  - [ ] Formulario prellenado con datos actuales
  - [ ] Campo código deshabilitado (no se puede cambiar)
  - [ ] Posibilidad de cambiar nombre y estado
  - [ ] Botones "Actualizar" y "Cancelar"

### CA-006: Validación de Edición
- [ ] **DADO** que estoy editando una marca
- [ ] **CUANDO** dejo el nombre vacío
- [ ] **ENTONCES** debo ver "Nombre es requerido"
- [ ] **CUANDO** ingreso nombre de más de 50 caracteres
- [ ] **ENTONCES** debo ver "Nombre máximo 50 caracteres"
- [ ] **CUANDO** ingreso nombre que ya existe en otra marca
- [ ] **ENTONCES** debo ver "Ya existe una marca con este nombre"

### CA-007: Actualizar Marca Exitosamente
- [ ] **DADO** que modifico una marca correctamente
- [ ] **CUANDO** presiono "Actualizar"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Actualizar los datos en la base de datos
  - [ ] Mostrar mensaje "Marca actualizada exitosamente"
  - [ ] Volver a la lista con datos actualizados

### CA-008: Desactivar Marca
- [ ] **DADO** que quiero desactivar una marca
- [ ] **CUANDO** presiono "Desactivar" en una marca activa
- [ ] **ENTONCES** debo ver:
  - [ ] Modal de confirmación "¿Estás seguro de desactivar esta marca?"
  - [ ] Advertencia "Los productos existentes no se verán afectados"
  - [ ] Botones "Confirmar" y "Cancelar"

### CA-009: Confirmar Desactivación
- [ ] **DADO** que confirmo la desactivación
- [ ] **CUANDO** presiono "Confirmar"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Marcar la marca como inactiva (no eliminar)
  - [ ] Mostrar mensaje "Marca desactivada exitosamente"
  - [ ] Actualizar la lista mostrando estado inactivo
  - [ ] La marca no aparece en selecciones para nuevos productos

### CA-010: Reactivar Marca
- [ ] **DADO** que quiero reactivar una marca inactiva
- [ ] **CUANDO** presiono "Activar" en una marca inactiva
- [ ] **ENTONCES** el sistema debe:
  - [ ] Marcar la marca como activa
  - [ ] Mostrar mensaje "Marca reactivada exitosamente"
  - [ ] La marca vuelve a estar disponible para nuevos productos

### CA-011: Búsqueda de Marcas
- [ ] **DADO** que quiero buscar una marca específica
- [ ] **CUANDO** escribo en el campo de búsqueda
- [ ] **ENTONCES** debo ver:
  - [ ] Filtrado en tiempo real por nombre o código
  - [ ] Resultados actualizados al escribir
  - [ ] Mensaje "No se encontraron marcas" si no hay coincidencias
  - [ ] Opción de limpiar búsqueda

### CA-012: Restricción de Eliminación
- [ ] **DADO** que una marca tiene productos asociados
- [ ] **CUANDO** intento desactivarla
- [ ] **ENTONCES** debo ver:
  - [ ] Advertencia "Esta marca tiene X productos asociados"
  - [ ] Información "Se desactivará pero productos existentes se mantienen"
  - [ ] Confirmación adicional requerida

## 📋 ESTADOS DE IMPLEMENTACIÓN

### Backend (Supabase)
- [ ] **PENDIENTE** - Tabla `marcas`:
  - [ ] id (UUID, PRIMARY KEY)
  - [ ] nombre (TEXT, NOT NULL, UNIQUE)
  - [ ] codigo (TEXT, NOT NULL, UNIQUE, LENGTH=3)
  - [ ] activo (BOOLEAN, DEFAULT true)
  - [ ] created_at (TIMESTAMP)
  - [ ] updated_at (TIMESTAMP)

- [ ] **PENDIENTE** - Edge Function `catalogos/marcas`:
  - [ ] GET /marcas - Listar todas las marcas
  - [ ] POST /marcas - Crear nueva marca
  - [ ] PUT /marcas/:id - Actualizar marca
  - [ ] PATCH /marcas/:id/toggle - Activar/desactivar marca

- [ ] **PENDIENTE** - Validaciones backend:
  - [ ] Código único, 3 letras mayúsculas
  - [ ] Nombre único, máximo 50 caracteres
  - [ ] Solo admin puede gestionar marcas

### Frontend (Flutter)
- [ ] **PENDIENTE** - MarcasListPage:
  - [ ] Lista de marcas con estado visual
  - [ ] Buscador con filtrado en tiempo real
  - [ ] Botones de acción por marca
  - [ ] Navegación a formularios

- [ ] **PENDIENTE** - MarcaFormPage:
  - [ ] Formulario crear/editar marca
  - [ ] Validaciones en tiempo real
  - [ ] Manejo de estados (loading, success, error)

- [ ] **PENDIENTE** - MarcasBloc:
  - [ ] Estados para gestión de marcas
  - [ ] Eventos CRUD completos
  - [ ] Cache local de marcas activas

### UX/UI
- [ ] **PENDIENTE** - Marcas Components:
  - [ ] MarcaCard con acciones
  - [ ] MarcaForm responsive
  - [ ] Estados visuales (activo/inactivo)
  - [ ] Modales de confirmación
  - [ ] Feedback visual para acciones

### QA
- [ ] **PENDIENTE** - Tests todos los criterios:
  - [ ] CRUD completo de marcas
  - [ ] Validaciones de nombre y código
  - [ ] Búsqueda y filtrado
  - [ ] Activar/desactivar marcas
  - [ ] Restricciones y permisos de admin

## ✅ DEFINICIÓN DE TERMINADO (DoD)
- [x] Todos los criterios de aceptación cumplidos
- [x] CRUD completo de marcas implementado
- [x] Validaciones frontend y backend funcionando
- [x] Solo admin puede gestionar catálogo
- [x] Códigos únicos de 3 letras generados correctamente
- [x] Búsqueda y filtrado operativo
- [x] Activar/desactivar sin eliminar registros
- [x] QA valida todos los flujos
- [x] Documentación actualizada

## 🔗 DEPENDENCIAS
- **HU-001**: Registro de Alta al Sistema Web (debe existir usuario admin)
- **HU-002**: Login por Roles con Aprobación (admin debe poder autenticarse)

## 🏷️ EJEMPLOS DE MARCAS DEL SECTOR
```
Nombre: "Adidas"     → Código: "ADS"
Nombre: "Nike"       → Código: "NIK"
Nombre: "Puma"       → Código: "PUM"
Nombre: "Umbro"      → Código: "UMB"
Nombre: "Reebok"     → Código: "REE"
Nombre: "New Balance"→ Código: "NBL"
```

## 🔐 RESTRICCIONES DE SEGURIDAD
- **Solo ADMIN** puede acceder a gestión de marcas
- **Códigos inmutables** una vez creados (para consistencia de SKU)
- **Soft delete** - nunca eliminar, solo desactivar
- **Auditoría** de cambios en catálogos maestros