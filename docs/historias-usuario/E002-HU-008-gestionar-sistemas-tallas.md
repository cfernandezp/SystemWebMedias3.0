# E002-HU-008: Gestionar Sistemas de Tallas

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E002-HU-008
- **Épica**: E002 - Gestión de Productos de Medias
- **Título**: Gestionar Sistemas de Tallas
- **Story Points**: 5 pts
- **Estado**: ⚪ Pendiente

## 🎯 HISTORIA DE USUARIO
**Como** administrador del sistema de medias
**Quiero** gestionar sistemas de tallas con diferentes tipos y valores configurables
**Para** adaptar productos a distintos estándares de tallas y generar SKUs precisos

## ✅ CRITERIOS DE ACEPTACIÓN

### CA-001: Visualizar Lista de Sistemas de Tallas
- [ ] **DADO** que soy admin autenticado
- [ ] **CUANDO** accedo a la sección "Catálogos > Sistemas de Tallas"
- [ ] **ENTONCES** debo ver:
  - [ ] Lista de sistemas con: nombre, tipo_sistema, valores, estado (activo/inactivo)
  - [ ] Botón "Agregar Nuevo Sistema"
  - [ ] Botones de acciones: Editar, Activar/Desactivar, Ver Valores
  - [ ] Filtros por tipo de sistema (ÚNICA, NÚMERO, LETRA, RANGO)
  - [ ] Contador total de sistemas activos/inactivos
  - [ ] Buscador por nombre

### CA-002: Agregar Nuevo Sistema de Tallas
- [ ] **DADO** que quiero agregar un sistema de tallas
- [ ] **CUANDO** presiono "Agregar Nuevo Sistema"
- [ ] **ENTONCES** debo ver formulario con:
  - [ ] Campo "Nombre" (obligatorio, máx 50 caracteres)
  - [ ] Dropdown "Tipo de Sistema" (ÚNICA, NÚMERO, LETRA, RANGO)
  - [ ] Campo "Descripción" (opcional, máx 200 caracteres)
  - [ ] Área "Configurar Valores" (dinámica según tipo)
  - [ ] Checkbox "Activo" (marcado por defecto)
  - [ ] Botones "Guardar" y "Cancelar"

### CA-003: Configurar Valores por Tipo de Sistema
- [ ] **DADO** que selecciono un tipo de sistema
- [ ] **CUANDO** elijo el tipo correspondiente
- [ ] **ENTONCES** debo ver configuración específica:

#### **TIPO: ÚNICA**
- [ ] Mensaje "Este sistema usa talla única"
- [ ] Campo "Descripción de la talla" (ej: "Talla Única 35-42")

#### **TIPO: NÚMERO**
- [ ] Lista editable de rangos numéricos
- [ ] Botón "Agregar Rango"
- [ ] Campos: "Desde" y "Hasta" para cada rango
- [ ] Ejemplo: 35-36, 37-38, 39-40, 41-42

#### **TIPO: LETRA**
- [ ] Lista editable de tallas por letras
- [ ] Botón "Agregar Talla"
- [ ] Campo texto para cada talla
- [ ] Ejemplo: XS, S, M, L, XL, XXL

#### **TIPO: RANGO**
- [ ] Lista editable de rangos amplios
- [ ] Botón "Agregar Rango"
- [ ] Campos: "Desde" y "Hasta" para cada rango
- [ ] Ejemplo: 34-38, 39-42, 43-46

### CA-004: Validaciones de Nuevo Sistema
- [ ] **DADO** que estoy creando un sistema
- [ ] **CUANDO** dejo el nombre vacío
- [ ] **ENTONCES** debo ver "Nombre es requerido"
- [ ] **CUANDO** no selecciono tipo de sistema
- [ ] **ENTONCES** debo ver "Tipo de sistema es requerido"
- [ ] **CUANDO** no configuro valores para el tipo seleccionado
- [ ] **ENTONCES** debo ver "Debe configurar al menos un valor para este tipo"
- [ ] **CUANDO** ingreso rangos superpuestos en NÚMERO o RANGO
- [ ] **ENTONCES** debo ver "Los rangos no pueden superponerse"
- [ ] **CUANDO** ingreso tallas duplicadas en LETRA
- [ ] **ENTONCES** debo ver "No se permiten tallas duplicadas"

### CA-005: Crear Sistema Exitosamente
- [ ] **DADO** que completo el formulario correctamente
- [ ] **CUANDO** presiono "Guardar"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Crear el sistema en la base de datos
  - [ ] Guardar todos los valores configurados
  - [ ] Mostrar mensaje "Sistema de tallas creado exitosamente"
  - [ ] Volver a la lista de sistemas
  - [ ] Mostrar el nuevo sistema en la lista

