import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_state.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/materiales_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/materiales_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/materiales_state.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/tipos_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/tipos_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/tipos_state.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/sistemas_talla/sistemas_talla_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/sistemas_talla/sistemas_talla_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/sistemas_talla/sistemas_talla_state.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_state.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_button.dart';

class ProductoMaestroFormPage extends StatelessWidget {
  final Map<String, dynamic>? arguments;

  const ProductoMaestroFormPage({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<MarcasBloc>()..add(const LoadMarcas())),
        BlocProvider(create: (_) => di.sl<MaterialesBloc>()..add(const LoadMaterialesEvent())),
        BlocProvider(create: (_) => di.sl<TiposBloc>()..add(const LoadTiposEvent())),
        BlocProvider(create: (_) => di.sl<SistemasTallaBloc>()..add(const LoadSistemasTallaEvent())),
        BlocProvider(create: (_) => di.sl<ProductoMaestroBloc>()),
      ],
      child: _ProductoMaestroFormView(arguments: arguments),
    );
  }
}

class _ProductoMaestroFormView extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const _ProductoMaestroFormView({this.arguments});

  @override
  State<_ProductoMaestroFormView> createState() => _ProductoMaestroFormViewState();
}

class _ProductoMaestroFormViewState extends State<_ProductoMaestroFormView> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();

  String? _marcaId;
  String? _materialId;
  String? _tipoId;
  String? _sistemaId;
  String? _valorTallaId;
  int _charCount = 0;

  bool get _isEditMode => widget.arguments?['mode'] == 'edit';
  int get _articulosTotales => widget.arguments?['articulosTotales'] ?? 0;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final producto = widget.arguments?['producto'];
      _marcaId = producto?['marcaId'];
      _materialId = producto?['materialId'];
      _tipoId = producto?['tipoId'];
      _sistemaId = producto?['sistemaTallaId'];
      _descripcionController.text = producto?['descripcion'] ?? '';
      _charCount = _descripcionController.text.length;
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return BlocConsumer<ProductoMaestroBloc, ProductoMaestroState>(
      listener: (context, state) {
        if (state is ProductoMaestroOperationSuccess) {
          _showSnackbar(context, state.message, isError: false);
          context.pop();
        }
        if (state is ProductoMaestroError) {
          _showSnackbar(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProductoMaestroLoading;

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
                              maxWidth: isDesktop ? 600 : double.infinity,
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
                                      if (_isEditMode && _articulosTotales > 0)
                                        _buildWarningCard(),

                                      _buildDropdownMarca(),
                                      const SizedBox(height: 20),

                                      _buildDropdownMaterial(),
                                      const SizedBox(height: 20),

                                      _buildDropdownTipo(),
                                      const SizedBox(height: 20),

                                      _buildDropdownSistemaTalla(),
                                      const SizedBox(height: 20),

                                      _buildDescripcionField(),
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
              _isEditMode ? 'Editar Producto Maestro' : 'Crear Producto Maestro',
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
          onTap: () => context.go('/productos-maestros'),
          child: Text(
            'Productos Maestros',
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

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Color(0xFFFF9800)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este producto tiene $_articulosTotales artículo${_articulosTotales == 1 ? '' : 's'} derivado${_articulosTotales == 1 ? '' : 's'}. Solo se puede editar la descripción.',
              style: const TextStyle(fontSize: 14, color: Color(0xFFE65100), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownMarca() {
    return BlocBuilder<MarcasBloc, MarcasState>(
      builder: (context, state) {
        if (state is MarcasLoading) {
          return const LinearProgressIndicator();
        }
        if (state is MarcasLoaded) {
          final activas = state.marcas.where((m) => m.activo).toList();

          if (activas.isEmpty) {
            return const Text(
              'No hay marcas activas disponibles',
              style: TextStyle(color: Color(0xFFF44336)),
            );
          }

          final valueExists = activas.any((m) => m.id == _marcaId);
          final validValue = valueExists ? _marcaId : null;

          return _buildDropdownField(
            label: 'Marca *',
            value: validValue,
            items: activas.map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre))).toList(),
            onChanged: (_isEditMode && _articulosTotales > 0) ? null : (v) => setState(() => _marcaId = v),
            validator: (v) => v == null ? 'Campo requerido' : null,
            enabled: !(_isEditMode && _articulosTotales > 0),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDropdownMaterial() {
    return BlocBuilder<MaterialesBloc, MaterialesState>(
      builder: (context, state) {
        if (state is MaterialesLoading) {
          return const LinearProgressIndicator();
        }
        if (state is MaterialesLoaded) {
          final activos = state.materiales.where((m) => m.activo).toList();

          if (activos.isEmpty) {
            return const Text(
              'No hay materiales activos disponibles',
              style: TextStyle(color: Color(0xFFF44336)),
            );
          }

          final valueExists = activos.any((m) => m.id == _materialId);
          final validValue = valueExists ? _materialId : null;

          return _buildDropdownField(
            label: 'Material *',
            value: validValue,
            items: activos.map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre))).toList(),
            onChanged: (_isEditMode && _articulosTotales > 0) ? null : (v) => setState(() => _materialId = v),
            validator: (v) => v == null ? 'Campo requerido' : null,
            enabled: !(_isEditMode && _articulosTotales > 0),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDropdownTipo() {
    return BlocBuilder<TiposBloc, TiposState>(
      builder: (context, state) {
        if (state is TiposLoading) {
          return const LinearProgressIndicator();
        }
        if (state is TiposLoaded) {
          final activos = state.tipos.where((t) => t.activo).toList();

          if (activos.isEmpty) {
            return const Text(
              'No hay tipos activos disponibles',
              style: TextStyle(color: Color(0xFFF44336)),
            );
          }

          final valueExists = activos.any((t) => t.id == _tipoId);
          final validValue = valueExists ? _tipoId : null;

          return _buildDropdownField(
            label: 'Tipo *',
            value: validValue,
            items: activos.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nombre))).toList(),
            onChanged: (_isEditMode && _articulosTotales > 0) ? null : (v) => setState(() => _tipoId = v),
            validator: (v) => v == null ? 'Campo requerido' : null,
            enabled: !(_isEditMode && _articulosTotales > 0),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDropdownSistemaTalla() {
    return BlocBuilder<SistemasTallaBloc, SistemasTallaState>(
      builder: (context, state) {
        if (state is SistemasTallaLoading) {
          return const LinearProgressIndicator();
        }
        if (state is SistemasTallaLoaded) {
          final activos = state.sistemas.where((s) => s.activo).toList();

          if (activos.isEmpty) {
            return const Text(
              'No hay sistemas de talla activos disponibles',
              style: TextStyle(color: Color(0xFFF44336)),
            );
          }

          final valueExists = activos.any((s) => s.id == _sistemaId);
          final validValue = valueExists ? _sistemaId : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sistema de Tallas *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: validValue,
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
                  fillColor: (_isEditMode && _articulosTotales > 0)
                      ? const Color(0xFFF3F4F6)
                      : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: activos.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${s.nombre} (${s.tipoSistema})',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (s.valores.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Tallas: ${s.valores.join(', ')}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (_isEditMode && _articulosTotales > 0)
                    ? null
                    : (v) {
                        setState(() {
                          _sistemaId = v;
                          _valorTallaId = null;
                        });
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    required String? Function(String?) validator,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
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
            fillColor: enabled ? Colors.white : const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDescripcionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción (opcional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Ej: Línea premium invierno 2025',
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
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterText: '',
          ),
          onChanged: (v) => setState(() => _charCount = v.length),
          validator: (v) => (v != null && v.length > 200) ? 'Máximo 200 caracteres' : null,
        ),
        const SizedBox(height: 4),
        Text(
          '$_charCount/200',
          style: TextStyle(
            fontSize: 12,
            color: _charCount > 200 ? const Color(0xFFF44336) : const Color(0xFF6B7280),
          ),
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
            onPressed: () => _handleSubmit(context),
          ),
        ),
      ],
    );
  }

  void _handleSubmit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final descripcion = _descripcionController.text.trim();
    final descripcionFinal = descripcion.isEmpty ? null : descripcion;

    if (_isEditMode) {
      context.read<ProductoMaestroBloc>().add(EditarProductoMaestroEvent(
            productoId: widget.arguments!['productoId'],
            descripcion: descripcionFinal,
          ));
    } else {
      context.read<ProductoMaestroBloc>().add(CrearProductoMaestroEvent(
            marcaId: _marcaId!,
            materialId: _materialId!,
            tipoId: _tipoId!,
            sistemaTallaId: _sistemaId!,
            descripcion: descripcionFinal,
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
      return _descripcionController.text != (widget.arguments?['producto']?['descripcion'] ?? '');
    }
    return _marcaId != null ||
           _materialId != null ||
           _tipoId != null ||
           _sistemaId != null ||
           _valorTallaId != null ||
           _descripcionController.text.isNotEmpty;
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
