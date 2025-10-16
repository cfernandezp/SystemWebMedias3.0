# E004-HU-004: Gestión de Proveedores

## INFORMACIÓN
- **Código**: E004-HU-004
- **Épica**: E004 - Gestión de Personas y Roles
- **Título**: Gestión de Proveedores
- **Story Points**: 5 pts
- **Estado**: Estado Borrador
- **Fecha**: 2025-10-15

## HISTORIA
**Como** administrador o gerente
**Quiero** gestionar proveedores que suministran productos de medias
**Para** registrar compras, condiciones de pago y productos que proveen

### Criterios Aceptación

#### CA-001: Buscar Persona para Asignar Rol Proveedor
- [ ] **DADO** que necesito registrar un nuevo proveedor
- [ ] **CUANDO** ingreso tipo de documento y número en el buscador
- [ ] **ENTONCES** el sistema debe buscar si la persona existe
- [ ] **Y** si existe, debe mostrar sus datos y permitir asignarle rol proveedor

#### CA-002: Crear Persona y Asignar Rol Proveedor
- [ ] **DADO** que la persona no existe en el sistema
- [ ] **CUANDO** completo datos de persona y datos de proveedor (condiciones de pago, tiempo de entrega)
- [ ] **ENTONCES** el sistema debe crear la persona y asignarle rol proveedor
- [ ] **Y** debe redirigir a la ficha del proveedor creado

#### CA-003: Asignar Rol Proveedor a Persona Existente
- [ ] **DADO** que la persona ya existe pero no tiene rol proveedor
- [ ] **CUANDO** la selecciono y asigno rol proveedor
- [ ] **ENTONCES** el sistema debe crear el registro de proveedor vinculado a la persona
- [ ] **Y** debe mantener otros roles que ya tenga (ej: si ya era cliente)

#### CA-004: Prevenir Duplicar Rol Proveedor
- [ ] **DADO** que intento asignar rol proveedor a una persona
- [ ] **CUANDO** esa persona ya tiene rol proveedor activo
- [ ] **ENTONCES** debo ver mensaje "Esta persona ya es proveedor. ¿Desea editar sus datos?"
- [ ] **Y** debe redirigir a edición del proveedor existente

#### CA-005: Configurar Condiciones de Pago
- [ ] **DADO** que registro un proveedor
- [ ] **CUANDO** ingreso condiciones de pago (contado, crédito 15 días, crédito 30 días, etc.)
- [ ] **ENTONCES** el sistema debe guardar esas condiciones
- [ ] **Y** deben aplicarse por defecto en futuras órdenes de compra

#### CA-006: Configurar Tiempo de Entrega
- [ ] **DADO** que registro un proveedor
- [ ] **CUANDO** ingreso tiempo estimado de entrega (en días)
- [ ] **ENTONCES** el sistema debe validar que sea un número positivo
- [ ] **Y** debe usarse para calcular fechas estimadas en órdenes de compra

#### CA-007: Registrar Productos Principales que Provee
- [ ] **DADO** que edito un proveedor
- [ ] **CUANDO** agrego productos o marcas que provee habitualmente
- [ ] **ENTONCES** el sistema debe guardar esa información descriptiva
- [ ] **Y** debe mostrarse al crear órdenes de compra para facilitar selección de proveedor

#### CA-008: Listar Proveedores Activos
- [ ] **DADO** que accedo al módulo "Proveedores"
- [ ] **CUANDO** se carga la lista
- [ ] **ENTONCES** debo ver todos los proveedores con: documento, nombre/razón social, condiciones de pago, tiempo entrega y estado
- [ ] **Y** debe permitir filtrar por estado y productos que provee

#### CA-009: Editar Datos del Proveedor
- [ ] **DADO** que selecciono un proveedor existente
- [ ] **CUANDO** edito condiciones de pago, tiempo de entrega o productos que provee
- [ ] **ENTONCES** el sistema debe actualizar solo los datos del rol proveedor
- [ ] **Y** los datos de la persona base deben editarse desde el módulo Personas

#### CA-010: Ver Historial de Compras a Proveedor
- [ ] **DADO** que veo el detalle de un proveedor
- [ ] **CUANDO** accedo a la pestaña "Historial de Compras"
- [ ] **ENTONCES** debo ver listado de todas las órdenes de compra con fecha, monto y productos
- [ ] **Y** debe mostrar total de compras y deuda pendiente actual

#### CA-011: Desactivar Proveedor
- [ ] **DADO** que un proveedor ya no suministra productos
- [ ] **CUANDO** lo desactivo
- [ ] **ENTONCES** no debe aparecer en el selector de proveedores al crear órdenes de compra
- [ ] **Y** debe conservar su historial de compras
- [ ] **Y** la persona base debe seguir activa

#### CA-012: Alertar Proveedor con RUC Preferente
- [ ] **DADO** que creo un proveedor
- [ ] **CUANDO** selecciono una persona con DNI (persona natural)
- [ ] **ENTONCES** debo ver advertencia "Los proveedores generalmente son empresas (RUC). ¿Confirma usar DNI?"
- [ ] **Y** debe permitir continuar si confirmo

## NOTAS
HU define QUÉ desde perspectiva usuario. Detalles técnicos (tabla proveedores, relaciones, cálculo deuda) los definen agentes especializados.

**Reglas de Negocio**:
- Proveedor es un ROL asignado a una persona existente
- Generalmente proveedores son empresas (RUC) pero puede ser persona natural
- Condiciones de pago: texto libre (ej: "Contado", "Crédito 30 días", "50% adelanto 50% contra entrega")
- Tiempo de entrega: días hábiles estimados
- Productos que provee: campo descriptivo para referencia
- No eliminar proveedores con compras registradas, solo desactivar

**Flujo de Negocio**:
1. Buscar persona por documento
2. Si NO existe → crear persona + asignar rol proveedor
3. Si existe SIN rol proveedor → asignar rol proveedor
4. Si existe CON rol proveedor → editar datos del proveedor
