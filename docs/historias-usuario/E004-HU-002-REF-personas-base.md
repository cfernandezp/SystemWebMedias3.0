# E004-HU-002: Gestión de Personas (Entidad Base)

## INFORMACIÓN
- **Código**: E004-HU-002
- **Épica**: E004 - Gestión de Personas y Roles
- **Título**: Gestión de Personas (Entidad Base)
- **Story Points**: 5 pts
- **Estado**: Refinada (REF)
- **Fecha**: 2025-10-15

## HISTORIA
**Como** usuario del sistema (admin/gerente)
**Quiero** gestionar personas identificadas por documento
**Para** tener un registro único de todas las personas que interactúan en el negocio antes de asignarles roles específicos

### Criterios Aceptación

#### CA-001: Buscar Persona por Documento
- [ ] **DADO** que necesito registrar una persona
- [ ] **CUANDO** ingreso tipo de documento y número
- [ ] **ENTONCES** el sistema debe buscar si ya existe
- [ ] **Y** si existe, debe mostrar datos de la persona encontrada

#### CA-002: Crear Nueva Persona
- [ ] **DADO** que la persona no existe en el sistema
- [ ] **CUANDO** completo los datos (tipo documento, nro documento, tipo persona, nombre/razón social, email, celular, dirección)
- [ ] **ENTONCES** el sistema debe crear la persona
- [ ] **Y** debe estar disponible para asignarle roles

#### CA-003: Validar Documento Único
- [ ] **DADO** que intento crear una persona
- [ ] **CUANDO** el número de documento ya existe en el sistema
- [ ] **ENTONCES** debo ver mensaje "Ya existe una persona con este documento"
- [ ] **Y** debe mostrar opción "Ver persona existente"

#### CA-004: Validar Formato de Documento
- [ ] **DADO** que ingreso un número de documento
- [ ] **CUANDO** el formato no coincide con el tipo seleccionado (ej: DNI con letras)
- [ ] **ENTONCES** debo ver mensaje de error "Formato inválido para DNI. Debe tener 8 dígitos"
- [ ] **Y** no debe permitir guardar

#### CA-005: Diferenciar Persona Natural vs Jurídica
- [ ] **DADO** que creo una persona
- [ ] **CUANDO** selecciono tipo "Natural"
- [ ] **ENTONCES** debe solicitar campo "Nombre completo"
- [ ] **PERO CUANDO** selecciono tipo "Jurídica"
- [ ] **ENTONCES** debe solicitar campo "Razón social"

#### CA-006: Listar Personas Registradas
- [ ] **DADO** que accedo al módulo "Personas"
- [ ] **CUANDO** se carga la lista
- [ ] **ENTONCES** debo ver todas las personas con: tipo documento, nro documento, nombre/razón social, tipo persona, roles asignados y estado
- [ ] **Y** debe permitir filtrar por tipo de documento, tipo de persona y estado

#### CA-007: Editar Datos de Persona
- [ ] **DADO** que selecciono una persona existente
- [ ] **CUANDO** edito sus datos de contacto (email, celular, dirección)
- [ ] **ENTONCES** el sistema debe actualizar la información
- [ ] **PERO** no debe permitir cambiar tipo de documento ni número de documento

#### CA-008: Desactivar Persona con Validación
- [ ] **DADO** que intento desactivar una persona
- [ ] **CUANDO** tiene roles activos (cliente activo, proveedor activo)
- [ ] **ENTONCES** debo ver advertencia "Esta persona tiene roles activos. ¿Desactivarlos también?"
- [ ] **Y** debe permitir desactivar solo la persona o en cascada (persona + roles)

#### CA-009: Prevenir Eliminación con Transacciones
- [ ] **DADO** que intento eliminar una persona
- [ ] **CUANDO** tiene transacciones registradas (ventas, compras, entregas)
- [ ] **ENTONCES** debo ver mensaje "Esta persona tiene transacciones registradas. Solo puede desactivarse"
- [ ] **Y** no debe permitir eliminar