### CA-006: Editar Sistema Existente
- [ ] **DADO** que quiero modificar un sistema
- [ ] **CUANDO** presiono "Editar" en un sistema
- [ ] **ENTONCES** debo ver:
  - [ ] Formulario prellenado con datos actuales
  - [ ] Tipo de sistema deshabilitado (no se puede cambiar)
  - [ ] Valores actuales cargados y editables
  - [ ] Posibilidad de cambiar nombre, descripción y valores
  - [ ] Botones "Actualizar" y "Cancelar"

### CA-007: Gestión de Valores en Edición
- [ ] **DADO** que estoy editando valores de un sistema
- [ ] **CUANDO** modifico los valores
- [ ] **ENTONCES** puedo:
  - [ ] Agregar nuevos valores con botón "+"
  - [ ] Eliminar valores existentes con botón "X"
  - [ ] Modificar valores existentes en línea
  - [ ] Ver advertencia si hay productos usando valores a eliminar

### CA-008: Validación de Eliminación de Valores
- [ ] **DADO** que intento eliminar un valor usado en productos
- [ ] **CUANDO** presiono eliminar en ese valor
- [ ] **ENTONCES** debo ver:
  - [ ] Warning "Este valor está siendo usado en X productos"
  - [ ] Lista de productos afectados
  - [ ] Opciones: "Eliminar igual", "Migrar a otro valor", "Cancelar"
  - [ ] Confirmación adicional requerida

### CA-009: Actualizar Sistema Exitosamente
- [ ] **DADO** que modifico un sistema correctamente
- [ ] **CUANDO** presiono "Actualizar"
- [ ] **ENTONCES** el sistema debe:
  - [ ] Actualizar los datos en la base de datos
  - [ ] Procesar cambios en valores (agregar/eliminar/modificar)
  - [ ] Mostrar mensaje "Sistema actualizado exitosamente"
  - [ ] Volver a la lista con datos actualizados

### CA-010: Ver Valores Detallados
- [ ] **DADO** que quiero ver todos los valores de un sistema
- [ ] **CUANDO** presiono "Ver Valores" en un sistema
- [ ] **ENTONCES** debo ver:
  - [ ] Modal con todos los valores configurados
  - [ ] Cantidad de productos por cada valor
  - [ ] Estadísticas de uso general
  - [ ] Botón "Editar" para ir a formulario de edición

### CA-011: Desactivar Sistema
- [ ] **DADO** que quiero desactivar un sistema
- [ ] **CUANDO** presiono "Desactivar" en un sistema activo
- [ ] **ENTONCES** debo ver:
  - [ ] Modal de confirmación "¿Estás seguro de desactivar este sistema?"
  - [ ] Advertencia "Los productos existentes no se verán afectados"
  - [ ] Información de productos asociados si los hay
  - [ ] Botones "Confirmar" y "Cancelar"

### CA-012: Búsqueda y Filtros
- [ ] **DADO** que quiero buscar sistemas específicos
- [ ] **CUANDO** uso las opciones de búsqueda
- [ ] **ENTONCES** puedo:
  - [ ] Buscar por nombre en tiempo real
  - [ ] Filtrar por tipo de sistema (ÚNICA, NÚMERO, LETRA, RANGO)
  - [ ] Filtrar por estado (activo/inactivo)
  - [ ] Combinar múltiples filtros
  - [ ] Ver resultados actualizados inmediatamente

## 📋 ESTADOS DE IMPLEMENTACIÓN

### Backend (Supabase)
- [ ] **PENDIENTE** - Tabla `sistemas_talla`:
  - [ ] id (UUID, PRIMARY KEY)
  - [ ] nombre (TEXT, NOT NULL, UNIQUE)
  - [ ] tipo_sistema (ENUM: 'UNICA', 'NUMERO', 'LETRA', 'RANGO')
  - [ ] descripcion (TEXT, NULLABLE)
  - [ ] activo (BOOLEAN, DEFAULT true)
  - [ ] created_at (TIMESTAMP)
  - [ ] updated_at (TIMESTAMP)

- [ ] **PENDIENTE** - Tabla `valores_talla`:
  - [ ] id (UUID, PRIMARY KEY)
  - [ ] sistema_talla_id (UUID, FK)
  - [ ] valor (TEXT, NOT NULL) // "35-36", "M", "34-38", "ÚNICA"
  - [ ] orden (INTEGER) // Para ordenamiento
  - [ ] activo (BOOLEAN, DEFAULT true)

