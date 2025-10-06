import 'package:flutter/material.dart';

/// Niveles de fortaleza de contraseña (HU-004)
enum PasswordStrength {
  weak,
  medium,
  strong,
}

/// Indicador visual de fortaleza de contraseña
///
/// Especificaciones HU-004:
/// - Barra de progreso con colores (rojo/amarillo/verde)
/// - Validación en tiempo real
/// - Criterios: longitud, mayúscula, minúscula, número
///
/// Reglas:
/// - Débil: < 8 caracteres
/// - Media: 8+ caracteres + letra + número
/// - Fuerte: 8+ caracteres + mayúscula + minúscula + número
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    Key? key,
    required this.password,
  }) : super(key: key);

  /// Calcula el nivel de fortaleza de la contraseña
  PasswordStrength _calculateStrength() {
    if (password.isEmpty || password.length < 8) {
      return PasswordStrength.weak;
    }

    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    // Fuerte: cumple todos los criterios
    if (hasUppercase && hasLowercase && hasNumber) {
      return PasswordStrength.strong;
    }

    // Media: al menos 8 caracteres + letra + número
    final hasLetter = hasUppercase || hasLowercase;
    if (password.length >= 8 && hasLetter && hasNumber) {
      return PasswordStrength.medium;
    }

    return PasswordStrength.weak;
  }

  /// Obtiene el progreso (0.0 - 1.0) según fortaleza
  double _getProgress() {
    switch (_calculateStrength()) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  /// Obtiene el color según fortaleza
  Color _getColor() {
    switch (_calculateStrength()) {
      case PasswordStrength.weak:
        return const Color(0xFFF44336); // Rojo
      case PasswordStrength.medium:
        return const Color(0xFFFFC107); // Amarillo
      case PasswordStrength.strong:
        return const Color(0xFF4CAF50); // Verde
    }
  }

  /// Obtiene el texto descriptivo según fortaleza
  String _getText() {
    switch (_calculateStrength()) {
      case PasswordStrength.weak:
        return 'Débil';
      case PasswordStrength.medium:
        return 'Media';
      case PasswordStrength.strong:
        return 'Fuerte';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = _getColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de progreso
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _getProgress(),
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),

        const SizedBox(height: 8),

        // Texto descriptivo
        Row(
          children: [
            Icon(
              _getStrengthIcon(),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              'Fortaleza: ${_getText()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Criterios de validación
        _buildCriteria(),
      ],
    );
  }

  /// Icono según fortaleza
  IconData _getStrengthIcon() {
    switch (_calculateStrength()) {
      case PasswordStrength.weak:
        return Icons.error_outline;
      case PasswordStrength.medium:
        return Icons.warning_amber_outlined;
      case PasswordStrength.strong:
        return Icons.check_circle_outline;
    }
  }

  /// Lista de criterios de validación con checkmarks
  Widget _buildCriteria() {
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCriteriaItem('Mínimo 8 caracteres', hasMinLength),
        _buildCriteriaItem('Al menos 1 mayúscula', hasUppercase),
        _buildCriteriaItem('Al menos 1 minúscula', hasLowercase),
        _buildCriteriaItem('Al menos 1 número', hasNumber),
      ],
    );
  }

  /// Item individual de criterio
  Widget _buildCriteriaItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: isMet
                ? const Color(0xFF4CAF50)
                : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
