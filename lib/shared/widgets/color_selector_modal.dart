import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/core/theme/design_tokens.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_state.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';

class ColorSelectorModal extends StatefulWidget {
  final Function(List<String> coloresIds, double precio) onColorsSelected;

  const ColorSelectorModal({
    super.key,
    required this.onColorsSelected,
  });

  @override
  State<ColorSelectorModal> createState() => _ColorSelectorModalState();
}

class _ColorSelectorModalState extends State<ColorSelectorModal> {
  final List<ColorModel> _selectedColors = [];
  final _precioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  String _getTipoColoracion() {
    switch (_selectedColors.length) {
      case 1:
        return 'Unicolor';
      case 2:
        return 'Bicolor';
      case 3:
        return 'Tricolor';
      default:
        return 'Selecciona 1-3 colores';
    }
  }

  Color _parseHexColor(String hexCode) {
    final hex = hexCode.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _toggleColor(ColorModel color) {
    setState(() {
      if (_selectedColors.any((c) => c.id == color.id)) {
        _selectedColors.removeWhere((c) => c.id == color.id);
      } else {
        if (_selectedColors.length < 3) {
          _selectedColors.add(color);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Máximo 3 colores permitidos'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _moveColor(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedColors.removeAt(oldIndex);
      _selectedColors.insert(newIndex, item);
    });
  }

  void _submitSelection() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un color'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final precio = double.parse(_precioController.text);
    final coloresIds = _selectedColors.map((c) => c.id).toList();
    widget.onColorsSelected(coloresIds, precio);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DesignColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.md),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(DesignSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: DesignSpacing.lg),
                  _buildColorSelection(),
                  const SizedBox(height: DesignSpacing.lg),
                  _buildTypeIndicator(),
                  if (_selectedColors.isNotEmpty) ...[
                    const SizedBox(height: DesignSpacing.lg),
                    _buildReorderSection(),
                  ],
                  const SizedBox(height: DesignSpacing.lg),
                  _buildPrecioField(),
                  const SizedBox(height: DesignSpacing.xl),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Selecciona Colores (1-3)',
          style: TextStyle(
            fontSize: DesignTypography.fontLg,
            fontWeight: DesignTypography.bold,
            color: DesignColors.textPrimary,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Cerrar',
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    return BlocBuilder<ColoresBloc, ColoresState>(
      builder: (context, state) {
        if (state is ColoresLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is! ColoresLoaded) {
          return const Center(
            child: Text('No se pudieron cargar los colores'),
          );
        }

        final coloresActivos = state.colores.where((c) => c.activo).toList();

        return Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            border: Border.all(color: DesignColors.border),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: coloresActivos.length,
            itemBuilder: (context, index) {
              final color = coloresActivos[index];
              final isSelected = _selectedColors.any((c) => c.id == color.id);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (_) => _toggleColor(color),
                title: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _parseHexColor(color.codigoHexPrimario),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: DesignColors.border,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignSpacing.sm),
                    Text(color.nombre),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTypeIndicator() {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: _selectedColors.isEmpty
            ? DesignColors.warning.withValues(alpha: 0.1)
            : DesignColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Row(
        children: [
          Icon(
            _selectedColors.isEmpty ? Icons.info : Icons.check_circle,
            color: _selectedColors.isEmpty ? DesignColors.warning : DesignColors.info,
            size: 20,
          ),
          const SizedBox(width: DesignSpacing.sm),
          Text(
            '${_selectedColors.length} color${_selectedColors.length != 1 ? 'es' : ''} seleccionado${_selectedColors.length != 1 ? 's' : ''} → ${_getTipoColoracion()}',
            style: TextStyle(
              fontSize: DesignTypography.fontSm,
              fontWeight: DesignTypography.medium,
              color: DesignColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reordenar (arrastra para cambiar orden):',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            fontWeight: DesignTypography.semibold,
            color: DesignColors.textPrimary,
          ),
        ),
        const SizedBox(height: DesignSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: DesignColors.border),
            borderRadius: BorderRadius.circular(DesignRadius.sm),
          ),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedColors.length,
            onReorder: _moveColor,
            itemBuilder: (context, index) {
              final color = _selectedColors[index];
              return ListTile(
                key: ValueKey(color.id),
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _parseHexColor(color.codigoHexPrimario),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DesignColors.border,
                      width: 2,
                    ),
                  ),
                ),
                title: Text('${index + 1}. ${color.nombre}'),
                trailing: const Icon(Icons.drag_handle),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrecioField() {
    return TextFormField(
      controller: _precioController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Precio de Venta *',
        prefixText: '\$ ',
        filled: true,
        fillColor: Colors.white,
        helperText: 'Precio debe ser mayor a 0',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: DesignColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: DesignColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: DesignColors.accent, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: DesignColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: DesignColors.error, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.md,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Precio es obligatorio';
        }
        final precio = double.tryParse(value);
        if (precio == null || precio <= 0) {
          return 'Precio debe ser mayor a 0';
        }
        return null;
      },
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.lg,
              vertical: DesignSpacing.md,
            ),
          ),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: DesignSpacing.md),
        ElevatedButton(
          onPressed: _submitSelection,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.lg,
              vertical: DesignSpacing.md,
            ),
          ),
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
