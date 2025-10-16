import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/core/theme/design_tokens.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_completo_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_completo_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_completo_state.dart';
import 'package:system_web_medias/features/productos_maestros/data/models/producto_completo_request_model.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/widgets/articulos_editable_table.dart';
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

class ProductoCreationExpertPage extends StatelessWidget {
  const ProductoCreationExpertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<ProductoCompletoBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<MarcasBloc>()..add(const LoadMarcas()),
        ),
        BlocProvider(
          create: (context) => di.sl<MaterialesBloc>()..add(const LoadMaterialesEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<TiposBloc>()..add(const LoadTiposEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<SistemasTallaBloc>()..add(const LoadSistemasTallaEvent()),
        ),
      ],
      child: Scaffold(
        backgroundColor: DesignColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Crear Producto Completo'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<ProductoCompletoBloc, ProductoCompletoState>(
          listener: (context, state) {
            // CA-008-007: Navegación post-creación
            if (state is ProductoCompletoCreated && state.navigateTo != null) {
              context.push(state.navigateTo!);
            }

            // CA-008-005: Errores
            if (state is ProductoCompletoError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: DesignColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.sm),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            // Loading durante creación
            if (state is ProductoCompletoCreating) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: DesignColors.primaryTurquoise,
                    ),
                    const SizedBox(height: DesignSpacing.md),
                    Text(
                      'Creando producto...',
                      style: TextStyle(
                        fontSize: DesignTypography.fontMd,
                        color: DesignColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Formulario (estado inicial o error)
            return const _ProductoCreationForm();
          },
        ),
      ),
    );
  }
}

class _ProductoCreationForm extends StatefulWidget {
  const _ProductoCreationForm();

  @override
  State<_ProductoCreationForm> createState() => _ProductoCreationFormState();
}

