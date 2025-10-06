# E003-HU-002: Sistema de Navegación con Menús Desplegables

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E003-HU-002
- **Épica**: E003 - Dashboard y Sistema de Navegación
- **Título**: Sistema de Navegación con Menús Desplegables
- **Story Points**: 8 pts
- **Estado**: 🟢 Refinada
- **Fecha Creación**: 2025-10-05

## 🎯 HISTORIA DE USUARIO
**Como** usuario del sistema (vendedor/gerente/admin)
**Quiero** navegar entre secciones mediante un menú lateral moderno con opciones desplegables
**Para** acceder rápidamente a las funcionalidades disponibles según mi rol

### Criterios de Aceptación

#### CA-001: Sidebar con Menús según Rol de Vendedor
- [ ] **DADO** que soy un vendedor autenticado
- [ ] **CUANDO** visualizo el sidebar
- [ ] **ENTONCES** debo ver las siguientes opciones:
  - [ ] 📊 **Dashboard** (enlace directo)
  - [ ] 🏪 **Punto de Venta** (enlace directo)
  - [ ] 📦 **Productos** (menú desplegable):
    - [ ] Gestionar catálogo
  - [ ] 📋 **Inventario** (enlace directo - solo lectura de su tienda)
  - [ ] 💰 **Ventas** (menú desplegable):
    - [ ] Historial de ventas
    - [ ] Mis comisiones
  - [ ] 👥 **Clientes** (menú desplegable):
    - [ ] Registrar cliente
    - [ ] Base de datos de clientes
  - [ ] 📈 **Reportes** (menú desplegable):
    - [ ] Análisis y métricas

#### CA-002: Sidebar con Menús según Rol de Gerente
- [ ] **DADO** que soy un gerente autenticado
- [ ] **CUANDO** visualizo el sidebar
- [ ] **ENTONCES** debo ver las siguientes opciones:
  - [ ] 📊 **Dashboard** (enlace directo)
  - [ ] 🏪 **Punto de Venta** (enlace directo)
  - [ ] 📦 **Productos** (menú desplegable):
    - [ ] Gestionar catálogo
  - [ ] 📋 **Inventario** (menú desplegable):
    - [ ] Control de stock
    - [ ] Transferencias (solicitar a otras tiendas)
  - [ ] 💰 **Ventas** (menú desplegable):
    - [ ] Historial de ventas
    - [ ] Comisiones del equipo
  - [ ] 👥 **Personas** (menú desplegable):
    - [ ] Registrar persona
    - [ ] Clientes
    - [ ] Proveedores
  - [ ] 📈 **Reportes** (menú desplegable):
    - [ ] Análisis y métricas
    - [ ] Dashboard de tienda
  - [ ] ⚙️ **Configuración** (menú desplegable):
    - [ ] Ajustes del sistema

#### CA-003: Sidebar con Menús según Rol de Admin
- [ ] **DADO** que soy un admin autenticado
- [ ] **CUANDO** visualizo el sidebar
- [ ] **ENTONCES** debo ver las siguientes opciones:
  - [ ] 📊 **Dashboard** (enlace directo)
  - [ ] 🏪 **Punto de Venta** (enlace directo)
  - [ ] 📦 **Productos** (menú desplegable):
    - [ ] Gestionar catálogo
    - [ ] Marcas
    - [ ] Materiales
    - [ ] Tipos
    - [ ] Sistemas de tallas
  - [ ] 📋 **Inventario** (menú desplegable):
    - [ ] Control de stock (todas las tiendas)
    - [ ] Transferencias entre tiendas
  - [ ] 💰 **Ventas** (menú desplegable):
    - [ ] Historial consolidado
    - [ ] Comisiones globales
  - [ ] 👥 **Personas** (menú desplegable):
    - [ ] Registrar persona/documento
    - [ ] Base de datos completa
    - [ ] Ver clientes
    - [ ] Ver proveedores
    - [ ] Ver transportistas
  - [ ] 📈 **Reportes** (menú desplegable):
    - [ ] Análisis global
    - [ ] Comparativas entre tiendas
  - [ ] 👨‍💼 **Admin** (menú desplegable):
    - [ ] Gestión de usuarios
    - [ ] Gestión de tiendas
  - [ ] ⚙️ **Configuración** (menú desplegable):
    - [ ] Ajustes del sistema

