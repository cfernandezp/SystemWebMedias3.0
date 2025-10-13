import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_maestro_filter_model.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_state.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/materiales_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/materiales_state.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/tipos_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/tipos_state.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/sistemas_talla/sistemas_talla_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/sistemas_talla/sistemas_talla_state.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_button.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_form_field.dart';

class ProductoMaestroFilterWidget extends StatefulWidget {
  final ProductoMaestroFilterModel? initialFilters;
  final Function(ProductoMaestroFilterModel) onApplyFilters;

  const ProductoMaestroFilterWidget({
    Key? key,
    this.initialFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<ProductoMaestroFilterWidget> createState() => _ProductoMaestroFilterWidgetState();
}

class _ProductoMaestroFilterWidgetState extends State<ProductoMaestroFilterWidget> {
  final _searchController = TextEditingController();
  String? _marcaId;
  String? _materialId;
  String? _tipoId;
  String? _sistemaTallaId;
  bool? _activo;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _marcaId = widget.initialFilters!.marcaId;
      _materialId = widget.initialFilters!.materialId;
      _tipoId = widget.initialFilters!.tipoId;
      _sistemaTallaId = widget.initialFilters!.sistemaTallaId;
      _activo = widget.initialFilters!.activo;
      _searchController.text = widget.initialFilters!.searchText ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Filtros de búsqueda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          CorporateFormField(
            controller: _searchController,
            label: 'Búsqueda de texto',
            hintText: 'Buscar en descripción o nombres...',
            prefixIcon: Icons.search,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _buildMarcaDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildMaterialDropdown()),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _buildTipoDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildSistemaTallaDropdown()),
            ],
          ),

          const SizedBox(height: 16),

          _buildActivoToggle(),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: CorporateButton(
                  text: 'Limpiar',
                  variant: ButtonVariant.secondary,
                  onPressed: _clearFilters,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CorporateButton(
                  text: 'Aplicar Filtros',
                  onPressed: _applyFilters,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarcaDropdown() {
    return BlocBuilder<MarcasBloc, MarcasState>(
      builder: (context, state) {
        if (state is MarcasLoaded) {
          final marcas = state.filteredMarcas.where((m) => m.activo).toList();
          return _buildDropdown(
            label: 'Marca',
            value: _marcaId,
            items: [
              const DropdownMenuItem(value: null, child: Text('Todas')),
              ...marcas.map((m) => DropdownMenuItem(
                value: m.id,
                child: Text(m.nombre),
              )),
            ],
            onChanged: (value) => setState(() => _marcaId = value),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMaterialDropdown() {
    return BlocBuilder<MaterialesBloc, MaterialesState>(
      builder: (context, state) {
        if (state is MaterialesLoaded) {
          final materiales = state.materiales.where((m) => m.activo).toList();
          return _buildDropdown(
            label: 'Material',
            value: _materialId,
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ...materiales.map((m) => DropdownMenuItem(
                value: m.id,
                child: Text(m.nombre),
              )),
            ],
            onChanged: (value) => setState(() => _materialId = value),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTipoDropdown() {
    return BlocBuilder<TiposBloc, TiposState>(
      builder: (context, state) {
        if (state is TiposLoaded) {
          final tipos = state.tipos.where((t) => t.activo).toList();
          return _buildDropdown(
            label: 'Tipo',
            value: _tipoId,
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ...tipos.map((t) => DropdownMenuItem(
                value: t.id,
                child: Text(t.nombre),
              )),
            ],
            onChanged: (value) => setState(() => _tipoId = value),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSistemaTallaDropdown() {
    return BlocBuilder<SistemasTallaBloc, SistemasTallaState>(
      builder: (context, state) {
        if (state is SistemasTallaLoaded) {
          final sistemas = state.sistemas.where((s) => s.activo).toList();
          return _buildDropdown(
            label: 'Sistema Tallas',
            value: _sistemaTallaId,
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ...sistemas.map((s) => DropdownMenuItem(
                value: s.id,
                child: Text(s.nombre),
              )),
            ],
            onChanged: (value) => setState(() => _sistemaTallaId = value),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(8),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivoToggle() {
    return Row(
      children: [
        const Text(
          'Estado:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: _activo == null,
                onSelected: (selected) {
                  if (selected) setState(() => _activo = null);
                },
              ),
              ChoiceChip(
                label: const Text('Activos'),
                selected: _activo == true,
                onSelected: (selected) {
                  if (selected) setState(() => _activo = true);
                },
              ),
              ChoiceChip(
                label: const Text('Inactivos'),
                selected: _activo == false,
                onSelected: (selected) {
                  if (selected) setState(() => _activo = false);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _marcaId = null;
      _materialId = null;
      _tipoId = null;
      _sistemaTallaId = null;
      _activo = null;
      _searchController.clear();
    });
  }

  void _applyFilters() {
    final filtros = ProductoMaestroFilterModel(
      marcaId: _marcaId,
      materialId: _materialId,
      tipoId: _tipoId,
      sistemaTallaId: _sistemaTallaId,
      activo: _activo,
      searchText: _searchController.text.isEmpty ? null : _searchController.text,
    );
    widget.onApplyFilters(filtros);
  }
}
