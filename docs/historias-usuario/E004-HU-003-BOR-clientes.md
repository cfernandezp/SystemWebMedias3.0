# E004-HU-003: Gestión de Clientes

## INFORMACIÓN
- **Código**: E004-HU-003
- **Épica**: E004 - Gestión de Personas y Roles
- **Título**: Gestión de Clientes
- **Story Points**: 6 pts
- **Estado**: Estado Borrador
- **Fecha**: 2025-10-15

## HISTORIA
**Como** usuario del sistema (admin/gerente/vendedor)
**Quiero** gestionar clientes que compran productos de medias
**Para** registrar sus compras, otorgar crédito y aplicar descuentos según su perfil

### Criterios Aceptación

#### CA-001: Buscar Persona para Asignar Rol Cliente
- [ ] **DADO** que necesito registrar un nuevo cliente
- [ ] **CUANDO** ingreso tipo de documento y número en el buscador
- [ ] **ENTONCES** el sistema debe buscar si la persona existe
- [ ] **Y** si existe, debe mostrar sus datos y permitir asignarle rol cliente

#### CA-002: Crear Persona y Asignar Rol Cliente Simultáneamente
- [ ] **DADO** que la persona no existe en el sistema
- [ ] **CUANDO** completo datos de persona (documento, nombre, contacto) y datos de cliente (límite crédito, descuento)
- [ ] **ENTONCES** el sistema debe crear la persona y asignarle rol cliente en una sola operación
- [ ] **Y** debe redirigir a la ficha del cliente creado

#### CA-003: Asignar Rol Cliente a Persona Existente
- [ ] **DADO** que la persona ya existe pero no tiene rol cliente
- [ ] **CUANDO** la selecciono y asigno rol cliente con sus datos específicos
- [ ] **ENTONCES** el sistema debe crear el registro de cliente vinculado a la persona
- [ ] **Y** debe mantener otros roles que ya tenga (ej: si ya era transportista)

#### CA-004: Prevenir Duplicar Rol Cliente
- [ ] **DADO** que intento asignar rol cliente a una persona
- [ ] **CUANDO** esa persona ya tiene rol cliente activo
- [ ] **ENTONCES** debo ver mensaje "Esta persona ya es cliente. ¿Desea editar sus datos?"
- [ ] **Y** debe redirigir a edición del cliente existente

#### CA-005: Configurar Límite de Crédito
- [ ] **DADO** que registro un cliente
- [ ] **CUANDO** ingreso límite de crédito (monto en soles)
- [ ] **ENTONCES** el sistema debe guardar ese límite
- [ ] **Y** debe validar que sea un número positivo o cero (cliente sin crédito)

#### CA-006: Configurar Descuento Habitual
- [ ] **DADO** que registro un cliente
- [ ] **CUANDO** ingreso descuento habitual (porcentaje)
- [ ] **ENTONCES** el sistema debe validar que esté entre 0% y 100%
- [ ] **Y** debe aplicarse automáticamente en futuras ventas

#### CA-007: Diferenciar Cliente Natural vs Jurídico
- [ ] **DADO** que visualizo la lista de clientes
- [ ] **CUANDO** un cliente tiene DNI
- [ ] **ENTONCES** debe mostrarse como "Cliente Natural"
- [ ] **PERO CUANDO** un cliente tiene RUC
- [ ] **ENTONCES** debe mostrarse como "Cliente Empresa"

#### CA-008: Listar Clientes Activos
- [ ] **DADO** que accedo al módulo "Clientes"
- [ ] **CUANDO** se carga la lista
- [ ] **ENTONCES** debo ver todos los clientes con: documento, nombre/razón social, tipo persona, límite crédito, descuento, crédito utilizado y estado
- [ ] **Y** debe permitir filtrar por tipo de documento, estado y zona de venta

#### CA-009: Editar Datos del Cliente
- [ ] **DADO** que selecciono un cliente existente
- [ ] **CUANDO** edito límite de crédito, descuento o zona de venta
- [ ] **ENTONCES** el sistema debe actualizar solo los datos del rol cliente
- [ ] **Y** los datos de la persona base (nombre, documento, contacto) deben editarse desde el módulo Personas

#### CA-010: Ver Historial de Compras
- [ ] **DADO** que veo el detalle de un cliente
- [ ] **CUANDO** accedo a la pestaña "Historial de Compras"
- [ ] **ENTONCES** debo ver listado de todas sus compras con fecha, monto y productos
- [ ] **Y** debe mostrar total de compras y crédito utilizado actual

#### CA-011: Desactivar Cliente
- [ ] **DADO** que un cliente ya no compra
- [ ] **CUANDO** lo desactivo
- [ ] **ENTONCES** no debe aparecer en el selector de clientes al registrar ventas
- [ ] **Y** debe conservar su historial de compras
- [ ] **Y** la persona base debe seguir activa (puede tener otros roles)

#### CA-012: Validar Crédito Disponible
- [ ] **DADO** que un cliente tiene límite de crédito configurado
- [ ] **CUANDO** visualizo su ficha
- [ ] **ENTONCES** debo ver: límite total, crédito utilizado y crédito disponible
- [ ] **Y** debe mostrar alerta si crédito disponible es menor al 20% del límite

## NOTAS
HU define QUÉ desde perspectiva usuario. Detalles técnicos (tabla clientes, relaciones con personas, cálculo crédito) los definen agentes especializados.

**Reglas de Negocio**:
- Cliente es un ROL asignado a una persona existente
- Una persona puede ser cliente con DNI (persona natural) o RUC (empresa)
- Límite de crédito: 0 = cliente sin crédito (solo pago contado)
- Descuento habitual: porcentaje entre 0% y 100%
- Crédito utilizado se calcula desde ventas pendientes de pago
- No eliminar clientes con compras registradas, solo desactivar
- Cliente inactivo no aparece en selector de ventas pero conserva historial

**Flujo de Negocio**:
1. Buscar persona por documento
2. Si NO existe → crear persona + asignar rol cliente
3. Si existe SIN rol cliente → asignar rol cliente
4. Si existe CON rol cliente → editar datos del cliente
