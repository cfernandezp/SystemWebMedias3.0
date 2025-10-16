# E004-HU-006: Consulta Multi-Rol

## INFORMACIÓN
- **Código**: E004-HU-006
- **Épica**: E004 - Gestión de Personas y Roles
- **Título**: Consulta Multi-Rol
- **Story Points**: 10 pts
- **Estado**: Estado Borrador
- **Fecha**: 2025-10-15

## HISTORIA
**Como** usuario del sistema (admin/gerente)
**Quiero** consultar todos los roles que tiene asignada una persona
**Para** tener una visión completa de su relación con el negocio y su historial unificado

### Criterios Aceptación

#### CA-001: Buscar Persona por Documento
- [ ] **DADO** que necesito consultar una persona
- [ ] **CUANDO** ingreso tipo de documento y número
- [ ] **ENTONCES** el sistema debe mostrar ficha completa de la persona
- [ ] **Y** debe mostrar todos los roles que tiene asignados

#### CA-002: Visualizar Todos los Roles Activos
- [ ] **DADO** que veo el detalle de una persona
- [ ] **CUANDO** tiene múltiples roles (ej: Cliente + Transportista)
- [ ] **ENTONCES** debo ver badge por cada rol activo con estado
- [ ] **Y** debe mostrar ícono diferente por rol (Cliente: carrito, Proveedor: camión, Transportista: moto)

#### CA-003: Ver Datos Específicos por Rol
- [ ] **DADO** que una persona tiene rol Cliente
- [ ] **CUANDO** hago clic en el badge "Cliente"
- [ ] **ENTONCES** debo ver panel expandido con: límite crédito, descuento habitual, crédito utilizado y zona de venta
- [ ] **Y** si también tiene rol Transportista, debe mostrar sus datos al hacer clic en badge "Transportista"

#### CA-004: Historial Unificado de Transacciones
- [ ] **DADO** que veo el detalle de una persona con múltiples roles
- [ ] **CUANDO** accedo a la pestaña "Historial Completo"
- [ ] **ENTONCES** debo ver todas las transacciones ordenadas cronológicamente
- [ ] **Y** cada transacción debe indicar el rol involucrado (ej: "Compra como Cliente", "Entrega como Transportista")

#### CA-005: Filtrar Historial por Rol
- [ ] **DADO** que veo el historial completo de una persona
- [ ] **CUANDO** aplico filtro "Solo Cliente"
- [ ] **ENTONCES** debo ver únicamente transacciones donde actuó como cliente
- [ ] **Y** debe permitir filtrar por cada rol disponible

#### CA-006: Ver Resumen Financiero Multi-Rol
- [ ] **DADO** que veo el detalle de una persona con múltiples roles
- [ ] **CUANDO** accedo a la pestaña "Resumen Financiero"
- [ ] **ENTONCES** debo ver tarjetas separadas por rol:
  - [ ] Como Cliente: total comprado, deuda pendiente
  - [ ] Como Proveedor: total vendido, cuentas por cobrar
  - [ ] Como Transportista: total entregas, monto ganado
- [ ] **Y** debe mostrar balance general consolidado

#### CA-007: Detectar Conflictos de Interés
- [ ] **DADO** que una persona es Cliente y Proveedor simultáneamente
- [ ] **CUANDO** veo su ficha
- [ ] **ENTONCES** debo ver advertencia "Esta persona tiene roles de Cliente y Proveedor"
- [ ] **Y** debe permitir revisar ambas relaciones comerciales

#### CA-008: Activar/Desactivar Roles Independientemente
- [ ] **DADO** que una persona tiene múltiples roles
- [ ] **CUANDO** desactivo el rol Cliente
- [ ] **ENTONCES** el rol Transportista debe seguir activo
- [ ] **Y** la persona base debe seguir activa

#### CA-009: Buscar Personas Multi-Rol en Lista General
- [ ] **DADO** que accedo al módulo "Personas"
- [ ] **CUANDO** aplico filtro "Con múltiples roles"
- [ ] **ENTONCES** debo ver solo personas que tienen 2 o más roles activos
- [ ] **Y** debe mostrar badges de todos sus roles en la lista

#### CA-010: Reportes por Persona Multi-Rol
- [ ] **DADO** que genero reporte de actividad
- [ ] **CUANDO** selecciono una persona con múltiples roles
- [ ] **ENTONCES** el reporte debe incluir secciones separadas por rol
- [ ] **Y** debe incluir totales consolidados al final

#### CA-011: Validar Asignación de Nuevo Rol
- [ ] **DADO** que intento asignar un nuevo rol a persona existente
- [ ] **CUANDO** esa persona ya tiene otros roles activos
- [ ] **ENTONCES** debo ver advertencia "Esta persona ya tiene roles: Cliente, Transportista. ¿Confirma agregar Proveedor?"
- [ ] **Y** debe permitir continuar si confirmo

#### CA-012: Timeline de Cambios de Roles
- [ ] **DADO** que veo el detalle de una persona
- [ ] **CUANDO** accedo a la pestaña "Timeline de Roles"
- [ ] **ENTONCES** debo ver historial cronológico de:
  - [ ] Fecha en que se asignó cada rol
  - [ ] Fecha en que se desactivó cada rol (si aplica)
  - [ ] Usuario que realizó el cambio
- [ ] **Y** debe permitir filtrar por tipo de evento (asignación/desactivación)

#### CA-013: Exportar Datos Multi-Rol
- [ ] **DADO** que veo el detalle de una persona con múltiples roles
- [ ] **CUANDO** hago clic en "Exportar PDF"
- [ ] **ENTONCES** debe generar documento con:
  - [ ] Datos de la persona
  - [ ] Sección por cada rol con sus datos específicos
  - [ ] Historial de transacciones por rol
  - [ ] Resumen financiero consolidado

## NOTAS
HU define QUÉ desde perspectiva usuario. Detalles técnicos (vistas consolidadas, joins, cálculos financieros) los definen agentes especializados.

**Reglas de Negocio**:
- Una persona puede tener 0, 1 o múltiples roles simultáneamente
- Roles son independientes: se pueden activar/desactivar por separado
- Historial unificado muestra transacciones de todos los roles ordenadas cronológicamente
- Cada transacción debe indicar el rol con el que se realizó
- Resumen financiero consolida información de todos los roles activos
- No hay límite de cantidad de roles por persona

**Casos de Ejemplo**:
1. **Juan Pérez (DNI 12345678)**:
   - Rol Cliente (activo): compra medias para su bodega
   - Rol Transportista (activo): hace entregas con su mototaxi
   - Historial: 20 compras como cliente + 45 entregas como transportista

2. **Distribuidora SAC (RUC 20123456789)**:
   - Rol Cliente (activo): compra medias al por mayor
   - Rol Proveedor (activo): provee empaques
   - Advertencia: "Cliente y Proveedor simultáneamente"

3. **María López (DNI 87654321)**:
   - Rol Cliente (inactivo desde 2024-06-15): dejó de comprar
   - Rol Transportista (activo): solo hace entregas ahora
   - Timeline muestra cambio de estado del rol Cliente

**Flujo de Negocio**:
1. Buscar persona por documento
2. Ver ficha con todos los roles asignados
3. Expandir cada rol para ver datos específicos
4. Consultar historial unificado de transacciones
5. Aplicar filtros por rol para análisis específico
6. Generar reportes consolidados multi-rol