class _ProductoCreationFormState extends State<_ProductoCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();

  String? _selectedMarcaId;
  String? _selectedMaterialId;
  String? _selectedTipoId;
  String? _selectedSistemaTallaId;
  String? _selectedValorTallaId;
  List<ArticuloData> _articulos = [];

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _selectedMarcaId != null &&
        _selectedMaterialId != null &&
        _selectedTipoId != null &&
        _selectedSistemaTallaId != null &&
        _selectedValorTallaId != null;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complete todos los campos obligatorios'),
          backgroundColor: DesignColors.warning,
        ),
      );
      return;
    }

    final request = ProductoCompletoRequestModel(
      productoMaestro: ProductoMaestroData(
        marcaId: _selectedMarcaId!,
        materialId: _selectedMaterialId!,
        tipoId: _selectedTipoId!,
        valorTallaId: _selectedValorTallaId!,
        descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      ),
      articulos: _articulos,
    );

    context.read<ProductoCompletoBloc>().add(CreateProductoCompletoEvent(request));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = DesignBreakpoints.isDesktop(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? DesignSpacing.lg : DesignSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductoBaseSection(isDesktop),
            const SizedBox(height: DesignSpacing.lg),
            _buildArticulosSection(isDesktop),
            const SizedBox(height: DesignSpacing.xl),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductoBaseSection(bool isDesktop) {
    return ExpansionTile(
      title: Text(
        'PRODUCTO BASE',
        style: TextStyle(
          fontWeight: DesignTypography.semibold,
          fontSize: DesignTypography.fontMd,
          color: DesignColors.textPrimary,
        ),
      ),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(DesignSpacing.md),
          child: Column(
            children: [
              if (isDesktop)
                Row(
                  children: [
                    Expanded(child: _buildMarcaDropdown()),
                    const SizedBox(width: DesignSpacing.md),
                    Expanded(child: _buildMaterialDropdown()),
                  ],
                )
              else ...[
                _buildMarcaDropdown(),
                const SizedBox(height: DesignSpacing.sm),
                _buildMaterialDropdown(),
              ],
              const SizedBox(height: DesignSpacing.sm),
              if (isDesktop)
                Row(
                  children: [
                    Expanded(child: _buildTipoDropdown()),
                    const SizedBox(width: DesignSpacing.md),
                    Expanded(child: _buildSistemaTallaDropdown()),
                  ],
                )
              else ...[
                _buildTipoDropdown(),
                const SizedBox(height: DesignSpacing.sm),
                _buildSistemaTallaDropdown(),
              ],
              const SizedBox(height: DesignSpacing.sm),
              _buildValorTallaDropdown(),
              const SizedBox(height: DesignSpacing.sm),
              _buildDescripcionField(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarcaDropdown() {
    return BlocBuilder<MarcasBloc, MarcasState>(
      builder: (context, state) {
        if (state is MarcasLoaded) {
          final marcasActivas = state.marcas.where((m) => m.activo).toList();
          return DropdownButtonFormField<String>(
            value: _selectedMarcaId,
            decoration: InputDecoration(
              labelText: 'Marca *',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.business),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.md,
              ),
            ),
            items: marcasActivas.map((marca) {
              return DropdownMenuItem(
                value: marca.id,
                child: Text(marca.nombre),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedMarcaId = value),
          );
        }
        return const LinearProgressIndicator();
      },
    );
  }

  Widget _buildMaterialDropdown() {
    return BlocBuilder<MaterialesBloc, MaterialesState>(
      builder: (context, state) {
        if (state is MaterialesLoaded) {
          final materialesActivos = state.materiales.where((m) => m.activo).toList();
          return DropdownButtonFormField<String>(
            value: _selectedMaterialId,
            decoration: InputDecoration(
              labelText: 'Material *',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.layers),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.md,
              ),
            ),
            items: materialesActivos.map((material) {
              return DropdownMenuItem(
                value: material.id,
                child: Text(material.nombre),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedMaterialId = value),
          );
        }
        return const LinearProgressIndicator();
      },
    );
  }

  Widget _buildTipoDropdown() {
    return BlocBuilder<TiposBloc, TiposState>(
      builder: (context, state) {
        if (state is TiposLoaded) {
          final tiposActivos = state.tipos.where((t) => t.activo).toList();
          return DropdownButtonFormField<String>(
            value: _selectedTipoId,
            decoration: InputDecoration(
              labelText: 'Tipo *',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.category),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.md,
              ),
            ),
            items: tiposActivos.map((tipo) {
              return DropdownMenuItem(
                value: tipo.id,
                child: Text(tipo.nombre),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedTipoId = value),
          );
        }
        return const LinearProgressIndicator();
      },
    );
  }

  Widget _buildSistemaTallaDropdown() {
    return BlocBuilder<SistemasTallaBloc, SistemasTallaState>(
      builder: (context, state) {
        if (state is SistemasTallaLoaded) {
          final sistemasActivos = state.sistemas.where((s) => s.activo).toList();
          return DropdownButtonFormField<String>(
            value: _selectedSistemaTallaId,
            decoration: InputDecoration(
              labelText: 'Sistema Talla *',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.straighten),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.md,
              ),
            ),
            items: sistemasActivos.map((sistema) {
              return DropdownMenuItem(
                value: sistema.id,
                child: Text(sistema.nombre),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSistemaTallaId = value;
                _selectedValorTallaId = null;
              });
            },
          );
        }
        return const LinearProgressIndicator();
      },
    );
  }

  Widget _buildValorTallaDropdown() {
    return BlocBuilder<SistemasTallaBloc, SistemasTallaState>(
      builder: (context, state) {
        if (_selectedSistemaTallaId == null) {
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Valor de Talla *',
              filled: true,
              fillColor: Colors.grey[100],
              prefixIcon: const Icon(Icons.format_size),
              helperText: 'Seleccione primero un sistema de tallas',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: DesignColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: DesignColors.border, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.md,
              ),
            ),
            items: const [],
            onChanged: null,
          );
        }

        if (state is SistemasTallaLoaded) {
          try {
            final sistema = state.sistemas.firstWhere(
              (s) => s.id == _selectedSistemaTallaId,
              orElse: () => throw Exception('Sistema no encontrado'),
            );

            final valores = sistema.valores;

            if (valores.isEmpty) {
              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Valor de Talla *',
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: const Icon(Icons.warning, color: Colors.orange),
                  helperText: 'Este sistema no tiene valores configurados',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: DesignColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: DesignColors.border, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.md,
                    vertical: DesignSpacing.md,
                  ),
                ),
                items: const [],
                onChanged: null,
              );
            }

            return DropdownButtonFormField<String>(
              value: _selectedValorTallaId,
              decoration: InputDecoration(
                labelText: 'Valor de Talla *',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.format_size),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DesignSpacing.md,
                  vertical: DesignSpacing.md,
                ),
              ),
              items: valores.map((valor) {
                return DropdownMenuItem(
                  value: valor,
                  child: Text(valor),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedValorTallaId = value;
                });
              },
            );
          } catch (e) {
            return DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Valor de Talla *',
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.error, color: Colors.red),
                helperText: 'Error: Sistema no encontrado',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: DesignColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: DesignColors.border, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DesignSpacing.md,
                  vertical: DesignSpacing.md,
                ),
              ),
              items: const [],
              onChanged: null,
            );
          }
        }

        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Valor de Talla *',
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: const SizedBox(
              width: 20,
              height: 20,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            helperText: 'Cargando sistemas...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: DesignColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: DesignColors.border, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.md,
            ),
          ),
          items: const [],
          onChanged: null,
        );
      },
    );
  }

  Widget _buildDescripcionField() {
    return CorporateFormField(
      controller: _descripcionController,
      label: 'Descripción',
      hintText: 'Descripción adicional del producto (opcional)',
      prefixIcon: Icons.description,
      maxLines: 3,
      validator: (value) {
        if (value != null && value.length > 200) {
          return 'Máximo 200 caracteres';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildArticulosSection(bool isDesktop) {
    return ExpansionTile(
      title: Text(
        'ARTÍCULOS (Opcional - Puedes crear después)',
        style: TextStyle(
          fontWeight: DesignTypography.semibold,
          fontSize: DesignTypography.fontMd,
          color: DesignColors.textPrimary,
        ),
      ),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(DesignSpacing.md),
          child: ArticulosEditableTable(
            articulos: _articulos,
            onArticulosChanged: (articulos) => setState(() => _articulos = articulos),
            marcaCodigo: _getMarcaCodigo(),
            materialCodigo: _getMaterialCodigo(),
            tipoCodigo: _getTipoCodigo(),
          ),
        ),
      ],
    );
  }

  String? _getMarcaCodigo() {
    if (_selectedMarcaId == null) return null;
    final marcasBloc = context.read<MarcasBloc>();
    if (marcasBloc.state is MarcasLoaded) {
      final marca = (marcasBloc.state as MarcasLoaded).marcas.firstWhere(
        (m) => m.id == _selectedMarcaId,
      );
      return marca.codigo;
    }
    return null;
  }

  String? _getMaterialCodigo() {
    if (_selectedMaterialId == null) return null;
    final materialesBloc = context.read<MaterialesBloc>();
    if (materialesBloc.state is MaterialesLoaded) {
      final material = (materialesBloc.state as MaterialesLoaded).materiales.firstWhere(
        (m) => m.id == _selectedMaterialId,
      );
      return material.codigo;
    }
    return null;
  }

  String? _getTipoCodigo() {
    if (_selectedTipoId == null) return null;
    final tiposBloc = context.read<TiposBloc>();
    if (tiposBloc.state is TiposLoaded) {
      final tipo = (tiposBloc.state as TiposLoaded).tipos.firstWhere(
        (t) => t.id == _selectedTipoId,
      );
      return tipo.codigo;
    }
    return null;
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CorporateButton(
          text: 'Cancelar',
          variant: ButtonVariant.secondary,
          onPressed: () => context.pop(),
        ),
        const SizedBox(width: DesignSpacing.md),
        CorporateButton(
          text: 'Crear Producto Completo',
          variant: ButtonVariant.primary,
          icon: Icons.add_circle_outline,
          onPressed: _isFormValid() ? _submitForm : null,
        ),
      ],
    );
  }
}
