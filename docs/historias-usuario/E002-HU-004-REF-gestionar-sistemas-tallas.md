# E002-HU-004: Gestionar Sistemas de Tallas

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E002-HU-004
- **Épica**: E002 - Gestión de Productos de Medias
- **Título**: Gestionar Sistemas de Tallas
- **Story Points**: 5 pts
- **Estado**: 🟢 Refinada

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

## 📐 REGLAS DE NEGOCIO (RN)

### RN-004-01: Tipos de Sistema de Tallas
**Contexto**: Creación o configuración de un sistema de tallas
**Restricción**: Solo existen 4 tipos de sistema válidos
**Validación**: El tipo debe ser exactamente uno de:
- **ÚNICA**: Una sola talla universal (ej: "ÚNICA")
- **NÚMERO**: Tallas numéricas individuales o rangos cortos (ej: "2", "3", "15", "35-36", "37-38")
- **LETRA**: Tallas alfabéticas (ej: "XS", "S", "M", "L", "XL", "XXL")
- **RANGO**: Rangos amplios numéricos (ej: "3-5", "5-9", "34-38", "39-42")
**Caso especial**: Una vez creado el sistema, el tipo NO puede modificarse (inmutable)

### RN-004-02: Unicidad de Nombre de Sistema
**Contexto**: Creación o edición de sistema de tallas
**Restricción**: No pueden existir dos sistemas con el mismo nombre
**Validación**: El nombre debe ser único en toda la tabla de sistemas de tallas
**Caso especial**: La validación es case-insensitive ("Tallas Europeas" = "tallas europeas")

### RN-004-03: Configuración de Valores Según Tipo
**Contexto**: Agregar valores a un sistema de tallas
**Restricción**: Los valores deben respetar el formato del tipo de sistema
**Validación por tipo**:
- **ÚNICA**: Solo se permite un valor fijo "ÚNICA"
- **NÚMERO**: Acepta números individuales ("2", "15") o rangos cortos con guion ("35-36", "37-38")
- **LETRA**: Solo acepta texto alfabético (letras mayúsculas/minúsculas, ej: "S", "XL")
- **RANGO**: Solo acepta formato "número-número" con rangos amplios (ej: "3-5", "34-38")
**Caso especial**: Los números en rangos NÚMERO y RANGO deben cumplir que el primer número < segundo número

### RN-004-04: No Duplicidad de Valores en Sistema
**Contexto**: Agregar o editar valores dentro de un mismo sistema
**Restricción**: No pueden existir valores duplicados en el mismo sistema
**Validación**: Dentro de un sistema, cada valor debe ser único
**Caso especial 1**: La validación es case-insensitive para tipo LETRA ("S" = "s")
**Caso especial 2**: Para tipo NÚMERO/RANGO, "35-36" ≠ "36-35" (diferente orden)

### RN-004-05: No Superposición de Rangos
**Contexto**: Configurar valores tipo NÚMERO o RANGO
**Restricción**: Los rangos numéricos no pueden superponerse
**Validación**: Dados dos rangos A-B y C-D, no debe cumplirse que:
- B ≥ C cuando A < C (superposición por la derecha)
- D ≥ A cuando C < A (superposición por la izquierda)
- A ≤ C y B ≥ D (un rango contiene al otro)
**Ejemplos válidos**: "35-36", "37-38", "39-40" (no se superponen)
**Ejemplos inválidos**: "35-38", "37-40" (38 está en ambos)

### RN-004-06: Mínimo Un Valor por Sistema
**Contexto**: Creación o edición de sistema de tallas
**Restricción**: Todo sistema debe tener al menos un valor configurado
**Validación**: Al guardar, debe existir mínimo 1 valor activo asociado al sistema
**Caso especial**: Tipo ÚNICA automáticamente tiene valor "ÚNICA" (no requiere configuración manual)

### RN-004-07: Inmutabilidad de Tipo de Sistema
**Contexto**: Edición de sistema existente
**Restricción**: El tipo de sistema NO puede modificarse una vez creado
**Validación**: Al editar, el campo "tipo_sistema" debe estar deshabilitado
**Razón de negocio**: Cambiar el tipo afectaría productos ya asociados y generaría inconsistencias en SKUs

### RN-004-08: Protección de Valores con Productos Asociados
**Contexto**: Eliminar o desactivar un valor de talla
**Restricción**: Si existen productos usando ese valor, se requiere acción explícita
**Validación**: Antes de eliminar, verificar si hay productos con ese valor
**Opciones si hay productos**:
1. **Cancelar**: No eliminar el valor
2. **Migrar**: Cambiar productos a otro valor del mismo sistema
3. **Eliminar igual**: Eliminar y dejar productos sin valor (requiere confirmación adicional)
**Caso especial**: Si es el único valor del sistema, NO permitir eliminación

### RN-004-09: Desactivación sin Afectar Productos
**Contexto**: Desactivar un sistema de tallas
**Restricción**: Desactivar sistema NO afecta productos existentes
**Validación**: Los productos que ya usan el sistema continúan funcionando normalmente
**Efecto**: Sistema desactivado NO aparece en listas de selección para nuevos productos
**Caso especial**: Permitir reactivación en cualquier momento

### RN-004-10: Ordenamiento de Valores
**Contexto**: Visualización y uso de valores de tallas
**Restricción**: Los valores deben presentarse en orden lógico
**Validación**: Usar campo "orden" para secuencia personalizada
**Orden sugerido por tipo**:
- **NÚMERO/RANGO**: Ascendente numérico (35-36, 37-38, 39-40)
- **LETRA**: Lógica XS → S → M → L → XL → XXL
- **ÚNICA**: N/A (un solo valor)
**Caso especial**: Administrador puede reordenar manualmente

### RN-004-11: Restricción de Acceso
**Contexto**: Cualquier operación de gestión de sistemas de tallas
**Restricción**: Solo usuarios con rol ADMIN pueden gestionar sistemas
**Validación**: Verificar rol antes de permitir crear, editar, desactivar o eliminar
**Caso especial**: Vendedores y gerentes solo pueden CONSULTAR sistemas (lectura)

### RN-004-12: Validación de Formato de Rangos
**Contexto**: Ingreso de valores tipo NÚMERO o RANGO
**Restricción**: Rangos deben tener formato válido "número-número"
**Validación**:
- Solo números enteros positivos
- Separador único: guion "-"
- Sin espacios
- Primer número < segundo número
**Ejemplos válidos**: "35-36", "3-5", "15-20"
**Ejemplos inválidos**: "36-35" (invertido), "35 - 36" (espacios), "35_36" (separador incorrecto)

### RN-004-13: Soft Delete - No Eliminación Física
**Contexto**: Eliminación de sistemas o valores
**Restricción**: NUNCA eliminar registros de la base de datos
**Validación**: Usar campo "activo" = false para desactivación lógica
**Razón de negocio**: Preservar historial y trazabilidad de productos asociados
**Caso especial**: Auditoría debe poder recuperar datos históricos

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