#### CA-010: Ver Resumen de Roles Asignados
- [ ] **DADO** que visualizo una persona
- [ ] **CUANDO** veo su detalle
- [ ] **ENTONCES** debo ver badge con cada rol asignado (Cliente, Proveedor, Transportista)
- [ ] **Y** debe indicar estado de cada rol (activo/inactivo)

## REGLAS DE NEGOCIO (RN)

### RN-047: Unicidad de Documento en el Sistema
**Contexto**: Al crear una nueva persona en el sistema
**Restricción**: No permitir duplicados de documento
**Validación**:
- Combinación tipo_documento + numero_documento debe ser única en todo el sistema
- Validación antes de crear la persona
- Búsqueda debe incluir personas activas e inactivas
- Si existe: mostrar datos de la persona encontrada
**Mensaje**: "Ya existe una persona con este documento"
**Caso especial**: Persona inactiva con mismo documento puede reactivarse en lugar de crear nueva

### RN-048: Inmutabilidad de Documento de Identidad
**Contexto**: Al editar datos de una persona existente
**Restricción**: Tipo y número de documento NO pueden modificarse
**Validación**:
- Tipo de documento es inmutable después de creación
- Número de documento es inmutable después de creación
- Solo datos de contacto y estado pueden editarse
**Razón**: Documento es identificador único permanente de la persona
**Caso especial**: Si requiere cambio de documento, crear nueva persona y desactivar anterior

### RN-049: Campos Según Tipo de Persona
**Contexto**: Al registrar o editar datos de una persona
**Restricción**: Campos obligatorios varían según tipo de persona
**Validación**:
- Persona Natural: nombre_completo es obligatorio, razon_social queda vacío
- Persona Jurídica: razon_social es obligatorio, nombre_completo queda vacío
- Tipo de persona es obligatorio (Natural o Jurídica)
**Caso especial**: No se permite dejar ambos campos vacíos o ambos llenos

### RN-050: Validación de Formato de Documento
**Contexto**: Al ingresar número de documento
**Restricción**: Aplicar validaciones del tipo de documento seleccionado
**Validación**:
- Utilizar función validar_formato_documento (RN-044 de E004-HU-001)
- Formato debe coincidir con tipo seleccionado
- Longitud debe estar en rango permitido
- Solo permitir caracteres válidos según formato
**Ejemplo**: DNI solo acepta 8 dígitos numéricos, RUC solo 11 dígitos numéricos
**Caso especial**: Validación en tiempo real al ingresar documento

### RN-051: Datos de Contacto Opcionales
**Contexto**: Al registrar una persona
**Restricción**: Definir datos obligatorios vs opcionales
**Validación**:
- Email: opcional, pero si se ingresa debe tener formato válido
- Celular: opcional, pero si se ingresa debe tener formato válido
- Dirección: opcional
- Teléfono fijo: opcional
**Caso especial**: Sistema debe funcionar sin datos de contacto, pero recomendar registrarlos

### RN-052: Formato de Email Válido
**Contexto**: Al ingresar email de contacto
**Restricción**: Validar estructura de correo electrónico
**Validación**:
- Debe contener @ y dominio
- No permitir espacios
- Formato estándar: usuario@dominio.extension
- Longitud máxima 100 caracteres
**Caso especial**: Email puede quedar vacío (opcional)

### RN-053: Formato de Celular Válido
**Contexto**: Al ingresar celular de contacto
**Restricción**: Validar formato de número celular
**Validación**:
- Solo dígitos numéricos
- Longitud 9 dígitos (Perú: 9XXXXXXXX)
- No permitir letras ni caracteres especiales
**Caso especial**: Celular puede quedar vacío (opcional), sistema preparado para formatos internacionales

