import 'package:flutter/material.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/color_preview_circle.dart';

class ColorSelectorWidget extends StatefulWidget {
  final List<ColorModel> coloresDisponibles;
  final List<String> coloresSeleccionados;
  final String? descripcionVisual;
  final ValueChanged<List<String>> onColoresChanged;
  final ValueChanged<String?>? onDescripcionChanged;

  const ColorSelectorWidget({
    Key? key,
    required this.coloresDisponibles,
    required this.coloresSeleccionados,
    this.descripcionVisual,
    required this.onColoresChanged,
    this.onDescripcionChanged,
  }) : super(key: key);

  @override
  State<ColorSelectorWidget> createState() => _ColorSelectorWidgetState();
}

class _ColorSelectorWidgetState extends State<ColorSelectorWidget> {
  bool _esUnicolor = true;
  List<String> _selectedColors = [];
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedColors = List.from(widget.coloresSeleccionados);
    _esUnicolor = _selectedColors.length <= 1;
    _descripcionController.text = widget.descripcionVisual ?? '';
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTipoSelector(),
        const SizedBox(height: 16),
        if (_esUnicolor) _buildUnicolorSelector() else _buildMulticolorSelector(),
        const SizedBox(height: 16),
        _buildPreview(),
        if (!_esUnicolor && _selectedColors.length >= 2) ...[
          const SizedBox(height: 16),
          _buildDescripcionVisualField(),
        ],
      ],
    );
  }

  Widget _buildTipoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _esUnicolor = true;
                    if (_esUnicolor && _selectedColors.length > 1) {
                      _selectedColors = [_selectedColors.first];
                      widget.onColoresChanged(_selectedColors);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _esUnicolor
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _esUnicolor
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _esUnicolor ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: _esUnicolor
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      const Text('Unicolor'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _esUnicolor = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: !_esUnicolor
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: !_esUnicolor
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        !_esUnicolor ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: !_esUnicolor
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      const Text('Multicolor'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnicolorSelector() {
    final coloresActivos = widget.coloresDisponibles.where((c) => c.activo).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedColors.isNotEmpty ? _selectedColors.first : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: coloresActivos.map((color) {
            return DropdownMenuItem<String>(
              value: color.nombre,
              child: Row(
                children: [
                  ColorPreviewCircle(
                    codigosHex: color.codigosHex,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(color.nombre),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedColors = [value];
                widget.onColoresChanged(_selectedColors);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildMulticolorSelector() {
    final coloresActivos = widget.coloresDisponibles.where((c) => c.activo).toList();
    final coloresNoSeleccionados = coloresActivos
        .where((c) => !_selectedColors.contains(c.nombre))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar Colores (mín. 2, máx. 5)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedColors.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No hay colores seleccionados',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedColors.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = _selectedColors.removeAt(oldIndex);
                      _selectedColors.insert(newIndex, item);
                      widget.onColoresChanged(_selectedColors);
                    });
                  },
                  itemBuilder: (context, index) {
                    final nombreColor = _selectedColors[index];
                    final color = widget.coloresDisponibles.firstWhere(
                      (c) => c.nombre == nombreColor,
                    );

                    return Card(
                      key: ValueKey(nombreColor),
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.drag_handle, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 8),
                            ColorPreviewCircle(
                              codigosHex: color.codigosHex,
                              size: 32,
                            ),
                          ],
                        ),
                        title: Text(
                          color.nombre,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Posición ${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          color: const Color(0xFFF44336),
                          onPressed: () {
                            setState(() {
                              _selectedColors.removeAt(index);
                              widget.onColoresChanged(_selectedColors);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              if (_selectedColors.length < 5 && coloresNoSeleccionados.isNotEmpty) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Agregar color...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: coloresNoSeleccionados.map((color) {
                    return DropdownMenuItem<String>(
                      value: color.nombre,
                      child: Row(
                        children: [
                          ColorPreviewCircle(
                            codigosHex: color.codigosHex,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(color.nombre),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && _selectedColors.length < 5) {
                      setState(() {
                        _selectedColors.add(value);
                        widget.onColoresChanged(_selectedColors);
                      });
                    }
                  },
                  initialValue: null,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    if (_selectedColors.isEmpty) return const SizedBox.shrink();

    final tipoColor = _getTipoColor();
    final colores = _selectedColors
        .map((nombre) => widget.coloresDisponibles.firstWhere((c) => c.nombre == nombre))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vista Previa',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              ...colores.map((color) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ColorPreviewCircle(
                  codigosHex: color.codigosHex,
                  size: 32,
                ),
              )),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tipoColor,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      colores.map((c) => c.nombre).join(', '),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescripcionVisualField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción Visual (Opcional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Ej: Rojo con franjas negras horizontales',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            widget.onDescripcionChanged?.call(value.isEmpty ? null : value);
          },
        ),
      ],
    );
  }

  String _getTipoColor() {
    switch (_selectedColors.length) {
      case 1:
        return 'Unicolor';
      case 2:
        return 'Bicolor';
      case 3:
        return 'Tricolor';
      default:
        return 'Multicolor';
    }
  }
}
