# Design Tokens - Sistema Venta Medias

**Estado**: 🎨 Especificación de Diseño
**Tema Activo**: Turquesa Moderno Retail (Default)
**Última actualización**: 2025-10-04

---

## 🎨 TEMA DEFAULT: TURQUESA MODERNO RETAIL

### IDENTIDAD VISUAL
Turquesa Moderno Retail - Sistema corporativo para venta de medias multi-tienda

---

## PALETA DE COLORES

### Colores Principales
```dart
static const Color primaryTurquoise = Color(0xFF4ECDC4);   // Color corporativo principal
static const Color primaryLight = Color(0xFF7DEDE8);       // Variante clara para hover/highlights
static const Color primaryDark = Color(0xFF26A69A);        // Variante oscura para contraste
static const Color secondary = Color(0xFF45B7AA);          // Color secundario
static const Color accent = Color(0xFF96E6B3);             // Color de acento verde menta
```

### Colores de Estado
```dart
static const Color success = Color(0xFF4CAF50);   // Verde para operaciones exitosas
static const Color error = Color(0xFFF44336);     // Rojo para errores y alertas
static const Color warning = Color(0xFFFF9800);   // Naranja para advertencias
static const Color info = Color(0xFF2196F3);      // Azul para información
```

### Colores de Superficie
```dart
static const Color backgroundLight = Color(0xFFF9FAFB);   // Fondo general claro
static const Color cardWhite = Color(0xFFFFFFFF);         // Fondo de tarjetas
static const Color textPrimary = Color(0xFF1A1A1A);       // Texto principal oscuro
static const Color textSecondary = Color(0xFF6B7280);     // Texto secundario gris
```

### Tema Oscuro (Para desarrollo futuro)
```dart
static const Color darkBackground = Color(0xFF121212);
static const Color darkSurface = Color(0xFF1E1E1E);
static const Color darkText = Color(0xFFE0E0E0);
```

---

## FORMAS Y GEOMETRÍA

### Border Radius Estándar
```dart
class DesignRadius {
  static const double cards = 12.0;              // Bordes suavemente redondeados
  static const double buttons = 8.0;             // Bordes sutiles para botones
  static const double formFields = 28.0;         // Super redondeados (pill-shaped)
  static const double dialogsModals = 12.0;      // Consistente con cards
  static const double errorContainers = 6.0;     // Bordes mínimos para mensajes
}
```

### Dimensiones Estándar
```dart
class DesignDimensions {
  static const double buttonHeight = 52.0;           // Alto estándar para botones principales
  static const double formFieldHeight = 48.0;        // Alto aproximado con padding
  static const double cardPadding = 16.0;            // Espaciado interno consistente
  static const double sectionSpacing = 16.0;         // Espaciado entre elementos
}
```

---

## SOMBRAS Y ELEVACIONES

### Elevaciones Material 3
```dart
class DesignElevation {
  static const double cards = 2.0;              // Sombra sutil para separación
  static const double buttonsPrimary = 3.0;     // Sombra media para CTAs
  static const double buttonsSecondary = 0.0;   // Sin sombra para botones outline
  static const double appBar = 2.0;             // Sombra sutil en header
  static const double hoverState = 8.0;         // Sombra pronunciada en hover
}
```

### Shadow Colors
```dart
// Sombra con tinte turquesa
static BoxShadow primaryShadow = BoxShadow(
  color: primaryTurquoise.withOpacity(0.4),
  blurRadius: 8.0,
  offset: Offset(0, 2),
);

// Sombra neutral suave
static BoxShadow cardShadow = BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8.0,
  offset: Offset(0, 2),
);
```

---

## TIPOGRAFÍA

### Jerarquía de Texto
```dart
class DesignTextStyle {
  // Títulos principales
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF26A69A),  // primaryDark
  );

  // Títulos de sección
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: Color(0xFF26A69A),  // primaryDark
  );

  // Texto principal
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  // Texto secundario
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  // Texto en botones
  static const TextStyle buttonText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );

  // Etiquetas de formulario
  static const TextStyle labelText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6B7280),  // textSecondary
  );
}
```

