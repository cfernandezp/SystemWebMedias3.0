import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/articulos/presentation/bloc/articulos_event.dart';
import 'package:system_web_medias/features/articulos/presentation/bloc/articulos_state.dart';
import 'package:system_web_medias/features/articulos/presentation/bloc/articulos_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_state.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_state.dart';
import 'package:system_web_medias/features/articulos/presentation/widgets/color_selector_articulo_widget.dart';
import 'package:system_web_medias/features/articulos/presentation/widgets/sku_preview_widget.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_button.dart';

class ArticuloFormPage extends StatelessWidget {
  final Map<String, dynamic>? arguments;

  const ArticuloFormPage({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ArticulosBloc>()),
        BlocProvider(create: (_) => di.sl<ProductoMaestroBloc>()..add(const ListarProductosMaestrosEvent())),
        BlocProvider(create: (_) => di.sl<ColoresBloc>()..add(const LoadColores())),
      ],
      child: _ArticuloFormView(arguments: arguments),
    );
  }
}

class _ArticuloFormView extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const _ArticuloFormView({this.arguments});

  @override
  State<_ArticuloFormView> createState() => _ArticuloFormViewState();
}

class _ArticuloFormViewState extends State<_ArticuloFormView> {
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController();

  String? _productoMaestroId;
  String _tipoColoracion = 'unicolor';
  List<String> _coloresIds = [];
  String? _skuGenerado;
  bool _skuDuplicado = false;