- [ ] **PENDIENTE** - Edge Function `catalogos/sistemas-talla`:
  - [ ] GET /sistemas-talla - Listar todos los sistemas
  - [ ] POST /sistemas-talla - Crear nuevo sistema con valores
  - [ ] PUT /sistemas-talla/:id - Actualizar sistema y valores
  - [ ] GET /sistemas-talla/:id/valores - Obtener valores del sistema
  - [ ] GET /sistemas-talla/:id/productos - Productos que usan el sistema

### Frontend (Flutter)
- [ ] **PENDIENTE** - SistemasTallaListPage:
  - [ ] Lista de sistemas con tipo y cantidad de valores
  - [ ] Filtros por tipo de sistema
  - [ ] Buscador en tiempo real
  - [ ] Modal de valores detallados

- [ ] **PENDIENTE** - SistemaTallaFormPage:
  - [ ] Formulario dinámico según tipo de sistema
  - [ ] Gestión visual de valores (agregar/eliminar)
  - [ ] Validaciones específicas por tipo
  - [ ] Preview de SKU generado

- [ ] **PENDIENTE** - Components:
  - [ ] ValorTallaInput (componente reutilizable)
  - [ ] TipoSistemaSelector
  - [ ] ValoresList (editable)

### UX/UI
- [ ] **PENDIENTE** - Sistemas Talla Components:
  - [ ] SistemaTallaCard con tipo visual
  - [ ] Formulario dinámico por tipo de sistema
  - [ ] Lista interactiva de valores
  - [ ] Modal de valores con estadísticas
  - [ ] Feedback visual para validaciones

### QA
- [ ] **PENDIENTE** - Tests todos los criterios:
  - [ ] CRUD completo de sistemas de tallas
  - [ ] Configuración de valores por cada tipo
  - [ ] Validaciones específicas (rangos, duplicados)
  - [ ] Edición de valores con productos asociados
  - [ ] Búsqueda y filtrado por tipo
  - [ ] Migración de valores en edición

## ✅ DEFINICIÓN DE TERMINADO (DoD)
- [ ] Todos los criterios de aceptación cumplidos
- [ ] CRUD completo de sistemas de tallas implementado
- [ ] Configuración dinámica de valores por tipo
- [ ] Validaciones específicas para cada tipo funcionando
- [ ] Gestión de valores con productos asociados
- [ ] Búsqueda y filtrado por múltiples criterios
- [ ] Solo admin puede gestionar catálogo
- [ ] QA valida todos los flujos y tipos
- [ ] Documentación actualizada

## 🔗 DEPENDENCIAS
- **E002-HU-005**: Gestionar Catálogo de Marcas (patrón establecido)
- **E002-HU-006**: Gestionar Catálogo de Materiales (patrón establecido)
- **E002-HU-007**: Gestionar Catálogo de Tipos (patrón establecido)

## 📏 EJEMPLOS DE SISTEMAS DEL SECTOR

### **SISTEMA ÚNICO**
```
Nombre: "Talla Única Estándar"
Tipo: ÚNICA
Valores: ["ÚNICA"]
Descripción: "Talla única que se adapta a pie 35-42"
```

### **SISTEMA NUMÉRICO**
```
Nombre: "Tallas Numéricas Europeas"
Tipo: NÚMERO
Valores: ["35-36", "37-38", "39-40", "41-42", "43-44"]
Descripción: "Sistema de tallas por números europeos en rangos"
```

### **SISTEMA LETRAS**
```
Nombre: "Tallas por Letras Estándar"
Tipo: LETRA
Valores: ["XS", "S", "M", "L", "XL", "XXL"]
Descripción: "Sistema de tallas alfabético estándar"
```

### **SISTEMA RANGOS**
```
Nombre: "Rangos Amplios"
Tipo: RANGO
Valores: ["34-38", "39-42", "43-46"]
Descripción: "Rangos amplios para medias deportivas"
```

## 💾 ESTRUCTURA DE DATOS
```json
{
  "sistema": {
    "id": "uuid",
    "nombre": "Tallas Numéricas Europeas",
    "tipo_sistema": "NUMERO",
    "descripcion": "Sistema estándar europeo",
    "activo": true
  },
  "valores": [
    {"valor": "35-36", "orden": 1, "activo": true},
    {"valor": "37-38", "orden": 2, "activo": true},
    {"valor": "39-40", "orden": 3, "activo": true}
  ]
}
```

## 🔐 RESTRICCIONES DE SEGURIDAD
- **Solo ADMIN** puede gestionar sistemas de tallas
- **Tipo inmutable** una vez creado (para consistencia)
- **Soft delete** - nunca eliminar, solo desactivar
- **Validación de productos** antes de eliminar valores
- **Auditoría** de cambios en sistemas y valores