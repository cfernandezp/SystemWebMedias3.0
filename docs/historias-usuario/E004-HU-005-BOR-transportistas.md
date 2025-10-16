# E004-HU-005: Gestión de Transportistas

## INFORMACIÓN
- **Código**: E004-HU-005
- **Épica**: E004 - Gestión de Personas y Roles
- **Título**: Gestión de Transportistas
- **Story Points**: 5 pts
- **Estado**: Estado Borrador
- **Fecha**: 2025-10-15

## HISTORIA
**Como** administrador o gerente
**Quiero** gestionar transportistas que realizan entregas de productos
**Para** asignarles envíos, controlar zonas de cobertura y tarifas de transporte

### Criterios Aceptación

#### CA-001: Buscar Persona para Asignar Rol Transportista
- [ ] **DADO** que necesito registrar un nuevo transportista
- [ ] **CUANDO** ingreso tipo de documento y número en el buscador
- [ ] **ENTONCES** el sistema debe buscar si la persona existe
- [ ] **Y** si existe, debe mostrar sus datos y permitir asignarle rol transportista

#### CA-002: Crear Persona y Asignar Rol Transportista
- [ ] **DADO** que la persona no existe en el sistema
- [ ] **CUANDO** completo datos de persona y datos de transportista (tipo vehículo, placa, zona cobertura)
- [ ] **ENTONCES** el sistema debe crear la persona y asignarle rol transportista
- [ ] **Y** debe redirigir a la ficha del transportista creado

#### CA-003: Asignar Rol Transportista a Persona Existente
- [ ] **DADO** que la persona ya existe pero no tiene rol transportista
- [ ] **CUANDO** la selecciono y asigno rol transportista
- [ ] **ENTONCES** el sistema debe crear el registro de transportista vinculado a la persona
- [ ] **Y** debe mantener otros roles que ya tenga (ej: si ya era cliente)

#### CA-004: Prevenir Duplicar Rol Transportista
- [ ] **DADO** que intento asignar rol transportista a una persona
- [ ] **CUANDO** esa persona ya tiene rol transportista activo
- [ ] **ENTONCES** debo ver mensaje "Esta persona ya es transportista. ¿Desea editar sus datos?"
- [ ] **Y** debe redirigir a edición del transportista existente

#### CA-005: Registrar Tipo de Vehículo
- [ ] **DADO** que registro un transportista
- [ ] **CUANDO** ingreso tipo de vehículo (mototaxi, auto, camioneta, camión)
- [ ] **ENTONCES** el sistema debe guardar ese dato
- [ ] **Y** debe mostrarse al asignar entregas para seleccionar transportista adecuado

#### CA-006: Registrar Placa del Vehículo
- [ ] **DADO** que registro un transportista
- [ ] **CUANDO** ingreso placa del vehículo
- [ ] **ENTONCES** el sistema debe validar que no esté vacía
- [ ] **Y** debe validar formato de placa (alfanumérico, máximo 7 caracteres)

#### CA-007: Configurar Zona de Cobertura
- [ ] **DADO** que registro un transportista
- [ ] **CUANDO** ingreso zona de cobertura (distritos o zonas que atiende)
- [ ] **ENTONCES** el sistema debe guardar esa información
- [ ] **Y** debe usarse para filtrar transportistas disponibles según zona de entrega

#### CA-008: Configurar Tarifa por Kilómetro o Zona
- [ ] **DADO** que registro un transportista
- [ ] **CUANDO** ingreso tarifa (monto por km o por zona)
- [ ] **ENTONCES** el sistema debe validar que sea un número positivo
- [ ] **Y** debe usarse para calcular costo estimado de entregas

#### CA-009: Listar Transportistas Activos
- [ ] **DADO** que accedo al módulo "Transportistas"
- [ ] **CUANDO** se carga la lista
- [ ] **ENTONCES** debo ver todos los transportistas con: documento, nombre/razón social, tipo vehículo, placa, zona cobertura y estado
- [ ] **Y** debe permitir filtrar por tipo de vehículo, zona de cobertura y estado

#### CA-010: Editar Datos del Transportista
- [ ] **DADO** que selecciono un transportista existente
- [ ] **CUANDO** edito tipo vehículo, placa, zona cobertura o tarifa
- [ ] **ENTONCES** el sistema debe actualizar solo los datos del rol transportista
- [ ] **Y** los datos de la persona base deben editarse desde el módulo Personas

#### CA-011: Ver Historial de Entregas
- [ ] **DADO** que veo el detalle de un transportista
- [ ] **CUANDO** accedo a la pestaña "Historial de Entregas"
- [ ] **ENTONCES** debo ver listado de todas las entregas realizadas con fecha, destino y monto cobrado
- [ ] **Y** debe mostrar total de entregas realizadas y monto total ganado

#### CA-012: Desactivar Transportista
- [ ] **DADO** que un transportista ya no realiza entregas
- [ ] **CUANDO** lo desactivo
- [ ] **ENTONCES** no debe aparecer en el selector de transportistas al asignar entregas
- [ ] **Y** debe conservar su historial de entregas
- [ ] **Y** la persona base debe seguir activa

#### CA-013: Permitir Transportista Natural o Jurídico
- [ ] **DADO** que creo un transportista
- [ ] **CUANDO** selecciono persona con DNI (transportista independiente)
- [ ] **ENTONCES** el sistema debe permitir registrarlo normalmente
- [ ] **PERO CUANDO** selecciono persona con RUC (empresa de transporte)
- [ ] **ENTONCES** también debe permitir registrarlo (ambos casos válidos)

## NOTAS
HU define QUÉ desde perspectiva usuario. Detalles técnicos (tabla transportistas, cálculo tarifas, asignación entregas) los definen agentes especializados.

**Reglas de Negocio**:
- Transportista es un ROL asignado a una persona existente
- Puede ser persona natural (DNI - ej: mototaxista) o jurídica (RUC - ej: empresa de transporte)
- Tipo de vehículo: catálogo (mototaxi, auto, camioneta, camión, otro)
- Placa: alfanumérico, máximo 7 caracteres, obligatorio
- Zona de cobertura: texto libre (ej: "Los Olivos, Independencia, San Martín de Porres")
- Tarifa: número positivo (puede ser por km, por zona o fija según acuerdo)
- No eliminar transportistas con entregas registradas, solo desactivar

**Flujo de Negocio**:
1. Buscar persona por documento
2. Si NO existe → crear persona + asignar rol transportista
3. Si existe SIN rol transportista → asignar rol transportista
4. Si existe CON rol transportista → editar datos del transportista
