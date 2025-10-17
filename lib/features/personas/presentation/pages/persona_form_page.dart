import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/core/theme/design_tokens.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_bloc.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_event.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_state.dart';
import 'package:system_web_medias/features/personas/presentation/widgets/buscar_persona_widget.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';

class PersonaFormPage extends StatelessWidget {
  final Map<String, dynamic>? arguments;

  const PersonaFormPage({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = di.sl<PersonaBloc>();
        final personaId = arguments?['personaId'];
        if (personaId != null) {
          bloc.add(ObtenerPersonaEvent(personaId: personaId));
        }
        return bloc;
      },
      child: _PersonaFormView(
        mode: arguments?['mode'] ?? 'create',
        personaId: arguments?['personaId'],
      ),
    );
  }
}

class _PersonaFormView extends StatefulWidget {
  final String mode;
  final String? personaId;

  const _PersonaFormView({
    required this.mode,
    this.personaId,
  });

  @override
  State<_PersonaFormView> createState() => _PersonaFormViewState();
}

class _PersonaFormViewState extends State<_PersonaFormView> {
  bool _personaBuscada = false;
  bool _personaExiste = false;
  Persona? _personaEncontrada;

  String? _tipoDocumentoId;
  String? _numeroDocumento;
  TipoPersona? _tipoPersona;

  final _nombreController = TextEditingController();
  final _razonSocialController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  String? _nombreError;
  String? _razonSocialError;
  String? _emailError;
  String? _celularError;

