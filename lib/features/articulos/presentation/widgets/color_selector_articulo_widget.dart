import 'package:flutter/material.dart';
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/color_preview_circle.dart';

class ColorSelectorArticuloWidget extends StatefulWidget {
  final List<ColorModel> coloresDisponibles;
  final String tipoColoracion;
  final List<String> coloresIds;
  final ValueChanged<String> onTipoChanged;
  final ValueChanged<List<String>> onColoresChanged;

  const ColorSelectorArticuloWidget({
    Key? key,
    required this.coloresDisponibles,
    required this.tipoColoracion,
    required this.coloresIds,
    required this.onTipoChanged,
    required this.onColoresChanged,
  }) : super(key: key);

  @override
  State<ColorSelectorArticuloWidget> createState() => _ColorSelectorArticuloWidgetState();
}

class _ColorSelectorArticuloWidgetState extends State<ColorSelectorArticuloWidget> {
  late String _tipoSeleccionado;
  late List<String> _idsSeleccionados;

  @override
  void initState() {
    super.initState();
    _tipoSeleccionado = widget.tipoColoracion;
    _idsSeleccionados = List.from(widget.coloresIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTipoSelector(),
        const SizedBox(height: 16),
        _buildColorSelector(),
        if (_idsSeleccionados.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildPreview(),
        ],
      ],
    );
  }

  Widget _buildTipoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Coloración *',
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
              child: _buildTipoChip('unicolor', 'Unicolor', 1),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTipoChip('bicolor', 'Bicolor', 2),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTipoChip('tricolor', 'Tricolor', 3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipoChip(String tipo, String label, int cantidad) {
    final isSelected = _tipoSeleccionado == tipo;

    return InkWell(
      onTap: () {
        setState(() {
          _tipoSeleccionado = tipo;
          _idsSeleccionados.clear();
        });
        widget.onTipoChanged(tipo);
        widget.onColoresChanged([]);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFF6B7280),
              ),
            ),
            Text(
              '$cantidad color${cantidad > 1 ? 'es' : ''}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    final cantidadEsperada = _tipoSeleccionado == 'unicolor' ? 1 : (_tipoSeleccionado == 'bicolor' ? 2 : 3);

    if (_tipoSeleccionado == 'unicolor') {
      return _buildUnicolorSelector();
    } else {
      return _buildMulticolorSelector(cantidadEsperada);
    }
  }

  Widget _buildUnicolorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar Color *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _idsSeleccionados.isNotEmpty ? _idsSeleccionados.first : null,
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
          items: widget.coloresDisponibles.map((color) {
            return DropdownMenuItem<String>(
              value: color.id,
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
          onChanged: (v) {
            if (v != null) {
              setState(() => _idsSeleccionados = [v]);
              widget.onColoresChanged([v]);
            }
          },
        ),
      ],
    );
  }

  Widget _buildMulticolorSelector(int cantidadEsperada) {
    final coloresNoSeleccionados = widget.coloresDisponibles
        .where((c) => !_idsSeleccionados.contains(c.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccionar Colores (exactamente $cantidadEsperada) *',
          style: const TextStyle(
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
              if (_idsSeleccionados.isEmpty)
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
                  itemCount: _idsSeleccionados.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = _idsSeleccionados.removeAt(oldIndex);
                      _idsSeleccionados.insert(newIndex, item);
                    });
                    widget.onColoresChanged(_idsSeleccionados);
                  },
                  itemBuilder: (context, index) {
                    final colorId = _idsSeleccionados[index];
                    final color = widget.coloresDisponibles.firstWhere((c) => c.id == colorId);

                    return Card(
                      key: ValueKey(colorId),
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
                              _idsSeleccionados.removeAt(index);
                            });
                            widget.onColoresChanged(_idsSeleccionados);
                          },
                        ),
                      ),
                    );
                  },
                ),
              if (_idsSeleccionados.length < cantidadEsperada && coloresNoSeleccionados.isNotEmpty) ...[
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
                      value: color.id,
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
                  onChanged: (v) {
                    if (v != null && _idsSeleccionados.length < cantidadEsperada) {
                      setState(() {
                        _idsSeleccionados.add(v);
                      });
                      widget.onColoresChanged(_idsSeleccionados);
                    }
                  },
                  initialValue: null,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_idsSeleccionados.length != cantidadEsperada)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, size: 16, color: Color(0xFF856404)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Debes seleccionar exactamente $cantidadEsperada color${cantidadEsperada > 1 ? 'es' : ''} para $_tipoSeleccionado',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPreview() {
    if (_idsSeleccionados.isEmpty) return const SizedBox.shrink();

    final colores = _idsSeleccionados
        .map((id) => widget.coloresDisponibles.firstWhere((c) => c.id == id))
        .toList();

    return Container(
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
                    _tipoSeleccionado.toUpperCase(),
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
    );
  }
}