import 'package:flutter/material.dart';

/// Checkbox personalizado para la funcionalidad "Recordarme" (HU-002)
///
/// Especificaciones:
/// - Tamaño fijo: 24x24px para touch target
/// - Color corporativo: primaryTurquoise cuando activo
/// - Tap en label: GestureDetector para mejor UX
/// - Disabled state: onChanged: null deshabilita
class RememberMeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const RememberMeCheckbox({
    Key? key,
    required this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onChanged != null ? () => onChanged!(!value) : null,
            child: Text(
              'Recordarme',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280), // textSecondary
              ),
            ),
          ),
        ),
      ],
    );
  }
}