#### CA-004: Comportamiento de Menús Desplegables
- [ ] **DADO** que veo un menú con ícono de flecha (▼)
- [ ] **CUANDO** hago clic en el menú principal
- [ ] **ENTONCES** debe expandirse mostrando las sub-opciones
- [ ] **Y** el ícono debe rotar a flecha arriba (▲)
- [ ] **CUANDO** hago clic nuevamente en el menú expandido
- [ ] **ENTONCES** debe colapsar ocultando las sub-opciones
- [ ] **Y** el ícono debe volver a flecha abajo (▼)

#### CA-005: Sidebar Colapsable
- [ ] **DADO** que estoy en cualquier pantalla con sidebar
- [ ] **CUANDO** hago clic en el botón de menú hamburguesa (☰)
- [ ] **ENTONCES** el sidebar debe colapsarse mostrando solo íconos
- [ ] **Y** los labels de texto deben ocultarse
- [ ] **CUANDO** hago clic nuevamente en el botón de menú
- [ ] **ENTONCES** el sidebar debe expandirse mostrando íconos y labels
- [ ] **CUANDO** el sidebar está colapsado y paso el mouse sobre un ícono
- [ ] **ENTONCES** debo ver un tooltip con el nombre de la opción

#### CA-006: Header con Perfil de Usuario y Logout
- [ ] **DADO** que estoy autenticado en el sistema
- [ ] **CUANDO** visualizo el header superior
- [ ] **ENTONCES** debo ver en la esquina derecha:
  - [ ] Avatar del usuario (inicial del nombre o foto)
  - [ ] Nombre del usuario
  - [ ] Rol del usuario (Vendedor/Gerente/Admin)
- [ ] **CUANDO** hago clic en el avatar o nombre
- [ ] **ENTONCES** debe desplegarse un menú dropdown con:
  - [ ] 👤 **Ver perfil** (navega a perfil de usuario)
  - [ ] ⚙️ **Configuración** (navega a ajustes)
  - [ ] 🚪 **Cerrar sesión** (ejecuta logout)
- [ ] **CUANDO** hago clic en "Cerrar sesión"
- [ ] **ENTONCES** debo ver un modal de confirmación:
  - [ ] Mensaje: "¿Estás seguro que deseas cerrar sesión?"
  - [ ] Botón "Cancelar" (cierra modal)
  - [ ] Botón "Cerrar sesión" (ejecuta logout y redirige a login)

#### CA-007: Indicador de Página Activa
- [ ] **DADO** que estoy navegando entre secciones
- [ ] **CUANDO** accedo a una página desde el sidebar
- [ ] **ENTONCES** la opción del menú correspondiente debe resaltarse:
  - [ ] Fondo con color primario (turquesa/cyan)
  - [ ] Texto en color blanco o contrastante
  - [ ] Borde izquierdo de 4px en color acento

#### CA-008: Breadcrumbs de Navegación
- [ ] **DADO** que estoy en cualquier página del sistema
- [ ] **CUANDO** visualizo el contenido principal
- [ ] **ENTONCES** debo ver breadcrumbs en la parte superior:
  - [ ] Ejemplo: **Dashboard** (página raíz)
  - [ ] Ejemplo: **Productos > Gestionar catálogo** (sub-página)
  - [ ] Ejemplo: **Admin > Gestión de usuarios** (página de admin)
- [ ] **CUANDO** hago clic en un breadcrumb
- [ ] **ENTONCES** debo navegar a esa sección

### Estado de Implementación
- [ ] **Backend** - Pendiente
  - [ ] Edge Function `user/get_menu_options` que devuelve menús según rol
  - [ ] RLS policies para verificar acceso a cada opción
  - [ ] Endpoint `auth/logout` para cerrar sesión
- [ ] **Frontend** - Pendiente
  - [ ] Sidebar component con lógica de expansión/colapso
  - [ ] MenuBloc para gestión de estado de menús
  - [ ] Header component con dropdown de perfil
  - [ ] Breadcrumbs component
  - [ ] Lógica de navegación condicional por rol
  - [ ] Modal de confirmación de logout
- [ ] **UX/UI** - Pendiente
  - [ ] Sidebar moderno con íconos y animaciones
  - [ ] Menús desplegables con transiciones suaves
  - [ ] Header con avatar y dropdown estilizado
  - [ ] Breadcrumbs con separadores visuales
  - [ ] Estados hover/active/focus en opciones
  - [ ] Animaciones de colapsar/expandir sidebar
