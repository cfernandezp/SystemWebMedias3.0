# ÉPICA E003: Dashboard y Sistema de Navegación

## 📋 INFORMACIÓN DE LA ÉPICA
- **Código**: E003
- **Nombre**: Dashboard y Sistema de Navegación
- **Descripción**: Interface principal post-login con dashboard de métricas del negocio y sistema de navegación moderno con menús desplegables según rol de usuario
- **Story Points Totales**: 21 pts
- **Estado**: ⚪ Pendiente

## 📚 HISTORIAS DE USUARIO

### E003-HU-001: Dashboard Principal con Métricas
- **Archivo**: `docs/historias-usuario/E003-HU-001-dashboard-metricas.md`
- **Estado**: ⚪ Pendiente
- **Story Points**: 8 pts
- **Prioridad**: Alta

### E003-HU-002: Sistema de Navegación con Menús Desplegables
- **Archivo**: `docs/historias-usuario/E003-HU-002-navegacion-menus.md`
- **Estado**: ⚪ Pendiente
- **Story Points**: 8 pts
- **Prioridad**: Alta

### E003-HU-003: Layout Responsivo y Adaptable
- **Archivo**: `docs/historias-usuario/E003-HU-003-layout-responsivo.md`
- **Estado**: ⚪ Pendiente
- **Story Points**: 5 pts
- **Prioridad**: Media

## 🎯 CRITERIOS DE ACEPTACIÓN DE LA ÉPICA
- [ ] Dashboard muestra métricas relevantes según rol del usuario
- [ ] Sistema de navegación es intuitivo y moderno
- [ ] Menús desplegables muestran opciones específicas por rol
- [ ] Perfil de usuario y logout accesibles desde header
- [ ] Interface es completamente responsiva en todos los dispositivos
- [ ] Transiciones y animaciones son fluidas y profesionales

## 📊 PROGRESO
- Total HU: 3
- ✅ Completadas: 0 (0%)
- 🟡 En Desarrollo: 0 (0%)
- ⚪ Pendientes: 3 (100%)

## 🎨 CONTEXTO DE DISEÑO
Esta épica define la experiencia principal post-login del sistema de venta de medias. El dashboard debe reflejar métricas críticas del retail multi-tienda:

### **Métricas por Rol:**
- **Vendedor**: Ventas del día, comisiones personales, productos en stock de su tienda
- **Gerente**: Dashboard de su tienda (ventas totales, top vendedores, stock bajo, metas mensuales)
- **Admin**: Vista consolidada de todas las tiendas, comparativas, alertas globales

### **Navegación Moderna:**
- Sidebar colapsable con iconos y labels
- Menús desplegables agrupados por funcionalidad
- Header superior con perfil de usuario y logout
- Breadcrumbs para tracking de ubicación
- Acceso rápido a acciones frecuentes

### **Componentes Visuales:**
- Cards con métricas en tiempo real
- Gráficos interactivos (line charts, bar charts)
- Indicadores de tendencias (+12.5%, -3.2%)
- Sistema de colores según estado (verde=positivo, rojo=alerta)
