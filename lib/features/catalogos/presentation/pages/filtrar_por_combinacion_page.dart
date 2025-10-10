import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/catalogos/data/models/color_model.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_state.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/color_preview_circle.dart';

class FiltrarPorCombinacionPage extends StatefulWidget {
  const FiltrarPorCombinacionPage({Key? key}) : super(key: key);

  @override
  State<FiltrarPorCombinacionPage> createState() => _FiltrarPorCombinacionPageState();
}

class _FiltrarPorCombinacionPageState extends State<FiltrarPorCombinacionPage> {
  final List<String> _coloresSeleccionados = [];
  List<Map<String, dynamic>> _productos = [];
  List<ColorModel> _coloresDisponibles = [];
  bool _hasSearched = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return BlocProvider(
      create: (_) => di.sl<ColoresBloc>()..add(const LoadColores()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme, isDesktop),
              const SizedBox(height: 24),
              BlocConsumer<ColoresBloc, ColoresState>(
                listener: (context, state) {
                  if (state is ColoresLoaded) {
                    setState(() {
                      _coloresDisponibles = state.colores.where((c) => c.activo).toList();
                    });
                  }
                  if (state is ProductosByCombinacionLoaded) {
                    setState(() {
                      _productos = state.productos;
                      _hasSearched = true;
                    });
                  }
                  if (state is ColoresError) {
                    _showSnackbar(context, state.message, isError: true);
                  }
                },
                builder: (context, state) {
                  if (state is ColoresLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      _buildColorSelector(context, theme, isDesktop),
                      const SizedBox(height: 24),
                      _buildSearchButton(context, theme),
                      const SizedBox(height: 24),
                      if (_hasSearched) _buildResults(context, isDesktop),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.go('/colores'),
              icon: const Icon(Icons.arrow_back),
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Filtrar por Combinación de Colores',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Busca productos con una combinación exacta de colores',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector(BuildContext context, ThemeData theme, bool isDesktop) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selecciona colores',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  '${_coloresSeleccionados.length} seleccionados',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_coloresSeleccionados.isNotEmpty) ...[
              _buildSelectedColorChips(theme),
              const SizedBox(height: 16),
            ],
            _buildAvailableColors(context, theme, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedColorChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _coloresSeleccionados.map((nombreColor) {
        final color = _coloresDisponibles.firstWhere(
          (c) => c.nombre == nombreColor,
          orElse: () => ColorModel(
            id: '',
            nombre: nombreColor,
            codigosHex: const ['#CCCCCC'],
            tipoColor: 'unico',
            activo: true,
            productosCount: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        return Chip(
          avatar: ColorPreviewCircle(
            codigoHex: color.codigoHexPrimario,
            size: 24,
          ),
          label: Text(color.nombre),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () {
            setState(() {
              _coloresSeleccionados.remove(nombreColor);
            });
          },
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvailableColors(BuildContext context, ThemeData theme, bool isDesktop) {
    final coloresNoSeleccionados = _coloresDisponibles
        .where((c) => !_coloresSeleccionados.contains(c.nombre))
        .toList();

    if (coloresNoSeleccionados.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Todos los colores han sido seleccionados',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: coloresNoSeleccionados.map((color) {
        return InkWell(
          onTap: () {
            setState(() {
              _coloresSeleccionados.add(color.nombre);
              _hasSearched = false;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPreviewCircle(
                  codigoHex: color.codigoHexPrimario,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  color.nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.add_circle_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _coloresSeleccionados.isEmpty ? null : _handleSearch,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(Icons.search),
        label: Text(
          _coloresSeleccionados.isEmpty
              ? 'Selecciona al menos un color'
              : 'Buscar Productos (${_coloresSeleccionados.length} ${_coloresSeleccionados.length == 1 ? 'color' : 'colores'})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, bool isDesktop) {
    if (_productos.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${_productos.length} ${_productos.length == 1 ? 'producto encontrado' : 'productos encontrados'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: _productos.length,
          itemBuilder: (context, index) {
            final producto = _productos[index];
            return _buildProductCard(producto);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> producto) {
    final nombre = producto['nombre']?.toString() ?? 'Sin nombre';
    final sku = producto['sku']?.toString() ?? 'N/A';
    final colores = (producto['colores'] as List<dynamic>?)
        ?.map((c) => c.toString())
        .toList() ?? [];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: colores.take(5).map((colorNombre) {
                    final colorData = _coloresDisponibles.firstWhere(
                      (c) => c.nombre == colorNombre,
                      orElse: () => ColorModel(
                        id: '',
                        nombre: colorNombre,
                        codigosHex: const ['#CCCCCC'],
                        tipoColor: 'unico',
                        activo: true,
                        productosCount: 0,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    return ColorPreviewCircle(
                      codigoHex: colorData.codigoHexPrimario,
                      size: 24,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              'SKU: $sku',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${colores.length} ${colores.length == 1 ? 'color' : 'colores'}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: const Color(0xFF9CA3AF).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron productos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otra combinación de colores',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF6B7280).withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearch() {
    if (_coloresSeleccionados.isNotEmpty) {
      context.read<ColoresBloc>().add(
            FilterProductosByCombinacionEvent(
              colores: _coloresSeleccionados,
            ),
          );
    }
  }

  void _showSnackbar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
