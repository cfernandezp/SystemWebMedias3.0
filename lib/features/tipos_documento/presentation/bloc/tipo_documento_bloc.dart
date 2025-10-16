import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_web_medias/features/tipos_documento/domain/usecases/actualizar_tipo_documento_usecase.dart';
import 'package:system_web_medias/features/tipos_documento/domain/usecases/crear_tipo_documento_usecase.dart';
import 'package:system_web_medias/features/tipos_documento/domain/usecases/eliminar_tipo_documento_usecase.dart';
import 'package:system_web_medias/features/tipos_documento/domain/usecases/listar_tipos_documento_usecase.dart';
import 'package:system_web_medias/features/tipos_documento/domain/usecases/validar_formato_documento_usecase.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_event.dart';
import 'package:system_web_medias/features/tipos_documento/presentation/bloc/tipo_documento_state.dart';

class TipoDocumentoBloc extends Bloc<TipoDocumentoEvent, TipoDocumentoState> {
  final ListarTiposDocumentoUseCase listarTiposDocumentoUseCase;
  final CrearTipoDocumentoUseCase crearTipoDocumentoUseCase;
  final ActualizarTipoDocumentoUseCase actualizarTipoDocumentoUseCase;
  final EliminarTipoDocumentoUseCase eliminarTipoDocumentoUseCase;
  final ValidarFormatoDocumentoUseCase validarFormatoDocumentoUseCase;

  TipoDocumentoBloc({
    required this.listarTiposDocumentoUseCase,
    required this.crearTipoDocumentoUseCase,
    required this.actualizarTipoDocumentoUseCase,
    required this.eliminarTipoDocumentoUseCase,
    required this.validarFormatoDocumentoUseCase,
  }) : super(TipoDocumentoInitial()) {
    on<ListarTiposDocumentoEvent>(_onListarTiposDocumento);
    on<CrearTipoDocumentoEvent>(_onCrearTipoDocumento);
    on<ActualizarTipoDocumentoEvent>(_onActualizarTipoDocumento);
    on<EliminarTipoDocumentoEvent>(_onEliminarTipoDocumento);
    on<ValidarFormatoDocumentoEvent>(_onValidarFormatoDocumento);
  }

  Future<void> _onListarTiposDocumento(
    ListarTiposDocumentoEvent event,
    Emitter<TipoDocumentoState> emit,
  ) async {
    emit(TipoDocumentoLoading());

    final result = await listarTiposDocumentoUseCase(
      incluirInactivos: event.incluirInactivos,
    );

    result.fold(
      (failure) => emit(TipoDocumentoError(message: failure.message)),
      (tipos) => emit(TipoDocumentoListLoaded(tipos: tipos)),
    );
  }

  Future<void> _onCrearTipoDocumento(
    CrearTipoDocumentoEvent event,
    Emitter<TipoDocumentoState> emit,
  ) async {
    emit(TipoDocumentoLoading());

    final params = CrearTipoDocumentoParams(
      codigo: event.codigo,
      nombre: event.nombre,
      formato: event.formato,
      longitudMinima: event.longitudMinima,
      longitudMaxima: event.longitudMaxima,
    );

    final result = await crearTipoDocumentoUseCase(params);

    result.fold(
      (failure) => emit(TipoDocumentoError(message: failure.message)),
      (tipo) => emit(
        TipoDocumentoOperationSuccess(
          message: 'Tipo de documento creado exitosamente',
          tipo: tipo,
        ),
      ),
    );
  }

  Future<void> _onActualizarTipoDocumento(
    ActualizarTipoDocumentoEvent event,
    Emitter<TipoDocumentoState> emit,
  ) async {
    emit(TipoDocumentoLoading());

    final params = ActualizarTipoDocumentoParams(
      id: event.id,
      codigo: event.codigo,
      nombre: event.nombre,
      formato: event.formato,
      longitudMinima: event.longitudMinima,
      longitudMaxima: event.longitudMaxima,
      activo: event.activo,
    );

    final result = await actualizarTipoDocumentoUseCase(params);

    result.fold(
      (failure) => emit(TipoDocumentoError(message: failure.message)),
      (tipo) => emit(
        TipoDocumentoOperationSuccess(
          message: 'Tipo de documento actualizado exitosamente',
          tipo: tipo,
        ),
      ),
    );
  }

  Future<void> _onEliminarTipoDocumento(
    EliminarTipoDocumentoEvent event,
    Emitter<TipoDocumentoState> emit,
  ) async {
    emit(TipoDocumentoLoading());

    final result = await eliminarTipoDocumentoUseCase(event.id);

    result.fold(
      (failure) => emit(TipoDocumentoError(message: failure.message)),
      (_) => emit(
        const TipoDocumentoOperationSuccess(
          message: 'Tipo de documento eliminado exitosamente',
        ),
      ),
    );
  }

  Future<void> _onValidarFormatoDocumento(
    ValidarFormatoDocumentoEvent event,
    Emitter<TipoDocumentoState> emit,
  ) async {
    emit(TipoDocumentoLoading());

    final params = ValidarFormatoDocumentoParams(
      tipoDocumentoId: event.tipoDocumentoId,
      numeroDocumento: event.numeroDocumento,
    );

    final result = await validarFormatoDocumentoUseCase(params);

    result.fold(
      (failure) => emit(TipoDocumentoError(message: failure.message)),
      (esValido) => emit(
        TipoDocumentoValidationResult(
          esValido: esValido,
          message: esValido
              ? 'Documento válido'
              : 'Documento inválido según el formato del tipo',
        ),
      ),
    );
  }
}