  bool get _isEditMode => widget.arguments?['mode'] == 'edit';

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final articulo = widget.arguments?['articulo'];
      _productoMaestroId = articulo?['productoMaestroId'];
      _tipoColoracion = articulo?['tipoColoracion'] ?? 'unicolor';
      _coloresIds = List<String>.from(articulo?['coloresIds'] ?? []);
      _precioController.text = articulo?['precio']?.toString() ?? '';
      _skuGenerado = articulo?['sku'];
    }
  }

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return MultiBlocListener(
      listeners: [
        BlocListener<ArticulosBloc, ArticulosState>(
          listener: (context, state) {
            if (state is ArticuloOperationSuccess) {
              _showSnackbar(context, state.message, isError: false);
              context.pop();
            }
            if (state is SkuGenerated) {
              setState(() {
                _skuGenerado = state.sku;
                _skuDuplicado = false;
              });
            }
            if (state is ArticulosError) {
              if (state.message.contains('ya existe')) {
                setState(() => _skuDuplicado = true);
              }
              _showSnackbar(context, state.message, isError: true);
            }
          },
        ),
      ],
      child: BlocBuilder<ArticulosBloc, ArticulosState>(
        builder: (context, state) {
          final isLoading = state is ArticulosLoading;

          return PopScope(
            canPop: !_hasUnsavedChanges(),
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _handleCancel();
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF9FAFB),
              body: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - (isDesktop ? 48.0 : 32.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, theme, isDesktop),
                          const SizedBox(height: 24),
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isDesktop ? 700 : double.infinity,
                              ),
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildDropdownProductoMaestro(),
                                        const SizedBox(height: 20),

                                        _buildColorSelector(),
                                        const SizedBox(height: 20),

                                        if (_skuGenerado != null) ...[
                                          SkuPreviewWidget(
                                            sku: _skuGenerado!,
                                            esDuplicado: _skuDuplicado,
                                          ),
                                          const SizedBox(height: 20),
                                        ],

                                        _buildPrecioField(),
                                        const SizedBox(height: 24),

                                        _buildActionButtons(context, isLoading),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
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
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _isEditMode ? 'Editar Artículo' : 'Crear Artículo Especializado',
              style: TextStyle(
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 56),
          child: _buildBreadcrumbs(context),
        ),
      ],
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.go('/dashboard'),
          child: Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('>', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ),
        InkWell(
          onTap: () => context.go('/articulos'),
          child: Text(
            'Artículos',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('>', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ),
        Text(
          _isEditMode ? 'Editar' : 'Crear',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDropdownProductoMaestro() {
    return BlocBuilder<ProductoMaestroBloc, ProductoMaestroState>(
      builder: (context, state) {
        if (state is ProductoMaestroLoading) {
          return const LinearProgressIndicator();
        }
        if (state is ProductoMaestroLoaded) {
          final activos = state.productos.where((p) => p.activo && !p.tieneCatalogosInactivos).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Producto Maestro *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _productoMaestroId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFF44336)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: activos.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(p.nombreCompleto, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) {
                  setState(() => _productoMaestroId = v);
                  _generarSkuSiCompleto();
                },
                validator: (v) => v == null ? 'Campo requerido' : null,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildColorSelector() {
    return BlocBuilder<ColoresBloc, ColoresState>(
      builder: (context, state) {
        if (state is ColoresLoading) {
          return const LinearProgressIndicator();
        }
        if (state is ColoresLoaded) {
          final coloresActivos = state.filteredColores.where((c) => c.activo).toList();
          return ColorSelectorArticuloWidget(
            coloresDisponibles: coloresActivos,
            tipoColoracion: _tipoColoracion,
            coloresIds: _coloresIds,
            onTipoChanged: (tipo) {
              setState(() {
                _tipoColoracion = tipo;
                _coloresIds.clear();
                _skuGenerado = null;
              });
            },
            onColoresChanged: (colores) {
              setState(() => _coloresIds = colores);
              _generarSkuSiCompleto();
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPrecioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Precio de Venta *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _precioController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            prefixText: '\$ ',
            hintText: 'Ej: 15000.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFF44336)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Campo requerido';
            final precio = double.tryParse(v);
            if (precio == null) return 'Precio inválido';
            if (precio <= 0) return 'Precio debe ser mayor a 0';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: CorporateButton(
            text: 'Cancelar',
            variant: ButtonVariant.secondary,
            onPressed: isLoading ? null : _handleCancel,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CorporateButton(
            text: _isEditMode ? 'Actualizar' : 'Guardar',
            icon: _isEditMode ? Icons.save : Icons.add,
            isLoading: isLoading,
            onPressed: _skuDuplicado ? null : () => _handleSubmit(context),
          ),
        ),
      ],
    );
  }

  void _generarSkuSiCompleto() {
    if (_productoMaestroId != null && _coloresIds.isNotEmpty) {
      final cantidadEsperada = _tipoColoracion == 'unicolor' ? 1 : (_tipoColoracion == 'bicolor' ? 2 : 3);
      if (_coloresIds.length == cantidadEsperada) {
        context.read<ArticulosBloc>().add(GenerarSkuEvent(
          productoMaestroId: _productoMaestroId!,
          coloresIds: _coloresIds,
        ));
      }
    }
  }

  void _handleSubmit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cantidadEsperada = _tipoColoracion == 'unicolor' ? 1 : (_tipoColoracion == 'bicolor' ? 2 : 3);
    if (_coloresIds.length != cantidadEsperada) {
      _showSnackbar(context, 'Debes seleccionar exactamente $cantidadEsperada color(es)', isError: true);
      return;
    }

    final precio = double.parse(_precioController.text);

    if (_isEditMode) {
      context.read<ArticulosBloc>().add(EditarArticuloEvent(
        articuloId: widget.arguments!['articuloId'],
        precio: precio,
      ));
    } else {
      context.read<ArticulosBloc>().add(CrearArticuloEvent(
        productoMaestroId: _productoMaestroId!,
        coloresIds: _coloresIds,
        precio: precio,
      ));
    }
  }

  void _handleCancel() {
    if (_hasUnsavedChanges()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('¿Descartar cambios?'),
          content: const Text('Los cambios no guardados se perderán. ¿Deseas continuar?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continuar editando')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text('Descartar'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  bool _hasUnsavedChanges() {
    if (_isEditMode) {
      return _precioController.text != (widget.arguments?['articulo']?['precio']?.toString() ?? '');
    }
    return _productoMaestroId != null || _coloresIds.isNotEmpty || _precioController.text.isNotEmpty;
  }

  void _showSnackbar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}