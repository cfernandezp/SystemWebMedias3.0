import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/core/theme/design_tokens.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_completo_request_model.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_state.dart';
import 'package:system_web_medias/shared/widgets/color_selector_modal.dart';
import 'package:system_web_medias/shared/widgets/color_chip.dart';

class ArticulosEditableTable extends StatefulWidget {
  final List<ArticuloData> articulos;
  final Function(List<ArticuloData>) onArticulosChanged;
  final String? marcaCodigo;
  final String? materialCodigo;
  final String? tipoCodigo;

  const ArticulosEditableTable({
    super.key,
    required this.articulos,
    required this.onArticulosChanged,
    this.marcaCodigo,
    this.materialCodigo,
    this.tipoCodigo,
  });

  @override
  State<ArticulosEditableTable> createState() => _ArticulosEditableTableState();
}

class _ArticulosEditableTableState extends State<ArticulosEditableTable> {
  late List<ArticuloData> _articulos;

  @override
  void initState() {
    super.initState();
    _articulos = List.from(widget.articulos);
  }

  @override
  void didUpdateWidget(ArticulosEditableTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.articulos != widget.articulos) {
      _articulos = List.from(widget.articulos);
    }
  }

  void _addArticulo(List<String> coloresIds, double precio) {
    setState(() {
      _articulos.add(ArticuloData(coloresIds: coloresIds, precio: precio));
      widget.onArticulosChanged(_articulos);
    });
  }

  void _removeArticulo(int index) {
    setState(() {
      _articulos.removeAt(index);
      widget.onArticulosChanged(_articulos);
    });
  }

  void _updatePrecio(int index, double precio) {
    setState(() {
      final articulo = _articulos[index];
      _articulos[index] = ArticuloData(
        coloresIds: articulo.coloresIds,
        precio: precio,
      );
      widget.onArticulosChanged(_articulos);
    });
  }

  String _getTipoColoracion(int cantidadColores) {
    switch (cantidadColores) {
      case 1:
        return 'Unicolor';
      case 2:
        return 'Bicolor';
      case 3:
        return 'Tricolor';
      default:
        return '-';
    }
  }

  String _generarSKU(List<String> coloresIds) {
    if (widget.marcaCodigo == null ||
        widget.materialCodigo == null ||
        widget.tipoCodigo == null) {
      return 'Completa campos base';
    }

    final coloresBloc = context.read<ColoresBloc>();
    if (coloresBloc.state is! ColoresLoaded) {
      return 'Cargando...';
    }

    final coloresState = coloresBloc.state as ColoresLoaded;
    final coloresCodigos = coloresIds.map((id) {
      final color = coloresState.colores.firstWhere((c) => c.id == id);
      return color.nombre.substring(0, 3).toUpperCase();
    }).join('-');

    return '${widget.marcaCodigo}-${widget.materialCodigo}-${widget.tipoCodigo}-$coloresCodigos';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<ColoresBloc>()..add(const LoadColores()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showColorSelectorModal(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Artículo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: DesignSpacing.md),
          if (_articulos.isEmpty)
            Container(
              padding: const EdgeInsets.all(DesignSpacing.xl),
              decoration: BoxDecoration(
                color: DesignColors.surface,
                border: Border.all(color: DesignColors.border),
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: DesignColors.disabled,
                    ),
                    const SizedBox(height: DesignSpacing.sm),
                    Text(
                      'No hay artículos agregados',
                      style: TextStyle(
                        fontSize: DesignTypography.fontMd,
                        color: DesignColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DesignSpacing.xs),
                    Text(
                      'Haz clic en "Agregar Artículo" para comenzar',
                      style: TextStyle(
                        fontSize: DesignTypography.fontSm,
                        color: DesignColors.disabled,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _buildTable(),
            const SizedBox(height: DesignSpacing.lg),
            _buildSKUPreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: DesignColors.surface,
        border: Border.all(color: DesignColors.border),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            DesignColors.primaryTurquoise.withValues(alpha: 0.1),
          ),
          columns: const [
            DataColumn(label: Text('Colores', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Precio', style: TextStyle(fontWeight: FontWeight.w600))),
            DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.w600))),
          ],
          rows: _articulos.asMap().entries.map((entry) {
            final index = entry.key;
            final articulo = entry.value;
            return DataRow(
              cells: [
                DataCell(_buildColoresCell(articulo.coloresIds)),
                DataCell(Text(_getTipoColoracion(articulo.coloresIds.length))),
                DataCell(_buildPrecioField(index, articulo.precio)),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: DesignColors.error),
                    onPressed: () => _removeArticulo(index),
                    tooltip: 'Eliminar artículo',
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildColoresCell(List<String> coloresIds) {
    return BlocBuilder<ColoresBloc, ColoresState>(
      builder: (context, state) {
        if (state is! ColoresLoaded) {
          return const Text('Cargando...');
        }

        final colores = coloresIds.map((id) {
          return state.colores.firstWhere((c) => c.id == id);
        }).toList();

        return Wrap(
          spacing: DesignSpacing.xs,
          runSpacing: DesignSpacing.xs,
          children: colores.map((color) {
            return ColorChip(
              colorId: color.id,
              colorName: color.nombre,
              hexCodes: color.codigosHex,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPrecioField(int index, double precio) {
    final controller = TextEditingController(text: precio.toString());

    return SizedBox(
      width: 120,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          prefixText: '\$ ',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.sm,
            vertical: DesignSpacing.sm,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            borderSide: const BorderSide(color: DesignColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            borderSide: const BorderSide(color: DesignColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            borderSide: const BorderSide(color: DesignColors.accent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignRadius.lg),
            borderSide: const BorderSide(color: DesignColors.error, width: 2),
          ),
        ),
        onChanged: (value) {
          final newPrecio = double.tryParse(value);
          if (newPrecio != null && newPrecio > 0) {
            _updatePrecio(index, newPrecio);
          }
        },
      ),
    );
  }

  Widget _buildSKUPreview() {
    if (widget.marcaCodigo == null ||
        widget.materialCodigo == null ||
        widget.tipoCodigo == null) {
      return Container(
        padding: const EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: DesignColors.warning.withValues(alpha: 0.1),
          border: Border.all(color: DesignColors.warning),
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        child: Row(
          children: [
            const Icon(Icons.info, color: DesignColors.warning, size: 20),
            const SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Text(
                'Completa los campos de producto base para ver los SKUs',
                style: TextStyle(
                  fontSize: DesignTypography.fontSm,
                  color: DesignColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.info.withValues(alpha: 0.1),
        border: Border.all(color: DesignColors.info),
        borderRadius: BorderRadius.circular(DesignRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SKUs a generar:',
            style: TextStyle(
              fontSize: DesignTypography.fontMd,
              fontWeight: DesignTypography.semibold,
              color: DesignColors.textPrimary,
            ),
          ),
          const SizedBox(height: DesignSpacing.sm),
          ..._articulos.map((articulo) {
            final sku = _generarSKU(articulo.coloresIds);
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.label, size: 16, color: DesignColors.info),
                  const SizedBox(width: DesignSpacing.xs),
                  Text(
                    '$sku (\$${articulo.precio.toStringAsFixed(2)})',
                    style: TextStyle(
                      fontSize: DesignTypography.fontSm,
                      fontFamily: 'monospace',
                      color: DesignColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showColorSelectorModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (dialogContext) => ColorSelectorModal(
        onColorsSelected: (coloresIds, precio) {
          _addArticulo(coloresIds, precio);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}
