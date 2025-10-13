import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_state.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/widgets/combinacion_warning_card.dart';
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
import 'package:system_web_medias/shared/design_system/atoms/corporate_button.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_form_field.dart';

class ProductoMaestroFormPage extends StatelessWidget {
  final Map<String, dynamic>? arguments;

  const ProductoMaestroFormPage({Key? key, this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mode = arguments?['mode'] ?? 'create';
    final productoId = arguments?['productoId'];
    final producto = arguments?['producto'];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ProductoMaestroBloc>()),
        BlocProvider(create: (_) => di.sl<MarcasBloc>()..add(const LoadMarcas())),
        BlocProvider(create: (_) => di.sl<MaterialesBloc>()..add(const LoadMaterialesEvent())),
        BlocProvider(create: (_) => di.sl<TiposBloc>()..add(const LoadTiposEvent())),
        BlocProvider(create: (_) => di.sl<SistemasTallaBloc>()..add(const LoadSistemasTallaEvent())),
      ],
      child: _ProductoMaestroFormView(
        mode: mode,
        productoId: productoId,
        producto: producto,
      ),
    );
  }
}

class _ProductoMaestroFormView extends StatefulWidget {
  final String mode;
  final String? productoId;
  final dynamic producto;

  const _ProductoMaestroFormView({
    required this.mode,
    this.productoId,
    this.producto,
  });

  @override
  State<_ProductoMaestroFormView> createState() => _ProductoMaestroFormViewState();
}

