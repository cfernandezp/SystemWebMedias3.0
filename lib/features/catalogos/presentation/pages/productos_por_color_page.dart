import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_state.dart';

class ProductosPorColorPage extends StatefulWidget {
  const ProductosPorColorPage({Key? key}) : super(key: key);

  @override
  State<ProductosPorColorPage> createState() => _ProductosPorColorPageState();
}

class _ProductosPorColorPageState extends State<ProductosPorColorPage> {
  final _colorController = TextEditingController();
  bool _exacto = false;
  List<Map<String, dynamic>> _productos = [];
  String _colorBuscado = '';

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return BlocProvider(
      create: (_) => di.sl<ColoresBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme, isDesktop),
              const SizedBox(height: 24),
              _buildSearchForm(context, theme, isDesktop),
              const SizedBox(height: 24),
              BlocConsumer<ColoresBloc, ColoresState>(
                listener: (context, state) {
                  if (state is ProductosByColorLoaded) {
                    setState(() {
                      _productos = state.productos;
                      _colorBuscado = state.colorNombre;
                      _exacto = state.exacto;
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

                  if (_productos.isNotEmpty) {
                    return _buildResults(context, isDesktop);
                  }

                  if (_colorBuscado.isNotEmpty && _productos.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildInitialState();
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
            Text(
              'Buscar Productos por Color',
              style: TextStyle(
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchForm(BuildContext context, ThemeData theme, bool isDesktop) {
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
            const Text(
              'Buscar productos que contengan un color específico',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _colorController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Rojo, Azul, Negro',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _handleSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        Text('Resultados: ${_productos.length} productos'),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('Sin resultados'));
  }

  Widget _buildInitialState() {
    return const Center(child: Text('Ingresa un color'));
  }

  void _handleSearch() {
    final colorNombre = _colorController.text.trim();
    if (colorNombre.isNotEmpty) {
      context.read<ColoresBloc>().add(
            LoadProductosByColor(
              colorNombre: colorNombre,
              exacto: _exacto,
            ),
          );
    }
  }

  void _showSnackbar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