- [ ] **QA** - Pendiente
  - [ ] Tests de todos los criterios de aceptación
  - [ ] Validación de opciones según rol
  - [ ] Tests de navegación y logout
  - [ ] Tests de responsive (sidebar en móvil)

### Definición de Terminado (DoD)
- [ ] Todos los criterios de aceptación cumplidos
- [ ] Backend implementado según SISTEMA_DOCUMENTACION.md
- [ ] Frontend consume APIs correctamente
- [ ] UX/UI sigue Design System
- [ ] QA valida todos los flujos
- [ ] Documentación actualizada

---

## 📊 REGLAS DE NEGOCIO PURAS

### RN-001: Modelo de Personas Multi-Documento Multi-Rol
**Regla**: Una persona puede tener múltiples documentos de identidad y asumir múltiples roles en el sistema simultáneamente.

**Contexto de Negocio**: En el negocio real, una misma persona física puede:
- Tener DNI (persona natural) y RUC (empresa)
- Ser cliente (compra medias) y proveedor (vende telas) al mismo tiempo
- Cambiar de rol a lo largo del tiempo (cliente → vendedor → proveedor)

**Lógica**:
```
PERSONA (entidad base)
├─ id, nombre_completo, email, telefono
└─ relaciones:
   ├─ DOCUMENTOS (1:N)
   │  ├─ tipo_documento: DNI, RUC, CE, Pasaporte
   │  ├─ numero_documento (único)
   │  └─ es_principal (boolean)
   └─ ROLES (N:N)
      ├─ rol: cliente, proveedor, transportista, vendedor_externo
      ├─ metadata_rol (JSONB específico por rol)
      └─ activo (boolean)
```

**Metadata según rol**:
- **Cliente**: `{credito_limite: 5000, descuento_default: 0.05, tipo_cliente: "minorista|mayorista"}`
- **Proveedor**: `{condiciones_pago: "30 días", categoria: "telas", cuenta_bancaria: "xxx"}`
- **Transportista**: `{zona_cobertura: "Lima Norte", tipo_vehiculo: "moto", capacidad_kg: 50}`
- **Vendedor Externo**: `{comision_porcentaje: 0.10, zona_asignada: "Lima Sur"}`

**Validaciones**:
- ✅ Una persona puede tener múltiples documentos, pero cada `numero_documento` debe ser único en el sistema
- ✅ Debe existir al menos un documento marcado como `es_principal = true`
- ✅ Una persona puede tener múltiples roles activos simultáneamente
- ✅ Al desactivar un rol, no se elimina el historial (soft delete)
- ✅ Si una persona tiene rol "cliente" y "proveedor", sus transacciones de compra y venta se mantienen separadas

**Casos de Negocio**:
- **Juan Pérez**: DNI 12345678 (principal) + RUC 20123456789 → Roles: Cliente + Proveedor
  - Cuando compra medias → usa DNI, registra como venta
  - Cuando vende telas → usa RUC, registra como compra a proveedor
- **María García**: Solo DNI 87654321 → Rol: Cliente
  - Si más adelante se convierte en vendedora → agregar rol "vendedor_externo" sin eliminar "cliente"

---

### RN-002: Segmentación de Acceso a Módulo "Personas" por Rol de Usuario
**Regla**: El acceso y visibilidad de personas en el sistema depende del rol del usuario autenticado.

**Contexto de Negocio**: Proteger información sensible. Un vendedor solo necesita ver clientes para hacer ventas, no debe ver proveedores o transportistas (información estratégica del negocio).

**Lógica de Permisos**:

| Rol de Usuario | Módulo Visible | Puede Ver (filtro de roles) | Puede Gestionar |
|----------------|----------------|---------------------------|-----------------|
| **Vendedor**   | "Clientes"     | Solo personas con rol `cliente` | Registrar/editar clientes |
| **Gerente**    | "Personas"     | Personas con rol `cliente` o `proveedor` | Registrar/editar clientes y proveedores |
| **Admin**      | "Personas"     | Todas las personas (todos los roles) | CRUD completo en todas las personas |

**Validaciones**:
- ✅ **Vendedor intenta acceder a `/personas?rol=proveedor`** → Rechazar (403 Forbidden)
- ✅ **Gerente intenta ver transportistas** → Rechazar (403 Forbidden)
- ✅ **Admin puede ver, crear, editar, eliminar cualquier persona con cualquier rol**
- ✅ Al registrar una persona, el sistema asigna automáticamente el rol según el contexto:
  - Vendedor registra → automáticamente rol `cliente`
  - Gerente desde "Proveedores" → automáticamente rol `proveedor`
  - Admin puede asignar manualmente múltiples roles