### Pesos de Fuente
```dart
class DesignFontWeight {
  static const FontWeight bold = FontWeight.w700;       // 700
  static const FontWeight semiBold = FontWeight.w600;   // 600
  static const FontWeight medium = FontWeight.w500;     // 500
  static const FontWeight regular = FontWeight.w400;    // 400
}
```

---

## COMPONENTES CORPORATIVOS

### CorporateButton

**Especificaciones:**
- Altura estándar: `52px`
- Border radius: `8px`
- Padding horizontal: `24px`

**Estados:**
```dart
// Primary
background: primaryTurquoise (#4ECDC4)
text: white
elevation: 3

// Secondary
background: transparent
border: 2px solid primaryTurquoise
text: primaryTurquoise
elevation: 0

// Loading
shimmer effect + dots animation

// Hover
overlay: white 10% opacity

// Pressed
overlay: white 20% opacity
```

---

### CorporateFormField

**Especificaciones:**
- Border radius: `28px` (pill-shaped)
- Fill color: Blanco (tema claro) / Gris 800 (tema oscuro)
- Padding: `16px` horizontal/vertical

**Animaciones:**
```dart
// Focus
duration: 200ms
transform: scale(1.02)
iconColor: grey → primaryTurquoise (#4ECDC4)
borderWidth: 1.5px → 2.5px
```

**Estados:**
```dart
// Normal
border: 1.5px solid #E5E7EB (gris)

// Focus
border: 2.5px solid #6366F1 (azul/morado)

// Error
border: 2.5px solid #F44336 (rojo)

// Disabled
background: #F3F4F6 (gris claro)
```

---

### Cards

**Especificaciones:**
```dart
elevation: 2
borderRadius: 12px
background: #FFFFFF
padding: 16px

// Hover effect
duration: 200ms
transform: scale(1.02)
elevation: 8
```

---

## RESPONSIVE BREAKPOINTS

### Breakpoints Obligatorios
```dart
class DesignBreakpoints {
  static const double mobile = 768.0;
  static const double tablet = 1200.0;
  static const double desktop = 1200.0;
}
```

### Mobile (< 768px)
- Navegación: Drawer oculto + BottomNavigation
- Grid: 1 columna
- Touch targets: Mínimo 44px

### Tablet (768px - 1200px)
- Navegación: NavigationRail colapsible (Material 3)
- Grid: 2 columnas
- Interacciones: Touch + hover hybrid

### Desktop (≥ 1200px)
- Navegación: Sidebar fijo expandido con toggle
- Grid: 3 columnas
- Interacciones: Mouse + keyboard shortcuts

---

## MICRO-INTERACCIONES

### Duraciones Estándar
```dart
class DesignDuration {
  static const Duration fast = Duration(milliseconds: 200);      // Hover, focus, ripple
  static const Duration medium = Duration(milliseconds: 300);    // Expansión, collapse
  static const Duration pageTransition = Duration(milliseconds: 350);  // Navegación
}
```

### Curvas de Animación
```dart
class DesignCurves {
  static const Curve standard = Curves.easeInOut;      // Transiciones generales
  static const Curve bounce = Curves.easeOutBack;      // Mensajes de error (bounce effect)
  static const Curve smooth = Curves.easeInOut;        // Animaciones suaves
}
```

### Estados Interactivos
```dart
// Hover
overlay: white 10-20% opacity
transform: scale(1.02) (opcional)

// Pressed
overlay: white 20% opacity
transform: scale(0.98)

// Focus
border: 2.5px
color: accent (#6366F1)

// Loading
shimmer effect + staggered dots animation
```

---

## MENSAJES Y FEEDBACK

### SnackBar Estándar

**Success:**
```dart
background: Color(0xFF4CAF50)  // verde
icon: Icons.check_circle
iconColor: Colors.white
behavior: SnackBarBehavior.floating
borderRadius: 8px
```

**Error:**
```dart
background: Color(0xFFF44336)  // rojo
icon: Icons.error
iconColor: Colors.white
behavior: SnackBarBehavior.floating
borderRadius: 8px
```

### Error Container (formularios)
```dart
background: Colors.red[50]
border: 1px solid Colors.red[200]
icon: Icons.error_outline
iconColor: Colors.red[600]
borderRadius: 6px
```