### RN-054: Protección de Personas con Transacciones
**Contexto**: Al intentar eliminar una persona
**Restricción**: No eliminar personas que tienen historial de transacciones
**Validación**:
- Verificar si persona tiene ventas registradas
- Verificar si persona tiene compras registradas (como proveedor)
- Verificar si persona tiene entregas registradas (como transportista)
- Si tiene al menos 1 transacción: prohibir eliminación
**Mensaje**: "Esta persona tiene transacciones registradas. Solo puede desactivarse"
**Caso especial**: Persona sin transacciones puede eliminarse físicamente

### RN-055: Desactivación en Cascada de Roles
**Contexto**: Al desactivar una persona base
**Restricción**: Gestionar roles activos asociados
**Validación**:
- Detectar si persona tiene roles activos (cliente activo, proveedor activo, transportista activo)
- Si tiene roles activos: mostrar advertencia con opciones
- Opción 1: Desactivar solo la persona (roles quedan activos)
- Opción 2: Desactivar persona y todos sus roles en cascada
**Mensaje**: "Esta persona tiene roles activos. ¿Desactivarlos también?"
**Caso especial**: Si todos los roles ya están inactivos, desactivar persona directamente

### RN-056: Búsqueda por Documento Antes de Crear
**Contexto**: Al iniciar flujo de creación de persona
**Restricción**: Evitar duplicados mediante búsqueda previa
**Validación**:
- Usuario debe ingresar tipo y número de documento primero
- Sistema busca en base de datos existente
- Si NO existe: habilitar formulario de creación
- Si existe: mostrar datos de persona existente con opción "Ver detalle"
**Caso especial**: Usuario puede cancelar y ver persona existente en lugar de crear

### RN-057: Tipos de Documento Según Tipo de Persona
**Contexto**: Al seleccionar tipo de documento para una persona
**Restricción**: Validar coherencia entre tipo de persona y tipo de documento
**Validación**:
- Persona Natural: puede usar DNI, CE (Carnet Extranjería), Pasaporte
- Persona Jurídica: debe usar RUC
- Validación al seleccionar combinación
**Mensaje**: "RUC solo aplica para Persona Jurídica" o "Persona Jurídica debe usar RUC"
**Caso especial**: Persona Natural con negocio puede tener RUC en segunda persona vinculada

### RN-058: Listado con Filtros Multi-Criterio
**Contexto**: Al visualizar lista de personas
**Restricción**: Permitir filtrado flexible para encontrar personas
**Validación**:
- Filtro por tipo de documento (DNI, RUC, CE, etc.)
- Filtro por tipo de persona (Natural, Jurídica)
- Filtro por estado (Activo, Inactivo)
- Filtro por roles asignados (tiene cliente, tiene proveedor, etc.)
- Búsqueda por nombre/razón social/número de documento
**Caso especial**: Filtros deben combinarse (operador AND)

### RN-059: Visualización de Roles Asignados
**Contexto**: Al mostrar lista de personas o detalle de persona
**Restricción**: Indicar claramente qué roles tiene asignados
**Validación**:
- Mostrar badges con cada rol asignado
- Indicar estado de cada rol (activo/inactivo)
- Roles posibles: Cliente, Proveedor, Transportista
- Una persona puede tener 0, 1, 2 o 3 roles simultáneamente
**Caso especial**: Persona sin roles asignados debe mostrar indicador "Sin roles"

### RN-060: Reactivación de Persona Inactiva
**Contexto**: Al encontrar persona inactiva en búsqueda por documento
**Restricción**: Permitir reactivar en lugar de duplicar
**Validación**:
- Si persona existe pero está inactiva: mostrar opción "Reactivar persona"
- Reactivación restaura estado activo
- Roles previos permanecen en su estado (activo/inactivo)
- Datos de contacto pueden actualizarse al reactivar
**Caso especial**: Reactivación no afecta historial de transacciones

## CASOS DE USO ESPECÍFICOS DEL NEGOCIO

