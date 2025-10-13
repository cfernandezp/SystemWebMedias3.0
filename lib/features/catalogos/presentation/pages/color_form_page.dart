import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/colores_state.dart';

class ColorFormPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const ColorFormPage({super.key, this.arguments});

  @override
  State<ColorFormPage> createState() => _ColorFormPageState();
}

class _ColorFormPageState extends State<ColorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  List<String> _selectedColors = [];
  String _tipoColor = 'unico';

  ColoresBloc? _sharedBloc;

  bool _isEditMode = false;
  String? _colorId;

  bool get _canAddMoreColors {
    if (_tipoColor == 'unico') return _selectedColors.isEmpty;
    return _selectedColors.length < 3;
  }

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.arguments?['mode'] == 'edit';

    final sharedBloc = widget.arguments?['bloc'] as ColoresBloc?;
    if (sharedBloc != null) {
      _sharedBloc = sharedBloc;
    }

    if (_isEditMode && widget.arguments?['color'] != null) {
      final colorData = widget.arguments!['color'] as Map<String, dynamic>;
      _colorId = colorData['id'] as String;
      _nombreController.text = colorData['nombre'] as String;
      final codigosHex = colorData['codigosHex'];
      if (codigosHex is List) {
        _selectedColors = List<String>.from(codigosHex);
        _tipoColor = _selectedColors.length == 1 ? 'unico' : 'compuesto';
      } else if (codigosHex is String) {
        _selectedColors = [codigosHex];
        _tipoColor = 'unico';
      }
    } else {
      _selectedColors = [];
      _tipoColor = 'unico';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return BlocProvider.value(
      value: _sharedBloc ?? (di.sl<ColoresBloc>()..add(const LoadColores())),
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
                                      _buildNombreField(),
                                      const SizedBox(height: 24),
                                      _buildTipoColorSelector(),
                                      const SizedBox(height: 24),
                                      _buildColorPickerSection(),
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

  Widget _buildTipoColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Color',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTipoOption(
                value: 'unico',
                label: 'Unico',
                description: '1 color',
                icon: Icons.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTipoOption(
                value: 'compuesto',
                label: 'Compuesto',
                description: '2-3 colores',
                icon: Icons.palette,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipoOption({
    required String value,
    required String label,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _tipoColor == value;
    return InkWell(
      onTap: () {
        setState(() {
          _tipoColor = value;
          if (_tipoColor == 'unico' && _selectedColors.length > 1) {
            _selectedColors = [_selectedColors.first];
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFF6B7280),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickerSection() {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona tus colores',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _tipoColor == 'unico'
            ? 'Selecciona 1 color'
            : 'Selecciona de 2 a 3 colores',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),
        _buildColorPreview(),
        const SizedBox(height: 16),
        _buildColorChipsList(),
        const SizedBox(height: 8),
        _buildHelperText(),
        const SizedBox(height: 16),
        _buildInlineColorPalette(isDesktop),
      ],
    );
  }

  Widget _buildColorPreview() {
    if (_selectedColors.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
        ),
        child: const Icon(
          Icons.palette_outlined,
          size: 48,
          color: Colors.grey,
        ),
      );
    }

    if (_selectedColors.length == 1) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: _hexToColor(_selectedColors[0]),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
        ),
      );
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
      ),
      child: Row(
        children: _selectedColors.asMap().entries.map((entry) {
          final index = entry.key;
          final hexCode = entry.value;

          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _hexToColor(hexCode),
                borderRadius: index == 0
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      )
                    : index == _selectedColors.length - 1
                        ? const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          )
                        : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorChipsList() {
    if (_selectedColors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Center(
          child: Text(
            'No hay codigos hex agregados',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedColors.asMap().entries.map((entry) {
        final index = entry.key;
        final hexCode = entry.value;

        return Chip(
          avatar: CircleAvatar(
            backgroundColor: _hexToColor(hexCode),
          ),
          label: Text(
            hexCode.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () {
            setState(() {
              _selectedColors.removeAt(index);
            });
          },
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey[300]!),
        );
      }).toList(),
    );
  }

  Widget _buildInlineColorPalette(bool isDesktop) {
    final commonColors = [
      '#FF0000', '#DC143C', '#FF6B6B', '#FF1744', '#F44336',
      '#E91E63', '#FF69B4', '#FFB6C1', '#FFC0CB', '#C71585',
      '#FFA500', '#FF8C00', '#FF7F50', '#FF4500', '#FFD700',
      '#FFFF00', '#FFF44F', '#FFEB3B', '#FFC107', '#FF9800',
      '#00FF00', '#32CD32', '#228B22', '#008000', '#00FA9A',
      '#00CED1', '#4CAF50', '#8BC34A', '#CDDC39', '#66BB6A',
      '#0000FF', '#1E90FF', '#4169E1', '#00BFFF', '#87CEEB',
      '#87CEFA', '#2196F3', '#03A9F4', '#00BCD4', '#3F51B5',
      '#800080', '#8B008B', '#9370DB', '#BA55D3', '#DDA0DD',
      '#EE82EE', '#FF00FF', '#9C27B0', '#673AB7', '#6A1B9A',
      '#A52A2A', '#8B4513', '#D2691E', '#CD853F', '#DEB887',
      '#F5DEB3', '#D7CCC8', '#BCAAA4', '#795548', '#6D4C41',
      '#000000', '#2C3E50', '#34495E', '#808080', '#A9A9A9',
      '#D3D3D3', '#E0E0E0', '#F5F5F5', '#FAFAFA', '#FFFFFF',
    ];

    final circleSize = isDesktop ? 36.0 : 32.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paleta de colores disponibles',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: commonColors.map((hex) {
              final isSelected = _selectedColors.contains(hex);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedColors.remove(hex);
                    } else {
                      if (_canAddMoreColors) {
                        _selectedColors.add(hex);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _tipoColor == 'unico'
                                ? 'Color unico: solo puedes seleccionar 1 color'
                                : 'Color compuesto: maximo 3 colores',
                            ),
                            backgroundColor: const Color(0xFFFF9800),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  });
                },
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: _hexToColor(hex),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (_isLightColor(hex) ? Colors.grey.shade400 : const Color(0xFFE5E7EB)),
                      width: isSelected ? 3 : 1.5,
                    ),
                  ),
                  child: isSelected
                    ? Icon(
                        Icons.check,
                        color: _isLightColor(hex) ? Colors.black : Colors.white,
                        size: 18,
                      )
                    : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperText() {
    if (_selectedColors.isEmpty) {
      return Text(
        _tipoColor == 'unico'
          ? 'Selecciona 1 color de la paleta'
          : 'Selecciona de 2 a 3 colores de la paleta',
        style: const TextStyle(
          color: Color(0xFFF44336),
          fontSize: 12,
        ),
      );
    }

    if (_tipoColor == 'unico') {
      return const Text(
        'Color unico seleccionado',
        style: TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (_selectedColors.length == 1) {
      return const Text(
        'Color compuesto: agrega al menos 1 color mas',
        style: TextStyle(
          color: Color(0xFFFF9800),
          fontSize: 12,
        ),
      );
    }

    return Text(
      'Color compuesto (${_selectedColors.length} tonos)',
      style: const TextStyle(
        color: Color(0xFF4CAF50),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      try {
        return Color(int.parse('FF$hex', radix: 16));
      } catch (e) {
        return Colors.grey;
      }
    }
    return Colors.grey;
  }

  bool _isLightColor(String hex) {
    final color = _hexToColor(hex);
    final luminance = color.computeLuminance();
    return luminance > 0.7;
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
          onPressed: isLoading ? null : () => _handleSubmit(context),
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

  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedColors.isEmpty) {
      _showSnackbar(
        context,
        'Debe seleccionar al menos 1 color',
        isError: true,
      );
      return;
    }

    if (_tipoColor == 'unico' && _selectedColors.length != 1) {
      _showSnackbar(
        context,
        'Color unico debe tener exactamente 1 color',
        isError: true,
      );
      return;
    }

    if (_tipoColor == 'compuesto') {
      if (_selectedColors.length < 2) {
        _showSnackbar(
          context,
          'Color compuesto debe tener al menos 2 colores',
          isError: true,
        );
        return;
      }
      if (_selectedColors.length > 3) {
        _showSnackbar(
          context,
          'Color compuesto: maximo 3 colores',
          isError: true,
        );
        return;
      }
    }

    final nombre = _nombreController.text.trim();

    if (_isEditMode && _colorId != null) {
      context.read<ColoresBloc>().add(
            UpdateColorEvent(
              id: _colorId!,
              nombre: nombre,
              codigosHex: _selectedColors,
            ),
          );
    } else {
      context.read<ColoresBloc>().add(
            CreateColorEvent(
              nombre: nombre,
              codigosHex: _selectedColors,
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