---

## 🔮 FUTUROS TEMAS (Desarrollo posterior)

### Arquitectura para Temas Dinámicos

**Estructura preparada:**
```dart
abstract class AppTheme {
  Color get primary;
  Color get primaryLight;
  Color get primaryDark;
  Color get secondary;
  Color get accent;
  // ... resto de colores
}

class TurquoiseTheme implements AppTheme {
  // Tema actual (default)
}

class DarkTheme implements AppTheme {
  // Para desarrollo futuro
}

class BlueTheme implements AppTheme {
  // Para desarrollo futuro
}

class OrangeTheme implements AppTheme {
  // Para desarrollo futuro
}
```

**Temas planificados:**
- ✅ Turquoise (Activo)
- ⏳ Dark Mode
- ⏳ Blue Theme
- ⏳ Orange Theme
- ⏳ Custom Theme Builder

**Pantalla de configuración futura:**
- Selector de tema activo
- Preview en tiempo real
- Creación de temas personalizados

---

## 📋 REGLAS DE IMPLEMENTACIÓN

### ✅ CORRECTO (Theme-aware)
```dart
// Siempre usa Theme.of(context)
color: Theme.of(context).colorScheme.primary
color: Theme.of(context).colorScheme.error

// O usa los tokens definidos
color: DesignTokens.primaryTurquoise
```

### ❌ INCORRECTO (Hardcoded)
```dart
// NUNCA hardcodees colores directamente
color: Color(0xFF4ECDC4)  // ❌ No escalable para temas
color: Colors.blue         // ❌ Rompe identidad visual
```

### Implementación en Flutter
```dart
// Todos los componentes deben ser theme-aware desde el inicio
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.primary,  // ✅ Preparado para cambio de tema
    );
  }
}
```

---

## 📦 PROMPT PARA AGENTES IA

**SISTEMA DE DISEÑO RETAIL MANAGER - ESPECIFICACIONES OBLIGATORIAS**

**PALETA:**
- Primary: #4ECDC4 (turquesa corporativo)
- Success: #4CAF50 | Error: #F44336 | Warning: #FF9800
- Backgrounds: #F9FAFB (light), #FFFFFF (cards)

**GEOMETRÍA:**
- Buttons: 52px altura, 8px radius
- Form Fields: 28px radius (pill-shaped)
- Cards: 12px radius, 16px padding
- Spacing: 16px estándar

**ELEVACIONES:**
- Cards: elevation 2
- Buttons primary: elevation 3
- Hover: elevation 8

**COMPONENTES:**
- CorporateButton: 52px, 8px radius, shimmer loading
- CorporateFormField: 28px radius, animación 200ms focus
- Cards: 12px radius, hover scale 1.02

**RESPONSIVE:**
- Desktop ≥1200px: Sidebar fijo, grid 3 cols
- Tablet 768-1199px: NavigationRail, grid 2 cols
- Mobile <768px: Drawer + BottomNav, grid 1 col

**ANIMACIONES:**
- Duración: 200ms (micro), 300ms (transiciones)
- Hover: Overlay blanco 10%, scale 1.02
- Focus: Border 2.5px, color #6366F1

**CRITERIO OBLIGATORIO:**
Mantener identidad turquesa moderna en TODA implementación.
SIEMPRE usar `Theme.of(context)` o `DesignTokens`, NUNCA hardcodear colores.

---

## 🔄 ACTUALIZACIÓN POR AGENTES

### @web-architect-expert
Al diseñar nuevas features, referencia estos tokens en:
- `docs/technical/design/components.md`
- Especificaciones de páginas nuevas

### @ux-ui-expert
Al implementar componentes:
- Lee este archivo ANTES de implementar
- Actualiza con código Dart final si hay nuevos componentes
- Mantén consistencia con tokens definidos
- SIEMPRE implementa theme-aware (usa `Theme.of(context)`)

### @flutter-expert
Al implementar lógica de negocio:
- Conoce la existencia de estos tokens
- No hardcodees colores en repositories/use cases
- Si necesitas colores, usa `DesignTokens`
