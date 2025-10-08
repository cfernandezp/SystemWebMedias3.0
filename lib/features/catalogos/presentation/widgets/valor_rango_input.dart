import 'package:flutter/material.dart';

/// Input especializado para rangos numéricos (NUMERO y RANGO)
///
/// Validaciones:
/// - Formato "N-M" válido
/// - Primer número < segundo número
/// - Solo números enteros positivos
class ValorRangoInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onDelete;

  const ValorRangoInput({
    Key? key,
    required this.controller,
    this.onDelete,
  }) : super(key: key);

  String? _validateRangeFormat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valor requerido';
    }

    final rangeRegex = RegExp(r'^\d+-\d+$');
    if (!rangeRegex.hasMatch(value)) {
      return 'Formato inválido. Use N-M (ej: 35-36)';
    }

    final parts = value.split('-');
    final start = int.tryParse(parts[0]);
    final end = int.tryParse(parts[1]);

    if (start == null || end == null) {
      return 'Los valores deben ser números enteros';
    }

    if (start >= end) {
      return 'El primer número debe ser menor que el segundo';
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
            decoration: InputDecoration(
              labelText: 'Rango',
              hintText: 'Ej: 35-36',
              prefixIcon: const Icon(Icons.numbers),
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
            validator: _validateRangeFormat,
          ),
        ),
        if (onDelete != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFF44336)),
            onPressed: onDelete,
            tooltip: 'Eliminar rango',
          ),
        ],
      ],
    );
  }
}
