import 'package:flutter/material.dart';

/// Barra de búsqueda para tipos (CA-011)
///
/// Especificaciones:
/// - Búsqueda en tiempo real
/// - Placeholder: "Buscar por nombre, descripción o código..."
/// - Icono de búsqueda y limpiar
class TipoSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;

  const TipoSearchBar({
    Key? key,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  State<TipoSearchBar> createState() => _TipoSearchBarState();
}

class _TipoSearchBarState extends State<TipoSearchBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: _searchController,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, descripción o código...',
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: theme.colorScheme.primary,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                onPressed: () {
                  _searchController.clear();
                  widget.onSearchChanged('');
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
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
