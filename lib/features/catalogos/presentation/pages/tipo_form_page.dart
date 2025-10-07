import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injection/injection_container.dart' as di;
import '../../../../shared/design_system/atoms/corporate_button.dart';
import '../../../../shared/design_system/atoms/corporate_form_field.dart';
import '../bloc/tipos_bloc.dart';
import '../bloc/tipos_event.dart';
import '../bloc/tipos_state.dart';

/// Página de formulario para crear/editar tipos (CA-002, CA-005)
///
/// Criterios de Aceptación:
/// - CA-002: Agregar nuevo tipo con validaciones
/// - CA-003: Validaciones de nombre, código y descripción
/// - CA-005: Editar tipo existente (código deshabilitado)
/// - CA-006: Validación de edición
class TipoFormPage extends StatelessWidget {
  final Map<String, dynamic>? arguments;

  const TipoFormPage({Key? key, this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = arguments?['bloc'] as TiposBloc?;

    if (bloc != null) {
      return BlocProvider.value(
        value: bloc,
        child: _TipoFormView(arguments: arguments),
      );
    } else {
      return BlocProvider(
        create: (_) => di.sl<TiposBloc>(),
        child: _TipoFormView(arguments: arguments),
      );
    }
  }
}

class _TipoFormView extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const _TipoFormView({this.arguments});

  @override
  State<_TipoFormView> createState() => _TipoFormViewState();
}

