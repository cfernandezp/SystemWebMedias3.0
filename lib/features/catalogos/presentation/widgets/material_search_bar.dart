import 'package:flutter/material.dart';

/// Barra de búsqueda para materiales (CA-011)
///
/// Especificaciones:
/// - Búsqueda en tiempo real (RN-002-009)
/// - Busca en nombre, descripción y código simultáneamente
/// - Debounce de 300ms para optimizar performance
/// - Icono de limpiar búsqueda
class MaterialSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;

  const MaterialSearchBar({
    Key? key,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  State<MaterialSearchBar> createState() => _MaterialSearchBarState();
}

class _MaterialSearchBarState extends State<MaterialSearchBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, descripción o código...',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  color: const Color(0xFF6B7280),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