  @override
  void dispose() {
    _nombreController.dispose();
    _razonSocialController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = DesignBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: DesignColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.mode == 'edit' ? 'Editar Persona' : 'Nueva Persona',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<PersonaBloc, PersonaState>(
        listener: (context, state) {
          if (state is PersonaSuccess) {
            _showSnackbar(
              context,
              widget.mode == 'edit'
                  ? 'Persona actualizada exitosamente'
                  : 'Persona creada exitosamente',
              isError: false,
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                context.push('/personas-detail', extra: {'personaId': state.persona.id});
              }
            });
          }

          if (state is PersonaError) {
            _showSnackbar(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (widget.mode == 'edit' && state is PersonaSuccess && !_personaBuscada) {
            _cargarDatosPersona(state.persona);
          }

          if (state is PersonaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 800 : double.infinity,
                ),
                padding: EdgeInsets.all(isDesktop ? DesignSpacing.xl : DesignSpacing.md),
                child: Card(
                  elevation: DesignElevation.md,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignRadius.md),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(DesignSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.mode == 'create') ...[
                          _buildSeccionBusqueda(context),
                          if (_personaBuscada && !_personaExiste) ...[
                            SizedBox(height: DesignSpacing.lg),
                            Divider(),
                            SizedBox(height: DesignSpacing.lg),
                            _buildFormularioCompleto(context, isDesktop),
                          ],
                        ] else ...[
                          _buildFormularioEdicion(context, isDesktop),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeccionBusqueda(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso 1: Buscar Persona',
          style: TextStyle(
            fontSize: DesignTypography.fontXl,
            fontWeight: DesignTypography.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
        Text(
          'Verifica si la persona ya existe antes de crear una nueva',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            color: DesignColors.textSecondary,
          ),
        ),
        SizedBox(height: DesignSpacing.lg),
        BuscarPersonaWidget(
          onPersonaFound: (persona) {
            setState(() {
              _personaBuscada = true;
              _personaExiste = true;
              _personaEncontrada = persona;
            });
          },
          onPersonaNotFound: (tipoDocId, numeroDoc) {
            setState(() {
              _personaBuscada = true;
              _personaExiste = false;
              _tipoDocumentoId = tipoDocId;
              _numeroDocumento = numeroDoc;
            });
          },
        ),
        if (_personaExiste && _personaEncontrada != null) ...[
          SizedBox(height: DesignSpacing.lg),
          _buildPersonaExistenteCard(context),
        ],
      ],
    );
  }

  Widget _buildPersonaExistenteCard(BuildContext context) {
    final persona = _personaEncontrada!;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignRadius.md),
        border: Border.all(color: DesignColors.info),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: DesignColors.info),
              SizedBox(width: DesignSpacing.sm),
              Expanded(
                child: Text(
                  'Persona Encontrada',
                  style: TextStyle(
                    fontSize: DesignTypography.fontMd,
                    fontWeight: DesignTypography.semibold,
                    color: DesignColors.info,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            persona.nombreCompleto ?? persona.razonSocial ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: DesignSpacing.xs),
          Text('${persona.tipoDocumentoId}: ${persona.numeroDocumento}'),
          Text('Estado: ${persona.activo ? "Activo" : "Inactivo"}'),
          SizedBox(height: DesignSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/personas-detail', extra: {'personaId': persona.id});
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Ver Persona Existente'),
                ),
              ),
              if (!persona.activo) ...[
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<PersonaBloc>().add(ReactivarPersonaEvent(
                        personaId: persona.id,
                        email: _emailController.text.isEmpty ? null : _emailController.text,
                        celular: _celularController.text.isEmpty ? null : _celularController.text,
                        telefono: _telefonoController.text.isEmpty ? null : _telefonoController.text,
                        direccion: _direccionController.text.isEmpty ? null : _direccionController.text,
                      ));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reactivar Persona'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.success,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioCompleto(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paso 2: Datos de la Persona',
          style: TextStyle(
            fontSize: DesignTypography.fontXl,
            fontWeight: DesignTypography.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: DesignSpacing.lg),
        Text(
          'Tipo de Persona *',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            fontWeight: DesignTypography.semibold,
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
        Row(
          children: [
            Expanded(
              child: RadioListTile<TipoPersona>(
                title: const Text('Natural'),
                subtitle: const Text('Persona física'),
                value: TipoPersona.natural,
                groupValue: _tipoPersona,
                onChanged: (value) {
                  setState(() {
                    _tipoPersona = value;
                    _razonSocialController.clear();
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<TipoPersona>(
                title: const Text('Jurídica'),
                subtitle: const Text('Empresa'),
                value: TipoPersona.juridica,
                groupValue: _tipoPersona,
                onChanged: (value) {
                  setState(() {
                    _tipoPersona = value;
                    _nombreController.clear();
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.lg),
        if (_tipoPersona == TipoPersona.natural)
          _buildTextField(
            controller: _nombreController,
            label: 'Nombre Completo *',
            error: _nombreError,
            icon: Icons.person,
          ),
        if (_tipoPersona == TipoPersona.juridica)
          _buildTextField(
            controller: _razonSocialController,
            label: 'Razón Social *',
            error: _razonSocialError,
            icon: Icons.business,
          ),
        SizedBox(height: DesignSpacing.md),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          error: _emailError,
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: DesignSpacing.md),
        _buildTextField(
          controller: _celularController,
          label: 'Celular',
          error: _celularError,
          icon: Icons.phone_android,
          keyboardType: TextInputType.phone,
          maxLength: 9,
        ),
        SizedBox(height: DesignSpacing.md),
        _buildTextField(
          controller: _telefonoController,
          label: 'Teléfono Fijo',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: DesignSpacing.md),
        _buildTextField(
          controller: _direccionController,
          label: 'Dirección',
          icon: Icons.location_on,
          maxLines: 3,
        ),
        SizedBox(height: DesignSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancelar'),
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: _validarYGuardar,
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormularioEdicion(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editar Datos de Contacto',
          style: TextStyle(
            fontSize: DesignTypography.fontXl,
            fontWeight: DesignTypography.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
        Text(
          'Solo puedes modificar los datos de contacto. Tipo y número de documento son inmutables.',
          style: TextStyle(
            fontSize: DesignTypography.fontSm,
            color: DesignColors.textSecondary,
          ),
        ),
        SizedBox(height: DesignSpacing.lg),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          error: _emailError,
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: DesignSpacing.md),
        _buildTextField(
          controller: _celularController,
          label: 'Celular',
          error: _celularError,
          icon: Icons.phone_android,
          keyboardType: TextInputType.phone,
          maxLength: 9,
        ),
        SizedBox(height: DesignSpacing.md),
        _buildTextField(
          controller: _telefonoController,
          label: 'Teléfono Fijo',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: DesignSpacing.md),
        _buildTextField(
          controller: _direccionController,
          label: 'Dirección',
          icon: Icons.location_on,
          maxLines: 3,
        ),
        SizedBox(height: DesignSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancelar'),
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: _validarYActualizar,
                child: const Text('Guardar Cambios'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? error,
    IconData? icon,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignRadius.sm),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (_) {
        setState(() {
          _nombreError = null;
          _razonSocialError = null;
          _emailError = null;
          _celularError = null;
        });
      },
    );
  }

  void _cargarDatosPersona(Persona persona) {
    setState(() {
      _personaBuscada = true;
      _tipoDocumentoId = persona.tipoDocumentoId;
      _numeroDocumento = persona.numeroDocumento;
      _tipoPersona = persona.tipoPersona;
      _nombreController.text = persona.nombreCompleto ?? '';
      _razonSocialController.text = persona.razonSocial ?? '';
      _emailController.text = persona.email ?? '';
      _celularController.text = persona.celular ?? '';
      _telefonoController.text = persona.telefono ?? '';
      _direccionController.text = persona.direccion ?? '';
    });
  }

  void _validarYGuardar() {
    setState(() {
      _nombreError = null;
      _razonSocialError = null;
      _emailError = null;
      _celularError = null;
    });

    bool valido = true;

    if (_tipoPersona == null) {
      _showSnackbar(context, 'Debes seleccionar el tipo de persona', isError: true);
      return;
    }

    if (_tipoPersona == TipoPersona.natural && _nombreController.text.isEmpty) {
      setState(() {
        _nombreError = 'El nombre completo es obligatorio para persona natural';
      });
      valido = false;
    }

    if (_tipoPersona == TipoPersona.juridica && _razonSocialController.text.isEmpty) {
      setState(() {
        _razonSocialError = 'La razón social es obligatoria para persona jurídica';
      });
      valido = false;
    }

    if (_emailController.text.isNotEmpty && !_validarEmail(_emailController.text)) {
      setState(() {
        _emailError = 'Formato de email inválido';
      });
      valido = false;
    }

    if (_celularController.text.isNotEmpty && !_validarCelular(_celularController.text)) {
      setState(() {
        _celularError = 'El celular debe tener exactamente 9 dígitos';
      });
      valido = false;
    }

    if (!valido) return;

    context.read<PersonaBloc>().add(CrearPersonaEvent(
      tipoDocumentoId: _tipoDocumentoId!,
      numeroDocumento: _numeroDocumento!,
      tipoPersona: _tipoPersona!.toBackendString(),
      nombreCompleto: _tipoPersona == TipoPersona.natural ? _nombreController.text : null,
      razonSocial: _tipoPersona == TipoPersona.juridica ? _razonSocialController.text : null,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      celular: _celularController.text.isEmpty ? null : _celularController.text,
      telefono: _telefonoController.text.isEmpty ? null : _telefonoController.text,
      direccion: _direccionController.text.isEmpty ? null : _direccionController.text,
    ));
  }

  void _validarYActualizar() {
    setState(() {
      _emailError = null;
      _celularError = null;
    });

    bool valido = true;

    if (_emailController.text.isNotEmpty && !_validarEmail(_emailController.text)) {
      setState(() {
        _emailError = 'Formato de email inválido';
      });
      valido = false;
    }

    if (_celularController.text.isNotEmpty && !_validarCelular(_celularController.text)) {
      setState(() {
        _celularError = 'El celular debe tener exactamente 9 dígitos';
      });
      valido = false;
    }

    if (!valido) return;

    context.read<PersonaBloc>().add(EditarPersonaEvent(
      personaId: widget.personaId!,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      celular: _celularController.text.isEmpty ? null : _celularController.text,
      telefono: _telefonoController.text.isEmpty ? null : _telefonoController.text,
      direccion: _direccionController.text.isEmpty ? null : _direccionController.text,
    ));
  }

  bool _validarEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(email);
  }

  bool _validarCelular(String celular) {
    return celular.length == 9 && RegExp(r'^\d+$').hasMatch(celular);
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
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
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
