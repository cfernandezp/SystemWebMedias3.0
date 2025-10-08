import 'package:flutter/material.dart';

/// Input especializado para tallas alfabéticas (LETRA)
///
/// Validaciones:
/// - Solo letras (A-Z, a-z)
/// - No duplicados (validación externa)
class ValorLetrasInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onDelete;

  const ValorLetrasInput({
    Key? key,
    required this.controller,
    this.onDelete,
  }) : super(key: key);

  String? _validateLettersOnly(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valor requerido';
    }

    final lettersRegex = RegExp(r'^[a-zA-Z]+$');
    if (!lettersRegex.hasMatch(value)) {
      return 'Solo se permiten letras (A-Z)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Talla',
              hintText: 'Ej: XS, S, M, L',
              prefixIcon: const Icon(Icons.text_fields),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFF44336), width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Color(0xFFF44336), width: 2),
              ),
            ),
            validator: _validateLettersOnly,
          ),
        ),
        if (onDelete != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFF44336)),
            onPressed: onDelete,
            tooltip: 'Eliminar talla',
          ),
        ],
      ],
    );
  }
}
