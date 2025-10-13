import 'package:flutter/material.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_filter_model.dart';

class ProductoMaestroFilterWidget extends StatefulWidget {
  final Function(ProductoMaestroFilterModel) onFilterChanged;

  const ProductoMaestroFilterWidget({super.key, required this.onFilterChanged});

  @override
  State<ProductoMaestroFilterWidget> createState() => _ProductoMaestroFilterWidgetState();
}

class _ProductoMaestroFilterWidgetState extends State<ProductoMaestroFilterWidget> {
  String? _marcaId;
  String? _materialId;
  String? _tipoId;
  String? _sistemaId;
  bool? _activo;
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: ExpansionTile(
        title: const Text('Filtros', style: TextStyle(fontWeight: FontWeight.w600)),
        initiallyExpanded: isDesktop,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Buscar',
                          hintText: 'Nombre, descripción...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (v) {
                          _searchText = v;
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<bool?>(
                        value: _activo,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(value: true, child: Text('Activos')),
                          DropdownMenuItem(value: false, child: Text('Inactivos')),
                        ],
                        onChanged: (v) {
                          setState(() => _activo = v);
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    widget.onFilterChanged(ProductoMaestroFilterModel(
      marcaId: _marcaId,
      materialId: _materialId,
      tipoId: _tipoId,
      sistemaTallaId: _sistemaId,
      activo: _activo,
      searchText: _searchText.isEmpty ? null : _searchText,
    ));
  }
}