class _TipoFormViewState extends State<_TipoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _codigoController = TextEditingController();
  final _imagenUrlController = TextEditingController();
  bool _activo = true;
  String? _tipoId;

  bool get _isEditMode => widget.arguments?['mode'] == 'edit';

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final tipo = widget.arguments!['tipo'] as Map<String, dynamic>;
      _tipoId = tipo['id'] as String;
      _nombreController.text = tipo['nombre'] as String;
      _descripcionController.text = tipo['descripcion'] as String? ?? '';
      _codigoController.text = tipo['codigo'] as String;
      _imagenUrlController.text = tipo['imagenUrl'] as String? ?? '';
      _activo = tipo['activo'] as bool;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _codigoController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Tipo' : 'Agregar Nuevo Tipo'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: BlocConsumer<TiposBloc, TiposState>(
        listener: (context, state) {
          if (state is TipoOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF4CAF50),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            // Navegar atrás después de operación exitosa
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                context.pop();
              }
            });
          }

          if (state is TiposError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFFF44336),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is TiposLoading;

          return Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 600 : double.infinity,
                ),
                margin: EdgeInsets.all(isDesktop ? 24 : 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título
                      Text(
                        _isEditMode ? 'Editar Tipo' : 'Nuevo Tipo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Campo Nombre (CA-002, CA-003)
                      CorporateFormField(
                        controller: _nombreController,
                        label: 'Nombre del Tipo',
                        hintText: 'Ej: Invisible, Tobillera, Media Caña',
                        prefixIcon: Icons.category,
                        textCapitalization: TextCapitalization.words,
                        validator: _validateNombre,
                        enabled: !isLoading,
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 20),

                      // Campo Código (CA-002, CA-003)
                      CorporateFormField(
                        controller: _codigoController,
                        label: 'Código (3 letras)',
                        hintText: 'Ej: INV, TOB, MCA',
                        prefixIcon: Icons.tag,
                        enabled: !_isEditMode && !isLoading, // Deshabilitado en modo edición (RN-003-004)
                        textCapitalization: TextCapitalization.characters,
                        validator: _validateCodigo,
                        onChanged: (value) {
                          // Auto-convertir a mayúsculas
                          final upperValue = value.toUpperCase();
                          if (value != upperValue) {
                            _codigoController.value = TextEditingValue(
                              text: upperValue,
                              selection: TextSelection.collapsed(
                                offset: upperValue.length,
                              ),
                            );
                          }
                          setState(() {});
                        },
                      ),

                      if (_isEditMode) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'El código no se puede modificar (RN-003-004)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Campo Descripción (CA-002, CA-003) - OPCIONAL
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CorporateFormField(
                            controller: _descripcionController,
                            label: 'Descripción (Opcional)',
                            hintText: 'Ej: Media muy baja, no visible con zapatos',
                            prefixIcon: Icons.description,
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            validator: _validateDescripcion,
                            enabled: !isLoading,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${_descripcionController.text.length}/200 caracteres',
                              style: TextStyle(
                                fontSize: 12,
                                color: _descripcionController.text.length > 200
                                    ? const Color(0xFFF44336)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Campo Imagen URL (CA-002) - OPCIONAL
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CorporateFormField(
                            controller: _imagenUrlController,
                            label: 'URL de Imagen (Opcional)',
                            hintText: 'https://ejemplo.com/imagen.jpg',
                            prefixIcon: Icons.image,
                            textCapitalization: TextCapitalization.none,
                            validator: _validateImagenUrl,
                            enabled: !isLoading,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'JPG/PNG, máximo 500KB, 300x300px recomendado',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Checkbox Activo
                      CheckboxListTile(
                        value: _activo,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _activo = value ?? true;
                                });
                              },
                        title: const Text('Activo'),
                        subtitle: Text(
                          _activo
                              ? 'Disponible para nuevos productos'
                              : 'No aparecerá en selecciones',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: CorporateButton(
                              text: 'Cancelar',
                              variant: ButtonVariant.secondary,
                              onPressed: isLoading ? null : () => context.pop(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CorporateButton(
                              text: _isEditMode ? 'Actualizar' : 'Guardar',
                              icon: _isEditMode ? Icons.save : Icons.add,
                              onPressed: isLoading ? null : () => _handleSubmit(context),
                            ),
                          ),
                        ],
                      ),

                      if (isLoading) ...[
                        const SizedBox(height: 16),
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Validar campo nombre (CA-003, CA-006, RN-003-002)
  String? _validateNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nombre es requerido';
    }

    if (value.trim().length > 50) {
      return 'Nombre máximo 50 caracteres';
    }

    return null;
  }

  /// Validar campo descripción (CA-003, RN-003-003)
  String? _validateDescripcion(String? value) {
    if (value != null && value.trim().length > 200) {
      return 'Descripción máximo 200 caracteres';
    }

    return null; // Opcional, puede ser vacío
  }

  /// Validar campo código (CA-003, RN-003-001)
  String? _validateCodigo(String? value) {
    if (_isEditMode) return null; // No validar en modo edición

    if (value == null || value.trim().isEmpty) {
      return 'Código es requerido';
    }

    final cleanValue = value.trim();

    if (cleanValue.length != 3) {
      return 'Código debe tener exactamente 3 letras';
    }

    final regExp = RegExp(r'^[A-Z]{3}$');
    if (!regExp.hasMatch(cleanValue)) {
      return 'Código solo puede contener letras mayúsculas';
    }

    return null;
  }

  /// Validar campo imagen URL (RN-003-003, RN-003-013)
  String? _validateImagenUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opcional
    }

    final cleanValue = value.trim();

    // Validar formato URL básico
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(cleanValue)) {
      return 'URL inválida';
    }

    // Validar extensión JPG/PNG
    if (!cleanValue.toLowerCase().endsWith('.jpg') &&
        !cleanValue.toLowerCase().endsWith('.jpeg') &&
        !cleanValue.toLowerCase().endsWith('.png')) {
      return 'Solo se permiten imágenes JPG o PNG';
    }

    return null;
  }

  /// Manejar envío del formulario (CA-004, CA-007)
  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final descripcion = _descripcionController.text.trim().isEmpty
        ? null
        : _descripcionController.text.trim();

    final imagenUrl = _imagenUrlController.text.trim().isEmpty
        ? null
        : _imagenUrlController.text.trim();

    if (_isEditMode) {
      context.read<TiposBloc>().add(
            UpdateTipoEvent(
              id: _tipoId!,
              nombre: _nombreController.text.trim(),
              descripcion: descripcion,
              activo: _activo,
            ),
          );
    } else {
      context.read<TiposBloc>().add(
            CreateTipoEvent(
              nombre: _nombreController.text.trim(),
              descripcion: descripcion,
              codigo: _codigoController.text.trim(),
              imagenUrl: imagenUrl,
            ),
          );
    }
  }
}
