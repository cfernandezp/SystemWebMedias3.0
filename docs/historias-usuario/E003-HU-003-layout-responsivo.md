# E003-HU-003: Layout Responsivo y Adaptable

## 📋 INFORMACIÓN DE LA HISTORIA
- **Código**: E003-HU-003
- **Épica**: E003 - Dashboard y Sistema de Navegación
- **Título**: Layout Responsivo y Adaptable
- **Story Points**: 5 pts
- **Estado**: 🟡 Borrador
- **Fecha Creación**: 2025-10-05

## 🎯 HISTORIA DE USUARIO
**Como** usuario del sistema accediendo desde diferentes dispositivos
**Quiero** que el dashboard y navegación se adapten a mi pantalla
**Para** tener una experiencia óptima en desktop, tablet y móvil

### Criterios de Aceptación

#### CA-001: Layout en Desktop (>1024px)
- [ ] **DADO** que accedo desde un dispositivo desktop
- [ ] **CUANDO** visualizo el dashboard
- [ ] **ENTONCES** debo ver:
  - [ ] Sidebar expandido por defecto (240px ancho)
  - [ ] Header fijo en la parte superior
  - [ ] Grid de cards de métricas en 4 columnas
  - [ ] Gráficos ocupando 2/3 del ancho
  - [ ] Lista de transacciones en 1/3 del ancho
  - [ ] Todos los elementos visibles sin scroll horizontal

#### CA-002: Layout en Tablet (768px - 1024px)
- [ ] **DADO** que accedo desde un dispositivo tablet
- [ ] **CUANDO** visualizo el dashboard
- [ ] **ENTONCES** debo ver:
  - [ ] Sidebar colapsado por defecto (solo íconos - 64px)
  - [ ] Header fijo con avatar y menú hamburguesa
  - [ ] Grid de cards de métricas en 2 columnas
  - [ ] Gráficos ocupando ancho completo
  - [ ] Lista de transacciones debajo de gráficos
  - [ ] Touch-friendly: elementos con espacio táctil mínimo 44px

#### CA-003: Layout en Móvil (<768px)
- [ ] **DADO** que accedo desde un dispositivo móvil
- [ ] **CUANDO** visualizo el dashboard
- [ ] **ENTONCES** debo ver:
  - [ ] Sidebar oculto por defecto (overlay al abrir)
  - [ ] Header fijo con menú hamburguesa y avatar
  - [ ] Grid de cards de métricas en 1 columna (apiladas)
  - [ ] Gráficos con scroll horizontal si es necesario
  - [ ] Lista de transacciones con scroll vertical
  - [ ] Botones y elementos táctiles de mínimo 48px
  - [ ] Texto legible sin zoom (mínimo 16px)

#### CA-004: Sidebar Responsivo
- [ ] **DADO** que estoy en cualquier dispositivo
- [ ] **CUANDO** hago clic en el botón de menú hamburguesa
- [ ] **ENTONCES** el comportamiento debe ser:
  - [ ] **Desktop**: Sidebar se colapsa/expande in-place (push content)
  - [ ] **Tablet**: Sidebar se colapsa/expande in-place
  - [ ] **Móvil**: Sidebar aparece como overlay con backdrop oscuro
- [ ] **CUANDO** el sidebar está abierto en móvil y hago clic fuera
- [ ] **ENTONCES** el sidebar debe cerrarse automáticamente

#### CA-005: Cards de Métricas Responsivas
- [ ] **DADO** que visualizo cards de métricas en cualquier dispositivo
- [ ] **CUANDO** el tamaño de pantalla cambia
- [ ] **ENTONCES** las cards deben:
  - [ ] **Desktop**: 4 cards por fila
  - [ ] **Tablet**: 2 cards por fila
  - [ ] **Móvil**: 1 card por fila (ancho completo)
  - [ ] Mantener proporción de altura consistente
  - [ ] Textos y números legibles sin truncar