class _ProductoMaestroFormViewState extends State<_ProductoMaestroFormView> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();

  String? _marcaId;
  String? _materialId;
  String? _tipoId;
  String? _sistemaTallaId;

  bool _showErrors = false;
  List<String>? _warnings;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'edit' && widget.producto != null) {
      _marcaId = widget.producto.marcaId;
      _materialId = widget.producto.materialId;
      _tipoId = widget.producto.tipoId;
      _sistemaTallaId = widget.producto.sistemaTallaId;
      _descripcionController.text = widget.producto.descripcion ?? '';
    }

    _descripcionController.addListener(() {
      if (!_hasChanges) {
        setState(() => _hasChanges = true);
      }
    });
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
    final isEdit = widget.mode == 'edit';
    final hasArticles = isEdit && (widget.producto?.articulosTotales ?? 0) > 0;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showUnsavedChangesDialog(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text(isEdit ? 'Editar Producto Maestro' : 'Crear Producto Maestro'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<ProductoMaestroBloc, ProductoMaestroState>(
          listener: (context, state) {
            if (state is ProductoMaestroCreated) {
              _showSnackbar(
                context,
                'Producto maestro creado exitosamente',
                isError: false,
              );
              if (state.warnings != null && state.warnings!.isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  _showWarningsDialog(context, state.warnings!);
                });
              }
              context.pop();
            }

            if (state is ProductoMaestroEdited) {
              _showSnackbar(
                context,
                'Producto maestro actualizado exitosamente',
                isError: false,
              );
              context.pop();
            }

            if (state is ProductoMaestroError) {
              if (state.hint == 'duplicate_combination_inactive') {
                _showReactivateDialog(context);
              } else {
                _showSnackbar(context, state.message, isError: true);
              }
            }

            if (state is CombinacionValidated) {
              setState(() {
                _warnings = state.warnings;
              });
            }
          },
          builder: (context, state) {
            final isLoading = state is ProductoMaestroLoading;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (hasArticles) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFF9800)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info, color: Color(0xFFFF9800)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Este producto tiene ${widget.producto.articulosTotales} articulos derivados. Solo se puede editar la descripcion',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        _buildMarcaDropdown(hasArticles),
                        const SizedBox(height: 20),

                        _buildMaterialDropdown(hasArticles),
                        const SizedBox(height: 20),

                        _buildTipoDropdown(hasArticles),
                        const SizedBox(height: 20),

                        _buildSistemaTallaDropdown(hasArticles),
                        const SizedBox(height: 20),

                        CorporateFormField(
                          controller: _descripcionController,
                          label: 'Descripción (opcional)',
                          hintText: 'Ej: Línea premium invierno 2025',
                          maxLines: 3,
                          enabled: !isLoading,
                          validator: (value) {
                            if (value != null && value.length > 200) {
                              return 'Máximo 200 caracteres';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            if (!_hasChanges) {
                              setState(() => _hasChanges = true);
                            }
                          },
                        ),

                        if (_warnings != null && _warnings!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          CombinacionWarningCard(warnings: _warnings!),
                        ],

                        const SizedBox(height: 24),

                        _buildVistaPrevia(),

                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              child: CorporateButton(
                                text: 'Cancelar',
                                variant: ButtonVariant.secondary,
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_hasChanges) {
                                          _showUnsavedChangesDialog(context);
                                        } else {
                                          context.pop();
                                        }
                                      },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: CorporateButton(
                                text: isEdit ? 'Actualizar' : 'Guardar',
                                isLoading: isLoading,
                                onPressed: isLoading ? null : _handleSubmit,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarcaDropdown(bool disabled) {
    return BlocBuilder<MarcasBloc, MarcasState>(
      builder: (context, state) {
        if (state is MarcasLoaded) {
          final marcas = state.filteredMarcas.where((m) => m.activo).toList();
          return _buildDropdownField(
            label: 'Marca *',
            value: _marcaId,
            items: marcas.map((m) => DropdownMenuItem(
              value: m.id,
              child: Text(m.nombre),
            )).toList(),
            onChanged: disabled
                ? null
                : (value) {
                    setState(() {
                      _marcaId = value;
                      _hasChanges = true;
                    });
                    _validateCombinacion();
                  },
            hasError: _showErrors && _marcaId == null,
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildMaterialDropdown(bool disabled) {
    return BlocBuilder<MaterialesBloc, MaterialesState>(
      builder: (context, state) {
        if (state is MaterialesLoaded) {
          final materiales = state.materiales.where((m) => m.activo).toList();
          return _buildDropdownField(
            label: 'Material *',
            value: _materialId,
            items: materiales.map((m) => DropdownMenuItem(
              value: m.id,
              child: Text(m.nombre),
            )).toList(),
            onChanged: disabled
                ? null
                : (value) {
                    setState(() {
                      _materialId = value;
                      _hasChanges = true;
                    });
                    _validateCombinacion();
                  },
            hasError: _showErrors && _materialId == null,
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildTipoDropdown(bool disabled) {
    return BlocBuilder<TiposBloc, TiposState>(
      builder: (context, state) {
        if (state is TiposLoaded) {
          final tipos = state.tipos.where((t) => t.activo).toList();
          return _buildDropdownField(
            label: 'Tipo *',
            value: _tipoId,
            items: tipos.map((t) => DropdownMenuItem(
              value: t.id,
              child: Text(t.nombre),
            )).toList(),
            onChanged: disabled
                ? null
                : (value) {
                    setState(() {
                      _tipoId = value;
                      _hasChanges = true;
                    });
                    _validateCombinacion();
                  },
            hasError: _showErrors && _tipoId == null,
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildSistemaTallaDropdown(bool disabled) {
    return BlocBuilder<SistemasTallaBloc, SistemasTallaState>(
      builder: (context, state) {
        if (state is SistemasTallaLoaded) {
          final sistemas = state.sistemas.where((s) => s.activo).toList();
          return _buildDropdownField(
            label: 'Sistema de Tallas *',
            value: _sistemaTallaId,
            items: sistemas.map((s) => DropdownMenuItem(
              value: s.id,
              child: Tooltip(
                message: 'Tipo: ${s.tipoSistema} - ${s.valoresCount} valores',
                child: Text(s.nombre),
              ),
            )).toList(),
            onChanged: disabled
                ? null
                : (value) {
                    setState(() {
                      _sistemaTallaId = value;
                      _hasChanges = true;
                    });
                    _validateCombinacion();
                  },
            hasError: _showErrors && _sistemaTallaId == null,
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    required bool hasError,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: hasError ? const Color(0xFFF44336) : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: onChanged == null ? const Color(0xFFF3F4F6) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: hasError ? const Color(0xFFF44336) : const Color(0xFFE5E7EB),
              width: hasError ? 2.5 : 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text('Seleccionar $label'),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(28),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              'Campo obligatorio',
              style: const TextStyle(fontSize: 12, color: Color(0xFFF44336)),
            ),
          ),
      ],
    );
  }

  Widget _buildVistaPrevia() {
    if (_marcaId == null || _materialId == null || _tipoId == null || _sistemaTallaId == null) {
      return const SizedBox.shrink();
    }

    final marcaNombre = context.read<MarcasBloc>().state is MarcasLoaded
        ? (context.read<MarcasBloc>().state as MarcasLoaded)
            .filteredMarcas
            .firstWhere((m) => m.id == _marcaId)
            .nombre
        : '';

    final materialNombre = context.read<MaterialesBloc>().state is MaterialesLoaded
        ? (context.read<MaterialesBloc>().state as MaterialesLoaded)
            .materiales
            .firstWhere((m) => m.id == _materialId)
            .nombre
        : '';

    final tipoNombre = context.read<TiposBloc>().state is TiposLoaded
        ? (context.read<TiposBloc>().state as TiposLoaded)
            .tipos
            .firstWhere((t) => t.id == _tipoId)
            .nombre
        : '';

    final sistemaNombre = context.read<SistemasTallaBloc>().state is SistemasTallaLoaded
        ? (context.read<SistemasTallaBloc>().state as SistemasTallaLoaded)
            .sistemas
            .firstWhere((s) => s.id == _sistemaTallaId)
            .nombre
        : '';

    final nombreCompleto = '$marcaNombre - $tipoNombre - $materialNombre - $sistemaNombre';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vista Previa',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            nombreCompleto,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _validateCombinacion() {
    if (_tipoId != null && _sistemaTallaId != null) {
      context.read<ProductoMaestroBloc>().add(
        ValidarCombinacionComercialEvent(
          tipoId: _tipoId!,
          sistemaTallaId: _sistemaTallaId!,
        ),
      );
    }
  }

  void _handleSubmit() {
    setState(() => _showErrors = true);

    if (_marcaId == null || _materialId == null || _tipoId == null || _sistemaTallaId == null) {
      _showSnackbar(context, 'Complete todos los campos obligatorios', isError: true);
      return;
    }

    if (_descripcionController.text.length > 200) {
      _showSnackbar(context, 'La descripción no puede exceder 200 caracteres', isError: true);
      return;
    }

    if (widget.mode == 'edit') {
      context.read<ProductoMaestroBloc>().add(
        EditarProductoMaestroEvent(
          productoId: widget.productoId!,
          marcaId: _marcaId,
          materialId: _materialId,
          tipoId: _tipoId,
          sistemaTallaId: _sistemaTallaId,
          descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
        ),
      );
    } else {
      context.read<ProductoMaestroBloc>().add(
        CrearProductoMaestroEvent(
          marcaId: _marcaId!,
          materialId: _materialId!,
          tipoId: _tipoId!,
          sistemaTallaId: _sistemaTallaId!,
          descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
        ),
      );
    }
  }

  void _showUnsavedChangesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Descartar cambios?'),
        content: const Text('Tiene cambios sin guardar. Desea descartarlos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Seguir editando'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }

  void _showWarningsDialog(BuildContext context, List<String> warnings) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        icon: const Icon(Icons.warning, size: 48, color: Color(0xFFFF9800)),
        title: const Text('Advertencias de combinación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: warnings.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(w)),
              ],
            ),
          )).toList(),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showReactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Producto inactivo existente'),
        content: const Text('Ya existe un producto inactivo con esta combinación. Desea reactivarlo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Aquí debería reactivar el producto existente
              _showSnackbar(context, 'Funcionalidad de reactivación pendiente', isError: true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Reactivar producto'),
          ),
        ],
      ),
    );
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
