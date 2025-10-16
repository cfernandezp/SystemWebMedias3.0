# ÉPICA E004: Gestión de Personas y Roles

## INFORMACIÓN
- **Código**: E004
- **Nombre**: Gestión de Personas y Roles
- **Descripción**: Sistema de gestión de personas (naturales y jurídicas) con múltiples roles asignables (cliente, proveedor, transportista) para retail de medias
- **Story Points**: 34 pts
- **Estado**: Estado Pendiente

## HISTORIAS

### E004-HU-001: Catálogo de Tipos de Documento
- **Archivo**: `docs/historias-usuario/E004-HU-001-REF-tipos-documento.md`
- **Estado**: Refinada (REF) | Story Points: 3 | Prioridad: Alta

### E004-HU-002: Gestión de Personas (Entidad Base)
- **Archivo**: `docs/historias-usuario/E004-HU-002-REF-personas-base.md`
- **Estado**: Refinada (REF) | Story Points: 5 | Prioridad: Crítica

### E004-HU-003: Gestión de Clientes
- **Archivo**: `docs/historias-usuario/E004-HU-003-BOR-clientes.md`
- **Estado**: Estado Borrador | Story Points: 6 | Prioridad: Crítica

### E004-HU-004: Gestión de Proveedores
- **Archivo**: `docs/historias-usuario/E004-HU-004-BOR-proveedores.md`
- **Estado**: Estado Borrador | Story Points: 5 | Prioridad: Alta

### E004-HU-005: Gestión de Transportistas
- **Archivo**: `docs/historias-usuario/E004-HU-005-BOR-transportistas.md`
- **Estado**: Estado Borrador | Story Points: 5 | Prioridad: Media

### E004-HU-006: Consulta Multi-Rol
- **Archivo**: `docs/historias-usuario/E004-HU-006-BOR-consulta-multi-rol.md`
- **Estado**: Estado Borrador | Story Points: 10 | Prioridad: Media

## CRITERIOS ÉPICA
- [ ] Tipos de documento configurables por país
- [ ] Personas únicas identificadas por documento
- [ ] Una persona puede tener múltiples roles simultáneos
- [ ] Flujo: primero buscar/crear persona, luego asignar rol
- [ ] Clientes pueden tener DNI o RUC
- [ ] Proveedores generalmente con RUC (pero flexible)
- [ ] Transportistas pueden ser personas naturales o jurídicas
- [ ] Historial unificado por persona base
- [ ] Validación de documentos según tipo

## PROGRESO
- Total HU: 6
- Completadas: 0 (0%)
- En Desarrollo: 0 (0%)
- Pendientes: 6 (100%)

## CONTEXTO DE NEGOCIO

### Modelo de Personas Multi-Rol

El sistema maneja **personas** como entidad base que pueden asumir diferentes **roles** en el negocio:

**Entidad Base - PERSONA**:
- Identificación única por documento (DNI, RUC, CE, Pasaporte)
- Tipo de persona: Natural (persona física) o Jurídica (empresa)
- Datos básicos: nombre/razón social, contacto, dirección

**Roles Asignables**:
- **CLIENTE**: Compra productos (puede ser persona natural con DNI o empresa con RUC)
- **PROVEEDOR**: Suministra productos (generalmente empresa con RUC)
- **TRANSPORTISTA**: Realiza entregas (persona natural independiente o empresa)
- **EMPLEADO**: Ya existe en el sistema (tabla usuarios)

### Flujo de Negocio

1. **Registro de Persona**:
   - Usuario busca por número de documento
   - Si NO existe → crear nueva persona
   - Si existe → usar persona existente

2. **Asignación de Rol**:
   - Seleccionar persona por documento
   - Asignar uno o más roles
   - Completar datos específicos del rol

3. **Gestión Multi-Rol**:
   - Una persona puede ser cliente Y proveedor simultáneamente
   - Cada rol tiene sus propios datos específicos
   - Historial unificado por persona

### Tipos de Documento por País

