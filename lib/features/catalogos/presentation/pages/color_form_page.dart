import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_state.dart';
import 'package:system_web_medias/features/catalogos/presentation/widgets/color_picker_field.dart';

class ColorFormPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const ColorFormPage({Key? key, this.arguments}) : super(key: key);

  @override
  State<ColorFormPage> createState() => _ColorFormPageState();
}

class _ColorFormPageState extends State<ColorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoHexController = TextEditingController();

  bool _isEditMode = false;
  String? _colorId;
  ColoresBloc? _sharedBloc;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.arguments?['mode'] == 'edit';
    _sharedBloc = widget.arguments?['bloc'] as ColoresBloc?;

    if (_isEditMode && widget.arguments?['color'] != null) {
      final colorData = widget.arguments!['color'] as Map<String, dynamic>;
      _colorId = colorData['id'] as String;
      _nombreController.text = colorData['nombre'] as String;
      _codigoHexController.text = colorData['codigoHex'] as String;
    } else {
      _codigoHexController.text = '#4ECDC4';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoHexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return BlocProvider.value(
      value: _sharedBloc!,
      child: BlocConsumer<ColoresBloc, ColoresState>(
        listener: (context, state) {
          if (state is ColorOperationSuccess) {
            _showSnackbar(context, state.message, isError: false);
            context.pop();
          }

          if (state is ColoresError) {
            _showSnackbar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is ColoresLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
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
                                _buildNombreField(),
                                const SizedBox(height: 24),
                                _buildColorPickerField(),
                                const SizedBox(height: 32),
                                _buildWarningMessage(state),
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
              _isEditMode ? 'Editar Color' : 'Agregar Color',
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
          onTap: () => context.go('/colores'),
          child: Text(
            'Colores',
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
          _isEditMode ? 'Editar' : 'Agregar',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildNombreField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre del Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nombreController,
          decoration: InputDecoration(
            hintText: 'Ej: Rojo, Azul, Verde',
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            if (value.trim().length < 3) {
              return 'El nombre debe tener al menos 3 caracteres';
            }
            if (value.trim().length > 30) {
              return 'El nombre no puede exceder 30 caracteres';
            }
            final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-]+$');
            if (!regex.hasMatch(value)) {
              return 'Solo se permiten letras, espacios y guiones';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildColorPickerField() {
    return ColorPickerField(
      label: 'Código de Color',
      controller: _codigoHexController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El código hexadecimal es requerido';
        }
        final regex = RegExp(r'^#[0-9A-Fa-f]{6}$');
        if (!regex.hasMatch(value)) {
          return 'Formato inválido. Debe ser #RRGGBB (Ej: #FF0000)';
        }
        return null;
      },
    );
  }

  Widget _buildWarningMessage(ColoresState state) {
    if (!_isEditMode) return const SizedBox.shrink();

    if (state is ColoresLoaded) {
      final color = state.colores.firstWhere(
        (c) => c.id == _colorId,
        orElse: () => state.colores.first,
      );

      if (color.productosCount > 0) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFE69C)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber,
                color: Color(0xFF856404),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Este cambio afectará a ${color.productosCount} producto${color.productosCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF856404),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButtons(BuildContext context, bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : () => context.pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: isLoading ? null : _handleSubmit,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            disabledBackgroundColor: Colors.grey,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nombre = _nombreController.text.trim();
    final codigoHex = _codigoHexController.text.trim().toUpperCase();

    if (_isEditMode && _colorId != null) {
      context.read<ColoresBloc>().add(
            UpdateColorEvent(
              id: _colorId!,
              nombre: nombre,
              codigoHex: codigoHex,
            ),
          );
    } else {
      context.read<ColoresBloc>().add(
            CreateColorEvent(
              nombre: nombre,
              codigoHex: codigoHex,
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
