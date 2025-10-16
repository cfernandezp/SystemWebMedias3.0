import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/core/theme/design_tokens.dart';
import 'package:system_web_medias/features/tipos_documento/domain/entities/tipo_documento_entity.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_bloc.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_event.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_state.dart';

class TipoDocumentoFormPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const TipoDocumentoFormPage({super.key, this.arguments});

  @override
  State<TipoDocumentoFormPage> createState() => _TipoDocumentoFormPageState();
}

class _TipoDocumentoFormPageState extends State<TipoDocumentoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _longitudMinimaController = TextEditingController();
  final _longitudMaximaController = TextEditingController();

  TipoDocumentoFormato _formatoSeleccionado = TipoDocumentoFormato.numerico;
  bool _activo = true;
  bool _isEditMode = false;
  String? _tipoId;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.arguments?['mode'] == 'edit';

    if (_isEditMode && widget.arguments?['tipo'] != null) {
      final tipo = widget.arguments!['tipo'] as TipoDocumentoEntity;
      _tipoId = tipo.id;
      _codigoController.text = tipo.codigo;
      _nombreController.text = tipo.nombre;
      _formatoSeleccionado = tipo.formato;
      _longitudMinimaController.text = tipo.longitudMinima.toString();
      _longitudMaximaController.text = tipo.longitudMaxima.toString();
      _activo = tipo.activo;
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _longitudMinimaController.dispose();
    _longitudMaximaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = DesignBreakpoints.isDesktop(context);

    return BlocProvider(
      create: (_) => di.sl<TipoDocumentoBloc>(),
      child: BlocConsumer<TipoDocumentoBloc, TipoDocumentoState>(
        listener: (context, state) {
          if (state is TipoDocumentoOperationSuccess) {
            _showSnackbar(context, state.message, isError: false);
            context.pop();
          }

          if (state is TipoDocumentoError) {
            _showSnackbar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is TipoDocumentoLoading;

          return Scaffold(
            backgroundColor: DesignColors.backgroundLight,
            body: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? DesignSpacing.lg : DesignSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme, isDesktop),
                  SizedBox(height: DesignSpacing.lg),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 700 : double.infinity,
                      ),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.md),
                          side: BorderSide(color: DesignColors.border),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(DesignSpacing.lg),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCodigoField(),
                                SizedBox(height: DesignSpacing.lg),
                                _buildNombreField(),
                                SizedBox(height: DesignSpacing.lg),
                                _buildFormatoSelector(),
                                SizedBox(height: DesignSpacing.lg),
                                _buildLongitudFields(isDesktop),
                                if (_isEditMode) ...[
                                  SizedBox(height: DesignSpacing.lg),
                                  _buildActivoSwitch(),
                                ],
                                SizedBox(height: DesignSpacing.xl),
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
              color: DesignColors.primaryTurquoise,
            ),
            SizedBox(width: DesignSpacing.sm),
            Text(
              _isEditMode ? 'Editar Tipo de Documento' : 'Nuevo Tipo de Documento',
              style: TextStyle(
                fontSize: isDesktop ? DesignTypography.font3xl : DesignTypography.font2xl,
                fontWeight: DesignTypography.bold,
                color: DesignColors.primaryTurquoise,
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.sm),
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
              fontSize: DesignTypography.fontSm,
              color: DesignColors.primaryTurquoise,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm),
          child: Text(
            '>',
            style: TextStyle(
              fontSize: DesignTypography.fontSm,
              color: DesignColors.textSecondary,
            ),
          ),
        ),
        InkWell(
          onTap: () => context.go('/tipos-documento'),
          child: Text(
            'Tipos de Documento',
            style: TextStyle(
              fontSize: DesignTypography.fontSm,
              color: DesignColors.primaryTurquoise,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm),
          child: Text(
            '>',
            style: TextStyle(
              fontSize: DesignTypography.fontSm,
              color: DesignColors.textSecondary,
            ),
          ),
        ),
        Text(
          _isEditMode ? 'Editar' : 'Nuevo',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            color: DesignColors.textSecondary,
            fontWeight: DesignTypography.semibold,
          ),
        ),
      ],
    );
  }

  Widget _buildCodigoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Código',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            fontWeight: DesignTypography.semibold,
            color: DesignColors.textPrimary,
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
        TextFormField(
          controller: _codigoController,
          maxLength: 10,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            UpperCaseTextFormatter(),
          ],
          decoration: InputDecoration(
            hintText: 'Ej: DNI, RUC, PAS',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              borderSide: BorderSide(color: DesignColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              borderSide: BorderSide(color: DesignColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              borderSide: BorderSide(
                color: DesignColors.primaryTurquoise,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              borderSide: BorderSide(color: DesignColors.error),
            ),
            filled: true,
            fillColor: DesignColors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.md,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El código es requerido';
            }
            if (value.trim().length > 10) {
              return 'Máximo 10 caracteres';
            }
            if (value.contains(' ')) {
              return 'No puede contener espacios';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNombreField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            fontWeight: DesignTypography.semibold,
            color: DesignColors.textPrimary,
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
        TextFormField(
          controller: _nombreController,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Ej: Documento Nacional de Identidad',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              borderSide: BorderSide(color: DesignColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              borderSide: BorderSide(color: DesignColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              borderSide: BorderSide(
                color: DesignColors.primaryTurquoise,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignRadius.sm),
              borderSide: BorderSide(color: DesignColors.error),
            ),
            filled: true,
            fillColor: DesignColors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.md,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            if (value.trim().length > 100) {
              return 'Máximo 100 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormatoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Formato de Validación',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            fontWeight: DesignTypography.semibold,
            color: DesignColors.textPrimary,
          ),
        ),
        SizedBox(height: DesignSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildFormatoOption(
                formato: TipoDocumentoFormato.numerico,
                label: 'Numérico',
                description: 'Solo dígitos (0-9)',
                icon: Icons.pin_outlined,
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: _buildFormatoOption(
                formato: TipoDocumentoFormato.alfanumerico,
                label: 'Alfanumérico',
                description: 'Letras y números',
                icon: Icons.text_fields,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatoOption({
    required TipoDocumentoFormato formato,
    required String label,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _formatoSeleccionado == formato;
    return InkWell(
      onTap: () {
        setState(() {
          _formatoSeleccionado = formato;
        });
      },
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignColors.primaryTurquoise.withValues(alpha: 0.1)
              : DesignColors.surface,
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          border: Border.all(
            color: isSelected ? DesignColors.primaryTurquoise : DesignColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? DesignColors.primaryTurquoise : DesignColors.textSecondary,
              size: 32,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontWeight: DesignTypography.semibold,
                fontSize: DesignTypography.fontSm,
                color: isSelected ? DesignColors.primaryTurquoise : DesignColors.textPrimary,
              ),
            ),
            SizedBox(height: DesignSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: DesignTypography.fontXs,
                color: isSelected ? DesignColors.primaryTurquoise : DesignColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLongitudFields(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Longitud del Documento',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            fontWeight: DesignTypography.semibold,
            color: DesignColors.textPrimary,
          ),
        ),
        SizedBox(height: DesignSpacing.md),
        if (isDesktop)
          Row(
            children: [
              Expanded(child: _buildLongitudMinimaField()),
              SizedBox(width: DesignSpacing.md),
              Expanded(child: _buildLongitudMaximaField()),
            ],
          )
        else
          Column(
            children: [
              _buildLongitudMinimaField(),
              SizedBox(height: DesignSpacing.md),
              _buildLongitudMaximaField(),
            ],
          ),
      ],
    );
  }

  Widget _buildLongitudMinimaField() {
    return TextFormField(
      controller: _longitudMinimaController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: 'Longitud Mínima',
        hintText: 'Ej: 8',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          borderSide: BorderSide(color: DesignColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          borderSide: BorderSide(color: DesignColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          borderSide: BorderSide(
            color: DesignColors.primaryTurquoise,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          borderSide: BorderSide(color: DesignColors.error),
        ),
        filled: true,
        fillColor: DesignColors.surface,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Requerido';
        }
        final numero = int.tryParse(value);
        if (numero == null || numero <= 0) {
          return 'Debe ser mayor a 0';
        }
        return null;
      },
    );
  }

  Widget _buildLongitudMaximaField() {
    return TextFormField(
      controller: _longitudMaximaController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: 'Longitud Máxima',
        hintText: 'Ej: 8',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          borderSide: BorderSide(color: DesignColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          borderSide: BorderSide(color: DesignColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          borderSide: BorderSide(
            color: DesignColors.primaryTurquoise,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
          borderSide: BorderSide(color: DesignColors.error),
        ),
        filled: true,
        fillColor: DesignColors.surface,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Requerido';
        }
        final numero = int.tryParse(value);
        if (numero == null || numero <= 0) {
          return 'Debe ser mayor a 0';
        }
        final minima = int.tryParse(_longitudMinimaController.text);
        if (minima != null && numero < minima) {
          return 'Debe ser >= mínima';
        }
        return null;
      },
    );
  }

  Widget _buildActivoSwitch() {
    return SwitchListTile(
      value: _activo,
      onChanged: (value) {
        setState(() {
          _activo = value;
        });
      },
      title: Text(
        'Estado Activo',
        style: TextStyle(
          fontSize: DesignTypography.fontSm,
          fontWeight: DesignTypography.semibold,
          color: DesignColors.textPrimary,
        ),
      ),
      subtitle: Text(
        _activo
            ? 'Aparecerá en selectores de nuevos registros'
            : 'No aparecerá en selectores de nuevos registros',
        style: TextStyle(
          fontSize: DesignTypography.fontXs,
          color: DesignColors.textSecondary,
        ),
      ),
      activeColor: DesignColors.primaryTurquoise,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : () => context.pop(),
          child: const Text('Cancelar'),
        ),
        SizedBox(width: DesignSpacing.md),
        FilledButton(
          onPressed: isLoading ? null : () => _handleSubmit(context),
          style: FilledButton.styleFrom(
            backgroundColor: DesignColors.primaryTurquoise,
            disabledBackgroundColor: DesignColors.disabled,
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

    final codigo = _codigoController.text.trim();
    final nombre = _nombreController.text.trim();
    final longitudMinima = int.parse(_longitudMinimaController.text);
    final longitudMaxima = int.parse(_longitudMaximaController.text);

    if (_isEditMode && _tipoId != null) {
      context.read<TipoDocumentoBloc>().add(
            ActualizarTipoDocumentoEvent(
              id: _tipoId!,
              codigo: codigo,
              nombre: nombre,
              formato: _formatoSeleccionado.toBackendString(),
              longitudMinima: longitudMinima,
              longitudMaxima: longitudMaxima,
              activo: _activo,
            ),
          );
    } else {
      context.read<TipoDocumentoBloc>().add(
            CrearTipoDocumentoEvent(
              codigo: codigo,
              nombre: nombre,
              formato: _formatoSeleccionado.toBackendString(),
              longitudMinima: longitudMinima,
              longitudMaxima: longitudMaxima,
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
              color: DesignColors.surface,
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: DesignColors.surface),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? DesignColors.error : DesignColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