**Casos de Negocio**:
- Vendedor registra "Pedro López DNI 11223344" → Sistema crea persona con rol `cliente`
- Gerente busca "Pedro López" en módulo "Clientes" → Lo encuentra
- Gerente busca "Pedro López" en módulo "Proveedores" → No lo encuentra (no tiene ese rol)
- Admin asigna rol `proveedor` a "Pedro López" → Ahora aparece en ambos filtros

---

### RN-003: Navegación Contextual desde Menú "Personas"
**Regla**: Al hacer clic en una opción del menú "Personas", se debe navegar a la vista correspondiente con filtros pre-aplicados según el rol seleccionado.

**Contexto de Negocio**: Evitar que el usuario tenga que filtrar manualmente cada vez. Si hace clic en "Ver Clientes", debe mostrar solo clientes directamente.

**Lógica de Navegación**:

**Para Admin**:
- **"Registrar persona/documento"** → `/personas/registrar` (sin rol pre-seleccionado, permite elegir)
- **"Base de datos completa"** → `/personas` (sin filtro, muestra todas)
- **"Ver clientes"** → `/personas?rol=cliente` (filtro pre-aplicado)
- **"Ver proveedores"** → `/personas?rol=proveedor` (filtro pre-aplicado)
- **"Ver transportistas"** → `/personas?rol=transportista` (filtro pre-aplicado)

**Para Gerente**:
- **"Registrar persona"** → `/personas/registrar?rol=cliente` (pre-selecciona cliente por defecto)
- **"Clientes"** → `/personas?rol=cliente`
- **"Proveedores"** → `/personas?rol=proveedor`

**Para Vendedor**:
- **"Registrar cliente"** → `/clientes/registrar` (interfaz simplificada, solo campos de cliente)
- **"Base de datos de clientes"** → `/clientes` (alias de `/personas?rol=cliente`, pero UI simplificada)

**Validaciones**:
- ✅ Los filtros pre-aplicados deben ser **editables** por el usuario en la vista destino
- ✅ Si el usuario cambia el filtro a un rol que no tiene permiso → Sistema rechaza
- ✅ URL con parámetros `?rol=xxx` debe validar permisos del usuario
- ✅ Breadcrumbs debe reflejar el contexto: "Personas > Clientes" o "Personas > Proveedores"

**Casos de Negocio**:
- Admin hace clic en "Ver transportistas" → Navega a `/personas?rol=transportista`, ve lista filtrada
- Admin cambia filtro a "Todos" → Ve todas las personas
- Gerente hace clic en "Clientes" → Navega a `/personas?rol=cliente`, ve solo clientes de su tienda
- Vendedor hace clic en "Base de datos de clientes" → Ve interfaz simplificada con solo clientes

---

### RN-004: Búsqueda de Personas por Documento o Nombre
**Regla**: El sistema debe permitir buscar personas por cualquier documento registrado o por nombre completo, respetando permisos de rol.

**Contexto de Negocio**: Un vendedor puede buscar a un cliente por su DNI o RUC indistintamente. Si el cliente tiene ambos documentos, debe encontrarlo con cualquiera.

**Lógica de Búsqueda**:
```sql
SELECT p.*
FROM personas p
LEFT JOIN personas_documentos pd ON p.id = pd.persona_id
LEFT JOIN personas_roles pr ON p.id = pr.persona_id
WHERE (
  p.nombre_completo ILIKE '%{query}%'
  OR pd.numero_documento ILIKE '%{query}%'
)
AND pr.rol IN ({roles_permitidos_para_usuario})
AND pr.activo = true
```

**Validaciones**:
- ✅ Buscar "12345678" → Encuentra a Juan Pérez (tiene DNI 12345678)
- ✅ Buscar "20123456789" → Encuentra a Juan Pérez (tiene RUC 20123456789)
- ✅ Buscar "Juan" → Encuentra a Juan Pérez + Juan López + cualquier "Juan"
- ✅ **Vendedor busca "20123456789"** → Si es cliente, lo encuentra; si es proveedor, NO lo encuentra
- ✅ Búsqueda debe ser **case-insensitive** (mayúsculas/minúsculas)
- ✅ Mostrar en resultados: nombre, documento principal, roles activos

