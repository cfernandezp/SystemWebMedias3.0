// Design Tokens - Sistema de Venta de Medias
// Fuente única de verdad para valores de diseño
// NUNCA hardcodear valores en widgets, SIEMPRE usar DesignTokens.*

import 'package:flutter/material.dart';

/// Colores del sistema (Tema Turquesa Moderno Retail)
class DesignColors {
  // Principales
  static const primaryTurquoise = Color(0xFF4ECDC4);
  static const primaryDark = Color(0xFF26A69A);
  static const accent = Color(0xFF6366F1);

  // Estados
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);

  // Neutrales
  static const backgroundLight = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const disabled = Color(0xFF9CA3AF);

  // Hover states
  static const primaryHover = Color(0xFF3DB9B0);
  static const accentHover = Color(0xFF4F52D9);
}

/// Espaciado consistente
class DesignSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Breakpoints para diseño responsive
class DesignBreakpoints {
  static const mobile = 768;
  static const tablet = 1024;
  static const desktop = 1200;
  static const largeDesktop = 1440;

  /// Helper para detectar si es desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Helper para detectar si es mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }
}

/// Border radius consistente
class DesignRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const full = 9999.0; // Circular
}

/// Tipografía
class DesignTypography {
  // Font sizes
  static const fontXs = 12.0;
  static const fontSm = 14.0;
  static const fontMd = 16.0;
  static const fontLg = 18.0;
  static const fontXl = 20.0;
  static const font2xl = 24.0;
  static const font3xl = 30.0;

  // Font weights
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semibold = FontWeight.w600;
  static const bold = FontWeight.w700;
}

/// Elevaciones (sombras)
class DesignElevation {
  static const sm = 2.0;
  static const md = 4.0;
  static const lg = 8.0;
  static const xl = 16.0;
}

/// Duraciones de animaciones
class DesignDuration {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
}