#### CA-006: Gráficos Responsivos
- [ ] **DADO** que visualizo gráficos en diferentes dispositivos
- [ ] **CUANDO** el tamaño de pantalla cambia
- [ ] **ENTONCES** los gráficos deben:
  - [ ] Adaptarse al ancho del contenedor
  - [ ] Mantener legibilidad de ejes y labels
  - [ ] **Móvil**: Mostrar scroll horizontal si hay muchos datos
  - [ ] Leyendas posicionadas correctamente (arriba en móvil, derecha en desktop)
  - [ ] Tooltips táctiles en dispositivos touch

#### CA-007: Header Responsivo
- [ ] **DADO** que visualizo el header en diferentes dispositivos
- [ ] **CUANDO** el tamaño de pantalla cambia
- [ ] **ENTONCES** el header debe:
  - [ ] **Desktop**: Logo + título + breadcrumbs + avatar/nombre
  - [ ] **Tablet**: Menú hamburguesa + título + avatar
  - [ ] **Móvil**: Menú hamburguesa + logo pequeño + avatar
  - [ ] Mantener altura fija: 64px en desktop, 56px en móvil
  - [ ] Dropdown de perfil alineado a la derecha

#### CA-008: Transiciones y Animaciones
- [ ] **DADO** que interactúo con elementos responsivos
- [ ] **CUANDO** cambian de tamaño o posición
- [ ] **ENTONCES** las transiciones deben ser:
  - [ ] Suaves (duración 200-300ms)
  - [ ] Con easing natural (ease-in-out)
  - [ ] Sin lag o flickering
  - [ ] Sidebar: transición de width/transform
  - [ ] Cards: transición de grid layout

#### CA-009: Orientación en Tablet/Móvil
- [ ] **DADO** que estoy en un dispositivo con rotación
- [ ] **CUANDO** cambio de orientación vertical a horizontal
- [ ] **ENTONCES** el layout debe:
  - [ ] Re-organizarse según el nuevo ancho
  - [ ] Mantener scroll position cuando sea posible
  - [ ] **Tablet horizontal**: Comportamiento similar a desktop pequeño
  - [ ] **Móvil horizontal**: Grid de 2 columnas en cards

#### CA-010: Accesibilidad Touch
- [ ] **DADO** que estoy en un dispositivo táctil
- [ ] **CUANDO** interactúo con elementos
- [ ] **ENTONCES** debe cumplir:
  - [ ] Área táctil mínima: 48x48px (WCAG 2.1)
  - [ ] Separación entre elementos: mínimo 8px
  - [ ] Estados hover reemplazados por estados active en touch
  - [ ] Menús desplegables abren con tap, no con hover
  - [ ] Gestos de swipe en sidebar móvil (opcional)

### Estado de Implementación
- [ ] **Backend** - No aplica
  - Esta HU es 100% frontend/UX-UI
- [ ] **Frontend** - Pendiente
  - [ ] MediaQuery utilities para breakpoints
  - [ ] ResponsiveLayout widget wrapper
  - [ ] Sidebar con lógica responsive (drawer en móvil)
  - [ ] Grid adaptable para cards
  - [ ] Chart widgets con responsive sizing
- [ ] **UX/UI** - Pendiente
  - [ ] Definir breakpoints: móvil (<768px), tablet (768-1024px), desktop (>1024px)
  - [ ] Layouts específicos por dispositivo
  - [ ] Sistema de espaciado responsivo
  - [ ] Tipografía escalable (fluid typography)
  - [ ] Touch targets de 48px mínimo
  - [ ] Testing en dispositivos reales
- [ ] **QA** - Pendiente
  - [ ] Tests de todos los criterios de aceptación
  - [ ] Validación en diferentes dispositivos
  - [ ] Tests de rotación de pantalla
  - [ ] Tests de touch interactions
  - [ ] Validación de performance en móviles

### Definición de Terminado (DoD)
- [ ] Todos los criterios de aceptación cumplidos
- [ ] Testeado en Chrome DevTools (responsive mode)
- [ ] Testeado en dispositivos reales (iOS, Android)
- [ ] Sin scroll horizontal en ningún breakpoint
- [ ] Performance 60fps en animaciones
- [ ] UX/UI sigue Design System
- [ ] QA valida todos los flujos
- [ ] Documentación actualizada
