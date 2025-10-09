import 'package:flutter/material.dart';

class ColorSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const ColorSearchBar({
    Key? key,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o código hexadecimal...',
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF6B7280),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