### CU-001: Registrar Cliente Natural (Consumidor Final)
**Escenario**: Vendedor registra cliente que compra para consumo personal
- Tipo Persona: Natural
- Tipo Documento: DNI
- Número Documento: 12345678 (8 dígitos)
- Nombre Completo: Juan Pérez García
- Email: juan.perez@gmail.com (opcional)
- Celular: 987654321 (opcional)
- Dirección: Av. Los Olivos 123, San Isidro (opcional)
- Estado: Activo
- **Resultado**: Persona creada, lista para asignar rol Cliente

### CU-002: Registrar Proveedor Jurídico (Empresa)
**Escenario**: Admin registra empresa proveedora de medias
- Tipo Persona: Jurídica
- Tipo Documento: RUC
- Número Documento: 20123456789 (11 dígitos)
- Razón Social: Textiles del Norte SAC
- Email: ventas@textilesnorte.com.pe
- Celular: 987123456 (representante)
- Dirección: Jr. Industrial 456, Los Olivos
- Estado: Activo
- **Resultado**: Persona creada, lista para asignar rol Proveedor

### CU-003: Evitar Duplicado al Registrar
**Escenario**: Gerente intenta registrar cliente que ya existe
1. Gerente ingresa: DNI 12345678
2. Sistema busca y encuentra persona existente: Juan Pérez García (ACTIVO, rol: Cliente)
3. Sistema muestra: "Ya existe una persona con este documento"
4. Sistema ofrece: botón "Ver persona existente"
5. **Resultado**: NO se crea duplicado, se usa persona existente

### CU-004: Editar Solo Datos de Contacto
**Escenario**: Cliente cambia número de celular
- Persona: Juan Pérez (DNI 12345678)
- Acción: Editar datos de contacto
- Permitido: cambiar email, celular, dirección
- **Bloqueado**: cambiar DNI o tipo de documento
- **Resultado**: Datos de contacto actualizados, documento inmutable

### CU-005: Desactivar Persona con Rol Activo
**Escenario**: Admin desactiva proveedor que dejó de trabajar con empresa
1. Persona: Textiles del Norte SAC (RUC 20123456789)
2. Tiene rol: Proveedor (ACTIVO)
3. Sistema pregunta: "Esta persona tiene roles activos. ¿Desactivarlos también?"
4. Admin selecciona: "Desactivar persona y roles"
5. **Resultado**: Persona INACTIVA, rol Proveedor INACTIVO

### CU-006: Prevenir Eliminación con Historial
**Escenario**: Gerente intenta eliminar cliente con compras
1. Persona: María López (DNI 87654321)
2. Tiene: 5 ventas registradas en el sistema
3. Sistema verifica transacciones: encuentra 5 ventas
4. Sistema bloquea eliminación
5. Sistema muestra: "Esta persona tiene transacciones registradas. Solo puede desactivarse"
6. **Resultado**: NO se elimina, solo opción de desactivar

### CU-007: Reactivar Persona Previamente Inactiva
**Escenario**: Proveedor que dejó de trabajar regresa
1. Admin busca: RUC 20999888777
2. Sistema encuentra: Distribuidora Central EIRL (INACTIVO)
3. Sistema muestra: datos de persona inactiva + botón "Reactivar"
4. Admin actualiza datos de contacto (nuevo email y celular)
5. Admin confirma reactivación
6. **Resultado**: Persona ACTIVA, datos actualizados, historial preservado

### CU-008: Persona con Múltiples Roles
**Escenario**: Transportista independiente también es cliente
1. Persona: Carlos Ruiz (DNI 11223344)
2. Inicialmente: rol Transportista (ACTIVO)
3. Posteriormente compra medias para su familia
4. Se le asigna: rol Cliente (ACTIVO)
5. Lista muestra: badges "Cliente" y "Transportista" ambos activos
6. **Resultado**: 1 persona con 2 roles activos, historial unificado

## NOTAS
HU define QUÉ desde perspectiva usuario. Detalles técnicos (tabla personas, campos, índices, constraints) los definen agentes especializados.

**Relación con E004-HU-001**: Utiliza tipos de documento configurados en catálogo, aplica validaciones RN-044 (formato documento)
