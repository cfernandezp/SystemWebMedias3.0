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
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_bloc.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_event.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/bloc/producto_maestro_state.dart';
import 'package:system_web_medias/features/productos_maestros/presentation/widgets/combinacion_warning_card.dart';
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
  List<String> _warnings = [];
  bool _isLoading = false;
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
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleCancel();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text(_isEditMode ? 'Editar Producto Maestro' : 'Crear Producto Maestro'),
          backgroundColor: Colors.white,
        ),
        body: BlocListener<ProductoMaestroBloc, ProductoMaestroState>(
          listener: (context, state) {
            if (state is ProductoMaestroOperationSuccess) {
              context.pop();
            }
            if (state is ProductoMaestroError) {
              setState(() => _isLoading = false);
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_isEditMode && _articulosTotales > 0) _buildWarningCard(),
                          _buildDropdownMarca(),
                          const SizedBox(height: 16),
                          _buildDropdownMaterial(),
                          const SizedBox(height: 16),
                          _buildDropdownTipo(),
                          const SizedBox(height: 16),
                          _buildDropdownSistemaHardcoded(),
                          const SizedBox(height: 24),
                          _buildVistaPrevia(),
                          const SizedBox(height: 24),
                          _buildDescripcionField(),
                          const SizedBox(height: 24),
                          if (_warnings.isNotEmpty) CombinacionWarningCard(warnings: _warnings),
                          if (_warnings.isNotEmpty) const SizedBox(height: 24),
                          _buildButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
          return DropdownButtonFormField<String>(
            value: _marcaId,
            decoration: InputDecoration(
              labelText: 'Marca *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: (_isEditMode && _articulosTotales > 0) ? const Color(0xFFF3F4F6) : Colors.white,
            ),
            items: activas.map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre))).toList(),
            onChanged: (_isEditMode && _articulosTotales > 0) ? null : (v) => setState(() => _marcaId = v),
            validator: (v) => v == null ? 'Campo requerido' : null,
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
          return DropdownButtonFormField<String>(
            value: _materialId,
            decoration: InputDecoration(
              labelText: 'Material *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: (_isEditMode && _articulosTotales > 0) ? const Color(0xFFF3F4F6) : Colors.white,
            ),
            items: activos.map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre))).toList(),
            onChanged: (_isEditMode && _articulosTotales > 0) ? null : (v) => setState(() => _materialId = v),
            validator: (v) => v == null ? 'Campo requerido' : null,
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
          return DropdownButtonFormField<String>(
            value: _tipoId,
            decoration: InputDecoration(
              labelText: 'Tipo *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: (_isEditMode && _articulosTotales > 0) ? const Color(0xFFF3F4F6) : Colors.white,
            ),
            items: activos.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nombre))).toList(),
            onChanged: (_isEditMode && _articulosTotales > 0)
                ? null
                : (v) {
                    setState(() => _tipoId = v);
                    _validateCombinacion();
                  },
            validator: (v) => v == null ? 'Campo requerido' : null,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDropdownSistemaHardcoded() {
    final sistemas = [
      {'id': 'sistema-1', 'nombre': 'NÚMERO (35-44)'},
      {'id': 'sistema-2', 'nombre': 'LETRA (S-XXL)'},
      {'id': 'sistema-3', 'nombre': 'ÚNICA'},
    ];
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _sistemaId,
            decoration: InputDecoration(
              labelText: 'Sistema de Tallas *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: (_isEditMode && _articulosTotales > 0) ? const Color(0xFFF3F4F6) : Colors.white,
            ),
            items: sistemas.map((s) => DropdownMenuItem(value: s['id'], child: Text(s['nombre']!))).toList(),
            onChanged: (_isEditMode && _articulosTotales > 0)
                ? null
                : (v) {
                    setState(() => _sistemaId = v);
                    _validateCombinacion();
                  },
            validator: (v) => v == null ? 'Campo requerido' : null,
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Valores disponibles del sistema de tallas seleccionado',
          child: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildVistaPrevia() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Vista Previa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getNombreCompuesto(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildDescripcionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: _descripcionController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            labelText: 'Descripción (opcional)',
            hintText: 'Ej: Línea premium invierno 2025',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            counterText: '',
          ),
          onChanged: (v) => setState(() => _charCount = v.length),
          validator: (v) => (v != null && v.length > 200) ? 'Máximo 200 caracteres' : null,
        ),
        const SizedBox(height: 4),
        Text(
          '$_charCount/200',
          style: TextStyle(fontSize: 12, color: _charCount > 200 ? const Color(0xFFF44336) : const Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isLoading ? null : _handleCancel,
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 12),
        CorporateButton(
          text: _isEditMode ? 'Actualizar' : 'Guardar',
          onPressed: _isLoading ? null : _handleSubmit,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  String _getNombreCompuesto() {
    if (_marcaId == null || _materialId == null || _tipoId == null || _sistemaId == null) {
      return 'Selecciona todos los campos para ver el nombre...';
    }
    return 'Vista previa disponible al guardar';
  }

  void _validateCombinacion() {
    if (_tipoId != null && _sistemaId != null) {
      context.read<ProductoMaestroBloc>().add(ValidarCombinacionEvent(tipoId: _tipoId!, sistemaTallaId: _sistemaId!));
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      if (_isEditMode) {
        context.read<ProductoMaestroBloc>().add(EditarProductoMaestroEvent(
              productoId: widget.arguments!['productoId'],
              descripcion: _descripcionController.text.trim(),
            ));
      } else {
        context.read<ProductoMaestroBloc>().add(CrearProductoMaestroEvent(
              marcaId: _marcaId!,
              materialId: _materialId!,
              tipoId: _tipoId!,
              sistemaTallaId: _sistemaId!,
              descripcion: _descripcionController.text.trim(),
            ));
      }
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
    return _marcaId != null || _materialId != null || _tipoId != null || _sistemaId != null || _descripcionController.text.isNotEmpty;
  }
}