**Perú (configuración inicial)**:
- **DNI**: Documento Nacional de Identidad (8 dígitos, personas naturales)
- **RUC**: Registro Único de Contribuyente (11 dígitos, personas jurídicas o naturales con negocio)
- **CE**: Carnet de Extranjería (9 dígitos)
- **PASAPORTE**: Pasaporte (variable, alfanumérico)

**Nota**: Sistema debe ser flexible para agregar tipos de documento de otros países en el futuro.

### Reglas de Negocio Generales

**RN-Personas-001**: Un documento no puede repetirse en el sistema
- Validación: Buscar por tipo_documento + nro_documento antes de crear
- Mensaje: "Ya existe una persona con este documento"

**RN-Personas-002**: Documentos según tipo de persona
- Persona Natural: DNI, CE, Pasaporte
- Persona Jurídica: RUC
- Validación al guardar persona

**RN-Personas-003**: Una persona puede tener múltiples roles
- Cliente puede convertirse en proveedor posteriormente
- Proveedor puede ser también transportista
- Historial unificado por persona base

**RN-Personas-004**: Validación de formato según tipo documento
- DNI: Exactamente 8 dígitos numéricos
- RUC: Exactamente 11 dígitos numéricos
- CE: Exactamente 9 dígitos alfanuméricos
- Pasaporte: Alfanumérico variable (máximo 12 caracteres)

**RN-Personas-005**: No eliminar personas con transacciones
- Si persona tiene ventas, compras o entregas → NO eliminar
- Solo permitir desactivar
- Mensaje: "Esta persona tiene transacciones registradas. Solo puede desactivarse"

## RELACIÓN CON OTRAS ÉPICAS

**Dependencias**:
- E001 - Autenticación y Autorización (roles de usuario para permisos)

**Bloqueante para**:
- E005 - Gestión de Ventas (requiere clientes)
- E006 - Gestión de Compras (requiere proveedores)
- E007 - Gestión de Entregas (requiere transportistas)

**Relacionada con**:
- E002 - Gestión de Productos (productos que compran clientes/proveedores suministran)
- E003 - Dashboard y Navegación (módulo personas en menú)

## NOTAS TÉCNICAS

### Estructura de Datos Propuesta (Alto Nivel)

**Tabla: tipos_documento**
- Catálogo de tipos de documento (DNI, RUC, CE, Pasaporte, etc.)
- Configuración de validaciones por tipo

**Tabla: personas**
- Entidad base con documento único
- Tipo de persona (Natural/Jurídica)
- Datos de contacto generales

**Tabla: clientes**
- Relación con persona_id
- Datos específicos de cliente (límite crédito, descuentos)

**Tabla: proveedores**
- Relación con persona_id
- Datos específicos de proveedor (condiciones pago, productos)

**Tabla: transportistas**
- Relación con persona_id
- Datos específicos de transportista (vehículo, zona cobertura)

### Ejemplo de Caso de Uso

**Escenario**: Juan Pérez es dueño de una bodega

1. Se registra como **persona**:
   - Tipo Natural, DNI 12345678
   - Nombre: Juan Pérez
   - Celular: 987654321

2. Se le asigna rol **CLIENTE**:
   - Compra medias al por mayor para su bodega
   - Límite crédito: S/. 5,000
   - Descuento habitual: 10%

3. Posteriormente registra su negocio:
   - Se crea nueva **persona**:
   - Tipo Jurídica, RUC 20123456789
   - Razón Social: Bodega Pérez SAC
   - Se vincula como **CLIENTE** también (para compras corporativas)

4. Si Juan hace entregas con su mototaxi:
   - Se le asigna rol **TRANSPORTISTA** a su persona DNI
   - Ahora Juan Pérez (DNI) es CLIENTE + TRANSPORTISTA

---

**Notas del Product Owner**:
Esta épica define la gestión de personas desde la perspectiva del negocio. Las HU especifican QUÉ necesita el sistema, NO CÓMO implementarlo técnicamente. Los agentes especializados (supabase-expert, ux-ui-expert, flutter-expert, qa-testing-expert) definirán la arquitectura, modelo de datos, componentes UI y tests.
