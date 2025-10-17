import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/core/injection/injection_container.dart' as di;
import 'package:system_web_medias/core/theme/design_tokens.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_bloc.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_event.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_state.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_bloc.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_event.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_state.dart';

class BuscarPersonaWidget extends StatefulWidget {
  final Function(Persona) onPersonaFound;
  final Function(String tipoDocId, String numeroDoc) onPersonaNotFound;

  const BuscarPersonaWidget({
    super.key,
    required this.onPersonaFound,
    required this.onPersonaNotFound,
  });

  @override
  State<BuscarPersonaWidget> createState() => _BuscarPersonaWidgetState();
}

class _BuscarPersonaWidgetState extends State<BuscarPersonaWidget> {
  String? _tipoDocumentoId;
  final _numeroDocumentoController = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _numeroDocumentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<TipoDocumentoBloc>()
            ..add(const ListarTiposDocumentoEvent()),
        ),
        BlocProvider(
          create: (_) => di.sl<PersonaBloc>(),
        ),
      ],
      child: BlocListener<PersonaBloc, PersonaState>(
        listener: (context, state) {
          if (state is PersonaSuccess) {
            setState(() {
              _hasSearched = true;
            });
            widget.onPersonaFound(state.persona);
          }

          if (state is PersonaError) {
            setState(() {
              _hasSearched = true;
            });
            if (_tipoDocumentoId != null && _numeroDocumentoController.text.isNotEmpty) {
              widget.onPersonaNotFound(_tipoDocumentoId!, _numeroDocumentoController.text);
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<TipoDocumentoBloc, TipoDocumentoState>(
              builder: (context, state) {
                if (state is TipoDocumentoListLoaded) {
                  final tiposActivos = state.tipos.where((td) => td.activo).toList();

                  return DropdownButtonFormField<String>(
                    value: _tipoDocumentoId,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Documento *',
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: tiposActivos.map((td) {
                      return DropdownMenuItem(
                        value: td.id,
                        child: Text('${td.codigo} - ${td.nombre}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _tipoDocumentoId = value;
                        _hasSearched = false;
                      });
                    },
                  );
                }

                if (state is TipoDocumentoLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return const SizedBox.shrink();
              },
            ),
            SizedBox(height: DesignSpacing.md),
            TextField(
              controller: _numeroDocumentoController,
              decoration: InputDecoration(
                labelText: 'Número de Documento *',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignRadius.sm),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) {
                setState(() {
                  _hasSearched = false;
                });
              },
            ),
            SizedBox(height: DesignSpacing.md),
            BlocBuilder<PersonaBloc, PersonaState>(
              builder: (context, state) {
                if (state is PersonaLoading) {
                  return const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Buscando persona...'),
                      ],
                    ),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _tipoDocumentoId != null &&
                            _numeroDocumentoController.text.isNotEmpty
                        ? () => _buscarPersona(context)
                        : null,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar Persona'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                    ),
                  ),
                );
              },
            ),
            if (_hasSearched) ...[
              SizedBox(height: DesignSpacing.md),
              BlocBuilder<PersonaBloc, PersonaState>(
                builder: (context, state) {
                  if (state is PersonaError) {
                    return Container(
                      padding: EdgeInsets.all(DesignSpacing.md),
                      decoration: BoxDecoration(
                        color: DesignColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.md),
                        border: Border.all(color: DesignColors.success),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: DesignColors.success),
                          SizedBox(width: DesignSpacing.sm),
                          Expanded(
                            child: Text(
                              'Persona no encontrada. Puedes proceder a registrarla.',
                              style: TextStyle(
                                color: DesignColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _buscarPersona(BuildContext context) {
    if (_tipoDocumentoId == null || _numeroDocumentoController.text.isEmpty) {
      return;
    }

    context.read<PersonaBloc>().add(BuscarPersonaPorDocumentoEvent(
      tipoDocumentoId: _tipoDocumentoId!,
      numeroDocumento: _numeroDocumentoController.text,
    ));
  }
}