**Casos de Negocio**:
- Cliente "María García" tiene DNI 11223344 y RUC 20112233441
- Vendedor busca "11223344" → Encuentra a María (es cliente)
- Vendedor busca "20112233441" → Encuentra a María (es cliente, mismo registro)
- Gerente busca "María" → Encuentra a María con sus 2 documentos y sus roles (cliente, proveedor)

---

### RN-005: Registro de Persona con Validación de Documento Único
**Regla**: No se pueden registrar dos personas con el mismo número de documento, incluso si el tipo de documento es diferente.

**Contexto de Negocio**: El documento (DNI, RUC, etc.) es la identidad única de una persona. Si el sistema permite duplicados, habrá inconsistencias (ventas a la persona A registradas en persona B).

**Lógica**:
- Al intentar registrar un nuevo documento, validar:
  ```sql
  SELECT COUNT(*) FROM personas_documentos
  WHERE numero_documento = '{nuevo_documento}'
  ```
- Si `COUNT > 0` → **Rechazar registro** con mensaje:
  - "El documento {numero} ya está registrado para {nombre_persona}. ¿Deseas agregar un nuevo documento a esta persona?"

**Validaciones**:
- ✅ Documento debe ser único a nivel global (no solo por tipo)
- ✅ Al agregar un segundo documento a una persona existente, validar:
  - ✅ Tipo de documento diferente (no puede tener 2 DNIs)
  - ✅ Si ya tiene 3+ documentos → advertir (caso inusual)
- ✅ Permitir agregar roles adicionales a persona existente sin duplicar registro

**Casos de Negocio**:
- **Caso 1**: Vendedor intenta registrar cliente "Juan Pérez DNI 12345678"
  - Sistema valida: DNI 12345678 no existe → ✅ Registra nueva persona
- **Caso 2**: Gerente intenta registrar proveedor "Juan Pérez RUC 20123456789"
  - Sistema valida: RUC no existe → ✅ Registra (podría ser misma persona, pero diferente documento)
- **Caso 3**: Admin intenta agregar RUC 20123456789 a Juan Pérez (que ya tiene DNI 12345678)
  - Sistema valida: RUC no existe → ✅ Agrega documento a persona existente
- **Caso 4**: Vendedor intenta registrar "María López DNI 11223344" pero ya existe
  - Sistema rechaza → Muestra "DNI 11223344 ya registrado para María García. ¿Es la misma persona?"

---

### RN-006: Menú Adaptativo según Permisos del Usuario
**Regla**: El sidebar solo debe mostrar opciones a las que el usuario tiene acceso según su rol y permisos asignados.

**Contexto de Negocio**: Evitar confusión del usuario. Si un vendedor no puede gestionar proveedores, no debe ver esa opción en el menú.

**Lógica**:
- El backend debe exponer un endpoint `GET /api/user/menu_options` que devuelva JSON:
  ```json
  {
    "role": "vendedor",
    "menu": [
      {"label": "Dashboard", "icon": "dashboard", "route": "/dashboard"},
      {"label": "Clientes", "icon": "people", "route": "/clientes", "children": [
        {"label": "Registrar cliente", "route": "/clientes/registrar"},
        {"label": "Base de datos", "route": "/clientes"}
      ]}
    ]
  }
  ```

**Validaciones**:
- ✅ Si el usuario tiene rol `vendedor` → No incluir "Personas > Proveedores" en JSON
- ✅ Si el usuario tiene permiso especial "ver_reportes_globales" → Incluir opción adicional
- ✅ Frontend debe renderizar SOLO las opciones devueltas por el backend (no hardcodear menús)
- ✅ Si usuario intenta navegar manualmente a URL no permitida → Backend rechaza con 403

**Casos de Negocio**:
- Vendedor autenticado → Backend devuelve menú con "Clientes", sin "Personas"
- Gerente autenticado → Backend devuelve menú con "Personas > Clientes/Proveedores"
- Admin autenticado → Backend devuelve menú completo con todas las opciones

---

## 🔗 RELACIONES CON OTRAS HISTORIAS

- **Depende de**: E001-HU-001 (Login), E003-HU-001 (Dashboard)
- **Bloquea**: Todas las HUs de gestión (Productos, Ventas, Inventario) - necesitan navegación funcional
- **Relacionada con**: E002-HU-001 a HU-004 (Gestión de Marcas, Materiales, Tipos, Tallas) - dependen de este módulo de navegación
