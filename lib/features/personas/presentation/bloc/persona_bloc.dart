import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/personas/domain/entities/persona.dart';
import 'package:system_web_medias/features/personas/domain/usecases/buscar_persona_por_documento.dart';
import 'package:system_web_medias/features/personas/domain/usecases/crear_persona.dart';
import 'package:system_web_medias/features/personas/domain/usecases/desactivar_persona.dart';
import 'package:system_web_medias/features/personas/domain/usecases/editar_persona.dart';
import 'package:system_web_medias/features/personas/domain/usecases/eliminar_persona.dart';
import 'package:system_web_medias/features/personas/domain/usecases/listar_personas.dart';
import 'package:system_web_medias/features/personas/domain/usecases/obtener_persona.dart';
import 'package:system_web_medias/features/personas/domain/usecases/reactivar_persona.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_event.dart';
import 'package:system_web_medias/features/personas/presentation/bloc/persona_state.dart';

class PersonaBloc extends Bloc<PersonaEvent, PersonaState> {
  final BuscarPersonaPorDocumento buscarPersonaPorDocumento;
  final CrearPersona crearPersona;
  final ListarPersonas listarPersonas;
  final ObtenerPersona obtenerPersona;
  final EditarPersona editarPersona;
  final DesactivarPersona desactivarPersona;
  final EliminarPersona eliminarPersona;
  final ReactivarPersona reactivarPersona;

  PersonaBloc({
    required this.buscarPersonaPorDocumento,
    required this.crearPersona,
    required this.listarPersonas,
    required this.obtenerPersona,
    required this.editarPersona,
    required this.desactivarPersona,
    required this.eliminarPersona,
    required this.reactivarPersona,
  }) : super(PersonaInitial()) {
    on<BuscarPersonaPorDocumentoEvent>(_onBuscarPersonaPorDocumento);
    on<CrearPersonaEvent>(_onCrearPersona);
    on<ListarPersonasEvent>(_onListarPersonas);
    on<ObtenerPersonaEvent>(_onObtenerPersona);
    on<EditarPersonaEvent>(_onEditarPersona);
    on<DesactivarPersonaEvent>(_onDesactivarPersona);
    on<EliminarPersonaEvent>(_onEliminarPersona);
    on<ReactivarPersonaEvent>(_onReactivarPersona);
  }

  Future<void> _onBuscarPersonaPorDocumento(
    BuscarPersonaPorDocumentoEvent event,
    Emitter<PersonaState> emit,
  ) async {
    emit(PersonaLoading());

    final result = await buscarPersonaPorDocumento(
      BuscarPersonaPorDocumentoParams(
        tipoDocumentoId: event.tipoDocumentoId,
        numeroDocumento: event.numeroDocumento,
      ),
    );

    result.fold(
      (failure) => emit(PersonaError(message: failure.message)),
      (persona) => emit(PersonaSuccess(persona: persona)),
    );
  }

  Future<void> _onCrearPersona(
    CrearPersonaEvent event,
    Emitter<PersonaState> emit,
  ) async {
    emit(PersonaLoading());

    final result = await crearPersona(
      CrearPersonaParams(
        tipoDocumentoId: event.tipoDocumentoId,
        numeroDocumento: event.numeroDocumento,
        tipoPersona: event.tipoPersona,
        nombreCompleto: event.nombreCompleto,
        razonSocial: event.razonSocial,
        email: event.email,
        celular: event.celular,
        telefono: event.telefono,
        direccion: event.direccion,
      ),
    );

    result.fold(
      (failure) => emit(PersonaError(message: failure.message)),
      (persona) => emit(PersonaSuccess(persona: persona)),
    );
  }

  Future<void> _onListarPersonas(
    ListarPersonasEvent event,
    Emitter<PersonaState> emit,
  ) async {
    emit(PersonaLoading());

    final result = await listarPersonas(
      ListarPersonasParams(
        tipoDocumentoId: event.tipoDocumentoId,
        tipoPersona: event.tipoPersona,
        activo: event.activo,
        busqueda: event.busqueda,
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(PersonaError(message: failure.message)),
      (data) {
        final items = data['items'] as List;
        final personas = items.cast<Persona>();
        emit(
          PersonaListSuccess(
            personas: personas,
            total: data['total'] as int,
            limit: data['limit'] as int,
            offset: data['offset'] as int,
            hasMore: data['hasMore'] as bool,
          ),
        );
      },
    );
  }

  Future<void> _onObtenerPersona(
    ObtenerPersonaEvent event,
    Emitter<PersonaState> emit,
  ) async {
    emit(PersonaLoading());

    final result = await obtenerPersona(
      ObtenerPersonaParams(personaId: event.personaId),
    );

    result.fold(
      (failure) => emit(PersonaError(message: failure.message)),
      (persona) => emit(PersonaSuccess(persona: persona)),
    );
  }

  Future<void> _onEditarPersona(
    EditarPersonaEvent event,
    Emitter<PersonaState> emit,
  ) async {
    emit(PersonaLoading());

    final result = await editarPersona(
      EditarPersonaParams(
        personaId: event.personaId,
        email: event.email,
        celular: event.celular,
        telefono: event.telefono,
        direccion: event.direccion,
      ),
    );

    result.fold(
      (failure) => emit(PersonaError(message: failure.message)),
      (persona) => emit(PersonaSuccess(persona: persona)),
    );
  }

  Future<void> _onDesactivarPersona(
    DesactivarPersonaEvent event,
    Emitter<PersonaState> emit,
  ) async {
    emit(PersonaLoading());

    final result = await desactivarPersona(
      DesactivarPersonaParams(
        personaId: event.personaId,
        desactivarRoles: event.desactivarRoles,
      ),
    );

    result.fold(
      (failure) => emit(PersonaError(message: failure.message)),
      (persona) => emit(PersonaSuccess(persona: persona)),
    );
  }

  Future<void> _onEliminarPersona(
    EliminarPersonaEvent event,
    Emitter<PersonaState> emit,
  ) async {
    emit(PersonaLoading());

    final result = await eliminarPersona(
      EliminarPersonaParams(personaId: event.personaId),
    );

    result.fold(
      (failure) => emit(PersonaError(message: failure.message)),
      (data) => emit(PersonaDeleteSuccess(
        message: data['message'] ?? 'Persona eliminada correctamente',
      )),
    );
  }

  Future<void> _onReactivarPersona(
    ReactivarPersonaEvent event,
    Emitter<PersonaState> emit,
  ) async {
    emit(PersonaLoading());

    final result = await reactivarPersona(
      ReactivarPersonaParams(
        personaId: event.personaId,
        email: event.email,
        celular: event.celular,
        telefono: event.telefono,
        direccion: event.direccion,
      ),
    );

    result.fold(
      (failure) => emit(PersonaError(message: failure.message)),
      (persona) => emit(PersonaSuccess(persona: persona)),
    );
  }
}
