import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_bloc.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_event.dart';
import 'package:system_web_medias/features/catalogos/presentation/bloc/marcas_state.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_button.dart';
import 'package:system_web_medias/shared/design_system/atoms/corporate_form_field.dart';

/// Página de formulario para crear/editar marcas (CA-002, CA-005)
///
/// Criterios de Aceptación:
/// - CA-002: Agregar nueva marca con validaciones
/// - CA-003: Validaciones de nombre y código
/// - CA-005: Editar marca existente (código deshabilitado)
/// - CA-006: Validación de edición
class MarcaFormPage extends StatelessWidget {
  final Map<String, dynamic>? arguments;

  const MarcaFormPage({Key? key, this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usar instancia existente del Bloc (pasada desde MarcasListPage)
    final bloc = arguments?['bloc'] as MarcasBloc?;

    if (bloc != null) {
      // Compartir misma instancia para sincronizar estado con lista
      return BlocProvider.value(
        value: bloc,
        child: _MarcaFormView(arguments: arguments),
      );
    } else {
      // Fallback: crear nueva instancia solo si no se pasó (caso excepcional)
      return BlocProvider(
        create: (_) => di.sl<MarcasBloc>(),
        child: _MarcaFormView(arguments: arguments),
      );
    }
  }
}

class _MarcaFormView extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const _MarcaFormView({this.arguments});

  @override
  State<_MarcaFormView> createState() => _MarcaFormViewState();
}

class _MarcaFormViewState extends State<_MarcaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  bool _activo = true;
  String? _marcaId;

  bool get _isEditMode => widget.arguments?['mode'] == 'edit';

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final marca = widget.arguments!['marca'] as Map<String, dynamic>;
      _marcaId = marca['id'] as String;
      _nombreController.text = marca['nombre'] as String;
      _codigoController.text = marca['codigo'] as String;
      _activo = marca['activo'] as bool;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Marca' : 'Agregar Nueva Marca'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: BlocConsumer<MarcasBloc, MarcasState>(
        listener: (context, state) {
          // Manejar MarcaOperationSuccess
          if (state is MarcaOperationSuccess) {
            _showSnackbar(context, state.message, isError: false);
            context.pop();
          }

          // Manejar MarcasError
          if (state is MarcasError) {
            _showSnackbar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is MarcasLoading;

          return Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 500 : double.infinity,
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
                        _isEditMode ? 'Editar Marca' : 'Nueva Marca',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Campo Nombre
                      CorporateFormField(
                        controller: _nombreController,
                        label: 'Nombre de la Marca',
                        hintText: 'Ej: Adidas, Nike, Puma',
                        prefixIcon: Icons.label,
                        textCapitalization: TextCapitalization.words,
                        validator: _validateNombre,
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 20),

                      // Campo Código
                      CorporateFormField(
                        controller: _codigoController,
                        label: 'Código (3 letras)',
                        hintText: 'Ej: ADS, NIK, PUM',
                        prefixIcon: Icons.tag,
                        enabled: !_isEditMode, // Deshabilitado en modo edición
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
                          'El código no se puede modificar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Checkbox Activo
                      CheckboxListTile(
                        value: _activo,
                        onChanged: (value) {
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
                              isLoading: isLoading,
                              onPressed: () => _handleSubmit(context),
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
    );
  }

  /// Validar campo nombre (CA-003, CA-006)
  String? _validateNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nombre es requerido';
    }

    if (value.trim().length > 50) {
      return 'Nombre máximo 50 caracteres';
    }

    return null;
  }

  /// Validar campo código (CA-003)
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

  /// Manejar envío del formulario (CA-004, CA-007)
  void _handleSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditMode) {
      // Actualizar marca existente
      context.read<MarcasBloc>().add(
            UpdateMarca(
              id: _marcaId!,
              nombre: _nombreController.text.trim(),
              activo: _activo,
            ),
          );
    } else {
      // Crear nueva marca
      context.read<MarcasBloc>().add(
            CreateMarca(
              nombre: _nombreController.text.trim(),
              codigo: _codigoController.text.trim(),
              activo: _activo,
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
